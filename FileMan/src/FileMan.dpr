program FileMan;
{$I 'defs.pas'}

{$R FileMan.res}

uses
  Forms,
  {$IFDEF DEBUG}SysUtils,{$ENDIF}
  Main in 'Forms\Main.pas' {FmMain},
  FLTypes in 'FLTypes.pas',
  FLConst in 'FLConst.pas',
  FLFunctions in 'FLFunctions.pas',
  CmGrid in 'CmGrid.pas',
  CmControl in 'CmControl.pas',
  FLGrid in 'FLGrid.pas',
  FLMessages in 'FLMessages.pas',
  FLPerform in 'FLPerform.pas',
  StrUtilsX in 'StrutilsX.pas',
  FLMenu in 'FLMenu.pas',
  CommonFolders in 'CommonFolders.pas',
  fsplugin in 'fsplugin.pas',
  FLMaskEx in 'FLMaskEx.pas',
  RequestDrv in 'Forms\RequestDrv.pas' {FmDrive},
  cxDrive10 in 'cxDrive10.pas',
  Dim in 'Dim.pas',
  DimConst in 'DimConst.pas',
  Progress in 'Forms\Progress.pas' {FmProgress},
  RequestCopyFlags in 'Forms\RequestCopyFlags.pas' {FmGetFlags},
  FLThreads in 'FLThreads.pas',
  FS in 'FS.pas',
  Search in 'Forms\Search.pas' {FmSearch},
  FileAttr in 'Forms\FileAttr.pas' {FmAttr};

{$IFDEF DEBUG}
var i: Integer;
{$ENDIF}
begin
  {$IFDEF DEBUG}
  LogIt();
  LogIt('Application started. Version=' + APP_VERSION);
  for i := 0 to ParamCount() do
    LogIt(Format('ParamStr(%d)=%s', [i, ParamStr(i)]));
  {$ENDIF}

  Application.Initialize;
  Application.CreateForm(TFmMain, FmMain);
  Application.Run;
  {$IFDEF DEBUG}
  LogIt('Application closed');
  {$ENDIF}
end.
