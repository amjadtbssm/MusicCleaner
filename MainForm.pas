unit MainForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.Imaging.pngimage, RzShellDialogs, Vcl.FileCtrl, Vcl.ComCtrls, Bass, ShellAPI, INIFiles,
  Vcl.Imaging.GIFImg, Math;

type
  TMusicCleaner = class(TForm)
    Image1: TImage;
    Label3: TLabel;
    LblPlaying: TLabel;
    Label5: TLabel;
    PathLabel: TLabel;
    LblStatus: TLabel;
    LblFile: TLabel;
    Image2: TImage;
    BtnSelectFolder: TButton;
    BtnSettings: TButton;
    BtnAbout: TButton;
    BtnPlay: TButton;
    BtnPause: TButton;
    btnStop: TButton;
    BtnDelete: TButton;
    BtnCopy: TButton;
    BtnMove: TButton;
    BtnExit: TButton;
    FileListBox1: TFileListBox;
    BtnHelp: TButton;
    ProgressBar1: TProgressBar;
    BtnPre: TButton;
    BtnNext: TButton;
    Timer1: TTimer;
    SelectFolderDialog: TRzSelectFolderDialog;
    procedure FormCreate(Sender: TObject);
    procedure BtnAboutClick(Sender: TObject);
    procedure BtnSettingsClick(Sender: TObject);
    procedure BtnExitClick(Sender: TObject);
    procedure BtnHelpClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormDestroy(Sender: TObject);
    procedure BtnSelectFolderClick(Sender: TObject);
    procedure BtnPlayClick(Sender: TObject);
    procedure BtnPauseClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure ProgressBar1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FileListBox1KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure BtnDeleteClick(Sender: TObject);
    procedure PlayMusic(Sender: TObject);
    procedure FileListBox1DblClick(Sender: TObject);
    procedure BtnCopyClick(Sender: TObject);
    procedure BtnMoveClick(Sender: TObject);
    procedure BtnNextClick(Sender: TObject);
    procedure btnStopClick(Sender: TObject);
    procedure BtnPreClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    { Private declarations }
    Procedure PlayItem(Item: Integer);
    Procedure LoadSettings;
    Procedure SaveSettings;
    Procedure FreeBassLib;
    procedure InitiliazeBassLIb;
    procedure CheckCopyPath(Sender: TObject);
    procedure CheckMovePath(Sender: TObject);
    Function FileOperation(const source, dest : string; op, flags : Integer) : boolean;
    Procedure RemoveSelected;
    Procedure UpdateCurItem;
    Procedure CheckCurItem;
  public
    { Public declarations }
  end;

var
  MusicCleaner: TMusicCleaner;
  Stream: HSTREAM;
  Tracking: Boolean;
  MoveDir: string;
  CopyDir: string;
  CurItem: Boolean;
  CurFile: Integer;
  IsPlaying: Boolean;

implementation

{$R *.dfm}

uses AboutForm, MainSettings;

// Extract a file name after striping its extension and paths
function ExtractFileNameWithoutExtension (const AFileName: String): String;
var
I: Integer;
begin
  I := LastDelimiter('.' + PathDelim + DriveDelim,AFilename);
  if (I = 0) or (AFileName[I] <> '.') then I := MaxInt;
  Result := ExtractFileName(Copy(AFileName, 1, I - 1)) ;
end;

procedure TMusicCleaner.BtnAboutClick(Sender: TObject);
begin
      //Show the About Box
      FormAbout.ShowModal;

end;

procedure TMusicCleaner.BtnCopyClick(Sender: TObject);
  Var
    FileName, TargetFileName: String;
    OpSuccess : boolean;
begin
    if FileListBox1.ItemIndex < 0 then Exit
      Else
      // Check if Copy to Folder Exists
      CheckCopyPath(Sender);
      // Copy the File
   FileName := IncludeTrailingPathDelimiter(FileListBox1.Directory)+FileListBox1.Items.Strings[FileListBox1.ItemIndex];
   TargetFileName := CopyDir +PathDelim+ FileListBox1.Items.Strings[FileListBox1.ItemIndex];
   OpSuccess := FileOperation(FileName, CopyDir, FO_COPY, FOF_ALLOWUNDO);
    if (OpSuccess) then begin
    LblStatus.Caption := 'File Copied to:';
    // File copied to below path
    LblFile.Caption := TargetFileName;
         end else begin
    LblStatus.Caption := 'Failed to Copy:';
    // Here the file title should be "Copied from" so that we can check
    // from where the copy command has failed
    LblFile.Caption := FileName;
         end;
