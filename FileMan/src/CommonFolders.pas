unit CommonFolders;
{$I 'defs.pas'}

interface

uses
  Windows, SysUtils, ShlObj, ActiveX;

  //---------------------------------------------------------------------------
  // Common Folders Location
  //---------------------------------------------------------------------------

  function GetCommonFilesFolder: string;
  function GetCurrentFolder: string;
  function GetProgramFilesFolder: string;
  function GetWindowsFolder: string;
  function GetWindowsSystemFolder: string;
  function GetWindowsTempFolder: string;
  function GetDesktopFolder: string;
  function GetProgramsFolder: string;
  function GetPersonalFolder: string;
  function GetFavoritesFolder: string;
  function GetStartupFolder: string;
  function GetRecentFolder: string;
  function GetSendToFolder: string;
  function GetStartmenuFolder: string;
  function GetDesktopDirectoryFolder: string;
  function GetNethoodFolder: string;
  function GetFontsFolder: string;
  function GetCommonStartmenuFolder: string;
  function GetCommonProgramsFolder: string;
  function GetCommonStartupFolder: string;
  function GetCommonDesktopdirectoryFolder: string;
  function GetAppdataFolder: string;
  function GetPrinthoodFolder: string;
  function GetCommonFavoritesFolder: string;
  function GetTemplatesFolder: string;
  function GetInternetCacheFolder: string;
  function GetCookiesFolder: string;
  function GetHistoryFolder: string;

implementation

uses Dim;

function RegReadStringDef(const RootKey: HKEY;
                          const Key, Name, Def: string): string;
                          forward;

type
{ MultiByte Character Set (MBCS) byte type }
  TMbcsByteType = (mbSingleByte, mbLeadByte, mbTrailByte);

