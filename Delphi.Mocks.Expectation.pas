unit Delphi.Mocks.Expectation;

interface


uses
  Rtti,
  Delphi.Mocks,
  Delphi.Mocks.Interfaces;

type
  TExpectation = class(TInterfacedObject,IExpectation)
  private
    FExpectationType        : TExpectationType;
    FArgs                   : TArray<TValue>;
    FExpectationMet         : boolean;
    FBeforeAfterMethodName  : string;
    FBetween                : array[0..1] of Cardinal;
    FTimes                  : Cardinal;
    FHitCount               : Cardinal;
    FMethodName             : string;
  protected
    function GetExpectationType : TExpectationType;
    function GetExpectationMet : boolean;
    function Match(const Args : TArray<TValue>) : boolean;
    procedure RecordHit;
    function Report : string;
    procedure CopyArgs(const Args: TArray<TValue>);
    constructor Create(const AMethodName : string);
    constructor CreateWhen(const AMethodName : string; const Args: TArray<TValue>);
  public
    constructor CreateOnceWhen(const AMethodName : string; const Args : TArray<TValue>);
    constructor CreateOnce(const AMethodName : string);

    constructor CreateNeverWhen(const AMethodName : string; const Args : TArray<TValue>);
    constructor CreateNever(const AMethodName : string);

    constructor CreateAtLeastOnceWhen(const AMethodName : string; const Args : TArray<TValue>);
    constructor CreateAtLeastOnce(const AMethodName : string);

    constructor CreateAtLeastWhen(const AMethodName : string; const times : Cardinal; const Args : TArray<TValue>);
    constructor CreateAtLeast(const AMethodName : string; const times : Cardinal);

    constructor CreateAtMostWhen(const AMethodName : string; const times : Cardinal; const Args : TArray<TValue>);
    constructor CreateAtMost(const AMethodName : string; const times : Cardinal);

    constructor CreateBetweenWhen(const AMethodName : string; const a,b : Cardinal; const Args : TArray<TValue>);
    constructor CreateBetween(const AMethodName : string; const a,b : Cardinal);

    constructor CreateExactlyWhen(const AMethodName : string; const times : Cardinal; const Args : TArray<TValue>);
    constructor CreateExactly(const AMethodName : string; const times : Cardinal);

    constructor CreateBeforeWhen(const AMethodName : string; const ABeforeMethodName : string ; const Args : TArray<TValue>);
    constructor CreateBefore(const AMethodName : string; const ABeforeMethodName : string);

    constructor CreateAfterWhen(const AMethodName : string; const AAfterMethodName : string;const Args : TArray<TValue>);
    constructor CreateAfter(const AMethodName : string; const AAfterMethodName : string);

  end;



implementation

uses
  Delphi.Mocks.Helpers;

{ TExpectation }

procedure TExpectation.CopyArgs(const Args: TArray<TValue>);
begin
  SetLength(FArgs,Length(args));
  if Length(args) > 0 then
    CopyArray(@FArgs[0],@args[0],TypeInfo(TValue),Length(args));
end;

constructor TExpectation.Create(const AMethodName : string);
begin
  FExpectationMet := False;
  FHitCount := 0;
  FMethodName := AMethodName;
end;

constructor TExpectation.CreateWhen(const AMethodName: string; const Args: TArray<TValue>);
begin
  FExpectationMet := False;
  FHitCount := 0;
  FMethodName := AMethodName;
  CopyArgs(Args);
end;



constructor TExpectation.CreateAfter(const AMethodName : string; const AAfterMethodName: string);
begin
  Create(AMethodName);
  FExpectationType := TExpectationType.After;
  FBeforeAfterMethodName := AAfterMethodName;
end;

constructor TExpectation.CreateAfterWhen(const AMethodName : string; const AAfterMethodName: string;  const Args: TArray<TValue>);
begin
  CreateWhen(AMethodName,Args);
  FExpectationType := TExpectationType.AfterWhen;
  FBeforeAfterMethodName := AAfterMethodName;
end;

constructor TExpectation.CreateAtLeast(const AMethodName : string; const times: Cardinal);
begin
  Create(AMethodName);
  FExpectationType := TExpectationType.AtLeast;
  FTimes := times;
end;

constructor TExpectation.CreateAtLeastOnce(const AMethodName : string);
begin
  Create(AMethodName);
  FExpectationType := TExpectationType.AtLeastOnce;
  FTimes := 1;
end;

constructor TExpectation.CreateAtLeastOnceWhen(const AMethodName : string; const Args: TArray<TValue>);
begin
  CreateWhen(AMethodName,Args);
  FExpectationType := TExpectationType.AtLeastOnceWhen;
  FTimes := 1;
end;

constructor TExpectation.CreateAtLeastWhen(const AMethodName : string; const times: Cardinal; const Args: TArray<TValue>);
begin
  CreateWhen(AMethodName,Args);
  FExpectationType := TExpectationType.AtLeastWhen;
  FTimes := times;
