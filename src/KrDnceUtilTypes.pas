unit KrDnceUtilTypes;

{$DEFINE DEF_LITTLE_ENDIAN}
{$DEFINE DEF_USE_TSEARCHREC_SIZE}


interface

uses
	System.Types, System.Classes, System.Generics.Collections, System.UITypes,
	FMX.Graphics;

const
	LIT_4CC_KDNCEPROJ: AnsiString = 'KRDN';
	LIT_4CC_KDNCEFRME: AnsiString = 'KDFR';
	LIT_4CC_KDNCESTEP: AnsiString = 'KDST';

	ARR_VAL_CLR_DEFC64PALETTE: array[0..3] of Byte = (
			0, 10, 6, 1);

type
	TC64Char = array[0..7] of Byte;

	TC64Colour = (Bkgrd0, Multi1, Multi2, Frgrd3);

	TC64Colours = array[0..3] of TC64Colour;

	TCharsetMatches = array[0..255] of Boolean;

	TC64Palette = array[TC64Colour] of Byte;

	TC64FrameClrs = record
	const
		Black = TAlphaColorRec.Alpha or TAlphaColor($000000);
		White =  TAlphaColorRec.Alpha or TAlphaColor($FFFFFF);
		Red = TAlphaColorRec.Alpha or TAlphaColor($92453A);
		Cyan = TAlphaColorRec.Alpha or TAlphaColor($7ECBD5);
		Purple = TAlphaColorRec.Alpha or TAlphaColor($934CB9);
		Green = TAlphaColorRec.Alpha or TAlphaColor($6FB446);
		Blue = TAlphaColorRec.Alpha or TAlphaColor($4335AD);
		Yellow = TAlphaColorRec.Alpha or TAlphaColor($DDE979);
		Orange = TAlphaColorRec.Alpha or TAlphaColor($9A6628);
		Brown = TAlphaColorRec.Alpha or TAlphaColor($634D00);
		LtRed = TAlphaColorRec.Alpha or TAlphaColor($C77F75);
		DkGrey = TAlphaColorRec.Alpha or TAlphaColor($5C5C5C);
		MdGrey = TAlphaColorRec.Alpha or TAlphaColor($898989);
		LtGreen = TAlphaColorRec.Alpha or TAlphaColor($B7F891);
		LtBlue = TAlphaColorRec.Alpha or TAlphaColor($8478E7);
		LtGrey = TAlphaColorRec.Alpha or TAlphaColor($B7B7B7);

	public
		class function  ColourByC64Index(const AIndex: Byte): TAlphaColor; static;

		class function  Bkgrd0: TAlphaColor; static;
		class function  Multi1: TAlphaColor; static;
		class function  Multi2: TAlphaColor; static;
		class function  Frgrd3: TAlphaColor; static;
	end;

	TC64CharViews = array[0..255] of TBitmap;

	TC64Screen = array[0..999] of Byte;

	TC64ScreenDiff = array[0..999] of SmallInt;

	TC64Frame = record
		Screen: TC64Screen;
		GridView: TBitmap;
		StartX,
		MidX,
		EndX: Integer;
		RefCount: Integer;
	end;

	TC64Frames = array of TC64Frame;

	TC64CellKind = (cckFrame, cckStep);
	TC64CellLink = (cclFromFrames, cclSmartLink, cclHardCentre, cclCustom);

	TC64FrameKind = (cfkRaw, cfkDiffRLE);

	TC64Cell = class(TObject)
	public
		Kind: TC64CellKind;
		Index: Integer;
		Offset: Integer;
		View: TBitmap;
		Link: TC64CellLink;
		StartX,
		EndX: Integer;

		constructor Create;
		destructor  Destroy; override;
	end;

	TC64Cells = TList<TC64Cell>;

	TC64Step = TList<TC64Cell>;
	TC64Steps = array of TC64Step;

	TC64Nodes = TList<TC64Cell>;

	TC64Bytes = array of Byte;

	TBundledFile = class(TObject)
		FileName: string;
		TempFile: string;
		IsBundled: Boolean;
		Data: TMemoryStream;
	end;

	TKarateDanceLib = packed record
		VerHi: Byte;
		VerLo: Byte;
		Reserved: Word;
		Palette: array[0..3] of Byte;
		Screen: TC64Screen;
	end;

	TKarateDanceFrme = packed record
		StartX,
		MidX,
		EndX: Byte;
		FrameKind: Byte;
