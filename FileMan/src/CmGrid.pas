unit CmGrid;
{$I 'defs.pas'}

interface

uses
  SysUtils, Classes, Controls, ExtCtrls, FLGrid, FLTypes, Graphics, StdCtrls;

type
  TCmGrid = class(TWinControl)
  private
    function GetColor: TColor;
    procedure SetColor(const Value: TColor);
    function GetStatusBar: Boolean;
    procedure SetStatusBar(const Value: Boolean);
    function GetDriveInfo: Boolean;
    procedure SetDriveInfo(const Value: Boolean);
    function GetPathBar: Boolean;
    procedure SetPathBar(const Value: Boolean);
    function GetNameBar: Boolean;
    procedure SetNameBar(const Value: Boolean);
    { Private declarations }
  protected
    { Protected declarations }
    FPanel: TFLGrid;
    FTopPan1, FTopPan2, FTopPan3, FBottomPan: TPanel;
    FPathEdit: TEdit;
    FBottomLab, FTopLab, FNameLab: TLabel;
    procedure SetParent(AParent: TWinControl); override;
    procedure DirChange(Sender: TObject);
    procedure SelChange(Sender: TObject);
    procedure MTopExit(Sender: TObject);
    procedure MTopEnter(Sender: TObject);
    procedure MTopClick(Sender: TObject);
    procedure MTopKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure MTopLeftChanged(Sender: TObject);
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    { Published declarations }
    procedure RefreshSelInfo();
    procedure RefreshDrvInfo();
    property Panel: TFLGrid read FPanel;
    property Color_: TColor read GetColor write SetColor;
    property Edit: TEdit read FPathEdit write FPathEdit;
    property BtmLab: TLabel read FBottomLab write FBottomLab;
    property StatusBar: Boolean read GetStatusBar write SetStatusBar;
    property DriveInfo: Boolean read GetDriveInfo write SetDriveInfo;
    property PathBar: Boolean read GetPathBar write SetPathBar;
    property NameBar: Boolean read GetNameBar write SetNameBar;
  end;

procedure Register;

implementation

uses Dialogs, FLConst, Forms, Windows, FLFunctions, cxDrive10;

const
  BOTTOM_PAN_HEIGHT = 18;
  TOP_PAN_HEIGHT = 18;

procedure Register;
begin
  RegisterComponents('Samples', [TCmGrid]);
end;

{ TFileMan }

constructor TCmGrid.Create(AOwner: TComponent);
begin
  inherited;
  FPanel := TFLGrid.Create(Self);
  FPanel.OnDirectoryChanged := DirChange;
  FPanel.OnSetMark := SelChange;
  FPanel.OnTopLeftChanged := MTopLeftChanged;

  FTopPan1 := TPanel.Create(Self);
  FTopPan2 := TPanel.Create(Self);
  FTopPan3 := TPanel.Create(Self);
  FBottomPan := TPanel.Create(Self);
  FPathEdit := TEdit.Create(Self);
  FBottomLab := TLabel.Create(Self);
  FTopLab := TLabel.Create(Self);
  FNameLab := TLabel.Create(Self);

  FTopPan1.Height := TOP_PAN_HEIGHT;
  FTopPan1.BevelOuter := bvNone;
  FTopPan2.Height := TOP_PAN_HEIGHT - 2;
  FTopPan2.BevelOuter := bvNone;
  FTopPan3.Height := TOP_PAN_HEIGHT - 2;
  FTopPan3.BevelOuter := bvNone;
  FBottomPan.BevelOuter := bvNone;
  FBottomPan.Height := BOTTOM_PAN_HEIGHT;

  FPathEdit.Left := 1;
  FPathEdit.Width := DEF_GRID_WIDTH-2;
  FPathEdit.Top := 0;
  FPathEdit.OnKeyDown := MTopKeyDown;
  FPathEdit.OnExit := MTopExit;
  FPathEdit.OnEnter := MTopEnter;
  FPathEdit.OnClick := MTopClick;
  FPathEdit.Height := FPanel.DefaultRowHeight-2;
  FPathEdit.BorderStyle := bsNone;
  FPathEdit.Anchors := [akTop, akLeft, akRight];
  FPathEdit.HideSelection := True;

  FBottomLab.Top := 2;
  FBottomLab.Left := 2;
  FTopLab.Top := 3;
  FTopLab.Left := 3;
  FNameLab.Top := 0;
  FNameLab.Left := 3;

  Self.Width := DEF_GRID_WIDTH;
  Self.Height := DEF_GRID_HEIGHT;
  Self.Color := FPanel.ColorAttr.Common.Backgroung;
end;

destructor TCmGrid.Destroy;
begin
  FPanel.Free;
  FPathEdit.Free;
  FTopLab.Free;
  FNameLab.Free;
  FBottomLab.Free;
  FTopPan1.Free;
  FTopPan2.Free;
  FTopPan3.Free;
  FBottomPan.Free;
  inherited;
end;

function TCmGrid.GetColor: TColor;
begin
  result := Color;
end;

procedure TCmGrid.DirChange(Sender: TObject);
begin
  if not Assigned(FPathEdit)then
    Exit;
  if FPanel.UseMaskEx then
    FPathEdit.Text := FPanel.Directory + FPanel.MaskEx.FileMask
  else
    FPathEdit.Text := FPanel.Directory + '*.*';

  RefreshSelInfo();
  RefreshDrvInfo();
end;

