unit RenameFrm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.UITypes, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type
  TRenameForm = class(TForm)
    EdtRename: TEdit;
    BtnRename: TButton;
    BtnCancel: TButton;
    LblStatus: TLabel;
    procedure BtnRenameClick(Sender: TObject);
    procedure BtnCancelClick(Sender: TObject);
    procedure EdtRenameKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  RenameForm: TRenameForm;

implementation

{$R *.dfm}

uses AboutForm, MainForm, MainSettings;

procedure TRenameForm.BtnCancelClick(Sender: TObject);
begin
          //Close the Dialog
          Close;
end;

procedure TRenameForm.BtnRenameClick(Sender: TObject);
 var
  RenInd: Integer;
begin
        //Rename the File
        with MusicCleaner.FileListBox1 do begin

          //Check before hand if the target file exists
          If System.SysUtils.FileExists(Directory + pathdelim + EdtRename.Text) Then
            Begin
              //File is already there ask for a new name
              MessageDlg('The file "'+EdtRename.Text+'" already exists', mtError, [mbOK], 0, mbOK);
              exit;
            End;
          MusicCleaner.CheckCurItem;
           if CurItem then Begin
             //If It is the current Item then free the Bass Lib
             MusicCleaner.FreeBassLib;
             end;
          if not RenameFile(Directory + pathdelim + Items[RenIndex], Directory + pathdelim + EdtRename.Text)  then begin
          //If file rename failed then report the error
          ShowMessage('An error has occured while renaming the file');
          //Show the status at the main form
          MusicCleaner.LblStatus.Caption := 'Error:';
          MusicCleaner.LblFile.Caption := 'An error has occured while renaming the file';
          //Update the Current Item
          MusicCleaner.UpdateCurItem;
          end else Begin
            //Rename was OK then update the Current Item
            //to match the new file name
            MusicCleaner.FileListBox1.Items.Strings[MusicCleaner.FileListBox1.ItemIndex] := EdtRename.Text;
            //Show the status at the main form
            MusicCleaner.LblStatus.Caption := 'File Renamed To:';
            MusicCleaner.LblFile.Caption := EdtRename.Text;
            //Update the Current Item
            MusicCleaner.UpdateCurItem;
          End;
                  //If the current Item was renamed then Re-Initiliaze Bass Lib
                  if CurItem then
                  begin
                      MusicCleaner.InitiliazeBassLIb;
                    end else
                  begin
                    //Do nothing
                  end;
            //Close the Rename Dialog
            Close;
        end;
end;

procedure TRenameForm.EdtRenameKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
      //If enter key is pressed then Rename File
      if Key = VK_RETURN then
      BtnRenameClick(sender);
end;

end.
