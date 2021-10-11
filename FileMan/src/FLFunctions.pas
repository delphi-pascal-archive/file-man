unit FLFunctions;
{$I 'defs.pas'}

interface
  uses Windows, Classes, FLTypes, Forms;

  function ConvFileSize(dwHigh, dwLow: Cardinal): Int64;
  function FileSizeLow(FileSize: Int64): Cardinal;
  function FileSizeHigh(FileSize: Int64): Cardinal;
  function SizeToStr(FileSize: Int64): String;
  function SizeToStrEx(FileSize: Int64; SizeMode: TSizeMode): String;
  function RemoveBackSlash(const DirName: string): string;      {c}
  function FileTimeToDateTime(ft: TFileTime): TDateTime;        {c}
  function LastDirectory(Directory: string): string;            {c}
  function OneLevelUpDirectory(Directory: string): string;      {c}
  function IncludeBackslash(const Path: String): String;
  function RemTemplates(const s: String; const Paths: TExtPaths): String;
  function ShellExec(const FileName: string; const Parameters: string;  {c}
    const Verb: string=''; CmdShow: Integer=SW_SHOWNORMAL): Boolean;
  function ShellOpenAs(const FileName: string): Boolean;         {c}
  function ShellExecAndWait(const FileName: string; const Parameters: string;
    const Verb: string=''; CmdShow: Integer=SW_SHOWNORMAL): Boolean;  {c}
  function FileRec(FileName: String): TWin32FindData;
  function MyDiskFree(Disk: Char): Int64;
  function MyHex(Digit: Cardinal): String;
  function FirstAvailableRoot(): String;
  function DisplayPropDialog(const Handle: HWND; const FileName: string): Boolean;  {c}
{  function DisplayPropDialog(const Handle: HWND; const Item: PItemIdList): Boolean; overload;}
  procedure ParseCmdStr(DosCommand: String; var Cmd, Params: String);
  function ClusterSize(Drive: Char): Int64;
  procedure RemoveComments(var SList: TStringList);
  function ValidFileName(const FileName: string): Boolean;  {c}
  procedure Delay(MSecs: Longint);
  procedure LngLoadFrom(const LngFile: String; Form: TForm);
  procedure LngSaveTo(const LngFile: String; Form: TForm);
  function GetFileSize(const FileName: string): Int64;
  function PathGetLongName2(Path: string): string;
  {$IFDEF DEBUG}
  procedure LogIt(LogStr: String = ''); overload;
  procedure LogIt(LogCmd: Integer); overload;
  procedure ExtractCommands(incFile: String);
  function Cmd2Str(cmd: Cardinal): String;
  {$ENDIF}

implementation

uses SysUtils, StrUtils, StrUtilsX, CommonFolders, ShellAPI, Dialogs,
  cxDrive10, FLConst, IniFiles, StdCtrls, TypInfo;

function ConvFileSize(dwHigh, dwLow: Cardinal): Int64;
begin
  result := dwHigh;
  result := (result shl 32) or dwLow;
end;

function SizeToStr(FileSize: Int64): String;
//відділення пробілами розрядів-тисяч
const SPACE = #32;
var s: String; i: Word;
begin
  s := IntToStr(FileSize);
  result := s[Length(s)];

  for i := Length(s)-1 downto 1 do
    if (Length(s) - i)mod 3 = 0 then
      result := s[i]+SPACE+ result
    else
      result := s[i] + result;
end;