//		FrrameData: array of Byte;
	end;

	TKarateDanceFCel = packed record
		Index: Word;
		Offset: SmallInt;
	end;

	TKarateDanceStep = packed record
		Frames: array of TKarateDanceFCel;
	end;

	TKarateDanceChnk = packed record
		Ident: array[0..3] of AnsiChar;
		Size: Cardinal;
	end;

var
	C64CharViews: TC64CharViews;
	C64Frames: TC64Frames;
	C64Steps: TC64Steps;
	C64AnimNodes: TC64Nodes;
	C64Palette: TC64Palette;
	BundledFiles: array of TBundledFile;


function  GetFileSize(AFileName: string): Int64;


function  C64ColorsToIndex(const AColours: TC64Colours): Byte;
procedure IndexToC64Colours(const AIndex: Byte; out AColours: TC64Colours);

//procedure C64CharToColours(const AChar: Byte; out AColours: TC64Colours);
procedure ColoursToC64Char(const AColours: TC64Colours;
		out AChar: TC64Char);


procedure C64CharsetRebuild;


procedure C64ScreenPaint(const AScreen: TC64Screen; ABitmap: TBitmap;
		const AScale: Integer = 1);

procedure C64ScreenDiff(const AScreen1, AScreen2: TC64Screen;
		out ADiff: TC64ScreenDiff);
procedure C64ScreenDiff2(const AScreen1, AScreen2: TC64Screen;
		out ADiff: TC64ScreenDiff);

procedure C64ScreenCopyRecMask(const ASource: TC64Screen; var ADest: TC64Screen;
		const AMask: TC64ScreenDiff; const ASrcRect: TRect;
		const AOffsX: Integer = 0; const AOffsY: Integer = 0);

procedure C64ScreenDiffRLEEncode(ADiff: TC64ScreenDiff; out AData: TC64Bytes);
procedure C64ScreenDiffRLEDecode(ASource: TC64Screen; AData: TC64Bytes;
		const AOffset: Integer; var AScreen: TC64Screen);

procedure C64ScreenDiffRLEEncode2(AScreen: TC64Screen; ADiff: TC64ScreenDiff;
		var AData: TC64Bytes; var AData1: TC64Bytes; var AData2: TC64Bytes);


procedure C64ScreenDiffRLEDecode3(ASource: TC64Screen; AData: TC64Bytes;
		const AOffset: Integer; var AScreen: TC64Screen);
procedure C64ScreenDiffRLEEncode3(ADiff: TC64ScreenDiff; out AData: TC64Bytes;
		var AData1, AData2: TC64Bytes);


procedure ClearBundledFiles;
procedure ClearBundledFile(var ABundledFile: TBundledFile);

procedure BundleFile(const AFileName, AExternalFile: string;
		var ABundledFile: TBundledFile);


procedure SaveLibrary(const AFileName: string);
procedure LoadLibrary(const AFileName: string);


implementation

uses
	System.SysUtils, System.IOUtils;

const
	ARR_VAL_CLR_DEFVICPALETTE: array[0..15] of TAlphaColor = (
			TC64FrameClrs.Black, TC64FrameClrs.White, TC64FrameClrs.Red,
			TC64FrameClrs.Cyan, TC64FrameClrs.Purple, TC64FrameClrs.Green,
			TC64FrameClrs.Blue, TC64FrameClrs.Yellow, TC64FrameClrs.Orange,
			TC64FrameClrs.Brown, TC64FrameClrs.LtRed, TC64FrameClrs.DkGrey,
			TC64FrameClrs.MdGrey, TC64FrameClrs.LtGreen, TC64FrameClrs.LtBlue,
			TC64FrameClrs.LtGrey);

