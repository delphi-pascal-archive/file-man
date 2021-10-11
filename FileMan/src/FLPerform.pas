unit FLPerform;
{$I 'defs.pas'}

interface

uses FlGrid, FLMessages, Classes, Dialogs, FLTypes, StdCtrls;

type
  PPanelRec = ^TPanelRec;
  TPanelRec = record
    Source, Target: TFLGrid;
    Left, Right: TFlGrid;
    LeftEd, RightEd,
    SourceEd, TargetEd, CmdEd: TEdit;
    end;

function PerformMsg(PanelRec: TPanelRec;
  Cmd: Cardinal; const Paths: TExtPaths): Integer;
procedure DetectPlugin(PanelRec: TPanelRec);
function ProgressProc(PluginNr:integer;SourceName,TargetName:pchar;PercentDone:integer):integer; stdcall;

var
  showProgress_min: Integer = 32*1024;
  progressInfo: TProgressInfo;

  //True = файли при знищенні поміщаються в Кошик
  win32delete: Boolean = False;

  //True = перевіряти вільне місце перед файловими операціями
  checkFreeSpace: Boolean = True;

  //True = зараз активний потік, що виконується не в фоні
  //(не виконувати ніяких команд, доки потік не завершиться).
  //Цю змінну потік повинен встановлювати і знімати сам.
  foregroundThread: Boolean = False;

  //True - при перегляді передавати в Lister список помічених файлів
  //False - передавати тільки підсвічений файл
  bListMarkedOnly: Boolean = True;
  
  bOpenAs8_3: Boolean = True;
  
  //True = при зміні диску на Alt+F1 завжди переходити в кореневий каталог
  bAlwaysToRoot: Boolean = False;

  FsMkDir: TFsMkDir;
  FsRenMovFile: TFsRenMovFile;
  FsRemoveDir: TFsRemoveDir;
  FsDeleteFile: TFsDeleteFile;

implementation

uses FLConst, SysUtils, ShellAPI, Windows, StrUtilsX, FLFunctions,
  FLMaskEx, RequestDrv, fsplugin, RequestCopyFlags, Dim, Progress,
  FLThreads, cxDrive10, Forms, FS, CommonFolders, Search, FileAttr,
  Controls;

function ProgressProc(PluginNr:integer;SourceName,TargetName:pchar;PercentDone:integer):integer; stdcall;
var
  percTotal: Integer;
begin
  if not Assigned(FmProgress) then
    begin
    result := 0;
    Exit;
    end;

  if progressInfo.SizeTotal > 0 then
    begin
    percTotal := Round(
      (progressInfo.SizeTotalDone
       + progressInfo.SizeCurrent*percentdone/100) / progressInfo.SizeTotal * 100);
    end
  else
    percTotal := 0;

  if progressInfo.SizeCurrent >= showProgress_min then
    result := fmprogress.ShowProgress(SourceName, TargetName, PercentDone, percTotal)
  else
    result := fmprogress.ShowProgress(SourceName, TargetName, 0, percTotal);
end;

{************* ПРОЦЕДУРИ ДЛЯ ВИКОРИСТАННЯ В TreeOperate **********************}

function ListProc(fi: TFileItem; pi: TProgressInfo; ExtData: Pointer): Integer;
//Формує список виділених файлів (без папок);
//в ExtData повинен бути вказівник на вже створений TStringList
var sl: TStringList;
begin
  result := 0;
  if ExtData = nil then Exit;
  sl := TStringList(ExtData);
  if ((fi.Flags and FL_MARK) = FL_MARK)
     and((fi.Attr and faDirectory) = 0) then
     begin
     sl.Add(fi.Name);
     end;
end;

{*****************************************************************************}

