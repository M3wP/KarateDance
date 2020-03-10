unit FormStepsBuildMain;

interface

uses
	System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
	FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
	FMX.Controls.Presentation, System.Rtti, System.ImageList, FMX.ImgList,
	FMX.Layouts, FMX.ListBox, FMX.Objects, C64UtilTypes, FMX.TabControl;

type
	TStepsBuildForm = class(TForm)
		ImageList1: TImageList;
		OpenDialog1: TOpenDialog;
		TabControl1: TTabControl;
		TabItem1: TTabItem;
		Footer: TToolBar;
		Label1: TLabel;
		Label2: TLabel;
		Label3: TLabel;
		Image1: TImage;
		ListBox1: TListBox;
		Rectangle1: TRectangle;
		Line1: TLine;
		Rectangle2: TRectangle;
		Line2: TLine;
		Rectangle3: TRectangle;
		Line3: TLine;
		ToolBar1: TToolBar;
		Button2: TButton;
		TabItem2: TTabItem;
		Line4: TLine;
		Line5: TLine;
		Line6: TLine;
		Line7: TLine;
		ToolBar2: TToolBar;
		Button1: TButton;
		ListBox2: TListBox;
		ToolBar3: TToolBar;
		Label4: TLabel;
		Label5: TLabel;
		Label6: TLabel;
		Panel1: TPanel;
		Image2: TImage;
		ListBox3: TListBox;
		Button3: TButton;
		TrackBar1: TTrackBar;
		Label7: TLabel;
		Label8: TLabel;
		Label9: TLabel;
		Switch1: TSwitch;
		Label10: TLabel;
		Timer1: TTimer;
		ImageList2: TImageList;
		Switch2: TSwitch;
		Label11: TLabel;
		Switch3: TSwitch;
		Label12: TLabel;
		Label13: TLabel;
		Label14: TLabel;
		Switch4: TSwitch;
		Label15: TLabel;
		Button4: TButton;
		Button5: TButton;
		TabItem3: TTabItem;
		Panel2: TPanel;
		ToolBar4: TToolBar;
		Button6: TButton;
		Button7: TButton;
		Button8: TButton;
		Button9: TButton;
    SaveDialog1: TSaveDialog;
    OpenDialog2: TOpenDialog;
		procedure Button2Click(Sender: TObject);
		procedure ListBox1Change(Sender: TObject);
		procedure FormCreate(Sender: TObject);
		procedure Timer1Timer(Sender: TObject);
		procedure Switch1Switch(Sender: TObject);
		procedure Button1Click(Sender: TObject);
		procedure ListBox2Change(Sender: TObject);
		procedure ListBox3Change(Sender: TObject);
		procedure Switch3Switch(Sender: TObject);
		procedure TrackBar1Change(Sender: TObject);
		procedure Switch4Switch(Sender: TObject);
		procedure Button3Click(Sender: TObject);
		procedure Button5Click(Sender: TObject);
		procedure Button8Click(Sender: TObject);
		procedure Button9Click(Sender: TObject);
		procedure TabControl1Change(Sender: TObject);
		procedure Button4Click(Sender: TObject);
		procedure Button7Click(Sender: TObject);
		procedure Button6Click(Sender: TObject);
	private
		FBkGrnd: TC64Screen;

		FSelectedStep: Integer;
		FStepFrame: Integer;
		FStepFirst: Boolean;
		FStpFrmDelta: Integer;

		procedure DoDrawC64MultiChar(ABitmap: TBitmap; AX, AY: Integer;
				const AColours: TC64Colours);
		procedure DoUpdateStepsViews(AStep: Integer; AStart: Integer);
		procedure DoAddStepFrames(AStep: Integer);
		procedure DoUpdateFrame(AFrame: Integer; ABitmap: TBitmap;
				const AListItem: Integer = -1);

		procedure DoProjectNew(const ADefFrame: Boolean);

		function  DoImageListAdd(AImgList: TImageList;
				ABitmap: TBitmap): Integer;
		procedure DoImageListReplace(AImgList: TImageList;
				AIndex: Integer; ABitmap: TBitmap);

		procedure DoCalcFrameExtents(AFrame: Integer);

		procedure DoDisplayFrame(AFrame: Integer);
		procedure DoDisplayMove(AMove: Integer);

	public

	end;

var
	StepsBuildForm: TStepsBuildForm;

implementation

{$R *.fmx}