type
	TNetCardinal = packed record
		case Boolean of
			False: (
				Value: Cardinal);
			True: (
				Byte0,
				Byte1,
				Byte2,
				Byte3: Byte);
	end;

	TNetWord = packed record
		case Boolean of
			False: (
				Value: Word);
			True: (
				Byte0,
				Byte1: Byte);
	end;

	TNetSmallInt = packed record
		case Boolean of
			False: (
				Value: SmallInt);
			True: (
				Byte0,
				Byte1: Byte);
	end;


function GetFileSize(AFileName: string): Int64;
	var
	sr: TSearchRec;

	begin
	if  FindFirst(AFileName, faAnyFile, sr) = 0 then
		begin
{$IFDEF DEF_USE_TSEARCHREC_SIZE}
		Result:= sr.Size;
{$ELSE}
		Result:= (Int64(sr.FindData.nFileSizeHigh) shl 32) + sr.FindData.nFileSizeLow;
{$ENDIF}
		FindClose(sr);
		end
	else
		 Result:= -1;
	end;

procedure ClearBundledFiles;
	var
	i: Integer;

	begin
	for i:= 0 to High(BundledFiles) do
		if  Assigned(BundledFiles[i]) then
			ClearBundledFile(BundledFiles[i]);
	end;

procedure ClearBundledFile(var ABundledFile: TBundledFile);
	begin
	if  Assigned(ABundledFile.Data) then
		begin
		ABundledFile.Data.Free;
		ABundledFile.Data:= nil;
		end;

	if  {ABundledFile.IsBundled
	and }(ABundledFile.TempFile <> '') then
		begin
		TFile.Delete(ABundledFile.TempFile);
		ABundledFile.TempFile:= '';
		end;
	end;

procedure BundleFile(const AFileName, AExternalFile: string;
		var ABundledFile: TBundledFile);
	begin
	ABundledFile.FileName:= TPath.GetFileName(AFileName);
	ABundledFile.TempFile:= AExternalFile;

	if  not Assigned(ABundledFile.Data) then
		ABundledFile.Data:= TMemoryStream.Create;

	ABundledFile.Data.Clear;
	ABundledFile.Data.LoadFromFile(AExternalFile);

	ABundledFile.IsBundled:= True;
	end;

function ToNetworkCardinal(const AValue: Cardinal): Cardinal;
{$IFDEF DEF_LITTLE_ENDIAN}
	var
	n: TNetCardinal;

	begin
	n.Byte0:= Byte((AValue shr 24) and $FF);
	n.Byte1:= Byte((AValue shr 16) and $FF);
	n.Byte2:= Byte((AValue shr 8) and $FF);
	n.Byte3:= Byte((AValue) and $FF);

	Result:= n.Value;
{$ELSE}
	begin
	Result:= AValue;
{$ENDIF}
	end;

function ToNetworkWord(const AValue: Word): Word;
{$IFDEF DEF_LITTLE_ENDIAN}
	var
	n: TNetWord;

	begin
	n.Byte0:= Byte((AValue shr 8) and $FF);
	n.Byte1:= Byte((AValue) and $FF);

	Result:= n.Value;
{$ELSE}
	begin
	Result:= AValue;
{$ENDIF}
	end;

function ToNetworkSmallInt(const AValue: SmallInt): SmallInt;
{$IFDEF DEF_LITTLE_ENDIAN}
	var
	n: TNetSmallInt;

	begin
	n.Byte0:= Byte((AValue shr 8) and $FF);
	n.Byte1:= Byte((AValue) and $FF);

	Result:= n.Value;
{$ELSE}
	begin
	Result:= AValue;
{$ENDIF}
	end;

function ToLocalCardinal(const AValue: Cardinal): Cardinal;
{$IFDEF DEF_LITTLE_ENDIAN}
	var
	n: TNetCardinal;

	begin
	n.Byte0:= Byte((AValue shr 24) and $FF);
	n.Byte1:= Byte((AValue shr 16) and $FF);
	n.Byte2:= Byte((AValue shr 8) and $FF);
	n.Byte3:= Byte((AValue) and $FF);

	Result:= n.Value;
{$ELSE}
	begin
	Result:= AValue;
{$ENDIF}
	end;

