unit FLThreads;
{$I 'defs.pas'}

//!!!
//Перед файловими операціями потрібно викликати DetectPlugin()
//Перед запуском і після завершення потоку встановлювати
//  foregroundThread = True/False відповідно

interface

uses
  Classes, FLPerform, FLGrid, Windows, FLTypes, FLMaskEx;

type
  TCopyThread = class(TThread)
  private
    { Private declarations }
  protected
    FPaths: TExtPaths;
    Fpr: TPanelRec;
    procedure Execute; override;
    procedure LaunchProcess;
  public
    procedure Init(PanelRec: TPanelRec;
      const Paths: TExtPaths);
  end;

type
  TRemoveThread = class(TThread)
  private
    { Private declarations }
  protected
    FPaths: TExtPaths;
    Fpr: TPanelRec;
    procedure Execute; override;
    procedure LaunchProcess;
  public
    Recycle: Boolean;
    procedure Init(PanelRec: TPanelRec;
      const Paths: TExtPaths);
  end;

type
  TRenOnlyThread = class(TThread)
  private
    { Private declarations }
  protected
    FPaths: TExtPaths;
    Fpr: TPanelRec;
    procedure Execute; override;
    procedure LaunchProcess;
  public
    procedure Init(PanelRec: TPanelRec;
      const Paths: TExtPaths);
  end;

type
  TSearchThread = class(TThread)
  private
    FFindFile: TMsgEvent;
    FFindDir: TMsgEvent;
    FPathChange: TMsgEvent;
    FLastFile: String;
    FLastDir: String;
    FLastPath: String;
    Fpr: TPanelRec;
  protected
    procedure Execute; override;
    procedure FileFound;
    procedure DirFound;
    procedure PathChange;
    procedure FindIn(const Dir: String);
  public
    Mask: TMaskEx;
    Path: String;
    property OnFindFile: TMsgEvent read FFindFile write FFindFile;
    property OnFindDir: TMsgEvent read FFindDir write FFindDir;
    property OnPathChange: TMsgEvent read FPathChange write FPathChange; 
    procedure Init(PanelRec: TPanelRec;
      const Paths: TExtPaths);
  end;

var
  moveFiles: Boolean = False;

implementation

uses FLConst, Progress, SysUtils, fsplugin, FLFunctions,
  RequestCopyFlags, FLMessages, Dim, Dialogs, FS, Controls, Forms;

var
  copyFlagsEx: TCopyFlagsEx;

{******************************************************************************}

function RenMovProc(fi: TFileItem; pi: TProgressInfo; ExtData: Pointer): Integer;
//Копіює файли з Source в Target
//В ExtData повинен бути вказівник на TPanelRec
var
  panelRec: PPanelRec;
  ri: TRemoteInfo;
  rec: TWin32FindData;
  dt: TDateTime;
  rez: Integer;
  freeSpace: Int64;
