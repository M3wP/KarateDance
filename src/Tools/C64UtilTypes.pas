unit C64UtilTypes;

interface

uses
	System.Types, System.Generics.Collections, System.UITypes, FMX.Graphics;

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

	TC64CellKind = (cckFrame, cckMove);

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


implementation

uses
	System.SysUtils;


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
			ADiff[i]:= AScreen1[i];
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
