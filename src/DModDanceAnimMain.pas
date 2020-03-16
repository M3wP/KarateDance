unit DModDanceAnimMain;

interface

uses
	System.SysUtils, System.Classes, System.ImageList, FMX.ImgList, FMX.Types,
	FMX.Dialogs, System.IniFiles, XSIDTypes, XSIDFiles;

type
	TDanceAnimConfig = class(TObject)
	private
		FSonglenFile: string;
		FDefaultLen: TTime;

		procedure SetDefaultLen(const AValue: TTime);

	public
		constructor Create;
		destructor  Destroy; override;

		procedure SaveToIniFile(const AFileName: string);
		procedure LoadFromIniFile(const AFileName: string);

		property  SonglenFile: string read FSonglenFile write FSonglenFile;
		property  DefaultLen: TTime read FDefaultLen write SetDefaultLen;
	end;

	TDanceAnimMainDMod = class(TDataModule)
		ImgLstStandard: TImageList;
		ImgLstCategories: TImageList;
		OpenDlgLibrary: TOpenDialog;
		OpenDlgSongLen: TOpenDialog;
		OpenDlgSIDTune: TOpenDialog;
		procedure DataModuleCreate(Sender: TObject);
		procedure DataModuleDestroy(Sender: TObject);
	private
		FConfig: TDanceAnimConfig;
		FPlayConfig: TXSIDConfig;

	public
		procedure InitConfigForXSIDFile(AFileConfig: TXSIDFileConfig);

		property  Configuration: TDanceAnimConfig read FConfig;
		property  PlayConfig: TXSIDConfig read FPlayConfig;
	end;

var
	DanceAnimMainDMod: TDanceAnimMainDMod;

implementation

{%CLASSGROUP 'FMX.Controls.TControl'}

{$R *.dfm}

uses
	System.IOUtils, FMX.Forms, C64Types, SIDConvTypes, XSIDPlatform,
	FMX.Platform.Win;

{ TDanceAnimConfig }

constructor TDanceAnimConfig.Create;
	begin
	inherited Create;

	FDefaultLen:= EncodeTime(0, 3, 0, 0);
	end;

destructor TDanceAnimConfig.Destroy;
	begin

	inherited;
	end;

procedure TDanceAnimConfig.LoadFromIniFile(const AFileName: string);
	var
	ini: TIniFile;

	begin
	ini:= TIniFile.Create(AFileName);
	try
		FSonglenFile:= ini.ReadString('Dependencies', 'SonglenFile', '');
		FDefaultLen:= ini.ReadTime('Defaults', 'DefaultLen',
				EncodeTime(0, 3, 0, 0));

		finally
		ini.Free;
		end;
	end;

procedure TDanceAnimConfig.SaveToIniFile(const AFileName: string);
	var
	ini: TIniFile;

	begin
	ini:= TIniFile.Create(AFileName);
	try
		ini.WriteString('Dependencies', 'SonglenFile', FSonglenFile);
		ini.WriteTime('Defaults', 'DefaultLen', FDefaultLen);

		finally
		ini.Free;
		end;
	end;

procedure TDanceAnimConfig.SetDefaultLen(const AValue: TTime);
	var
	h,
	m,
	s,
	ms: Word;

	begin
	DecodeTime(AValue, h, m, s, ms);

	FDefaultLen:= EncodeTime(0, m, s, 0);
	end;

procedure TDanceAnimMainDMod.DataModuleCreate(Sender: TObject);
	var
	f: string;

	begin
	f:= TPath.ChangeExtension(ParamStr(0), '.ini');

	FConfig:= TDanceAnimConfig.Create;
	FConfig.LoadFromIniFile(f);

	InitialiseConfig(f);

	FPlayConfig:= TXSIDConfig.Create;

	if  FConfig.SonglenFile <> '' then
		LoadSongLengths(FConfig.SonglenFile);
	end;

procedure TDanceAnimMainDMod.DataModuleDestroy(Sender: TObject);
	var
	f: string;
	ini: TIniFile;

	begin
	FPlayConfig.Free;

	f:= TPath.ChangeExtension(ParamStr(0), '.ini');
	FConfig.SaveToIniFile(f);

	FinaliseConfig(f);
	end;

procedure TDanceAnimMainDMod.InitConfigForXSIDFile(
		AFileConfig: TXSIDFileConfig);
	var
	p: TStringList;

	begin
	FPlayConfig.Assign(GlobalConfig);

	p:= TStringList.Create;
	try
		p.Add('Handle=' + IntToStr(WindowHandleToPlatform(
				Application.MainForm.Handle).wnd));

		FPlayConfig.SetRenderParams(p);

		finally
		p.Free;
		end;

	if  not FPlayConfig.SystemOverride
	and (AFileConfig.System > cstUnknown) then
		FPlayConfig.System:= AFileConfig.System;

	if  not FPlayConfig.UpdateRateOverride then
		FPlayConfig.UpdateRate:= AFileConfig.UpdateRate;

	if  not FPlayConfig.ModelOverride
	and (AFileConfig.Model > csmAny) then
		FPlayConfig.Model:= AFileConfig.Model;

	FPlayConfig.FilterEnable:= AFileConfig.FilterEnable;
	FPlayConfig.Filter6581:= AFileConfig.Filter6581;
	FPlayConfig.Filter8580:= AFileConfig.Filter8580;
	FPlayConfig.DigiBoostEnable:= AFileConfig.DigiBoostEnable;
	end;

end.