function SizeToStrEx(FileSize: Int64; SizeMode: TSizeMode): String;
const
  caps: Array[TSizeMode] of String =
    ('b', 'Kb', 'Mb', 'Gb', 'Tb', #0);
var
  k: Int64;
begin
  k := -1;
  case SizeMode of
    smBytes   : k := 1;
    smKBytes  : k := 1024;
    smMBytes  : k := 1024*1024;
    smGBytes  : k := 1024*1024*1024;
    smTBytes  : begin k := 1024*1024*1024; k := k*1024; end;
    smDynamic :
      begin
      case FileSize of
        0..1024-1                  : SizeMode := smBytes;
        1024..1024*1024-1          : SizeMode := smKBytes;
        1024*1024..1024*1024*1024-1: SizeMode := smMBytes;
        else                         SizeMode := smGBytes;
        end;
      result := SizeToStrEx(FileSize, SizeMode);
      Exit;
      end;
    end;
  result := SizeToStr(FileSize div k) + #32 + caps[SizeMode];
end;

function RemoveBackSlash(const DirName: string): string;
begin
  Result := DirName;
  if (Length(Result) > 1) and
{$IFDEF RX_D3}
    (AnsiLastChar(Result)^ = '\') then
{$ELSE}
    (Result[Length(Result)] = '\') then
{$ENDIF}
  begin
    if not ((Length(Result) = 3) and (UpCase(Result[1]) in ['A'..'Z']) and
      (Result[2] = ':')) then
      Delete(Result, Length(Result), 1);
  end;
end;

function FileTimeToDateTime(ft: TFileTime): TDateTime;
var st: TSystemTime; tft: TFileTime;
begin
  FileTimeToLocalFileTime(ft, tft);
  FileTimeToSystemTime(tft, st);
  Result:= SystemTimeToDateTime(st);
end;

function LastDirectory(Directory: string): string;
var p: Integer; NewDir: string;
begin
  NewDir:= RemoveBackSlash(Directory);

    while True do begin
      p := Pos('\', NewDir);
      if p = 0 then break;
      NewDir:= Copy(NewDir, p+1, 999);
    end;
    Result := NewDir;
end;

function OneLevelUpDirectory(Directory: string): string;
var p, last: integer;
    NewDir: string;
begin
  NewDir:= RemoveBackSlash(Directory);
  last := 0;
  p := 0;
  repeat
    last := last + p;
    p := Pos('\', Copy(NewDir,last+1,999));
  until p = 0;
  if last = 0 then
       Result := Directory
  else Result := Copy(NewDir, 1, last);
end;

function IncludeBackslash(const Path: String): String;
begin
  result := Path;
  if (Result <> '') and (result[Length(result)] <> '\') then
    result := result + '\';
end;

function FileSizeLow(FileSize: Int64): Cardinal;
begin
  result := FileSize and $FFFFFFFF;
end;

function FileSizeHigh(FileSize: Int64): Cardinal;
begin
  result := FileSize shr 32;
end;

function RemBackSlash(const DirName: string): string;
begin
  Result := DirName;
  if (Length(Result) > 1) and
    (Result[Length(Result)] = '\') then
      Delete(Result, Length(Result), 1);
end;

function RemTemplates(const s: String; const Paths: TExtPaths): String;
begin
  result := UpperCase(s);
  result := ReplaceStr(result, '%INIFILE%', paths.IniFile);
  result := ReplaceStr(result, '%WINDOWS%', GetWindowsFolder());
  result := ReplaceStr(result, '%APP_EXE%', ParamStr(0));
  result := ReplaceStr(result, '%APP_PATH%', RemBackslash(ExtractFileDir(ParamStr(0))));
end;

function PCharOrNil(const S: AnsiString): PAnsiChar;
begin
  if Length(S) = 0 then
    Result := nil
  else
    Result := PAnsiChar(S);
end;

function ShellExec(const FileName: string; const Parameters: string;
  const Verb: string; CmdShow: Integer): Boolean;
// (c) Jedi VCL
var
  Sei: TShellExecuteInfo;
begin
  FillChar(Sei, SizeOf(Sei), #0);
  Sei.cbSize := SizeOf(Sei);
  Sei.fMask := SEE_MASK_DOENVSUBST or SEE_MASK_FLAG_NO_UI;
  Sei.lpFile := PChar(FileName);
  Sei.lpParameters := PCharOrNil(Parameters);
  Sei.lpVerb := PCharOrNil(Verb);
  Sei.nShow := CmdShow;
  Result := ShellExecuteEx(@Sei);
end;

function ShellExecAndWait(const FileName: string; const Parameters: string;
  const Verb: string; CmdShow: Integer): Boolean;
// (c) Jedi VCL
var
  Sei: TShellExecuteInfo;
begin
  FillChar(Sei, SizeOf(Sei), #0);
  Sei.cbSize := SizeOf(Sei);
  Sei.fMask := SEE_MASK_DOENVSUBST or SEE_MASK_FLAG_NO_UI or SEE_MASK_NOCLOSEPROCESS;
  Sei.lpFile := PChar(FileName);
  Sei.lpParameters := PCharOrNil(Parameters);
  Sei.lpVerb := PCharOrNil(Verb);
  Sei.nShow := CmdShow;
  Result := ShellExecuteEx(@Sei);
  if Result then
  begin
    WaitForInputIdle(Sei.hProcess, INFINITE);
    WaitForSingleObject(Sei.hProcess, INFINITE);
    CloseHandle(Sei.hProcess);
  end;
end;

function ShellOpenAs(const FileName: string): Boolean;
// (c) Jedi VCL
begin
  Result := ShellExecAndWait('rundll32', Format('shell32.dll,OpenAs_RunDLL "%s"', [FileName]), '', SW_SHOWNORMAL);
end;

function FileRec(FileName: String): TWin32FindData;
var rec: TWin32FindData; h: THandle;
begin
  FillChar(rec, SizeOf(rec), 0);
  h := FindFirstFile(PAnsiChar(FileName), rec);
  if h <> INVALID_HANDLE_VALUE then
    result := rec;
  Windows.FindClose(h);
end;

function MyDiskFree(Disk: Char): Int64;
var
  sectPerClust, bytesPerSec, freeClust, totalClust: Cardinal;
  s: String;
  rez: LongBool;

begin
  s := disk + ':\';
  rez := GetDiskFreeSpace(PAnsiChar(s), sectPerClust, bytesPerSec, freeClust, totalClust);
  result := freeClust*sectPerClust*bytesPerSec;
  if not rez then
    result := -1;
end;

function MyHex(Digit: Cardinal): String;
begin
  result := Lowercase('$'+Dec2Hex(Digit, 6));
end;

function FirstAvailableRoot(): String;
//Знаходить шлях до кореневої директорії першого (за алфавітом) доступного
//логічного диску (жорсткого, якщо можливо)
var
  dt: TDriveType;
  i: Byte;
  n: Integer;
begin
  n := -1;
  for i := 0 to MAX_DRIVES do
    begin
    dt := TDriveType.Create(i);
    if (dt.DriveType=dtFixed)and(DirectoryExists(chr(ord('A')+i) + ':\'))then
      begin
      n := i;
      dt.Free;
      Break
      end;
    dt.Free;
    end;

  //Якщо немає жодного жорсткого диску, то шукати будь-який
  if n = -1 then
    for i := 0 to MAX_DRIVES do
      begin
      dt := TDriveType.Create(i);
      if (dt.DriveType<>dtNoRoot)and(dt.DriveType<>dtRemote)
        and(dt.DriveType<>dtNoRoot)and(DirectoryExists(chr(ord('A')+i) + ':\'))then
        begin
        n := i;
        dt.Free;
        Break;
        end;
      dt.Free;
      end;

  result := chr(ord('A')+n) + ':\';
end;

function DisplayPropDialog(const Handle: HWND; const FileName: string): Boolean;
// (c) Jedi VCL
var
  Info: TShellExecuteInfo;
begin  //можливо для діалогу "Властивості файлу"
  FillChar(Info, SizeOf(Info), #0);
  with Info do
  begin
    cbSize := SizeOf(Info);
    lpFile := PChar(FileName);
    nShow := SW_SHOW;
    fMask := SEE_MASK_INVOKEIDLIST;
    Wnd := Handle;
    lpVerb := PChar('properties');
  end;
  Result := ShellExecuteEx(@Info);
end;
(*
function DisplayPropDialog(const Handle: HWND; const Item: PItemIdList): Boolean;
// (c) Jedi VCL
var
  Info: TShellExecuteInfo;
begin
  FillChar(Info, SizeOf(Info), #0);
  with Info do
  begin
    cbSize := SizeOf(Info);
    nShow := SW_SHOW;
    lpIDList := Item;
    fMask := SEE_MASK_INVOKEIDLIST or SEE_MASK_IDLIST;
    Wnd := Handle;
    lpVerb := PChar('properties');
  end;
  Result := ShellExecuteEx(@Info);
end;
    *)

procedure ParseCmdStr(DosCommand: String; var Cmd, Params: String);
//Вхідний параметр - DosCommand - командний рядок.
//Функція розділяє DosCommand на власне команду (назву файла) і параметри.
const BRACKETS = [#39, #34];  //символи, які вважаються за лапки
begin
  DosCommand := Trim(DosCommand);
  if Length(DosCommand) = 0 then
    begin
    cmd := '';
    params := '';
    Exit;
    end;

  ReplaceStr(DosCommand, #39, #34);
  if DosCommand[1] = #34 then
    begin
    cmd := ExtractWord(1, DosCommand, [#34]);
    params := Copy(DosCommand,
                   Length(cmd)+3,
                   Length(DosCommand) - Length(cmd) - 2);
    end
  else
    begin
    cmd := ExtractWord(1, DosCommand, [#32]);
    params := Copy(DosCommand,
                   Length(cmd)+1,
                   Length(DosCommand) - Length(cmd));
    end;

  Params := Trim(params);
end;

function ClusterSize(Drive: Char): Int64;
//Повертає розмір кластера (ПРАЦЮЄ НЕПРАВИЛЬНО!)
var
  sectPerClust, bytesPerSect, clustFree, clustTotal: Cardinal;
  root: PAnsiChar;
begin
  root := PAnsiChar(drive + ':\');
  if GetDiskFreeSpace(root, sectPerClust, bytesPerSect, clustFree, clustTotal) then
    result := bytesPerSect*sectPerClust
  else
    result := -1;
end;

procedure RemoveComments(var SList: TStringList);
var i, j, cnt: Integer;
begin
  i := 0;
  while i <= slist.Count - 1 do
    begin
    if (slist.Strings[i] = '')or(slist.Strings[i][1] = ';') then
      slist.Delete(i)
    else
      begin
      cnt := WordCount(slist.Strings[i], [';']);
      if cnt >= 2 then
        for j := cnt downto 2 do
          slist.Strings[i] := ReplaceStr(slist.Strings[i],
            ';' + ExtractWord(j, slist.Strings[i], [';']),
            '');
      slist.Strings[i] := ReplaceStr(slist.Strings[i], ';', '');
      if (slist.Strings[i][1] = ';')or(slist.Strings[i][1] = '') then
        slist.Delete(i)
      else
        Inc(i);
      end;
    end;
end;

function ValidFileName(const FileName: string): Boolean;
//(c) RX Library
  function HasAny(const Str, Substr: string): Boolean;
  var
    I: Integer;
  begin
    Result := False;
    for I := 1 to Length(Substr) do begin
      if Pos(Substr[I], Str) > 0 then begin
        Result := True;
        Break;
      end;
    end;
  end;
begin
  Result := (FileName <> '') and (not HasAny(FileName, '<>"[]|'));
//  if Result then Result := Pos('\', ExtractFileName(FileName)) = 0;
end;

procedure Delay(MSecs: Longint);
//(c) RX Library
var
  FirstTickCount, Now: Longint;
begin
  FirstTickCount := GetTickCount;
  repeat
    Application.ProcessMessages;
    { allowing access to other controls, etc. }
    Now := GetTickCount;
  until (Now - FirstTickCount >= MSecs) or (Now < FirstTickCount);
end;

procedure LngSaveTo(const LngFile: String; Form: TForm);
var
  ini: TIniFile;
  i: Integer;
  PropInfo:PPropInfo;
  atext: String;

begin
  ini := TIniFile.Create(LngFile);
  {$IFDEF DEBUG}
  if not FileExists(LngFile) then
    LogIt('LngSave Failed: lng='+LngFile);
  {$ENDIF}

  for i := 0 to Form.ComponentCount - 1 do
    begin
    PropInfo := GetPropInfo(Form.Components[i],'caption');
    if PropInfo <> nil then
      begin
      atext := GetStrProp(Form.Components[i], PropInfo);
      if atext <> '' then
        ini.WriteString(Form.Name,
                        LowerCase(Form.Components[i].Name+'.Cap'),
                        atext);
      end;

    PropInfo := GetPropInfo(Form.Components[i],'text');
    if PropInfo <> nil then
      begin
      atext := GetStrProp(Form.Components[i], PropInfo);
      if atext <> '' then
        ini.WriteString(Form.Name,
                        LowerCase(Form.Components[i].Name+'.Tex'),
                        atext);
      end;

    PropInfo := GetPropInfo(Form.Components[i],'hint');
    if PropInfo <> nil then
      begin
      atext := GetStrProp(Form.Components[i], PropInfo);
      if atext <> '' then
        ini.WriteString(Form.Name,
                        LowerCase(Form.Components[i].Name+'.Tip'),
                        atext);
      end;

    end;

  ini.Free;
end;

procedure LngLoadFrom(const LngFile: String; Form: TForm);
var
  ini: TIniFile;
  i: Integer;
  PropInfo:PPropInfo;
  atext: String;

begin
  ini := TIniFile.Create(LngFile);
  {$IFDEF DEBUG}
  if not FileExists(LngFile) then
    LogIt('LngRead Failed: lng='+LngFile);
  {$ENDIF}

  for i := 0 to Form.ComponentCount - 1 do
    begin
    PropInfo := GetPropInfo(Form.Components[i],'caption');
    if PropInfo <> nil then
      begin
      atext := ini.ReadString(Form.Name,
                      LowerCase(Form.Components[i].Name+'.Cap'),
                      '');
      if atext <> '' then
        SetStrProp(Form.Components[i], 'caption', atext);
      end;

    PropInfo := GetPropInfo(Form.Components[i],'text');
    if PropInfo <> nil then
      begin
      atext := ini.ReadString(Form.Name,
                      LowerCase(Form.Components[i].Name+'.Tex'),
                      '');
      if atext <> '' then
        SetStrProp(Form.Components[i], 'text', atext);
      end;

    PropInfo := GetPropInfo(Form.Components[i],'hint');
    if PropInfo <> nil then
      begin
      atext := ini.ReadString(Form.Name,
                      LowerCase(Form.Components[i].Name+'.Tip'),
                      '');
      if atext <> '' then
        SetStrProp(Form.Components[i], 'hint', atext);
      end;

    end;

  ini.Free;
end;

function GetFileSize(const FileName: string): Int64;
var
  SearchRec: TWin32FindData;
  h: Cardinal;
begin
  h := FindFirstFile(PAnsiChar(ExpandFileName(FileName)), SearchRec);
  if h <> INVALID_HANDLE_VALUE then
    Result := ConvFileSize(SearchRec.nFileSizeHigh, SearchRec.nFileSizeLow)
  else Result := -1;
  Windows.FindClose(h);
end;

function PathGetLongName2(Path: string): string;
// (c) Jedi VCL
var
  I : Integer;
  SearchHandle : THandle;
  FindData : TWin32FindData;
  IsBackSlash : Boolean;
begin
  Path := ExpandFileName(Path);
  Result := UpperCase(ExtractFileDrive(Path));
  I := Length(Result);
  if Length(Path) <= I then Exit;   // only drive
  if Path[I + 1] = '\' then
  begin
    Result := Result + '\';
    Inc(I);
  end;
  Delete(Path, 1, I);
  repeat
    I := Pos('\', Path);
    IsBackSlash := I > 0;
    if Not IsBackSlash then
      I := Length(Path) + 1;
    SearchHandle := FindFirstFile(PChar(Result + Copy(Path, 1,
      I - 1)), FindData);
    if SearchHandle <> INVALID_HANDLE_VALUE then
    begin
      try
        Result := Result + FindData.cFileName;
        if IsBackSlash then
          Result := Result + '\';
      finally
        Windows.FindClose(SearchHandle);
      end;
    end
    else
    begin
      Result := Result + Path;
      Break;
    end;
    Delete(Path, 1, I);
  until Length(Path) = 0;
end;

{$IFDEF DEBUG}

procedure LogIt(LogStr: String = '');
begin
  if LogStr<>'' then
    LogStr := LogStr
  else
    LogStr := #13#10+'  ['+DateTimeToStr(GetTime())+']';
  Writeln(DebugLog, LogStr);
end;

procedure LogIt(LogCmd: Integer); overload;
var s: String;
begin
  s := Cmd2Str(LogCmd);
  Writeln(DebugLog, 'cmd='+s);
end;

procedure ExtractCommands(incFile: String);
var
  rez: String;
  i, validInt: Integer;
  cmd: Cardinal;
  sl: TStringList;
begin
  rez := '';
  SetLength(cmdList, 0);
  sl := TStringList.Create;
  try
    sl.LoadFromFile(incFile);
  except
    sl.Free;
    Exit;
  end;

  RemoveComments(sl);

  for i := 0 to sl.Count - 1 do
    begin
    Val(sl.Values[sl.Names[i]], cmd, validInt);
    if validInt = 0 then
      begin
      SetLength(cmdList, Length(cmdList)+1);
      cmdList[Length(cmdList)-1].Str := sl.Names[i];
      cmdList[Length(cmdList)-1].Cmd := cmd;
      end;
    end;
    
  sl.Free;
end;

function Cmd2Str(cmd: Cardinal): String;
var i: Integer;
begin
  result := '';
  for i := 0 to Length(cmdList)-1 do
    if cmdList[i].Cmd = cmd then
      begin
      result := cmdList[i].Str;
      Break;
      end;
  if result = '' then
    result := IntToStr(cmd);
end;
{$ENDIF}

end.