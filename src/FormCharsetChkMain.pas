unit FormCharsetChkMain;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.StdCtrls, KrDnceUtilTypes;

type
	TForm1 = class(TForm)
		Button1: TButton;
		OpenDialog1: TOpenDialog;
		Button2: TButton;
		Label1: TLabel;
		Label2: TLabel;
		Button3: TButton;
		Button4: TButton;
		SaveDialog1: TSaveDialog;
		Label3: TLabel;
		Label4: TLabel;
		Label5: TLabel;
		Button5: TButton;
		Button6: TButton;
		Label6: TLabel;
		Label7: TLabel;
		Button7: TButton;
		procedure Button1Click(Sender: TObject);
		procedure Button2Click(Sender: TObject);
		procedure Button3Click(Sender: TObject);
		procedure Button4Click(Sender: TObject);
		procedure Button5Click(Sender: TObject);
		procedure Button6Click(Sender: TObject);
		procedure Button7Click(Sender: TObject);
	private
		FSize: Integer;
		FCharset: array of Byte;
		FChrsetIdxs: array[0..255] of Integer;
		FChrsetMchs: TCharsetMatches;

		FFrameCount: Integer;
		FFrames: TMemoryStream;

		FFramesConv: TMemoryStream;

		procedure C64CharToColours(const AChar: Byte; out AColours: TC64Colours);

		procedure DoFillCharset(AOffset: Integer);
		procedure DoProcChrsetIdxs(const ASize: Integer);

	public
		{ Public declarations }
	end;

var
	Form1: TForm1;

implementation

{$R *.fmx}

{ TForm1 }

procedure TForm1.Button1Click(Sender: TObject);
	var
	f: TMemoryStream;

	begin
	if  OpenDialog1.Execute then
		begin
		f:= TMemoryStream.Create;
		try
			f.LoadFromFile(OpenDialog1.FileName);

			if  f.Size > 2048 then
				begin
				Label1.Text:= 'Invalid charset size';
				Exit;
				end;

			FSize:= f.Size;

			SetLength(FCharset, 2048);
			FillChar(FCharset[0], 2048, 0);
			Move(PByte(f.Memory)[0], FCharset[0], FSize);

			Label1.Text:= IntToStr(FSize);

			finally
			f.Free;
			end;
		end;
	end;

procedure TForm1.Button2Click(Sender: TObject);
	begin
	try
		DoProcChrsetIdxs(FSize);

		Label2.Text:= IntToStr(FSize div 8);

		except
		on  E: Exception do
			Label2.Text:= E.Message;
		end;
	end;

procedure TForm1.Button3Click(Sender: TObject);
	begin
	try
		DoFillCharset(FSize);

		Label3.Text:= 'Done';

		except
		on  E: Exception do
			Label3.Text:= E.Message;
		end;
	end;

procedure TForm1.Button4Click(Sender: TObject);
	var
	f: TFileStream;

	begin
	if  SaveDialog1.Execute then
		begin
		f:= TFileStream.Create(SaveDialog1.FileName, fmCreate);
		try
			f.WriteBuffer(FCharset[0], 2048);

			finally
			f.Free;
			end;
		end;
	end;

procedure TForm1.Button5Click(Sender: TObject);
	begin
	if  OpenDialog1.Execute then
		begin
		if  Assigned(FFrames) then
			begin
			FFrames.Free;
			FFrames:= nil;
			end;

		FFrames:= TMemoryStream.Create;
		FFrames.LoadFromFile(OpenDialog1.FileName);

		if  (FFrames.Size mod 1000) <> 0 then
			begin
			FFrames.Free;
			FFrames:= nil;

			Label6.Text:= 'Invalid frames size';
			Exit;
			end;

		FFrameCount:= FFrames.Size div 1000;

		Label6.Text:= IntToStr(FFrameCount);
		end;
	end;

procedure TForm1.Button6Click(Sender: TObject);
	var
	i: Integer;

	begin
	if  Assigned(FFramesConv) then
		begin
		FFramesConv.Free;
		FFramesConv:= nil;
		end;

	if  Assigned(FFrames) then
		begin
		FFramesConv:= TMemoryStream.Create;

		FFramesConv.SetSize(FFrames.Size);

		for i:= 0 to FFrames.Size - 1 do
			PByte(FFramesConv.Memory)[i]:=
					FChrsetIdxs[PByte(FFrames.Memory)[i]];

		Label7.Text:= IntToStr(FFramesConv.Size);
		end;
	end;

procedure TForm1.Button7Click(Sender: TObject);
	begin
	if  SaveDialog1.Execute then
		begin
		FFramesConv.Position:= 0;
		FFramesConv.SaveToFile(SaveDialog1.FileName);
		end;
	end;

procedure TForm1.C64CharToColours(const AChar: Byte; out AColours: TC64Colours);
	var
	b: Byte;

	begin
	b:= FCharset[AChar * 8];
	AColours[0]:= TC64Colour((b and (128 or 64)) shr 6);
	AColours[1]:= TC64Colour((b and (8 or 4)) shr 2);

	b:= FCharset[AChar * 8 + 4];
	AColours[2]:= TC64Colour((b and (128 or 64)) shr 6);
	AColours[3]:= TC64Colour((b and (8 or 4)) shr 2);
	end;

procedure TForm1.DoFillCharset(AOffset: Integer);
	var
	c: TC64Char;
	i,
	n: Integer;
	l: TC64Colours;

	begin
	n:= 0;

	for i:= 0 to 255 do
		if  not FChrsetMchs[i] then
			begin
			IndexToC64Colours(i, l);

			ColoursToC64Char(l, c);

			Move(c[0], FCharset[AOffset + n * 8], 8);
			Inc(n);

			if  ((n * 8) + AOffset) > 2048 then
				raise Exception.Create('Data range error!');
			end;
	end;

procedure TForm1.DoProcChrsetIdxs(const ASize: Integer);
	var
	i: Integer;
	l: TC64Colours;
	b: Byte;

	begin
	if  (ASize mod 8) <> 0 then
		raise Exception.Create('Invalid charset!');

	for i:= 0 to 255 do
		begin
		FChrsetMchs[i]:= False;
		FChrsetIdxs[i]:= -1;
		end;

	for i:= 0 to Pred(ASize div 8) do
		begin
		C64CharToColours(i, l);
		b:= C64ColorsToIndex(l);

		if  FChrsetMchs[b] then
			raise Exception.Create('Duplicate colour set!');

		FChrsetMchs[b]:= True;
		FChrsetIdxs[i]:= b;
		end;
	end;

end.