function ToLocalWord(const AValue: Word): Word;
{$IFDEF DEF_LITTLE_ENDIAN}
	var
	n: TNetWord;

	begin
	n.Byte0:= Byte((AValue shr 8) and $FF);
	n.Byte1:= Byte((AValue) and $FF);

	Result:= n.Value;
{$ELSE}
	begin
	Result:= AValue;
{$ENDIF}
	end;

function ToLocalSmallInt(const AValue: SmallInt): SmallInt;
{$IFDEF DEF_LITTLE_ENDIAN}
	var
	n: TNetSmallInt;

	begin
	n.Byte0:= Byte((AValue shr 8) and $FF);
	n.Byte1:= Byte((AValue) and $FF);

	Result:= n.Value;
{$ELSE}
	begin
	Result:= AValue;
{$ENDIF}
	end;

procedure WriteChunk(AFile: TFileStream; const AIdent: AnsiString;
		const AData: PByte; const ASize: Cardinal);
	var
	c: TKarateDanceChnk;
	b: Byte;

	begin
	b:= 0;

	Move(AIdent[Low(AnsiString)], c.Ident[0], 4);
	c.Size:= ToNetworkCardinal(ASize);

	AFile.WriteBuffer(c, SizeOf(TKarateDanceChnk));

	if  ASize > 0 then
		AFile.WriteBuffer(AData[0], ASize);

	if  (ASize mod 2) > 0 then
		AFile.Write(b, 1)
	end;


procedure ReadChunk(AFile: TFileStream; var AChunk: TKarateDanceChnk);
	begin
	if  AFile.Read(AChunk, SizeOf(TKarateDanceChnk)) <> SizeOf(TKarateDanceChnk) then
		raise Exception.Create('Invalid IFF Structure!');

	AChunk.Size:= ToLocalCardinal(AChunk.Size);
	end;


procedure SaveLibrary(const AFileName: string);
	var
	f: TFileStream;
	p: TKarateDanceLib;
	i,
	j: Integer;
	r: TKarateDanceFrme;
	d: TC64ScreenDiff;
	b: TC64Bytes;
	c: array of Byte;
	s: TKarateDanceStep;

	begin
	f:= TFileStream.Create(AFileName, fmCreate);
	try
		p.VerHi:= 0;
		p.VerLo:= 0;
		p.Reserved:= 0;

		Move(C64Palette[TC64Colour.Bkgrd0], p.Palette[0], 4);

		Move(C64Frames[0].Screen[0], p.Screen[0], SizeOf(TC64Screen));

		WriteChunk(f, LIT_4CC_KDNCEPROJ, PByte(@p), SizeOf(TKarateDanceLib));

		for i:= 1 to High(C64Frames) do
			begin
			r.StartX:= C64Frames[i].StartX;
			r.MidX:= C64Frames[i].MidX;
			r.EndX:= C64Frames[i].EndX;

			r.FrameKind:= Ord(cfkDiffRLE);

			C64ScreenDiff(C64Frames[0].Screen, C64Frames[i].Screen, d);
			C64ScreenDiffRLEEncode(d, b);

			SetLength(c, SizeOf(TKarateDanceFrme) + Length(b));
			Move(r, c[0], SizeOf(TKarateDanceFrme));
			Move(b[0], c[SizeOf(TKarateDanceFrme)], Length(b));

			WriteChunk(f, LIT_4CC_KDNCEFRME, PByte(@c[0]), Length(c));
			end;

		for i:= 0 to High(C64Steps) do
			begin
			SetLength(s.Frames, C64Steps[i].Count);

			for j:= 0 to C64Steps[i].Count - 1 do
				begin
				s.Frames[j].Index:=  ToNetworkWord(C64Steps[i].Items[j].Index);
				s.Frames[j].Offset:= ToNetworkSmallInt(C64Steps[i].Items[j].Offset);
				end;

			if  C64Steps[i].Count > 0 then
				WriteChunk(f, LIT_4CC_KDNCESTEP, PByte(@s.Frames[0]),
						Length(s.Frames) * SizeOf(TKarateDanceFCel))
			else
				WriteChunk(f, LIT_4CC_KDNCESTEP, PByte(nil), 0);
			end;

		finally
		f.Free;
		end;
	end;