var

  { in case of additions, don't forget to update initialization section! }

  IsWin95: Boolean = False;
  IsWin95OSR2: Boolean = False;
  IsWin98: Boolean = False;
  IsWin98SE: Boolean = False;
  IsWinME: Boolean = False;
  IsWinNT: Boolean = False;
  IsWinNT3: Boolean = False;
  IsWinNT4: Boolean = False;
  IsWin2K: Boolean = False;

const
  HKLM_CURRENT_VERSION_WINDOWS = 'Software\Microsoft\Windows\CurrentVersion';
  HKLM_CURRENT_VERSION_NT      = 'Software\Microsoft\Windows NT\CurrentVersion';

const
  {$IFDEF LINUX}
  PathSeparator    = '/';
  {$ENDIF LINUX}
  {$IFDEF WIN32}
  DriveLetters     = ['a'..'z', 'A'..'Z'];
  PathDevicePrefix = '\\.\';
  PathSeparator    = '\';
  PathUncPrefix    = '\\';
  {$ENDIF WIN32}

function RelativeKey(const Key: string): PChar;
begin
  Result := PChar(Key);
  if (Key <> '') and (Key[1] = '\') then
    Inc(Result);
end;

function PidlFree(var IdList: PItemIdList): Boolean;
var
  Malloc: IMalloc;
begin
  Result := False;
  if IdList = nil then
    Result := True
  else
  begin
    if Succeeded(SHGetMalloc(Malloc)) and (Malloc.DidAlloc(IdList) > 0) then
    begin
      Malloc.Free(IdList);
      IdList := nil;
      Result := True;
    end;
  end;
end;

procedure StrResetLength(var S: AnsiString);
begin
  SetLength(S, StrLen(PChar(S)));
end;

function PidlToPath(IdList: PItemIdList): string;
begin
  SetLength(Result, MAX_PATH);
  if SHGetPathFromIdList(IdList, PChar(Result)) then
    StrResetLength(Result)
  else
    Result := '';
end;

function GetSpecialFolderLocation(const Folder: Integer): string;
var
  FolderPidl: PItemIdList;
begin
  if Succeeded(SHGetSpecialFolderLocation(0, Folder, FolderPidl)) then
  begin
    Result := PidlToPath(FolderPidl);
    PidlFree(FolderPidl);
  end
  else
    Result := '';
end;

function PathRemoveSeparator(const Path: string): string;
var
  L: Integer;
begin
  L := Length(Path);
  if (L <> 0) and (AnsiLastChar(Path) = PathSeparator) then
    Result := Copy(Path, 1, L - 1)
  else
    Result := Path;
end;

function StrLen(S: PChar): Integer; assembler;
asm
        TEST    EAX, EAX
        JZ      @@EXIT

        PUSH    EBX
        MOV     EDX, EAX                 // save pointer
@L1:    MOV     EBX, [EAX]               // read 4 bytes
        ADD     EAX, 4                   // increment pointer
        LEA     ECX, [EBX-$01010101]     // subtract 1 from each byte
        NOT     EBX                      // invert all bytes
        AND     ECX, EBX                 // and these two
        AND     ECX, $80808080           // test all sign bits
        JZ      @L1                      // no zero bytes, continue loop
        TEST    ECX, $00008080           // test first two bytes
        JZ      @L2
        SHL     ECX, 16                  // not in the first 2 bytes
        SUB     EAX, 2
@L2:    SHL     ECX, 9                   // use carry flag to avoid a branch
        SBB     EAX, EDX                 // compute length
        POP     EBX

        JZ      @@EXIT                   // Az: SBB sets zero flag
        DEC     EAX                      // do not include null terminator
@@EXIT:
end;

// Utility function which returns the Windows independent CurrentVersion key
// inside HKEY_LOCAL_MACHINE

function REG_CURRENT_VERSION: string;
begin
  if IsWinNT then
    Result := HKLM_CURRENT_VERSION_NT
  else
    Result := HKLM_CURRENT_VERSION_WINDOWS;
end;

//------------------------------------------------------------------------------

function GetCommonFilesFolder: string;
begin
  Result := RegReadStringDef(HKEY_LOCAL_MACHINE, HKLM_CURRENT_VERSION_WINDOWS,
    'CommonFilesDir', '');
end;

//------------------------------------------------------------------------------

function GetCurrentFolder: string;
var
  Required: Cardinal;
begin
  Result := '';
  Required := GetCurrentDirectory(0, nil);
  if Required <> 0 then
  begin
    SetLength(Result, Required);
    GetCurrentDirectory(Required, PChar(Result));
    StrResetLength(Result);
  end;
end;

//------------------------------------------------------------------------------

function GetProgramFilesFolder: string;
begin
  Result := RegReadStringDef(HKEY_LOCAL_MACHINE, HKLM_CURRENT_VERSION_WINDOWS,
    'ProgramFilesDir', '');
end;

//------------------------------------------------------------------------------

function GetWindowsFolder: string;
var
  Required: Cardinal;
begin
  Result := '';
  Required := GetWindowsDirectory(nil, 0);
  if Required <> 0 then
  begin
    SetLength(Result, Required);
    GetWindowsDirectory(PChar(Result), Required);
    StrResetLength(Result);
  end;
end;

//------------------------------------------------------------------------------

function GetWindowsSystemFolder: string;
var
  Required: Cardinal;
begin
  Result := '';
  Required := GetSystemDirectory(nil, 0);
  if Required <> 0 then
  begin
    SetLength(Result, Required);
    GetSystemDirectory(PChar(Result), Required);
    StrResetLength(Result);
  end;
end;

//------------------------------------------------------------------------------

function GetWindowsTempFolder: string;
var
  Required: Cardinal;
begin
  Result := '';
  Required := GetTempPath(0, nil);
  if Required <> 0 then
  begin
    SetLength(Result, Required);
    GetTempPath(Required, PChar(Result));
    StrResetLength(Result);
    Result := PathRemoveSeparator(Result);
  end;
end;

//------------------------------------------------------------------------------

function GetDesktopFolder: string;
begin
  Result := GetSpecialFolderLocation(CSIDL_DESKTOP);
end;

//------------------------------------------------------------------------------

function GetProgramsFolder: string;
begin
  Result := GetSpecialFolderLocation(CSIDL_PROGRAMS);
end;

//------------------------------------------------------------------------------

function GetPersonalFolder: string;
begin
  Result := GetSpecialFolderLocation(CSIDL_PERSONAL);
end;

//------------------------------------------------------------------------------

function GetFavoritesFolder: string;
begin
  Result := GetSpecialFolderLocation(CSIDL_FAVORITES);
end;

//------------------------------------------------------------------------------

function GetStartupFolder: string;
begin
  Result := GetSpecialFolderLocation(CSIDL_STARTUP);
end;

//------------------------------------------------------------------------------

function GetRecentFolder: string;
begin
  Result := GetSpecialFolderLocation(CSIDL_RECENT);
end;

//------------------------------------------------------------------------------

function GetSendToFolder: string;
begin
  Result := GetSpecialFolderLocation(CSIDL_SENDTO);
end;

//------------------------------------------------------------------------------

function GetStartmenuFolder: string;
begin
  Result := GetSpecialFolderLocation(CSIDL_STARTMENU);
end;

//------------------------------------------------------------------------------

function GetDesktopDirectoryFolder: string;
begin
  Result := GetSpecialFolderLocation(CSIDL_DESKTOPDIRECTORY);
end;

//------------------------------------------------------------------------------

function GetNethoodFolder: string;
begin
  Result := GetSpecialFolderLocation(CSIDL_NETHOOD);
end;

//------------------------------------------------------------------------------

function GetFontsFolder: string;
begin
  Result := GetSpecialFolderLocation(CSIDL_FONTS);
end;

//------------------------------------------------------------------------------

function GetCommonStartmenuFolder: string;
begin
  Result := GetSpecialFolderLocation(CSIDL_COMMON_STARTMENU);
end;

//------------------------------------------------------------------------------

function GetCommonProgramsFolder: string;
begin
  Result := GetSpecialFolderLocation(CSIDL_COMMON_PROGRAMS);
end;

//------------------------------------------------------------------------------

function GetCommonStartupFolder: string;
begin
  Result := GetSpecialFolderLocation(CSIDL_COMMON_STARTUP);
end;

//------------------------------------------------------------------------------

function GetCommonDesktopdirectoryFolder: string;
begin
  Result := GetSpecialFolderLocation(CSIDL_COMMON_DESKTOPDIRECTORY);
end;

//------------------------------------------------------------------------------

function GetAppdataFolder: string;
begin
  Result := GetSpecialFolderLocation(CSIDL_APPDATA);
end;

//------------------------------------------------------------------------------

function GetPrinthoodFolder: string;
begin
  Result := GetSpecialFolderLocation(CSIDL_PRINTHOOD);
end;

//------------------------------------------------------------------------------

function GetCommonFavoritesFolder: string;
begin
  Result := GetSpecialFolderLocation(CSIDL_COMMON_FAVORITES);
end;

//------------------------------------------------------------------------------

function GetTemplatesFolder: string;
begin
  Result := GetSpecialFolderLocation(CSIDL_TEMPLATES);
end;

//------------------------------------------------------------------------------

function GetInternetCacheFolder: string;
begin
  Result := GetSpecialFolderLocation(CSIDL_INTERNET_CACHE);
end;

//------------------------------------------------------------------------------

function GetCookiesFolder: string;
begin
  Result := GetSpecialFolderLocation(CSIDL_COOKIES);
end;

//------------------------------------------------------------------------------

function GetHistoryFolder: string;
begin
  Result := GetSpecialFolderLocation(CSIDL_HISTORY);
end;

// the following special folders are pure virtual and cannot be
// mapped to a directory path:
// CSIDL_INTERNET
// CSIDL_CONTROLS
// CSIDL_PRINTERS
// CSIDL_BITBUCKET
// CSIDL_DRIVES
// CSIDL_NETWORK
// CSIDL_ALTSTARTUP
// CSIDL_COMMON_ALTSTARTUP

function RegReadStringDef(const RootKey: HKEY; const Key, Name, Def: string): string;
var
  RegKey: HKEY;
  Size: DWORD;
  StrVal: string;
  RegKind: DWORD;
begin
  Result := Def;
  if RegOpenKeyEx(RootKey, RelativeKey(Key), 0, KEY_READ, RegKey) = ERROR_SUCCESS then
  begin
    RegKind := 0;
    Size := 0;
    if RegQueryValueEx(RegKey, PChar(Name), nil, @RegKind, nil, @Size) = ERROR_SUCCESS then
      if RegKind in [REG_SZ, REG_EXPAND_SZ] then
      begin
        SetLength(StrVal, Size);
        if RegQueryValueEx(RegKey, PChar(Name), nil, @RegKind, PByte(StrVal), @Size) = ERROR_SUCCESS then
        begin
          SetLength(StrVal, StrLen(PChar(StrVal)));
          Result := StrVal;
        end;
      end;
    RegCloseKey(RegKey);
  end;
end;

initialization

{
  IsWin95: Boolean = False;
  IsWin95OSR2: Boolean = False;
  IsWin98: Boolean = False;
  IsWin98SE: Boolean = False;
  IsWinME: Boolean = False;
  IsWinNT: Boolean = False;
  IsWinNT3: Boolean = False;
  IsWinNT4: Boolean = False;
  IsWin2K: Boolean = False;
}

  case GetOperatingSystem() of
    UndefinedWindows:
      IsWin95 := True;
    Windows3x:
      IsWin95 := True;
    Windows95:
      IsWin95 := True;
    Windows98:
      IsWin98 := True;
    WindowsME, WindowsNT, Windows2000, WindowsXP:
      IsWinNT := True;
    end;

end.
