program Music_Cleaner;

uses
  Vcl.Forms,
  MainForm in 'MainForm.pas' {MusicCleaner},
  MainSettings in 'MainSettings.pas' {FrmSettings},
  AboutForm in 'AboutForm.pas' {FormAbout},
  Vcl.Themes,
  Vcl.Styles;

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  TStyleManager.TrySetStyle('Amethyst Kamri');
  Application.Title := 'Music Cleaner';
  Application.CreateForm(TMusicCleaner, MusicCleaner);
  Application.CreateForm(TFrmSettings, FrmSettings);
  Application.CreateForm(TFormAbout, FormAbout);
  Application.Run;
end.
