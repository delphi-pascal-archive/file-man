unit FLTypes;
{$I 'defs.pas'}

{***************************************************************************}
//Глобальні оголошення типів і класів

interface
  uses Graphics, Windows, Controls, Classes, StrUtilsX, SysUtils;

  type
  {$IFDEF DEBUG}
  TCmdRec = record
    Str: String;
    Cmd: Cardinal;
    end;
  TCmdList = Array of TCmdRec;
  {$ENDIF}

  //Тип сортування файлів
  TSortFile = (smNone, smFolder, smDate, smName, smExt, smSize, smRevDate, smRevName, smRevExt, smRevSize);
  //Режим відображення розміру файла (для ф-ції SizeToStrEx)
  //smDynamic - підбирається оптимальне значення TSizeMode
  TSizeMode = (smBytes, smKBytes, smMBytes, smGBytes, smTBytes, smDynamic);

  //Інформація про файли у списку і про виділені файли
  TListInfo = record
    Count, SelCount, SelCountWithDirs: Cardinal;
    Size, SelSize: Int64;
    end;

  PExtPaths = ^TExtPaths;
  TExtPaths = record
    Lister, Editor: String;
    ListerParams, EditorParams: String;
    IniFile, LngFile, MnuFile: String;
    end;

  TFilterMode = (fmAll, fmExecs, fmUserSpec);

{************************** НАСТРОЙКИ КОЛЬОРІВ *****************************}

  //Режим перемалювання клітинки
  TCellState = (sCommon, sHighlight, sMark, sHighlightMark);

  TRowColorAttr_ = class(TGraphicsObject)
    {HorzBorder, VertBorder,}
    private
      FBackgroung, FText: TColor;
    published
      property Backgroung: TColor read FBackgroung write FBackgroung;
      property Text: TColor read FText write FText;
    end;

  //Об'єкт - атрибути кольора
  TRowColorAttr = class(TGraphicsObject)
    private
      FCommon, FMark, FCommonHighlighted,
      FMarkHighlighted,
      FHeaderPressed, FHeaderUnpressed: TRowColorAttr_;
    public
      constructor Create; virtual;
      destructor Destroy; override;
    published
      property Common: TRowColorAttr_ read FCommon write FCommon;
      property Mark: TRowColorAttr_ read FMark write FMark;
      property CommonHighlighted: TRowColorAttr_ read FCommonHighlighted
        write FCommonHighlighted;
      property MarkHighlighted: TRowColorAttr_ read FMarkHighlighted
        write FMarkHighlighted;
      property HeaderPressed: TRowColorAttr_ read FHeaderPressed
        write FHeaderPressed;
      property HeaderUnPressed: TRowColorAttr_ read FHeaderUnPressed
        write FHeaderUnPressed;
    end;

