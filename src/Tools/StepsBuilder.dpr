program StepsBuilder;

uses
  System.StartUpCopy,
  FMX.Forms,
  FormStepsBuildMain in 'FormStepsBuildMain.pas' {StepsBuildForm},
  C64UtilTypes in 'C64UtilTypes.pas',
  FormStepsBuildStep in 'FormStepsBuildStep.pas' {StepsBuildStepForm},
  FormStepsBuildScreen in 'FormStepsBuildScreen.pas' {StepsBuildScreenForm},
  FormStepsBuildImages in 'FormStepsBuildImages.pas' {StepsBuildImagesForm},
  KrDnceGraphTypes in 'KrDnceGraphTypes.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TStepsBuildForm, StepsBuildForm);
  Application.CreateForm(TStepsBuildStepForm, StepsBuildStepForm);
  Application.CreateForm(TStepsBuildScreenForm, StepsBuildScreenForm);
  Application.CreateForm(TStepsBuildImagesForm, StepsBuildImagesForm);
  Application.Run;
end.
