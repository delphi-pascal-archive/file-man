unit FLGrid;
{$I 'defs.pas'}

interface

uses
  Windows, Messages, Forms, SysUtils, Classes, Graphics, Controls, Grids,
  StdCtrls, FLTypes, FLMaskEx;

type
  TFLGrid = class(TCustomGrid)
  private
    { Private declarations }
    EmptyFI: TFileItem;
    FIcDir, FIcDirHid, FIcDirOpen: TIcon;
    FIcFile, FIcFileHid: TIcon;
    FIcDirUp: TIcon;
    FFileList: TList;
    FDirectory: String;
    FSort: TSortFile;
    FIconSort: TBitMap;
    FIconSort2: TBitMap;
    FTitleName: String;
    FTitleExt: String;
    FTitleSize: String;
    FTitleDate: String;
    FMaskEx: TMaskEx;
    FUseMaskEx: Boolean;
    FDirInBrackets: Boolean;
    FOnColumnMoved: TMovedEvent;
    FOnDrawCell: TDrawCellEvent;
    FOnRowMoved: TMovedEvent;
    FOnSelectCell: TSelectCellEvent;
    FOnSetEditText: TSetEditEvent;
    FOnTopLeftChanged: TNotifyEvent;
    FOnDirectoryChanged: TNotifyEvent;
    FOnFileExec: TNotifyEvent;
    FRowColorAttr: TRowColorAttr;
    FMarkRButton: Boolean;
    FListInfo: TListInfo;
    FOnSetMark: TNotifyEvent;
    FOnColResize: TNotifyEvent;
    FOnSorting: TSortEvent;
    FUserDefFilter: String;
    FFilterMode: TFilterMode;
    FFilterModeChange: TNotifyEvent;
    FPluginIndex: Integer;
    FShowIcons: Boolean;
    FNames8_3: Boolean;

    function  GetVariantValue(i: Longint; sm: TSortFile; List: TList): variant;
    procedure ReadDir(const Dir: String; AList: TList);
    procedure SetColorAttr(const Value: TRowColorAttr);
    procedure SetDirInBrackets(const Value: Boolean);
    function GetHighlightedFile: TFileItem;
    procedure SetFilterMode(const Value: TFilterMode);
    function GetFirstMarkedFile: TFileItem;

  protected
    { Protected declarations }
    procedure ColumnMoved(FromIndex, ToIndex: Longint); override;
    procedure DrawCell(ACol, ARow: Longint; ARect: TRect;
      AState: TGridDrawState); override;
//    procedure DblClick; override;
    procedure RowMoved(FromIndex, ToIndex: Longint); override;
    function  SelectCell(ACol, ARow: Longint): Boolean; override;
    procedure TopLeftChanged; override;
    procedure DirectoryChanged;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure SetDirectory(Dir: string);
    procedure SetFileItem(Name: String);
    procedure SetSortFile(sm: TSortFile);
    procedure SetSortFile2(sm: TSortFile; List: TList);
    procedure SetTitleName(Name: String);
    procedure SetTitleSize(Size: String);
    procedure SetTitleDate(Date: String);
    procedure SetTitleExt(Ext: String);
    function IsActiveControl: Boolean;
    function DoMouseWheelDown(Shift: TShiftState;
      MousePos: TPoint): Boolean; override;
    function DoMouseWheelUp(Shift: TShiftState;
      MousePos: TPoint): Boolean; override;
    function GetCellState(ARow: Longint; AState: TGridDrawState): TCellState;
    function IsRowFile(ARow: Integer): Boolean;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    function GetFIMark(Index: Integer): Boolean;
    procedure SetFIMark(Index: Integer; Value: Boolean);
    procedure ColWidthsChanged; override;
    procedure ClearFileList(var AList: TList);

    property BorderStyle;
    property DefaultColWidth;
    property FixedCols;
    property ParentColor;
    property Width;
    property Height;
    property Top;
    property Left;
    property Options;
    property FixedRows;
  public
    { Public declarations }
    procedure SetListInfo();
    function CellRect(ACol, ARow: Longint): TRect;
    procedure MouseToCell(X, Y: Integer; var ACol, ARow: Longint);
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure DeleteRow(ARow: Longint); override;
    property FileList: TList read FFileList write FFileList;
    procedure CommonSort1(iLo, iHi: longInt; sm: TSortFile; List: TList);
    procedure CommonSort2(iLo, iHi: longInt; sm: TSortFile; List: TList);
    procedure SecondSort(Master, sm: TSortFile; List: TList);
    procedure Sorting(sm: TSortFile; List: TList);
    procedure UpFolder;
    procedure GoIntoDir;

    //операції з помітками
    procedure MarkInvert(ARow: Longint; RepaintRow: Boolean);
    procedure MarkInvertEx(ARow: Longint; RepaintRow: Boolean);
    procedure MarkSetMarkEx(ARow: Longint;
      RepaintRow: Boolean; AFileList: TList);
    procedure MarkInvertAll(OnlyFiles: Boolean = False);
    procedure MarkSetMark(ARow: Longint; Marked: Boolean;
      RepaintRow: Boolean); overload;
    procedure MarkSetMark(ARowFrom, ARowTo: Longint;
      Marked: Boolean); overload;
    procedure MarkAll(Marked: Boolean; OnlyFiles: Boolean = False);
    procedure MarkAllDirs(Marked: Boolean);
    procedure MarkAllDirsEx();
    procedure MarkByMask(Marked: Boolean; Mask: TMaskEx);
    procedure MarkNoExtFiles(Marked: Boolean);

    function GetShortName(AFile: TFileItem): String;
    function GetExt(AFile: TFileItem): String;
    procedure GetTree(AFileList: TList);
    procedure TreeOperate(AFileList: TList; FileProc: TFileProc;
      ExtData: Pointer); overload;
    procedure TreeOperateInv(AFileList: TList; FileProc: TFileProc;
      ExtData: Pointer);
    procedure TreeOperate2Inv(AFileList: TList; FileProc: TFileProc;
      ExtData: Pointer);
    procedure TreeOperate2(AFileList: TList; FileProc: TFileProc;
      ExtData: Pointer); overload;
    procedure TreeOperate(AFileList: TList; FileProc: TFileProc); overload;
    procedure HideUnmarked(OnlyFiles: Boolean = True);
    procedure HideAllDirs();
    function GotoFile(FileName: String): Boolean;

    property Canvas;
    property ScrollBars;
    property Col;
    property ColWidths;
    property Color;
    property EditorMode;
    property GridHeight;
    property GridWidth;
    property LeftCol;
    property Selection;
    property Row;
    property RowHeights;
    property TabStops;
    property ColCount;
    property TopRow;
    procedure LoadIcons();
    procedure DestroyIcons();
    property HighlightedFile: TFileItem read GetHighlightedFile;
    property FirstMarkedFile: TFileItem read GetFirstMarkedFile;
    property MaskEx: TMaskEx read FMaskEx write FMaskEx;
    property UseMaskEx: Boolean read FUseMaskEx write FUseMaskEx;
    property PluginIndex: Integer read FPluginIndex write FPluginIndex;
    function RereadSrc: Boolean;
    function RereadSoft: Boolean;
  published
    { Published declarations }
    property Align;
    property Ctl3D;
    property DefaultRowHeight;
    property DefaultDrawing;
    property DragCursor;
    property DragMode;
    property Enabled;
    property FixedColor;
    property RowCount;
    property Font;
    property GridLineWidth;
    property ParentCtl3D;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property TabOrder;
    property TabStop;
    property Visible;
    property VisibleColCount;
    property VisibleRowCount;
    property OnClick;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnStartDrag;
    property OnMouseMove;
    property OnMouseUp;
    property Directory: string read FDirectory write SetDirectory;
    property SortFile: TSortFile read FSort write SetSortFile;
    property TitleName: String read FTitleName write SetTitleName;
    property TitleSize: String read FTitleSize write SetTitleSize;
    property TitleDate: String read FTitleDate write SetTitleDate;
    property TitleExt: String read FTitleExt write SetTitleExt;
    property ColorAttr: TRowColorAttr read FRowColorAttr
      write SetColorAttr;
    property OnColumnMoved: TMovedEvent read FOnColumnMoved write FOnColumnMoved;
    property OnDrawCell: TDrawCellEvent read FOnDrawCell write FOnDrawCell;
    property OnRowMoved: TMovedEvent read FOnRowMoved write FOnRowMoved;
    property OnSelectCell: TSelectCellEvent read FOnSelectCell write FOnSelectCell;
    property OnSetEditText: TSetEditEvent read FOnSetEditText write FOnSetEditText;
    property OnTopLeftChanged: TNotifyEvent read FOnTopLeftChanged write FOnTopLeftChanged;
    property OnDirectoryChanged: TNotifyEvent read FOnDirectoryChanged write FOnDirectoryChanged;
    property OnFileExec: TNotifyEvent read FOnFileExec write FOnFileExec;
    property MarkRButton: Boolean read FMarkRButton write FMarkRButton;
    property DirInBrackets: Boolean read FDirInBrackets write SetDirInBrackets;
    property ListInfo: TListInfo read FListInfo;
    property OnSetMark: TNotifyEvent read FOnSetMark write FOnSetMark;
    property OnColResize: TNotifyEvent read FOnColResize write FOnColResize;
    property OnSorting: TSortEvent read FOnSorting write FOnSorting;
    property OnFilterModeChange: TNotifyEvent read FFilterModeChange write FFilterModeChange;
    property UserDefFilter: String read FUserDefFilter write FUserDefFilter;
    property FilterMode: TFilterMode read FFilterMode write SetFilterMode;
    property ShowIcons: Boolean read FShowIcons write FShowIcons;
    property Names8_3: Boolean read FNames8_3 write FNames8_3;
  end;