begin
  result := 0;  //sleep(200);
{  if (ExtData = nil)or(fi.Name='') then
    begin
    result := 1;
    Exit;
    end;}
  if ((fi.Attr and faDirectory) = 0)then
    begin
    panelRec := PPanelRec(ExtData);
    FillChar(ri, SizeOf(ri), 0);
    ri.SizeLow := FileSizeLow(fi.Size);
    ri.SizeHigh := FileSizeHigh(fi.Size);
    ri.Attr := fi.Attr;
    ri.LastWriteTime := fi.TimeLastWrite;
    ProgressInfo.SizeCurrent := fi.Size;
    
    if checkFreeSpace and (panelRec^.Source.Directory[1] <> '\')then
      begin
      freeSpace := MyDiskFree(panelRec^.Target.Directory[1]);
      if freeSpace < fi.Size then
        begin
        if FileExists(panelRec^.Target.Directory + fi.Name) then
          begin
          freeSpace := freeSpace + GetFileSize(panelRec^.Target.Directory + fi.Name);
          //showmessage(inttostr(freespace)+'  '+inttostr(fi.size));
          if (freeSpace < fi.Size)and(CopyFlagsEx.Replace or CopyFlagsEx.ReplaceAll) then
            if MessageDlg(ER_NO_SPACE, mtError, [mbCancel, mbYes], 0) = mrCancel then
              begin
              result := FS_FILE_USERABORT;
              Exit;
              end;
          end
        else
          if MessageDlg(ER_NO_SPACE, mtError, [mbCancel, mbYes], 0) = mrCancel then
            begin
            result := FS_FILE_USERABORT;
            Exit;
            end;
        end;
      end;
      
    rez := FsRenMovFile(PAnsiChar(panelRec^.Source.Directory + fi.Name),
      PAnsiChar(panelRec^.Target.Directory + fi.Name),
      moveFiles, (CopyFlagsEx.Replace or CopyFlagsEx.ReplaceAll), @ri);
    case rez of
      FS_FILE_OK: Inc(progressInfo.SizeTotalDone, progressInfo.SizeCurrent);
      FS_FILE_EXISTS:
        if not (CopyFlagsEx.Skip or CopyFlagsEx.SkipAll)then
          begin
          if panelRec^.Source.Directory + fi.Name = panelRec^.Target.Directory + fi.Name then
            begin
            ShowMessage(ER_ITSELF);
            result := 1;
            Exit;
            end;
          rec := FileRec(panelRec^.Target.Directory + fi.Name);
          dt := FileTimeToDateTime(rec.ftLastWriteTime);
          FmGetFlags := TFmGetFlags.Create(Application.MainForm);
          CopyFlagsEx := FmGetFlags.DoRequestFlags(
            panelRec^.Target.Directory + fi.Name,
            SizeToStr(ConvFileSize(rec.nFileSizeHigh, rec.nFileSizeLow))+' bytes,   '+
            DateTimeToStr(dt),
            panelRec^.Source.Directory + fi.Name,
            SizeToStr(fi.Size)+' bytes,   '+
            DateTimeToStr(FileTimeToDateTime(fi.TimeLastWrite)));
          FmGetFlags.Free;
          FmGetFlags := nil;
          if CopyFlagsEx.Abort then result := FS_FILE_USERABORT
          else result := RenMovProc(fi, pi, ExtData);
          end;
      FS_FILE_WRITEERROR:
        if not (CopyFlagsEx.SkipIOError or CopyFlagsEx.SkipIOErrorAll) then
          case MessageDlg(ER_WRITEERROR, mtError,
                          [mbCancel, mbRetry, mbIgnore], 0) of
            mrCancel: result := 1;
            mrRetry: result := RenMovProc(fi, pi, ExtData);
            mrIgnore:
              begin
              CopyFlagsEx.SkipIOErrorAll := True;
              end;
            end;
      FS_FILE_READERROR:
        if not (CopyFlagsEx.SkipIOError or CopyFlagsEx.SkipIOErrorAll) then
          case MessageDlg(ER_READERROR, mtError,
                          [mbCancel, mbRetry, mbIgnore], 0) of
            mrCancel: result := 1;
            mrRetry: result := RenMovProc(fi, pi, ExtData);
            mrIgnore:
              begin
              CopyFlagsEx.SkipIOErrorAll := True;
              end;
            end;
      else
        result := 1;
      end;//end case
    end;

  CopyFlagsEx.Skip := False;
  CopyFlagsEx.Replace := False;
  CopyFlagsEx.SkipIOError := False;

end;

function CopyDirs(fi: TFileItem; pi: TProgressInfo; ExtData: Pointer): Integer;
//Копіює папки (не файли) з Source в Target
//В ExtData повинен бути вказівник на TPanelRec
var panelRec: PPanelRec;
begin
  result := 0;
  if (ExtData = nil)or(fi.Name='') then
    begin
    result := 1;
    Exit;
    end;
  panelRec := PPanelRec(ExtData);
  if ((fi.Attr and faDirectory) = faDirectory)
     and((fi.Flags and FL_DIRUP) = 0)
  then
    FsMkDir(PAnsiChar(panelRec^.Target.Directory + fi.Name));
end;

function DelDirs(fi: TFileItem; pi: TProgressInfo; ExtData: Pointer): Integer;
//Копіює папки (не файли) з Source в Target
//В ExtData повинен бути вказівник на TPanelRec
var panelRec: PPanelRec;
begin
  result := 0;
  if (ExtData = nil)or(fi.Name='') then
    begin
    result := 1;
    Exit;
    end;
  panelRec := PPanelRec(ExtData);
  if ((fi.Attr and faDirectory) = faDirectory)
     and((fi.Flags and FL_DIRUP) = 0)
  then
    FsRemoveDir(PAnsiChar(panelRec^.Source.Directory + fi.Name));
end;

function DelFiles(fi: TFileItem; pi: TProgressInfo; ExtData: Pointer): Integer;
//Знищує файли
//В ExtData повинен бути вказівник на TPanelRec
var panelRec: PPanelRec;
begin
  result := 0;
  if (ExtData = nil)or(fi.Name='') then
    begin
    result := 1;
    Exit;
    end;
  panelRec := PPanelRec(ExtData);
  if ((fi.Attr and faDirectory) = 0) then
    begin
    progressInfo.SizeCurrent := fi.Size;
    FsDeleteFile(PAnsiChar(panelRec^.Source.Directory + fi.Name));
    Inc(progressInfo.SizeTotalDone, progressInfo.SizeCurrent);
    if ProgressProc(0, PAnsiChar(panelRec^.Source.Directory + fi.Name), PAnsiChar(''), 100) <> 0 then
      result := FS_FILE_USERABORT;
    end;
end;

{******************************************************************************}

{ TCopyThread }

procedure TCopyThread.Execute;
begin
  inherited;
  Synchronize(LaunchProcess);
end;

procedure TCopyThread.Init(PanelRec: TPanelRec;
  const Paths: TExtPaths);
begin
  Fpr := panelRec;
end;

procedure TCopyThread.LaunchProcess;
var
  row: Integer;
  lst: TList;
  b: Boolean;

begin
  foregroundThread := True;

  row := Fpr.Source.Selection.Top;
  if (Fpr.Source.ListInfo.SelCount = 0) then
    begin
    if ((Fpr.Source.HighlightedFile.Flags and FL_DIRUP) = 0)
       and(Fpr.Source.HighlightedFile.Name <> '') then
      Fpr.Source.MarkSetMark(row, True, True)
    else   //не вибрано нічого
      begin
      ShowMessage(NO_FILES_SELECTED);
      foregroundThread := False;
      Exit;
      end;
    end;
  DetectPlugin(Fpr);
  lst := TList.Create;

  b := Fpr.Source.UseMaskEx;
  Fpr.Source.UseMaskEx := False;

  Fpr.Source.GetTree(lst);

  Fpr.Source.UseMaskEx := b;

  Fpr.Source.SetListInfo;
  //ініціалізація структур
  FillChar(CopyFlagsEx, SizeOf(CopyFlagsEx), 0);
  FillChar(ProgressInfo, SizeOf(ProgressInfo), 0);
  ProgressInfo.SizeTotal := Fpr.Source.ListInfo.SelSize;
  ProgressInfo.CountTotal := Fpr.Source.ListInfo.SelCount;
  //задання підпису для форми FmProgress
  FmProgress := TFmProgress.Create(Application.MainForm);
  if moveFiles then
    FmProgress.Operation.Caption := S_RENMOVE
  else
    FmProgress.Operation.Caption := S_COPY;
  FmProgress.Show;
  //ігнорувати win32delete - знищувати файли назовсім при переміщенні
  b := win32delete;
  win32delete := False;

  //операція копіювання/переміщення
  Fpr.Source.TreeOperate(lst, CopyDirs, @Fpr);
  Fpr.Source.TreeOperate2(lst, RenMovProc, @Fpr);
  if moveFiles then
    Fpr.Source.TreeOperate2inv(lst, DelDirs, @Fpr);

  //відновити попереднє значення win32delete
  win32delete := b;
  FmProgress.CloseForce;
  FmProgress.Free;
  FmProgress := nil;
  lst.Clear;
  lst.Free;

  foregroundThread := False;

  //спроба перечитати вміст обох панелей
  PerformMsg(Fpr, cm_RereadLeft, FPaths);
  PerformMsg(Fpr, cm_RereadRight, FPaths);

end;

{******************************************************************************}

{ TRemoveThread }


procedure TRemoveThread.Execute;
begin
  inherited;
  Synchronize(LaunchProcess);
end;

procedure TRemoveThread.Init(PanelRec: TPanelRec;
  const Paths: TExtPaths);
begin
  Fpr := PanelRec;
end;

procedure TRemoveThread.LaunchProcess;
var
  row: Integer;
  panelRec: TPanelRec;
  lst: TList;
  b: Boolean;

begin
  foregroundThread := True;

  row := Fpr.Source.Selection.Top;
  if (Fpr.Source.ListInfo.SelCount = 0) then
    begin
    if ((Fpr.Source.HighlightedFile.Flags and FL_DIRUP) = 0)
       and(Fpr.Source.HighlightedFile.Name <> '') then
      Fpr.Source.MarkSetMark(row, True, True)
    else   //не вибрано нічого
      begin
      ShowMessage(NO_FILES_SELECTED);
      foregroundThread := False;
      Exit;
      end;
    end;
  panelRec.Source := Fpr.Source;
  panelRec.Target := Fpr.Target;
  DetectPlugin(panelRec);
  FillChar(CopyFlagsEx, SizeOf(CopyFlagsEx), 0);
  lst := TList.Create;

  b := Fpr.Source.UseMaskEx;
  Fpr.Source.UseMaskEx := False;

  Fpr.Source.GetTree(lst);

  Fpr.Source.UseMaskEx := b;

  Fpr.Source.SetListInfo;
  FillChar(ProgressInfo, SizeOf(ProgressInfo), 0);
  ProgressInfo.SizeTotal := Fpr.Source.ListInfo.SelSize;
  ProgressInfo.CountTotal := Fpr.Source.ListInfo.SelCount;
  FmProgress := TFmProgress.Create(Application.MainForm);
  FmProgress.Operation.Caption := S_REMOVE;
  FmProgress.Show;
  b := win32delete;
  win32delete := self.Recycle;

  Fpr.Source.TreeOperate(lst, DelFiles, @panelRec);
  Fpr.Source.TreeOperate2inv(lst, DelDirs, @panelRec);

  win32delete := b;
  FmProgress.CloseForce;
  FmProgress.Free;
  FmProgress := nil;
  lst.Clear;
  lst.Free;

  foregroundThread := False;

  PerformMsg(Fpr, cm_RereadLeft, FPaths);
  PerformMsg(Fpr, cm_RereadRight, FPaths);

end;

{ TRenOnlyThread }

procedure TRenOnlyThread.Execute;
begin
  inherited;

  Synchronize(LaunchProcess);
end;

procedure TRenOnlyThread.Init(PanelRec: TPanelRec; const Paths: TExtPaths);
begin
  Fpr := PanelRec;
  FPaths := Paths;
end;

procedure TRenOnlyThread.LaunchProcess;
var
  oldName, newName: String;
  ri: TRemoteInfo;
begin
  foregroundThread := True;

  DetectPlugin(Fpr);
  if Fpr.Source.ListInfo.SelCountWithDirs > 1 then
    begin
    Showmessage(ER_MULTREN);
    foregroundThread := False;
    Exit;
    end;
  if Fpr.Source.ListInfo.SelCount = 0 then
    Fpr.Source.MarkSetMark(Fpr.Source.Selection.Top, True, False);

  oldName := Fpr.Source.FirstMarkedFile.Name;
  with Fpr.Source.FirstMarkedFile, Fpr.Source do
  if oldName <> '' then
    begin
    newName := InputBox(S_RENFILE, Format(S_RENONLY, [oldName]), oldName);
    if (newName <> '')and(newName <> oldName) then
      begin
      FillChar(ri, SizeOf(ri), 0);
      ri.SizeLow := FileSizeLow(Size);
      ri.SizeHigh := FileSizeHigh(Size);
      ri.Attr := Attr;
      ri.LastWriteTime := TimeLastWrite;
      oldName := Directory + oldName;
      newName := Directory + newName;
      if FsRenMovFile(PAnsiChar(oldName),
        PAnsiChar(newName), True, False, @ri) <> 0 then
        begin
        Showmessage(ER_RENFILE);
        Fpr.Source.Repaint;
        foregroundThread := False;
        Exit;
        end;
      end
    else
      begin
      Fpr.Source.MarkAll(False, False);
      Fpr.Source.Repaint;
      foregroundThread := False;
      Exit;
      end;
    end;
  foregroundThread := False;

  PerformMsg(Fpr, cm_RereadLeft, FPaths);
  PerformMsg(Fpr, cm_RereadRight, FPaths);

  Fpr.Source.GotoFile(newName);
end;

{ TSearchThread }

procedure TSearchThread.DirFound;
begin
  if Assigned(FFindDir) then
    FFindDir(Self, FLastDir);
end;

procedure TSearchThread.Execute;
begin
  inherited;
  foregroundThread := True;
  DetectPlugin(Fpr);

  Assert(Assigned(self.Mask), 'Thread: Assign Mask before using thread!');
  Assert(DirectoryExists(path), 'Thread: path not exists');

  FindIn(path);

  foregroundThread := False;
end;

procedure TSearchThread.FindIn(const Dir: String);
var
  H: THandle;
  b: Boolean;
  FI: TFileItem;
  _filemask: PCHar;
  _rez: TWin32FindData;

begin
  if Terminated then Exit;
  try
    _filemask:= PCHar(Dir + '*.*');
    H:= FindFirstFile(_filemask, _rez);
    if H <> INVALID_HANDLE_VALUE then
      begin
      b:= true;
      while b do
        begin
        if _rez.cFileName[0] = '.' then
          begin //if DIR_UP
          if StrComp(_rez.cFileName, '..')=0 then
            begin
            {FI:= TFileItem.Create;
            fi.Flags := FL_DIRUP;
            fi.Attr := High(Cardinal);
            FI.Name:= _rez.cFileName;
            FI.Free;}
            end;
          end
        else  //if not DIR_UP
          begin
          FI:= TFileItem.Create;
          FI.Attr:= _rez.dwFileAttributes;
          FI.Size := ConvFileSize(_rez.nFileSizeHigh, _rez.nFileSizeLow);
          FI.TimeCreation := _rez.ftCreationTime;
          FI.TimeLastAccess := _rez.ftLastAccessTime;
          FI.TimeLastWrite := _rez.ftLastWriteTime;
          FI.Name:= _rez.cFileName;
          //Застосувати розширену маску (тільки для файлів), якщо вона визначена
          if Mask.MatchMask(fi) then
            begin
            if (fi.Attr and faDirectory) = 0 then
              begin
              FLastFile := Dir + fi.Name;
              Synchronize(FileFound);
              end
            else
              begin
              FLastDir := Dir + fi.Name;
              Synchronize(DirFound);
              end
            end;
          if (fi.Attr and faDirectory) = faDirectory then
            begin
            FLastPath := Dir + fi.Name + '\';
            Synchronize(PathChange);
            FindIn(Dir + fi.Name + '\');
            end;
          FI.Free;
          //if fi
          end;
        b:= FindNextFile(H, _rez);
        end;
      end;
    windows.FindClose(H);
  finally
  end;
end;

procedure TSearchThread.Init(PanelRec: TPanelRec; const Paths: TExtPaths);
begin
  Fpr := panelRec;
end;

procedure TSearchThread.FileFound;
begin
  if Assigned(FFindFile) then
    FFindFile(Self, FLastFile);
end;

procedure TSearchThread.PathChange;
begin
  if Assigned(FPathChange) then
    FPathChange(Self, FLastPath);
end;

end.