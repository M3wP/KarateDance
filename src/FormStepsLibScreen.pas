unit FormStepsLibScreen;

interface

uses
	System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
	FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.ListBox,
	FMX.StdCtrls, FMX.Layouts, FMX.Controls.Presentation, FMX.Objects,
	System.Generics.Collections, KrDnceUtilTypes;

type
	PC64Screen = ^TC64Screen;

	TValueData = record
		Value: Integer;
		Data: SmallInt;
	end;

	TValueDatum = array of TValueData;

	TChangeSink = class(TObject)
	protected
		FInTran: Boolean;

	public
		constructor Create; virtual;

		procedure Init; virtual; abstract;

		procedure BeginTran(const AIdent: string = ''); virtual; abstract;
		procedure EndTran; virtual; abstract;
		procedure AddValue(const AValue: Integer; const AData: SmallInt); virtual; abstract;

		property  InTran: Boolean read FInTran;
	end;

	TCursorSink = class(TChangeSink)
	private
		FClear: TBitmap;

	public
		constructor Create; override;
		destructor  Destroy; override;

		procedure Init; override;
		procedure BeginTran(const AIdent: string = ''); override;
		procedure EndTran; override;
		procedure AddValue(const AValue: Integer; const AData: SmallInt); override;
	end;

	TScreenSink = class(TChangeSink)
	public
		procedure Init; override;
		procedure BeginTran(const AIdent: string = ''); override;
		procedure EndTran; override;
		procedure AddValue(const AValue: Integer; const AData: SmallInt); override;
	end;

	TCustomTool = class;
	TCustomToolClass = class of TCustomTool;

	THistory = class(TObject)
		Ident: string;
		Tool: TCustomToolClass;
		ValueData: TValueDatum;
	end;

	TUndoSink = class(TChangeSink)
	protected
		FHistory: TList<THistory>;

	public
		constructor Create; override;
		destructor  Destroy; override;

		procedure Init; override;
		procedure BeginTran(const AIdent: string = ''); override;
		procedure EndTran; override;
		procedure AddValue(const AValue: Integer; const AData: SmallInt); override;
	end;

	TCustomTool = class(TObject)
	protected
		FMouseDown: Boolean;

	public
		constructor Create; virtual;

		class function  Ident: string; virtual; abstract;
		class function  AutoCapture: Boolean; virtual;

		class procedure Undo(const AValues: TValueDatum); virtual; abstract;

		procedure TrackMouse(const AScreenPos: Integer;
				const ASubPos: Byte; const AShift: TShiftState); virtual; abstract;
		procedure MouseDown(const AScreenPos: Integer;
				const ASubPos: Byte;
				const AButton: TMouseButton;
				const AShift: TShiftState); virtual; abstract;
		procedure MouseUp(const AScreenPos: Integer;
				const ASubPos: Byte;
				const AButton: TMouseButton;
				const AShift: TShiftState); virtual; abstract;
	end;

	TPencilTool = class(TCustomTool)
	private
		FButton: TMouseButton;

	public
		class function  Ident: string; override;
		class procedure Undo(const AValues: TValueDatum); override;

		procedure TrackMouse(const AScreenPos: Integer;
				const ASubPos: Byte; const AShift: TShiftState); override;
		procedure MouseDown(const AScreenPos: Integer;
				const ASubPos: Byte;
				const AButton: TMouseButton;
				const AShift: TShiftState); override;
		procedure MouseUp(const AScreenPos: Integer;
				const ASubPos: Byte;
				const AButton: TMouseButton;
				const AShift: TShiftState); override;
	end;

	TStepsLibScreenForm = class(TForm)
		Image1: TImage;
		Footer: TToolBar;
		Label1: TLabel;
		Label2: TLabel;
		Label3: TLabel;
		ToolBar1: TToolBar;
		ListBox1: TListBox;
		Button1: TButton;
		Button2: TButton;
		ComboBox1: TComboBox;
		ComboBox2: TComboBox;
		ComboBox3: TComboBox;
		Image2: TImage;
    ListBoxItem1: TListBoxItem;
    ListBoxItem2: TListBoxItem;
    ListBoxItem3: TListBoxItem;
    ListBoxItem4: TListBoxItem;
    ListBoxItem5: TListBoxItem;
    ListBoxItem6: TListBoxItem;
    ListBoxItem7: TListBoxItem;
    ListBoxItem8: TListBoxItem;
		procedure ComboBox3Change(Sender: TObject);
		procedure Image1MouseMove(Sender: TObject; Shift: TShiftState; X,
				Y: Single);
		procedure FormCreate(Sender: TObject);
		procedure Image1MouseLeave(Sender: TObject);
		procedure Image1MouseDown(Sender: TObject; Button: TMouseButton;
				Shift: TShiftState; X, Y: Single);
		procedure Image1MouseUp(Sender: TObject; Button: TMouseButton;
				Shift: TShiftState; X, Y: Single);
		procedure Button2Click(Sender: TObject);
		procedure FormDestroy(Sender: TObject);
	private
		FCursorSink: TCursorSink;
		FCurrTool: TCustomTool;

		procedure DoApplyGrid(ABitmap: TBitmap);

		procedure DoClearUndoHistory;

	protected
		FScreen: PC64Screen;
		FScreenSink: TScreenSink;
		FUndoSink: TUndoSink;

		procedure DoRebuildBitmap;

	public
		function  ShowEditScreen(var AScreen: TC64Screen): TModalResult;
	end;

