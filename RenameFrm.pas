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
    EdtExt: TEdit;
    procedure BtnRenameClick(Sender: TObject);
    procedure BtnCancelClick(Sender: TObject);
    procedure EdtRenameKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  RenameForm: TRenameForm;
  ext: string;


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
        //Get the Extension
        ext := EdtExt.Text;
        //Rename the File
        with MusicCleaner.FileListBox1 do begin

          //Check before hand if the target file exists
          If System.SysUtils.FileExists(Directory + pathdelim + EdtRename.Text+Ext) Then
            Begin
              //File is already there ask for a new name
              MessageDlg('The file "'+EdtRename.Text+Ext+'" already exists', mtError, [mbOK], 0, mbOK);
              exit;
            End;
          MusicCleaner.CheckCurItem;
           if CurItem then Begin
             //If It is the current Item then free the Bass Lib
             MusicCleaner.FreeBassLib;
             end;
          if not RenameFile(Directory + pathdelim + Items[RenIndex], Directory + pathdelim + EdtRename.Text+Ext)  then begin
          //If file rename failed then report the error
          ShowMessage('An error has occurred while renaming the file');
          //Show the status at the main form
          MusicCleaner.LblStatus.Caption := 'Error:';
          MusicCleaner.LblFile.Caption := 'An error has occurred while renaming the file';
          //Update the Current Item
          MusicCleaner.UpdateCurItem;
          end else Begin
            //Rename was OK then update the Current Item
            //to match the new file name
            MusicCleaner.FileListBox1.Items.Strings[MusicCleaner.FileListBox1.ItemIndex] := (EdtRename.Text+Ext);
            //Show the status at the main form
            MusicCleaner.LblStatus.Caption := 'File Renamed To:';
            MusicCleaner.LblFile.Caption := (EdtRename.Text + Ext);
            //Update the Current Item
            MusicCleaner.UpdateCurItem;
          End;
                  //If the current Item was renamed then Re-Initialize Bass Lib
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

procedure TRenameForm.FormShow(Sender: TObject);
begin
      //Set Focus to the EdtRename
      EdtRename.SetFocus;
end;

end.
