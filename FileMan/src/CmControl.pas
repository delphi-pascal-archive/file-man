unit CmControl;
{$I 'defs.pas'}

interface

uses
  SysUtils, Classes, CmGrid, FLGrid, FLTypes, FLPerform, Menus, ComCtrls, Forms,
  StdCtrls, Controls;

type
  TGrp = Array of Cardinal;

  TCmControl = class(TComponent)
  private
    { Private declarations }
    FPan1: TCmGrid;
    FPan2: TCmGrid;
    FSource, FTarget: TFLGrid;
    FMenu: TMainMenu;
    FTool: TToolBar;
    FPrompt: TEdit;
    FUnknownCmd: TCommandEvent;
    procedure SetFPan1(const Value: TCmGrid);
    procedure SetFPan2(const Value: TCmGrid);
    procedure LinkPanel(APanel: TFLGrid);
    procedure SetToolBarFKey(const Value: TToolBar);
    function GetIniName: String;
    procedure SetIniName(const Value: String);
    procedure SetCmdPrompt(const Value: TEdit);
  protected
    { Protected declarations }
    procedure UpdateMenu(Command: Cardinal);
    procedure MenuGrpUpdate(const Group: TGrp; Cmd: Cardinal; Menu: TMenuItem);
    procedure MenuUpdFilters(Menu: TMenuItem);
    procedure LngLoadEx(const LngFile: String);
    procedure LngWriteEx(const LngFile: String);
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function PerformCmd(Command: Cardinal): Integer;
    procedure IniSaveTo();
    procedure IniLoadFrom();
    procedure SetToolBtnCaps(ShiftState: TShiftState);
    procedure MPanelColResize(Sender: TObject);
    procedure MKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure MKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure MPromptKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure MKeyPress(Sender: TObject; var Key: Char);
    procedure MEnter(Sender: TObject);
    procedure MOnSorting(Sender: TObject; SortFile: TSortFile);
    procedure MToolBtnClick(Sender: TObject);
    procedure MExecFile(Sender: TObject);
    procedure MFilterModeChanged(Sender: TObject);
    procedure MAppActivate(Sender: TObject);
    procedure MDblClick(Sender: TObject);
    property SourcePan: TFLGrid read FSource;
    property TargetPan: TFLGrid read FTarget;
    procedure ExecCmdLine(command: String);

  published
    { Published declarations }
    property FilePanel1: TCmGrid read FPan1 write SetFPan1;
    property FilePanel2: TCmGrid read FPan2 write SetFPan2;
    property Menu: TMainMenu read FMenu write FMenu;
    property CommandPrompt: TEdit read FPrompt write SetCmdPrompt;
    property IniFile: String read GetIniName write SetIniName;
    property ToolBarFKey: TToolBar read FTool write SetToolBarFKey;
    property OnUnknownCmd: TCommandEvent read FUnknownCmd write FUnknownCmd;
  end;

procedure Register;

var
  paths: TExtPaths;

implementation

uses FLConst, Windows, FLMessages, Dialogs, IniFiles, StrUtilsX,
  fsplugin, Graphics, RequestDrv, FLFunctions, ShellAPI, cxDrive10;

var
  //групи команд-перемикачів (sort: byName/bySize/byExt/byDate etc.)
  grp: Array of TGrp;
  screenMode: String;
  colorInd: String;
  colorInd_: Integer;

  bRereadCD, bRereadFD, bRereadHD, bRereadNET: Boolean;
  bDirsYourself: Boolean = True;

  bFirstActivate: Boolean = True;
  cLeftDir, cRightDir: String;

procedure Register;
begin
  RegisterComponents('Samples', [TCmControl]);
end;

procedure InitGrp;
//ініціалізація групи команд-перемикачів
begin
  //кількість груп
  SetLength(grp, 3);

  //група[0] - типи сортування
  SetLength(grp[0], 5);
  grp[0][0] := cm_SrcByName;
  grp[0][1] := cm_SrcByExt;
  grp[0][2] := cm_srcByDateTime;
  grp[0][3] := cm_SrcBySize;
  grp[0][4] := cm_SrcUnsorted;
  //група[1] - обернений порядок сортування
  SetLength(grp[1], 1);
  grp[1][0] := cm_SrcNegOrder;
  //група[2] - обернений порядок сортування
  SetLength(grp[2], 3);
  grp[2][0] := cm_SrcExecs;
  grp[2][1] := cm_SrcAllFiles;
  grp[2][2] := cm_SrcUserSpec;

end;

function GetGrpIndex(Cmd: Cardinal): Integer;
//якщо команда належить до групи, повертає індекс групи
var i, j: Integer;
begin
  result := -1;
  for i := 0 to Length(grp)-1 do
    for j := 0 to Length(grp[i])-1 do
      if grp[i][j] = cmd then
        begin
        result := i;
        Exit;
        end;
end;

function FileProc(fi: TFileItem; pi: TProgressInfo; ExtData: Pointer): Integer;
begin
  result := 0;
  if ((fi.Attr and faDirectory) = faDirectory) then
    showmessage(fi.Name);
end;

{ TCmControl }

constructor TCmControl.Create(AOwner: TComponent);
begin
  inherited;

  Application.OnActivate := MAppActivate;
  InitGrp();
end;

destructor TCmControl.Destroy;
begin

  inherited;
end;

procedure TCmControl.ExecCmdLine(command: String);
var
  cmd: Cardinal;
  cFile, cParams: String;
begin
  command := Trim(command);
  if command = '' then exit;
  cmd := 0;
  SetCurrentDir(FSource.Directory);
  if command = 'cd\' then
    cmd := cm_GoToRoot
  else if command = 'cd..' then
    cmd := cm_GoToParent
  else if (ExtractWord(1, command, [' ']) = 'cd')
    and(Length(command) >= 4) then
    begin
    cFile := Copy(command, 4, Length(command) - 3);
    cFile := Trim(cFile);
    if DirectoryExists(IncludeBackslash(cFile)) then
      FSource.Directory := ExpandFileName(cFile);
    end
  else if DirectoryExists(IncludeBackslash(command)) then
    begin
    if bDirsYourself then
      ExecCmdLine('cd ' + command)
    else
      ShellExecute(FSource.Handle,
                   PAnsiChar('open'),
                   PAnsiChar(IncludeBackslash(command)),
                   PAnsiChar(''),
                   PAnsiChar(GetCurrentDir()),
                   SW_SHOWNORMAL)
    end
  else
    begin
    ParseCmdStr(command, cFile, cParams);
    if ShellExecute(FSource.Handle,
                      PAnsiChar('open'),
                      PAnsiChar(cFile),
                      PAnsiChar(cParams),
                      PAnsiChar(GetCurrentDir()),
                      SW_SHOWNORMAL) <= 32 then
      ShowMessage(Format(ER_NOFILE, [command]));
    end;


  if cmd > 0 then
    PerformCmd(cmd);
