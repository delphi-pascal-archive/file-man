unit RequestDrv;
{$I 'defs.pas'}

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, FLTypes;

type
  TFmDrive = class(TForm)
    DrvCombo: TComboBox;
    Label1: TLabel;
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure DrvComboDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure DrvComboSelect(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
    function RequestDrive(CurrentDrv: Char; var NewDrv: Char): Boolean;
  end;

var
  FmDrive: TFmDrive;
  ColorAttr: TRowColorAttr;

implementation

uses cxDrive10, FLConst, FLFunctions, CmControl;

{$R *.dfm}

var
  mr: Integer = mrCancel;
  drvTypes: Array[0..MAX_DRIVES] of TDriveTypeEnum;

function TFmDrive.RequestDrive(CurrentDrv: Char; var NewDrv: Char): Boolean;
var
  dt: TDriveType;
  i: Byte;
  nIndex: Integer;
begin

  DrvCombo.Items.Clear;
  FmDrive.ModalResult := 0;
  FillChar(drvTypes, SizeOf(drvTypes), 0);
  for i := 0 to MAX_DRIVES do
    begin
    dt := TDriveType.Create(i);
    if (dt.DriveType<>dtNoRoot)and(dt.DriveType<>dtRemote)then
      begin
      DrvCombo.Items.Add(chr(ord('A')+i));
      drvTypes[DrvCombo.Items.Count-1] := dt.DriveType;
      end;
    dt.Free;
    end;
    
  mr := mrCancel;
  nIndex := DrvCombo.Items.IndexOf(CurrentDrv);
  if nIndex = -1 then
    nIndex := DrvCombo.Items.IndexOf(FirstAvailableRoot()[1]);
  DrvCombo.ItemIndex := nIndex;
  //DrvCombo.DroppedDown := True;
  if not FmDrive.Visible then
    FmDrive.ShowModal;
  if mr <> mrOK then
    result := False
  else
    result := True;
  NewDrv := DrvCombo.Text[1];
end;

procedure TFmDrive.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  case Key of
    VK_ESCAPE:
      begin
      mr := mrCancel;
      FmDrive.Close;
      end;
    VK_RETURN:
      begin
      mr := mrOK;
      FmDrive.Close;
      end;
    Ord('A')..Ord('Z'):
      begin
      mr := mrOK;
      if Chr(Key) = DrvCombo.Text[1] then
        FmDrive.Close;
      end;
    end;
end;

procedure TFmDrive.DrvComboDrawItem(Control: TWinControl; Index: Integer;
  Rect: TRect; State: TOwnerDrawState);
var s: String;
begin

  with DrvCombo do
    begin

    if (odSelected in State)or(odFocused in State) then
      begin
      Canvas.Brush.Color := ColorAttr.CommonHighlighted.Backgroung;
      Canvas.Font.Color := ColorAttr.CommonHighlighted.Text;
      end
    else
      begin
      Canvas.Brush.Color := ColorAttr.Common.Backgroung;
      Canvas.Font.Color := ColorAttr.Common.Text;
      end;

    //Canvas.FillRect(Rect);
    case drvTypes[index] of
      dtRemovable: s := 'Removable';
      dtFixed    : s := 'HDD';
      dtCdRom    : s := 'CD-ROM';
      dtRam      : s := 'RAM DRIVE';
      end;
    s := '-[' + DrvCombo.Items[index] + ']-' + '    ' + s;
    //Canvas.TextOut(Rect.Left+2, Rect.Top, s);
    Canvas.TextRect(Rect, Rect.Left+1, Rect.Top, s);
    end;
end;

procedure TFmDrive.DrvComboSelect(Sender: TObject);
begin
  if mr = mrOK then
    FmDrive.Close;
end;

procedure TFmDrive.FormDestroy(Sender: TObject);
begin
//  ColorAttr.Free;
end;

procedure TFmDrive.FormShow(Sender: TObject);
begin
  LngLoadFrom(RemTemplates(CmControl.paths.LngFile, CmControl.paths), FmDrive);
end;

procedure TFmDrive.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  {$IFDEF SAVELNG}
  LngSaveTo(RemTemplates(CmControl.paths.LngFile, CmControl.paths), FmDrive);
  {$ENDIF}
end;

end.