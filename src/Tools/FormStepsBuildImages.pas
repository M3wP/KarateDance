unit FormStepsBuildImages;

interface

uses
	System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
	FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Layouts,
	FMX.ListBox, FMX.StdCtrls, FMX.Controls.Presentation, FMX.Objects,
	System.ImageList, FMX.ImgList, C64UtilTypes, System.Generics.Collections;

type
	TImgImport = class(TObject)
	public
		FileName: string;

		ColourCnt: Integer;
		Colours: array[0..3] of TAlphaColor;
		ColourMap: array[0..3] of SmallInt;
		CanImport: Boolean;

		Mapping: array[0..79, 0..49] of SmallInt;

		ImportView,
		MapView: TBitmap;

		constructor Create;
		destructor  Destroy; override;
	end;

	TStepsBuildImagesForm = class(TForm)
		ToolBar1: TToolBar;
		Button2: TButton;
		ListBox1: TListBox;
		Footer: TToolBar;
		OpenDialog1: TOpenDialog;
		ImageList1: TImageList;
		Button5: TButton;
		Button1: TButton;
		Panel1: TPanel;
		Image1: TImage;
		CheckBox1: TCheckBox;
		Label1: TLabel;
		Label2: TLabel;
		Label3: TLabel;
		Label4: TLabel;
		Label5: TLabel;
		Label6: TLabel;
		ComboBox1: TComboBox;
		ComboBox2: TComboBox;
		ComboBox3: TComboBox;
		ComboBox4: TComboBox;
		Rectangle1: TRectangle;
		Rectangle2: TRectangle;
		Rectangle3: TRectangle;
		Rectangle4: TRectangle;
		Button3: TButton;
		Button4: TButton;
		Button6: TButton;
		Button7: TButton;
		Rectangle5: TRectangle;
		Rectangle6: TRectangle;
		Rectangle7: TRectangle;
		Rectangle8: TRectangle;
		procedure FormCreate(Sender: TObject);
		procedure Button2Click(Sender: TObject);
		procedure ListBox1Change(Sender: TObject);
		procedure ComboBox1Change(Sender: TObject);
		procedure Button3Click(Sender: TObject);
		procedure FormDestroy(Sender: TObject);
	private
		FImportImgs: TList<TImgImport>;
		FFixed: Boolean;

		FCombos: array[0..3] of TComboBox;
		FSrcRects,
		FDstRects: array[0..3] of TRectangle;

		FSelectedImage: Integer;

		procedure DoDisplayImage(const AImage: Integer);
		procedure DoUpdateImageView(const AImage: Integer);
		procedure DoRebuildMapView(const AImage: Integer);
		procedure DoRemapImageColour(const AImage: Integer;
				const AColour: TAlphaColor; const AMap: Integer);

		function  ColourForMap(const AMap: Integer;
				const ADefault: TAlphaColor): TAlphaColor;

		function  GetImageCount: Integer;

	public
		procedure Clear;
		procedure AddImage(const AFileName: string; ABitmap: TBitmap);
		procedure ImageToScreen(const AImage: Integer; var AScreen: TC64Screen);

		function  ShowAddImages(const AFixed: Boolean = False): TModalResult;

		property  ImageCount: Integer read GetImageCount;
	end;

var
	StepsBuildImagesForm: TStepsBuildImagesForm;

implementation

{$R *.fmx}

uses
	System.IOUtils, KrDnceGraphTypes;


{ TImgImport }

constructor TImgImport.Create;
	var
	x,
	y: Integer;

	begin
	ImportView:= TBitmap.Create;
	ImportView.Width:= 80;
	ImportView.Height:= 50;

	MapView:= TBitmap.Create;
	MapView.Width:= 80;
	MapView.Height:= 50;

	for x:= 0 to 79 do
		for y:= 0 to 49 do
			Mapping[x, y]:= -1;
	end;

destructor TImgImport.Destroy;
	begin
	MapView.Free;
	ImportView.Free;

	inherited;
	end;

