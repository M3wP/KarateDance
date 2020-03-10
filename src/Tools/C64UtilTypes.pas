unit C64UtilTypes;

{$DEFINE LITTLE_ENDIAN}

interface

uses
	System.Types, System.Generics.Collections, System.UITypes, FMX.Graphics;

const
	LIT_4CC_KDNCEPROJ: AnsiString = 'KRDN';
	LIT_4CC_KDNCEFRME: AnsiString = 'KDFR';
	LIT_4CC_KDNCESTEP: AnsiString = 'KDST';

type
	TC64Char = array[0..7] of Byte;

	TC64Colour = (Bkgrd0, Multi1, Multi2, Frgrd3);

	TC64Colours = array[0..3] of TC64Colour;

	TCharsetMatches = array[0..255] of Boolean;


	TC64FrameClrs = record
	const
		Bkgrd0 = TAlphaColorRec.Alpha or TAlphaColor($000000);
		Multi1 = TAlphaColorRec.Alpha or TAlphaColor($C77F75);
		Multi2 = TAlphaColorRec.Alpha or TAlphaColor($4335AD);
		Frgrd3 = TAlphaColorRec.Alpha or TAlphaColor($FFFFFF);
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

	TC64FrameKind = (cfkRaw, cfkDiffRLE);

	TC64Cell = class(TObject)
	public
		Kind: TC64CellKind;
		Index: Integer;
		Offset: Integer;
		View: TBitmap;

		constructor Create;
		destructor  Destroy; override;
	end;

	TC64Cells = TList<TC64Cell>;

	TC64Step = TList<TC64Cell>;
	TC64Steps = array of TC64Step;

	TC64Bytes = array of Byte;

	TKarateDanceProj = packed record
		VerHi: Byte;
		VerLo: Byte;
		Reserved: Word;
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


function  C64ColorsToIndex(const AColours: TC64Colours): Byte;
procedure IndexToC64Colours(const AIndex: Byte; out AColours: TC64Colours);

//procedure C64CharToColours(const AChar: Byte; out AColours: TC64Colours);
procedure ColoursToC64Char(const AColours: TC64Colours;
		out AChar: TC64Char);


procedure C64ScreenPaint(const AScreen: TC64Screen; ABitmap: TBitmap;
		const AScale: Integer = 1);

procedure C64ScreenDiff(const AScreen1, AScreen2: TC64Screen;
		out ADiff: TC64ScreenDiff);

procedure C64ScreenCopyRecMask(const ASource: TC64Screen; var ADest: TC64Screen;
		const AMask: TC64ScreenDiff; const ASrcRect: TRect;
		const AOffsX: Integer = 0; const AOffsY: Integer = 0);

procedure C64ScreenDiffRLEEncode(ADiff: TC64ScreenDiff; out AData: TC64Bytes);
procedure C64ScreenDiffRLEDecode(ASource: TC64Screen; AData: TC64Bytes;
		const AOffset: Integer; var AScreen: TC64Screen);

procedure SaveProject(const AFileName: string);
procedure LoadProject(const AFileName: string);


implementation

uses
	System.Classes, System.SysUtils;

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


function ToNetworkCardinal(const AValue: Cardinal): Cardinal;
{$IFDEF LITTLE_ENDIAN}
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
{$IFDEF LITTLE_ENDIAN}
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
{$IFDEF LITTLE_ENDIAN}
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
{$IFDEF LITTLE_ENDIAN}
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
{$IFDEF LITTLE_ENDIAN}
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
{$IFDEF LITTLE_ENDIAN}
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


procedure SaveProject(const AFileName: string);
	var
	f: TFileStream;
	p: TKarateDanceProj;
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

		Move(C64Frames[0].Screen[0], p.Screen[0], SizeOf(TC64Screen));

		WriteChunk(f, LIT_4CC_KDNCEPROJ, PByte(@p), SizeOf(TKarateDanceProj));

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

procedure LoadProject(const AFileName: string);
	var
	f: TFileStream;
	b: Byte;
	i: Integer;
	c: TKarateDanceChnk;
	d: TC64Bytes;
	p: TKarateDanceProj;
	r: TKarateDanceFrme;
	s: TKarateDanceStep;
	l: TC64Cell;

	begin
	f:= TFileStream.Create(AFileName, fmOpenRead);
	try
		ReadChunk(f, c);

		if  (c.Size <> SizeOf(TKarateDanceProj))
		or  (CompareText(string(c.Ident), string(LIT_4CC_KDNCEPROJ)) <> 0)  then
			raise Exception.Create('Invalid Project File!');

		f.ReadBuffer(p, SizeOf(TKarateDanceProj));
		if  (c.Size mod 2) > 0 then
			f.Read(b, 1);

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



end.