implementation

uses
  StrUtils, FLFunctions, FLConst,
  {$IFDEF DEBUG}Dialogs,{$ENDIF} CommonFolders, StrUtilsX;

var
  rowPressed, colPressed: Integer;
  btnPressed: TMouseButton;
  disableListInfoUpdate: Boolean = False;

{
procedure Register;
begin
  RegisterComponents('Samples', [TFLGrid]);
end;
}

function DirEnterable_(Dir: String): Boolean;
//Ця функція - доповнення до DirectoryExists і багфікс:
//повертає False, якщо шлях існує, але користувач не має прав доступу до папки (WinNT)
var fdata: TWin32FindData; h: Cardinal;
begin
  result := DirectoryExists(Dir);
  if result then
    begin
    h := FindFirstFile(PChar(Dir + '*.*'), fdata);
    result := h <> INVALID_HANDLE_VALUE;
    {$IFDEF DEBUG}
    if not result then
      LogIt('Warning: DirNotAccessable dir='+Dir);
    {$ENDIF}
    Windows.FindClose(h);
    end;
end;

constructor TFLGrid.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FNames8_3 := False;
  FShowIcons := True;
  EmptyFI := TFileItem.Create;
  FFilterMode := fmAll;
  FMaskEx := TMaskEx.Create;
  FUseMaskEx := False;
  FFileList:= TList.Create;

  LoadIcons();

  FTitleName := S_NAME;
  FTitleExt := S_EXT;
  FTitleSize := S_SIZE;
  FTitleDate := S_DATE;
  DefaultRowHeight:= ROW_HEIGHT;
  Options:= Options + [goThumbTracking, goRowSelect] - [goRangeSelect];
  FixedCols:= 0;
  GridLineWidth:= 0;
  ScrollBars:= ssVertical;
  ColCount:= DEF_COL_COUNT;
  FDirectory:= GetPersonalFolder();
  BorderStyle := bsNone;

  Options := Options + [goColSizing];
  Font.Name := FONT_FACE;
  Font.Size := FONT_SIZE;
  Font.Style := FONT_STYLE;
  //Set color attributes
  FRowColorAttr := TRowColorAttr.Create;
  with FRowColorAttr do
    begin
    Common.Backgroung := CL_BACKGROUND;
    Common.Text := CL_COMMON_TEXT;
    CommonHighlighted.Backgroung := CL_HIGHLIGHT;
    CommonHighlighted.Text := CL_HIGHLIGHTED_TEXT;
    Mark.Text := CL_MARK_TEXT;
    Mark.Backgroung := CL_MARK;
    MarkHighlighted.Backgroung := CL_MARK_HIGHL;
    MarkHighlighted.Text := CL_MARK_HIGHL_TEXT;
    end;
  SetColorAttr(FRowColorAttr); //apply new attributes
  MarkRButton := True;
  ColWidths[0] := 224;
  ColWidths[1] := 39;
  ColWidths[2] := 66;
  ColWidths[3] := 93;
  FDirInBrackets := True;
end;

destructor TFLGrid.Destroy;
begin
  MaskEx.Free;
  DestroyIcons();
  ClearFileList(FFileList);
  FFileList.Free;
  FRowColorAttr.Free;
  EmptyFI.Free;
  inherited Destroy;
end;

function TFLGrid.CellRect(ACol, ARow: Longint): TRect;
begin
  Result := inherited CellRect(ACol, ARow);
end;

procedure TFLGrid.MouseToCell(X, Y: Integer; var ACol, ARow: Longint);
var
  Coord: TGridCoord;
begin
  Coord := MouseCoord(X, Y);
  ACol := Coord.X;
  ARow := Coord.Y;
end;

procedure TFLGrid.ColumnMoved(FromIndex, ToIndex: Longint);
begin
  if Assigned(FOnColumnMoved) then FOnColumnMoved(Self, FromIndex, ToIndex);
end;

procedure TFLGrid.RowMoved(FromIndex, ToIndex: Longint);
begin
  if Assigned(FOnRowMoved) then FOnRowMoved(Self, FromIndex, ToIndex);
end;

function TFLGrid.SelectCell(ACol, ARow: Longint): Boolean;
begin
  Result := True;
  if Assigned(FOnSelectCell) then FOnSelectCell(Self, ACol, ARow, Result);
end;

procedure TFLGrid.TopLeftChanged;
begin
  inherited TopLeftChanged;
  if Assigned(FOnTopLeftChanged) then FOnTopLeftChanged(Self);
end;

function TFLGrid.IsActiveControl: Boolean;
var
  H: Hwnd;
  ParentForm: TCustomForm;
begin
  Result := False;
  ParentForm := GetParentForm(Self);
  if Assigned(ParentForm) then
  begin
    if (ParentForm.ActiveControl = Self) then
      Result := True
  end
  else
  begin
    H := GetFocus;
    while IsWindow(H) and (Result = False) do
    begin
      if H = WindowHandle then
        Result := True
      else
        H := GetParent(H);
    end;
  end;
end;

procedure TFLGrid.DirectoryChanged;
begin
  inherited;
  if Assigned(FOnDirectoryChanged) then FOnDirectoryChanged(Self);
end;

procedure TFLGrid.SetDirectory(Dir: string);
var
  List: TList;
begin
  dir := IncludeBackslash(Dir);
  if not DirEnterable_(Dir) then Exit;
  FDirectory := PathGetLongName2(dir);
  List := TList.Create;

  Screen.Cursor := crHourGlass;
  ReadDir(FDirectory, List);
  SetSortFile2(FSort, List);
  ClearFileList(FFileList);
  FFileList.Free;
  FFileList := List;
  RowCount:= List.Count + 1;
  if RowCount < 2 then
    begin
    RowCount:= 2;
    FixedRows:= 1;
    end;
  Row := 1;
  SetListInfo();
  Refresh;
  SetCurrentDir(FDirectory);
  DirectoryChanged; // event
  Screen.Cursor := crDefault;
  if Assigned(FOnTopLeftChanged) then
    FOnTopLeftChanged(Self);
end;