procedure LoadLibrary(const AFileName: string);
	var
	f: TFileStream;
	b: Byte;
	i: Integer;
	c: TKarateDanceChnk;
	d: TC64Bytes;
	p: TKarateDanceLib;
	r: TKarateDanceFrme;
	s: TKarateDanceStep;
	l: TC64Cell;

	begin
	f:= TFileStream.Create(AFileName, fmOpenRead);
	try
		ReadChunk(f, c);

		if  (c.Size <> SizeOf(TKarateDanceLib))
		or  (CompareText(string(c.Ident), string(LIT_4CC_KDNCEPROJ)) <> 0)  then
			raise Exception.Create('Invalid Project File!');

		f.ReadBuffer(p, SizeOf(TKarateDanceLib));
		if  (c.Size mod 2) > 0 then
			f.Read(b, 1);

		Move(p.Palette[0], C64Palette[TC64Colour.Bkgrd0], 4);

		SetLength(C64Frames, 1);
		Move(p.Screen[0], C64Frames[0].Screen[0], SizeOf(TC64Screen));

		while f.Position < f.Size do
			begin
			ReadChunk(f, c);

			SetLength(d, c.Size);
			f.ReadBuffer(d[0], c.Size);
			if  (c.Size mod 2) > 0 then
				f.Read(b, 1);

			if  CompareText(string(c.Ident), string(LIT_4CC_KDNCEFRME)) = 0  then
				begin
				Move(d[0], r, SizeOf(TKarateDanceFrme));

				SetLength(C64Frames, Length(C64Frames) + 1);

				C64Frames[High(C64Frames)].StartX:= r.StartX;
				C64Frames[High(C64Frames)].MidX:= r.MidX;
				C64Frames[High(C64Frames)].EndX:= r.EndX;

				if  TC64FrameKind(r.FrameKind) = cfkRaw then
					Move(d[SizeOf(TKarateDanceFrme)],
							C64Frames[High(C64Frames)].Screen[0],
							SizeOf(TC64Screen))
				else
					C64ScreenDiffRLEDecode(C64Frames[0].Screen,
							d, SizeOf(TKarateDanceFrme),
							C64Frames[High(C64Frames)].Screen);
				end
			else if CompareText(string(c.Ident), string(LIT_4CC_KDNCESTEP)) = 0  then
				begin

				if  c.Size > 0 then
					begin
					SetLength(s.Frames, Trunc(c.Size / SizeOf(TKarateDanceFCel)));

					Move(d[0], s.Frames[0], Length(s.Frames) * SizeOf(TKarateDanceFCel));
					end
				else
					SetLength(s.Frames, 0);

				SetLength(C64Steps, Length(C64Steps) + 1);
				C64Steps[High(C64Steps)]:= TC64Step.Create;

				for i:= 0 to High(s.Frames) do
					begin
					s.Frames[i].Index:= ToLocalWord(s.Frames[i].Index);
					s.Frames[i].Offset:= ToLocalSmallInt(s.Frames[i].Offset);

					l:= TC64Cell.Create;
					l.Kind:= cckFrame;
					l.Index:= s.Frames[i].Index;
					l.Offset:= s.Frames[i].Offset;

					C64Steps[High(C64Steps)].Add(l);
					end;

				end;
			end;

		finally
		f.Free;
		end;
	end;

function C64ColorsToIndex(const AColours: TC64Colours): Byte;
	var
	i: Integer;
	b: Byte;

	begin
	Result:= 0;

	for i:= 0 to 3 do
		begin
		b:= Ord(AColours[i]);
		if  i < 3 then
			b:= b shl ((3 - i) * 2);

		Result:= Result or b;
		end;
	end;

