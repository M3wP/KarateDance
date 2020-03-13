unit FormStepsLibMain;

interface

uses
	System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
	FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
	FMX.Controls.Presentation, System.Rtti, System.ImageList, FMX.ImgList,
	FMX.Layouts, FMX.ListBox, FMX.Objects, KrDnceUtilTypes, FMX.TabControl;

type
	TStepsLibMainForm = class(TForm)
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
		Button10: TButton;
		SaveDialog2: TSaveDialog;
		Button11: TButton;
		Label16: TLabel;
		Label17: TLabel;
		ComboBox1: TComboBox;
		Button12: TButton;
		Label18: TLabel;
		Button13: TButton;
		Button14: TButton;
		Image3: TImage;
		Label19: TLabel;
		Label20: TLabel;
		Label21: TLabel;
		Label22: TLabel;
		Label23: TLabel;
		ComboBox2: TComboBox;
		ComboBox3: TComboBox;
		ComboBox4: TComboBox;
		ComboBox5: TComboBox;
		OpenDialog3: TOpenDialog;
    ImageList3: TImageList;
    ImageList4: TImageList;
    StyleBook1: TStyleBook;
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
		procedure Button10Click(Sender: TObject);
		procedure Button11Click(Sender: TObject);
		procedure FormDestroy(Sender: TObject);
		procedure ComboBox2Change(Sender: TObject);
		procedure Button12Click(Sender: TObject);
		procedure Button13Click(Sender: TObject);
		procedure Button14Click(Sender: TObject);
	private
		FLoading: Boolean;
		FBkGrnd: TC64Screen;

		FSelectedStep: Integer;
		FStepFrame: Integer;
		FStepFirst: Boolean;
		FStpFrmDelta: Integer;

		procedure DoUpdateStepsViews(AStep: Integer; AStart: Integer);
		procedure DoAddStepFrames(AStep: Integer);
		procedure DoUpdateFrame(AFrame: Integer; ABitmap: TBitmap;
				const AListItem: Integer = -1);

		procedure DoGenerateBkgdFrame(const AIndex: Integer);
		procedure DoRebuildBackgroundFrame;

		procedure DoLibraryNew(const ADefFrame: Boolean);

		procedure DoCalcFrameExtents(AFrame: Integer);

		procedure DoDisplayFrame(AFrame: Integer);
		procedure DoDisplayStep(AStep: Integer);

	public

	end;

var
	StepsLibMainForm: TStepsLibMainForm;

implementation

{$R *.fmx}

uses
	System.IOUtils, KrDnceGraphTypes, FMX.MultiResBitmap, FormStepsLibStep,
	FormStepsLibScreen, FormStepsLibImages;

const
	VAL_SIZ_FRAMEMS: array[0..12] of Cardinal = (
			1500, 1000, 750, 667, 500, 333, 250, 200, 150, 125, 100, 50, 25);


procedure TStepsLibMainForm.Button10Click(Sender: TObject);
	var
	i: Integer;
	s: TC64Screen;
	b1,
	b2: TBitmap;

	begin
	if  StepsLibImagesForm.ShowAddImages = mrOk then
		begin
		ListBox1.BeginUpdate;
		b2:= TBitmap.Create;
		try
			b2.Width:= 320;
			b2.Height:= 200;

			for i:= 0 to StepsLibImagesForm.ImageCount - 1 do
				try
					StepsLibImagesForm.ImageToScreen(i, s);

					SetLength(C64Frames, Length(C64Frames) + 1);

					Move(s[0], C64Frames[High(C64Frames)].Screen[0], 1000);
					DoUpdateFrame(High(C64Frames), b2);

					b1:= b2.CreateThumbnail(32, 32);
					ImageListAdd(ImageList1, b1);
					b1.Free;

					except;
					end;

			finally
			b2.Free;
			ListBox1.EndUpdate;
			end;
		end;
	end;

procedure TStepsLibMainForm.Button11Click(Sender: TObject);
	var
	b: TBitmap;

	begin
	if  Assigned(ListBox1.Selected) then
		if  SaveDialog2.Execute then
			begin
			b:= TBitmap.Create;
			try
				b.Width:= 320;
				b.Height:= 200;

				C64ScreenPaint(C64Frames[ListBox1.Selected.Tag].Screen, b);

				b.SaveToFile(SaveDialog2.FileName);

				finally
				b.Free;
				end;
			end;
	end;

