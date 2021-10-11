unit FileAttr;
{$I 'defs.pas'}

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TFmAttr = class(TForm)
    GroupBox1: TGroupBox;
    BtnCancel: TButton;
    BtnOK: TButton;
    ChArch: TCheckBox;
    ChSys: TCheckBox;
    ChHid: TCheckBox;
    ChRead: TCheckBox;
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure SetAttr(var Attr: Cardinal; var Time: TDateTime);
  end;

var
  FmAttr: TFmAttr;

implementation

uses FLFunctions, CmControl, FLConst;

{$R *.dfm}

{ TFmAttr }

procedure TFmAttr.SetAttr(var Attr: Cardinal; var Time: TDateTime);
begin
  ChArch.Checked := (Attr and faArchive) = faArchive;
  ChSys.Checked := (Attr and faSysFile) = faSysFile;
  ChHid.Checked := (Attr and faHidden) = faHidden;
  ChRead.Checked := (Attr and faReadOnly) = faReadOnly;
  FmAttr.ShowModal;
  if FmAttr.ModalResult = mrOK then
    begin
    if ChArch.Checked then
      Attr := Attr or faArchive
    else
      Attr := Attr and (not faArchive);

    if ChSys.Checked then
      Attr := Attr or faSysFile
    else
      Attr := Attr and (not faSysFile);

    if ChHid.Checked then
      Attr := Attr or faHidden
    else
      Attr := Attr and (not faHidden);

    if ChRead.Checked then
      Attr := Attr or faReadOnly
    else
      Attr := Attr and (not faReadOnly);

    end;
end;

procedure TFmAttr.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
    Close;
end;

procedure TFmAttr.FormShow(Sender: TObject);
begin
  LngLoadFrom(RemTemplates(CmControl.paths.LngFile, CmControl.paths), FmAttr);
end;

procedure TFmAttr.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  {$IFDEF SAVELNG}
  LngSaveTo(RemTemplates(CmControl.paths.LngFile, CmControl.paths), FmAttr);
  {$ENDIF}
end;

end.