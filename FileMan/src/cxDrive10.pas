{********************************************************************************************************}
{                                                                                                        }
{ Carbonsoft cxDisk Drive Information Class Release 1                                                    }
{                                                                                                        }
{ Copyright © 2004 Kev French, Carbonsoft. All rights reserved.                                          }
{ http://www.carbonsoft.com/cxdrive/                                                                     }
{                                                                                                        }
{ IMPORTANT INFORMATION                                                                                  }
{ This work is licensed under the Creative Commons Attribution-ShareAlike License. To view a copy        }
{ of this license, visit http://creativecommons.org/licenses/by-sa/1.0/ or send a letter to Creative     }
{ Commons, 559 Nathan Abbott Way, Stanford, California 94305, USA.                                       }
{                                                                                                        }
{ You are free:                                                                                          }
{   - to copy, distribute, display, and perform the work                                                 }
{   - to make derivative works                                                                           }
{   - to make commercial use of the work                                                                 }
{                                                                                                        }
{ Under the following conditions:                                                                        }
{   - Attribution. You must give the original author credit                                              }
{   - Share Alike. If you alter, transform, or build upon this work, you may distribute the              }
{                  resulting work only under a license identical to this one                             }
{                                                                                                        }
{ - For any reuse or distribution, you must make clear to others the license terms of this work          }
{ - Any of these conditions can be waived if you get permission from the author.                         }
{                                                                                                        }
{ For more information please contact licensing@carbonsoft.com                                           }
{                                                                                                        }
{********************************************************************************************************}
{                                                                                                        }
{ History:                                                                                               }
{ 08-Oct-2003       1.0.05b      Preview release                                                         }
{                                                                                                        }
{********************************************************************************************************}
unit cxDrive10;

interface

// MSWINDOWS define not present pre Delphi 6
{$IFDEF WIN32}
  {$IFNDEF MSWINDOWS}
    {$DEFINE MSWINDOWS}
  {$ENDIF MSWINDOWS}
{$ENDIF WIN32}

uses
  Classes, SysUtils, Windows, ShellApi;

//--------------------------------------------------------------------------------------------------------
// Enhanced integer and boolean types
//--------------------------------------------------------------------------------------------------------

resourcestring
  RsDisk_Format_Yes      = 'Yes';
  RsDisk_Format_No       = 'No';
  RsDisk_Format_On       = 'On';
  RsDisk_Format_Off      = 'Off';

  RsDisk_Format_Integer  = '%d';

  RsDisk_Format_Bytes    = '%d bytes';
  RsDisk_Format_KBytes   = '%1.0n Kb';
  RsDisk_Format_MBytes   = '%1.0n Mb';
  RsDisk_Format_GBytes   = '%1.2n Gb';
  RsDisk_Format_TBytes   = '%1.2n Tb';

  RsDisk_Format_Version  = '%d.%d.%2.2d';

type
  IDiskHugeNumber = interface
    ['{C540F255-F373-4A20-AF1E-2A3C03BFDFDE}']
    function AsNumber: Int64;
    function Formatted: String;
  end;
  TDiskHugeNumber = class(TInterfacedObject, IDiskHugeNumber)
  private
    fValue: Int64;
  public
    constructor Create(Value: Int64);
    destructor Destroy; override;

    function AsNumber: Int64;
    function Formatted: String;
  end;

  IDiskBoolean = interface
    ['{D6669ECF-6FB5-4854-AD86-04CEDA6B6692}']
    function AsBoolean: Boolean;
    function FormatYesNo: String;
    function FormatOnOff: String;
  end;
  TDiskBoolean = class(TInterfacedObject, IDiskBoolean)
  private
    fValue: Boolean;
  public
    constructor Create(Value: Boolean);
    destructor Destroy; override;

    function AsBoolean: Boolean;
    function FormatYesNo: String;
    function FormatOnOff: String;
  end;

//--------------------------------------------------------------------------------------------------------
// Drive type
//--------------------------------------------------------------------------------------------------------

resourcestring
  RsDisk_Type_Unknown    = 'Unknown';
  RsDisk_Type_NoRoot     = 'No Drive';
  RsDisk_Type_Removable  = 'Removable';
  RsDisk_Type_Fixed      = 'Fixed';
  RsDisk_Type_Remote     = 'Remote';
  RsDisk_Type_CdRom      = 'CdRom';
  RsDisk_Type_Ram        = 'Ram';

type
  TDriveTypeEnum = (dtUnknown, dtNoRoot, dtRemovable, dtFixed, dtRemote, dtCdRom, dtRam);

  IDriveType = interface
    ['{7279EE2B-5B97-41FF-B793-4DD5A0C39783}']
    function DriveType: TDriveTypeEnum;
    function Name: String;
  end;
  TDriveType = class(TInterfacedObject, IDriveType)
  private
    fDrive: Integer;

    function DrivePath: String;
  public
    constructor Create(Drive: Integer);
    destructor Destroy; override;

    function DriveType: TDriveTypeEnum;
    function Name: String;
  end;

const
  cDriveTypeMap: array[dtUnknown..dtRam] of String = (RsDisk_Type_Unknown, RsDisk_Type_NoRoot,
                                                      RsDisk_Type_Removable, RsDisk_Type_Fixed,
                                                      RsDisk_Type_Remote, RsDisk_Type_CdRom,
                                                      RsDisk_Type_Ram);

//--------------------------------------------------------------------------------------------------------
// Drive features
//--------------------------------------------------------------------------------------------------------

type
  IDriveFeatures = interface
    ['{E94E88F0-74D0-4DB2-8737-28F76D32A2B6}']
    function NamedStreams: IDiskBoolean;
    function ReadOnly: IDiskBoolean;
    function ObjectIds: IDiskBoolean;
    function ReparsePoints: IDiskBoolean;
    function SparseFiles: IDiskBoolean;
    function DiskQuotas: IDiskBoolean;
    function CasePreserved: IDiskBoolean;
    function CaseSensitive: IDiskBoolean;
    function FileCompression: IDiskBoolean;
    function FileEncryption: IDiskBoolean;
    function PersistentAcl: IDiskBoolean;
    function UnicodeOnDisk: IDiskBoolean;
    function Compressed: IDiskBoolean;
  end;
  TDriveFeatures = class(TInterfacedObject, IDriveFeatures)
  private
    fFeatures: DWord;
  public
    constructor Create(Features: DWord);
    destructor Destroy; override;
    function NamedStreams: IDiskBoolean;
    function ReadOnly: IDiskBoolean;
    function ObjectIds: IDiskBoolean;
    function ReparsePoints: IDiskBoolean;
    function SparseFiles: IDiskBoolean;
    function DiskQuotas: IDiskBoolean;
    function CasePreserved: IDiskBoolean;
    function CaseSensitive: IDiskBoolean;
    function FileCompression: IDiskBoolean;
    function FileEncryption: IDiskBoolean;
    function PersistentAcl: IDiskBoolean;
    function UnicodeOnDisk: IDiskBoolean;
    function Compressed: IDiskBoolean;
  end;

const
  FILE_VOLUME_QUOTAS            = $00000020;
  FS_FILE_ENCRYPTION            = $00020000;
  FILE_NAMED_STREAMS            = $00040000;
  FILE_SUPPORTS_OBJECT_IDS      = $00010000;
  FILE_READ_ONLY_VOLUME         = $00080000;
  FILE_SUPPORTS_REPARSE_POINTS  = $00000080;
  FILE_SUPPORTS_SPARSE_FILES    = $00000040;

//--------------------------------------------------------------------------------------------------------
// Drive space
//--------------------------------------------------------------------------------------------------------

type
  IDriveSpace = interface
    ['{4FC33F5D-8C76-4F5F-AAD6-EAE1C51E8D29}']
    function BytesAvailable: IDiskHugeNumber;
    function BytesTotal: IDiskHugeNumber;
    function BytesFree: IDiskHugeNumber;
    function BytesUsed: IDiskHugeNumber;
  end;
  TDriveSpace = class(TInterfacedObject, IDriveSpace)
  private
    fDrive: Integer;

    fBytesAvailable: Int64;
    fTotalBytes: Int64;
    fTotalFreeBytes: Int64;

    procedure GetDriveSpaceInfo;
  public
    constructor Create(Drive: Integer);
    destructor Destroy; override;

    function BytesAvailable: IDiskHugeNumber;
    function BytesTotal: IDiskHugeNumber;
    function BytesFree: IDiskHugeNumber;
    function BytesUsed: IDiskHugeNumber;
  end;

//--------------------------------------------------------------------------------------------------------
// Drive shell information
//--------------------------------------------------------------------------------------------------------

  IDriveShellInfo = interface
    ['{CF04F655-B982-4B06-8216-2719E29D9DDB}']
    function Icon: HIcon;
    function Image: Integer;
    function DisplayName: String;
    function TypeName: String;
  end;

  TDriveShellInfo = class(TInterfacedObject, IDriveShellInfo)
  private
    fDrive: Integer;
    fShellDriveInfo: TSHFileInfo;

    procedure GetDriveShellInfo;
  public
    constructor Create(Drive: Integer);
    destructor Destroy; override;

    function Icon: HIcon;
    function Image: Integer;
    function DisplayName: String;
    function TypeName: String;
  end;

//--------------------------------------------------------------------------------------------------------
// Drive information
//--------------------------------------------------------------------------------------------------------

type
  TVolumeInformation = record
    Index: Integer;
    RootPathName: String;
    DisplayName: String;
    VolumeNameBuffer: String;
    VolumeSerialNumber: DWord;
    MaximumComponentLength: DWord;
    FileSystemFlags: DWord;
    FileSystemName: String;
  end;

  IDriveInfo = interface
    ['{4300B119-01C0-4140-95F5-521ED5F7BC9B}']
    function Available: IDiskBoolean;
    function DriveType: IDriveType;
    function Index: Integer;
    function Letter: String;
    function VolumeLabel: String;
    function Features: IDriveFeatures;
    function Space: IDriveSpace;
    function Serial: String;
    function Shell: IDriveShellInfo;
    function FileSystem: String;
    procedure ShowShellDialog;
  end;
  TDriveInfo = class(TInterfacedObject, IDriveInfo)
  private
    fDrive: Integer;
    fDriveInfo: TVolumeInformation;

    procedure GetDriveInfo;
  public
    constructor Create(Drive: Integer);
    destructor Destroy; override;

    function Available: IDiskBoolean;
    function DriveType: IDriveType;
    function Index: Integer;
    function Letter: String;
    function VolumeLabel: String;
    function Features: IDriveFeatures;
    function Space: IDriveSpace;
    function Serial: String;
    function Shell: IDriveShellInfo;
    function FileSystem: String;

    procedure ShowShellDialog;
  end;

//--------------------------------------------------------------------------------------------------------
// Drive object
//--------------------------------------------------------------------------------------------------------

const
  cDisk_DrivePath_Fmt = '%s:\';
  cDriveLetters: array[0..25] of char = ('A','B','C','D','E','F','G','H','I','J','K','L','M',
                                         'N','O','P','Q','R','S','T','U','V','W','X','Y','Z');

type
  TcxDriveInfo = class
  private
    function GetDriveInfoByIndex(Index: Integer): IDriveInfo;
  public
    function Version: String;

    function ByLetter(Letter: String): IDriveInfo;
    property Drives[Index: Integer]: IDriveInfo read GetDriveInfoByIndex; default;
  end;

const
  cToolkit_Version  = 1005;

var
  cxDrive: TcxDriveInfo;

implementation

{ TDiskHugeNumber }

function TDiskHugeNumber.AsNumber: Int64;
begin
  Result := fValue;
end;

constructor TDiskHugeNumber.Create(Value: Int64);
begin
  inherited Create;
  fValue := Value;
end;

destructor TDiskHugeNumber.Destroy;
begin
  inherited;
end;

function TDiskHugeNumber.Formatted: String;
const
  Kbyte = 1024;
  MByte = 1048576;
  GByte = 1073741824;
begin
  if fValue < KByte then
    Result := Format(RsDisk_Format_Bytes, [fValue])
  else
    if fValue < MByte then
      Result := Format(RsDisk_Format_KBytes, [fValue / KByte])
    else
      if fValue < GByte then
        Result := Format(RsDisk_Format_MBytes, [fValue / MByte])
      else
        Result := Format(RsDisk_Format_GBytes, [fValue / GByte]);
end;

{ TDiskBoolean }

function TDiskBoolean.AsBoolean: Boolean;
begin
  Result := fValue;
end;

constructor TDiskBoolean.Create(Value: Boolean);
begin
  inherited Create;

  fValue := Value;
end;

destructor TDiskBoolean.Destroy;
begin
  inherited;
end;

function TDiskBoolean.FormatOnOff: String;
const
  cBoolean_Results: array[False..True] of String = (RsDisk_Format_Off, RsDisk_Format_On);
begin
  Result := cBoolean_Results[fValue];
end;

function TDiskBoolean.FormatYesNo: String;
const
  cBoolean_Results: array[False..True] of String = (RsDisk_Format_No, RsDisk_Format_Yes);
begin
  Result := cBoolean_Results[fValue];
end;

{ TDriveType }

constructor TDriveType.Create(Drive: Integer);
begin
  inherited Create;

  fDrive := Drive;
end;

destructor TDriveType.Destroy;
begin
  inherited;
end;

function TDriveType.DrivePath: String;
begin
  Result := Format(cDisk_DrivePath_Fmt, [cDriveLetters[fDrive]]);
end;

function TDriveType.DriveType: TDriveTypeEnum;
var
  Path: String;
begin
  Path := DrivePath;
  Result := TDriveTypeEnum(GetDriveType(PChar(Path)));
end;

function TDriveType.Name: String;
begin
  Result := cDriveTypeMap[DriveType];
end;

{ TDriveFeatures }

function TDriveFeatures.CasePreserved: IDiskBoolean;
begin
  Result := TDiskBoolean.Create((fFeatures and FS_CASE_IS_PRESERVED) <> 0);
end;

function TDriveFeatures.CaseSensitive: IDiskBoolean;
begin
  Result := TDiskBoolean.Create((fFeatures and FS_CASE_SENSITIVE) <> 0);
end;

function TDriveFeatures.Compressed: IDiskBoolean;
begin
  Result := TDiskBoolean.Create((fFeatures and FS_VOL_IS_COMPRESSED) <> 0);
end;

constructor TDriveFeatures.Create(Features: DWord);
begin
  inherited Create;

  fFeatures := Features;
end;

destructor TDriveFeatures.Destroy;
begin
  inherited;
end;

function TDriveFeatures.DiskQuotas: IDiskBoolean;
begin
  Result := TDiskBoolean.Create((fFeatures and FILE_VOLUME_QUOTAS) <> 0);
end;

function TDriveFeatures.FileCompression: IDiskBoolean;
begin
  Result := TDiskBoolean.Create((fFeatures and FS_FILE_COMPRESSION) <> 0);
end;

function TDriveFeatures.FileEncryption: IDiskBoolean;
begin
  Result := TDiskBoolean.Create((fFeatures and FS_FILE_ENCRYPTION) <> 0);
end;

function TDriveFeatures.NamedStreams: IDiskBoolean;
begin
  Result := TDiskBoolean.Create((fFeatures and FILE_NAMED_STREAMS) <> 0);
end;

function TDriveFeatures.ObjectIds: IDiskBoolean;
begin
  Result := TDiskBoolean.Create((fFeatures and FILE_SUPPORTS_OBJECT_IDS) <> 0);
end;

function TDriveFeatures.PersistentAcl: IDiskBoolean;
begin
  Result := TDiskBoolean.Create((fFeatures and FS_PERSISTENT_ACLS) <> 0);
end;

function TDriveFeatures.ReadOnly: IDiskBoolean;
begin
  Result := TDiskBoolean.Create((fFeatures and FILE_READ_ONLY_VOLUME) <> 0);
end;

function TDriveFeatures.ReparsePoints: IDiskBoolean;
begin
  Result := TDiskBoolean.Create((fFeatures and FILE_SUPPORTS_REPARSE_POINTS) <> 0);
end;

function TDriveFeatures.SparseFiles: IDiskBoolean;
begin
  Result := TDiskBoolean.Create((fFeatures and FILE_SUPPORTS_SPARSE_FILES) <> 0);
end;

function TDriveFeatures.UnicodeOnDisk: IDiskBoolean;
begin
  Result := TDiskBoolean.Create((fFeatures and FS_UNICODE_STORED_ON_DISK) <> 0);
end;

{ TDriveSpace }

function TDriveSpace.BytesAvailable: IDiskHugeNumber;
begin
  Result := TDiskHugeNumber.Create(fBytesAvailable);
end;

function TDriveSpace.BytesFree: IDiskHugeNumber;
begin
  Result := TDiskHugeNumber.Create(fTotalFreeBytes);
end;

function TDriveSpace.BytesTotal: IDiskHugeNumber;
begin
  Result := TDiskHugeNumber.Create(fTotalBytes);
end;

function TDriveSpace.BytesUsed: IDiskHugeNumber;
begin
  Result := TDiskHugeNumber.Create(fTotalBytes - fTotalFreeBytes);
end;

constructor TDriveSpace.Create(Drive: Integer);
begin
  inherited Create;

  fDrive := Drive;
  GetDriveSpaceInfo;
end;

destructor TDriveSpace.Destroy;
begin
  inherited;
end;

procedure TDriveSpace.GetDriveSpaceInfo;
var
  Path: String;
begin
  Path := Format(cDisk_DrivePath_Fmt, [cDriveLetters[fDrive]]);

  // SysUtils prototype uses appropriate WinApi function
  SysUtils.GetDiskFreeSpaceEx(PChar(Path), fBytesAvailable, fTotalBytes, @fTotalFreeBytes)
end;

{ TDriveShellInfo }

constructor TDriveShellInfo.Create(Drive: Integer);
begin
  inherited Create;

  fDrive := Drive;
  GetDriveShellInfo;
end;

destructor TDriveShellInfo.Destroy;
begin
  inherited;
end;

function TDriveShellInfo.DisplayName: String;
begin
  Result := Trim(String(fShellDriveInfo.szDisplayName));
end;

procedure TDriveShellInfo.GetDriveShellInfo;
var
  Path: String;
begin
  Path := Format(cDisk_DrivePath_Fmt , [cDriveLetters[fDrive]]);
  ShGetFileInfo(PChar(Path), 0, fShellDriveInfo, SizeOf (TSHFileInfo),
                SHGFI_TYPENAME or SHGFI_DISPLAYNAME or SHGFI_SYSICONINDEX);
end;

function TDriveShellInfo.Icon: HIcon;
begin
  Result := fShellDriveInfo.hIcon;
end;

function TDriveShellInfo.Image: Integer;
begin
  Result := fShellDriveInfo.iIcon;
end;

function TDriveShellInfo.TypeName: String;
begin
  Result := Trim(String(fShellDriveInfo.szDisplayName));
end;

{ TDriveInfo }

function TDriveInfo.Available: IDiskBoolean;
begin
  Result := TDiskBoolean.Create(cxDrive[fDrive].DriveType.DriveType <> dtNoRoot);
end;

constructor TDriveInfo.Create(Drive: Integer);
begin
  inherited Create;

  fDrive := Drive;
  GetDriveInfo;
end;

destructor TDriveInfo.Destroy;
begin
  inherited;
end;

function TDriveInfo.DriveType: IDriveType;
begin
  Result := TDriveType.Create(fDrive);
end;

function TDriveInfo.Features: IDriveFeatures;
begin
  Result := TDriveFeatures.Create(fDriveInfo.FileSystemFlags);
end;

function TDriveInfo.FileSystem: String;
begin
  Result := Trim(fDriveInfo.FileSystemName);
end;

procedure TDriveInfo.GetDriveInfo;
var
  Path: String;
  VolumeName: array[0..MAX_PATH - 1] of Char;
  VolumeSerial: DWord;
  MaxComponentLength: Cardinal;
  FeatureFlags: DWord;
  FileSystem: array[0..MAX_PATH - 1] of Char;

  ErrorMode: Cardinal;
begin
  Path := Format(cDisk_DrivePath_Fmt , [cDriveLetters[fDrive]]);

  ErrorMode := SetErrorMode(SEM_FAILCRITICALERRORS);
  try
    if GetVolumeInformation(PChar(Path), VolumeName, MAX_PATH, @VolumeSerial, MaxComponentLength, FeatureFlags,
                            @FileSystem, MAX_PATH) then
    begin
      fDriveInfo.Index := fDrive;
      fDriveInfo.RootPathName := Path;
      fDriveInfo.VolumeNameBuffer := Trim(String(VolumeName));
      fDriveInfo.VolumeSerialNumber := VolumeSerial;
      fDriveInfo.MaximumComponentLength := MaxComponentLength;
      fDriveInfo.FileSystemFlags := FeatureFlags;
      fDriveInfo.FileSystemName := Trim(String(FileSystem));
    end
    else
    begin
      fDriveInfo.Index := fDrive;
      fDriveInfo.RootPathName := Path;
      fDriveInfo.VolumeNameBuffer := '';
      fDriveInfo.VolumeSerialNumber := 0;
      fDriveInfo.MaximumComponentLength := 0;
      fDriveInfo.FileSystemFlags := 0;
      fDriveInfo.FileSystemName := '';
    end;
  finally
    SetErrorMode(ErrorMode);
  end;
end;

function TDriveInfo.Index: Integer;
begin
  Result := fDrive;
end;

function TDriveInfo.Letter: String;
begin
  Result := cDriveLetters[fDrive];
end;

function TDriveInfo.Serial: String;
begin
  Result := IntToStr(fDriveInfo.VolumeSerialNumber);
end;

function TDriveInfo.Shell: IDriveShellInfo;
begin
  Result := TDriveShellInfo.Create(fDrive);
end;

procedure TDriveInfo.ShowShellDialog;
Var
  Path: String;
  ExecuteInfo: TShellExecuteinfo;
Begin
  Path := Format(cDisk_DrivePath_Fmt , [cDriveLetters[fDrive]]);
  FillChar(ExecuteInfo, SizeOf(ExecuteInfo), 0);
  ExecuteInfo.cbSize := SizeOf(ExecuteInfo);
  ExecuteInfo.lpFile := PChar(Path);
  ExecuteInfo.lpVerb := 'properties';
  ExecuteInfo.fMask := SEE_MASK_INVOKEIDLIST;
  ShellExecuteEx(@ExecuteInfo);
end;

function TDriveInfo.Space: IDriveSpace;
begin
  Result := TDriveSpace.Create(fDrive);
end;

function TDriveInfo.VolumeLabel: String;
begin
  Result := Trim(fDriveInfo.VolumeNameBuffer)
end;

{ TcxDriveInfo }

function TcxDriveInfo.ByLetter(Letter: String): IDriveInfo;
var
  i: Integer;
begin
  for i := 0 to 25 do
    if cDriveLetters[i] = UpperCase(Letter) then
    begin
      Result := TDriveInfo.Create(i);
      Exit;
    end;
end;

function TcxDriveInfo.GetDriveInfoByIndex(Index: Integer): IDriveInfo;
begin
  Result := TDriveInfo.Create(Index);
end;

function TcxDriveInfo.Version: String;
begin
  Result := Format(RsDisk_Format_Version, [(cToolkit_Version div 1000),
                                          ((cToolkit_Version - ((cToolkit_Version div 1000)*1000)) div 100),
                                           (cToolkit_Version mod 100)]);                            
end;

initialization
  cxDrive := TcxDriveInfo.Create;

finalization
  cxDrive.Free;

end.
