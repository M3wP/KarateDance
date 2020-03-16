program DanceAnimator;

uses
  System.StartUpCopy,
  FMX.Forms,
  FormDanceAnimMain in 'FormDanceAnimMain.pas' {DanceAnimMainForm},
  DModDanceAnimMain in 'DModDanceAnimMain.pas' {DanceAnimMainDMod: TDataModule},
  FormDanceAnimNodes in 'FormDanceAnimNodes.pas' {DanceAnimNodesForm},
  KrDnceGraphTypes in 'KrDnceGraphTypes.pas',
  KrDnceUtilTypes in 'KrDnceUtilTypes.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TDanceAnimMainDMod, DanceAnimMainDMod);
  Application.CreateForm(TDanceAnimMainForm, DanceAnimMainForm);
  Application.CreateForm(TDanceAnimNodesForm, DanceAnimNodesForm);
  Application.Run;
end.