end;

function TCmControl.GetIniName: String;
begin
  result := paths.IniFile;
end;

procedure TCmControl.IniLoadFrom();
var
  ini: TIniFile;
  i: Integer;
begin

  ini := TIniFile.Create(paths.IniFile);
  try
    paths.Lister := ini.ReadString('View/Edit', 'Lister', '%APP_PATH%\lister32\lister.exe');
    paths.ListerParams := ini.ReadString('View/Edit', 'Lister_params', '/i=%INIFILE%');
    paths.Editor := ini.ReadString('View/Edit', 'Editor', '%WINDOWS%\notepad.exe');
    paths.EditorParams := ini.ReadString('View/Edit', 'Editor_params', '');
    paths.LngFile := ini.ReadString('Configuration', 'LngFile', '%APP_PATH%\Language\english.lng');

    LngLoadEx(RemTemplates(paths.LngFile, paths));

    cLeftDir := ini.ReadString('Left', 'Path', FirstAvailableRoot());
    FPan1.Panel.SortFile := TSortFile(ini.ReadInteger('Left', 'Sortorder', Integer(smName)));
    FPan1.Panel.UserDefFilter := ini.ReadString('Left', 'Userspec', '*.*');
    cRightDir := ini.ReadString('Right', 'Path', FirstAvailableRoot());
    FPan2.Panel.SortFile := TSortFile(ini.ReadInteger('Right', 'Sortorder', Integer(smName)));
    FPan2.Panel.UserDefFilter := ini.ReadString('Right', 'Userspec', '*.*');
    bListMarkedOnly := ini.ReadBool('View/Edit', 'ListMarkedFiles', bListMarkedOnly);
    FPan1.Panel.ShowIcons := ini.ReadBool('Configuration', 'Icons', FPan1.Panel.ShowIcons);
    FPan2.Panel.ShowIcons := ini.ReadBool('Configuration', 'Icons', FPan2.Panel.ShowIcons);
    FPan1.StatusBar := ini.ReadBool('Configuration', 'StatusBar', True);
    FPan2.StatusBar := ini.ReadBool('Configuration', 'StatusBar', True);
    FPan1.PathBar := ini.ReadBool('Configuration', 'PathBar', True);
    FPan2.PathBar := ini.ReadBool('Configuration', 'PathBar', True);
    FPan1.NameBar := ini.ReadBool('Configuration', 'NameBar', True);
    FPan2.NameBar := ini.ReadBool('Configuration', 'NameBar', True);
    COPY_BUFFER := ini.ReadInteger('Configuration', 'CopyBuffer', COPY_BUFFER);
    showProgress_min := ini.ReadInteger('Configuration', 'ShowProgressMin', showProgress_min);
    if showProgress_min < COPY_BUFFER then
      showProgress_min := COPY_BUFFER;
    colorInd_ := ini.ReadInteger('Configuration', 'ColorIndex', 0);
    bOpenAs8_3 := ini.ReadBool('Configuration', 'OpenAs8.3', bOpenAs8_3);
    colorInd := 'Colors' + IntToStr(colorInd_);
    FSource.DirInBrackets := ini.ReadBool('Configuration', 'DirBrackets', FSource.DirInBrackets);
    FTarget.DirInBrackets := ini.ReadBool('Configuration', 'DirBrackets', FSource.DirInBrackets);
    FPan1.DriveInfo := ini.ReadBool('Configuration', 'DriveInfoBar', FPan1.DriveInfo);
    FPan2.DriveInfo := ini.ReadBool('Configuration', 'DriveInfoBar', FPan1.DriveInfo);
    bRereadHD := ini.ReadBool('Configuration', 'RereadHDD', True);
    bRereadCD := ini.ReadBool('Configuration', 'RereadCD', True);
    bRereadFD := ini.ReadBool('Configuration', 'RereadFDD', True);
    bRereadNET := ini.ReadBool('Configuration', 'RereadNET', True);
    FSource.DoubleBuffered := ini.ReadBool('Configuration', 'DoubleBuffered', False);
    FTarget.DoubleBuffered := ini.ReadBool('Configuration', 'DoubleBuffered', False);
    bDirsYourself := ini.ReadBool('Configuration', 'DirsYourself', bDirsYourself);
    FSource.Names8_3 := ini.ReadBool('Configuration', 'FileNames8.3', FSource.Names8_3);
    FTarget.Names8_3 := ini.ReadBool('Configuration', 'FileNames8.3', FSource.Names8_3);
    checkFreeSpace := ini.ReadBool('Configuration', 'CheckFreeSpace', checkFreeSpace);
    bAlwaysToRoot := ini.ReadBool('Configuration', 'AlwaysToRoot', bAlwaysToRoot);
    with FPan1.Panel.ColorAttr do
      begin
      Common.Backgroung := ini.ReadInteger(colorInd, 'BackColor', Common.Backgroung);
      Common.Text := ini.ReadInteger(colorInd, 'ForeColor', Common.Text);
      CommonHighlighted.Backgroung := ini.ReadInteger(colorInd, 'CursorColor', CommonHighlighted.Backgroung);
      CommonHighlighted.Text := ini.ReadInteger(colorInd, 'CursorText', CommonHighlighted.Text);
      Mark.Text := ini.ReadInteger(colorInd, 'MarkText', Mark.Text);
      Mark.Backgroung := ini.ReadInteger(colorInd, 'MarkBack', Mark.Backgroung);
      MarkHighlighted.Text := ini.ReadInteger(colorInd, 'MarkCursorText', MarkHighlighted.Text);
      MarkHighlighted.Backgroung := ini.ReadInteger(colorInd, 'MarkCursor', MarkHighlighted.Backgroung);
      end;
    with FPan2.Panel.ColorAttr do
      begin
      Common.Backgroung := ini.ReadInteger(colorInd, 'BackColor', Common.Backgroung);
      Common.Text := ini.ReadInteger(colorInd, 'ForeColor', Common.Text);
      CommonHighlighted.Backgroung := ini.ReadInteger(colorInd, 'CursorColor', CommonHighlighted.Backgroung);
      CommonHighlighted.Text := ini.ReadInteger(colorInd, 'CursorText', CommonHighlighted.Text);
      Mark.Text := ini.ReadInteger(colorInd, 'MarkText', Mark.Text);
      Mark.Backgroung := ini.ReadInteger(colorInd, 'MarkBack', Mark.Backgroung);
      MarkHighlighted.Text := ini.ReadInteger(colorInd, 'MarkCursorText', MarkHighlighted.Text);
      MarkHighlighted.Backgroung := ini.ReadInteger(colorInd, 'MarkCursor', MarkHighlighted.Backgroung);
      end;
    with FPan1.Panel.Font do
      begin
      Name := ini.ReadString(screenMode, 'FontName', Name);
      Size := ini.ReadInteger(screenMode, 'FontSize', Size);
      //Style
      if ini.ReadBool(screenMode, 'FontBold', fsBold in Style) then
        Style := Style + [fsBold]
      else
        Style := Style - [fsBold];
      if ini.ReadBool(screenMode, 'FontItalic', fsItalic in Style) then
        Style := Style + [fsItalic]
      else
        Style := Style - [fsItalic];
      if ini.ReadBool(screenMode, 'FontUnderline', fsUnderline in Style) then
        Style := Style + [fsUnderline]
      else
        Style := Style - [fsUnderline];
      end;
    with FPan2.Panel.Font do
      begin
      Name := ini.ReadString(screenMode, 'FontName', Name);
      Size := ini.ReadInteger(screenMode, 'FontSize', Size);
      //Style
      if ini.ReadBool(screenMode, 'FontBold', fsBold in Style) then
        Style := Style + [fsBold]
      else
        Style := Style - [fsBold];
      if ini.ReadBool(screenMode, 'FontItalic', fsItalic in Style) then
        Style := Style + [fsItalic]
      else
        Style := Style - [fsItalic];
      if ini.ReadBool(screenMode, 'FontUnderline', fsUnderline in Style) then
        Style := Style + [fsUnderline]
      else
        Style := Style - [fsUnderline];
      end;
    if FPrompt <> nil then
      with FPrompt, FPan2.Panel.ColorAttr do
      begin
      Color := Common.Backgroung;
      Font.Color := Common.Text;
      Font.Style := FPan2.Panel.Font.Style;
      Font.Size := FPan2.Panel.Font.Size;
      Font.Name := FPan2.Panel.Font.Name;
      end;
    FPan1.Panel.Color := FPan1.Panel.ColorAttr.Common.Backgroung;
    FPan2.Panel.Color := FPan2.Panel.ColorAttr.Common.Backgroung;
    FPan1.Color_ := FPan1.Panel.ColorAttr.Common.Backgroung;
    FPan2.Color_ := FPan2.Panel.ColorAttr.Common.Backgroung;
    RequestDrv.ColorAttr := FPan2.Panel.ColorAttr;
    for i := 0 to FPan1.Panel.ColCount - 1 do
      FPan1.Panel.ColWidths[i] :=
        ini.ReadInteger(screenMode,
        'column'+IntToStr(i)+'width', FPan1.Panel.ColWidths[i]);
    for i := 0 to FPan2.Panel.ColCount - 1 do
      FPan2.Panel.ColWidths[i] :=
        ini.ReadInteger(screenMode,
        'column'+IntToStr(i)+'width', FPan2.Panel.ColWidths[i]);
    win32delete := ini.ReadBool('Configuration', 'win32delete', win32delete);
  except
    {$IFDEF DEBUG}
    LogIt('Error: Ini load failed');
    {$ENDIF}
  end;
  ini.Free;

  ini := TIniFile.Create(RemTemplates(paths.LngFile, paths));
  try
    paths.MnuFile := ini.ReadString('FmMain', 'MnuFile', 'english.mnu');
  except
  end;
  ini.Free;

