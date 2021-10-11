unit FLMaskEx;
{$I 'defs.pas'}

interface

uses FLTypes, Classes, SysUtils, StrUtilsX;

{const
  //TMaskEx.Flags - це комбінація значень:
  FL_SIZE = 1;
  FL_DATE_BETWEEN = 2;
  FL_DATE_NOT_OLDER = 4;
  FL_ATTRIBUTES = 8;
  FL_UNUSED5 = 16;
  FL_UNUSED6 = 32;
  FL_UNUSED7 = 64;
  FL_UNUSED8 = 128;}

{********************* ОБ'ЄКТ - ПАРАМЕТРИ ПОШУКУ ФАЙЛІВ ********************}

type
  TMaskEx = class(TStringList)
  private
    FName: String;

    //атрибути відбору файлів
    FPath: String;
    FSize: Int64;
    FSizeCompareMode: TSizeMode1;
    FSizeUnitMode: TSizeMode2;
    FAttr: Cardinal;
    FAttrArchieve, FAttrReadOnly, FAttrHidden: TAttrMode;
    FAttrSystem, FAttrDirectory: TAttrMode;
    FDateFrom, FDateTo: TDateTime;
    FOlderThen: Cardinal;
    FOlderThenMode: TOlderThenMode;

    //режим відбору файлів (що саме перевіряти)
    FCheckSize: Boolean;
    FCheckDate: Boolean;
    FCheckDateBetween: Boolean;
    FCheckOlderThen: Boolean;
    FMaskStr: String;

    procedure SetMaskStr(const Value: String);
  public
    procedure Init;
    //Перевіряє чи відповідає FileItem значенню багатозначної маски MaskStr
    function MatchMask(const FileItem: TFileItem; IgnoreCase: Boolean = True): Boolean;

    //Ім'я маски - встановлюється і використовується довільно
    property Name: String read FName write FName;
    //Багатозначна маска зі значеннями, що розділяються пробілами
    //наприклад: MaskStr:='*.exe hi??2.htm *.cpp.';
    property FileMask: String read FMaskStr write SetMaskStr;
  end;

implementation

{ TMaskEx }

const SPACES = [#32, ';'];

procedure TMaskEx.Init;
begin
  FMaskStr := '';
  FPath := '';
  FSize := 1;
  FSizeCompareMode := m1Equal;
  FSizeUnitMode := m2KBytes;
  FAttr := 0;
  FAttrArchieve := amDontCare;
  FAttrReadOnly := amDontCare;
  FAttrHidden := amDontCare;
  FAttrSystem := amDontCare;
  FAttrDirectory := amDontCare;
  FDateFrom := EncodeDate(1962, 4, 14);
  FDateTo := Date();
  FOlderThen := 1;
  FOlderThenMode := omDays;

  FCheckSize := False;
  FCheckDate := False;
  FCheckDateBetween := False;
  FCheckOlderThen := False;

end;

function TMaskEx.MatchMask(const FileItem: TFileItem;
  IgnoreCase: Boolean): Boolean;
//Перевіряє чи задовільняє файл всі умови відбору
//Співпадіння імені файлу перевіряється завжди. Якщо маска відбору імен
//файлів порожня, то перевірка за іменем завжди True
var
  i: Integer;
begin
{Спочатку вважається, що файл підходить. Потім послідовно перевіряються
 властивості файлу. Якщо якась із перевірок не справджується, то файл не
 підходить і перевірки закінчуються - вихід із підпрограми}
  result := False;

  //співпадіння імені файлу з багатозначною маскою
  if Self.Count > 0 then
    for i := 0 to Self.Count-1 do
      if IsWild(FileItem.Name, Self.Strings[i], IgnoreCase) then
        begin
        result := True;
        Break;
        end;
end;

procedure TMaskEx.SetMaskStr(const Value: String);
var i, n: Integer;
begin
  Self.Clear;
  n := WordCount(Value, SPACES);
  FMaskStr := '';
  if n = 0 then Exit;
  for i := 1 to n do
    begin
    Self.Add(ExtractWord(i, Value, SPACES));
    FMaskStr := FMaskStr + ExtractWord(i, Value, SPACES) + ';';
    end;
  SetLength(FMaskStr, Length(FMaskStr)-1);
end;

end.