{ TStepsBuildImagesForm }

procedure TStepsBuildImagesForm.AddImage(const AFileName: string;
		ABitmap: TBitmap);
	var
	b1: TBitmap;
	l: TListBoxItem;
	img: TImgImport;
	i,
	x,
	y: Integer;
	rd: TBitmapData;
	p: TAlphaColor;
	f: Boolean;

	begin
	img:= TImgImport.Create;
	img.FileName:= AFileName;
	img.CanImport:= False;

	for i:= 0 to 3 do
		img.ColourMap[i]:= -1;

	FImportImgs.Add(img);

	b1:= ABitmap.CreateThumbnail(32, 32);
	ImageListAdd(ImageList1, b1);
	b1.Free;

	l:= TListBoxItem.Create(ListBox1);
	l.ItemData.Text:= AFileName;
	l.ImageIndex:= FImportImgs.Count - 1;
	l.Tag:= FImportImgs.Count - 1;

	l.Parent:= ListBox1;

	if  ((ABitmap.Width mod 40) <> 0)
	or  (ABitmap.Width < 80) then
		Exit;

	if  ((ABitmap.Height mod 25) <> 0)
	or  (ABitmap.Height < 50) then
		Exit;

	i:= Trunc(ABitmap.Width / 80);
	if  Trunc(ABitmap.Height / 50) <> i then
		Exit;

	b1:= ABitmap.CreateThumbnail(80, 50);
	img.ImportView.CopyFromBitmap(b1);
	img.MapView.CopyFromBitmap(b1);
	b1.Free;

	img.ColourCnt:= 0;

	if  img.ImportView.Map(TMapAccess.Read, rd) then
	try
		for x:= 0 to img.ImportView.Width - 1 do
			begin
			for y:= 0 to img.ImportView.Height - 1 do
				begin
				p:= rd.GetPixel(x, y);
				if  TAlphaColorRec(p).A <> $FF then
					begin
					img.ColourCnt:= -1;
					Break;
					end;

				f:= False;
				for i:= 0 to img.ColourCnt - 1 do
					if  img.Colours[i] = p then
						begin
						f:= True;
						Break;
						end;

				if  f then
					Continue;

				Inc(img.ColourCnt);
				if  img.ColourCnt > 4 then
					Break;

				img.Colours[img.ColourCnt - 1]:= p;
				end;

			if  (img.ColourCnt < 0)
			or  (img.ColourCnt > 4) then
				Break;
			end;

		finally
		img.ImportView.Unmap(rd);
		end;

	if  (img.ColourCnt < 0)
	or  (img.ColourCnt > 4) then
		Exit;

	img.CanImport:= True;
	end;

procedure TStepsBuildImagesForm.Button2Click(Sender: TObject);
	var
	i: Integer;
	b: TBitmap;

	begin
	if  OpenDialog1.Execute then
		begin
		for i:= 0 to OpenDialog1.Files.Count - 1 do
			begin
			b:= TBitmap.CreateFromFile(OpenDialog1.Files[i]);
			try

				AddImage(TPath.GetFileName(OpenDialog1.Files[i]), b);

				finally
				b.Free;
				end;
			end;

		if  not Assigned(ListBox1.Selected) then
			ListBox1.SelectRange(ListBox1.ListItems[0], ListBox1.ListItems[0]);
		end;
	end;

procedure TStepsBuildImagesForm.Button3Click(Sender: TObject);
	var
	i,
	m: Integer;
	p: TAlphaColor;

	begin
	i:= TButton(Sender).Tag;

	if  (FSelectedImage > -1)
	and (FCombos[i].Enabled) then
		begin
		p:= FImportImgs[FSelectedImage].Colours[i];
		m:= FImportImgs[FSelectedImage].ColourMap[i];

		for i:= 0 to FImportImgs.Count - 1 do
			if  i <> FSelectedImage then
				begin
				DoRemapImageColour(i, p, m);
				DoRebuildMapView(i);
				end;
		end;
	end;