{********************* ОБ'ЄКТ - ІНФОРМАЦІЯ ПРО ФАЙЛ ************************}

type
  //TFileItem.Flags - у файлі FLConst.pas
  TFileItem = class(TObject)
    //additional
    Num: Longint;
    Flags: Byte;
    SubItems: TList;
    //find data
    Attr: Cardinal;
    Name: String;
    Size: Int64;
    TimeCreation: TFileTime;
    TimeLastAccess: TFileTime;
    TimeLastWrite: TFileTime;
    end;

type
  TCopyFlagsEx = record
    Replace, ReplaceAll, ReplaceAllOlder,
    Skip, SkipAll,
    Rename, Resume,
    SkipIOError, SkipIOErrorAll,
    Abort: Boolean;
    end;

  TProgressInfo = record
    SizeTotal, SizeCurrent, SizeTotalDone: Int64;
    CountTotal, CountDone: Integer;
    end;

{*************************** ПРОЦЕДУРНІ ТИПИ *******************************}

  TFileProc = function (Fi: TFileItem; Progress: TProgressInfo; ExtData: Pointer): Integer;
  TSortEvent = procedure (Sender: TObject; SortFile: TSortFile) of object;
  TMsgEvent = procedure (Sender: TObject; Msg: String) of object;
  TCommandEvent = procedure (Sender: TObject; Cmd: Cardinal) of object;

{*********************** СУМІСНІСТЬ З FS-ПЛАГІНАМИ *************************}

type
  tRemoteInfo=record
    SizeLow,SizeHigh:longint;
    LastWriteTime:TFileTime;
    Attr:longint;
  end;
  pRemoteInfo=^tRemoteInfo;

type
  tFsDefaultParamStruct=record
    size,
    PluginInterfaceVersionLow,
    PluginInterfaceVersionHi:longint;
    DefaultIniName:array[0..MAX_PATH-1] of char;
  end;
  pFsDefaultParamStruct=^tFsDefaultParamStruct;

{***************** СУМІСНІСТЬ З FS-ПЛАГІНАМИ - ПРОЦЕДУРНІ ТИПИ *************}

{ callback functions }
type
  TProgressProc=function(PluginNr:integer;SourceName,TargetName:pchar;PercentDone:integer):integer; stdcall;
  TLogProc=procedure(PluginNr,MsgType:integer;LogString:pchar); stdcall;
  TRequestProc=function(PluginNr,RequestType:integer;CustomTitle,CustomText,ReturnedText:pchar;maxlen:integer):bool; stdcall;

{imported functions}
type
TFsInit =
  function (PluginNr:integer;pProgressProc:tProgressProc;pLogProc:tLogProc;
    pRequestProc:tRequestProc):integer; stdcall;

TFsFindFirst =
  function (path :pchar;var FindData:tWIN32FINDDATA):thandle; stdcall;

TFsFindNext =
  function (Hdl:thandle;var FindData:tWIN32FINDDATA):bool; stdcall;

TFsFindClose =
  function (Hdl:thandle):integer; stdcall;

TFsMkDir =
  function (RemoteDir:pchar):bool; stdcall;

TFsExecuteFile =
  function (MainWin:thandle;RemoteName,Verb:pchar):integer; stdcall;

TFsRenMovFile =
  function (OldName,NewName:pchar;Move,OverWrite:bool;RemoteInfo:pRemoteInfo):integer; stdcall;

TFsGetFile =
  function (RemoteName,LocalName:pchar;CopyFlags:integer;RemoteInfo:pRemoteInfo):integer; stdcall;

TFsPutFile =
  function (LocalName,RemoteName:pchar;CopyFlags:integer):integer; stdcall;

TFsDeleteFile =
  function (RemoteName:pchar):bool; stdcall;

TFsRemoveDir =
  function (RemoteName:pchar):bool; stdcall;

TFsDisconnect =
  function (DisconnectRoot:pchar):bool; stdcall;

TFsSetAttr =
  function (RemoteName:pchar;NewAttr:integer):bool; stdcall;

TFsSetTime =
  function (RemoteName:pchar;CreationTime,LastAccessTime,LastWriteTime:PFileTime):bool; stdcall;

TFsStatusInfo =
  procedure (RemoteDir:pchar;InfoStartEnd,InfoOperation:integer); stdcall;

TFsGetDefRootName =
  procedure (DefRootName:pchar;maxlen:integer); stdcall;

TFsExtractCustomIcon =
  function (RemoteName:pchar;ExtractFlags:integer;var TheIcon:hicon):integer; stdcall;

TFsSetDefaultParams =
  procedure (dps:pFsDefaultParamStruct); stdcall;

{************************** ТИПИ ДЛЯ FLMASK *******************************}

type
  TSizeMode1 = (m1Equal, m1Smaller, m1Larger,
    m1SmallerOrEqual, m1LargerOrEqual);
  TSizeMode2 = (m2Bytes, m2KBytes, m2MBytes);
  //Чи перевіряти атрибут файлу:
  // amDontCare - не перевіряти
  // amChecked - повинен бути наявним
  // amUnChecked - повинен бути відсутнім
  TAttrMode = (amDontCare, amChecked, amUnChecked);
  TOlderThenMode = (omMinutes, omHours, omDays, omWeeks, omMonths, omYears);

implementation

uses cxDrive10;

{ TRowColorAttr }

constructor TRowColorAttr.Create;
begin
  FCommon := TRowColorAttr_.Create;
  FMark := TRowColorAttr_.Create;
  FCommonHighlighted := TRowColorAttr_.Create;
  FMarkHighlighted := TRowColorAttr_.Create;
  FHeaderPressed := TRowColorAttr_.Create;
  FHeaderUnPressed := TRowColorAttr_.Create;
end;

destructor TRowColorAttr.Destroy;
begin
  FCommon.Free;
  FMark.Free;
  FCommonHighlighted.Free;
  FMarkHighlighted.Free;
  FHeaderPressed.Free;
  FHeaderUnPressed.Free;

  inherited;
end;

end.