//  LngWriteEx(RemTemplates(paths.LngFile, paths));

end;

procedure TCmControl.IniSaveTo();
var
  ini: TIniFile;
  i: Integer;
begin
  ini := TIniFile.Create(paths.IniFile);
  try
    ini.WriteBool(   'Configuration', 'AlwaysToRoot', bAlwaysToRoot);
    ini.WriteBool(   'Configuration', 'DirsYourself', bDirsYourself);
    ini.WriteString( 'Configuration', 'cDirUp', S_DIR_UP);
    ini.WriteString( 'Configuration', 'cEmptyDrvLabel', NO_DRIVE_LABEL);
    ini.WriteString( 'Configuration', 'cExeMask', EXE_MASK);
    ini.WriteString( 'Configuration', 'cFolder', S_FOLDER);
    ini.WriteBool(   'Configuration', 'CheckFreeSpace', checkFreeSpace);
    ini.WriteInteger('Configuration', 'ColorIndex', colorInd_);
    ini.WriteInteger('Configuration', 'CopyBuffer', COPY_BUFFER);
    ini.WriteBool(   'Configuration', 'DirBrackets', FSource.DirInBrackets);
    ini.WriteBool(   'Configuration', 'DoubleBuffered', FSource.DoubleBuffered);
    ini.WriteBool(   'Configuration', 'DriveInfoBar', FPan1.DriveInfo);
    ini.WriteBool(   'Configuration', 'Icons', FPan1.Panel.ShowIcons);
    ini.WriteBool(   'Configuration', 'FileNames8.3', FSource.Names8_3);
    ini.WriteString( 'Configuration', 'LngFile', paths.LngFile);
    ini.WriteBool(   'Configuration', 'NameBar', FPan1.NameBar);
    ini.WriteBool(   'Configuration', 'OpenAs8.3', bOpenAs8_3);
    ini.WriteBool(   'Configuration', 'PathBar', FPan1.PathBar);
    ini.WriteBool(   'Configuration', 'RereadCD', bRereadCD);
    ini.WriteBool(   'Configuration', 'RereadFDD', bRereadFD);
    ini.WriteBool(   'Configuration', 'RereadHDD', bRereadHD);
    ini.WriteBool(   'Configuration', 'RereadNET', bRereadNET);
    ini.WriteInteger('Configuration', 'ShowProgressMin', showProgress_min);
    ini.WriteBool(   'Configuration', 'StatusBar', FPan1.StatusBar);
    ini.WriteBool(   'Configuration', 'Win32delete', win32delete);
    ini.WriteString( 'Left',          'Path', FPan1.Panel.Directory);
    ini.WriteString( 'Right',         'Path', FPan2.Panel.Directory);
    ini.WriteInteger('Left',          'Sortorder', Integer(FPan1.Panel.SortFile));
    ini.WriteInteger('Right',         'Sortorder', Integer(FPan2.Panel.SortFile));
    ini.WriteString( 'Left',          'Userspec', FPan1.Panel.UserDefFilter);
    ini.WriteString( 'Right',         'Userspec', FPan2.Panel.UserDefFilter);
    ini.WriteString( 'View/Edit',     'Lister', paths.Lister);
    ini.WriteString( 'View/Edit',     'Lister_params', paths.ListerParams);
    ini.WriteString( 'View/Edit',     'Editor', paths.Editor);
    ini.WriteString( 'View/Edit',     'Editor_params', paths.EditorParams);
    ini.WriteBool(   'View/Edit',     'ListMarkedFiles', bListMarkedOnly);
    with FPan1.Panel.ColorAttr do
      begin
      ini.WriteString(colorInd, 'BackColor', MyHex(Common.Backgroung));
      ini.WriteString(colorInd, 'ForeColor', MyHex(Common.Text));
      ini.WriteString(colorInd, 'CursorColor', MyHex(CommonHighlighted.Backgroung));
      ini.WriteString(colorInd, 'CursorText', MyHex(CommonHighlighted.Text));
      ini.WriteString(colorInd, 'MarkText', MyHex(Mark.Text));
      ini.WriteString(colorInd, 'MarkCursorText', MyHex(MarkHighlighted.Text));
      ini.WriteString(colorInd, 'MarkCursor', MyHex(MarkHighlighted.Backgroung));
      ini.WriteString(colorInd, 'MarkBack', MyHex(Mark.Backgroung));
      end;
    with FPan1.Panel.Font do
      begin
      ini.WriteString(screenMode, 'FontName', Name);
      ini.WriteInteger(screenMode, 'FontSize', Size);
      //Style
      ini.WriteBool(screenMode, 'FontBold', fsBold in Style);
      ini.WriteBool(screenMode, 'FontItalic', fsItalic in Style);
      ini.WriteBool(screenMode, 'FontUnderline', fsUnderline in Style);
      end;
    with FPan2.Panel.Font do
      begin
      ini.WriteString(screenMode, 'FontName', Name);
      ini.WriteInteger(screenMode, 'FontSize', Size);
      //Style
      ini.WriteBool(screenMode, 'FontBold', fsBold in Style);
      ini.WriteBool(screenMode, 'FontItalic', fsItalic in Style);
      ini.WriteBool(screenMode, 'FontUnderline', fsUnderline in Style);
      end;
    for i := 0 to FPan1.Panel.ColCount - 1 do
      ini.WriteInteger(screenMode,
        'column'+IntToStr(i)+'width', FPan1.Panel.ColWidths[i]);
  except
    {$IFDEF DEBUG}
    LogIt('Error: Ini write failed');
    {$ENDIF}
    showmessage(Format(ER_INIWRITE, [ini.FileName]));
  end;
    ini.Free;
    
  ini := TIniFile.Create(RemTemplates(paths.LngFile, paths));
  try
    ini.WriteString('FmMain', 'MnuFile', paths.MnuFile);
  except
  end;
  ini.Free;