uses
	System.IOUtils, FMX.MultiResBitmap, FormStepsBuildStep, FormStepsBuildScreen;

const
	VAL_SIZ_FRAMEMS: array[0..12] of Cardinal = (
			1500, 1000, 750, 667, 500, 333, 250, 200, 150, 125, 100, 50, 25);


procedure TStepsBuildForm.Button1Click(Sender: TObject);
	var
	l: TListBoxItem;

	begin
	if  StepsBuildStepForm.ShowAddFrames(Length(C64Steps)) = mrOk then
		begin
		SetLength(C64Steps, Length(C64Steps) + 1);
		C64Steps[High(C64Steps)]:= TC64Step.Create;

		l:= TListBoxItem.Create(ListBox2);
		l.Text:= IntToStr(High(C64Steps) + 1);
		l.Tag:= High(C64Steps);

		l.Parent:= ListBox2;

		DoAddStepFrames(High(C64Steps));
		end;
	end;

procedure TStepsBuildForm.Button2Click(Sender: TObject);
	var
	f: TMemoryStream;
	i,
	s: Integer;
	b2: TBitmap;

	begin
	if  OpenDialog1.Execute then
		begin
		f:= TMemoryStream.Create;
		try
			f.LoadFromFile(OpenDialog1.FileName);

			if  (f.Size mod 1000) <> 0 then
				ShowMessage('Invalid Frames File!')
			else
				begin
				s:= Length(C64Frames);
				SetLength(C64Frames, s + f.Size div 1000);

				ListBox1.BeginUpdate;
				b2:= TBitmap.Create;
				try
//					ListBox1.Items.Clear;
//					ImageList1.Source.Clear;
//					ImageList1.ClearCache;

					b2.Width:= 320;
					b2.Height:= 200;

					for i:= s to High(C64Frames) do
						begin
						Move(PByte(f.Memory)[(i - s) * 1000],
								C64Frames[i].Screen[0], 1000);

						DoUpdateFrame(i, b2);

						DoImageListAdd(ImageList1, b2.CreateThumbnail(32, 32));
						end;

					finally
					b2.Free;
					ListBox1.EndUpdate;
					end;

//				SetLength(C64Steps, 0);
				end;

			finally
			f.Free;
			end;
		end;
	end;

procedure TStepsBuildForm.Button3Click(Sender: TObject);
	begin
	if  StepsBuildStepForm.ShowAddFrames(FSelectedStep) = mrOk then
		begin
		DoAddStepFrames(FSelectedStep);
		DoDisplayMove(FSelectedStep);
		end;
	end;

procedure TStepsBuildForm.Button4Click(Sender: TObject);
	var
	b2: TBitmap;

	begin
	if  Assigned(ListBox1.Selected) then
		begin
		SetLength(C64Frames, Length(C64Frames) + 1);

		C64Frames[High(C64Frames)]:= C64Frames[ListBox1.Selected.Tag];

		C64Frames[High(C64Frames)].GridView:= nil;
		C64Frames[High(C64Frames)].RefCount:= 0;

		ListBox1.BeginUpdate;
		b2:= TBitmap.Create;
		try
			b2.Width:= 320;
			b2.Height:= 200;

			DoUpdateFrame(High(C64Frames), b2);

			DoImageListAdd(ImageList1, b2.CreateThumbnail(32, 32));

			finally
			b2.Free;
			ListBox1.EndUpdate;
			end;
		end;
	end;

procedure TStepsBuildForm.Button5Click(Sender: TObject);
	var
	b2: TBitmap;

	begin
	if  Assigned(ListBox1.Selected) then
		begin
		StepsBuildScreenForm.ShowEditScreen(
				C64Frames[ListBox1.Selected.Tag].Screen);

		ListBox1.BeginUpdate;
		b2:= TBitmap.Create;
		try
			b2.Width:= 320;
			b2.Height:= 200;

			DoUpdateFrame(ListBox1.Selected.Tag, b2, ListBox1.Selected.Tag);

			DoImageListReplace(ImageList1, ListBox1.Selected.Tag,
					b2.CreateThumbnail(32, 32));

			finally
			b2.Free;
			ListBox1.EndUpdate;
			end;

		DoDisplayFrame(ListBox1.Selected.Tag);
		end;
	end;

