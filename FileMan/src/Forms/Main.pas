unit Main;

{$I 'defs.pas'}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Menus, Buttons, Grids, ValEdit, ComCtrls,
  ToolWin, AppEvnts;

type
  TFmMain = class(TForm)
    Panel2: TPanel;
    Panel3: TPanel;
    LPanel: TPanel;
    Splitter1: TSplitter;
    RPanel: TPanel;
    CmdPrompt: TEdit;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    ToolButton5: TToolButton;
    ToolButton6: TToolButton;
    ToolButton7: TToolButton;
    ToolButton8: TToolButton;
    ToolButton9: TToolButton;
    ToolButton10: TToolButton;
    ToolButton11: TToolButton;
    ToolButton12: TToolButton;
    ToolButton13: TToolButton;
    ToolButton14: TToolButton;
    ToolButton15: TToolButton;
    ToolButton16: TToolButton;
    ToolButton17: TToolButton;
    ToolButton18: TToolButton;
    ToolButton19: TToolButton;
    ApplicationEvents1: TApplicationEvents;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure Splitter1Moved(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure MenuClick(Sender: TObject);
    procedure UnknownCmd(Sender: TObject; Cmd: Cardinal);
    procedure FormShow(Sender: TObject);
    procedure ApplicationEvents1Exception(Sender: TObject; E: Exception);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure SavePos;
  end;

var
  FmMain: TFmMain;

implementation

uses FLConst, FLFunctions, FLTypes, CmControl, CmGrid, FLMenu,
  ShellAPI, IniFiles, FLMessages, FLThreads;

{$R *.dfm}

const
  DX = 30;
  DY = 30;

var
  LPan, RPan: TCmGrid;
  Mng: TCmControl;
  Mnu: TFLMenu;
  widthPercent: Byte;
  iniFile: String = 'fileman.ini';

procedure TFmMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Hide;

  {$IFDEF SAVELNG}
  LngSaveTo(RemTemplates(CmControl.paths.LngFile, CmControl.paths), Application.MainForm);
  {$ENDIF}
  Mng.IniSaveTo();

  try
    LPan.Free;
    RPan.Free;
    Mng.Free;
    Mnu.Free;
  except
  end;
end;

procedure TFmMain.FormCreate(Sender: TObject);
var
  ini: TIniFile;
  mnufile, incfile: String;

begin
  Caption := APP_NAME;
  iniFile := ExtractFilePath(Application.ExeName)+iniFile;
  {$IFDEF DEBUG}
  LogIt('IniFile='+iniFile);
  {$ENDIF}

  LPan := TCmGrid.Create(FmMain);
  LPan.Parent := LPanel;
  LPan.Align := alClient;
  LPan.TabOrder := 0;

  RPan := TCmGrid.Create(FmMain);
  RPan.Parent := RPanel;
  RPan.Align := alClient;
  RPan.TabOrder := 1;

  Mng := TCmControl.Create(FmMain);
  Mng.FilePanel1 := LPan;
  Mng.FilePanel2 := RPan;
  Mng.ToolBarFKey := ToolBar1;
  Mng.CommandPrompt := CmdPrompt;
  Mng.OnUnknownCmd := UnknownCmd;

  Mng.IniFile := iniFile;

  ini := TIniFile.Create(iniFile);
  FmMain.Left := ini.ReadInteger(
    IntToStr(Screen.Width)+'x'+IntToStr(Screen.Height),
    'x', {(Screen.Width - FmMain.Width) div 2}DX);
  FmMain.Top := ini.ReadInteger(IntToStr(Screen.Width)+'x'+IntToStr(Screen.Height),
    'y', {(Screen.Height - FmMain.Height) div 2}DY);
  FmMain.Width := ini.ReadInteger(IntToStr(Screen.Width)+'x'+IntToStr(Screen.Height),
    'dx', FmMain.Width{Screen.Width - DX * 2});
  FmMain.Height := ini.ReadInteger(IntToStr(Screen.Width)+'x'+IntToStr(Screen.Height),
    'dy', FmMain.Height{Screen.Height - DY * 3});
  if ini.ReadBool(IntToStr(Screen.Width)+'x'+IntToStr(Screen.Height),
      'Maximized', False)then
    FmMain.WindowState := wsMaximized;
  incFile := ini.ReadString('Configuration', 'CommandList', '%APP_PATH%\fileman.inc');
  ini.Free;


  Mng.IniLoadFrom();
  widthPercent := 50;
  FormResize(Sender);

  SetCurrentDir(ExtractFilePath(RemTemplates(CmControl.paths.LngFile, CmControl.paths)));
  MnuFile := ExpandFileName(CmControl.paths.MnuFile);

  Mnu := TFLMenu.Create(FmMain);
  FmMain.Menu := Mnu;
  {$IFDEF DEBUG}
  LogIt('IncFile='+RemTemplates(incFile, CmControl.paths));
  LogIt('MnuFile='+RemTemplates(mnuFile, CmControl.paths));
  {$ENDIF}
  Mnu.IncFile := incFile;
  Mnu.MnuFile := MnuFile;
  Mnu.DefProc := MenuClick;
  Mnu.LoadMenu;
  Mng.Menu := Mnu;

end;

procedure TFmMain.Splitter1Moved(Sender: TObject);
begin
  widthPercent := Round(LPanel.Width / FmMain.Width * 100);
end;

procedure TFmMain.FormResize(Sender: TObject);
begin
  LPanel.Width := Abs(Round(widthPercent * Width / 100) - 5);
end;

procedure TFmMain.MenuClick(Sender: TObject);
begin
  Mng.PerformCmd((Sender as TMenuItem).Tag);
end;

procedure TFmMain.UnknownCmd(Sender: TObject; Cmd: Cardinal);
begin
  case Cmd of
    cm_ConfigSavePos:
      SavePos();
    FLMessages.cm_Exit:;
    else
      begin
      {$IFDEF DEBUG}
      LogIt('UnknownCommand: '+IntToStr(Cmd));
      {$ENDIF}
      ShowMessage('Unknown command! (¹ = '+IntToStr(Cmd)+')');
      end;
    end;
end;

procedure TFmMain.SavePos;
var
  ini: TIniFile;
begin
  ini := TIniFile.Create(iniFile);

  try
    if WindowState = wsNormal then
      begin
      ini.WriteBool(IntToStr(Screen.Width)+'x'+IntToStr(Screen.Height),
        'Maximized', False);
      ini.WriteInteger(IntToStr(Screen.Width)+'x'+IntToStr(Screen.Height),
        'x', FmMain.Left);
      ini.WriteInteger(IntToStr(Screen.Width)+'x'+IntToStr(Screen.Height),
        'y', FmMain.Top);
      ini.WriteInteger(IntToStr(Screen.Width)+'x'+IntToStr(Screen.Height),
        'dx', FmMain.Width);
      ini.WriteInteger(IntToStr(Screen.Width)+'x'+IntToStr(Screen.Height),
        'dy', FmMain.Height);
      end
    else
      ini.WriteBool(IntToStr(Screen.Width)+'x'+IntToStr(Screen.Height),
        'Maximized', True);
  except
    {$IFDEF DEBUG}
    LogIt('IniWrite Failed: ini='+iniFile);
    {$ENDIF}
  end;

//  ini.WriteString('Configuration', 'Mainmenu', Mnu.MnuFile);
  ini.WriteString('Configuration', 'CommandList', Mnu.IncFile);
  ini.Free;
end;

procedure TFmMain.FormShow(Sender: TObject);
begin
  LngLoadFrom(RemTemplates(CmControl.paths.LngFile, CmControl.paths), Application.MainForm);
end;

procedure TFmMain.ApplicationEvents1Exception(Sender: TObject;
  E: Exception);
begin
  {$IFDEF DEBUG}
  LogIt('Error: '+E.Message);
  {$ELSE}
  ShowMessage(E.Message);
  {$ENDIF}
end;

end.