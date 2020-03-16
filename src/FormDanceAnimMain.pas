unit FormDanceAnimMain;

interface

uses
	System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
	FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,
	FMX.Layouts, FMX.ListBox, FMX.StdCtrls, FMX.Controls.Presentation,
	FMX.TabControl, FMX.Edit, System.Generics.Collections, KrDnceUtilTypes,
	FMX.DateTimeCtrls, FMX.EditBox, FMX.NumberBox, SIDConvTypes, XSIDThread,
	XSIDFiles;

type
	TCompiledFrame = class(TObject)
		OrgFrame: Integer;
		Format: TC64FrameKind;
		Data: TC64Bytes;
	end;

	TCompiledFrames = TList<TCompiledFrame>;

	TDanceAnimMainForm = class(TForm)
		TabControl1: TTabControl;
		TabItem1: TTabItem;
		TabItem2: TTabItem;
		StyleBook1: TStyleBook;
		TabItem3: TTabItem;
		TabItem4: TTabItem;
		TabItem5: TTabItem;
		ToolBar4: TToolBar;
		Button2: TButton;
		Button3: TButton;
		Button1: TButton;
		Panel1: TPanel;
		ToolBar1: TToolBar;
		Button4: TButton;
		Button6: TButton;
		ListBox1: TListBox;
		Panel2: TPanel;
		ToolBar2: TToolBar;
		Button7: TButton;
		Panel3: TPanel;
		ToolBar3: TToolBar;
		Button5: TButton;
		Panel4: TPanel;
		Image1: TImage;
		Button8: TButton;
		Button9: TButton;
		Label1: TLabel;
		Label2: TLabel;
		Edit1: TEdit;
		Button10: TButton;
		Label3: TLabel;
		Label4: TLabel;
		Label5: TLabel;
		Label6: TLabel;
		Label7: TLabel;
		CheckBox1: TCheckBox;
		Label8: TLabel;
		Button11: TButton;
		CheckBox2: TCheckBox;
		Label9: TLabel;
		Label10: TLabel;
		Image2: TImage;
		Label11: TLabel;
		Label12: TLabel;
		Label13: TLabel;
		Label14: TLabel;
		Label15: TLabel;
		Label16: TLabel;
		Label17: TLabel;
		Label18: TLabel;
		ListBox2: TListBox;
		RadioButton1: TRadioButton;
		RadioButton2: TRadioButton;
		RadioButton3: TRadioButton;
		RadioButton4: TRadioButton;
		RadioButton5: TRadioButton;
		Label19: TLabel;
		Button12: TButton;
		Label20: TLabel;
		Label21: TLabel;
		Label22: TLabel;
		Label23: TLabel;
		Label24: TLabel;
		Label25: TLabel;
		Timer1: TTimer;
		TabItem6: TTabItem;
		Panel5: TPanel;
		Label26: TLabel;
		Edit2: TEdit;
		Label27: TLabel;
		Button13: TButton;
		Edit3: TEdit;
		Label28: TLabel;
		Button14: TButton;
		Label29: TLabel;
		Label30: TLabel;
		TimeEdit1: TTimeEdit;
		Panel6: TPanel;
		Label31: TLabel;
		Label32: TLabel;
		CheckBox3: TCheckBox;
		Edit4: TEdit;
		Button15: TButton;
		Label33: TLabel;
		Label34: TLabel;
		Label35: TLabel;
		Label36: TLabel;
		Label37: TLabel;
		Timer2: TTimer;
		NumberBox1: TNumberBox;
		Label38: TLabel;
		procedure Button10Click(Sender: TObject);
		procedure Button6Click(Sender: TObject);
		procedure ListBox1Change(Sender: TObject);
		procedure FormCreate(Sender: TObject);
		procedure Button7Click(Sender: TObject);
		procedure Timer1Timer(Sender: TObject);
		procedure Button5Click(Sender: TObject);
		procedure Button9Click(Sender: TObject);
		procedure Button8Click(Sender: TObject);
		procedure FormDestroy(Sender: TObject);
		procedure Button13Click(Sender: TObject);
		procedure Button15Click(Sender: TObject);
		procedure Timer2Timer(Sender: TObject);
	private
		FLoading: Boolean;

		FCompile: TCompiledFrames;

		FXSIDFile,
		FDumpFile: TBundledFile;

		FBlankFrame: TC64Screen;
		FCurrFrame: Integer;

		FSIDFile: string;