procedure TStepsBuildForm.Button6Click(Sender: TObject);
	var
	i,
	j: Integer;
	b2: TBitmap;
	l: TListBoxItem;

	begin
	if  OpenDialog2.Execute then
		begin
		DoProjectNew(False);
		LoadProject(OpenDialog2.FileName);

		ListBox1.BeginUpdate;
		b2:= TBitmap.Create;
		try

			b2.Width:= 320;
			b2.Height:= 200;

			for i:= 0 to High(C64Frames) do
				begin
				DoUpdateFrame(i, b2);

				DoImageListAdd(ImageList1, b2.CreateThumbnail(32, 32));
				end;

			finally
			b2.Free;
			ListBox1.EndUpdate;
			end;

		ListBox2.Items.BeginUpdate;
		try
			for i:= 0 to High(C64Steps) do
				begin
				l:= TListBoxItem.Create(ListBox2);
				l.Text:= IntToStr(i + 1);
				l.Tag:= i;

				l.Parent:= ListBox2;

				if  C64Steps[i].Count > 0 then
					DoUpdateStepsViews(i, 0);

				for j:= 0 to C64Steps[i].Count - 1 do
					C64Frames[C64Steps[i].Items[j].Index].RefCount:=
							C64Frames[C64Steps[i].Items[j].Index].RefCount + 1;
				end;

			finally
			ListBox2.Items.EndUpdate;
			end;
		end;
	end;

procedure TStepsBuildForm.Button7Click(Sender: TObject);
	begin
	if  SaveDialog1.Execute then
		SaveProject(SaveDialog1.FileName);
	end;

procedure TStepsBuildForm.Button8Click(Sender: TObject);
	begin
	DoProjectNew(True);
	end;

procedure TStepsBuildForm.Button9Click(Sender: TObject);
	var
	c: TC64Cell;

	begin
	if  Assigned(ListBox3.Selected)
	and (FSelectedStep > -1) then
		begin
		c:= C64Steps[FSelectedStep].Items[ListBox3.Selected.Tag];
		C64Steps[FSelectedStep].Delete(ListBox3.Selected.Tag);

		C64Frames[c.Index].RefCount:= C64Frames[c.Index].RefCount - 1;

		c.Free;

		DoDisplayMove(FSelectedStep);
		end;
	end;

procedure TStepsBuildForm.DoDisplayFrame(AFrame: Integer);
	begin
	Image1.Bitmap.Assign(C64Frames[AFrame].GridView);

	Rectangle1.Position.X:= C64Frames[AFrame].StartX * 17;
	Rectangle1.Visible:= True;

	Label1.Text:= IntToStr(C64Frames[AFrame].StartX);

	Rectangle2.Position.X:= C64Frames[AFrame].EndX * 17;
	Rectangle2.Visible:= True;

	Label3.Text:= IntToStr(C64Frames[AFrame].EndX);

	Rectangle3.Position.X:= C64Frames[AFrame].MidX * 17;
	Rectangle3.Visible:= True;

	Label2.Text:= IntToStr(C64Frames[AFrame].MidX);

	Button5.Enabled:= (AFrame > 0) and (C64Frames[AFrame].RefCount <= 0);
	end;

procedure TStepsBuildForm.DoDisplayMove(AMove: Integer);
	var
	i: Integer;
	l: TListBoxItem;

	begin
//	Switch1.IsChecked:= False;

	FSelectedStep:= AMove;
	FStpFrmDelta:= 1;

	if  C64Steps[AMove].Count = 0 then
		begin
		FStepFrame:= -1;
		Switch1.Enabled:= False;

		Image2.Bitmap.Assign(nil);
		end
	else
		begin
		FStepFrame:= 0;
		Switch1.Enabled:= True;

		if  (not Switch3.IsChecked)
		and (Switch2.IsChecked) then
			Image2.Bitmap.Assign(C64Steps[AMove].Items[
					C64Steps[AMove].Count - 1].View)
		else
			Image2.Bitmap.Assign(C64Steps[AMove].Items[0].View);
		end;

	Switch1.IsChecked:= Switch1.IsChecked and Switch1.Enabled;

	ListBox3.Items.BeginUpdate;
	try
		ListBox3.Clear;

		ImageList2.Source.Clear;
		ImageList2.ClearCache;

		for i:= 0 to C64Steps[AMove].Count - 1 do
			begin
			DoImageListAdd(ImageList2,
					C64Steps[AMove].Items[i].View.CreateThumbnail(32, 32));

			l:= TListBoxItem.Create(ListBox3);
			l.ImageIndex:= i;
			l.ItemData.Text:= Format('%d (%3.3d)', [i + 1,
					C64Steps[AMove].Items[i].Index]);
			l.Tag:= i;

			l.Parent:= ListBox3;
			end;

		finally
		ListBox3.Items.EndUpdate;
		end;
	end;

