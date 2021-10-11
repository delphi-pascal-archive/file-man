unit FS;
{$I 'defs.pas'}

{************************** FILE SYSTEM **************************************}

interface

uses Windows, FLTypes;

function FsMkDir_(RemoteDir:pchar): bool; stdcall;
function FsRemoveDir_(RemoteName:pchar):bool; stdcall;
function FsDeleteFile_(RemoteName:pchar):bool; stdcall;
function FsRenMovFile_(OldName,NewName:pchar;Move,OverWrite:bool;RemoteInfo:pRemoteInfo):integer; stdcall;

var
  nBufSize: Int64 = 1024*32;

implementation

uses FLPerform, SysUtils, Dim, Forms, fsplugin, Classes, FLFunctions, Dialogs;

{**************************** FS **********************************************}

function FsMkDir_(RemoteDir:pchar): bool; stdcall;
begin
  result := CreateDirectory(RemoteDir, nil);
end;

function FsRemoveDir_(RemoteName:pchar):bool; stdcall;
begin
  result := RemoveDirectory(RemoteName);
end;

function FsDeleteFile_(RemoteName:pchar):bool; stdcall;
begin
  ProgressProc(0, RemoteName, '', 0);
  //здається, DeleteFile не знищує ReadOnly-файли, тому:
  FileSetAttr(String(RemoteName), 0);

  if win32delete then
    //глюк, деякі файли не стирає, незалежно, чи вони ReadOnly
    result := Recycle(RemoteName, application.Handle)
  else
    result := DeleteFile(String(RemoteName));
  ProgressProc(0, RemoteName, '', 100);
end;

function FsRenMovFile_(OldName,NewName:pchar;Move,OverWrite:bool;RemoteInfo:pRemoteInfo):integer; stdcall;
var
  fsSrc, fsTar: TFileStream;
  bufSize, elapsed, copySize, total: Int64;

begin
  if ProgressProc(0, OldName, NewName, 0) <> 0 then
    begin
    result := FS_FILE_USERABORT;
    Exit;
    end;
  result := FS_FILE_OK;

  if FileExists(newName) then
    begin
    if Overwrite then
      begin
      FileSetAttr(String(newName), 0);
      if not sysutils.deletefile(String(newName)) then
        result := FS_FILE_WRITEERROR;
      end
    else
      result := FS_FILE_EXISTS;
    end;
    
  //Якщо потрібно перемістити файл в межах одного диску, його досить
  //тільки переіменувати
  if (result = FS_FILE_OK) and move
    //якщо на одному диску
    and (OldName[0] = NewName[0])
    //і диск не мережевий
    and (OldName[0] <> '\') then
    //то переіменувати файл
    if Windows.movefile(OldName, NewName) then
      //операція завершена успішно
      begin
      if not(ProgressProc(0, OldName, NewName, 100) = 0) then
        result := FS_FILE_USERABORT;
      Exit;
      end
    else  //Windows.movefile не спрацювала
      result := FS_FILE_WRITEERROR;
  if result <> FS_FILE_OK then  exit;


{-------------------------------------------------------}
//Власне копіювання
  try
    fsSrc := TFileStream.Create(String(oldName), fmOpenRead or fmShareDenyWrite);
  except
    try
      fsSrc := TFileStream.Create(String(oldName), fmOpenRead);
    except
      {$IFDEF DEBUG}
      LogIt('Error: Copying - cannot access source file');
      LogIt('  file='+String(oldName));
      {$ENDIF}
      result := FS_FILE_READERROR;
      Exit;
    end;
  end;

  try
    fsTar := TFileStream.Create(String(newName), fmCreate);
  except
    {$IFDEF DEBUG}
    LogIt('Error: Copying - cannot create target file');
    LogIt('  file='+String(newName));
    {$ENDIF}
    result := FS_FILE_WRITEERROR;
    fsSrc.Free;
    Exit;
  end;

  FileSetAttr(String(newName), FileGetAttr(String(oldName)));

  //nBufSize - це глобальна змінна, яку можна змінити ззовні, поки файл
  //ще не копіюється (тому що копіювання - в окремому потоці).
  //Для запобігання таким глюкам використовується локальна змінна bufSize,
  //яка невидима ззовні функції
  bufSize := nBufSize;

  elapsed := fsSrc.Size - fsSrc.Position;
  total := fsSrc.Size;

  while (elapsed > 0) do
    begin
    if elapsed < bufSize then
      CopySize := elapsed
    else
      CopySize := bufSize;

    try
      fsTar.CopyFrom(fsSrc, CopySize)
    except
      on EReadError do
        begin
        {$IFDEF DEBUG}
        LogIt('Error: Copying - read error');
        LogIt('  file='+String(oldName));
        {$ENDIF}
        result := FS_FILE_READERROR;
        end;
      on EWriteError do
        begin
        {$IFDEF DEBUG}
        LogIt('Error: Copying - write error');
        LogIt('  file='+String(newName));
        {$ENDIF}
        result := FS_FILE_WRITEERROR;
        end;
      else
        begin
        {$IFDEF DEBUG}
        LogIt('Error: Copying - unknown error');
        LogIt('  source='+String(oldName));
        LogIt('  target='+String(newName));
        {$ENDIF}
        result := FS_FILE_WRITEERROR;
        end;
      fsSrc.Free;
      fsTar.Free;
      ProgressProc(0, OldName, NewName, 0);
      FileSetAttr(String(newName), 0);
      DeleteFile(String(newName));
      Exit;
    end;
    elapsed := fsSrc.Size - fsSrc.Position;
    if ProgressProc(0, OldName, NewName, 100 - Round(elapsed / total * 100)) <> 0 then
      begin
      result := FS_FILE_USERABORT;
      Break;
      end;
    end;

  fsSrc.Free;
  fsTar.Free;

  if result {= FS_FILE_USERABORT} <> FS_FILE_OK then
    begin
    FileSetAttr(String(newName), 0);
    DeleteFile(String(newName))
    end
  else if move then
    begin
    FileSetAttr(String(oldName), 0);
    if not DeleteFile(String(oldName)) then
      result := FS_FILE_READERROR;
    end;

{-------------------------------------------------------}

end;

end.