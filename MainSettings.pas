unit MainSettings;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, RzShellDialogs;

type
  TFrmSettings = class(TForm)
    EdtCopyDir: TEdit;
    EdtMoveDir: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    SelectDirDlg: TRzSelectFolderDialog;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmSettings: TFrmSettings;

implementation

{$R *.dfm}

uses MainForm;

procedure TFrmSettings.Button1Click(Sender: TObject);
begin
        // Set the MainForm Variables Accordingly
        MainForm.CopyDir := EdtCopyDir.Text;
        MainForm.MoveDir := EdtMoveDir.Text;


      // Check the contents of EditBoxes
      Try
       if System.SysUtils.DirectoryExists (EdtCopyDir.Text) then
          begin
            // ShowMessage('Copy To Folder Exists');
            Exit;
          end else
            ShowMessage('Copy To Folder does not exist' + #13#10 + 'It will be created');
            System.SysUtils.ForceDirectories(EdtCopyDir.Text);

        if System.SysUtils.DirectoryExists (EdtMoveDir.Text) then
           begin
              // ShowMessage ('Move To Folder Exists');
            Exit;
         end else
            ShowMessage('Move To Folder does not exist' + #13#10 + 'It will be created');
            System.SysUtils.ForceDirectories(EdtMoveDir.Text);
            Finally

             Close;
      End;
end;

procedure TFrmSettings.Button2Click(Sender: TObject);
begin
        if SelectDirDlg.Execute
          then
             SelectDirDlg.Title := 'Select Copy To Folder';
             EdtCopyDir.Text := SelectDirDlg.SelectedPathName;
end;

procedure TFrmSettings.Button3Click(Sender: TObject);
begin
        if SelectDirDlg.Execute
          then
             SelectDirDlg.Title := 'Select Move To Folder';
             EdtMoveDir.Text := SelectDirDlg.SelectedPathName;
end;

procedure TFrmSettings.FormCreate(Sender: TObject);
begin
             // Initilize the Folders
             EdtCopyDir.Text := MainForm.CopyDir;
             EdtMoveDir.Text := MainForm.MoveDir;
end;

end.