end;

procedure TMusicCleaner.BtnDeleteClick(Sender: TObject);
  Var
    OpSuccess : boolean;
    FileOrFolder : string;
begin
      CurItem := False;
      if FileListBox1.ItemIndex < 0 then begin Exit
      end Else

        Begin
            // Delete the selected file
            FileOrFolder := IncludeTrailingPathDelimiter(FileListBox1.Directory)+FileListBox1.Items.Strings[FileListBox1.ItemIndex];
            CheckCurItem;
                  if CurItem then Begin
                        //CurItem Collides free the bass
                        FreeBassLib;
                 end;

          OpSuccess := FileOperation(FileOrFolder, '', FO_DELETE, FOF_ALLOWUNDO or FOF_NOCONFIRMATION);
            if (OpSuccess) then begin
                        LblStatus.Caption := 'File Deleted:';
                        LblFile.Caption := FileOrFolder;
                        RemoveSelected;
                        UpdateCurItem;

                end else
                    begin
                        LblStatus.Caption := 'Failed to Delete:';
                        LblFile.Caption := FileOrFolder;
                        UpdateCurItem;
                    End;
                                if CurItem then  begin
                                     InitiliazeBassLIb;
                                           end else
                                              begin
                                              Exit;
                                    end;
      End;  // Main Procedure
      BtnPlayClick(sender);
end;

procedure TMusicCleaner.BtnExitClick(Sender: TObject);
begin
      //Close the Application
      close;
end;

procedure TMusicCleaner.BtnHelpClick(Sender: TObject);
begin
      // Show the Help File
      ShellExecute(Handle, 'open', PChar(ExtractFilePath(Application.ExeName)+'\Help\Help.html'),nil,nil,SW_SHOWNORMAL) ;
end;

procedure TMusicCleaner.BtnMoveClick(Sender: TObject);
 Var
    OpSuccess : boolean;
    FileOrFolder, MoveTargetFile : string;
begin
      CurItem := False;
      if FileListBox1.ItemIndex < 0 then begin Exit
      end Else

        Begin
            // Delete File
            FileOrFolder := IncludeTrailingPathDelimiter(FileListBox1.Directory)+FileListBox1.Items.Strings[FileListBox1.ItemIndex];
            MoveTargetFile := MoveDir +PathDelim+ FileListBox1.Items.Strings[FileListBox1.ItemIndex];;
            CheckCurItem;
                  if CurItem then Begin
                        //CurItem Collides free the bass lib
                        FreeBassLib;
                 end;
          OpSuccess := FileOperation(FileOrFolder, MoveDir, FO_MOVE, FOF_ALLOWUNDO);
            if (OpSuccess) then begin
                        LblStatus.Caption := 'File Moved to:';
                        LblFile.Caption := MoveTargetFile;
                        RemoveSelected;
                        UpdateCurItem;

                end else
                    begin
                        // RemoveSelected;
                        LblStatus.Caption := 'Failed to Move:';
                        LblFile.Caption := FileOrFolder;
                        UpdateCurItem;
                    End;

                                if CurItem then  begin
                                     // If the cuurent item was playing
                                     // the bass lib was freed so re-initialize
                                     InitiliazeBassLIb;
                                     // Also play the next track ;-)
                                     BtnPlayClick(sender);
                                           end else
                                              begin
                                              Exit;
                                    end;
      End;  // Main Procedure

end;

procedure TMusicCleaner.BtnNextClick(Sender: TObject);
 var
  CurrentOne, NextOne: Integer;
  EndOfList: Boolean;