end;

procedure TCmControl.LinkPanel(APanel: TFLGrid);
begin
  if APanel = nil then Exit;

  APanel.OnColResize := MPanelColResize;
  APanel.OnKeyDown := MKeyDown;
  APanel.OnKeyUp := MKeyUp;
  APanel.OnEnter := MEnter;
  APanel.OnSorting := MOnSorting;
  //APanel.OnFileExec := MExecFile;
  APanel.OnFilterModeChange := MFilterModeChanged;
  APanel.OnKeyPress := MKeyPress;
  APanel.OnDblClick := MDblClick;

  APanel.OnEnter(APanel);
end;

procedure TCmControl.MAppActivate(Sender: TObject);
var
  drLeft, drRight: TDriveTypeEnum;
  i: Integer;
  dt: TDriveType;
  w: Word;
begin
  {$IFDEF DEBUG}
  LogIt('WM_GETFOCUS');
{  LogIt('WM_GETFOCUS left = '+FPan1.Panel.Directory);
  LogIt('WM_GETFOCUS right = '+FPan2.Panel.Directory);}
  {$ENDIF}
  //Для уникнення великих затримок при відкритті програми, якщо для панелі задано
  //шлях до папки, в якій дуже багато файлів
  if bFirstActivate then
    begin
    Application.ProcessMessages;
    FPan1.Panel.Directory := cLeftDir;
    FPan2.Panel.Directory := cRightDir;
    if FPan1.Panel.Directory <> cLeftDir then
      FPan1.Panel.Directory := FirstAvailableRoot();
    if FPan2.Panel.Directory <> cRightDir then
      FPan2.Panel.Directory := FirstAvailableRoot();
    bFirstActivate := False;
    Exit;
    end;

  w := VK_RETURN;
  if FmDrive <> nil then
    FmDrive.OnKeyDown(TObject(Sender), w, []);

  drLeft := dtUnknown;
  drRight := dtUnknown;
  Application.ProcessMessages;

  {$IFDEF DEBUG}
//  LogIt('WM_GETFOCUS Checking drives to reread...');
  {$ENDIF}
  for i := 0 to MAX_DRIVES do
    begin
    dt := TDriveType.Create(i);
    if ((chr(ord('A')+i)) = UpperCase(FPan1.Panel.Directory[1]))then
      drLeft := dt.DriveType;
    if ((chr(ord('A')+i)) = UpperCase(FPan2.Panel.Directory[1]))then
      drRight := dt.DriveType;
    dt.Free;
    end;

  case drLeft of
    dtRemovable:
      if bRereadFD then
        PerformCmd(cm_RereadLeftSoft);
    dtFixed:
      if bRereadHD then
        PerformCmd(cm_RereadLeftSoft);
    dtRemote:
      if bRereadNET then
        PerformCmd(cm_RereadLeftSoft);
    dtCdRom:
      if bRereadCD then
        PerformCmd(cm_RereadLeftSoft);
    else
      PerformCmd(cm_RereadLeftSoft);
    end;

  case drRight of
    dtRemovable:
      if bRereadFD then
        PerformCmd(cm_RereadRightSoft);
    dtFixed:
      if bRereadHD then
        PerformCmd(cm_RereadRightSoft);
    dtRemote:
      if bRereadNET then
        PerformCmd(cm_RereadRightSoft);
    dtCdRom:
      if bRereadCD then
        PerformCmd(cm_RereadRightSoft);
    else
      PerformCmd(cm_RereadRightSoft);
    end;