procedure TStepsLibMainForm.Button12Click(Sender: TObject);
	begin
	DoGenerateBkgdFrame(ComboBox1.ItemIndex);
	DoRebuildBackgroundFrame;
	end;

procedure TStepsLibMainForm.Button13Click(Sender: TObject);
	var
	f: TMemoryStream;

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
				Move(PByte(f.Memory)[0], FBkGrnd[0], SizeOf(TC64Screen));
				DoRebuildBackgroundFrame;
				end;

			finally
			f.Free;
			end;
		end;
	end;

procedure TStepsLibMainForm.Button14Click(Sender: TObject);
	var
	b: TBitmap;

	begin
	if  OpenDialog3.Execute then
		begin
		b:= TBitmap.CreateFromFile(OpenDialog3.FileName);
		try
			StepsLibImagesForm.Clear;
			StepsLibImagesForm.AddImage(TPath.GetFileName(OpenDialog3.FileName),
					b);

			finally
			b.Free;
			end;

		if  StepsLibImagesForm.ShowAddImages(True) = mrOk then
			begin
			StepsLibImagesForm.ImageToScreen(0, FBkGrnd);
			DoRebuildBackgroundFrame;
			end;
		end;
	end;

procedure TStepsLibMainForm.Button1Click(Sender: TObject);
	var
	l: TListBoxItem;

	begin
	if  StepsLibStepForm.ShowAddFrames(Length(C64Steps)) = mrOk then
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

procedure TStepsLibMainForm.Button2Click(Sender: TObject);
	var
	f: TMemoryStream;
	i,
	s: Integer;
	b1,
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

						b1:= b2.CreateThumbnail(32, 32);
						ImageListAdd(ImageList1, b1);
						b1.Free;
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

procedure TStepsLibMainForm.Button3Click(Sender: TObject);
	begin
	if  StepsLibStepForm.ShowAddFrames(FSelectedStep) = mrOk then
		begin
		DoAddStepFrames(FSelectedStep);
		DoDisplayStep(FSelectedStep);
		end;
	end;

procedure TStepsLibMainForm.Button4Click(Sender: TObject);
	var
	b1,
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

			b1:= b2.CreateThumbnail(32, 32);
			ImageListAdd(ImageList1, b1);
			b1.Free;

			finally
			b2.Free;
			ListBox1.EndUpdate;
			end;
		end;
	end;

procedure TStepsLibMainForm.Button5Click(Sender: TObject);
	var
	b1,
	b2: TBitmap;

	begin
	if  Assigned(ListBox1.Selected) then
		begin
		StepsLibScreenForm.ShowEditScreen(
				C64Frames[ListBox1.Selected.Tag].Screen);

		ListBox1.BeginUpdate;
		b2:= TBitmap.Create;
		try
			b2.Width:= 320;
			b2.Height:= 200;

			DoUpdateFrame(ListBox1.Selected.Tag, b2, ListBox1.Selected.Tag);

			b1:= b2.CreateThumbnail(32, 32);
			ImageListReplace(ImageList1, ListBox1.Selected.Tag, b1);
			b1.Free;

			finally
			b2.Free;
			ListBox1.EndUpdate;
			end;

		DoDisplayFrame(ListBox1.Selected.Tag);
		end;
	end;