begin
   // Play Next Item
  if FileListBox1.ItemIndex < 0 then
            Exit else
        Begin
          // Pick the current file
          CurrentOne := CurFile;
        // If current track has reached the end of list then go to first track
        if (CurrentOne = FileListBox1.Items.Count -1) then
          Begin
           CurrentOne := 0;
          end else begin
            //Go to the next track
            CurrentOne := CurrentOne + 1;
          end;
      // Get the Next Track ID Number and Play the track
      NextOne := CurrentOne;
      PlayItem(NextOne);
      //Set the current file to the new Track ID Number
      CurFile := NextOne;
      //Change the Now Playing Lable Caption
      FileListBox1.ItemIndex := NextOne;
      LblPlaying.Caption := IncludeTrailingPathDelimiter(FileListBox1.Directory)+FileListBox1.Items.Strings[NextOne];
  End;
end;

procedure TMusicCleaner.BtnPauseClick(Sender: TObject);
begin
    // Pause the playing BASS Stream
    BASS_ChannelPause(stream);
end;

procedure TMusicCleaner.BtnPlayClick(Sender: TObject);
begin
if BASS_ChannelIsActive(stream) = BASS_ACTIVE_PAUSED then begin
  BASS_ChannelPlay(stream, False)
end else Begin
   if FileListBox1.ItemIndex < 0 then Exit else
      PlayItem(FileListBox1.ItemIndex);
      CurFile := FileListBox1.ItemIndex;
      LblPlaying.Caption := IncludeTrailingPathDelimiter(FileListBox1.Directory)+FileListBox1.Items.Strings[CurFile];
    end;
end;

procedure TMusicCleaner.BtnPreClick(Sender: TObject);
 var
  CurrentOne, NextOne: Integer;
  EndOfList: Boolean;
begin
  // Play Previous Item
  if FileListBox1.ItemIndex < 0 then
            Exit else
        Begin
          // Get current track
          CurrentOne := CurFile;
        // If current track is the first track then go to last track
        // (As previous of the first track would be last)
        if  CurrentOne = 0 then
          Begin
           CurrentOne := FileListBox1.Items.Count -1;
          end else begin
            // Go to previous track
            CurrentOne := CurrentOne - 1;
          end;
      // Assign the previous track
      NextOne := CurrentOne;
      // Play the previous track
      PlayItem(NextOne);
      // Set the current track file
      CurFile := NextOne;
      //Change the Now Playing Lable Caption
      FileListBox1.ItemIndex := NextOne;
      LblPlaying.Caption := IncludeTrailingPathDelimiter(FileListBox1.Directory)+FileListBox1.Items.Strings[NextOne];
  End;
end;

procedure TMusicCleaner.BtnSelectFolderClick(Sender: TObject);
Var
  Path, S    : String;
begin
  if SelectFolderDialog.Execute then
  begin
    Path:=IncludeTrailingPathDelimiter(SelectFolderDialog.SelectedPathName);
    FileListBox1.Directory := Path;
    PathLabel.Caption := Path;
  end;
end;

procedure TMusicCleaner.BtnSettingsClick(Sender: TObject);
begin
      //Show the Settings Dialog
      FrmSettings.ShowModal;
end;

procedure TMusicCleaner.btnStopClick(Sender: TObject);
begin
  // Stop the current playing track
  BASS_ChannelStop(stream);
  // Reset the current track position to start
  BASS_ChannelSetPosition(stream, 0, 0);
end;

