unit DModDanceAnimMain;

interface

uses
  System.SysUtils, System.Classes, System.ImageList, FMX.ImgList, FMX.Types,
  FMX.Dialogs;

type
  TDanceAnimMainDMod = class(TDataModule)
    ImgLstStandard: TImageList;
    ImgLstCategories: TImageList;
    OpenDlgLibrary: TOpenDialog;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  DanceAnimMainDMod: TDanceAnimMainDMod;

implementation

{%CLASSGROUP 'FMX.Controls.TControl'}

{$R *.dfm}

end.