procedure TStepsBuildForm.DoDrawC64MultiChar(ABitmap: TBitmap; AX, AY: Integer;
		const AColours: TC64Colours);
	var
	i: Integer;
	p: TAlphaColor;

	begin
	if  not ABitmap.Canvas.BeginScene then
		raise Exception.Create('Error updating bitmap!');
	try
		for i:= 0 to 3 do
			begin
			p:= TC64FrameClrs.Bkgrd0;
			case AColours[i] of
				TC64Colour.Multi1:
					p:= TC64FrameClrs.Multi1;
				TC64Colour.Multi2:
					p:= TC64FrameClrs.Multi2;
				TC64Colour.Frgrd3:
					p:= TC64FrameClrs.Frgrd3;
				end;

			ABitmap.Canvas.Stroke.Color:= TAlphaColorRec.Null;
			ABitmap.Canvas.Stroke.Dash:= TStrokeDash.Solid;

			ABitmap.Canvas.Fill.Color:= p;
			ABitmap.Canvas.Fill.Kind:= TBrushKind.Solid;

			case i of
				0:
					ABitmap.Canvas.FillRect(RectF(0, 0, 4, 4), 0, 0, [], 1);
				1:
					ABitmap.Canvas.FillRect(RectF(4, 0, 8, 4), 0, 0, [], 1);
				2:
					ABitmap.Canvas.FillRect(RectF(0, 4, 4, 8), 0, 0, [], 1);
				3:
					ABitmap.Canvas.FillRect(RectF(4, 4, 8, 8), 0, 0, [], 1);
				end;
			end;

		finally
		ABitmap.Canvas.EndScene;
		end;
	end;

function TStepsBuildForm.DoImageListAdd(AImgList: TImageList;
		ABitmap: TBitmap): Integer;
	const
	SCALE = 1;

	var
	vSource: TCustomSourceItem;
	vBitmapItem: TCustomBitmapItem;
	vDest: TCustomDestinationItem;
	vLayer: TLayer;

	begin
	Result := -1;
	if (ABitmap.Width = 0)
	or (ABitmap.Height = 0) then
		Exit;

//	add source bitmap
	vSource:= AImgList.Source.Add;
	vSource.MultiResBitmap.TransparentColor:= TColorRec.Fuchsia;
	vSource.MultiResBitmap.SizeKind:= TSizeKind.Source;
	vSource.MultiResBitmap.Width:= Round(aBitmap.Width / SCALE);
	vSource.MultiResBitmap.Height:= Round(aBitmap.Height / SCALE);

	vBitmapItem := vSource.MultiResBitmap.ItemByScale(SCALE, True, True);

	if vBitmapItem = nil then
		begin
		vBitmapItem:= vSource.MultiResBitmap.Add;
		vBitmapItem.Scale:= Scale;
		end;

	vBitmapItem.Bitmap.Assign(ABitmap);

	vDest:= AImgList.Destination.Add;
	vLayer:= vDest.Layers.Add;
	vLayer.SourceRect.Rect:= TRectF.Create(TPoint.Zero, vSource.MultiResBitmap.Width,
			vSource.MultiResBitmap.Height);
	vLayer.Name:= vSource.Name;
	Result:= vDest.Index;
	end;

procedure TStepsBuildForm.DoImageListReplace(AImgList: TImageList;
		AIndex: Integer; ABitmap: TBitmap);
	const
	SCALE = 1;

	var
	vSource: TCustomSourceItem;
	vBitmapItem: TCustomBitmapItem;
	vDest: TCustomDestinationItem;
	vLayer: TLayer;

	begin
	if (ABitmap.Width = 0)
	or (ABitmap.Height = 0) then
		Exit;

//	replace source bitmap
	vSource:= AImgList.Source.Items[AIndex];
	vBitmapItem := vSource.MultiResBitmap.ItemByScale(SCALE, True, True);

	if vBitmapItem = nil then
		begin
		vBitmapItem:= vSource.MultiResBitmap.Add;
		vBitmapItem.Scale:= Scale;
		end;

	vBitmapItem.Bitmap.Assign(ABitmap);

	vDest:= AImgList.Destination.Items[AIndex];
	vLayer:= vDest.Layers.Items[0];
	vLayer.SourceRect.Rect:= TRectF.Create(TPoint.Zero, vSource.MultiResBitmap.Width,
			vSource.MultiResBitmap.Height);
	vLayer.Name:= vSource.Name;
	end;