procedure TMusicCleaner.CheckCopyPath(Sender: TObject);
begin
      // Check if the Copy to Directories exist if not create them

      if DirectoryExists (CopyDir) then
          begin
            Exit;
          end else
            ShowMessage('Copy To Folder does not exist' + #13#10 + 'It will be created');
            CreateDir(CopyDir);
end;

procedure TMusicCleaner.CheckCurItem;
  var
    CurntIndex: Integer;
begin
        // Check the current Playing Item Index
        CurntIndex := FileListBox1.ItemIndex;
        if CurntIndex > CurFile then begin
    exit
    end else if CurntIndex < CurFile then
    begin
      // As it is meant to check only do not alter index
      Exit;
    end

    // If playing the current selected index then set CurItem to True
     else if CurntIndex = CurFile then
     Begin
       CurItem := True;
     End;
end;

procedure TMusicCleaner.CheckMovePath(Sender: TObject);
begin
          // Check if the Move to Directories exist if not create them

      if DirectoryExists (MoveDir) then
          begin
            // ShowMessage('Copy To Folder Exists');
            Exit;
          end else
            ShowMessage('Move To Folder does not exist' + #13#10 + 'It will be created');
            CreateDir(MoveDir);
end;

procedure TMusicCleaner.FileListBox1DblClick(Sender: TObject);
begin
     // Play the double clicked track
     PlayMusic(sender);
end;

procedure TMusicCleaner.FileListBox1KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
        //If enter key is pressed then play selected entry
      if Key = VK_RETURN then
      PlayMusic(sender);

      // Play Button Key is pressed then play
      if Key= VK_PLAY then
        PlayMusic(sender);

      //If Delete Key is pressed then delete the selected File
      if Key = VK_DELETE then
        BtnDeleteClick(Sender);

end;

function TMusicCleaner.FileOperation(const source, dest: string; op,
  flags: Integer): boolean;
{perform Copy, Move, Delete, Rename on files + folders via WinAPI}
var
  Structure : TSHFileOpStruct;
  src, dst : string;
  OpResult : integer;
begin
  {setup file op structure}
  FillChar(Structure, SizeOf (Structure), #0);
  src := source + #0#0;
  dst := dest + #0#0;
  Structure.Wnd := 0;
  Structure.wFunc := op;
  Structure.pFrom := PChar(src);
  Structure.pTo := PChar(dst);
  Structure.fFlags := flags or FOF_SILENT;
  case op of
    {set title for simple progress dialog}
    FO_COPY : Structure.lpszProgressTitle := 'Copying...';
    FO_DELETE : Structure.lpszProgressTitle := 'Deleting...';
    FO_MOVE : Structure.lpszProgressTitle := 'Moving...';
    FO_RENAME : Structure.lpszProgressTitle := 'Renaming...';
    end; {case op of..}
  OpResult := 1;
  try
    {perform operation}
    OpResult := SHFileOperation(Structure);
  finally
    {report success / failure}
    result := (OpResult = 0);
    end; {try..finally..}
end; {function FileOperation}

procedure TMusicCleaner.FormClose(Sender: TObject; var Action: TCloseAction);
begin
    // Save Form and Directory Settings
    SaveSettings;
end;

procedure TMusicCleaner.FormCreate(Sender: TObject);
begin
       // Load the Settings i.e. Default Move and Copy Directories
       LoadSettings;
       // Initialize Bass Library
       // If initialization fails terminate the application
       if Bass_init( -1, 44100, 0, Handle, nil) = false then begin
            showmessage('Audio Initalization Failed'+#13#10+'Music Cleaner will now close');
	          Application.Terminate;
	  end;
end;

procedure TMusicCleaner.FormDestroy(Sender: TObject);
begin
       // Free Bass Library
      FreeBassLib;
end;

procedure TMusicCleaner.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
       //If F1 key is pressed show the about box
       if Key = VK_F1 then
        BtnAboutClick(sender);

        //If the SPACE key is pressed play/pause the track
        if Key = VK_SPACE then
        Begin
          //If the track is paused play it
          if BASS_ChannelIsActive(stream) = BASS_ACTIVE_PAUSED then begin
              BASS_ChannelPlay(stream, False)
                end else Begin
                //if track is playing pause it
                BASS_ChannelPause(stream);
                End;
        End;

       //if Play/Pause button is clicked then play or pause the track
      if Key=VK_MEDIA_PLAY_PAUSE Then
        Begin
          //If the track is paused play it
          if BASS_ChannelIsActive(stream) = BASS_ACTIVE_PAUSED then begin
              BASS_ChannelPlay(stream, False)
                end else Begin
                //if track is playing pause it
                BASS_ChannelPause(stream);
                End;
      End;
end;

procedure TMusicCleaner.FreeBassLib;
begin
   // Free the Bass Library
        BASS_Free();
end;

procedure TMusicCleaner.InitiliazeBassLIb;
begin
    if Bass_init( -1, 44100, 0, Handle, nil) = false then
        exit;
end;

procedure TMusicCleaner.LoadSettings;
var
    ini: TIniFile;
begin
  // Load INI File and load the settings
  INI := TIniFile.Create(ExtractFilePath(Application.ExeName)+ 'settings.ini');
    Try
       MoveDir := Ini.ReadString('MusicCleaner', 'MoveDir', MoveDir);
       CopyDir := Ini.ReadString('MusicCleaner', 'CopyDir', CopyDir);
       Top := INI.ReadInteger('Placement','Top', Top) ;
       Left := INI.ReadInteger('Placement','Left', Left);
    Finally
       Ini.Free;
    End;
end;

procedure TMusicCleaner.PlayItem(Item: Integer);
var
  MyFile:String;
begin
    MyFile := IncludeTrailingPathDelimiter(FileListBox1.Directory)+FileListBox1.Items.Strings[Item];
     if item < 0  then exit;
   if stream <> 0 then
      BASS_StreamFree(stream);
      stream := BASS_StreamCreateFile(False, PChar(MyFile), 0, 0, 0 {$IFDEF UNICODE} or BASS_UNICODE {$ENDIF});
    if stream = 0  then
      showmessage('Error Loading File')
    else begin
      ProgressBar1.Min := 0;
      ProgressBar1.Max := BASS_ChannelGetLength(stream, 0) -1;
      ProgressBar1.Position := 0;
      BASS_ChannelPlay(Stream,False);
    end;
end;

procedure TMusicCleaner.PlayMusic(Sender: TObject);
begin
      // Play the selected Item in BASS
      PlayItem(FileListBox1.ItemIndex);
      CurFile := FileListBox1.ItemIndex;
      // Change the Now Playing Lable Caption
      LblPlaying.Caption := IncludeTrailingPathDelimiter(FileListBox1.Directory)+FileListBox1.Items.Strings[FileListBox1.ItemIndex];
end;

procedure TMusicCleaner.ProgressBar1MouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  Percent: Double;
begin
  Percent := X / ProgressBar1.Width;
  BASS_ChannelSetPosition(stream, Floor(Percent * (BASS_ChannelGetLength(stream, 0) -1)), 0)
end;

procedure TMusicCleaner.RemoveSelected;
var
  PrevIndex, I: Integer;
begin
            // Remove The selected Entry

            //Get the current Track ID
            PrevIndex := FileListBox1.ItemIndex;
            // Remove it from the FileListBox
            FileListBox1.Items.Delete(PrevIndex);

            //if removed Track ID is grater than FileListBox items
          if PrevIndex > (FileListBox1.Items.Count -1) then
              begin
              //Then move Track ID to one track previous
              PrevIndex := FileListBox1.Items.Count -1;
              //Set the current selected track to the previous track
              FileListBox1.ItemIndex := PrevIndex;
              end else
                  begin
                    //If Its not larger than the deleted track then leave as is
                    FileListBox1.ItemIndex := PrevIndex;
                  end;

          // If the remaining track is single then make it selected
          if (PrevIndex = 0) and  (FileListBox1.Items.Count <> -1) then
                 FileListBox1.ItemIndex := 0;
end;

procedure TMusicCleaner.SaveSettings;
  var
    ini: TIniFile;
begin
    // Save Settings to INI File
  INI := TIniFile.Create(ExtractFilePath(Application.ExeName)+ 'settings.ini');
    Try
  with INI do
     begin
       WriteString('MusicCleaner','MoveDir', MoveDir);
       WriteString('MusicCleaner','CopyDir', CopyDir);
       WriteInteger('Placement','Top', Top) ;
       WriteInteger('Placement','Left', Left) ;
     end;
   finally
     Ini.Free;
    End;
end;

procedure TMusicCleaner.Timer1Timer(Sender: TObject);
begin
    // Show the progress of the playing item
    if Tracking = False then
    ProgressBar1.Position := BASS_ChannelGetPosition(stream,0);
end;

procedure TMusicCleaner.UpdateCurItem;
var
  CurntItem: Integer;
begin
      // Check the current Playing Item Index
        if CurFile <> -1 then
         begin
        CurntItem := FileListBox1.ItemIndex;
        if CurntItem > CurFile then begin
      //Current Playing File is prior to the index
      // CurFile Variable will not be disturbed
    exit
    end else if CurntItem = CurFile then
    begin
        // If CurntItem equals the CurFile then simply exit the function
        CurFile := CurntItem;
        Exit;
        end else if CurntItem < CurFile then
    begin
      // CurFile is Greater than current index so 1 will be minused
      CurFile := CurFile - 1;
    end;
         end;
end;

end.
