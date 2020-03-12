unit FormStepsLibStep;

interface

uses
	System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
	FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
	FMX.Edit, FMX.EditBox, FMX.NumberBox, FMX.Controls.Presentation;

type
	TStepsLibStepForm = class(TForm)
		Label1: TLabel;
		Label2: TLabel;
		Label3: TLabel;
		NumberBox1: TNumberBox;
		RadioButton1: TRadioButton;
		Label4: TLabel;
		NumberBox2: TNumberBox;
		Label5: TLabel;
		Label6: TLabel;
		RadioButton2: TRadioButton;
		Label7: TLabel;
		RadioButton3: TRadioButton;
		RadioButton4: TRadioButton;
		RadioButton5: TRadioButton;
		Label8: TLabel;
		Label9: TLabel;
		Button1: TButton;
		Button2: TButton;
		NumberBox3: TNumberBox;
		procedure RadioButton1Change(Sender: TObject);
		procedure NumberBox1Change(Sender: TObject);
	private
		{ Private declarations }
	public
		function ShowAddFrames(const AMove: Integer): TModalResult;
	end;

var
	StepsLibStepForm: TStepsLibStepForm;

implementation

{$R *.fmx}

uses
	KrDnceUtilTypes, DModStepsLibMain;


procedure TStepsLibStepForm.NumberBox1Change(Sender: TObject);
	begin
	if  RadioButton1.IsChecked then
		begin
		if  NumberBox2.Value < NumberBox1.Value then
			NumberBox2.Value:= NumberBox1.Value + 1;

		NumberBox2.Min:= NumberBox1.Value + 1;
		end;
	end;

procedure TStepsLibStepForm.RadioButton1Change(Sender: TObject);
	begin
	NumberBox2.Enabled:= RadioButton1.IsChecked;
	end;

function TStepsLibStepForm.ShowAddFrames(const AMove: Integer): TModalResult;
	begin
	Label9.Text:= IntToStr(AMove + 1);

	NumberBox1.Min:= 1;
	NumberBox1.Max:= High(C64Frames);

	RadioButton1.IsChecked:= False;

	NumberBox2.Min:= 1;
	NumberBox2.Max:= High(C64Frames);

	if  High(C64Steps) >= AMove then
		Label6.Text:= IntToStr(C64Steps[AMove].Count)
	else
		Label6.Text:= '0';

	if  (High(C64Steps) < AMove)
	or  (C64Steps[AMove].Count = 0) then
		begin
		RadioButton4.IsChecked:= True;
		RadioButton2.Enabled:= False;
		RadioButton3.Enabled:= False;
		RadioButton4.Enabled:= False;
		RadioButton5.Enabled:= False;
		end
	else
		begin
		RadioButton2.IsChecked:= True;
		RadioButton2.Enabled:= True;
		RadioButton3.Enabled:= True;
		RadioButton4.Enabled:= True;
		RadioButton5.Enabled:= True;
		end;

	Result:= ShowModal;
	end;

end.