procedure TStepsLibMainForm.Button6Click(Sender: TObject);
	var
	i,
	j: Integer;
	b1,
	b2: TBitmap;
	l: TListBoxItem;

	begin
	if  OpenDialog2.Execute then
		begin
		DoLibraryNew(False);

		FLoading:= True;

		LoadLibrary(OpenDialog2.FileName);

		C64CharsetRebuild;
		Move(C64Frames[0].Screen[0], FBkGrnd[0], SizeOf(TC64Screen));

		Panel2.Enabled:= Length(C64Frames) = 1;

		ComboBox2.ItemIndex:= C64Palette[TC64Colour.Bkgrd0];
		ComboBox3.ItemIndex:= C64Palette[TC64Colour.Multi1];
		ComboBox4.ItemIndex:= C64Palette[TC64Colour.Multi2];
		ComboBox5.ItemIndex:= C64Palette[TC64Colour.Frgrd3];

		ListBox1.BeginUpdate;
		b2:= TBitmap.Create;
		try

			b2.Width:= 320;
			b2.Height:= 200;

			for i:= 0 to High(C64Frames) do
				begin
				DoUpdateFrame(i, b2);

				b1:= b2.CreateThumbnail(32, 32);
				ImageListAdd(ImageList1, b1);
				b1.Free;

				if  i = 0 then
					begin
					Image3.Bitmap.Width:= 320;
					Image3.Bitmap.Height:= 200;
					Image3.Bitmap.CopyFromBitmap(b2);
					end;
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

		FLoading:= False;
		end;
	end;

procedure TStepsLibMainForm.Button7Click(Sender: TObject);
	begin
	if  SaveDialog1.Execute then
		SaveLibrary(SaveDialog1.FileName);
	end;

procedure TStepsLibMainForm.Button8Click(Sender: TObject);
	begin
	DoLibraryNew(True);
	end;

procedure TStepsLibMainForm.Button9Click(Sender: TObject);
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

		DoDisplayStep(FSelectedStep);
		end;
	end;

procedure TStepsLibMainForm.ComboBox2Change(Sender: TObject);
	var
	c: TComboBox;

	begin
	if  not FLoading then
		begin
		c:= TComboBox(Sender);

		C64Palette[TC64Colour(c.Tag)]:= c.ItemIndex;

		C64CharsetRebuild;
		DoRebuildBackgroundFrame;
		end;
	end;

procedure TStepsLibMainForm.DoDisplayFrame(AFrame: Integer);
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

procedure TStepsLibMainForm.DoDisplayStep(AStep: Integer);
	var
	i: Integer;
	l: TListBoxItem;
	b1: TBitmap;

	begin
//	Switch1.IsChecked:= False;

	FSelectedStep:= AStep;
	FStpFrmDelta:= 1;

	if  C64Steps[AStep].Count = 0 then
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
			Image2.Bitmap.Assign(C64Steps[AStep].Items[
					C64Steps[AStep].Count - 1].View)
		else
			Image2.Bitmap.Assign(C64Steps[AStep].Items[0].View);
		end;

	Switch1.IsChecked:= Switch1.IsChecked and Switch1.Enabled;

	ListBox3.Items.BeginUpdate;
	try
		ListBox3.Clear;

		ImageList2.Source.Clear;
		ImageList2.ClearCache;

		for i:= 0 to C64Steps[AStep].Count - 1 do
			begin
			b1:= C64Steps[AStep].Items[i].View.CreateThumbnail(32, 32);
			ImageListAdd(ImageList2, b1);
			b1.Free;

			l:= TListBoxItem.Create(ListBox3);
			l.ImageIndex:= i;
			l.ItemData.Text:= Format('%d (%3.3d)', [i + 1,
					C64Steps[AStep].Items[i].Index]);
			l.Tag:= i;

			l.Parent:= ListBox3;
			end;

		finally
		ListBox3.Items.EndUpdate;
		end;
	end;

procedure TStepsLibMainForm.DoGenerateBkgdFrame(const AIndex: Integer);
	var
	i,
	j: Integer;

	begin
	FillChar(FBkGrnd[0], SizeOf(TC64Screen), 0);

	if  AIndex = 1 then
		begin
		for i:= 0 to 39 do
			FBkGrnd[17 * 40 + i]:= 5;

		for i:= 0 to 6 do
			for j:= 0 to 39 do
				FBkGrnd[18 * 40 + i * 40 + j]:= 85;
		end
	else if  AIndex = 2 then
		begin
		for i:= 0 to 39 do
			FBkGrnd[17 * 40 + i]:= 10;

		for i:= 0 to 6 do
			for j:= 0 to 39 do
				FBkGrnd[18 * 40 + i * 40 + j]:= 170;
		end;
	end;