procedure TFLGrid.ReadDir(const Dir: String; AList: TList);
var
  H: THandle;
  b: Boolean;
  FI: TFileItem;
  _filemask: PCHar;
  _rez: TWin32FindData;
  i: Longint;

begin
  try
    FillChar(FListInfo, SizeOf(FListInfo), 0);
    _filemask:= PCHar(DIR + '*.*');
    H:= FindFirstFile(_filemask, _rez);
    ClearFileList(AList);
    AList.Count := 0;
    if H <> INVALID_HANDLE_VALUE then
      begin
      b:= true;
      while b do
        begin
        if _rez.cFileName[0] = '.' then
          begin //if DIR_UP
          if StrComp(_rez.cFileName, '..')=0 then
            begin
            FI:= TFileItem.Create;
            fi.Flags := FL_DIRUP;
            fi.Attr := High(Cardinal);
            FI.Name:= _rez.cFileName;
            FI.TimeCreation := _rez.ftCreationTime;
            i:= AList.Add(FI);
            FI.Num := i;
            end;
          end
        else  //if not DIR_UP
          begin
          FI:= TFileItem.Create;
          FI.Attr:= _rez.dwFileAttributes;
          //Ця перевірка - багфікс: якщо не перевіряти, файл це чи папка, буде швидше,
          //але на компакт-дисках папки будуть мати розмір не 0
          if (FI.Attr and faDirectory) = 0 then
            FI.Size := ConvFileSize(_rez.nFileSizeHigh, _rez.nFileSizeLow)
          else
            FI.Size:= 0;
          FI.TimeCreation := _rez.ftCreationTime;
          FI.TimeLastAccess := _rez.ftLastAccessTime;
          FI.TimeLastWrite := _rez.ftLastWriteTime;
          FI.Name:= _rez.cFileName;
          //Застосувати розширену маску (тільки для файлів), якщо вона визначена
          if FUseMaskEx and ((_rez.dwFileAttributes and faDirectory) = 0) then
            begin
            if FMaskEx.MatchMask(fi) then
              begin
              i:= AList.Add(FI);
              FI.Num := i;
              end
            else
              FI.Free;
            end
          else
            begin
            i:= AList.Add(FI);
            FI.Num := i;
            end;
          end;
        b:= FindNextFile(H, _rez);
        end;
      end;
    windows.FindClose(H);
  except
    {$IFDEF DEBUG}
    LogIt('Error: Read dir failed, dir='+dir);
    {$ENDIF}
  end;
end;

procedure TFLGrid.SetFileItem(Name: String);
var i: Longint;
begin

  i := FileList.Count-1;
  while i >= 1 do
    begin
    if LowerCase(TFileItem(FileList[i]).Name) = LowerCase(Name) then Break;
    Dec(i);
    end;
  Row := i + 1;

  if Assigned(FOnTopLeftChanged) then
    FOnTopLeftChanged(Self);

end;

procedure TFLGrid.UpFolder;
var
  t: string;
begin
  t := LastDirectory(FDirectory);
  SetDirectory(OneLevelUpDirectory(FDirectory));
  SetFileItem(t);
  Refresh;
  DirectoryChanged; // event
end;

procedure TFLGrid.KeyDown(var Key: Word; Shift: TShiftState);
//var FI: TFileItem;
var
  iFrom, iTo, i: Longint;
  mark: Boolean;
begin
  case Key of
    VK_RIGHT :
      if Assigned(OnKeyDown) then
        OnKeyDown(Self, Key, Shift);
    VK_LEFT  :
      if Assigned(OnKeyDown) then
        OnKeyDown(Self, Key, Shift);
    VK_UP, VK_DOWN:
      begin  //виділення на Shift+стрілка
      if ssShift in Shift then
        begin
        MarkInvert(Selection.Top, True);
        inherited;
        {в залежності від того, стоїть inherited до чи після виклику MarkInvert,
        змінюється мітка поточного чи наступного рядка}
        end
      else if ssCtrl in Shift then
        begin
        if (TopRow >= Row)
        and (TopRow + VisibleRowCount < RowCount) then Row := TopRow + 1
        else if(TopRow + VisibleRowCount < Row + 2)
               and(TopRow > FixedRows)then Row := TopRow + VisibleRowCount - 2;
        inherited;
        end
      else
        inherited;
      end;
    VK_END, VK_HOME, VK_PRIOR, VK_NEXT:
      if ssShift in Shift then
        begin
        iFrom := Selection.Top;
        inherited;
        iTo := Selection.Top;
        mark := not GetFIMark(iFrom - 1);
        if iTo < iFrom then
          begin
          i := iTo;
          iTo := iFrom;
          iFrom := i;
          end;
        MarkSetMark(iFrom, iTo, mark);
        if Key <> VK_PRIOR then
          begin
          if Selection.Top < RowCount-1 then
            Row := Row+1;
          end
        else
          if Selection.Top > FixedRows + 1 then
            Row := Row-1;
        Repaint;
        end
      else
        inherited;
    else
      inherited;
    end;
  if Assigned(FOnTopLeftChanged) then
    FOnTopLeftChanged(Self);
end;

procedure TFLGrid.DrawCell(ACol, ARow: Longint; ARect: TRect;
      AState: TGridDrawState);
const DY = 2;
var
  drawMode: TCellState;
  R: TRect;
  s: String;
  FI: TFileItem;
  Ico: TIcon;