procedure TStepsBuildImagesForm.Clear;
	var
	i: Integer;
	img: TImgImport;

	begin
	FSelectedImage:= -1;

	ImageList1.Source.Clear;
	ImageList1.Destination.Clear;
	ImageList1.ClearCache;

	ListBox1.Items.Clear;

	for i:= FImportImgs.Count - 1 downto 0 do
		begin
		img:= FImportImgs[i];
		FImportImgs.Delete(i);
		img.Free;
		end;

	for i:= 0 to 3 do
		FCombos[i].ItemIndex:= 0;
	end;

function TStepsBuildImagesForm.ColourForMap(const AMap: Integer;
		const ADefault: TAlphaColor): TAlphaColor;
	begin
	Result:= ADefault;

	case AMap of
		0:
			Result:= TC64FrameClrs.Bkgrd0;
		1:
			Result:= TC64FrameClrs.Multi1;
		2:
			Result:= TC64FrameClrs.Multi2;
		3:
			Result:= TC64FrameClrs.Frgrd3;
		end;
	end;

procedure TStepsBuildImagesForm.ComboBox1Change(Sender: TObject);
	var
	c: TComboBox;

	begin
	c:= TComboBox(Sender);

	if  (FSelectedImage > -1)
	and (c.Enabled) then
		begin
		FImportImgs[FSelectedImage].ColourMap[c.Tag]:= c.ItemIndex - 1;

		FDstRects[c.Tag].Fill.Color:= ColourForMap(c.ItemIndex - 1,
				FImportImgs[FSelectedImage].Colours[c.Tag]);

		DoRebuildMapView(FSelectedImage);
		DoUpdateImageView(FSelectedImage);
		end;
	end;

procedure TStepsBuildImagesForm.DoDisplayImage(const AImage: Integer);
	var
	i: Integer;
	img: TImgImport;

	begin
	FSelectedImage:= AImage;

	DoUpdateImageView(AImage);

	img:= FImportImgs.Items[AImage];
	CheckBox1.IsChecked:= img.CanImport;

	for i:= 0 to 3 do
		if  i > (img.ColourCnt - 1) then
			begin
			FCombos[i].Enabled:= False;
			FCombos[i].ItemIndex:= 0;

			FSrcRects[i].Fill.Color:= TAlphaColorRec.Null;
			FDstRects[i].Fill.Color:= TAlphaColorRec.Null;
			end
		else
			begin
			FCombos[i].Enabled:= True;
			FCombos[i].ItemIndex:= img.ColourMap[i] + 1;

			FSrcRects[i].Fill.Color:= img.Colours[i];
			FDstRects[i].Fill.Color:= ColourForMap(img.ColourMap[i],
					img.Colours[i]);
			end;
	end;

procedure TStepsBuildImagesForm.DoRebuildMapView(const AImage: Integer);
	var
	x,
	y,
	i,
	m: Integer;
	p: TAlphaColor;
	rd,
	wd: TBitmapData;
	img: TImgImport;

	begin
	img:= FImportImgs[AImage];

	if  img.ImportView.Map(TMapAccess.Read, rd) then
	try
		if  img.MapView.Map(TMapAccess.Write, wd) then
		try
			for x:= 0 to img.ImportView.Width - 1 do
				for y:= 0 to img.ImportView.Height - 1 do
					begin
					p:= rd.GetPixel(x, y);

					m:= -1;
					for i:= 0 to img.ColourCnt - 1 do
						if  img.Colours[i] = p then
							begin
							m:= i;
							Break;
							end;

					if  m > -1 then
						m:= img.ColourMap[m];

					img.Mapping[x, y]:= m;

					p:= ColourForMap(m, p);

					wd.SetPixel(x, y, p);
					end;

			finally
			FImportImgs[AImage].MapView.Unmap(wd);
			end;

		finally
		FImportImgs[AImage].ImportView.Unmap(rd);
		end;
	end;