procedure TStepsBuildForm.DoProjectNew(const ADefFrame: Boolean);
	var
	b2: TBitmap;
	i,
	j: Integer;
	c: TC64Cell;

	begin
	ImageList1.Source.Clear;
	ImageList1.Destination.Clear;

	ListBox1.Items.BeginUpdate;
	b2:= TBitmap.Create;
	try
		ListBox1.Items.Clear;

		b2.Width:= 320;
		b2.Height:= 200;

		if  ADefFrame then
			begin
			SetLength(C64Frames, 1);

			DoUpdateFrame(0, b2);
			DoImageListAdd(ImageList1, b2.CreateThumbnail(32, 32));
			end;

		finally
		b2.Free;
		ListBox1.Items.EndUpdate;
		end;

	ImageList2.Source.Clear;
	ImageList2.Destination.Clear;

	ListBox2.Items.Clear;

	ListBox3.Items.Clear;

	for i:= High(C64Steps) downto 0 do
		begin
		for j:= C64Steps[i].Count - 1 downto 0 do
			begin
			c:= C64Steps[i].Items[j];
			C64Steps[i].Delete(j);
			c.Free;
			end;

		C64Steps[i].Free;
		end;

	SetLength(C64Steps, 0);
	end;

procedure TStepsBuildForm.DoUpdateFrame(AFrame: Integer; ABitmap: TBitmap;
		const AListItem: Integer);
	var
	j,
	x,
	y: Integer;
	b3: TBitmap;
	l: TListBoxItem;

	begin
	b3:= TBitmap.Create;

	b3.Width:= 680;
	b3.Height:= 425;
	b3.Clear(TAlphaColorRec.Silver);

	if  AFrame > 0 then
		DoCalcFrameExtents(AFrame)
	else
		begin
		Move(FBkGrnd[0], C64Frames[AFrame].Screen[0], 1000);
		C64Frames[AFrame].StartX:= 0;
		C64Frames[AFrame].EndX:= 39;
		C64Frames[AFrame].MidX:= 19;
		end;

	C64ScreenPaint(C64Frames[AFrame].Screen, ABitmap);

	b3.Canvas.BeginScene;
	try
		for j:= 0 to 999 do
			begin
			x:= j mod 40;
			y:= j div 40;

			b3.Canvas.DrawBitmap(C64CharViews[C64Frames[AFrame].Screen[j]],
					RectF(0, 0, 8, 8),
					RectF(x * 17, y * 17, x * 17 + 16, y * 17 + 16), 1);
//					b3.Canvas.FillText(RectF(x * 17, y * 17, x * 17 + 16,
//							y * 17 + 16), IntToStr(FFrames[i].Screen[j]),
//							False, 1, [], TTextAlign.Center);
			end;

		finally
		b3.Canvas.EndScene;
		end;

	C64Frames[AFrame].GridView:= b3;

//	ImageControl1.Bitmap.Assign(b3);
//	ImageControl1.Repaint;
//	Application.ProcessMessages;

	if  AListItem = -1 then
		begin
		l:= TListBoxItem.Create(ListBox1);
		l.ItemData.Text:= Format('Frame: %3.3d', [AFrame]);
		l.ImageIndex:= AFrame;
		l.Tag:= AFrame;

		l.Parent:= ListBox1;
		end;
	end;

procedure TStepsBuildForm.DoUpdateStepsViews(AStep: Integer; AStart: Integer);
	var
	i,
	s,
	e,
	f: Integer;
	d: TC64ScreenDiff;
	c: TC64Screen;

	begin
	s:= AStart;
	e:= C64Steps[AStep].Count - 1;

	if  s > e then
		Exit;

	for i:= s to e do
		begin
		f:= C64Steps[AStep].Items[i].Index;

		C64ScreenDiff(C64Frames[0].Screen, C64Frames[f].Screen, d);

		Move(C64Frames[0].Screen[0], c[0], SizeOf(TC64Screen));
		C64ScreenCopyRecMask(C64Frames[f].Screen, c, d,
				Rect(C64Frames[f].StartX, 0, C64Frames[f].EndX + 1, 25),
				C64Steps[AStep].Items[i].Offset, 0);

		C64ScreenPaint(c, C64Steps[AStep].Items[i].View);
		end;
	end;

