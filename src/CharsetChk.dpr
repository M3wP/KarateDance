program CharsetChk;

uses
  System.StartUpCopy,
  FMX.Forms,
  FormCharsetChkMain in 'FormCharsetChkMain.pas' {Form1},
  KrDnceUtilTypes in 'KrDnceUtilTypes.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
