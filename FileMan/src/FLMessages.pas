unit FLMessages;
{$I 'defs.pas'}

interface

uses Messages;

const
  {message}
  WM_CMD_PERFORM        = WM_USER + 51;

  {wParam values}
  

  cm_SrcComments=300;             //Source: Show comments
  cm_SrcShort=301;                //Source: Only file names
  cm_SrcLong=302;                 //Source: All file details
  cm_SrcTree=303;                 //Source: Directory tree
  cm_SrcQuickview=304;            //Source: Quick view panel
  cm_VerticalPanels=305;          //File windows above each other
  cm_SrcExecs=311;                //Source: Only programs
  cm_SrcAllFiles=312;             //Source: All files
  cm_SrcUserSpec=313;             //Source: Last selected
  cm_SrcUserDef=314;              //Source: Select user type
  cm_SrcByName=321;               //Source: Sort by name
  cm_SrcByExt=322;                //Source: Sort by extension
  cm_SrcBySize=323;               //Source: Sort by size
  cm_SrcByDateTime=324;           //Source: Sort by date
  cm_SrcUnsorted=325;             //Source: Unsorted
  cm_SrcNegOrder=330;             //Source: Reversed order
  cm_SrcOpenDrives=331;           //Source: Open drive list

  cm_LeftComments=100;            //Left: Show comments
  cm_LeftShort=101;               //Left: Only file names
  cm_LeftLong=102;                //Left: All file details
  cm_LeftTree=103;                //Left: Directory tree
  cm_LeftQuickview=104;           //Left: Quick view panel
  cm_LeftExecs=111;               //Left: Only programs
  cm_LeftAllFiles=112;            //Left: All files
  cm_LeftUserSpec=113;            //Left: Last selected
  cm_LeftUserDef=114;             //Left: Select user type
  cm_LeftByName=121;              //Left: Sort by name
  cm_LeftByExt=122;               //Left: Sort by extension
  cm_LeftBySize=123;              //Left: Sort by size
  cm_LeftByDateTime=124;          //Left: Sort by date
  cm_LeftUnsorted=125;            //Left: Unsorted
  cm_LeftNegOrder=130;            //Left: Reversed order
  cm_LeftOpenDrives=131;          //Left: Open drive list

  cm_RightComments=200;           //Right: Show comments
  cm_RightShort=201;              //Right: Only file names
  cm_RightLong=202;               //Right: All file details
  cm_RightTree=203;               //Right: Directory tree
  cm_RightQuickview=204;          //Right: Quick view panel
  cm_RightExecs=211;              //Right: Only programs
  cm_RightAllFiles=212;           //Right: All files
  cm_RightUserSpec=213;           //Right: Last selected
  cm_RightUserDef=214;            //Right: Select user type
  cm_RightByName=221;             //Right: Sort by name
  cm_RightByExt=222;              //Right: Sort by extension
  cm_RightBySize=223;             //Right: Sort by size
  cm_RightByDateTime=224;         //Right: Sort by date
  cm_RightUnsorted=225;           //Right: Unsorted
  cm_RightNegOrder=230;           //Right: Reversed order
  cm_RightOpenDrives=231;         //Right: Open drive list

  cm_Config=490;                  //Conf: General settings
  cm_Config2=516;                 //Conf: Extended settings
  cm_PackerConfig=491;            //Conf: Packer
  cm_FontConfig=492;              //Conf: Font
  cm_ConfigSavePos=493;           //Conf: Save position
  cm_ColorConfig=494;             //Conf: Colors
  cm_Confirmation=495;            //Conf: Confirmation
  cm_EditConfig=496;              //Conf: Viewer/Editor
  cm_ConfTabChange=497;           //Conf: Tabstops
  cm_ButtonConfig=498;            //Conf: Button bar
  cm_LanguageConfig=499;          //Conf: Language

  cm_CDtree=500;                  //Popup directory tree
  cm_SearchFor=501;               //Search for
  cm_SetAttrib=502;               //Change attributes
  cm_GetFileSpace=503;            //Calculate space
  cm_PrintFile=504;               //Print file
  cm_VolumeId=505;                //Volume label
  cm_SysInfo=506;                 //System information
  cm_Associate=507;               //Associate
  cm_PackFiles=508;               //Pack files
  cm_UnpackFiles=509;             //Unpack all
  cm_TestArchive=518;             //Test selected archives
  cm_VersionInfo=510;             //Version information
  cm_ExecuteDOS=511;              //Start DOS
  cm_NetConnect=512;              //Network connections
  cm_NetDisconnect=513;           //Disconnect network drives
  cm_NetShareDir=514;             //Share directory
  cm_NetUnshareDir=515;           //Unshare directory
  cm_SpreadSelection=521;         //Select group
  cm_ShrinkSelection=522;         //Unselect group
  cm_SelectAll=523;               //Select all
  cm_ClearAll=524;                //Unselect all
  cm_ExchangeSelection=525;       //Invert selection
  cm_DirectoryHotlist=526;        //Directory popup menu
  cm_SelectCurrentExtension=527;  //Select all files with same ext.
  cm_UnselectCurrentExtension=528;//Unselect all files with same ext.
  cm_RestoreSelection=529;        //Selection before last operation
  cm_Exchange=531;                //Swap panels
  cm_MatchSrc=532;                //target=Source
  cm_CompareDirs=533;             //Compare dirs
  cm_DirMatch=534;                //Mark newer
  cm_RereadSource=540;            //Reread source
  cm_FtpConnect=550;              //Connect to FTP
  cm_FtpNew=551;                  //New FTP connection
  cm_FtpDisconnect=552;           //Disconnect from FTP
  cm_FtpHiddenFiles=553;          //Show hidden FTP files
  cm_FtpAbort=554;                //Abort current FTP command
  cm_FtpResumeDownload=555;       //Resume aborted download
  cm_FtpSelectTransferMode=556;   //Select Binary, ASCII or Auto mode
  cm_ftpaddtolist=557;            //Add selected files to download list
  cm_ftpdownloadlist=558;         //Download files in download list
  cm_OpenTransferManager=559;     //Background transfer manager
  cm_Split=560;                   //Split file into pieces
  cm_Combine=561;                 //Combine partial files
  cm_Encode=562;                  //Encode MIME/UUE/XXE
  cm_Decode=563;                  //Decode MIME/UUE/XXE/BinHex
  cm_CRCcreate=564;               //Create CRC checksums
  cm_CRCcheck=565;                //Verify CRC checksums

  cm_GotoPreviousDir=570;         //Go back
  cm_GotoNextDir=571;             //Go forward
  cm_DirectoryHistory=572;        //History list

  cm_configSaveSettings=580;      //Save current paths etc.
  cm_configChangeIniFiles=581;    //Open ini files in notepad

  cm_HelpIndex=610;               //Help index
  cm_Keyboard=620;                //Keyboard help
  cm_Register=630;                //Registration info
  cm_VisitHomepage=640;           //Visit http:                          //www.ghisler.com/
  cm_About=690;                   //Help/About Total Commander

  cm_ChangeStartMenu=700;         //Change Start menu

  cm_Exit=24340;                  //Exit Total Commander

  cm_Minimize=2000;               //Minimize Total Commander
  cm_Maximize=2015;               //Maximize Total Commander
  cm_Restore=2016;                //Restore normal size
  cm_GoToRoot=2001;               //Go to root directory
  cm_GoToParent=2002;             //Go to parent directory
  cm_GoToDir=2003;                //Open dir or zip under cursor
  cm_ClearCmdLine=2004;           //Clear command line
  cm_NextCommand=2005;            //Next command line
  cm_PrevCommand=2006;            //Previous command line

  cm_List=903;                    //View with Lister
  cm_Edit=904;                    //Edit (Notepad)
  cm_Copy=905;                    //Copy files
  cm_RenMov=906;                  //Rename/Move files
  cm_MkDir=907;                   //Make directory
  cm_Delete=908;                  //Delete files
  cm_50percent=909;               //Window separator at 50%
  cm_Return=1001;                 //Simulate: Return pressed
  cm_RenameOnly=1002;             //Rename (Shift+F6)
  cm_Properties=1003;             //Properties dialog
  cm_CreateShortcut=1004;         //Create a shortcut

  cm_CutToClipboard=2007;         //(32-bit) Cut selected files to clipboard
  cm_CopyToClipboard=2008;        //(32-bit) Copy selected files to clipboard
  cm_PasteFromClipboard=2009;     //(32-bit) Paste from clipboard to current dir
  cm_SwitchLongNames=2010;        //Turn long names on and off (Win9x/Me/NT/2000 only)
  cm_SwitchHidSys=2011;           //Turn hidden/system files on and off
  cm_SwitchDirSort=2012;          //Turn directory sorting by name on/off
  cm_Switch83Names=2013;          //Turn 8.3 names lowercase on/off
  cm_countdircontent=2014;        //Calculate space occupied by subdirs in current dir
  cm_CopyNamesToClip=2017;        //Copy filenames to clipboard
  cm_CopyFullNamesToClip=2018;    //Copy names with full path
  cm_CopyNetNamesToClip=2021;     //Copy names with UNC path
  cm_CopySrcPathToClip=2029;      //Copy source path to clipboard
  cm_CopyTrgPathToClip=2030;      //Copy target path to clipboard
  cm_AddPathToCmdline=2019;       //Copy path to command line

  cm_FileSync=2020;               //Synchronize directories
  cm_CompareFilesByContent=2022;  //File comparison
  cm_ShowOnlySelected=2023;       //Hide files which aren't selected
  cm_TransferLeft=2024;           //Transfer dir under cursor to left window
  cm_TransferRight=2025;          //Transfer dir under cursor to right window
  cm_DirBranch=2026;              //Show all files in current dir and no subdirs
  cm_PrintDir=2027;               //Print current directory (with preview)
  cm_printdirsub=2028;            //Print dir with subdirs

  cm_OpenDesktop=2121;            //Desktop folder
  cm_OpenDrives=2122;             //My computer
  cm_OpenControls=2123;           //Control panel
  cm_OpenFonts=2124;              //Fonts folder
  cm_OpenNetwork=2125;            //Network neighborhood
  cm_OpenPrinters=2126;           //Printers folder
  cm_OpenRecycled=2127;           //Recycle bin

  cm_EditPermissionInfo=2200;     //Permissions dialog (NTFS)
  cm_EditPersmissionInfo=2200;    //Typo...
  cm_EditAuditInfo=2201;          //File auditing (NTFS)
  cm_EditOwnerInfo=2202;          //Take ownership (NTFS)
  cm_ShowFileUser=2203;           //Which remote user has opened a local file
  cm_AdministerServer=2204;       //Connect to admin share to open \\server\c$ etc.

  cm_DirectCableConnect=2300;     //Connect to other PC by cable
  cm_NTinstallDriver=2301;        //Install parallel port driver on NT
  cm_NTremoveDriver=2302;         //Remove parallel port driver on NT

  cm_MultiRenameFiles=2400;       //Rename multiple files

  cm_ContextMenu=2500;            //Show context menu
  cm_SyncChangeDir=2600;          //Synchronous directory changing in both windows
  cm_EditComment=2700;            //Edit file comment
  cm_OpenAsUser=2800;             //Open program under cursor as different user

  cm_visButtonbar=2901;           //Show/hide button bar
  cm_visDriveButtons=2902;        //Show/hide drive button bars
  cm_visTwoDriveButtons=2903;     //Show/hide two drive bars
  cm_visFlatdriveButtons=2904;    //Buttons: Flat/normal mode
  cm_visFlatInterface=2905;       //Interface: Flat/normal mode
  cm_visDriveCombo=2906;          //Show/hide drive combobox
  cm_visCurDir=2907;              //Show/hide current directory
  cm_visTabheader=2908;           //Show/hide tab header (sorting)
  cm_visStatusbar=2909;           //Show/hide status bar
  cm_visCmdLine=2910;             //Show/hide Command line
  cm_visKeyButtons=2911;          //Show/hide function key buttons
  cm_EditPath=2912;               //Edit path field above file list
  cm_UnloadPlugins=2913;          //Unload all plugins

  cm_focusleft=4001;              //Focus on left file list
  cm_focusright=4002;             //Focus on right file list


  cm_RereadLeft=1;                //Reread left
  cm_RereadRight=2;               //Reread right
  cm_RereadSourceSoft=3;
  cm_RereadLeftSoft=4;
  cm_RereadRightSoft=5;
  cm_Recycle=6;                   //Deletes file to recycled bin

implementation

end.