//		FXSIDFile: string;

		FSIDData: TNodeData;

		FSIDTune,
		FConvStep: Integer;

		FXSIDConfig: TXSIDFileConfig;

		procedure DoLibraryNew;

		procedure DoAddStepNodes(const AStart, AEnd: Integer;
				const ALink: TC64CellLink; const AValue: Integer);

		procedure DoShowNode(const ANode: Integer);
		procedure DoClearCompileNodes;

		procedure DoRecalcNodeStartEnd(const ANode: Integer);

		procedure DoLoadSIDFile;
		procedure DoBuildXSIDFIle;

		procedure XSIDLoadCallback(const AStage: TXSIDFileStage;
			const APosition, ASize: Int64);
		procedure XSIDPlayCallback(const AID: Integer;
			const AStats: TXSIDStats);

	public
		{ Public declarations }
	end;

var
	DanceAnimMainForm: TDanceAnimMainForm;

implementation

{$R *.fmx}

uses
	System.IOUtils, SIDPlay, XSIDTypes, DModDanceAnimMain, FormDanceAnimNodes;


const
	ARR_LIT_TOK_CONVSTEPS: array [0..3] of string = (
			'-', '\', '|', '/');


{ TDanceAnimMainForm }

procedure TDanceAnimMainForm.Button10Click(Sender: TObject);
	begin
	if  DanceAnimMainDMod.OpenDlgLibrary.Execute then
		begin
		DoLibraryNew;

		FLoading:= True;

		LoadLibrary(DanceAnimMainDMod.OpenDlgLibrary.FileName);

		C64CharsetRebuild;

		Edit1.Text:= DanceAnimMainDMod.OpenDlgLibrary.FileName;

		Label4.Text:= IntToStr(Length(C64Frames));
		Label6.Text:= IntToStr(Length(C64Steps));

		FLoading:= False;
		end;
	end;

procedure TDanceAnimMainForm.Button13Click(Sender: TObject);
	begin
	if  DanceAnimMainDMod.OpenDlgSongLen.Execute then
		begin
		Edit2.Text:= DanceAnimMainDMod.OpenDlgSongLen.FileName;
		DanceAnimMainDMod.Configuration.SonglenFile:=
				DanceAnimMainDMod.OpenDlgSongLen.FileName;
		LoadSongLengths(DanceAnimMainDMod.OpenDlgSongLen.FileName);
		end;
	end;

procedure TDanceAnimMainForm.Button15Click(Sender: TObject);
	begin
	ConvCountLock.BeginRead;
	try
		if  ConvCount > 0 then
			Exit;

		finally
		ConvCountLock.EndRead;
		end;

	if  Timer2.Enabled then
		Exit;

	if  DanceAnimMainDMod.OpenDlgSIDTune.Execute then
		if  CompareText(Edit4.Text, DanceAnimMainDMod.OpenDlgSIDTune.FileName) <> 0 then
			begin
//			if  FXSIDFile <> '' then
//				TFile.Delete(FXSIDFile);
//			FXSIDFile:= '';
			ClearBundledFile(FXSIDFile);
			FXSIDFile.IsBundled:= False;

			FSIDFile:= DanceAnimMainDMod.OpenDlgSIDTune.FileName;
			DoLoadSIDFile;

			FSIDTune:= FSIDData.header.startSong;

			Edit4.Text:= FSIDFile;
			NumberBox1.Min:= 1;
			NumberBox1.Max:= FSIDData.header.songs;
			NumberBox1.Value:= FSIDData.header.startSong;
			end;
	end;

procedure TDanceAnimMainForm.Button5Click(Sender: TObject);
	var
	pos,
	lastPos: Integer;
	ctx: TXSIDContext;

	begin
	if  FCompile.Count > 0 then
		if  not Timer1.Enabled  then
			begin
			FCurrFrame:= 0;
			Timer1.Enabled:= True;

			if  FXSIDFile.IsBundled then
				begin
				pos:= 0;
				lastPos:= GlobalEvents.Seek(pos, ctx);
				GlobalXSID.RestoreContext(ctx);

				if  lastPos < pos then
					GlobalXSID.Zoom(pos - lastPos);

				GlobalXSID.RunSignal.SetEvent;
				GlobalXSID.PausedSignal.ResetEvent;
				end;
			end;
	end;

procedure TDanceAnimMainForm.Button6Click(Sender: TObject);
	var
	s,
	e: Integer;
	l: TC64CellLink;
	v: Integer;

	begin
	if  DanceAnimNodesForm.ShowAddNodes = mrOk then
		begin
		s:= Round(DanceAnimNodesForm.NumberBox1.Value) - 1;
		if  DanceAnimNodesForm.RadioButton1.IsChecked then
			e:= Round(DanceAnimNodesForm.NumberBox2.Value) - 1
		else
			e:= s;

		l:= cclFromFrames;
		v:= Trunc(DanceAnimNodesForm.NumberBox3.Value);

		DoAddStepNodes(s, e, l, v);
		end;
	end;

procedure TDanceAnimMainForm.Button7Click(Sender: TObject);
	var
	i,
	j,
	k,
	o,
	n: Integer;
	d: TC64ScreenDiff;
	h: Boolean;
	f,
	p: TC64Screen;
	c: TC64Cells;
	m: TCompiledFrame;
	z: TFileStream;
	b1,
	b2,
	b3,
	b4: TC64Bytes;

	procedure DoGenNextFrame(const AFrame, AOffset: Integer; var AScreen: TC64Screen);
		var
		d: TC64ScreenDiff;

		begin
		C64ScreenDiff(C64Frames[0].Screen, C64Frames[AFrame].Screen, d);
		Move(C64Frames[0].Screen[0], AScreen[0], SizeOf(TC64Screen));
		C64ScreenCopyRecMask(C64Frames[AFrame].Screen, AScreen, d,
				Rect(C64Frames[AFrame].StartX, 0, C64Frames[AFrame].EndX + 1, 25),
				AOffset, 0);
		end;

	procedure RLEEncodeBytes(const AInput: TC64Bytes; out AOut: TC64Bytes);
		var
		i: Integer;
		c,
		d: Byte;

		begin
		SetLength(AOut, 0);

		c:= 1;
		d:= AInput[0];
		for i:= 1 to High(AInput) do
			begin
			if  AInput[i] <> d then
				begin
				SetLength(AOut, Length(AOut) + 2);
				AOut[Pred(High(AOut))]:= c;
				AOut[High(AOut)]:= d;

				c:= 1;
				d:= AInput[i];
				end
			else
				begin
				if  c = 255 then
					begin
					SetLength(AOut, Length(AOut) + 2);
					AOut[Pred(High(AOut))]:= c;
					AOut[High(AOut)]:= d;

					c:= 1;
					d:= AInput[i];
					end
				else
					Inc(c);
				end;
			end;

		if  c > 0  then
			begin
			SetLength(AOut, Length(AOut) + 2);
			AOut[Pred(High(AOut))]:= c;
			AOut[High(AOut)]:= d;
			end;
		end;


	begin
	ConvCountLock.BeginRead;
	try
		if  ConvCount > 0 then
			Exit;

		finally
		ConvCountLock.EndRead;
		end;

	if  (FSIDFile <> '')
//	and (FXSIDFIle = '') then
	and (FXSIDFile.TempFile = '') then
		DoBuildXSIDFIle;

	SetLength(b1, 0);
	SetLength(b2, 0);

	if  Length(C64Frames) = 0 then
		Exit;

	Move(C64Frames[0].Screen[0], p[0], SizeOf(TC64Screen));

	DoClearCompileNodes;

	for i:= 0 to C64AnimNodes.Count - 1 do
		begin
		j:= 0;
		k:= 19;
		h:= True;
		while h do
			begin
			if  C64AnimNodes[i].Kind = cckFrame then
				begin
				n:= C64AnimNodes[i].Index;
				o:= C64AnimNodes[i].StartX - C64Frames[n].MidX;

				DoGenNextFrame(n, o, f);

				h:= False;
				end
			else
				begin
				c:= C64Steps[C64AnimNodes[i].Index];
				n:= c[j].Index;

				if  j = 0 then
					begin
					o:= C64AnimNodes[i].StartX - C64Frames[c[0].Index].MidX;
					k:= o;
					end
				else
					o:= k;// + C64Frames[n].MidX;

				DoGenNextFrame(n, o, f);

				Inc(j);
				h:= j < c.Count;
				end;

			m:= TCompiledFrame.Create;
			m.OrgFrame:= n;

			if  FCompile.Count = 0 then
				begin
				m.Format:= cfkRaw;
				SetLength(m.Data, SizeOf(TC64Screen));
				Move(p[0], m.Data[0], SizeOf(TC64Screen));
//				Move(f[0], m.Data[0], SizeOf(TC64Screen));

				m.OrgFrame:= 0;
				FCompile.Add(m);

				m:= TCompiledFrame.Create;
				m.OrgFrame:= n;

				C64ScreenDiff(p, f, d);
				m.Format:= cfkDiffRLE;
				C64ScreenDiffRLEEncode3(d, m.Data, b1, b2);
				end
			else
				begin
				C64ScreenDiff(p, f, d);
				m.Format:= cfkDiffRLE;
				C64ScreenDiffRLEEncode3(d, m.Data, b1, b2);
//				m.Format:= cfkRaw;
//				SetLength(m.Data, SizeOf(TC64Screen));
//				Move(f[0], m.Data[0], SizeOf(TC64Screen));
				end;

//			Move(f[0], p[0], SizeOf(TC64Screen));

			FCompile.Add(m);
			end;
		end;

	Label14.Text:= IntToStr(FCompile.Count);

	o:= 0;
	for i:= 0 to FCompile.Count - 1 do
		Inc(o, Length(FCompile[i].Data));

//	RLEEncodeBytes(b1, b3);
//	RLEEncodeBytes(b2, b4);

	Label16.Text:= IntToStr(o) + '/' + IntToStr(Length(b3) + Length(b4));

	Label24.Text:= IntToStr(Length(b1)) + '/' + IntToStr(Length(b3));
	Label25.Text:= IntToStr(Length(b2)) + '/' + IntToStr(Length(b4));

	z:= TFileStream.Create('test.dat', fmCreate);
	try
		for i:= 0 to FCompile.Count - 1 do
			z.WriteBuffer(FCompile[i].Data[0], Length(FCompile[i].Data));

		finally
		z.Free;
		end;

	z:= TFileStream.Create('test1.dat', fmCreate);
	try
		z.WriteBuffer(b1[0], Length(b1));

		finally
		z.Free;
		end;

	z:= TFileStream.Create('test2.dat', fmCreate);
	try
		z.WriteBuffer(b2[0], Length(b2));

		finally
		z.Free;
		end;

	z:= TFileStream.Create('test3.dat', fmCreate);
	try
		z.WriteBuffer(b3[0], Length(b3));

		finally
		z.Free;
		end;

	z:= TFileStream.Create('test4.dat', fmCreate);
	try
		z.WriteBuffer(b4[0], Length(b4));

		finally
		z.Free;
		end;
	end;

procedure TDanceAnimMainForm.Button8Click(Sender: TObject);
	begin
	if  Timer1.Enabled then
		begin
		if  FXSIDFile.IsBundled then
			begin
			GlobalXSID.RunSignal.ResetEvent;
			GlobalXSID.PausedSignal.WaitFor;
			end;

		Timer1.Enabled:= False;
		end
	else if FCurrFrame > 0 then
		begin
		if  FXSIDFile.IsBundled then
			begin
			GlobalXSID.RunSignal.SetEvent;
			GlobalXSID.PausedSignal.ResetEvent;
			end;

		Timer1.Enabled:= True;
		end;
	end;

procedure TDanceAnimMainForm.Button9Click(Sender: TObject);
	begin
	if  FXSIDFile.IsBundled then
		GlobalXSID.RunSignal.ResetEvent;

	Timer1.Enabled:= False;
	end;

procedure TDanceAnimMainForm.DoAddStepNodes(const AStart, AEnd: Integer;
		const ALink: TC64CellLink; const AValue: Integer);
	var
	i,
	j: Integer;
	c: TC64Cell;
	l: TListBoxItem;

	begin
	ListBox1.Items.BeginUpdate;
	try
		for i:= AStart to AEnd do
			begin
			c:= TC64Cell.Create;

			c.Kind:= cckStep;
			c.Index:= i;

			c.Link:= ALink;
			c.Offset:= AValue;

			j:= C64AnimNodes.Add(c);

			DoRecalcNodeStartEnd(j);

			l:= TListBoxItem.Create(ListBox1);
			l.ItemData.Text:= IntToStr(j + 1);
			l.Tag:= j;
			l.Parent:= ListBox1;
			end;

		finally
		ListBox1.Items.EndUpdate;
		end;

	if  not Assigned(ListBox1.Selected) then
		ListBox1.SelectRange(ListBox1.ListItems[0], ListBox1.ListItems[0]);
	end;

procedure TDanceAnimMainForm.DoBuildXSIDFIle;
	var
	h,
	m,
	s,
	ms: Word;
	tf: Double;
	ti: Cardinal;
//	f: string;
	i: Integer;

(*
 * Load ROM dump from file.
 * Allocate the buffer if file exists, otherwise return 0.
 *)
	function DoLoadRom(path: string; romSize: Cardinal): TMemoryStream;
		begin
		Result:= TMemoryStream.Create;
		Result.LoadFromFile(path);

//		Result.SetSize(romSize);
		end;

	procedure DoDumpFile(ANode: PNodeData; ASong: Integer; ADumpFile: string;
			ADuration: Cardinal);
		var
		play,
		dump,
		tune,
		conf: Pointer;
		kr,
		br,
		cr: TMemoryStream;
		buf: array[0..15] of SmallInt;
		i,
		j: Cardinal;

		begin
		play:= PlayerCreate;

//		Load ROM files
		kr:= DoLoadRom('kernal', 8192);
		br:= DoLoadRom('basic', 8192);
		cr:= DoLoadRom('chargen', 4096);

		PlayerSetROMS(play, PByte(kr.Memory), PByte(br.Memory), PByte(cr.Memory));

		kr.Free;
		br.Free;
		cr.Free;

		dump:= DumpSIDCreate(PAnsiChar('ConvertDump'), PAnsiChar(AnsiString(ADumpFile)));

//		maxsids:= PlayerGetInfoMaxSIDs(play);
		DumpSIDCreateSIDs(dump, {maxsids}1);

		if  not DumpSIDGetStatus(dump) then
			raise Exception.Create(string(DumpSIDGetError(dump)));

		tune:= SIDTuneCreate(PAnsiChar(AnsiString(FSIDFile)));

		if  not SIDTuneGetStatus(tune) then
			raise Exception.Create('Tune Create Failed');

		SIDTuneSelectSong(tune, ASong);

		conf:= SIDConfigCreate;
		SIDConfigSetFrequency(conf, 48000);
		SIDConfigSetSamplingMethod(conf, 0);
		SIDConfigSetFastSampling(conf, False);
		SIDConfigSetPlayback(conf, 1);
		SIDConfigSetSIDEmulation(conf, dump);

		if  not PlayerSetConfig(play, conf) then
			raise Exception.Create(string(PlayerGetError(play)));

		if  not PlayerLoadTune(play, tune) then
			raise Exception.Create(string(PlayerGetError(play)));

		i:= 0;
		while i < ADuration do
			begin
			j:= (i div 8) mod 4;

			if  (i mod 8) = 0 then
				begin
				Label35.Text:= 'Converting...  ' + ARR_LIT_TOK_CONVSTEPS[j];
				Application.ProcessMessages;
				end;

			PlayerPlay(play, @buf[0], 0);
			i:= PlayerGetTime(play);
			end;

		PlayerDestroy(play);
		SIDConfigDestroy(conf);
		SIDTuneDestroy(tune);
		DumpSIDDestroy(dump);
		end;

//	function StripChars(const ACharsToStrip, ASrc: string): string;
//		var
//		c: Char;
//
//		begin
//		Result:= ASrc;
//		for c in ACharsToStrip do
//			Result:= StringReplace(Result, c, '_', [rfReplaceAll, rfIgnoreCase]);
//		end;

	begin
//	FXSIDFile:= TPath.ChangeExtension(TPath.GetTempFileName, 'xsid');
	FDumpFile.TempFile:= TPath.GetTempFileName;

	Label35.Text:= 'Converting...';

	Button3.Enabled:= False;

	DecodeTime(FSIDData.lengths[FSIDTune - 1], h, m, s, ms);
	tf:= h * 3600 + m * 60 + s + ms / 1000;

	ti:= Round(tf);

	FXSIDFile.TempFile:= TPath.ChangeExtension(FDumpFile.TempFile, '.xsid');

	DoDumpFile(@FSIDData, FSIDTune{ + 1}, FDumpFile.TempFile, ti);

//	i:= GetFileSize(f);

	TSIDConvCompCntrl.Create(@FSIDData, FSidTune, scfDetermine, sctLZMA,
			FDumpFile.TempFile);

	FConvStep:= 0;
	Timer2.Enabled:= True;
	end;

procedure TDanceAnimMainForm.DoClearCompileNodes;
	var
	i: Integer;

	begin
	for i:= FCompile.Count - 1 downto 0 do
		FCompile[i].Free;

	FCompile.Clear;
	end;

procedure TDanceAnimMainForm.DoLibraryNew;
	var
	i,
	j: Integer;
	c: TC64Cell;

	begin
	FLoading:= True;

	for i:= 0 to High(C64Frames) do
		if  Assigned(C64Frames[i].GridView) then
			begin
			C64Frames[i].GridView.Free;
			C64Frames[i].GridView:= nil;
			end;

	SetLength(C64Frames, 0);

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

	Edit1.Text:= '';
	Label4.Text:= '';
	Label6.Text:= '';

//	CheckBox1.IsChecked:= False;

	FLoading:= False;
	end;

procedure TDanceAnimMainForm.DoLoadSIDFile;
	function  ReadWordBE(AStream: TStream): Word; inline;
		var
		b1,
		b2: Byte;

		begin
		AStream.Read(b1, 1);
		AStream.Read(b2, 1);
		Result:= (b1 shl 8) or b2;
		end;

	function  ReadCardinalBE(AStream: TStream): Cardinal; inline;
		var
		b1,
		b2,
		b3,
		b4: Word;

		begin
		AStream.Read(b1, 1);
		AStream.Read(b2, 1);
		AStream.Read(b3, 1);
		AStream.Read(b4, 1);
		Result:= (b1 shl 24) or (b2 shl 16) or (b3 shl 8) or b4;
		end;

	procedure DoProcessFile(const AFile: string);
		const
		NL: AnsiString = #13#10;

		var
		f: TFileStream;
		s1,
		s2: AnsiString;
		j: Integer;
		v: Word;
		t: TTime;
		i: Integer;

		begin
		FSIDData.fileIndex:= 0;

		f:= TFileStream.Create(AFile, fmOpenRead);
		try
			f.Read(FSIDData.header.tag, 4);
			FSIDData.header.version:= ReadWordBE(f);
			FSIDData.header.dataOffset:= ReadWordBE(f);
			FSIDData.header.loadAddress:= ReadWordBE(f);
			FSIDData.header.initAddress:= ReadWordBE(f);
			FSIDData.header.playAddress:= ReadWordBE(f);
			FSIDData.header.songs:= ReadWordBE(f);
			FSIDData.header.startSong:= ReadWordBE(f);
			FSIDData.header.speedFlags:= ReadCardinalBE(f);

			FSIDData.updateRate:= 4;

			f.Read(FSIDData.header.name, 32);
			f.Read(FSIDData.header.author, 32);
			f.Read(FSIDData.header.released, 32);

			if  FSIDData.header.version >= 2 then
				FSIDData.header.flags:= ReadWordBE(f)
			else
				FSIDData.header.flags:= 0;

			f.Seek(FSIDData.header.dataOffset + 2, soFromBeginning);
			SIDPlayComputeStreamMD5(f, FSIDData.header, FSIDData.md5);

			finally
			f.Free;
			end;

		if  FSIDData.header.version >= 2 then
			begin
			v:= (FSIDData.header.flags and $30) shr 4;
			if  v = 3 then
				FSIDData.sidType:= 0
			else
				FSIDData.sidType:= v;
			end
		else
			FSIDData.sidType:= 0;

		FSIDData.caption:= string(FSIDData.header.author) + ' - ' +
				string(FSIDData.header.name);
		if  FSIDData.header.startSong > 0 then
			Include(FSIDData.selected, FSIDData.header.startSong - 1);

		if  not SongLengths.TryGetValue(FSIDData.md5, FSIDData.details) then
			FSIDData.details:= nil;

		SetLength(FSIDData.lengths, FSIDData.header.songs);


//!!FIXME
//		Use default value
		t:= EncodeTime(0, 3, 0, 0);


		for i:= 0 to FSIDData.header.songs - 1 do
			begin
			if  Assigned(FSIDData.details)
			and (FSIDData.details.Count > i) then
				FSIDData.lengths[i]:= FSIDData.details[i].time
			else
				FSIDData.lengths[i]:= t;
			end;

		SetLength(FSIDData.sidParams, FSIDData.header.songs);
		SetLength(FSIDData.metaData, FSIDData.header.songs);

		s1:= FSIDData.header.name + NL + FSIDData.header.author + NL +
				FSIDData.header.name + NL;
		s2:= Copy(FSIDData.header.released, 1, 4);
		if  not TryStrToInt(string(s2), j) then
			s2:= '';
		s2:= s2 + NL + 'copyright=' + FSIDData.header.released;

		for j:= 0 to FSIDData.header.songs - 1 do
			FSIDData.metaData[j]:= string(s1) + Format('%2.2d', [j + 1]) + string(NL) +
					string(s2);

		end;

	begin
	DoProcessFile(FSIDFile);
	end;

procedure TDanceAnimMainForm.DoRecalcNodeStartEnd(const ANode: Integer);
	var
	i: Integer;
	s: TC64Step;

	begin
	if  C64AnimNodes[ANode].Kind = cckFrame then
		case C64AnimNodes[ANode].Link of
			cclFromFrames:
				begin
				C64AnimNodes[ANode].StartX:= C64Frames[C64AnimNodes[ANode].Index].MidX;
				C64AnimNodes[ANode].EndX:= C64AnimNodes[ANode].StartX;
				end;
			cclSmartLink:
				begin
				if  ANode = 0 then
					i:= 19
				else if C64AnimNodes[ANode - 1].Kind = cckFrame then
					i:= C64Frames[C64AnimNodes[ANode - 1].Index].MidX
				else
					i:= C64AnimNodes[ANode - 1].EndX;

				C64AnimNodes[ANode].StartX:= i;
				C64AnimNodes[ANode].EndX:= i;
				end;
			cclHardCentre:
				begin
				C64AnimNodes[ANode].StartX:= 19;
				C64AnimNodes[ANode].EndX:= 19;
				end;
			cclCustom:
				begin
				C64AnimNodes[ANode].StartX:= C64AnimNodes[ANode].Offset;
				C64AnimNodes[ANode].EndX:= C64AnimNodes[ANode].Offset;
				end;
			end
	else
		case C64AnimNodes[ANode].Link of
			cclFromFrames:
				begin
				s:= C64Steps[C64AnimNodes[ANode].Index];
				C64AnimNodes[ANode].StartX:= C64Frames[s[0].Index].MidX;
				C64AnimNodes[ANode].EndX:= C64Frames[s[s.Count - 1].Index].MidX;
				end;
			cclSmartLink:
				begin
				if  ANode = 0 then
					i:= 19
				else if C64AnimNodes[ANode - 1].Kind = cckFrame then
					i:= C64Frames[C64AnimNodes[ANode - 1].Index].MidX
				else
					i:= C64AnimNodes[ANode - 1].EndX;

				s:= C64Steps[C64AnimNodes[ANode].Index];

				C64AnimNodes[ANode].StartX:= i;
				C64AnimNodes[ANode].EndX:= i +
						(C64Frames[s[s.Count - 1].Index].MidX -
						C64Frames[s[0].Index].MidX);
				end;
			cclHardCentre:
				begin
				C64AnimNodes[ANode].StartX:= 19;
				C64AnimNodes[ANode].EndX:= 19;
				end;
			cclCustom:
				begin
				i:= C64AnimNodes[ANode].Offset;
				s:= C64Steps[C64AnimNodes[ANode].Index];

				C64AnimNodes[ANode].StartX:= i;
				C64AnimNodes[ANode].EndX:= i +
						(C64Frames[s[s.Count - 1].Index].MidX -
						C64Frames[s[0].Index].MidX);
				end;
			end

	end;

procedure TDanceAnimMainForm.DoShowNode(const ANode: Integer);
	var
	c: TC64Cell;
	b: TBitmap;
	d: TC64ScreenDiff;
	s: TC64Screen;
	f: TC64Frame;
	o: Integer;

	begin
	c:= C64AnimNodes[ANode];

	if  c.Kind = cckFrame then
		begin
		Label11.Text:= '1';
		CheckBox2.IsChecked:= True;

		f:= C64Frames[c.Index];
		end
	else
		begin
		Label11.Text:= IntToStr(C64Steps[c.Index].Count);
		CheckBox2.IsChecked:= False;

		f:= C64Frames[C64Steps[c.Index][0].Index];
		end;

	Label21.Text:= IntToStr(c.StartX);
	Label23.Text:= IntToStr(c.EndX);

	b:= TBitmap.Create;
	try
		b.Width:= 320;
		b.Height:= 200;

		C64ScreenDiff(C64Frames[0].Screen, f.Screen, d);

		Move(C64Frames[0].Screen[0], s[0], SizeOf(TC64Screen));

		o:= c.StartX - f.MidX;

		C64ScreenCopyRecMask(f.Screen, s, d, Rect(f.StartX, 0, f.EndX + 1, 25),
				o, 0);

		C64ScreenPaint(s, b);

		Image2.Bitmap.Width:= 320;
		Image2.Bitmap.Height:= 200;

		Image2.Bitmap.CopyFromBitmap(b);

		finally
		b.Free;
		end;
	end;

procedure TDanceAnimMainForm.FormCreate(Sender: TObject);
	begin
	FCompile:= TCompiledFrames.Create;

	FXSIDFile:= TBundledFile.Create;
	FDumpFile:= TBundledFile.Create;

	SetLength(BundledFiles, 4);
	BundledFiles[2]:= FXSIDFile;
	BundledFiles[3]:= FDumpFile;

	Edit2.Text:= DanceAnimMainDMod.Configuration.SonglenFile;
	end;

procedure TDanceAnimMainForm.FormDestroy(Sender: TObject);
	begin
	ClearBundledFiles;

	FXSIDFile.Free;
	FDumpFile.Free;

	DoClearCompileNodes;
	FCompile.Free;
	end;

procedure TDanceAnimMainForm.ListBox1Change(Sender: TObject);
	begin
	if  Assigned(ListBox1.Selected) then
		DoShowNode(ListBox1.Selected.Tag);
	end;

procedure TDanceAnimMainForm.Timer1Timer(Sender: TObject);
	var
	s: TC64Screen;
	b: TBitmap;

	begin
	if  FCurrFrame >= FCompile.Count then
		FCurrFrame:= 0;

	if  FCurrFrame = 0 then
		begin
		Move(FCompile[0].Data[0], FBlankFrame[0], SizeOf(TC64Screen));
		Inc(FCurrFrame);
		end;

	Move(FBlankFrame[0], s[0], SizeOf(TC64Screen));
	C64ScreenDiffRLEDecode3(FBlankFrame, FCompile[FCurrFrame].Data, 0,
			s);

	b:= TBitmap.Create;
	try
		b.Width:= 320;
		b.Height:= 200;

		C64ScreenPaint(s, b);

		Image1.Bitmap.Width:= 320;
		Image1.Bitmap.Height:= 200;

		Image1.Bitmap.CopyFromBitmap(b);

		finally
		b.Free;
		end;

	Inc(FCurrFrame);
	end;

procedure TDanceAnimMainForm.Timer2Timer(Sender: TObject);
	var
	cnt: Integer;
	f: string;
	l: TList;
	pos,
	lastPos: Integer;
	ctx: TXSIDContext;

	begin
	ConvCountLock.BeginRead;
	try
		cnt:= ConvPending;

		finally
		ConvCountLock.EndRead;
		end;

	if  cnt = 0 then
		begin
		Label35.Text:= 'Built.  ' + FXSIDFile.TempFile;

		f:= TPath.GetFileNameWithoutExtension(FSIDFile) + '_' +
				IntToStr(FSIDTune) + '.xsid';

		ClearBundledFile(FDumpFile);
		BundleFile(f, FXSIDFile.TempFile, FXSIDFile);

		Label37.Text:= IntToStr(FXSIDFile.Data.Size);

		if  Assigned(GlobalXSID) then
			begin
			GlobalXSID.RunSignal.ResetEvent;
			GlobalXSID.PausedSignal.WaitFor(INFINITE);

			GlobalXSIDStop;
			end;

		l:= TList.Create;
		try
			XSIDLoadFileXSID(FXSIDFile.TempFile, l, XSIDLoadCallback, FXSIDConfig);

			DanceAnimMainDMod.InitConfigForXSIDFile(FXSIDConfig);
			GlobalXSIDStart(DanceAnimMainDMod.PlayConfig, XSIDPlayCallback);

			GlobalXSID.RunSignal.ResetEvent;
			GlobalXSID.PausedSignal.WaitFor(INFINITE);

			GlobalEvents.ClearEvents;
			GlobalEvents.CopyEvents(l);

//			Make sounds stop at end
			GlobalEvents.AddEvent(2, 4, 0);
			GlobalEvents.AddEvent(2, 11, 0);
			GlobalEvents.AddEvent(2, 18, 0);

			finally
			l.Free;
			end;

		pos:= 0;
		lastPos:= GlobalEvents.Seek(pos, ctx);
		GlobalXSID.RestoreContext(ctx);

		if  lastPos < pos then
			GlobalXSID.Zoom(pos - lastPos);

		Label35.Text:= 'Ready.';

		Timer2.Enabled:= False;
		end
	else
		begin
		Label35.Text:= 'Processing...  ' + ARR_LIT_TOK_CONVSTEPS[FConvStep];

		Inc(FConvStep);
		if  FConvStep > High(ARR_LIT_TOK_CONVSTEPS) then
			FConvStep:= 0;
		end;
	end;

procedure TDanceAnimMainForm.XSIDLoadCallback(const AStage: TXSIDFileStage;
		const APosition, ASize: Int64);
	begin
	Label35.Text:= 'Loading...  ' + ARR_LIT_TOK_CONVSTEPS[FConvStep];

	Inc(FConvStep);
	if  FConvStep > High(ARR_LIT_TOK_CONVSTEPS) then
		FConvStep:= 0;
	end;

procedure TDanceAnimMainForm.XSIDPlayCallback(const AID: Integer;
		const AStats: TXSIDStats);
	begin

	end;

end.
