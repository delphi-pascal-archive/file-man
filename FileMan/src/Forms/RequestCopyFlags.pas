unit RequestCopyFlags;
{$I 'defs.pas'}

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, FLTypes;

type
  TFmGetFlags = class(TForm)
    Panel1: TPanel;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Label1: TLabel;
    lFile01: TLabel;
    lFile01info: TLabel;
    Label2: TLabel;
    lFile02: TLabel;
    lFile02info: TLabel;
    Bevel1: TBevel;
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
    function DoRequestFlags(const File01, File01Info,
      File02, File02Info: String): TCopyFlagsEx;
  end;

var
  FmGetFlags: TFmGetFlags;

implementation

uses Main, FLConst, FLFunctions, CmControl;

{$R *.dfm}

const
  rAbort    = mrCancel;
  rYes      = mrCancel + 1;
  rYesToAll = mrCancel + 2;
  rSkip     = mrCancel + 3;
  rSkipAll  = mrCancel + 4;

function TFmGetFlags.DoRequestFlags(const File01, File01Info, File02,
  File02Info: String): TCopyFlagsEx;
begin
  Button1.ModalResult := rYes;
  Button2.ModalResult := rYesToAll;
  Button3.ModalResult := rSkip;
  Button4.ModalResult := rSkipAll;

  FillChar(result, SizeOf(result), 0);
  FmGetFlags.lFile01.Caption := File01;
  FmGetFlags.lFile01info.Caption := File01Info;
  FmGetFlags.lFile02.Caption := File02;
  FmGetFlags.lFile02info.Caption := File02Info;

  case FmGetFlags.ShowModal of
    rAbort    : result.Abort := True;
    rYes      : result.Replace := True;
    rYesToAll : result.ReplaceAll := True;
    rSkip     : result.Skip := True;
    rSkipAll  : result.SkipAll := True;
    end;
end;

procedure TFmGetFlags.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  case Key of
    VK_ESCAPE: Close;
    end;
end;

procedure TFmGetFlags.FormShow(Sender: TObject);
begin
  LngLoadFrom(RemTemplates(CmControl.paths.LngFile, CmControl.paths), FmGetFlags);
  Button1.SetFocus;
end;

procedure TFmGetFlags.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  {$IFDEF SAVELNG}
  LngSaveTo(RemTemplates(CmControl.paths.LngFile, CmControl.paths), FmGetFlags);
  {$ENDIF}
end;

end.