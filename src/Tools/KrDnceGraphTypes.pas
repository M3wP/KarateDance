unit KrDnceGraphTypes;

interface

uses
	System.Types, System.UITypes, FMX.Graphics, FMX.ImgList;



function  ImageListAdd(AImgList: TImageList; ABitmap: TBitmap): Integer;
procedure ImageListReplace(AImgList: TImageList; AIndex: Integer;
		ABitmap: TBitmap);



implementation

uses
	FMX.MultiResBitmap;


function  ImageListAdd(AImgList: TImageList; ABitmap: TBitmap): Integer;
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

procedure ImageListReplace(AImgList: TImageList; AIndex: Integer;
		ABitmap: TBitmap);
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

end.