end;

procedure TCmControl.MEnter(Sender: TObject);
begin
  if (Sender as TFlGrid) = FPan1.Panel then
    begin
    FSource := FPan1.Panel;
    FPan1.Color_ := FPan1.Color_;
    if Assigned(FPan2) then
      begin
      FTarget := FPan2.Panel;
      FPan2.Edit.Color := clGray;
      FPan2.Edit.Font.Color := clSilver;
      end;
    end
  else
    begin
    FSource := FPan2.Panel;
    FPan2.Color_ := FPan2.Color_;
    if Assigned(FPan2) then
      begin
      FTarget := FPan1.Panel;
      FPan1.Edit.Color := clMedGray;
      FPan1.Edit.Font.Color := clSilver;
      end;
    end;

  MOnSorting(FSource, FSource.SortFile);
  if FMenu <> nil then MenuUpdFilters(FMenu.Items);
end;

procedure TCmControl.MenuGrpUpdate(const Group: TGrp; Cmd: Cardinal;
  Menu: TMenuItem);
var i, j: Integer;
begin

  for i := 0 to Menu.Count-1 do
    if Menu.Items[i].Count = 0 then
      begin
      if Menu.Items[i].Tag = cmd then
        begin
        if Length(group) > 1 then
          Menu.Items[i].Checked := True
        else
          Menu.Items[i].Checked := not Menu.Items[i].Checked;
        end
      else
        for j := 0 to Length(group)-1 do
          if Menu.Items[i].Tag = group[j] then
              Menu.Items[i].Checked := False
      end
    else
      MenuGrpUpdate(Group, Cmd, Menu.Items[i]);
end;

procedure TCmControl.MenuUpdFilters(Menu: TMenuItem);
//Встановлює галочки на пунктах меню, що відповідають вибраному
//режиму фільтрування (програми, всі файли і т. д.)
var
  i: Integer;
  cmd: Cardinal;
  s: String;
begin
  for i := 0 to Menu.Count-1 do
    if Menu.Items[i].Count = 0 then
      begin
      if Menu.Items[i].Tag = cm_SrcUserSpec then
        begin
        s := FSource.UserDefFilter;
        if Length(s) > 60 then
          begin
          SetLength(s, 60);
          s := s + '...';
          end;
        Menu.Items[i].Caption := s;
        end
      end
    else
      MenuUpdFilters(Menu.Items[i]);
  case FSource.FilterMode of
    fmAll      : cmd := cm_SrcAllFiles;
    fmExecs    : cmd := cm_SrcExecs;
    fmUserSpec : cmd := cm_SrcUserSpec;
    else cmd := 0;
    end;
  UpdateMenu(cmd);
end;

procedure TCmControl.MExecFile(Sender: TObject);
begin
  PerformCmd(cm_Return);
end;

procedure TCmControl.MFilterModeChanged(Sender: TObject);
begin
  MenuUpdFilters(FMenu.Items);
end;

procedure TCmControl.MKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  command: Cardinal;
  row: Integer;

begin
  row := FSource.Selection.Top;
  command := 0;

  if Shift <> [] then
  case Key of
    VK_CONTROL, VK_SHIFT, VK_MENU:
      SetToolBtnCaps(Shift);
    end;

  if Shift = [ssCtrl] then
  case Key of
    //якщо утримується клавіша Ctrl
    Ord('A'):
      begin
      FSource.MarkAll(True);
      FSource.Repaint;
      end;
    Ord('P'):
      command := cm_AddPathToCmdline;
    Ord('R'):
      command := cm_RereadSource;
    Ord('J'):
      command := cm_MatchSrc;
    VK_ADD:
      command := cm_SelectAll;
    VK_SUBTRACT:
      command := cm_ClearAll;
    VK_RIGHT:
      if FSource = FPan1.Panel then
        command := cm_TransferRight;
    VK_LEFT:
      if FSource = FPan2.Panel then
        command := cm_TransferLeft;
    VK_F3:
      command := cm_SrcByName;
    VK_F4:
      command := cm_SrcByExt;
    VK_F5:
      command := cm_SrcBySize;
    VK_F6:
      command := cm_srcByDateTime;
    VK_F7:
      command := cm_SrcUnsorted;
    VK_F10:
      command := cm_SrcAllFiles;
    VK_F11:
      command := cm_SrcExecs;
    VK_F12:
      command := cm_SrcUserDef;
    Ord('S'):
      command := cm_ShowOnlySelected;
    Ord('B'):
      command := cm_DirBranch;
    220: //Ctrl+\
      command := cm_GoToRoot;
    VK_PRIOR:
      command := cm_GoToParent;
    end
  else if Shift = [ssAlt] then
  case Key of
    Ord('A'):
      command := cm_SetAttrib;
    VK_ADD:
      command := cm_SelectCurrentExtension;
    VK_SUBTRACT:
      command := cm_UnselectCurrentExtension;
    VK_F1:
      command := cm_LeftOpenDrives;
    VK_F2:
      command := cm_RightOpenDrives;
    VK_F7:
      command := cm_SearchFor;
    VK_UP:
      command := cm_EditPath;
    VK_RETURN:
      command := cm_Properties;
    end
  else if Shift = [ssShift] then
  case Key of
    VK_F8, VK_DELETE:
      command := cm_Delete;
    VK_F6:
      command := cm_RenameOnly;
    end
  else if Shift = [ssShift, ssAlt] then
  case Key of
    VK_RETURN:
      command := cm_CountDirContent;
    end
  else if Shift = [] then
  case Key of
    //якщо не утримується клавіша
    VK_ESCAPE:
      command := cm_ClearCmdLine;
    VK_RETURN:
      if (FSource.HighlightedFile.Attr and faDirectory) = faDirectory then
        command := cm_GoToDir
      else
        PerformCmd(cm_Return);
    VK_SPACE:
      FSource.MarkInvertEx(row, True);
    VK_BACK:
      command := cm_GoToParent;
    VK_F2:
      command := cm_RereadSource;
    VK_F3:
      command := cm_List;
    VK_F4:
      command := cm_Edit;
    VK_F5:
      command := cm_Copy;
    VK_F6:
      command := cm_RenMov;
    VK_F7:
      command := cm_MkDir;
    VK_F8, VK_DELETE:
      if win32delete then
        command := cm_Recycle
      else
        command := cm_Delete;
    VK_F9:
      command := cm_Associate;
    VK_LEFT, VK_RIGHT:
      FPrompt.SetFocus;
    VK_ADD:
      command := cm_SpreadSelection;
    VK_SUBTRACT:
      command := cm_ShrinkSelection;
    VK_MULTIPLY:
      command := cm_ExchangeSelection;
    end;

  if PerformCmd(command) <> -1 then
    UpdateMenu(command);

