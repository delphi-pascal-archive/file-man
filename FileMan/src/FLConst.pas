unit FLConst;
{$I 'defs.pas'}

interface

uses FLMessages, Graphics{$IFDEF DEBUG}, SysUtils, Forms, Classes, FLFunctions, FLTypes{$ENDIF};

const APP_VERSION = '0.0.16';
{$IFDEF DEBUG}
const APP_NAME = 'FileMan '+APP_VERSION+' debug';
var
  DebugLog: Text;
  cmdList: TCmdList;
{$ELSE}
const APP_NAME = 'FileMan '+APP_VERSION;
{$ENDIF}

const
  //size const
  ROW_HEIGHT = 16;
  DEF_COL_COUNT = 4;
  DEF_COL_WIDTH = 70;
  DEF_GRID_HEIGHT = 250;
  DEF_GRID_WIDTH = 350;
  GRID_LINE_WIDTH = 0;
  //icons to show
  LOAD_DEF_ICONS = True;
  //colors
  CL_HIGHLIGHT = $00E68604;
  CL_HIGHLIGHTED_TEXT = $00FFFFFF;
  CL_COMMON_TEXT = $00FFFFFF;
  CL_HEADER = $808080;
  CL_BACKGROUND = $00CA0000;
  CL_MARK = $00CA0000;
  CL_MARK_TEXT = $000000FF;
  CL_MARK_HIGHL = $00E68604;
  CL_MARK_HIGHL_TEXT = $000000FF;

  //font
  FONT_FACE = 'MS Sans Serif';//'Tahoma';
  FONT_SIZE = 8;
  FONT_STYLE = [fsBold];

  MAX_DRIVES = 30;

  TOOLBAR_ACTS: Array[0..3, 1..10] of Cardinal =
    ((0, cm_RereadSource, cm_List, cm_Edit, cm_Copy,
      cm_RenMov, cm_MkDir, cm_Recycle, cm_Associate, 0),
     (0, 0, 0, 0, 0,
      0, 0, 0, 0, 0),
     (cm_LeftOpenDrives, cm_RightOpenDrives, 0, 0, 0,
      0, cm_SearchFor, 0, 0, 0),
     (0, 0, 0, 0, 0,
      cm_RenameOnly, 0, cm_Delete, 0, 0)
      );

const
  //TFileItem.Flags - це комбінація значень:
  FL_DIRUP = 1;         //перехід на рівень вгору
  FL_MARK = 2;          //помічений файл
  FL_SYS_ICON = 4;      //файл з нестандартною іконкою
  FL_DIROPEN = 8;
  FL_UNUSED5 = 16;
  FL_UNUSED6 = 32;
  FL_UNUSED7 = 64;
  FL_UNUSED8 = 128;

var    //error strings
  NO_FILES_SELECTED: String = 'No file(s) selected!';
  ER_NO_SPACE      : String = 'Not enough free space!'+#13#10+'Continue anyway?';
  ER_WRITEERROR    : String = 'Write error!';
  ER_READERROR     : String = 'Read error!';
  ER_PROGR_NOT_EXEC: String = 'Error executing program!';
  ER_ERROR         : String = 'Unknown error %s';
  ER_ITSELF        : String = 'You cannot copy a file to itself!';
  ER_NOPATH        : String = 'Path not found %s';
  ER_NOLISTER      : String = 'Lister not found: "%s"';
  ER_NOEDITOR      : String = 'Editor not found: "%s"';
  ER_MULTATTR      : String = 'Multi-change attributes is not supported!';
  ER_MULTREN       : String = 'Multi-rename is not supported!';
  ER_RENFILE       : String = 'Error while renaming file!';
  ER_NOFILE        : String = 'File not found "%s"';
  ER_INIWRITE      : String = 'Cannot save settings to file "%s"';
  ER_OPERATION     : String = 'Operation not supported!';
  ER_FILEEXISTS    : String = 'File (or directory) already exists!';
  ER_FILEWRITE     : String = 'Write error!';

var    // strings
  S_DIR_UP         : String = '<DIR-UP>';
  S_FOLDER         : String = '<FOLDER>';
  S_NAME           : String = 'Name';
  S_EXT            : String = 'Ext';
  S_SIZE           : String = 'Size';
  S_DATE           : String = 'Date';
  S_ATTR           : String = 'Attr';
  S_NEWSEL         : String = 'New selection type';
  S_ENTMASK        : String = 'Enter file mask (*.* or other)';
  S_NEWDIR         : String = 'New directory';
  S_ENTDIR         : String = 'Enter directory name';
  S_SELFILES       : String = 'Select files';
  S_UNSFILES       : String = 'Unselect files';
  S_RENFILE        : String = 'Rename file';
  S_SELINFO        : String = '%s k of %s k / %s of %s files';
  S_DRVINFO        : String = '%s:[%s] %s of %s k free';
  S_DELETE         : String = 'Do you really want to delete selected file(s)?';
  S_RENONLY        : String = 'Rename "%s" to:';
  S_COPY           : String = 'Copying';
  S_RENMOVE        : String = 'Renaming/moving';
  S_REMOVE         : String = 'Removing';
  NO_DRIVE_LABEL   : String = '_empty_';
  EXE_MASK         : String = '*.EXE;*.COM;*.BAT;*.PIF;*.CMD';
  S_NOFILESFOUND   : String = '<-no files found->';
  S_SEARCH         : String = 'Files: %s; Folders: %s';

  S_ABOUT          : String =
      #13#10+'Курсовая работа'
      +#13#10+'Болоховецкий А. Ю., группа ИН-35, email:soulmare@gmail.com'
      +#13#10#13#10+'Дрогобычский Государственный Педагогический Университет'
      +#13#10+'им. Ивана Франко'
      +#13#10+'Украина, 2006 р.';

var
  //Перший індекс:
  //0 - Shift = []
  //1 - ssCtrl in Shift
  //2 - ssAlt in Shift
  //3 - ssShift in Shift
  TOOLBAR_CAPS: Array[0..3, 1..10] of String =
    (('F1Help',     'F2Reread',   'F3View',     'F4Edit',     'F5Copy',
      'F6Ren/Mov',  'F7MkDir',    'F8Delete',   'F9OpenAs',   ''),
     ('',           '',           '',           '',           '',
      '',           '',           '',           '',           '         '),
     ('F1Left',     'F2Right',    '',           '',           '',
      '',           'F7Find',     '',           '',           '         '),
     ('',           '',           '',           '',           '',
      'F6Rename',   '',           'F8Delete',   '',           '         ')
      );


var
  COPY_BUFFER: Int64 = 1024*200;

implementation

initialization
  {$IFDEF DEBUG}
  AssignFile(DebugLog, ExtractFilePath(Application.Exename)+'debug.log');
  if FileExists(ExtractFilePath(Application.Exename)+'debug.log') then
    Append(DebugLog)
  else
    ReWrite(DebugLog);
  ExtractCommands(ExtractFilePath(Application.ExeName)+'FileMan.inc');
  {$ENDIF}

finalization
  {$IFDEF DEBUG}
  CloseFile(DebugLog);
  {$ENDIF}

end.