begin
  R:= ARect;
  if ARow = 0 then // заголовок
    begin
    case ACol of
      0: S:= FTitleName;
      1: S:= FTitleExt;
      2: S:= FTitleSize;
      3: S:= FTitleDate;
      end;

    with Canvas do
      begin
      TextRect(ARect, ARect.Left+4, ((ARect.Bottom-ARect.Top)div 2)
        - TextHeight('I')div 2, S);

      if (ACol=0)and(FSort=smName) then
        BrushCopy(Rect(R.Right-FIconSort.Width-4, R.Top+2, R.Right-4, R.Top+2+FIconSort.Height),
          FIconSort, FIconSort.Canvas.ClipRect, clSilver)
      else
      if (ACol=0)and(FSort=smRevName) then
        BrushCopy(Rect(R.Right-FIconSort.Width-4, R.Top+2, R.Right-4, R.Top+2+FIconSort.Height),
          FIconSort2, FIconSort2.Canvas.ClipRect, clSilver)
      else
      if (ACol=1)and(FSort=smExt) then
        BrushCopy(Rect(R.Right-FIconSort.Width-4, R.Top+2, R.Right-4, R.Top+2+FIconSort.Height),
          FIconSort, FIconSort.Canvas.ClipRect, clSilver)
      else
      if (ACol=1)and(FSort=smRevExt) then
        BrushCopy(Rect(R.Right-FIconSort.Width-4, R.Top+2, R.Right-4, R.Top+2+FIconSort.Height),
          FIconSort2, FIconSort2.Canvas.ClipRect, clSilver)
      else
      if ((ACol=1)and(FSort=smExt))or((ACol=2)and(FSort=smSize))or
         ((ACol=3)and(FSort=smDate)) then
          BrushCopy(Rect(R.Right-FIconSort.Width-4, R.Top+2, R.Right-4, R.Top+2+FIconSort.Height),
          FIconSort, FIconSort.Canvas.ClipRect, clSilver)
      else
      if ((ACol=1)and(FSort=smRevExt))or((ACol=2)and(FSort=smRevSize))or
         ((ACol=3)and(FSort=smRevDate)) then
          BrushCopy(Rect(R.Right-FIconSort2.Width-4, R.Top+2, R.Right-4, R.Top+2+FIconSort2.Height),
          FIconSort2, FIconSort2.Canvas.ClipRect, clSilver);
      Exit;
      end;
    end;

  r := ARect;
  if ARow < FixedRows then
    begin
    inherited;
    Exit;
    end;
  drawMode := GetCellState(ARow, AState);
  case drawMode of
    sHighlightMark :
      begin
      Canvas.Brush.Color := FRowColorAttr.MarkHighlighted.Backgroung;
      Canvas.Font.Color := FRowColorAttr.MarkHighlighted.Text;
      end;
    sMark          :
      begin
      Canvas.Brush.Color := FRowColorAttr.Mark.Backgroung;
      Canvas.Font.Color := FRowColorAttr.Mark.Text;
      end;
    sHighlight     :
      begin
      Canvas.Brush.Color := FRowColorAttr.CommonHighlighted.Backgroung;
      Canvas.Font.Color := FRowColorAttr.CommonHighlighted.Text;
      end;
    sCommon        :
      begin
      Canvas.Brush.Color := FRowColorAttr.Common.Backgroung;
      Canvas.Font.Color := FRowColorAttr.Common.Text;
      end;
    end;
  Canvas.FillRect(arect);
  if ARow > FFileList.Count then Exit;
  FI:= FFileList[ARow-1];
  Inc(R.Top, 2);

  with Canvas do
  case ACol of
    0: begin // name
       if (fi.Flags and FL_DIROPEN) = FL_DIROPEN then
           ico := FIcDirOpen
       else if (fi.Attr and faDirectory) = faDirectory then
         begin
         if (fi.Attr and faHidden) = faHidden then
           begin
           if (fi.Flags and FL_DIRUP) = FL_DIRUP then
             ico := FIcDirUp
           else
             ico := FIcDirHid;
           end
         else
           ico := FIcDir;
         end
       else
         begin
         if (fi.Attr and faHidden) = faHidden then
           ico := FIcFileHid
         else
           ico := FIcFile
         end;
       if FShowIcons then
         begin
         Draw(R.Left + 3, R.Top - 1, ico);
         Inc(R.Left, 20);
         end
       else
         Inc(R.Left, 3);
       s := GetShortName(FI);
       DrawTextEx(Handle, PChar(s), -1, R, DT_SINGLELINE or DT_END_ELLIPSIS, nil)
       end;
    1: begin //Ext
       s := GetExt(fi);
       if (fi.Attr and faDirectory) = 0 then
         DrawTextEx(Handle, PChar(s), -1, R, DT_SINGLELINE or DT_END_ELLIPSIS, nil);
       end;
    2: begin // size
       Dec(R.Right, 2);
       if (fi.Attr and faDirectory) = faDirectory then
         begin
         if (fi.Flags and FL_DIRUP) = FL_DIRUP then
           begin
           s:= S_DIR_UP;
           DrawTextEx(Handle, PChar(s), -1, R, DT_SINGLELINE or DT_END_ELLIPSIS or DT_LEFT, nil)
           end
         else
           begin
           if fi.Size = 0 then
             begin
             s := S_FOLDER;
             DrawTextEx(Handle, PChar(s), -1, R, DT_SINGLELINE or DT_END_ELLIPSIS or DT_LEFT, nil)
             end
           else
             begin
             R.Left := 0;
             s := SizeToStr(FI.Size);
             DrawTextEx(Handle, PChar(s), -1, R, DT_SINGLELINE or DT_END_ELLIPSIS or DT_RIGHT, nil)
             end
           end;
         end
       else
         begin
         R.Left := 0;
         s:= SizeToStr(FI.Size);
         DrawTextEx(Handle, PChar(s), -1, R, DT_SINGLELINE or DT_END_ELLIPSIS or DT_RIGHT, nil);
         end;
       end;
    3: begin // date
         Dec(R.Right, 2);
         if (FI.Attr and faDirectory) = 0 then
           s:= FormatDateTime('dd.mm.yy hh:nn', FileTimeToDateTime(FI.TimeLastWrite))
         else
           s:= FormatDateTime('dd.mm.yy hh:nn', FileTimeToDateTime(FI.TimeCreation));
         DrawTextEx(Handle, PChar(s), -1, R, DT_SINGLELINE or DT_END_ELLIPSIS or DT_RIGHT, nil);
       end;
    end;
  DrawTextEx(Handle, PChar(FI.Name), -1, R, DT_SINGLELINE or DT_END_ELLIPSIS, nil);


  if Assigned(FOnDrawCell) then FOnDrawCell(Self, ACol, ARow, ARect, AState);
end;

{procedure TFLGrid.DblClick;
var NewPos: TPoint;
begin
  Windows.GetCursorPos(NewPos);  NewPos:= ScreenToClient(NewPos);
  if (NewPos.y > 0)and(NewPos.y < DefaultRowHeight) then Exit;
  inherited;
  GoIntoDir;
end; }

function TFLGrid.GetVariantValue(i: Longint; sm: TSortFile; List: TList): variant;
var fi: TFileItem;
begin
  fi:= List[i];
  case sm of
    smNone:           Result:= fi.Num;
    smFolder:         if (fi.Flags and FL_DIRUP) = FL_DIRUP then
                        result := 0
                      else
                        Result:= not (fi.Attr and faDirectory);
    smName,smRevName: Result:= AnsiLowerCase(fi.Name);
    smDate,smRevDate: Result:= FileTimeToDateTime(fi.TimeCreation);
    smExt, smRevExt:  if (fi.Attr and faDirectory) = 0 then
                        Result:= AnsiLowerCase(ExtractFileExt(fi.Name))
                      else
                        result := '';
    smSize,smRevSize: Result:= fi.Size;
  end;
end;

// --------------------- Common Sort по возрастанию ---------
procedure TFLGrid.CommonSort1(iLo, iHi: longInt; sm: TSortFile; List: TList);
var Lo, Hi: Longint; TFI: TFileItem; Mid: Variant;
begin
  Lo := iLo;
  Hi := iHi;
  Mid := GetVariantValue((Lo + Hi) div 2, sm, List);
  repeat
    while GetVariantValue(Lo, sm, List) < Mid do Inc(Lo);
    while GetVariantValue(Hi, sm, List) > Mid do Dec(Hi);
    if Lo <= Hi then
    begin
      TFI:= List[Lo];
      List[Lo]:= List[Hi];
      List[Hi]:= TFI;
      Inc(Lo);
      Dec(Hi);
    end;
  until Lo > Hi;
  if Hi > iLo then CommonSort1(iLo, Hi, sm, List);
  if Lo < iHi then CommonSort1(Lo, iHi, sm, List);
end;

// --------------------------- Common Sort по убыванию -----------
procedure TFLGrid.CommonSort2(iLo, iHi: longInt; sm: TSortFile; List: TList);
var Lo, Hi: Longint; TFI: TFileItem; Mid: Variant;
begin
  Lo := iLo;
  Hi := iHi;
  Mid := GetVariantValue((Lo + Hi) div 2, sm, List);
  repeat
    while GetVariantValue(Lo, sm, List) > Mid do Inc(Lo);
    while GetVariantValue(Hi, sm, List) < Mid do Dec(Hi);
    if Lo <= Hi then
    begin
      TFI:= List[Lo];
      List[Lo]:= List[Hi];
      List[Hi]:= TFI;
      Inc(Lo);
      Dec(Hi);
    end;
  until Lo > Hi;
  if Hi > iLo then CommonSort2(iLo, Hi, sm, List);
  if Lo < iHi then CommonSort2(Lo, iHi, sm, List);
end;
// -----------------------------------------------------------

procedure TFLGrid.SecondSort(Master, sm: TSortFile; List: TList);
var b, i: Longint; TF, First: Variant;
begin
  b:= 0; First:= GetVariantValue(0, Master, List);
  TF:= GetVariantValue(0, smFolder, List);
  for i:= 0 to List.Count-1 do
  begin
    if (TF    <> GetVariantValue(i, smFolder, List))or
       (First <> GetVariantValue(i, Master, List)) then
    begin
      case sm of
        smName,smDate,smExt,smSize:
          CommonSort1(b, i-1, sm, List);
        smRevName,smRevDate,smRevExt,smRevSize:
          CommonSort2(b, i-1, sm, List);
      end;
      b:= i; First:= GetVariantValue(i, Master, List);
      TF:= GetVariantValue(i, smFolder, List);
    end;
  end;
      case sm of
        smName,smDate,smExt,smSize:
          CommonSort1(b, List.Count-1, sm, List);
        smRevName,smRevDate,smRevExt,smRevSize:
          CommonSort2(b, List.Count-1, sm, List);
      end;
