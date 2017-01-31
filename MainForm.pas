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
    Button1: TButton;
    Button2: TButton;
    Timer1: TTimer;
    SelectFolderDialog: TRzSelectFolderDialog;
    procedure FormCreate(Sender: TObject);
    procedure BtnAboutClick(Sender: TObject);
    procedure BtnSettingsClick(Sender: TObject);
    procedure BtnExitClick(Sender: TObject);
    procedure BtnHelpClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
    Procedure LoadSettings;
    Procedure SaveSettings;
    Procedure FreeBassLib;
    procedure InitiliazeBassLIb;
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

procedure TMusicCleaner.BtnSettingsClick(Sender: TObject);
begin
      //Show the Settings Dialog
      FrmSettings.ShowModal;
end;

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

end.