end;

procedure TCmControl.MKeyPress(Sender: TObject; var Key: Char);
begin
  case key  of
    #0..#32,
    '*', '/', '-', '+':
      Exit;
    end;

  FPrompt.Text := Key;
  FPrompt.SetFocus;
  FPrompt.SelStart := 1;
end;

procedure TCmControl.MKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  SetToolBtnCaps(Shift);
end;

procedure TCmControl.MOnSorting(Sender: TObject; SortFile: TSortFile);
var cmdSrc, cmdLeft, cmdRight: Cardinal;
begin
  if Sender = nil then Exit;
  cmdSrc := 0; cmdLeft := 0; cmdRight := 0;
  if FSource <> nil then
  if (Sender as TFLGrid) = FSource then
  case SortFile of
    smFolder, smNone  : cmdSrc := cm_SrcUnsorted;
    smName, smRevName : cmdSrc := cm_SrcByName;
    smExt, smRevExt   : cmdSrc := cm_SrcByExt;
    smSize, smRevSize : cmdSrc := cm_SrcBySize;
    smDate, smRevDate : cmdSrc := cm_SrcByDateTime;
    end;
  if FPan1 <> nil then
  if (Sender as TFLGrid) = FPan1.Panel then
  case SortFile of
    smFolder, smNone  : cmdLeft := cm_LeftUnsorted;
    smName, smRevName : cmdLeft := cm_LeftByName;
    smExt, smRevExt   : cmdLeft := cm_LeftByExt;
    smSize, smRevSize : cmdLeft := cm_LeftBySize;
    smDate, smRevDate : cmdLeft := cm_LeftByDateTime;
    end;
  if FPan2 <> nil then
  if (Sender as TFLGrid) = FPan2.Panel then
  case SortFile of
    smFolder, smNone  : cmdRight := cm_RightUnsorted;
    smName, smRevName : cmdRight := cm_RightByName;
    smExt, smRevExt   : cmdRight := cm_RightByExt;
    smSize, smRevSize : cmdRight := cm_RightBySize;
    smDate, smRevDate : cmdRight := cm_RightByDateTime;
    end;


  if cmdSrc <> 0 then
    UpdateMenu(cmdSrc);
  if cmdLeft <> 0 then
    UpdateMenu(cmdLeft);
  if cmdRight <> 0 then
    UpdateMenu(cmdRight);
end;

procedure TCmControl.MPanelColResize(Sender: TObject);
var
  Target: TFLGrid;
  i: Integer;
begin
  if (Sender as TFLGrid) = FPan1.Panel then
    Target := FPan2.Panel
  else
    Target := FPan1.Panel;
  for i := 0 to DEF_COL_COUNT - 1 do
    Target.ColWidths[i] := (Sender as TFLGrid).ColWidths[i];
end;

procedure TCmControl.MPromptKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var cmStr: String;
begin
  cmStr := Trim(Lowercase(FPrompt.Text));
  case Key of
    VK_ESCAPE, VK_UP:
      begin
      FPrompt.Clear;
      FSource.SetFocus;
      end;
    VK_RETURN:
      begin
      ExecCmdLine(cmStr);
      FPrompt.Clear;
      FSource.SetFocus;
      end;
    end;
end;

procedure TCmControl.MToolBtnClick(Sender: TObject);
var cmd: Cardinal;
begin
  cmd := TOOLBAR_ACTS[FTool.Tag, (Sender as TToolButton).Tag];
  PerformCmd(cmd);
  SetToolBtnCaps([]);
end;

function TCmControl.PerformCmd(Command: Cardinal): Integer;
var pr: TPanelRec;
begin
  pr.Left := FPan1.Panel;
  pr.LeftEd := FPan1.Edit;
  pr.Right := FPan2.Panel;
  pr.RightEd := FPan2.Edit;
  pr.CmdEd := FPrompt;
  pr.Source := FSource;
  pr.Target := FTarget;
  if FSource = FPan1.Panel then
    begin
    pr.SourceEd := FPan1.Edit;
    pr.TargetEd := FPan2.Edit;
    end
  else
    begin
    pr.SourceEd := FPan2.Edit;
    pr.TargetEd := FPan1.Edit;
    end;

  if command = cm_configSaveSettings then self.IniSaveTo();
  result := PerformMsg(pr, command, paths);
  if result = 0 then UpdateMenu(command);

  case result of
    FS_FILE_NOTSUPPORTED:
      ShowMessage(ER_OPERATION);
    FS_FILE_EXISTS:
      ShowMessage(ER_FILEEXISTS);
    FS_FILE_WRITEERROR:
      ShowMessage(ER_FILEWRITE);
    -1:
      if Assigned(OnUnknownCmd) then
        FUnknownCmd(Self, Command);
    end;
end;

procedure TCmControl.SetCmdPrompt(const Value: TEdit);
begin
  FPrompt := Value;
  FPrompt.OnKeyDown := MPromptKeyDown;
  FPrompt.Color := CL_BACKGROUND;
  FPrompt.Font.Color := CL_COMMON_TEXT;
  FPrompt.Font.Name := FONT_FACE;
  FPrompt.Font.Size := FONT_SIZE;
  FPrompt.Font.Style := FONT_STYLE;
end;

procedure TCmControl.SetFPan1(const Value: TCmGrid);
begin
  FPan1 := Value;
  LinkPanel(FPan1.Panel);
end;

procedure TCmControl.SetFPan2(const Value: TCmGrid);
begin
  FPan2 := Value;
  LinkPanel(FPan2.Panel);
end;

procedure TCmControl.SetIniName(const Value: String);
begin
  paths.IniFile := Value;
end;