end;

procedure TFLGrid.Sorting(sm: TSortFile; List: TList);
begin
  if sm = smNone then
    CommonSort1(0, List.Count-1, sm, List)
  else begin
    CommonSort1(0, List.Count-1, smFolder, List); // папки в начало
    SecondSort(smFolder, sm, List);
    case sm of
      smName:              SecondSort(sm, smExt, List);
      smSize,smExt,smDate: SecondSort(sm, smName, List);
      smRevName:           SecondSort(sm, smRevExt, List);
      smRevSize,smRevExt,
      smRevDate:           SecondSort(sm, smRevName, List);
    end;
  end;
  FSort := sm;
end;

procedure TFLGrid.SetSortFile(sm: TSortFile);
var t: string;
begin
  if FFileList.Count <= 0 then
    begin
    FSort := sm;
    Refresh;
    if Assigned(FOnSorting) then
      FOnSorting(Self, sm);
    Exit;
    end;
  t:= TFileItem(FileList[Row-1]).Name;
  Sorting(sm, FFileList);
  SetFileItem(t);
  if Assigned(FOnSorting) then
    FOnSorting(Self, sm);
  Refresh;
end;

procedure TFLGrid.DeleteRow(ARow: Longint);
begin
  inherited;
end;

procedure TFLGrid.MouseUp(Button: TMouseButton; Shift: TShiftState;
    X, Y: Integer);
var
  Head: Boolean;
  ARow, AColumn, i, w: Integer;
  //потрібна перевірка чи не змінюють мишкою розмір колонки
begin
  inherited;
  if RowCount < 2 then Exit;
  if Button = mbLeft then
    begin
    MouseToCell(x, y, AColumn, ARow);
    Head:= ARow=0;
    if Head then // if MouseUp on the Header
      begin
      w := 0;
      for i := 0 to AColumn do
        begin
        Inc(w, ColWidths[i]);
        if Abs(w-x)<6 then
          Exit;
        end;
      case AColumn of
        0: if FSort<>smName then SortFile:= smName else SortFile:= smRevName;
        1: if FSort<>smExt then SortFile:= smExt else SortFile:= smRevExt;
        2: if FSort<>smSize then SortFile:= smSize else SortFile:= smRevSize;
        3: if FSort<>smDate then SortFile:= smDate else SortFile:= smRevDate;
        end;
      end;
    end;

  rowPressed := -1;
  colPressed := -1;
end;

procedure TFLGrid.SetTitleName(Name: String);
var r: TRect;
begin
  FTitleName:= Name;
  r:= Rect(0, 0, Width, DefaultRowHeight);
  RedrawWindow(Handle, @r, 0, RDW_INVALIDATE);
end;

procedure TFLGrid.SetTitleSize(Size: String);
var r: TRect;
begin
  FTitleSize:= Size;
  r:= Rect(0, 0, Width, DefaultRowHeight);
  RedrawWindow(Handle, @r, 0, RDW_INVALIDATE);
end;

procedure TFLGrid.SetTitleDate(Date: String);
var r: TRect;
begin
  FTitleDate:= Date;
  r:= Rect(0, 0, Width, DefaultRowHeight);
  RedrawWindow(Handle, @r, 0, RDW_INVALIDATE);
end;

procedure TFLGrid.SetTitleExt(Ext: String);
var r: TRect;
begin
  FTitleExt:= Ext;
  r := Rect(0, 0, Width, DefaultRowHeight);
  RedrawWindow(Handle, @r, 0, RDW_INVALIDATE);
end;

function TFLGrid.DoMouseWheelDown(Shift: TShiftState;
  MousePos: TPoint): Boolean;
begin
  SendMessage(Handle, WM_VSCROLL, SB_LINEDOWN, 0);
  result := False;
end;

function TFLGrid.DoMouseWheelUp(Shift: TShiftState;
  MousePos: TPoint): Boolean;
begin
  SendMessage(Handle, WM_VSCROLL, SB_LINEUP, 0);
  result := False;
end;

procedure TFLGrid.SetColorAttr(const Value: TRowColorAttr);
begin
  FRowColorAttr := Value;
  Color := Value.Common.Backgroung;
  if Visible then  Repaint;
end;

function TFLGrid.GetCellState(ARow: Integer;
  AState: TGridDrawState): TCellState;
var
  mark: Boolean;
begin
  mark := GetFIMark(ARow-1);
  if (gdSelected in AState)and mark then
    result := sHighlightMark
  else if (gdSelected in AState) then
    result := sHighlight
  else if mark then
    result := sMark
  else
    result := sCommon;
  if (not Focused)
    and (result = sHighlight) then
    result := sCommon
  else if (not Focused)
    and (result = sHighlightMark) then
    result := sMark;

end;

procedure TFLGrid.MarkAll(Marked, OnlyFiles: Boolean);
//встановлює помітку для всіх рядків
var i: Integer;
begin
  if OnlyFiles then   //тільки для файлів
    for i := 0 to FFileList.Count - 1 do
      begin
      if IsRowFile(i+1) then
        SetFIMark(i, Marked);
      end
  else                //для всіх рядків
    for i := 0 to FFileList.Count - 1 do
      SetFIMark(i, Marked);
  SetListInfo();
end;

procedure TFLGrid.MarkInvert(ARow: Integer; RepaintRow: Boolean);
//змінює помітку на протилежну
var mark: Boolean;
begin
  if FFileList.Count = 0 then Exit;
  mark := GetFIMark(ARow-1);
  SetFIMark(ARow-1, not mark);
  if RepaintRow then
    //перемалювати заново помічену область
    InvalidateRow(ARow);
  SetListInfo();
end;

procedure TFLGrid.MarkInvertAll(OnlyFiles: Boolean);
var i: Integer;
begin
  disableListInfoUpdate := True;
  if OnlyFiles then   //тільки для файлів
    for i := 0 to FFileList.Count-1 do
      begin
      if IsRowFile(i+1) then
        MarkInvert(i+1, False);
      end
  else                //для всіх рядків
    for i := 0 to FFileList.Count-1 do
      MarkInvert(i+1, False);
  disableListInfoUpdate := False;    
  SetListInfo();
end;

procedure TFLGrid.MarkSetMark(ARowFrom, ARowTo: Integer;
  Marked: Boolean);
var i: Integer;
begin
  if FFileList.Count = 0 then Exit;
  for i := ARowFrom to ARowTo do
    SetFIMark(i-1, Marked);
  SetListInfo();
end;

procedure TFLGrid.MarkSetMark(ARow: Integer; Marked,
  RepaintRow: Boolean);
//встановлює помітку для вказаного рядка
begin
  if FFileList.Count = 0 then Exit;

  SetFIMark(ARow-1, marked);

  if RepaintRow then
    //перемалювати заново помічену область
    InvalidateRow(ARow);
  SetListInfo();
end;

function TFLGrid.IsRowFile(ARow: Integer): Boolean;
var fi: TFileItem;
begin
  fi := FFileList[ARow-1];
  result := (fi.Attr and faDirectory) = 0;
end;

procedure TFLGrid.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
var
  Column, Row: Integer;
  lParam: Cardinal;
begin
  inherited;

  if Assigned(FOnTopLeftChanged) then
    FOnTopLeftChanged(Self);

  MouseToCell(x, y, Column, Row);
  rowPressed := Row;
  if rowPressed = -1 then Exit;
  colPressed := Column;
  btnPressed := Button;
  //Якщо кнопка права
  //і можна робити помітки правою кнопкою
  if (Button = mbRight) and MarkRButton then
    begin
    //змінити мітку рядка
    MarkInvert(Row, True);
    //якщо мітку було поставлено
    if GetFIMark(row-1) then
      begin
      //підсвітити рядок з міткою
      lParam := (Row-TopRow+1) * DefaultRowHeight;
      lParam := (lParam + 2)shl(SizeOf(word)*8)+2;
      SendMessage(Handle, WM_LBUTTONDOWN, 0, lParam);
      SendMessage(Handle, WM_LBUTTONUP, 0, lParam);
      end;
    end;
