unit Search;
{$I 'defs.pas'}

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, FLTypes, FLPerform, ComCtrls;

type
  TFmSearch = class(TForm)
    Pan1: TPanel;
    MaskEd: TEdit;
    BtnAct: TButton;
    BtnCancel: TButton;
    Label1: TLabel;
    PathEd: TEdit;
    Label2: TLabel;
    Label3: TLabel;
    StBar: TStatusBar;
    FindList: TListBox;
    procedure BtnActClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormShow(Sender: TObject);
    procedure BtnCancelClick(Sender: TObject);
    procedure FindListDblClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
    FFileName: String;
    FPanelRec: TPanelRec;
    FPaths: TExtPaths;

    procedure Start;
    procedure Stop;
    //procedure Pause;
    procedure MTeminated(Sender: TObject);
    procedure MFileFound(Sender: TObject; FileName: String);
    procedure MDirFound(Sender: TObject; FileName: String);
    procedure MPathChange(Sender: TObject; FileName: String);
    procedure InitForm;
  public
    { Public declarations }
    property FileName: String read FFileName write FFileName;
    procedure Init(PanelRec: TPanelRec;
      const Paths: TExtPaths);
  end;

var
  FmSearch: TFmSearch;

implementation

uses FLThreads, FLMaskEx, StrUtilsX, FLFunctions, FLConst, CmControl;

{$R *.dfm}

const
  DIR_ = 'dir> ';

var
  thr: TSearchThread;
  mask: TMaskEx;
  thrActive: Boolean;
  nFiles, nDirs: Int64;

procedure TFmSearch.BtnActClick(Sender: TObject);
begin
  if FindList.Focused then
    begin
    FindList.OnDblClick(Sender);
    end
  else
    begin
    if thrActive then
      Stop
    else
      Start;
    end;
end;

procedure TFmSearch.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  {$IFDEF SAVELNG}
  LngSaveTo(RemTemplates(CmControl.paths.LngFile, CmControl.paths), FmSearch);
  {$ENDIF}
  if Assigned(mask) then
    begin
    mask.Free;
    mask := nil;
    end;
end;

procedure TFmSearch.Start;
var s, wrd, str: String; n, i: Integer;
begin
  InitForm;
  if not DirectoryExists(PathEd.Text) then
    begin
    ShowMessage('Path not found!');
    Exit;
    end;
  PathEd.Enabled := False;

  mask := TMaskEx.Create;
  mask.Init;
  s := MaskEd.Text;
  if s <> '' then
    begin
    n := WordCount(s, [#32, ';']);
    str := '';
    for i := 1 to n do
      begin
      wrd := ExtractWord(i, s, [#32, ';']);
      if wrd[1] <> '*' then wrd := '*' + wrd;
      if wrd[Length(wrd)] <> '*' then wrd := wrd + '*';
      str := str + #32 + wrd;
      end;
    str := Trim(str);
    str := ReplaceStr(str, #32, ';');
    end
  else
    str := '*';
  mask.FileMask := str;

  thr := TSearchThread.Create(True);
  thr.Init(FPanelRec, FPaths);
  thr.FreeOnTerminate := True;
  thr.Mask := mask;
  thr.OnTerminate := MTeminated;
  thr.OnFindFile := MFileFound;
  thr.OnFindDir := MDirFound;
  thr.OnPathChange := MPathChange;
  thr.Path := PathEd.Text;

  thrActive := True;
  thr.Resume;
end;

procedure TFmSearch.Stop;
begin
  thr.Terminate;
end;

procedure TFmSearch.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := not thrActive;
  if thrActive then thr.Terminate;
end;

procedure TFmSearch.FormShow(Sender: TObject);
begin
  LngLoadFrom(RemTemplates(CmControl.paths.LngFile, CmControl.paths), FmSearch);
  InitForm;
  MaskEd.SetFocus;
end;

procedure TFmSearch.MTeminated(Sender: TObject);
begin
  thrActive := False;
  PathEd.Enabled := True;
  FindList.SetFocus;
  StBar.Panels[0].Text := PathEd.Text;
end;

procedure TFmSearch.BtnCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TFmSearch.InitForm;
begin
  StBar.Panels[0].Text := PathEd.Text;
  FindList.Clear;
  FindList.Items.Add(S_NOFILESFOUND);
  FFileName := '';
  nFiles := 0;
  nDirs := 0;
  Label3.Caption := Format(S_SEARCH, ['0', '0']);
end;

procedure TFmSearch.Init(PanelRec: TPanelRec; const Paths: TExtPaths);
begin
  FPanelRec := PanelRec;
  FPaths := Paths;
  PathEd.Text := FPanelRec.Source.Directory;
end;

procedure TFmSearch.MDirFound(Sender: TObject; FileName: String);
begin
  if FindList.Items[0] = S_NOFILESFOUND then
    begin
    FindList.Items.Clear;
    FindList.Items.Add('<------------------->');
    end;

  Inc(nDirs);
  Label3.Caption := Format(S_SEARCH, [SizeToStr(nFiles), SizeToStr(nDirs)]);
  FindList.Items.Insert(1, DIR_ + FileName);
end;

procedure TFmSearch.MFileFound(Sender: TObject; FileName: String);
begin
  if FindList.Items[0] = S_NOFILESFOUND then
    begin
    FindList.Items.Clear;
    FindList.Items.Add('<------------------->');
    end;

  Inc(nFiles);
  Label3.Caption := Format(S_SEARCH, [SizeToStr(nFiles), SizeToStr(nDirs)]);
  FindList.Items.Add(FileName);
end;

procedure TFmSearch.FindListDblClick(Sender: TObject);
begin
  if thrActive or (FindList.ItemIndex < 1)
    or((nFiles = 0)and(nDirs = 0))then Exit;
  Self.FileName := ReplaceStr(FindList.Items[FindList.ItemIndex], DIR_, '');
  Close;
end;

procedure TFmSearch.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if key = VK_ESCAPE then
    Close;
end;

procedure TFmSearch.MPathChange(Sender: TObject; FileName: String);
begin
  StBar.Panels[0].Text := FileName;
end;

end.