procedure TStepsLibMainForm.DoLibraryNew(const ADefFrame: Boolean);
	var
	b1,
	b2: TBitmap;
	i,
	j: Integer;
	c: TC64Cell;

	begin
	FLoading:= True;

	ImageList1.Source.Clear;
	ImageList1.Destination.Clear;

	ListBox1.Items.BeginUpdate;
	b2:= TBitmap.Create;
	try
		ListBox1.Items.Clear;

		b2.Width:= 320;
		b2.Height:= 200;

		Image3.Bitmap.Width:= 320;
		Image3.Bitmap.Height:= 200;

		for i:= 0 to High(C64Frames) do
			C64Frames[i].GridView.Free;

		if  ADefFrame then
			begin
			Move(ARR_VAL_CLR_DEFC64PALETTE[0], C64Palette[TC64Colour.Bkgrd0], 4);

			C64CharsetRebuild;

			SetLength(C64Frames, 1);

			DoUpdateFrame(0, b2);
			b1:= b2.CreateThumbnail(32, 32);
			ImageListAdd(ImageList1, b1);
			b1.Free;

			Image3.Bitmap.CopyFromBitmap(b2);
			end
		else
			SetLength(C64Frames, 0);

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

	ComboBox2.ItemIndex:= C64Palette[TC64Colour.Bkgrd0];
	ComboBox3.ItemIndex:= C64Palette[TC64Colour.Multi1];
	ComboBox4.ItemIndex:= C64Palette[TC64Colour.Multi2];
	ComboBox5.ItemIndex:= C64Palette[TC64Colour.Frgrd3];

	Panel2.Enabled:= Length(C64Frames) = 1;

	FLoading:= False;
	end;

procedure TStepsLibMainForm.DoRebuildBackgroundFrame;
	var
	b,
	b1: TBitmap;

	begin
	b:= TBitmap.Create;
	try
		b.Width:= 320;
		b.Height:= 200;

		Image3.Bitmap.Width:= 320;
		Image3.Bitmap.Height:= 200;

		DoUpdateFrame(0, b, 0);
//		C64ScreenPaint(C64Frames[0].Screen, b);

		Image3.Bitmap.CopyFromBitmap(b);

		b1:= b.CreateThumbnail(32, 32);
		ImageListReplace(ImageList1, 0, b1);
		b1.Free;

		finally
		b.Free;
		end;
	end;