end;

procedure TFLGrid.LoadIcons();
begin
  FIcFile := TIcon.Create;
  FIcFile.Handle := LoadImage(hInstance, 'FILE', IMAGE_ICON, 16, 16, 0);
  FIcFileHid := TIcon.Create;
  FIcFileHid.Handle := LoadImage(hInstance, 'FILEHIDDEN', IMAGE_ICON, 16, 16, 0);
  FIcDir := TIcon.Create;
  FIcDir.Handle := LoadImage(hInstance, 'DIR', IMAGE_ICON, 16, 16, 0);
  FIcDirHid := TIcon.Create;
  FIcDirHid.Handle := LoadImage(hInstance, 'DIRHIDDEN', IMAGE_ICON, 16, 16, 0);
  FIcDirUp := TIcon.Create;
  FIcDirUp.Handle := LoadImage(hInstance, 'DIRUP', IMAGE_ICON, 16, 16, 0);
  FIcDirOpen := TIcon.Create;
  FIcDirOpen.Handle := LoadImage(hInstance, 'DIROPEN', IMAGE_ICON, 16, 16, 0);

  FIconSort:= TBitMap.Create; FIconSort2:= TBitMap.Create;
  FIconSort.LoadFromResourceName(hInstance, 'SORT');
  FIconSort2.LoadFromResourceName(hInstance, 'SORT2');
end;

function TFLGrid.GetExt(AFile: TFileItem): String;
begin
  if FNames8_3 then
    result := ExtractFileExt(ExtractShortPathName(Directory + AFile.Name))
  else
    result := ExtractFileExt(AFile.Name);
  result := StrUtils.RightStr(result, Length(result)-1);
  result := ReplaceStr(result, '&', '&&');
end;

function TFLGrid.GetShortName(AFile: TFileItem): String;
var
  ext, fname: String;
begin
  if FNames8_3 then
    fname := ExtractFileName(ExtractShortPathName(Directory + AFile.Name))
  else
    fname := AFile.Name;
    
  if (AFile.Attr and faDirectory) = 0 then
    begin
    result := fname;
    ext := ExtractFileExt(fname);
    result := StrUtils.LeftStr(result, Length(result) - Length(ext));
    end
  else
    if FDirInBrackets then
      result := '[' + fname + ']'
    else
      result := fname;
  result := ReplaceStr(result, '&', '&&');
end;

procedure TFLGrid.SetDirInBrackets(const Value: Boolean);
begin
  FDirInBrackets := Value;
  Repaint;
end;

procedure TFLGrid.SetListInfo;
//встановлює інформацію про кількісь і об'єм
//виділених файлів
var
  i: Integer;
  fi: TFileItem;
begin
  if disableListInfoUpdate then Exit;
  FillChar(FListInfo, SizeOf(FListInfo), 0);
  with FListInfo do
  for i := 0 to FFileList.Count - 1 do
    begin
    fi := FFileList[i];
    if ((fi.Attr and faDirectory) = 0)then
      begin
      if GetFIMark(i) then
        begin
        Inc(SelCount);
        Inc(SelSize, fi.Size);
        end;
      Inc(Count);
      Inc(Size, fi.Size);
      end
    else
      if GetFIMark(i) then
        begin
        Inc(SelSize, fi.Size);
        Inc(SelCountWithDirs, 1);
        end;
    end;
  Inc(FListInfo.SelCountWithDirs, FListInfo.SelCount);
  if Assigned(FOnSetMark) then
    FOnSetMark(Self);
end;

function TFLGrid.GetFIMark(Index: Integer): Boolean;
var fi: TFileItem;
begin
  if FFileList.Count = 0 then
    begin
    result := False;
    Exit;
    end;
  if FFileList.Count > index then
    begin
    fi := FFileList[index];
    result := (fi.Flags and FL_MARK) = FL_MARK;
    end
  else
    result := False;
end;

procedure TFLGrid.SetFIMark(Index: Integer; Value: Boolean);
var fi: TFileItem;
begin
  if FFileList.Count = 0 then Exit;
  fi := FFileList[index];
  if value then
    fi.Flags := fi.Flags or FL_MARK
  else
    fi.Flags := fi.Flags and (not FL_MARK);
end;

function TFLGrid.GetHighlightedFile: TFileItem;
begin
  if FFileList.Count = 0 then
    result := EmptyFI
  else
    result := FFileList[Self.Row-1];
end;

procedure TFLGrid.ColWidthsChanged;
begin
  inherited;
  if Assigned(FOnColResize) then
    FOnColResize(Self);
end;

procedure TFLGrid.ClearFileList(var AList: TList);
//очищує список файлів
//список не знищується, вкладені списки - очищуються і знищуються
var
//  i:longint;
  fi: TFileItem;
begin
{  if AList = nil then Exit;
  for i := 0 to AList.Count-1 do
    begin
    fi := AList[i];
    if fi.SubItems <> nil then
      begin
      ClearFileList(fi.SubItems);
      fi.SubItems.Free;
      end;
    fi.Free;
    end;  }

  if AList = nil then Exit;
  while AList.Count> 0 do
    begin
    fi := AList[0];
    if fi.SubItems <> nil then
      begin
      ClearFileList(fi.SubItems);
      fi.SubItems.Free;
      end;
    fi.Free;
    AList.Delete(0);
    end;

  AList.Clear;
end;

procedure TFLGrid.MarkSetMarkEx(ARow: Integer;
  RepaintRow: Boolean; AFileList: TList);