procedure DetectPlugin(PanelRec: TPanelRec);
//Якщо файлова система - звичайна, а не фс-плагіна, то
//використати вбудовані функції
begin
  if (PanelRec.Source.PluginIndex = 0)and(PanelRec.Target.PluginIndex = 0) then
    begin
    FsMkDir := FsMkDir_;
    FsRenMovFile := FsRenMovFile_;
    FsRemoveDir := FsRemoveDir_;
    FsDeleteFile := FsDeleteFile_;
    end;
end;

procedure ChangeDrive(Grid: TFlgrid);
var
  s: String;
  c: Char;
  pt: TPoint;

begin
  if FMDrive <> nil then Exit;
  pt.X := 0;  pt.Y := 0;
  ClientToScreen(Grid.Handle, pt);
  FmDrive := TFmDrive.Create(Application.MainForm);
  FmDrive.Left := pt.X;
  FmDrive.Top := pt.Y;
  repeat
    if FmDrive.RequestDrive(Grid.Directory[1], c) then
      s := c + ':\'
    else
      begin
      if DirectoryExists(Grid.Directory) then
        s := Grid.Directory
      else if DirectoryExists(ExtractFileDrive(Grid.Directory)) then
        s := ExtractFileDrive(Grid.Directory)
      else
        s := FirstAvailableRoot();
      end;
  until DirectoryExists(s);

  if (Grid.Directory[1] = s[1]) and (not bAlwaysToRoot) and PathExists(Grid.Directory) then
    Grid.Directory := Grid.Directory
  else
    Grid.Directory := s;
  Grid.SetFocus;
  FmDrive.Free;
  FmDrive := nil;
end;

procedure List_(hWnd: THandle; const Paths: TExtPaths;
  FileList: TStringList);
//Запускає зовнішню програму перегляду файлів
var
  i: Integer;
  params, cmd: String;
begin
  params := '';
  if (paths.Lister = '')or(FileList.Count = 0)then
    Exit;
  if paths.ListerParams <> '' then
    params := '"'+RemTemplates(paths.ListerParams, Paths)+'"';
  cmd := RemTemplates(paths.Lister, paths);
  if not FileExists(cmd) then
    begin
    Showmessage(Format(ER_NOLISTER, [cmd]));
    Exit;
    end;
  for i := 0 to FileList.Count-1 do
    {...' "' + FileList.Strings[i] + '"'; чомусь глючить, тому:}
    //params := params + ' "' + IncludeBackSlash(IncludeBackSlash(GetCurrentDir())) + FileList.Strings[i]+'"';
    params := params + ' ' + ExtractShortPathName(IncludeBackSlash(GetCurrentDir()) + FileList.Strings[i]);
  params := Trim(params);
  if paths.Lister <> '' then
    ShellExecute(hWnd,
      PAnsiChar('open'),
      PAnsiChar(cmd),
      PAnsiChar(params),
      PAnsiChar(IncludeBackSlash(GetCurrentDir())),
      SW_SHOW);
end;

procedure Edit_(hWnd: THandle; const Paths: TExtPaths;
  FileList: TStringList);
//Запускає зовнішню програму редагування файлів файлів
var
  i: Integer;
  params, cmd: String;
begin
  params := '';
  if (paths.Editor = '')or(FileList.Count = 0)then
    Exit;
  if paths.EditorParams <> '' then
    params := '"'+RemTemplates(paths.EditorParams, Paths)+'"';
  cmd := RemTemplates(paths.Editor, paths);
  if not FileExists(cmd) then
    begin
    Showmessage(Format(ER_NOEDITOR, [cmd]));
    Exit;
    end;
  for i := 0 to FileList.Count-1 do
    params := params + ' "' + IncludeBackSlash(GetCurrentDir()) + FileList.Strings[i]+'"';
  params := Trim(params);
  if paths.Editor <> '' then
    ShellExecute(hWnd,
      PAnsiChar('open'),
      PAnsiChar(cmd),
      PAnsiChar(params),
      PAnsiChar(IncludeBackSlash(GetCurrentDir())),
      SW_SHOW);
end;