procedure TStepsLibMainForm.DoUpdateFrame(AFrame: Integer; ABitmap: TBitmap;
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

procedure TStepsLibMainForm.DoUpdateStepsViews(AStep: Integer; AStart: Integer);
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

procedure TStepsLibMainForm.FormCreate(Sender: TObject);
	begin
	FSelectedStep:= -1;
	FStpFrmDelta:= 1;

	C64CharsetRebuild;

	DoGenerateBkgdFrame(2);

	DoLibraryNew(True);
	end;

procedure TStepsLibMainForm.FormDestroy(Sender: TObject);
	var
	i,
	j: Integer;

	begin
	for i:= 0 to High(C64Steps) do
		begin
		for j:= C64Steps[i].Count - 1 downto 0 do
			C64Steps[i][j].Free;

		C64Steps[i].Free;
		end;

	SetLength(C64Steps, 0);

	for i:= 0 to High(C64Frames) do
		C64Frames[i].GridView.Free;

	SetLength(C64Frames, 0);

	for i:= 0 to 255 do
		C64CharViews[i].Free;
	end;

procedure TStepsLibMainForm.DoAddStepFrames(AStep: Integer);
	var
	j: Integer;
	s,
	e,
	o: Integer;
	c: TC64Cell;

	begin
	s:= C64Steps[AStep].Count;

	if  StepsLibStepForm.RadioButton1.IsChecked then
		begin
//		SetLength(C64Steps[AMove].Frames, s +
//				Trunc(StepsBuildStepForm.NumberBox2.Value) -
//				Trunc(StepsBuildStepForm.NumberBox1.Value) + 1);

		for j:= Trunc(StepsLibStepForm.NumberBox1.Value) to
				 Trunc(StepsLibStepForm.NumberBox2.Value) do
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
		c.Index:= Trunc(StepsLibStepForm.NumberBox1.Value);

		C64Frames[Trunc(StepsLibStepForm.NumberBox1.Value)].RefCount:=
				C64Frames[Trunc(StepsLibStepForm.NumberBox1.Value)].RefCount + 1;

		C64Steps[AStep].Add(c);
		end;

	if  s = 0 then
		o:= 19 - C64Frames[C64Steps[AStep].Items[0].Index].MidX
	else
		if  StepsLibStepForm.RadioButton2.IsChecked then
			o:= C64Steps[AStep].Items[C64Steps[AStep].Count - 1].Offset
		else if StepsLibStepForm.RadioButton3.IsChecked then
			o:= C64Frames[C64Steps[AStep].Items[C64Steps[AStep].Count - 1].Index].MidX -
				C64Frames[C64Steps[AStep].Items[C64Steps[AStep].Count - 1].Index + 1].MidX
		else if StepsLibStepForm.RadioButton4.IsChecked then
			o:= 19 - C64Frames[C64Steps[AStep].Items[s + 1].Index].MidX
		else
			o:= Trunc(StepsLibStepForm.NumberBox3.Value);

//	s:= Length(C64Steps[AMove].Offsets);
	e:= C64Steps[AStep].Count - 1;

//	SetLength(C64Steps[AMove].Offsets, Length(C64Steps[AMove].Frames));

	if  s <= e then
		for j:= s to e do
			C64Steps[AStep].Items[j].Offset:= o;

	DoUpdateStepsViews(AStep, s);
	end;

procedure TStepsLibMainForm.DoCalcFrameExtents(AFrame: Integer);
	var
	f: Boolean;
	x,
	y: Integer;
	i: Integer;
	d: TC64ScreenDiff;

	begin
	C64ScreenDiff(C64Frames[0].Screen, C64Frames[AFrame].Screen, d);

	C64Frames[AFrame].StartX:= 0;
	f:= False;
	for x:= 0 to 39 do
		begin
		for y:= 0 to 24 do
			begin
			i:= y * 40 + x;

//			if  not (C64Frames[AFrame].Screen[i] in [0, 10, 170]) then
			if  d[i] > -1 then
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

//			if  not (C64Frames[AFrame].Screen[i] in [0, 10, 170]) then
			if  d[i] > -1 then
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

procedure TStepsLibMainForm.ListBox1Change(Sender: TObject);
	begin
	if  Assigned(ListBox1.Selected) then
		DoDisplayFrame(ListBox1.Selected.Tag);
	end;

procedure TStepsLibMainForm.ListBox2Change(Sender: TObject);
	begin
	if  Assigned(ListBox2.Selected) then
		DoDisplayStep(ListBox2.Selected.Tag);
	end;

procedure TStepsLibMainForm.ListBox3Change(Sender: TObject);
	begin
	if  (FSelectedStep > -1)
	and (not Switch1.IsChecked)
	and (Assigned(ListBox3.Selected)) then
		begin
		FStepFrame:= ListBox3.Selected.Tag;
		Image2.Bitmap.Assign(C64Steps[FSelectedStep].Items[FStepFrame].View);
		end;
	end;

procedure TStepsLibMainForm.Switch1Switch(Sender: TObject);
	begin
	Timer1.Enabled:= Switch1.IsChecked;
	FStepFirst:= Switch1.IsChecked and (not FStepFirst);
	end;

procedure TStepsLibMainForm.Switch3Switch(Sender: TObject);
	begin
	Switch2.Enabled:= not Switch3.IsChecked;
	end;

procedure TStepsLibMainForm.Switch4Switch(Sender: TObject);
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

procedure TStepsLibMainForm.TabControl1Change(Sender: TObject);
	begin
	if  (TabControl1.ActiveTab = TabItem1)
	and Assigned(ListBox1.Selected) then
		DoDisplayFrame(ListBox1.Selected.Tag);

	if  (TabControl1.ActiveTab = TabItem3) then
		Panel2.Enabled:= Length(C64Frames) = 1;
	end;

procedure TStepsLibMainForm.Timer1Timer(Sender: TObject);
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

procedure TStepsLibMainForm.TrackBar1Change(Sender: TObject);
	begin
	Timer1.Interval:= VAL_SIZ_FRAMEMS[Trunc(TrackBar1.Value)];
	Label13.Text:= IntToStr(VAL_SIZ_FRAMEMS[Trunc(TrackBar1.Value)]);
	end;

end.
