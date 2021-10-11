unit Progress;
{$I 'defs.pas'}

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Gauges;

type
  TFmProgress = class(TForm)
    FileInd: TGauge;
    BtnCancel: TButton;
    Label1: TLabel;
    Src: TLabel;
    Label3: TLabel;
    Target: TLabel;
    Operation: TLabel;
    TotalInd: TGauge;
    procedure BtnCancelClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
    procedure SetExtMode(const Value: Boolean);
    function GetExtMode: Boolean;
  public
    { Public declarations }
    //Закрити вікно (звичайним Close закривається не завжди)
    procedure CloseForce;
    function ShowProgress(SourceName, TargetName: String;
      PercentDone: Integer; PercentTotal: Integer = -1): Integer;
    //True - показувати два індикатори: поточного файлу і загальний
    property Extended: Boolean read GetExtMode write SetExtMode;
  end;

var
  FmProgress: TFmProgress;

implementation

uses Main, FLConst, CmControl, FLFunctions;

{$R *.dfm}

var
  Terminated: Boolean;
  Forced: Boolean;

procedure TFmProgress.BtnCancelClick(Sender: TObject);
begin
  Terminated := True;
end;

procedure TFmProgress.CloseForce;
begin
  Forced := True;
  FmMain.Enabled := True;
  FmProgress.Close;
end;

procedure TFmProgress.FormShow(Sender: TObject);
begin
  LngLoadFrom(RemTemplates(CmControl.paths.LngFile, CmControl.paths), FmProgress);
  Terminated := False;
  Forced := False;
  FmMain.Enabled := False;
end;

procedure TFmProgress.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  CanClose := Forced;
  Terminated := True;
end;

procedure TFmProgress.SetExtMode(const Value: Boolean);
begin
  if Value = Extended then Exit;
  if Value then
    begin
    TotalInd.Visible := True;
    Height := 165;
    end
  else
    begin
    TotalInd.Visible := False;
    Height := 140;
    end;
end;

procedure TFmProgress.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_ESCAPE then Terminated := True;
end;

function TFmProgress.ShowProgress(SourceName, TargetName: String;
  PercentDone, PercentTotal: Integer): Integer;
begin
  Src.Caption := SourceName;
  Target.Caption := TargetName;
  FileInd.Progress := PercentDone;
  TotalInd.Progress := PercentTotal;
  if Terminated then result := 1
  else result := 0;
  Application.ProcessMessages;
end;

function TFmProgress.GetExtMode: Boolean;
begin
  result := TotalInd.Visible;
end;

procedure TFmProgress.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  {$IFDEF SAVELNG}
  LngSaveTo(RemTemplates(CmControl.paths.LngFile, CmControl.paths), FmProgress);
  {$ENDIF}
  Terminated := False;
end;

end.