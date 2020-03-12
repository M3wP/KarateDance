program StepsLibrarian;

uses
  System.StartUpCopy,
  FMX.Forms,
  FormStepsLibMain in 'FormStepsLibMain.pas' {StepsLibMainForm},
  KrDnceUtilTypes in 'KrDnceUtilTypes.pas',
  FormStepsLibStep in 'FormStepsLibStep.pas' {StepsLibStepForm},
  FormStepsLibScreen in 'FormStepsLibScreen.pas' {StepsLibScreenForm},
  FormStepsLibImages in 'FormStepsLibImages.pas' {StepsLibImagesForm},
  KrDnceGraphTypes in 'KrDnceGraphTypes.pas',
  DModStepsLibMain in 'DModStepsLibMain.pas' {StepsLibMainDMod: TDataModule};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TStepsLibMainForm, StepsLibMainForm);
  Application.CreateForm(TStepsLibStepForm, StepsLibStepForm);
  Application.CreateForm(TStepsLibScreenForm, StepsLibScreenForm);
  Application.CreateForm(TStepsLibImagesForm, StepsLibImagesForm);
  Application.CreateForm(TStepsLibMainDMod, StepsLibMainDMod);
  Application.Run;
end.