procedure TStepsBuildForm.FormCreate(Sender: TObject);
	var
	c: TC64Colours;
	i,
	j: Integer;

	begin
	FSelectedStep:= -1;
	FStpFrmDelta:= 1;

	for i:= 0 to 255 do
		begin
		C64CharViews[i]:= TBitmap.Create;
		C64CharViews[i].Width:= 8;
		C64CharViews[i].Height:= 8;

		IndexToC64Colours(i, c);
		DoDrawC64MultiChar(C64CharViews[i], 0, 0, c);
		end;

	FillChar(FBkGrnd[0], SizeOf(TC64Screen), 0);

	for i:= 0 to 39 do
		FBkGrnd[17 * 40 + i]:= 10;

	for i:= 0 to 6 do
		for j:= 0 to 39 do
			FBkGrnd[18 * 40 + i * 40 + j]:= 170;

	Button8Click(Self);
	end;

procedure TStepsBuildForm.DoAddStepFrames(AStep: Integer);
	var
	j: Integer;
	s,
	e,
	o: Integer;
	c: TC64Cell;

	begin
	s:= C64Steps[AStep].Count;

	if  StepsBuildStepForm.RadioButton1.IsChecked then
		begin
//		SetLength(C64Steps[AMove].Frames, s +
//				Trunc(StepsBuildStepForm.NumberBox2.Value) -
//				Trunc(StepsBuildStepForm.NumberBox1.Value) + 1);

		for j:= Trunc(StepsBuildStepForm.NumberBox1.Value) to
				 Trunc(StepsBuildStepForm.NumberBox2.Value) do
			begin
			c:= TC64Cell.Create;
			c.Kind:= cckFrame;
			c.Index:= j;

			C64Steps[AStep].Add(c);

			C64Frames[j].RefCount:= C64Frames[j].RefCount + 1;
			end;
		end
	else
		begin
		c:= TC64Cell.Create;
		c.Kind:= cckFrame;
		c.Index:= Trunc(StepsBuildStepForm.NumberBox1.Value);

		C64Frames[Trunc(StepsBuildStepForm.NumberBox1.Value)].RefCount:=
				C64Frames[Trunc(StepsBuildStepForm.NumberBox1.Value)].RefCount + 1;

		C64Steps[AStep].Add(c);
		end;

	if  s = 0 then
		o:= 19 - C64Frames[C64Steps[AStep].Items[0].Index].MidX
	else
		if  StepsBuildStepForm.RadioButton2.IsChecked then
			o:= C64Steps[AStep].Items[C64Steps[AStep].Count - 1].Offset
		else if StepsBuildStepForm.RadioButton3.IsChecked then
			o:= C64Frames[C64Steps[AStep].Items[C64Steps[AStep].Count - 1].Index].MidX -
				C64Frames[C64Steps[AStep].Items[C64Steps[AStep].Count - 1].Index + 1].MidX
		else if StepsBuildStepForm.RadioButton4.IsChecked then
			o:= 19 - C64Frames[C64Steps[AStep].Items[s + 1].Index].MidX
		else
			o:= Trunc(StepsBuildStepForm.NumberBox3.Value);

//	s:= Length(C64Steps[AMove].Offsets);
	e:= C64Steps[AStep].Count - 1;

//	SetLength(C64Steps[AMove].Offsets, Length(C64Steps[AMove].Frames));

	if  s <= e then
		for j:= s to e do
			C64Steps[AStep].Items[j].Offset:= o;

	DoUpdateStepsViews(AStep, s);
	end;

procedure TStepsBuildForm.DoCalcFrameExtents(AFrame: Integer);
	var
	f: Boolean;
	x,
	y: Integer;
	i: Integer;

	begin
	C64Frames[AFrame].StartX:= 0;
	f:= False;
	for x:= 0 to 39 do
		begin
		for y:= 0 to 24 do
			begin
			i:= y * 40 + x;

			if  not (C64Frames[AFrame].Screen[i] in [0, 10, 170]) then
				begin
				C64Frames[AFrame].StartX:= x;
				f:= True;
				Break;
				end;
			end;

		if  f then
			Break;
		end;

	C64Frames[AFrame].EndX:= 39;
	f:= False;
	for x:= 39 downto 0 do
		begin
		for y:= 0 to 24 do
			begin
			i:= y * 40 + x;

			if  not (C64Frames[AFrame].Screen[i] in [0, 10, 170]) then
				begin
				C64Frames[AFrame].EndX:= x;
				f:= True;
				Break;
				end;
			end;

		if  f then
			Break;
		end;

	C64Frames[AFrame].MidX:=
			Trunc((C64Frames[AFrame].EndX - C64Frames[AFrame].StartX) / 2) +
			C64Frames[AFrame].StartX;
	end;