procedure TCmGrid.SelChange(Sender: TObject);
begin
  RefreshSelInfo();
end;

procedure TCmGrid.SetColor(const Value: TColor);
begin
  color := Value;
  if not Assigned(FPathEdit)then
    Exit;
  with FPanel.ColorAttr, FPathEdit do
    begin
    Color := Common.Backgroung;
    Font.Color := Common.Text;
    Font.Name := FPanel.Font.Name;
    Font.Size := FPanel.Font.Size;
    Font.Style := FPanel.Font.Style;
    end;
  with FTopLab, FPanel.Font do
    begin
    Font.Name := Name;
    Font.Size := Size;
    Font.Style := Style;
    end;
  with FNameLab, FPanel.Font do
    begin
    Font.Name := Name;
    Font.Size := Size;
    Font.Style := Style;
    end;
  with FBottomLab, FPanel.Font do
    begin
    Font.Name := Name;
    Font.Size := Size;
    Font.Style := Style;
    end;
end;

procedure TCmGrid.SetParent(AParent: TWinControl);
begin
  inherited;
  if (FPanel = nil)
    or(AParent = nil)
    or(Self = nil) then Exit;

  FTopPan1.Align := alTop;
  FTopPan1.Parent := Self;
  FTopPan3.Align := alTop;
  FTopPan3.Parent := Self;
  FTopPan2.Align := alTop;
  FTopPan2.Parent := Self;
  FBottomPan.Align := alBottom;
  FBottomPan.Parent := Self;
  FPathEdit.Parent := FTopPan2;
  FPathEdit.TabStop := False;
  FBottomLab.Parent := FBottomPan;
  FTopLab.Parent := FTopPan1;
  FNameLab.Parent := FTopPan3;

  FPanel.Align := alClient;
  FPanel.Parent := Self;
  FPanel.SortFile := smName;
end;

procedure TCmGrid.MTopKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  case Key of
    VK_ESCAPE:
      FPanel.SetFocus;
    VK_RETURN:
      begin
      FPanel.Directory := FPathEdit.Text;
      FPanel.SetFocus;
      end;
    end;
end;

procedure TCmGrid.MTopExit(Sender: TObject);
begin
  DirChange(Sender);
end;

procedure TCmGrid.MTopEnter(Sender: TObject);
begin
  FPathEdit.Text := FPanel.Directory;
  FPathEdit.SelectAll;
  if Assigned(FPanel.OnEnter) then
    FPanel.OnEnter(FPanel);
end;

procedure TCmGrid.MTopClick(Sender: TObject);
begin
  FPathEdit.SelectAll;
end;

procedure TCmGrid.RefreshSelInfo;
//Оновлення інформації під списком файлів
//Дістає і відображає інформацію про кількість
//і розмір вибраних файлів і т.д.
var
  count, countSel, vol, volSel: String;
begin
  volSel := SizeToStr(FPanel.ListInfo.SelSize div 1024);
  vol := SizeToStr(FPanel.ListInfo.Size div 1024);
  countSel := SizeToStr(FPanel.ListInfo.SelCount);
  count := SizeToStr(FPanel.ListInfo.Count);
  FBottomLab.Caption := Format(S_SELINFO, [volSel, vol, countSel, count]);
end;

procedure TCmGrid.RefreshDrvInfo;
//Оновлення інформації над списком файлів
//Дістає і відображає інформацію про активний логічний диск
var
  dt: TDriveType;
  di: TDriveInfo;
  i: Byte;
  lab, vol, free: String;

begin
  for i := 0 to MAX_DRIVES do
    begin
    dt := TDriveType.Create(i);
    if (dt.DriveType<>dtNoRoot)and(dt.DriveType<>dtRemote)
      and (chr(ord('A')+i) = UpperCase(FPanel.Directory[1]))then
      begin
      di := TDriveInfo.Create(i);
      lab := di.VolumeLabel;
      vol := SizeToStr(di.Space.BytesTotal.AsNumber div 1024);
      free := SizeToStr(di.Space.BytesFree.AsNumber div 1024);
      di.Free;
      lab := Lowercase(lab);
      if lab = '' then lab := NO_DRIVE_LABEL;
      FTopLab.Caption := Format(S_DRVINFO, [chr(ord('A')+i), lab, free, vol]);
      end;
    dt.Free;
    end;
end;

function TCmGrid.GetStatusBar: Boolean;
begin
  result := FBottomPan.Visible;
end;

procedure TCmGrid.SetStatusBar(const Value: Boolean);
begin
  FBottomPan.Visible := Value;
end;

function TCmGrid.GetPathBar: Boolean;
begin
  result := FTopPan2.Visible;
end;

procedure TCmGrid.SetPathBar(const Value: Boolean);
begin
  FTopPan2.Visible := Value;
end;

function TCmGrid.GetDriveInfo: Boolean;
begin
  result := FTopPan1.Visible;
end;

procedure TCmGrid.SetDriveInfo(const Value: Boolean);
begin
  FTopPan1.Visible := Value;
end;

function TCmGrid.GetNameBar: Boolean;
begin
  result := FTopPan3.Visible;
end;

procedure TCmGrid.SetNameBar(const Value: Boolean);
begin
  FTopPan3.Visible := Value;
end;

procedure TCmGrid.MTopLeftChanged(Sender: TObject);
begin
  if FTopPan3.Visible then
    FNameLab.Caption := FPanel.HighlightedFile.Name;
end;

end.