var
	StepsLibScreenForm: TStepsLibScreenForm;

implementation

{$R *.fmx}

uses DModStepsLibMain;

{ TMovesBuildScreenForm }

procedure TStepsLibScreenForm.Button2Click(Sender: TObject);
	begin
	if  FUndoSink.FHistory.Count > 0 then
		begin
		FUndoSink.FHistory[FUndoSink.FHistory.Count - 1].Tool.Undo(
				FUndoSink.FHistory[FUndoSink.FHistory.Count - 1].ValueData);

		ListBox1.Items.Delete(ListBox1.Count - 1);

		FUndoSink.FHistory[FUndoSink.FHistory.Count - 1].Free;
		FUndoSink.FHistory.Delete(FUndoSink.FHistory.Count - 1);
		end;
	end;

procedure TStepsLibScreenForm.ComboBox3Change(Sender: TObject);
	begin
    DoRebuildBitmap;
	end;

procedure TStepsLibScreenForm.DoApplyGrid(ABitmap: TBitmap);
	var
	i: Integer;

	begin
	if  ComboBox3.ItemIndex = 1 then
		begin
		ABitmap.Canvas.BeginScene;
		try
			ABitmap.Canvas.Stroke.Color:= TAlphaColorRec.Silver;
			ABitmap.Canvas.Stroke.Kind:= TBrushKind.Solid;

			for i:= 0 to 79 do
				ABitmap.Canvas.DrawLine(PointF(i * 8, 0), PointF(i * 8, 400), 1);

			for i:= 0 to 49 do
				ABitmap.Canvas.DrawLine(PointF(0, i * 8), PointF(640, i * 8), 1);

			finally
			ABitmap.Canvas.EndScene;
			end;
		end
	else if ComboBox3.ItemIndex = 2 then
		begin
		ABitmap.Canvas.BeginScene;
		try
			ABitmap.Canvas.Stroke.Color:= TAlphaColorRec.Silver;
			ABitmap.Canvas.Stroke.Kind:= TBrushKind.Solid;

			for i:= 0 to 39 do
				ABitmap.Canvas.DrawLine(PointF(i * 16, 0), PointF(i * 16, 400), 1);

			for i:= 0 to 24 do
				ABitmap.Canvas.DrawLine(PointF(0, i * 16), PointF(640, i * 16), 1);

			finally
			ABitmap.Canvas.EndScene;
			end;
		end;
	end;

