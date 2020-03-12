unit DModStepsLibMain;

interface

uses
	System.SysUtils, System.Classes, System.ImageList, FMX.ImgList;

type
	TStepsLibMainDMod = class(TDataModule)
		ImgLstStandard: TImageList;
		ImgLstC64Palette: TImageList;
		procedure DataModuleCreate(Sender: TObject);
	private
		{ Private declarations }
	public
		{ Public declarations }
	end;

var
	StepsLibMainDMod: TStepsLibMainDMod;

implementation

{%CLASSGROUP 'FMX.Controls.TControl'}

{$R *.dfm}

uses
	System.Types, System.UITypes, FMX.Graphics, KrDnceGraphTypes, KrDnceUtilTypes;


procedure TStepsLibMainDMod.DataModuleCreate(Sender: TObject);
	var
	i: Integer;
	b: TBitmap;

	begin
	b:= TBitmap.Create;
	try
		b.Width:= 16;
		b.Height:= 16;

		for i:= 0 to 15 do
			begin
			b.Clear(TAlphaColorRec.Null);

			b.Canvas.BeginScene;
			try
				b.Canvas.Stroke.Kind:= TBrushKind.Solid;
				b.Canvas.Stroke.Color:= TAlphaColorRec.Black;
				b.Canvas.Stroke.Thickness:= 1;

				b.Canvas.Fill.Kind:= TBrushKind.Solid;
				b.Canvas.Fill.Color:= TC64FrameClrs.ColourByC64Index(i);

				b.Canvas.FillRect(RectF(1, 1, 14, 14), 0, 0, [], 1);

				finally
				b.Canvas.EndScene;
				end;

			ImageListAdd(ImgLstC64Palette, b);
			end;

		finally
		b.Free;
		end;
	end;

end.