procedure IndexToC64Colours(const AIndex: Byte; out AColours: TC64Colours);
	var
	i: Integer;
	m,
	b: Byte;

	begin
	m:= 128 or 64;
	for i:= 0 to 3 do
		begin
		b:= AIndex and m;
		if  i < 3 then
			b:= b shr ((3 - i) * 2);

		AColours[i]:= TC64Colour(b);

		m:= m shr 2;
		end;
	end;

procedure ColoursToC64Char(const AColours: TC64Colours;
		out AChar: TC64Char);
	var
	b: Byte;
	i: Integer;

	begin
	b:= (Ord(AColours[0]) shl 6) or (Ord(AColours[0]) shl 4) or
			(Ord(AColours[1]) shl 2) or Ord(AColours[1]);
	for i:= 0 to 3 do
		AChar[i]:= b;

	b:= (Ord(AColours[2]) shl 6) or (Ord(AColours[2]) shl 4) or
			(Ord(AColours[3]) shl 2) or Ord(AColours[3]);
	for i:= 4 to 7 do
		AChar[i]:= b;
	end;


procedure DoDrawC64MultiChar(ABitmap: TBitmap; AX, AY: Integer;
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


procedure C64CharsetRebuild;
	var
	i: Integer;
	c: TC64Colours;

	begin
	for i:= 0 to 255 do
		begin
		if  not Assigned(C64CharViews[i]) then
			C64CharViews[i]:= TBitmap.Create;

		C64CharViews[i].Width:= 8;
		C64CharViews[i].Height:= 8;

		IndexToC64Colours(i, c);
		DoDrawC64MultiChar(C64CharViews[i], 0, 0, c);
		end;
	end;


procedure C64ScreenPaint(const AScreen: TC64Screen; ABitmap: TBitmap;
		const AScale: Integer);
	var
	i,
	x,
	y: Integer;

	begin
	ABitmap.Canvas.BeginScene;
	try
		for i:= 0 to 999 do
			begin
			x:= i mod 40;
			y:= i div 40;

			ABitmap.Canvas.DrawBitmap(C64CharViews[AScreen[i]],
					RectF(0, 0, 8, 8),
					RectF(x * 8 * AScale, y * 8 * AScale,
					x * 8  * AScale + 8 * AScale,
					y * 8  * AScale + 8 * AScale), 1);
			end;

		finally
		ABitmap.Canvas.EndScene;
		end;
	end;

procedure C64ScreenDiff(const AScreen1, AScreen2: TC64Screen;
		out ADiff: TC64ScreenDiff);
	var
	i: Integer;

	begin
	for i:= 0 to High(TC64Screen) do
		if  AScreen1[i] = AScreen2[i] then
			ADiff[i]:= -1
		else
			ADiff[i]:= AScreen2[i];
	end;

procedure C64ScreenDiff2(const AScreen1, AScreen2: TC64Screen;
		out ADiff: TC64ScreenDiff);
	var
	i: Integer;

	begin
	for i:= 0 to High(TC64Screen) do
		if  AScreen1[i] = AScreen2[i] then
			if  AScreen2[i] = C64Frames[0].Screen[i] then
				ADiff[i]:= -2
			else
				ADiff[i]:= -1
		else
			ADiff[i]:= AScreen2[i];
	end;

procedure C64ScreenCopyRecMask(const ASource: TC64Screen; var ADest: TC64Screen;
		const AMask: TC64ScreenDiff; const ASrcRect: TRect;
		const AOffsX, AOffsY: Integer);
	var
	x,
	y: Integer;
	isrc,
	idst: Integer;

	begin
	for x:= ASrcRect.Left to ASrcRect.Right - 1 do
		for y:= ASrcRect.Top to ASrcRect.Bottom - 1 do
			begin
			isrc:= y * 40 + x;
			idst:= (y + AOffsY) * 40 + x + AOffsX;

			if  AMask[isrc] >= 0 then
				ADest[idst]:= ASource[isrc];
			end;
	end;


procedure C64ScreenDiffRLEEncode(ADiff: TC64ScreenDiff; out AData: TC64Bytes);
	var
	c,
	d: Byte;
	i: Integer;

	begin
	SetLength(AData, 0);

	i:= 0;
	while i < SizeOf(TC64ScreenDiff) do
		begin
		if  ADiff[i] < 0 then
			begin
			c:= 0;
			d:= 0;

			while (i < SizeOf(TC64ScreenDiff)) and (d < 255) and (ADiff[i] < 0) do
				begin
				Inc(d);
				Inc(i);
				end;
			end
		else
			begin
			c:= 1;
			d:= ADiff[i];

			Inc(i);
			while (i < SizeOf(TC64ScreenDiff)) and (c < 255) and (ADiff[i] = d) do
				begin
				Inc(c);
				Inc(i);
				end;
			end;

		SetLength(AData, Length(AData) + 2);
		AData[Pred(High(AData))]:= c;
		AData[High(AData)]:= d;
		end;
	end;

procedure C64ScreenDiffRLEEncode3(ADiff: TC64ScreenDiff; out AData: TC64Bytes;
		var AData1, AData2: TC64Bytes);
	var
	c,
	d: Byte;
	i,
	x,
	y: Integer;

	procedure MoveToNext;
		begin
		Inc(y);
		if  y > 24 then
			begin
			y:= 0;
			Inc(x);
			end;
		end;

	begin
	SetLength(AData, 0);

	x:= 0;
	y:= 0;
	repeat
		i:= y * 40 + x;

		if  ADiff[i] < 0 then
			begin
			c:= 0;
			d:= 0;

			while (x < 40) and (d < 255) and (ADiff[i] < 0) do
				begin
				Inc(d);

				MoveToNext;
				i:= y * 40 + x;
				end;
			end
		else
			begin
			c:= 1;
			d:= ADiff[i];

			MoveToNext;
			i:= y * 40 + x;

			while (x < 40) and (c < 255) and (ADiff[i] = d) do
				begin
				Inc(c);

				MoveToNext;
				i:= y * 40 + x;
				end;
			end;

		SetLength(AData, Length(AData) + 2);
		AData[Pred(High(AData))]:= c;
		AData[High(AData)]:= d;

		SetLength(AData1, Length(AData1) + 1);
		AData1[High(AData1)]:= c;
		SetLength(AData2, Length(AData2) + 1);
		AData2[High(AData2)]:= d;
		until (x > 39);

	SetLength(AData, Length(AData) + 2);
	AData[Pred(High(AData))]:= 0;
	AData[High(AData)]:= 0;

	SetLength(AData1, Length(AData1) + 1);
	AData1[High(AData1)]:= 0;
	SetLength(AData2, Length(AData2) + 1);
	AData2[High(AData2)]:= 0;
	end;

procedure C64ScreenDiffRLEEncode2(AScreen: TC64Screen; ADiff: TC64ScreenDiff;
		var AData: TC64Bytes; var AData1: TC64Bytes; var AData2: TC64Bytes);
	var
	c: Integer;
	d: Byte;
	i,
	j,
	x,
	y: Integer;

	procedure MoveToNext;
		begin
		Inc(y);
		if  y > 24 then
			begin
			y:= 0;
			Inc(x);
			end;
		end;

	begin
	SetLength(AData, 0);

	c:= 0;
	x:= 0;
	y:= 0;
	while x < 40 do
		begin
		i:= y * 40 + x;

		if  ADiff[i] < 0 then
			begin
			if  c = 256 then
				begin
				SetLength(AData, Length(AData) + 2);
				AData[Pred(High(AData))]:= c - 1;
				AData[High(AData)]:= AScreen[i];

				SetLength(AData1, Length(AData1) + 1);
				AData1[High(AData1)]:= c - 1;
				SetLength(AData2, Length(AData2) + 1);
				AData2[High(AData2)]:= AScreen[i];

				c:= 0;
				end
			else
				Inc(c);
			end
		else
			begin
			SetLength(AData, Length(AData) + 2);
			AData[Pred(High(AData))]:= c;
			AData[High(AData)]:= ADiff[i];

			SetLength(AData1, Length(AData1) + 1);
			AData1[High(AData1)]:= c;
			SetLength(AData2, Length(AData2) + 1);
			AData2[High(AData2)]:= ADiff[i];

			c:= 0;
			end;

		MoveToNext;
		end;

	SetLength(AData, Length(AData) + 2);
	AData[Pred(High(AData))]:= 0;
	AData[High(AData)]:= 0;

	SetLength(AData1, Length(AData1) + 1);
	AData1[High(AData1)]:= 0;
	SetLength(AData2, Length(AData2) + 1);
	AData2[High(AData2)]:= 0;
	end;

procedure C64ScreenDiffRLEDecode3(ASource: TC64Screen; AData: TC64Bytes;
		const AOffset: Integer; var AScreen: TC64Screen);
	var
	i,
	j: Integer;
	c,
	d: Byte;
	x,
	y,
	p: Integer;

	procedure MoveToNext;
		begin
		Inc(y);
		if  y > 24 then
			begin
			y:= 0;
			Inc(x);
			end;
		end;

	begin
	p:= 0;
	i:= AOffset;

	x:= 0;
	y:= 0;
	while (x < 40) and (i < Length(AData)) do
		begin
		p:= y * 40 + x;

		c:= AData[i];
		d:= AData[i + 1];
		Inc(i, 2);

		if  (c = 0)
		and (d = 0) then
			Exit;

		if  c = 0 then
			for j:= 0 to d - 1 do
				begin
				AScreen[p]:= ASource[p];

				MoveToNext;
				p:= y * 40 + x;
				end
		else
			for j:= 0 to c - 1 do
				begin
				AScreen[p]:= d;

				MoveToNext;
				p:= y * 40 + x;
				end;
		end;
	end;


procedure C64ScreenDiffRLEDecode(ASource: TC64Screen; AData: TC64Bytes;
		const AOffset: Integer; var AScreen: TC64Screen);
	var
	i,
	j: Integer;
	c,
	d: Byte;
	p: Integer;

	begin
	p:= 0;
	i:= AOffset;

	while (p < SizeOf(TC64Screen)) and (i < Length(AData)) do
		begin
		c:= AData[i];
		d:= AData[i + 1];
		Inc(i, 2);

		if  c = 0 then
			for j:= 0 to d - 1 do
				begin
				AScreen[p]:= ASource[p];
				Inc(p);
				end
		else
			for j:= 0 to c - 1 do
				begin
				AScreen[p]:= d;
				Inc(p);
				end;
		end;
	end;

{ TC64Cell }

constructor TC64Cell.Create;
	begin
	View:= TBitmap.Create;
	View.Width:= 320;
	View.Height:= 200;
	end;

destructor TC64Cell.Destroy;
	begin
	View.Free;

	inherited;
	end;



{ TC64FrameClrs }

class function TC64FrameClrs.Bkgrd0: TAlphaColor;
	begin
	Result:= ColourByC64Index(C64Palette[TC64Colour.Bkgrd0]);
	end;

class function TC64FrameClrs.ColourByC64Index(const AIndex: Byte): TAlphaColor;
	begin
	Result:= ARR_VAL_CLR_DEFVICPALETTE[AIndex and $0F];
	end;

class function TC64FrameClrs.Frgrd3: TAlphaColor;
	begin
	Result:= ColourByC64Index(C64Palette[TC64Colour.Frgrd3]);
	end;

class function TC64FrameClrs.Multi1: TAlphaColor;
	begin
	Result:= ColourByC64Index(C64Palette[TC64Colour.Multi1]);;
	end;

class function TC64FrameClrs.Multi2: TAlphaColor;
	begin
	Result:= ColourByC64Index(C64Palette[TC64Colour.Multi2]);;
	end;

procedure ClearNodes;
	var
	i: Integer;

	begin
	for i:= C64AnimNodes.Count - 1 downto 0 do
		C64AnimNodes[i].Free;
	end;

initialization
	Move(ARR_VAL_CLR_DEFC64PALETTE[0], C64Palette[TC64Colour.Bkgrd0], 4);
	C64AnimNodes:= TC64Nodes.Create;

finalization
	ClearNodes;
	C64AnimNodes.Free;



end.