procedure TStepsLibScreenForm.DoClearUndoHistory;
	var
	i: Integer;

	begin
	for i:= FUndoSink.FHistory.Count - 1 downto 0 do
		FUndoSink.FHistory[i].Free;

	FUndoSink.FHistory.Clear;

	ListBox1.Items.Clear;
	end;

procedure TStepsLibScreenForm.DoRebuildBitmap;
	var
	b: TBitmap;

	begin
	b:= TBitmap.Create;
	b.Width:= 640;
	b.Height:= 400;

	C64ScreenPaint(FScreen^, b, 2);

	DoApplyGrid(b);

	Image1.Bitmap.Assign(b);
	end;

procedure TStepsLibScreenForm.FormCreate(Sender: TObject);
	begin
	FCursorSink:= TCursorSink.Create;
	FCursorSink.Init;

	FScreenSink:= TScreenSink.Create;
	FScreenSink.Init;

	FUndoSink:= TUndoSink.Create;
	FUndoSink.Init;

	FCurrTool:= TPencilTool.Create;
	Image1.AutoCapture:= FCurrTool.AutoCapture;
	end;

procedure TStepsLibScreenForm.FormDestroy(Sender: TObject);
	begin
	FCursorSink.Free;
	FScreenSink.Free;
	FUndoSink.Free;

	if  Assigned(FCurrTool) then
		FCurrTool.Free;
	end;

procedure TStepsLibScreenForm.Image1MouseDown(Sender: TObject;
		Button: TMouseButton; Shift: TShiftState; X, Y: Single);
	var
	p: Integer;
	s: Byte;
	sx,
	sy: Integer;

	begin
	if  (X < 0)
	or  (Y < 0) then
		begin
		p:= -1;
		s:= 0;
		end
	else
		begin
		sx:= Trunc(X / 8);
		sy:= Trunc(Y / 8);

		p:= Trunc(sy / 2) * 40 + Trunc(sx / 2);
		s:= 0;

		if  (sy mod 2) > 0 then
			begin
			if  (sx mod 2) > 0 then
				s:= 3
			else
				s:= 2
			end
		else if (sx mod 2) > 0 then
			begin
			if  (sy mod 2) > 0 then
				s:= 2
			else
				s:= 1
			end;
		end;

	FCurrTool.MouseDown(p, s, Button, Shift);
	end;

procedure TStepsLibScreenForm.Image1MouseLeave(Sender: TObject);
	begin
//	FCursorSink.EndTran;
	end;

procedure TStepsLibScreenForm.Image1MouseMove(Sender: TObject;
		Shift: TShiftState; X, Y: Single);
	var
	p: Integer;
	s: Byte;
	sx,
	sy: Integer;

	begin
	if  (X < 0)
	or  (Y < 0) then
		begin
		p:= -1;
		s:= 0;
		end
	else
		begin
		sx:= Trunc(X / 8);
		sy:= Trunc(Y / 8);

		p:= Trunc(sy / 2) * 40 + Trunc(sx / 2);
		s:= 0;

		if  (sy mod 2) > 0 then
			begin
			if  (sx mod 2) > 0 then
				s:= 3
			else
				s:= 2
			end
		else if (sx mod 2) > 0 then
			begin
			if  (sy mod 2) > 0 then
				s:= 2
			else
				s:= 1
			end;
		end;

	FCurrTool.TrackMouse(p, s, Shift);
	end;

procedure TStepsLibScreenForm.Image1MouseUp(Sender: TObject;
		Button: TMouseButton; Shift: TShiftState; X, Y: Single);
	var
	p: Integer;
	s: Byte;
	sx,
	sy: Integer;

	begin
	if  (X < 0)
	or  (Y < 0) then
		begin
		p:= -1;
		s:= 0;
		end
	else
		begin
		sx:= Trunc(X / 8);
		sy:= Trunc(Y / 8);

		p:= Trunc(sy / 2) * 40 + Trunc(sx / 2);
		s:= 0;

		if  (sy mod 2) > 0 then
			begin
			if  (sx mod 2) > 0 then
				s:= 3
			else
				s:= 2
			end
		else if (sx mod 2) > 0 then
			begin
			if  (sy mod 2) > 0 then
				s:= 2
			else
				s:= 1
			end;
		end;

	FCurrTool.MouseUp(p, s, Button, Shift);
	end;

