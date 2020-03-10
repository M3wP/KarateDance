program CharsetChk;

uses
  System.StartUpCopy,
  FMX.Forms,
  FormCharsetChkMain in 'FormCharsetChkMain.pas' {Form1},
  C64UtilTypes in 'C64UtilTypes.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
