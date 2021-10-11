unit FLMenu;
{$I 'defs.pas'}

interface

uses
  SysUtils, Classes, Menus, FLTypes;

type
  TMnuType = (muSeparator, muItem, muPopup, muEndPopup);
  TMnuRec = record
    MnuType: TMnuType;
    Caption: String;
    ShortCut: String;
    Command: Cardinal;
    end;
  TMnuArray = Array of TMnuRec;

type
  TFLMenu = class(TMainMenu)
  private
    { Private declarations }
    FIncFile: TFileName;
    FMnuFile: TFileName;
    FDefProc: TNotifyEvent;
  protected
    { Protected declarations }
    function MyAddItem(const MnuRec: TMnuRec; AOwner: TMenuItem): TMenuItem;
    function AssignStruct(Struct: TMnuArray; Menu: TMenuItem;
      ItemNum: Integer): Integer;
  public
    { Public declarations }
    function LoadMenu(): Integer;
  published
    { Published declarations }
    property DefProc: TNotifyEvent read FDefProc write FDefProc;
    property IncFile: TFileName read FIncFile write FIncFile;
    property MnuFile: TFileName read FMnuFile write FMnuFile;
  end;

procedure Register;

var paths: TExtPaths;

implementation

uses StrUtilsX, StrUtils, FLFunctions;

procedure Register;
begin
  RegisterComponents('Samples', [TFLMenu]);
end;

function LoadMenuStruct(FMnuFile, FIncFile: String; var MnuList: TMnuArray): Integer;
var
  slMnu, slInc: TStringList;
  cWord, cLine, s: String;
  i, j, validInt: Integer;
begin
  result := -1;
  SetLength(MnuList, 1);
  MnuList[0].MnuType := muPopup; SetLength(MnuList, 0);
  if (FMnuFile = '')or(FIncFile = '')then
    Exit
  else if not (FileExists(FMnuFile) and FileExists(FIncFile)) then
    Exit;

  slMnu := TStringList.Create;
  slInc := TStringList.Create;
  try
    slMnu.LoadFromFile(FMnuFile);
    slInc.LoadFromFile(FIncFile);
  except
    slMnu.Free;
    slInc.Free;
    Exit;
  end;
  RemoveComments(slMnu);
  RemoveComments(slInc);

  for i := 0 to slMnu.Count - 1 do
    begin
    cLine := slMnu.Strings[i];
    cWord := ExtractWord(1, cLine, [' ', #9]);
    if (UpperCase(cWord) <> 'MENUITEM')
      and(UpperCase(cWord) <> 'POPUP')
      and(UpperCase(cWord) <> 'END_POPUP') then
      Continue;
    SetLength(mnuList, Length(mnuList)+1);
    if UpperCase(ExtractWord(2, cLine, [' ', #9])) = 'SEPARATOR' then
      begin
      MnuList[Length(mnuList)-1].MnuType := muSeparator;
      Continue;
      end
    else if UpperCase(ExtractWord(2, cLine, [' ', #9])) = 'END_POPUP' then
      begin
      MnuList[Length(mnuList)-1].MnuType := muEndPopup;
      Continue;
      end;

    //item type
   if UpperCase(cWord) = 'MENUITEM' then
     MnuList[Length(mnuList)-1].MnuType := muItem
   else if UpperCase(cWord) = 'POPUP' then
     MnuList[Length(mnuList)-1].MnuType := muPopup
   else if UpperCase(cWord) = 'END_POPUP' then
     MnuList[Length(mnuList)-1].MnuType := muEndPopup
   else if UpperCase(cWord) = 'SEPARATOR' then
     MnuList[Length(mnuList)-1].MnuType := muSeparator;

    //caption
    s := Copy(cLine, Pos('"', cLine)+1, Length(cLine) - Pos('"', cLine));
    s := StrUtils.LeftStr(s, Pos('"', s)-1);
    j := Pos('\t', s);
    if j = 0 then
      MnuList[Length(mnuList)-1].Caption := s
    else
      begin
      MnuList[Length(mnuList)-1].Caption := StrUtils.LeftStr(s, j-1);
      MnuList[Length(mnuList)-1].ShortCut := StrUtils.RightStr(s, Length(s)-j-1);
      end;

    //command str
    j := WordCount(cLine, [#39, #9, #34, #44, ',', ' ']);
    if (UpperCase(cWord) = 'MENUITEM') then
      begin
      s := ExtractWord(j, cLine, [#39, #9, #34, #44, ',', ' ']);
      //command num
      Val(s, j, validInt);
      if validInt = 0 then
        MnuList[Length(mnuList)-1].Command := j
      else
        begin
        s := slInc.Values[s];
        {
        for j := 0 to slInc.Count - 1 do
          begin
          cLine := slInc.Strings[j];
          cLine := StrUtils.LeftStr(cLine, Pos(';', cLine)-1);
          cWord := StrUtils.LeftStr(cLine, Pos('=', cLine)-1);
          if UpperCase(cWord) = UpperCase(s) then
            begin
            cWord := StrUtils.RightStr(cLine, Length(cLine)-Pos('=', cLine));
            Break;
            end;
          end;}
        Val(s, j, validInt);
        if validInt = 0 then
          MnuList[Length(mnuList)-1].Command := j
        else
          MnuList[Length(mnuList)-1].Command := 0;
        end;
      end
    else
      MnuList[Length(mnuList)-1].Command := 0;

    end;

  slInc.Free;
  slMnu.Free;
  result := 0;
end;

{ TFLMenu }

function TFLMenu.AssignStruct(Struct: TMnuArray; Menu: TMenuItem;
  ItemNum: Integer): Integer;
begin
  while ItemNum <= Length(struct)-1 do
    begin
    case struct[itemNum].MnuType of
      muItem, muSeparator:
        MyAddItem(struct[itemNum], menu);
      muPopup:
        ItemNum := AssignStruct(struct,
          MyAddItem(struct[itemNum], menu),
          ItemNum+1);
      muEndPopup:
        begin
        result := ItemNum;
        Exit;
        end;
      end;
    Inc(ItemNum);
    end;
  result := Length(struct);
end;

function TFLMenu.LoadMenu: Integer;
var
  mnuList: TMnuArray;
  mnuFile, incFile: String;
begin
  result := -1;
  Items.Clear;

  mnuFile := RemTemplates(FMnuFile, Paths);
  incFile := RemTemplates(FIncFile, Paths);

  if (mnuFile = '')or(incFile = '')then
    Exit
  else if not (FileExists(mnuFile) and FileExists(incFile)) then
    Exit;
  result := LoadMenuStruct(mnuFile, incFile, mnuList);
  if result <> 0 then Exit;
  AssignStruct(mnuList, Self.Items, 0);
end;

function TFLMenu.MyAddItem(const MnuRec: TMnuRec;
  AOwner: TMenuItem): TMenuItem;
begin
  result := TMenuItem.Create(AOwner);
  if MnuRec.MnuType = muSeparator then
    result.Caption := '-'
  else
    begin
    result.Caption := MnuRec.Caption;
    if MnuRec.ShortCut <> '' then
      result.Caption := result.Caption + #9 + MnuRec.ShortCut;
    result.Tag := MnuRec.Command;
    if (result.Tag = 0)and(MnuRec.MnuType=muItem) then result.Enabled := False;
    if (MnuRec.MnuType = muItem) and Assigned(FDefProc) then
      result.OnClick := FDefProc;
    end;
  AOwner.Add(result);
end;

end.