function TStepsLibScreenForm.ShowEditScreen(
		var AScreen: TC64Screen): TModalResult;
	begin
	FScreen:= @AScreen;
	Image1.AutoCapture:= True;

	DoClearUndoHistory;
	DoRebuildBitmap;

	ComboBox2.ListItems[0].ImageIndex:= C64Palette[TC64Colour.Bkgrd0];
	ComboBox2.ListItems[1].ImageIndex:= C64Palette[TC64Colour.Multi1];
	ComboBox2.ListItems[2].ImageIndex:= C64Palette[TC64Colour.Multi2];
	ComboBox2.ListItems[3].ImageIndex:= C64Palette[TC64Colour.Frgrd3];

	Result:= ShowModal;
	end;

{ TChangeSink }

constructor TChangeSink.Create;
	begin
	inherited Create;

	end;

{ TCursorSink }

procedure TCursorSink.AddValue(const AValue: Integer; const AData: SmallInt);
	var
	x,
	y: Integer;

	begin
	if  not Assigned(StepsLibScreenForm.Image2.Bitmap) then
		Exit;

	if  not StepsLibScreenForm.Image2.Bitmap.Canvas.BeginScene then
		Exit;
	try
		StepsLibScreenForm.Image2.Bitmap.Canvas.Stroke.Kind:= TBrushKind.None;

		StepsLibScreenForm.Image2.Bitmap.Canvas.Fill.Kind:= TBrushKind.Solid;

		if  AData = 0 then
			StepsLibScreenForm.Image2.Bitmap.Canvas.Fill.Color:=
					TAlphaColorRec.Crimson
		else
			StepsLibScreenForm.Image2.Bitmap.Canvas.Fill.Color:=
					TAlphaColorRec.Forestgreen;

		x:= AValue mod 80;
		y:= AValue div 80;

		StepsLibScreenForm.Image2.Bitmap.Canvas.FillRect(
				RectF(x * 8, y * 8, x * 8 + 8, y * 8 + 8), 0, 0, [], 0.5);

		finally
		StepsLibScreenForm.Image2.Bitmap.Canvas.EndScene;
		StepsLibScreenForm.Image2.Repaint;
		end;
	end;

procedure TCursorSink.BeginTran(const AIdent: string);
	begin
	FInTran:= True;
	end;

constructor TCursorSink.Create;
	begin
	inherited;

	FClear:= TBitmap.Create;
	FClear.Width:= 640;
	FClear.Height:= 400;

	FClear.Clear(TAlphaColorRec.Null);
	end;

destructor TCursorSink.Destroy;
	begin
	FClear.Free;

	inherited;
	end;

procedure TCursorSink.EndTran;
	begin
	if  FInTran then
		StepsLibScreenForm.Image2.Bitmap.Assign(FClear);

	FInTran:= False;
	end;

procedure TCursorSink.Init;
	begin
	StepsLibScreenForm.Image2.Bitmap.Assign(FClear);
	end;

{ TCustomTool }

class function TCustomTool.AutoCapture: Boolean;
	begin
	Result:= True;
	end;

constructor TCustomTool.Create;
	begin
	inherited Create;
	end;

{ TScreenSink }