procedure TCmControl.SetToolBarFKey(const Value: TToolBar);
//Встановлює значення Tag для кнопок панелі F-клавіш
var
  i, tg: Integer;
begin
  FTool := Value;
  tg := 1;
  with FTool do
  for i := 0 to ButtonCount-1 do
    if Buttons[i].Style = tbsButton then
      begin
      Buttons[i].Tag := tg;
      Buttons[i].OnClick := MToolBtnClick;
      Inc(tg);
      if tg > 10 then Break;
      end;
  SetToolBtnCaps([]);
end;

procedure TCmControl.SetToolBtnCaps(ShiftState: TShiftState);
//Встановлює написи для кнопок панелі F-клавіш
//відповідно до утримуваної додаткової клавіші.
//Значення беруться з масиву TOOLBAR_CAPS
var
  i, state: Integer;
begin
  {bug, thats why ->}if ShiftState <> [] then Exit;
  state := 0;
  if ssCtrl in ShiftState then state := 1
  else if ssAlt in ShiftState then state := 2
  else if ssShift in ShiftState then state := 3;

  with FTool do
  for i := 0 to ButtonCount-1 do
    if (Buttons[i].Tag <> 0)
       and (Buttons[i].Caption <> TOOLBAR_CAPS[state, Buttons[i].Tag]) then
      Buttons[i].Caption := TOOLBAR_CAPS[state, Buttons[i].Tag];
  FTool.Tag := state;
end;

procedure TCmControl.UpdateMenu(Command: Cardinal);
var
  iGroupIndex: Integer;
begin
  if command = 0 then Exit;
  if command = cm_SrcUserDef then
    command := cm_SrcUserSpec;
  iGroupIndex := GetGrpIndex(command);
  if (iGroupIndex <> -1)and(FMenu <> nil) then
    MenuGrpUpdate(grp[iGroupIndex], command, FMenu.Items);
end;

procedure TCmControl.MDblClick(Sender: TObject);
var NewPos: TPoint;
begin
  Windows.GetCursorPos(NewPos);  NewPos:= (Sender as TFlGrid).ScreenToClient(NewPos);
  if (NewPos.y > 0)and(NewPos.y < (Sender as TFlGrid).DefaultRowHeight) then Exit;
  if ((Sender as TFlGrid).HighlightedFile.Attr and faDirectory) = faDirectory then
    PerformCmd(cm_GoToDir)
  else
    PerformCmd(cm_Return);
end;

procedure TCmControl.LngLoadEx(const LngFile: String);
var
  ini: TIniFile;
  i, j: Integer;
begin
  ini := TIniFile.Create(lngFile);

  with FPan1.Panel do
    begin
    TitleName := ini.ReadString('FmMain', 'Panel.NameCap', TitleName);
    TitleExt  := ini.ReadString('FmMain', 'Panel.ExtCap', TitleExt);
    TitleSize := ini.ReadString('FmMain', 'Panel.SizeCap', TitleSize);
    TitleDate := ini.ReadString('FmMain', 'Panel.DateCap', TitleDate);
    end;
  with FPan2.Panel do
    begin
    TitleName := ini.ReadString('FmMain', 'Panel.NameCap', TitleName);
    TitleExt  := ini.ReadString('FmMain', 'Panel.ExtCap', TitleExt);
    TitleSize := ini.ReadString('FmMain', 'Panel.SizeCap', TitleSize);
    TitleDate := ini.ReadString('FmMain', 'Panel.DateCap', TitleDate);
    end;

  for i := 0 to 3 do
    for j := 1 to 9 do
      case i of
        0: TOOLBAR_CAPS[i, j] := ini.ReadString('FmMain', 'btnF'+IntToStr(j), TOOLBAR_CAPS[i, j]);
        1: TOOLBAR_CAPS[i, j] := ini.ReadString('FmMain', 'btnCtrlF'+IntToStr(j), TOOLBAR_CAPS[i, j]);
        2: TOOLBAR_CAPS[i, j] := ini.ReadString('FmMain', 'btnAltF'+IntToStr(j), TOOLBAR_CAPS[i, j]);
        3: TOOLBAR_CAPS[i, j] := ini.ReadString('FmMain', 'btnShiftF'+IntToStr(j), TOOLBAR_CAPS[i, j]);
        end;
  SetToolBtnCaps([]);

  S_COPY            := ini.ReadString('FmMain', 'cCopy', S_COPY);
  S_DELETE          := ini.ReadString('FmMain', 'cDelete', S_DELETE);
  S_DIR_UP          := ini.ReadString('FmMain', 'cDirUp', S_DIR_UP);
  S_DRVINFO         := ini.ReadString('FmMain', 'cDrvInfo', S_DRVINFO);
  NO_DRIVE_LABEL    := ini.ReadString('FmMain', 'cEmptyDrvLabel', NO_DRIVE_LABEL);
  S_ENTDIR          := ini.ReadString('FmMain', 'cEntDir', S_ENTDIR);
  S_ENTMASK         := ini.ReadString('FmMain', 'cEnterMask', S_ENTMASK);
  EXE_MASK          := ini.ReadString('FmMain', 'cExeMask', EXE_MASK);
  S_FOLDER          := ini.ReadString('FmMain', 'cFolder', S_FOLDER);
  S_NEWDIR          := ini.ReadString('FmMain', 'cMkDir', S_NEWDIR);
  S_NEWSEL          := ini.ReadString('FmMain', 'cNewSel', S_NEWSEL);
  S_REMOVE          := ini.ReadString('FmMain', 'cRemov', S_REMOVE);
  S_RENFILE         := ini.ReadString('FmMain', 'cRenFile', S_RENFILE);
  S_RENMOVE         := ini.ReadString('FmMain', 'cRenMov', S_RENMOVE);
  S_RENONLY         := ini.ReadString('FmMain', 'cRenOnly', S_RENONLY);
  S_SEARCH          := ini.ReadString('FmMain', 'cSearchRep', S_SEARCH);
  S_NOFILESFOUND    := ini.ReadString('FmMain', 'cSearchNf', S_NOFILESFOUND);
  S_SELFILES        := ini.ReadString('FmMain', 'cSelFiles', S_SELFILES);
  S_SELINFO         := ini.ReadString('FmMain', 'cSelInfo', S_SELINFO);
  S_UNSFILES        := ini.ReadString('FmMain', 'cUnselFiles', S_UNSFILES);

  ER_ITSELF         := ini.ReadString('FmMain', 'eCopyToItself', ER_ITSELF);
  ER_FILEEXISTS     := ini.ReadString('FmMain', 'eFileExists', ER_FILEEXISTS);
  ER_FILEWRITE      := ini.ReadString('FmMain', 'eFileWrite', ER_FILEWRITE);
  ER_INIWRITE       := ini.ReadString('FmMain', 'eIniWrite', ER_INIWRITE);
  ER_MULTATTR       := ini.ReadString('FmMain', 'eMultAttr', ER_MULTATTR);
  ER_MULTREN        := ini.ReadString('FmMain', 'eMultRen', ER_MULTREN);
  ER_NOEDITOR       := ini.ReadString('FmMain', 'eNoEditor', ER_NOEDITOR);
  ER_NOFILE         := ini.ReadString('FmMain', 'eNoFile', ER_NOFILE);
  NO_FILES_SELECTED := ini.ReadString('FmMain', 'eNoFilesSelected', NO_FILES_SELECTED);
  ER_NOLISTER       := ini.ReadString('FmMain', 'eNoLister', ER_NOLISTER);
  ER_NOPATH         := ini.ReadString('FmMain', 'eNoPath', ER_NOPATH);
  ER_NO_SPACE       := ini.ReadString('FmMain', 'eNoSpace', ER_NO_SPACE);
  ER_OPERATION      := ini.ReadString('FmMain', 'eOperUnknown', ER_OPERATION);
  ER_PROGR_NOT_EXEC := ini.ReadString('FmMain', 'eProgramNotExec', ER_PROGR_NOT_EXEC);
  ER_READERROR      := ini.ReadString('FmMain', 'eReadError', ER_READERROR);
  ER_RENFILE        := ini.ReadString('FmMain', 'eRenFile', ER_RENFILE);
  ER_ERROR          := ini.ReadString('FmMain', 'eUnknownEr', ER_ERROR);
  ER_WRITEERROR     := ini.ReadString('FmMain', 'eWriteError', ER_WRITEERROR);

  ini.Free;