end;

constructor TExpectation.CreateAtMost(const AMethodName : string; const times: Cardinal);
begin
  Create(AMethodName);
  FExpectationType := TExpectationType.AtMost;
  FTimes := times;
end;

constructor TExpectation.CreateAtMostWhen(const AMethodName : string; const times: Cardinal; const Args: TArray<TValue>);
begin
  CreateWhen(AMethodName,Args);
  FExpectationType := TExpectationType.AtMostWhen;
  FTimes := times;
end;

constructor TExpectation.CreateBefore(const AMethodName : string; const ABeforeMethodName: string);
begin
  Create(AMethodName);
  FExpectationType  := TExpectationType.Before;
  FBeforeAfterMethodName  := ABeforeMethodName;
end;

constructor TExpectation.CreateBeforeWhen(const AMethodName : string; const ABeforeMethodName: string; const Args: TArray<TValue>);
begin
  CreateWhen(AMethodName,Args);
  FExpectationType := TExpectationType.BeforeWhen;
  FBeforeAfterMethodName := ABeforeMethodName;
end;

constructor TExpectation.CreateBetween(const AMethodName : string; const a, b: Cardinal);
begin
  Create(AMethodName);
  FExpectationType := TExpectationType.Between;
  FBetween[0] := a;
  FBetween[1] := b;
end;

constructor TExpectation.CreateBetweenWhen(const AMethodName : string; const a, b: Cardinal; const Args: TArray<TValue>);
begin
  CreateWhen(AMethodName,Args);
  FExpectationType := TExpectationType.BetweenWhen;
  FBetween[0] := a;
  FBetween[1] := b;
end;

constructor TExpectation.CreateExactly(const AMethodName : string; const times: Cardinal);
begin
  Create(AMethodName);
  FExpectationType := TExpectationType.Exactly;
  FTimes := times;
end;

constructor TExpectation.CreateExactlyWhen(const AMethodName : string; const times: Cardinal; const Args: TArray<TValue>);
begin
  CreateWhen(AMethodName,Args);
  FExpectationType := TExpectationType.ExactlyWhen;
  FTimes := times;
end;

constructor TExpectation.CreateNever(const AMethodName : string) ;
begin
  Create(AMethodName);
  FExpectationType := TExpectationType.NeverWhen;
  FExpectationMet := True;
end;

constructor TExpectation.CreateNeverWhen(const AMethodName : string; const Args: TArray<TValue>);
begin
  CreateWhen(AMethodName,Args);
  FExpectationType := TExpectationType.NeverWhen;
  FExpectationMet := True;
end;

constructor TExpectation.CreateOnce(const AMethodName : string );
begin
  Create(AMethodName);
  FExpectationType := TExpectationType.Once;
  FTimes := 1;
end;

constructor TExpectation.CreateOnceWhen(const AMethodName : string; const Args: TArray<TValue>);
begin
  CreateWhen(AMethodName,Args);
  FExpectationType := TExpectationType.OnceWhen;
  FTimes := 1;
end;

function TExpectation.GetExpectationMet: boolean;
begin
  result := FExpectationMet;
end;

function TExpectation.GetExpectationType: TExpectationType;
begin
  result := FExpectationType;
end;

function TExpectation.Match(const Args: TArray<TValue>): boolean;

  function MatchArgs : boolean;
  var
    i : integer;
  begin
    result := False;
    if Length(Args) <> Length(FArgs) then
      exit;
    for i := 0 to Length(args) -1 do
    begin
      if not FArgs[i].Equals(args[i]) then
        exit;
    end;
    result := True;
  end;

begin

end;

procedure TExpectation.RecordHit;
begin
  Inc(FHitCount);
  case FExpectationType of
    Once: FExpectationMet := FHitCount = FTimes;
    OnceWhen: ;
    Never: ;
    NeverWhen: ;
    AtLeastOnce: ;
    AtLeastOnceWhen: ;
    AtLeast: ;
    AtLeastWhen: ;
    AtMostOnce: ;
    AtMostOnceWhen: ;
    AtMost: ;
    AtMostWhen: ;
    Between: ;
    BetweenWhen: ;
    Exactly: ;
    ExactlyWhen: ;
    Before: ;
    BeforeWhen: ;
    After: ;
    AfterWhen: ;
  end;

end;

function TExpectation.Report: string;
begin
  result := '';
  if not FExpectationMet then
  begin
     case FExpectationType of
       Once: ;
       OnceWhen: ;
       Never: ;
       NeverWhen: ;
       AtLeastOnce: ;
       AtLeastOnceWhen: ;
       AtLeast: ;
       AtLeastWhen: ;
       AtMostOnce: ;
       AtMostOnceWhen: ;
       AtMost: ;
       AtMostWhen: ;
       Between: ;
       BetweenWhen: ;
       Exactly: ;
       ExactlyWhen: ;
       Before: ;
       BeforeWhen: ;
       After: ;
       AfterWhen: ;
     end;
  end;

end;

end.