{*****************************************************************************}

function PerformMsg(PanelRec: TPanelRec;
  Cmd: Cardinal; const Paths: TExtPaths): Integer;
var
  //row: Integer;
  i: Integer;
  dw: Cardinal;
  dtime: TDateTime;
  lst: TList;
  sl: TStringList;
  s: String;
  mask: TMaskEx;
  thrCopy: TCopyThread;
  thrDel: TRemoveThread;
  thrRen: TRenOnlyThread;
  dt: TDriveType;
  //di: TDriveInfo;
  Source, Target, Left, Right: TFLGrid;

begin
result := 0;
//Якщо активний не фоновий потік, то не виконувати команд
if foregroundThread then Exit;
//row := Source.Selection.Top;
Source := PanelRec.Source;
Target := PanelRec.Target;
Left := PanelRec.Left;
Right := PanelRec.Right;

{$IFDEF DEBUG}
if cmd > 0 then
  LogIt(cmd);
{$ENDIF}

case Cmd of
  0: ;
  cm_GoToParent:
    Source.UpFolder;
  cm_SelectAll:
    begin
    Source.MarkAll(True, True);
    Source.Repaint;
    end;
  cm_ClearAll:
    begin
    Source.MarkAll(False, False);
    Source.Repaint;
    end;
  cm_ExchangeSelection:
    begin
    Source.MarkInvertAll(True);
    Source.Repaint;
    end;
  cm_MatchSrc:
    Target.Directory := Source.Directory;
  cm_SrcByName:
    Source.SortFile := smName;
  cm_SrcByExt:
    Source.SortFile := smExt;
  cm_srcByDateTime:
    Source.SortFile := smDate;
  cm_SrcBySize:
    Source.SortFile := smSize;
  cm_SrcUnsorted:
    Source.SortFile := smFolder;
  cm_LeftOpenDrives:
    ChangeDrive(Left);
  cm_RightOpenDrives:
    ChangeDrive(Right);
  cm_SrcOpenDrives:
    ChangeDrive(Source);
  cm_List:
    begin
    Source.MarkAllDirs(False);
    Source.Repaint;
    sl := TStringList.Create;
    if (Source.ListInfo.SelCount = 0) or (not bListMarkedOnly) then
      begin
      if ((Source.HighlightedFile.Attr and faDirectory) = 0)
         and(Source.HighlightedFile.Name <> '') then
        sl.Add(Source.HighlightedFile.Name)
      else
        showmessage(NO_FILES_SELECTED);  
      end
    else
      begin
      lst := TList.Create;
      Source.GetTree(lst);
      Source.TreeOperate(lst, ListProc, Pointer(sl));
      lst.Clear;
      lst.Free;
      end;
    SetCurrentDir(Source.Directory);
    List_(Source.Handle, Paths, sl);
    sl.Free;
    end;
  cm_Edit:
    begin
    sl := TStringList.Create;
    if ((Source.HighlightedFile.Attr and faDirectory) = 0)
       and(Source.HighlightedFile.Name <> '') then
      sl.Add(Source.HighlightedFile.Name)
    else
      showmessage(NO_FILES_SELECTED);
    SetCurrentDir(Source.Directory);
    Edit_(Source.Handle, Paths, sl);
    sl.Free;
    end;
  cm_Return:
    begin
    if (Source.HighlightedFile.Name='')
      or(Source.HighlightedFile.Name = '..') then Exit;
    i := ShellExecute(Source.Handle,
                      PAnsiChar('open'),
                      PAnsiChar(Source.Directory + Source.HighlightedFile.Name),
                      PAnsiChar(''),
                      PAnsiChar(Source.Directory),
                      SW_SHOWNORMAL);
    if i <= 31 then
    case i of
      31: result := PerformMsg(PanelRec, cm_Associate, Paths);
      5 : ShowMessage(ER_PROGR_NOT_EXEC);
      else
        ShowMessage(Format(ER_ERROR, [i]));
      end;
    end;
  cm_Associate:
    if (Source.HighlightedFile.Name='')
      or(Source.HighlightedFile.Name = '..') then
      ShowMessage(NO_FILES_SELECTED)
    else
      begin
      if bOpenAs8_3 then
        begin
        s := ExtractShortPathName(Source.Directory + Source.HighlightedFile.Name);
        if s = '' then s := '"'+Source.Directory + Source.HighlightedFile.Name+'"';
        end
      else
        s := '"'+Source.Directory + Source.HighlightedFile.Name+'"';
      ShellOpenAs(s)
      end;
  cm_SrcAllFiles:
    Source.FilterMode := fmAll;
  cm_SrcExecs:
    Source.FilterMode := fmExecs;
  cm_RereadSource:
    if not Source.RereadSrc then
      PerformMsg(PanelRec, cm_SrcOpenDrives, Paths);
  cm_RereadLeft:
    if not Left.RereadSrc then
      PerformMsg(PanelRec, cm_LeftOpenDrives, Paths);
  cm_RereadRight:
    if not Right.RereadSrc then
      PerformMsg(PanelRec, cm_RightOpenDrives, Paths);
  cm_RereadSourceSoft:
    if not Source.RereadSoft then
      PerformMsg(PanelRec, cm_SrcOpenDrives, Paths);
  cm_RereadLeftSoft:
    if not Left.RereadSoft then
      PerformMsg(PanelRec, cm_LeftOpenDrives, Paths);
  cm_RereadRightSoft:
    if not Right.RereadSoft then
      PerformMsg(PanelRec, cm_RightOpenDrives, Paths);
  cm_SrcUserSpec:
    Source.FilterMode := fmUserSpec;
  cm_SrcUserDef:
    begin
    s := InputBox(S_NEWSEL, S_ENTMASK, '');
    if s <> '' then
      begin
      Source.UserDefFilter := s;
      PerformMsg(PanelRec, cm_SrcUserSpec, Paths);
      end
    else result := -2;
    end;
  cm_SelectCurrentExtension:
    if (Source.HighlightedFile.Attr and faDirectory)=0 then
      begin
      mask := TMaskEx.Create;
      mask.Init;
      mask.FileMask := '*'+ExtractFileExt(Source.HighlightedFile.Name);
      if mask.FileMask <> '*' then
        Source.MarkByMask(True, mask)
      else
        Source.MarkNoExtFiles(True);
      mask.Free;
      Source.Repaint;
      end;
  cm_UnselectCurrentExtension:
    if (Source.HighlightedFile.Attr and faDirectory)=0 then
      begin
      mask := TMaskEx.Create;
      mask.Init;
      mask.FileMask := '*'+ExtractFileExt(Source.HighlightedFile.Name);
      if mask.FileMask <> '*' then
        Source.MarkByMask(False, mask)
      else
        Source.MarkNoExtFiles(False);
      mask.Free;
      Source.Repaint;
      end;
  cm_GoToDir:
    if DirectoryExists(Source.Directory + Source.HighlightedFile.Name) then
      Source.GoIntoDir
    else
      begin
      Showmessage(Format(ER_NOPATH, [Source.Directory + Source.HighlightedFile.Name]));
      result := PerformMsg(PanelRec, cm_RereadSource, Paths);
      end;
  cm_GoToRoot:
    Source.Directory := IncludeBackslash(ExtractFileDrive(Source.Directory));
  cm_MkDir:
    begin
    DetectPlugin(panelRec);
    //Якщо процедура не визначена, то файлова операція не підтримується
    //активним фс-плагіном
    if @FsMkDir = nil then
      result := FS_FILE_NOTSUPPORTED
    else
      begin
      s := InputBox(S_NEWDIR, S_ENTDIR, '');
      if DirectoryExists(Source.Directory+s) then begin
        result := FS_FILE_EXISTS; Exit; end;
      if not ValidFileName(s) then begin
        result := FS_FILE_WRITEERROR; Exit; end;
      if not FsMkDir(PChar(Source.Directory + s)) then begin
        result := FS_FILE_WRITEERROR; Exit; end
      else
        begin
        PerformMsg(PanelRec, cm_ReReadLeft, Paths);
        PerformMsg(PanelRec, cm_ReReadRight, Paths);
        Source.GotoFile(Source.Directory + s);
        end;
      end;
    end;
  cm_Copy:
    begin
    FLThreads.moveFiles := False;
    thrCopy := TCopyThread.Create(True);
    thrCopy.Priority := tpIdle;
    thrCopy.Init(PanelRec, Paths);
    thrCopy.FreeOnTerminate := True;
    thrCopy.Resume;
    end;
  cm_RenMov:
    begin
    FLThreads.moveFiles := True;
    thrCopy := TCopyThread.Create(True);
    thrCopy.Init(PanelRec, Paths);
    thrCopy.Resume;
    end;
  cm_Delete:
    if MessageDlg(S_DELETE, mtConfirmation,
                  [mbOK, mbCancel], 0) = mrOK then
      begin
      thrDel := TRemoveThread.Create(True);
      thrDel.Recycle := False;
      thrDel.Init(PanelRec, Paths);
      thrDel.FreeOnTerminate := True;
      thrDel.Resume;
      end;
  cm_Recycle:
    begin
    thrDel := TRemoveThread.Create(True);
    thrDel.Recycle := win32delete;

    //Якщо файл не на жорсткому диску, не пробувати помістити його в Кошик
    for i := 0 to MAX_DRIVES do
      begin
      dt := TDriveType.Create(i);
      if ((chr(ord('A')+i)) = Source.Directory[1])
        and(dt.DriveType<>dtFixed)then
        thrDel.Recycle := False;
      dt.Free;
      end;

    thrDel.Init(PanelRec, Paths);
    thrDel.FreeOnTerminate := True;
    thrDel.Resume;
    end;
  cm_TransferLeft:
    if ((Right.HighlightedFile.Attr and faDirectory) = faDirectory)
    then
      begin
      if ((Right.HighlightedFile.Flags and FL_DIRUP) = FL_DIRUP)then
        Left.Directory := Right.Directory
      else
        Left.Directory := Right.Directory + Right.HighlightedFile.Name + '\';
      end
    else
      Left.Directory := Right.Directory;
  cm_TransferRight:
    if ((Left.HighlightedFile.Attr and faDirectory) = faDirectory)
    then
      begin
      if ((Left.HighlightedFile.Flags and FL_DIRUP) = FL_DIRUP)then
        Right.Directory := Left.Directory
      else
        Right.Directory := Left.Directory + Left.HighlightedFile.Name + '\';
      end
    else
      Right.Directory := Left.Directory;
  cm_FocusLeft:
    Left.SetFocus;
  cm_FocusRight:
    Right.SetFocus;
  cm_SpreadSelection:
    begin
    s := InputBox(S_SELFILES, S_ENTMASK, '');
    if s <> '' then
      begin
      mask := TMaskEx.Create;
      mask.FileMask := s;
      Source.MarkByMask(True, mask);
      Source.Repaint;
      mask.Free;
      end
    else result := -2;
    end;
  cm_ShrinkSelection:
    begin
    s := InputBox(S_UNSFILES, S_ENTMASK, '');
    if s <> '' then
      begin
      mask := TMaskEx.Create;
      mask.FileMask := s;
      Source.MarkByMask(False, mask);
      Source.Repaint;
      mask.Free;
      end
    else result := -2;
    end;
  cm_EditPath:
    PanelRec.SourceEd.SetFocus;
  cm_RenameOnly:
    begin
    FLThreads.moveFiles := True;
    thrRen := TRenOnlyThread.Create(True);
    thrRen.Init(PanelRec, Paths);
    thrRen.FreeOnTerminate := True;
    thrRen.Resume;
    end;
  cm_ShowOnlySelected:
    Source.HideUnmarked(True);
  cm_CountDirContent:
    begin
    Source.MarkAllDirsEx();
    Source.MarkAllDirs(False);
    end;
  cm_DirBranch:
    Source.HideAllDirs;
  cm_ExecuteDOS:
    begin
    s := GetWindowsFolder()[1] + ':\' + 'command.com';
    ShellExecute(Source.Handle,
                  PAnsiChar('open'),
                  PAnsiChar(s),
                  PAnsiChar(''),
                  PAnsiChar(Source.Directory),
                  SW_SHOWNORMAL);
    end;
  cm_SearchFor:
    begin
    FmSearch := TFmSearch.Create(Application.MainForm);
    FmSearch.Init(PanelRec, Paths);
    FmSearch.ShowModal;
    if FmSearch.FileName <> '' then
      Source.GotoFile(FmSearch.FileName);
    FmSearch.Free;
    FmSearch := nil;
    end;
  cm_About: //     :)
    ShowMessage(APP_NAME+S_ABOUT);
  cm_AddPathToCmdline:
    begin
    PanelRec.CmdEd.Text := PanelRec.CmdEd.Text + Source.Directory;
    PanelRec.CmdEd.SetFocus;
    end;
  cm_ClearCmdLine:
    begin
    PanelRec.CmdEd.Clear;
    Source.SetFocus;
    end;
  cm_Properties:
    if Source.HighlightedFile.Name <> '' then
      DisplayPropDialog(Application.Handle,
                        Source.Directory + Source.HighlightedFile.Name);
  (*cm_GetFileSpace:
    begin

    {for i := 0 to MAX_DRIVES do
      begin
      dt := TDriveType.Create(i);
      if ((chr(ord('A')+i)) = Source.Directory[1])
        and(dt.DriveType<>dtFixed)then
        begin
        dt.Free;
        Break;
        end;
      dt.Free;
      end;

    di := TDriveInfo.Create(i);

    di.Free;}


    with Source.ListInfo do
      s := 'Total space occupied: ' + SizeToStr(SelSize) + ' bytes'
        + ' in ' + SizeToStr(SelCount) + #13#10 + #13#10;
    s := s + 'Considering cluster size' + #13#10 + '  on source drive: '
      + SizeToStr(1024) + ' bytes' + #13#10 + '  on target drive: '
      + SizeToStr(1024) + ' bytes';
    ShowMessage(s);

    showmessage(inttostr(clustersize(source.Directory[1])));
    end;  *)
  cm_SetAttrib:
    if Source.ListInfo.SelCountWithDirs > 1 then
      Showmessage(ER_MULTATTR)
    else
      begin
      if Source.ListInfo.SelCount = 0 then
        Source.MarkSetMark(Source.Selection.Top, True, False);
      if (Source.FirstMarkedFile.Name <> '')
        and ((Source.FirstMarkedFile.Flags and FL_DIRUP) = 0) then
        begin
        dtime := FileTimeToDateTime(Source.FirstMarkedFile.TimeLastWrite);
        dw := Source.FirstMarkedFile.Attr;
        FmAttr := TFmAttr.Create(Application.MainForm);
        FmAttr.SetAttr(dw, dtime);
        FmAttr.Free;
        FileSetAttr(Source.Directory + Source.FirstMarkedFile.Name, dw);
        Source.MarkAll(False);
        PerformMsg(PanelRec, cm_RereadLeft, Paths);
        PerformMsg(PanelRec, cm_RereadRight, Paths);
        end
      else
        begin
        ShowMessage(NO_FILES_SELECTED);
        Source.MarkAll(False);
        Source.Repaint;
        end;
      end;
  else  //case else
    result := -1;
  end;  //end case
end;

{*****************************************************************************}

end.