procedure TScreenSink.AddValue(const AValue: Integer; const AData: SmallInt);
	var
	i,
	x,
	y: Integer;

	begin
	if  FInTran then
		begin
		StepsLibScreenForm.FScreen[AValue]:= AData;

		if  not StepsLibScreenForm.Image1.Bitmap.Canvas.BeginScene then
			Exit;
		try
			x:= AValue mod 40;
			y:= AValue div 40;

			StepsLibScreenForm.Image1.Bitmap.Canvas.DrawBitmap(
					C64CharViews[AData], RectF(0, 0, 8, 8),
					RectF(x * 16, y * 16, x * 16 + 16, y * 16 + 16), 1);

			StepsLibScreenForm.Image1.Bitmap.Canvas.Stroke.Color:=
					TAlphaColorRec.Silver;
			StepsLibScreenForm.Image1.Bitmap.Canvas.Stroke.Kind:=
					TBrushKind.Solid;

			case StepsLibScreenForm.ComboBox3.ItemIndex of
				1:
					begin
					for i:= 1 to 2 do
						StepsLibScreenForm.Image1.Bitmap.Canvas.DrawLine(
								PointF(x * 16 + i * 8, y * 16),
								PointF(x * 16 + i * 8, y * 16 + 16), 1);

					for i:= 1 to 2 do
						StepsLibScreenForm.Image1.Bitmap.Canvas.DrawLine(
								PointF(x * 16, y * 16 + i * 8),
								PointF(x * 16 + 16, y * 16 + i * 8), 1);
					end;
				2:
					begin
					StepsLibScreenForm.Image1.Bitmap.Canvas.DrawLine(
							PointF(x * 16 + 16, y * 16),
							PointF(x * 16 + 16, y * 16 + 16), 1);

					StepsLibScreenForm.Image1.Bitmap.Canvas.DrawLine(
							PointF(x * 16, y * 16 + 16),
							PointF(x * 16 + 16, y * 16 + 16), 1);
					end;
				end;

			finally
			StepsLibScreenForm.Image1.Bitmap.Canvas.EndScene;
			StepsLibScreenForm.Image1.Repaint;
			end;
		end;
	end;

procedure TScreenSink.BeginTran(const AIdent: string);
	begin
	FInTran:= True;
	end;

procedure TScreenSink.EndTran;
	begin
	if  FInTran then
		StepsLibScreenForm.DoRebuildBitmap;

	FInTran:= False;
	end;

procedure TScreenSink.Init;
	begin

	end;

{ TUndoSink }

procedure TUndoSink.AddValue(const AValue: Integer; const AData: SmallInt);
	var
	h: THistory;

	begin
	if  FInTran then
		begin
		h:= FHistory[FHistory.Count - 1];

		SetLength(h.ValueData, Length(h.ValueData) + 1);
		h.ValueData[High(h.ValueData)].Value:= AValue;
		h.ValueData[High(h.ValueData)].Data:= AData;
		end;
	end;

procedure TUndoSink.BeginTran(const AIdent: string);
	var
	h: THistory;

	begin
	if  FInTran then
		Exit;

	h:= THistory.Create;

	h.Ident:= AIdent;
	h.Tool:= TCustomToolClass(StepsLibScreenForm.FCurrTool.ClassType);

	FHistory.Add(h);

	FInTran:= True;
	end;

constructor TUndoSink.Create;
	begin
	inherited Create;

	FHistory:= TList<THistory>.Create;

	end;

destructor TUndoSink.Destroy;
	var
	i: Integer;

	begin
	for i:= FHistory.Count - 1 downto 0 do
		FHistory.Items[i].Free;

	FHistory.Free;

	inherited;
	end;

procedure TUndoSink.EndTran;
	var
	l: TListBoxItem;

	begin
	if  not FInTran  then
		Exit;

	l:= TListBoxItem.Create(StepsLibScreenForm.ListBox1);
	l.Text:= FHistory.Items[FHistory.Count - 1].Ident;

	l.Parent:= StepsLibScreenForm.ListBox1;

	FInTran:= False;
	end;

procedure TUndoSink.Init;
	begin

	end;

{ TPencilTool }

class function TPencilTool.Ident: string;
	begin
	Result:= 'Pencil';
	end;