procedure TStepsBuildImagesForm.DoRemapImageColour(const AImage: Integer;
		const AColour: TAlphaColor; const AMap: Integer);
	var
	i: Integer;
	img: TImgImport;

	begin
	img:= FImportImgs[AImage];

	for i:= 0 to img.ColourCnt - 1 do
		if  img.Colours[i] = AColour then
			begin
			img.ColourMap[i]:= AMap;
			Break;
			end;
	end;

procedure TStepsBuildImagesForm.DoUpdateImageView(const AImage: Integer);
	begin
	Image1.Bitmap.Width:= 320;
	Image1.Bitmap.Height:= 200;

	if  FImportImgs.Items[AImage].CanImport then
		begin
		Image1.Bitmap.Canvas.BeginScene;
		try
			Image1.Bitmap.Canvas.DrawBitmap(FImportImgs.Items[AImage].MapView,
					RectF(0, 0, 80, 50), RectF(0, 0, 320, 200), 1);

			finally
			Image1.Bitmap.Canvas.EndScene;
			end;
		end
	else
		Image1.Bitmap.Clear(TAlphaColorRec.Crimson);
	end;

procedure TStepsBuildImagesForm.FormCreate(Sender: TObject);
	begin
	FSelectedImage:= -1;

	FImportImgs:= TList<TImgImport>.Create;

	FCombos[0]:= ComboBox1;
	FCombos[1]:= ComboBox2;
	FCombos[2]:= ComboBox3;
	FCombos[3]:= ComboBox4;

	FSrcRects[0]:= Rectangle1;
	FSrcRects[1]:= Rectangle2;
	FSrcRects[2]:= Rectangle3;
	FSrcRects[3]:= Rectangle4;

	FDstRects[0]:= Rectangle5;
	FDstRects[1]:= Rectangle6;
	FDstRects[2]:= Rectangle7;
	FDstRects[3]:= Rectangle8;
	end;

procedure TStepsBuildImagesForm.FormDestroy(Sender: TObject);
	begin
	Clear;
	FImportImgs.Free;
	end;

function TStepsBuildImagesForm.GetImageCount: Integer;
	begin
    Result:= FImportImgs.Count;
	end;

procedure TStepsBuildImagesForm.ImageToScreen(const AImage: Integer;
		var AScreen: TC64Screen);
	var
	i,
	x,
	y: Integer;
	img: TImgImport;
	c: TC64Colours;

	begin
	img:= FImportImgs[AImage];

	if  not img.CanImport then
		raise Exception.Create('Invalid image!');

	for i:= 0 to img.ColourCnt - 1 do
		if  img.ColourMap[i] < 0 then
			raise Exception.Create('Incomplete mapping!');

	for x:= 0 to 39 do
		for y:= 0 to 24 do
			begin
			c[0]:= TC64Colour(img.Mapping[x * 2, y * 2]);
			c[1]:= TC64Colour(img.Mapping[x * 2 + 1, y * 2]);
			c[2]:= TC64Colour(img.Mapping[x * 2, y * 2 + 1]);
			c[3]:= TC64Colour(img.Mapping[x * 2 + 1, y * 2 + 1]);

			AScreen[y * 40 + x]:= C64ColorsToIndex(c);
			end;
	end;

procedure TStepsBuildImagesForm.ListBox1Change(Sender: TObject);
	begin
	if  Assigned(ListBox1.Selected) then
		begin
		Panel1.Visible:= True;
		DoDisplayImage(ListBox1.Selected.Tag);
		end;
	end;

function TStepsBuildImagesForm.ShowAddImages(
		const AFixed: Boolean): TModalResult;
	begin
	FFixed:= AFixed;

	if  not FFixed then
		Clear
	else
		ListBox1.SelectRange(ListBox1.ListItems[0], ListBox1.ListItems[0]);

	Button2.Enabled:= not FFixed;

	Result:= ShowModal;
	end;

end.
