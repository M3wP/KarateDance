unit FormDanceAnimNodes;

interface

uses
	System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
	FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
	FMX.Edit, FMX.EditBox, FMX.NumberBox, FMX.Controls.Presentation;

type
	TDanceAnimNodesForm = class(TForm)
		Label1: TLabel;
		Label2: TLabel;
		Label3: TLabel;
		NumberBox1: TNumberBox;
		RadioButton1: TRadioButton;
		Label4: TLabel;
		NumberBox2: TNumberBox;
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
		procedure NumberBox1Change(Sender: TObject);
		procedure RadioButton1Change(Sender: TObject);
	private

	public
		function ShowAddNodes(const AFrames: Boolean = False): TModalResult;
	end;

var
	DanceAnimNodesForm: TDanceAnimNodesForm;

implementation

{$R *.fmx}

uses
	DModDanceAnimMain, KrDnceUtilTypes;

{ TDanceAnimNodesForm }

procedure TDanceAnimNodesForm.NumberBox1Change(Sender: TObject);
	begin
	if  RadioButton1.IsChecked then
		begin
		if  NumberBox2.Value < NumberBox1.Value then
			NumberBox2.Value:= NumberBox1.Value + 1;

		NumberBox2.Min:= NumberBox1.Value + 1;
		end;
	end;

procedure TDanceAnimNodesForm.RadioButton1Change(Sender: TObject);
	begin
	NumberBox2.Enabled:= RadioButton1.IsChecked;
	end;

function TDanceAnimNodesForm.ShowAddNodes(const AFrames: Boolean): TModalResult;
	begin
	NumberBox1.Min:= 1;
	NumberBox2.Min:= 1;

	if  AFrames then
		begin
		Label3.Text:= 'Start Frame:';
		Label4.Text:= 'End Frame:';
		NumberBox1.Max:= Length(C64Frames);
		NumberBox2.Max:= Length(C64Frames);
		end
	else
		begin
		Label3.Text:= 'Start Step:';
		Label4.Text:= 'End Step:';
		NumberBox1.Max:= Length(C64Steps);
		NumberBox2.Max:= Length(C64Steps);
		end;

	RadioButton1.IsChecked:= False;
	RadioButton2.IsChecked:= True;

	Result:= ShowModal;
	end;

end.