end;

procedure TCmControl.LngWriteEx(const LngFile: String);
var
  ini: TIniFile;
  i, j: Integer;
begin
  ini := TIniFile.Create(lngFile);

  with FPan1.Panel do
    begin
    ini.WriteString('FmMain', 'Panel.NameCap', TitleName);
    ini.WriteString('FmMain', 'Panel.ExtCap', TitleExt);
    ini.WriteString('FmMain', 'Panel.SizeCap', TitleSize);
    ini.WriteString('FmMain', 'Panel.DateCap', TitleDate);
    end;

  for i := 0 to 3 do
    for j := 1 to 9 do
      case i of
        0: ini.WriteString('FmMain', 'btnF'+IntToStr(j), TOOLBAR_CAPS[i, j]);
        1: ini.WriteString('FmMain', 'btnCtrlF'+IntToStr(j), TOOLBAR_CAPS[i, j]);
        2: ini.WriteString('FmMain', 'btnAltF'+IntToStr(j), TOOLBAR_CAPS[i, j]);
        3: ini.WriteString('FmMain', 'btnShiftF'+IntToStr(j), TOOLBAR_CAPS[i, j]);
        end;


  ini.WriteString('FmMain', 'cCopy', S_COPY);
  ini.WriteString('FmMain', 'cDelete', S_DELETE);
  ini.WriteString('FmMain', 'cDirUp', S_DIR_UP);
  ini.WriteString('FmMain', 'cDrvInfo', S_DRVINFO);
  ini.WriteString('FmMain', 'cEmptyDrvLabel', NO_DRIVE_LABEL);
  ini.WriteString('FmMain', 'cEntDir', S_ENTDIR);
  ini.WriteString('FmMain', 'cEnterMask', S_ENTMASK);
  ini.WriteString('FmMain', 'cExeMask', EXE_MASK);
  ini.WriteString('FmMain', 'cFolder', S_FOLDER);
  ini.WriteString('FmMain', 'cMkDir', S_NEWDIR);
  ini.WriteString('FmMain', 'cNewSel', S_NEWSEL);
  ini.WriteString('FmMain', 'cRemov', S_REMOVE);
  ini.WriteString('FmMain', 'cRenFile', S_RENFILE);
  ini.WriteString('FmMain', 'cRenMov', S_RENMOVE);
  ini.WriteString('FmMain', 'cRenOnly', S_RENONLY);
  ini.WriteString('FmMain', 'cSearchRep', S_SEARCH);
  ini.WriteString('FmMain', 'cSearchNf', S_NOFILESFOUND);
  ini.WriteString('FmMain', 'cSelFiles', S_SELFILES);
  ini.WriteString('FmMain', 'cSelInfo', S_SELINFO);
  ini.WriteString('FmMain', 'cUnselFiles', S_UNSFILES);

  ini.WriteString('FmMain', 'eCopyToItself', ER_ITSELF);
  ini.WriteString('FmMain', 'eFileExists', ER_FILEEXISTS);
  ini.WriteString('FmMain', 'eFileWrite', ER_FILEWRITE);
  ini.WriteString('FmMain', 'eIniWrite', ER_INIWRITE);
  ini.WriteString('FmMain', 'eMultAttr', ER_MULTATTR);
  ini.WriteString('FmMain', 'eMultRen', ER_MULTREN);
  ini.WriteString('FmMain', 'eNoEditor', ER_NOEDITOR);
  ini.WriteString('FmMain', 'eNoFile', ER_NOFILE);
  ini.WriteString('FmMain', 'eNoFilesSelected', NO_FILES_SELECTED);
  ini.WriteString('FmMain', 'eNoLister', ER_NOLISTER);
  ini.WriteString('FmMain', 'eNoPath', ER_NOPATH);
  ini.WriteString('FmMain', 'eNoSpace', ER_NO_SPACE);
  ini.WriteString('FmMain', 'eOperUnknown', ER_OPERATION);
  ini.WriteString('FmMain', 'eProgramNotExec', ER_PROGR_NOT_EXEC);
  ini.WriteString('FmMain', 'eReadError', ER_READERROR);
  ini.WriteString('FmMain', 'eRenFile', ER_RENFILE);
  ini.WriteString('FmMain', 'eUnknownEr', ER_ERROR);
  ini.WriteString('FmMain', 'eWriteError', ER_WRITEERROR);

  ini.Free;
end;

initialization

  screenMode := IntToStr(Screen.Width)+'x'+IntToStr(Screen.Height);

end.