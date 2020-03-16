unit C64Thread;

{$IFDEF FPC}
	{$MODE DELPHI}
{$ENDIF}
{$H+}

interface

uses
	Classes, SyncObjs, C64Types;

type
{ TC64SystemThread }

	TC64SystemThread = class(TThread)
	protected
//		FLock: TCriticalSection;
		FRunSignal: TSimpleEvent;
		FPausedSignal: TSimpleEvent;

		FWasPaused: Boolean;

		FCycPSec: Cardinal;
		FIntrval: Double;

		FCycPUpd: TC64Float;
		FCycResidual: TC64Float;

		FRefreshCnt: Integer;
		FRefreshUpd: Integer;
		FCycRefresh: Cardinal;

		FThsDiff,
		FLstIntrv,
		FThsIntrv,
		FThsComp,
		FLstCompI: Double;

		FCmpOffs,
		FCmpTick: cycle_count;

		FLstTick,
		FThsTick: cycle_count;

		FDelayCount: Cardinal;

		FName: string;
		FFreeRun: Boolean;

		procedure DoConstruction; virtual; abstract;
		procedure DoDestruction; virtual; abstract;
		procedure DoClock(const ATicks: Cardinal); virtual; abstract;
		procedure DoPause; virtual; abstract;
		procedure DoPlay; virtual; abstract;

		procedure UpdateFrontEnd(const ATicks: Cardinal; const ACount: Integer); virtual;

		procedure Execute; override;

	public
		constructor Create(const ASystemType: TC64SystemType;
				const AUpdateRate: TC64UpdateRate);
		destructor  Destroy; override;

		property  RunSignal: TSimpleEvent read FRunSignal;
		property  PausedSignal: TSimpleEvent read FPausedSignal;

//		procedure Lock;
//		procedure Unlock;

		procedure SetDelayCount(const ACycles: Cardinal);
	end;


implementation

uses
	SysUtils;


const
	ARR_VAL_CNT_UPDRATE: array[TC64UpdateRate] of Integer =
			(16, 8, 4, 2, 1);


{ TC64SystemThread }

procedure TC64SystemThread.UpdateFrontEnd(const ATicks: Cardinal;
		const ACount: Integer);
	begin

	end;

procedure TC64SystemThread.Execute;
	var
	doCyclesF: TC64Float;
	doCyclesI: cycle_count;
//	delyCount: Integer;
//	actCyclesF: TC64Float;
//	actCycles: cycle_count;
	delyFact: Integer;

	begin
//	FLock:= TCriticalSection.Create;
	FRunSignal:= TSimpleEvent.Create;
	FRunSignal.SetEvent;

	FPausedSignal:= TSimpleEvent.Create;
	FPausedSignal.ResetEvent;

//	doTicks:= 0;

	FThsTick:= 0;
	FLstTick:= 0;

	FCmpOffs:= 0;
	FCmpTick:= 0;

	FCycResidual:= 0;
	FRefreshCnt:= 0;

//	It seems that we have to call this here.  See the constructor.
	DoConstruction;

	FLstIntrv:= C64TimerGetTime;
	FLstCompI:= FLstIntrv;

	while not Terminated do
		begin
		FThsIntrv:= C64TimerGetTime;

		FThsDiff:= FThsIntrv - FLstIntrv;
		if  FThsDiff < 0 then
			begin
//			UpdateFrontEnd;
			Continue;
			end;

		doCyclesF:= FCycPUpd + FCycResidual;
		doCyclesI:= Trunc(doCyclesF);
		FCycResidual:= doCyclesF - doCyclesI;

		if  FRunSignal.WaitFor(0) = wrSignaled then
			begin
			if  FWasPaused then
				begin
				FWasPaused:= False;
				DoPlay;
				end;

			delyFact:= FDelayCount;
//			actCyclesF:= doCyclesI;
//
//			if  actCyclesF < 1 then
//				begin
//				Inc(delyCount);
//				actCycles:= 0;
//				end
//			else
//				begin
//				actCycles:= Trunc(actCyclesF) + delyCount;
//				delyCount:= 0;
//				end;
//
//			if  actCycles > 0 then
				DoClock(doCyclesI);

			if  delyFact > 1 then
				Sleep(Trunc(doCyclesI * delyFact * FIntrval * 1000));

		Inc(FRefreshCnt, FRefreshUpd);
		if  FRefreshCnt > 15 then
			begin
			FThsIntrv:= C64TimerGetTime;
			FThsDiff:= FThsIntrv - FLstIntrv;

//				FThsTick:= Round(FThsDiff / FIntrval);
//				Dec(FThsTick, FCycRefresh);

//dengland      I am having trouble getting this to work.  I think this calculation
//              of free time is correct but it may be colliding with wait for buffer
//              sleeping in the audio??  I think I may have to run the audio buffer
//              handling in a different thread to the SID?  I wonder if it would pay
//              off then.  Perhaps I could collect metrics about delays spent and
//				factor those in???
//
//              -- Update:  Halving the expected value seems to work well?  Nah...

				FThsTick:= Trunc((FCycRefresh * FIntrval - FThsDiff) * 500);

				FRefreshCnt:= 0;

//			UpdateFrontEnd;
			if  FThsTick <= 0 then
				begin
				FLstIntrv:= FThsIntrv;
				Continue;
				end
			else
				begin
//					if  not FFreeRun then

//dengland              Can't do this at the moment
//						Sleep(FThsTick);



//dengland              High accuracy alternative
//					C64Wait(Abs(FThsTick) * FIntrval);

				FLstIntrv:= C64TimerGetTime;
				end;
			end;
			end
		else if not (FPausedSignal.WaitFor(0) = wrSignaled) then
			begin
			FWasPaused:= True;
			FPausedSignal.SetEvent;
			DoPause;
			end
		else
			begin
			FRunSignal.WaitFor(100);
			FLstIntrv:= C64TimerGetTime;
			FRefreshCnt:= 0;
			end;
		end;

	DoDestruction;
	FPausedSignal.Free;
	FRunSignal.Free;
//	FLock.Free;
	end;

procedure TC64SystemThread.SetDelayCount(const ACycles: Cardinal);
	begin
	FDelayCount:= ACycles;
	end;

constructor TC64SystemThread.Create(const ASystemType: TC64SystemType;
		const AUpdateRate: TC64UpdateRate);
	begin
//	We can't call DoConstruction here because the memory doesn't seem to get
//		allocated in a way in which we can use it if we do...  Annoying.

	FRefreshUpd:= ARR_VAL_CNT_UPDRATE[AUpdateRate];
	FCycRefresh:= Trunc(ARR_VAL_SYSCYCPRFS[ASystemType]);
	FCycPUpd:= FCycRefresh / (1 shl Ord(AUpdateRate));

	FCycPSec:= ARR_VAL_SYSCYCPSEC[ASystemType];
	FIntrval:= (1 / FCycPSec);

    FDelayCount:= 1;

	inherited Create(False);
	end;

destructor TC64SystemThread.Destroy;
	begin
//	Don't call DoDestruction here because we aren't calling DoConstruction in
//		the constructor.

	inherited Destroy;
	end;

//procedure TC64SystemThread.Lock;
//	begin
//	FLock.Acquire;
//	end;

//procedure TC64SystemThread.Unlock;
//	begin
//	FLock.Release;
//	end;

end.