//змінює помітку на протилежну
//Якщо мітку потрібно поставити на папку,
//проводиться рекурсивний пошук в цій папці
//і встановлюється її розмір як сума розмірів
//усіх вміщуваних файлів.
//У змінній AFileList формується дерево файлів і папок

  procedure SearchInto(var fi: TFileItem; const PATH: String;
    Lst: TList);
  //рекурсивна процедура пошуку
  var
    i: Integer;
    fi_: TFileItem;
  begin
    ReadDir(path, fi.SubItems);
    for i := 0 to fi.SubItems.Count-1 do
      begin
      fi_ := fi.SubItems[i];
      if ((fi_.Attr and faDirectory) = faDirectory)
        and ((fi_.Flags and FL_DIRUP) = 0) then
        begin
        fi_.SubItems := TList.Create;
        SearchInto(fi_, PATH+fi_.Name+'\', lst);
        end;
      Inc(fi.Size, fi_.Size);
      end;
  end;

var
  fi: TFileItem;
  path: String;
begin
  if FFileList.Count = 0 then Exit;
  fi := FFileList[ARow - 1];
  if ((fi.Attr and faDirectory) = faDirectory)
    and ((fi.Flags and FL_DIRUP) = 0)
    and ((fi.Flags and FL_MARK) = 0) then
    begin
    path := IncludeBackslash(Directory + fi.Name);
    if fi.SubItems = nil then
      fi.SubItems := TList.Create
    else
      ClearFileList(fi.SubItems);
    fi.Size := 0;
    SearchInto(fi, path, AFileList);
    if AFileList <> nil then
      AFileList.Add(fi);
    end
  else if ((fi.Attr and faDirectory) = 0)
    and ((fi.Flags and FL_MARK) = 0) then
    if AFileList <> nil then
      AFileList.Add(fi);
  MarkSetMark(ARow, True, RepaintRow);
  SetListInfo();
end;

procedure TFLGrid.GetTree(AFileList: TList);
//Дістати дерево виділених файлів і папок
//Перед викликом треба створити змінну AFileList
var
  i: Longint;
  fi: TFileItem;
begin
  disableListInfoUpdate := True;
  if FFileList.Count = 0 then Exit;

  for i := 0 to FFileList.Count-1 do
    begin
    fi := FFileList[i];
    if ((fi.Flags and FL_MARK) = FL_MARK)
      and ((fi.Flags and FL_DIRUP) = 0) then
      begin
      MarkSetMark(i+1, False, False);
      MarkSetMarkEx(i+1, True, AFileList);
      end;
    end;
  disableListInfoUpdate := False;
end;

procedure TFLGrid.MarkInvertEx(ARow: Integer; RepaintRow: Boolean);
var
  fi: TFileItem;
  b: Boolean;
begin
  if FFileList.Count = 0 then Exit;
  fi := FFileList[ARow-1];
  if ((fi.Flags and FL_MARK) = FL_MARK) then
    MarkSetMark(ARow, False, RepaintRow)
  else
    begin
    b := UseMaskEx;
    UseMaskEx := False;
    disableListInfoUpdate := True;
    MarkSetMarkEx(ARow, RepaintRow, nil);
    disableListInfoUpdate := False;
    UseMaskEx := b;
    SetListInfo();
    end;
end;

procedure TFLGrid.DestroyIcons;
begin
  FIcFile.Free;
  FIcFileHid.Free;
  FIcDir.Free;
  FIcDirHid.Free;
  FIcDirUp.Free;
  FIcDirOpen.Free;
  
  FIconSort.Free;
  FIconSort2.Free;
end;

procedure TFLGrid.TreeOperate(AFileList: TList; FileProc: TFileProc;
  ExtData: Pointer);
//Обхід дерева файлів і папок
//Перед викликом потрібно:
//  1) створити дерево
//  2) сформувати дерево (GetTree(...))
//Дерево рекурсивно обходиться, для кожного елемента
//викликається процедура FileProc, задана при виклику
//FileProc може бути, наприклад, процедурою копіювання файлу
//ExtData - довільна структура, що передається в FileProc

  procedure TreeOperate_(lst: TList; Proc: TFileProc;
    eData: Pointer; const pref: String);
  var
    fi: TFileItem;
    i: Integer;
    pi: TProgressInfo;
  begin
    if lst = nil then Exit;
    for i := 0 to lst.Count-1 do
      begin
      fi := lst[i];
      if fi.Name[1] = '.' then
        Continue;
      fi.Name := pref+fi.Name;
      if Proc(fi, pi, eData) <> 0 then Exit;
      if fi.SubItems <> nil then
        TreeOperate_(fi.SubItems, Proc, eData, fi.Name+'\');
      end;
  end;

begin
  TreeOperate_(AFileList, FileProc, ExtData, '');
end;

procedure TFLGrid.TreeOperate(AFileList: TList; FileProc: TFileProc);
begin
  TreeOperate(AFileList, FileProc, nil);
end;

procedure TFLGrid.MarkAllDirs(Marked: Boolean);
//встановлює помітку для всіх рядків - папок
var i: Integer;
begin
  if FFileList.Count = 0 then Exit;
  for i := 1 to RowCount - 1 do
    begin
    if not IsRowFile(i) then
      SetFIMark(i-1, Marked);
    end;
  SetListInfo();
end;

function TFLGrid.RereadSrc: Boolean;
var
  List: TList;
  dir: String;

begin
  result := DirectoryExists(Directory);
  dir := IncludeBackslash(Directory);
  if not result then
    begin
    result := DirectoryExists(IncludeBackslash(ExtractFileDrive(Directory)));
    if result then Dir := IncludeBackslash(ExtractFileDrive(Directory));
    end;
  if not result then Exit;
  FDirectory := dir;
  List := TList.Create;

  Screen.Cursor := crHourGlass;
  ReadDir(FDirectory, List);
  RowCount:= List.Count + 1;
  if RowCount < 2 then
    begin
    RowCount:= 2;
    FixedRows:= 1;
    end;
  SetSortFile2(FSort, List);
  ClearFileList(FFileList);
  FFileList.Free;
  FFileList := List;
  SetListInfo();
  Refresh;
  DirectoryChanged; // event
  Screen.Cursor := crDefault;

  if Assigned(FOnTopLeftChanged) then
    FOnTopLeftChanged(Self);

end;

procedure TFLGrid.SetFilterMode(const Value: TFilterMode);
begin
  FFilterMode := Value;
  FMaskEx.Init;
  case Value of
    fmAll: FUseMaskEx := False;
    fmExecs:
      begin
      FUseMaskEx := True;
      FMaskEx.FileMask := EXE_MASK;
      end;
    fmUserSpec:
      begin
      FUseMaskEx := True;
      FMaskEx.FileMask := FUserDefFilter;
      end;
    end;

  Self.RereadSrc;
  if Assigned(FFilterModeChange) then
    FFilterModeChange(Self);
end;

procedure TFLGrid.MarkByMask(Marked: Boolean; Mask: TMaskEx);
//встановлює помітку для файлів, що відповідають масці
var
  i: Integer;
  fi: TFileItem;
begin
  if FFileList.Count = 0 then Exit;
  for i := 1 to RowCount - 1 do
    begin
    fi := TFileItem(FFileList[i-1]);
    if ((fi.Attr and faDirectory)=0) and mask.MatchMask(fi) then
      SetFIMark(i-1, Marked);
    end;
  SetListInfo();
end;

procedure TFLGrid.GoIntoDir;
var
  FI: TFileItem;
  r: TRect;
  cDir: String;
begin
  if FFileList.Count = 0 then Exit;
  FI:= FFileList[Row-1];


  if (fi.Flags and FL_DIRUP) = FL_DIRUP then
    UpFolder
  else if (fi.Attr and faDirectory) = faDirectory then
    begin
    fi.Flags := fi.Flags or FL_DIROPEN;
    r := CellRect(0, Row);
    r.Right := r.Left + 16 + 3;
    Dec(r.Bottom);
    DrawCell(0, Row, r, [gdSelected , gdFocused]);
    cDir := IncludeBackslash(Directory + FI.Name);
    Directory := cDir;
    //Якщо з якихось причин папка не відкрилася
    if Directory <> cDir then
      begin
      fi.Flags := fi.Flags and (not FL_DIROPEN);
      DrawCell(0, Row, r, [gdSelected , gdFocused]);
      end;
    end
  else
    if Assigned(FOnFileExec) then  OnFileExec(Self);

end;

procedure TFLGrid.TreeOperate2(AFileList: TList; FileProc: TFileProc;
  ExtData: Pointer);
//Якщо TreeOperate потрібно викликати декілька разів, вперше викликається
// TreeOperate, наступні рази - TreeOperate2

var abort: Boolean;

  procedure TreeOperate_(lst: TList; Proc: TFileProc;
    eData: Pointer);
  var
    fi: TFileItem;
    i: Integer;
    pi: TProgressInfo;
  begin
    if lst = nil then Exit;
    for i := 0 to lst.Count-1 do
      begin
      fi := lst[i];
      if fi.Name[1] = '.' then
        Continue;
      if abort then Exit;  
      abort := Proc(fi, pi, eData) <> 0;
      if fi.SubItems <> nil then
        TreeOperate_(fi.SubItems, Proc, eData);
      if ((fi.Flags and FL_MARK) = FL_MARK)then
        begin
        fi.Flags := fi.Flags and (not FL_MARK);
        {if fi.Size > 100000 then
          Repaint;
        self.InvalidateRow(fi.Num-1);}
        end;
      end;
  end;

begin
  abort := False;
  TreeOperate_(AFileList, FileProc, ExtData);
  SetListInfo;
  Repaint;
end;

procedure TFLGrid.TreeOperateInv(AFileList: TList; FileProc: TFileProc;
  ExtData: Pointer);
  procedure TreeOperate_(lst: TList; Proc: TFileProc;
    eData: Pointer; const pref: String);
  var
    fi: TFileItem;
    i: Integer;
    pi: TProgressInfo;
  begin
    if lst = nil then Exit;
    for i := 0 to lst.Count-1 do
      begin
      fi := lst[i];
      if fi.Name[1] = '.' then
        Continue;
      fi.Name := pref+fi.Name;
      if fi.SubItems <> nil then
        TreeOperate_(fi.SubItems, Proc, eData, fi.Name+'\');
      if Proc(fi, pi, eData) <> 0 then Exit;
      end;
  end;

begin
  TreeOperate_(AFileList, FileProc, ExtData, '');
end;

procedure TFLGrid.TreeOperate2Inv(AFileList: TList; FileProc: TFileProc;
  ExtData: Pointer);
//Теж саме, що і TreeOperate2, але рекурсія у зворотньому порядку:
//від найглибших елементів до зовнішнього. Використовується для
//знищення дерева порожніх папок
var abort: Boolean;

  procedure TreeOperate_(lst: TList; Proc: TFileProc;
    eData: Pointer);
  var
    fi: TFileItem;
    i: Integer;
    pi: TProgressInfo;
  begin
    if lst = nil then Exit;
    for i := 0 to lst.Count-1 do
      begin
      fi := lst[i];
      if fi.Name[1] = '.' then
        Continue;
      if abort then Exit;
      if fi.SubItems <> nil then
        TreeOperate_(fi.SubItems, Proc, eData);
      if ((fi.Flags and FL_MARK) = FL_MARK)then
        begin
        fi.Flags := fi.Flags and (not FL_MARK);
        {if fi.Size > 100000 then
          Repaint;}
        self.InvalidateRow(fi.Num-1);
        end;
      abort := Proc(fi, pi, eData) <> 0;
      end;
  end;

begin
  abort := False;
  TreeOperate_(AFileList, FileProc, ExtData);
  SetListInfo;
  Repaint;
end;

procedure TFLGrid.MarkNoExtFiles(Marked: Boolean);
//Встановлює помітку для всіх файлів без розширення.
//Процедура MarkByMask(), якщо задати їй пошук за порожньою маскою,
//замість них знаходить всі файли - це потрібно для пошуку файлів (Ctrl+F)
var i: Integer; fi: TFileItem;
begin
  for i := 0 to FFileList.Count - 1 do
    if IsRowFile(i+1)then
      begin
      fi := FFileList[i];
      if(ExtractFileExt(fi.Name)='')then
        SetFIMark(i, Marked);
      end;
  SetListInfo();
end;

function TFLGrid.GetFirstMarkedFile: TFileItem;
var i: Integer;
begin
  result := nil;
  if FFileList.Count = 0 then
    result := EmptyFI
  else
    for i := 0 to FFileList.Count - 1 do
      if GetFIMark(i) then result := FFileList[i];

  if result = nil then
    result := EmptyFI;
end;

procedure TFLGrid.HideUnmarked(OnlyFiles: Boolean);
//Ховає непозначені файли
//Якщо OnlyFiles = True, то непозначені каталоги ховаються теж
var i: Integer; fi: TFileItem;
begin
  i := 0;
  while i <= FFileList.Count - 1 do
    begin
    if not GetFIMark(i) then
      begin
      fi := FFileList[i];
      if (((fi.Attr and faDirectory) = faDirectory)
        and OnlyFiles and ((fi.Flags and FL_DIRUP) = 0))
        or((fi.Attr and faDirectory) = 0) then
        begin
        if fi.SubItems <> nil then
          ClearFileList(fi.SubItems);
        fi.Free;
        FFileList.Delete(i);
        Dec(i);
        end;
      end;
    Inc(i);
    end;
  if FFileList.Count > 0 then
    RowCount := FFileList.Count + FixedRows
  else
    RowCount := FixedRows + 1;
  SetListInfo();
  Repaint;
end;

procedure TFLGrid.MarkAllDirsEx();
var i: Integer;
begin
  if FFileList.Count = 0 then Exit;
  MarkAllDirs(False);
  for i := 1 to RowCount - 1 do
    begin
    if not IsRowFile(i) then
      MarkSetMarkEx(i, True, nil);
    end;
  SetListInfo();
end;

procedure TFLGrid.HideAllDirs;
//Ховає всі директорії
var i: Integer; fi: TFileItem;
begin
  i := 0;
  while i <= FFileList.Count - 1 do
    begin
    fi := FFileList[i];
    if (((fi.Attr and faDirectory) = faDirectory)
      and ((fi.Flags and FL_DIRUP) = 0)) then
      begin
      if fi.SubItems <> nil then
        ClearFileList(fi.SubItems);
      fi.Free;
      FFileList.Delete(i);
      Dec(i);
      end;
    Inc(i);
    end;
  RowCount := FFileList.Count + FixedRows;
  SetListInfo();
  Repaint;
end;

function TFLGrid.GotoFile(FileName: String): Boolean;
//Перейти до підпапки, в якій знаходиться FileName і перемістити курсор
//на рядок, що відповідає FileName.
//FileName може бути файлом або папкою. Для уникнення неоднозначності,
//якщо FileName - папка, то її ім'я повинно містити "\" в кінці
var
  i: Integer;
  fi: TFileItem;
  fn: String;
begin

  result := FileExists(FileName) or DirectoryExists(FileName);
  fn := LowerCase(FileName);

  if FileExists(fn) then
    begin
    if LowerCase(Directory) <> ExtractFileDir(fn) then
      Directory := ExtractFileDir(FileName);
    for i := 0 to FFileList.Count - 1 do
      begin
      fi := FFileList[i];
      if LowerCase(fi.Name) = ExtractFileName(fn)then
        begin
        Row := i+1;
        Break;
        end;
      end;
    end
  else if DirectoryExists(fn) then
    begin
    if LowerCase(Directory) <> OneLevelUpDirectory(fn) then
      Directory := OneLevelUpDirectory(FileName);
    for i := 0 to FFileList.Count - 1 do
      begin
      fi := FFileList[i];
      if LowerCase(fi.Name) = ExtractFileName(fn)then
        begin
        Row := i+1;
        Break;
        end;
      end;
    end;

  if Assigned(FOnTopLeftChanged) then
    FOnTopLeftChanged(Self);

end;

procedure TFLGrid.SetSortFile2(sm: TSortFile; List: TList);
//Це overload-версія SetSortFile, але зроблена у вигляді окремої процедури
begin
  if List.Count <= 0 then Exit;
  Sorting(sm, List);
  if Assigned(FOnSorting) then
    FOnSorting(Self, sm);
end;

function TFLGrid.RereadSoft: Boolean;
var
  List: TList;
  equal: Boolean;
  i: Integer;
  fi1, fi2: TFileItem;

begin
  result := DirectoryExists(Directory);
  if not result then
    begin
    result := DirectoryExists(IncludeBackslash(ExtractFileDrive(Directory)));
    if result then Directory := IncludeBackslash(ExtractFileDrive(Directory));
    Exit;
    end;
  if not result then Exit;

  Screen.Cursor := crHourGlass;
  List := TList.Create;
  ReadDir(FDirectory, List);
  equal := List.Count = FFileList.Count;
  SetSortFile2(FSort, List);

  if not equal then
    begin
    RowCount:= List.Count + 1;
    if RowCount < 2 then begin RowCount:= 2; FixedRows:= 1; end;
    ClearFileList(FFileList);
    FFileList.Free;
    FFileList := List;
    SetListInfo();
    Refresh;
    DirectoryChanged; // event
    Screen.Cursor := crDefault;
    Exit;
    end;

  for i := 0 to List.Count - 1 do
    begin
    fi1 := List[i];
    fi2 := FFileList[i];
    if fi1.Name <> fi2.Name then
      begin
      equal := False;
      Break;
      end;
    end;

  if not equal then
    begin
    RowCount:= List.Count + 1;
    if RowCount < 2 then begin RowCount:= 2; FixedRows:= 1; end;
    ClearFileList(FFileList);
    FFileList.Free;
    FFileList := List;
    SetListInfo();
    Refresh;
    DirectoryChanged; // event
    end;

  if equal then List.Free;
  Screen.Cursor := crDefault;
  if Assigned(FOnTopLeftChanged) then
    FOnTopLeftChanged(Self);

end;

end.