procedure TPencilTool.MouseDown(const AScreenPos: Integer; const ASubPos: Byte;
		const AButton: TMouseButton; const AShift: TShiftState);
	var
	c: Byte;
	l: TC64Colours;
	b: TC64Colours;

	begin
	if  FMouseDown then
		Exit;

	FButton:= AButton;

	if  FButton = TMouseButton.mbLeft then
		begin
		StepsLibScreenForm.FScreenSink.BeginTran('Pencil');
		StepsLibScreenForm.FUndoSink.BeginTran('Pencil');
		end
	else
		begin
		StepsLibScreenForm.FScreenSink.BeginTran('Eraser');
		StepsLibScreenForm.FUndoSink.BeginTran('Eraser');
		end;

	FMouseDown:= True;

	StepsLibScreenForm.FUndoSink.AddValue(AScreenPos,
			StepsLibScreenForm.FScreen[AScreenPos]);

	IndexToC64Colours(StepsLibScreenForm.FScreen[AScreenPos],
			l);


	if  FButton = TMouseButton.mbLeft then
		l[ASubPos]:= TC64Colour(StepsLibScreenForm.ComboBox2.ItemIndex)
	else
		begin
		IndexToC64Colours(C64Frames[0].Screen[AScreenPos], b);
		l[ASubPos]:= b[ASubPos];
		end;

	c:= C64ColorsToIndex(l);

	StepsLibScreenForm.FScreenSink.AddValue(AScreenPos, c);
	end;

procedure TPencilTool.MouseUp(const AScreenPos: Integer; const ASubPos: Byte;
		const AButton: TMouseButton; const AShift: TShiftState);
	begin
	if  not FMouseDown then
		Exit;

	StepsLibScreenForm.FScreenSink.EndTran;
	StepsLibScreenForm.FUndoSink.EndTran;

	FMouseDown:= False;
	end;

procedure TPencilTool.TrackMouse(const AScreenPos: Integer;
		const ASubPos: Byte; const AShift: TShiftState);
	var
	x,
	y: Integer;
	c: Byte;
	l: TC64Colours;
	b: TC64Colours;


	begin
	if  AScreenPos > -1 then
		begin
		StepsLibScreenForm.FCursorSink.EndTran;

		if  FMouseDown then
			begin
			StepsLibScreenForm.FUndoSink.AddValue(AScreenPos,
					StepsLibScreenForm.FScreen[AScreenPos]);

			IndexToC64Colours(StepsLibScreenForm.FScreen[AScreenPos],
					l);


			if  FButton = TMouseButton.mbLeft then
				l[ASubPos]:= TC64Colour(StepsLibScreenForm.ComboBox2.ItemIndex)
			else
				begin
				IndexToC64Colours(C64Frames[0].Screen[AScreenPos], b);
				l[ASubPos]:= b[ASubPos];
				end;

			c:= C64ColorsToIndex(l);

			StepsLibScreenForm.FScreenSink.AddValue(AScreenPos, c);

			c:= 1;
			end
		else
			begin
			c:= 0;
			end;

		StepsLibScreenForm.FCursorSink.BeginTran;

		x:= (AScreenPos mod 40) * 2;
		y:= (AScreenPos div 40) * 2;

		case ASubPos of
			1:
				Inc(x);
			2:
				Inc(y);
			3:
				begin
				Inc(x);
				Inc(y);
				end;
			end;

		StepsLibScreenForm.FCursorSink.AddValue(y * 80 + x, c);
		end
	else
		StepsLibScreenForm.FCursorSink.EndTran;
	end;

class procedure TPencilTool.Undo(const AValues: TValueDatum);
	var
	i: Integer;

	begin
	StepsLibScreenForm.FScreenSink.BeginTran('Undo');

	for i:= High(AValues) downto 0 do
		StepsLibScreenForm.FScreenSink.AddValue(AValues[i].Value,
				AValues[i].Data);

	StepsLibScreenForm.FScreenSink.EndTran;
	end;

end.