procedure TStepsBuildForm.ListBox1Change(Sender: TObject);
	begin
	if  Assigned(ListBox1.Selected) then
		DoDisplayFrame(ListBox1.Selected.Tag);
	end;

procedure TStepsBuildForm.ListBox2Change(Sender: TObject);
	begin
	if  Assigned(ListBox2.Selected) then
		DoDisplayMove(ListBox2.Selected.Tag);
	end;

procedure TStepsBuildForm.ListBox3Change(Sender: TObject);
	begin
	if  (FSelectedStep > -1)
	and (not Switch1.IsChecked)
	and (Assigned(ListBox3.Selected)) then
		begin
		FStepFrame:= ListBox3.Selected.Tag;
		Image2.Bitmap.Assign(C64Steps[FSelectedStep].Items[FStepFrame].View);
		end;
	end;

procedure TStepsBuildForm.Switch1Switch(Sender: TObject);
	begin
	Timer1.Enabled:= Switch1.IsChecked;
	FStepFirst:= Switch1.IsChecked and (not FStepFirst);
	end;

procedure TStepsBuildForm.Switch3Switch(Sender: TObject);
	begin
	Switch2.Enabled:= not Switch3.IsChecked;
	end;

procedure TStepsBuildForm.Switch4Switch(Sender: TObject);
	begin
	if  Switch4.IsChecked then
		begin
		Switch3.Enabled:= False;
		end
	else
		begin
		Switch3.Enabled:= True;
		end;
	end;

procedure TStepsBuildForm.TabControl1Change(Sender: TObject);
	begin
	if  (TabControl1.ActiveTab = TabItem1)
	and Assigned(ListBox1.Selected) then
		DoDisplayFrame(ListBox1.Selected.Tag);

	end;

procedure TStepsBuildForm.Timer1Timer(Sender: TObject);
	begin
	if  Switch4.IsChecked
	and (not FStepFirst) then
		if  Switch2.IsChecked then
			begin
			if  FStepFrame = 0 then
				begin
				Switch1.IsChecked:= False;
				Timer1.Enabled:= False;
				Exit;
				end;
			end
		else
			if  FStepFrame = C64Steps[FSelectedStep].Count - 1 then
				begin
				Switch1.IsChecked:= False;
				Timer1.Enabled:= False;
				Exit;
				end;

	FStepFirst:= False;

	if  Switch3.IsChecked then
		FStepFrame:= FStepFrame + FStpFrmDelta
	else if Switch2.IsChecked then
		Dec(FStepFrame)
	else
		Inc(FStepFrame);

	if  FStepFrame > C64Steps[FSelectedStep].Count - 1 then
		if  Switch3.IsChecked then
			begin
			FStepFrame:= Pred(C64Steps[FSelectedStep].Count - 1);
			FStpFrmDelta:= -1;
			end
		else
			FStepFrame:= 0;

	if  FStepFrame < 0 then
		if  Switch3.IsChecked then
			begin
			FStepFrame:= 1;
			FStpFrmDelta:= 1;
			end
		else
			FStepFrame:= C64Steps[FSelectedStep].Count - 1;

	Image2.Bitmap.Assign(C64Steps[FSelectedStep].Items[FStepFrame].View);
	Label14.Text:= IntToStr(FStepFrame + 1) + '/' +
			IntToStr(C64Steps[FSelectedStep].Count) + ' ' +
			IntToStr(C64Steps[FSelectedStep].Items[FStepFrame].Offset);
	end;

procedure TStepsBuildForm.TrackBar1Change(Sender: TObject);
	begin
	Timer1.Interval:= VAL_SIZ_FRAMEMS[Trunc(TrackBar1.Value)];
	Label13.Text:= IntToStr(VAL_SIZ_FRAMEMS[Trunc(TrackBar1.Value)]);
	end;

end.
