unit Delphi.Mocks.MethodData;

interface

uses
  Rtti,
  SysUtils,
  Generics.Collections,
  Delphi.Mocks,
  Delphi.Mocks.Interfaces;

type
  TMethodData = class(TInterfacedObject,IMethodData)
  private
    FMethodName : string;
    FBehaviors : TList<IBehavior>;
    FReturnDefault : TValue;
    FHitCount     : integer;
    FExpectations : TList<IExpectation>;
  protected

    //Behaviors
    procedure WillReturnDefault(const returnValue : TValue);
    procedure WillReturnWhen(const Args: TArray<TValue>; const returnValue : TValue);
    procedure WillRaiseAlways(const exceptionClass : ExceptClass);
    procedure WillRaiseWhen(const exceptionClass : ExceptClass;const Args: TArray<TValue>);
    procedure WillExecute(const func : TExecuteFunc);
    procedure WillExecuteWhen(const func : TExecuteFunc; const Args: TArray<TValue>);

    function FindBehavior(const behaviorType : TBehaviorType; const Args: TArray<TValue>) : IBehavior;overload;
    function FindBehavior(const behaviorType : TBehaviorType) : IBehavior; overload;
    function FindBestBehavior(const Args: TArray<TValue>) : IBehavior;
    procedure RecordHit(const Args: TArray<TValue>; const returnType : TRttiType; out Result : TValue);



    //Expectations
    function FindExpectation(const expectationType : TExpectationType; const Args: TArray<TValue>) : IExpectation;overload;
    function FindExpectation(const expectationTypes : TExpectationTypes) : IExpectation;overload;

    procedure OnceWhen(const Args : TArray<TValue>);
    procedure Once;
    procedure NeverWhen(const Args : TArray<TValue>);
    procedure Never;
    procedure AtLeastOnceWhen(const Args : TArray<TValue>);
    procedure AtLeastOnce;
    procedure AtLeastWhen(const times : Cardinal; const Args : TArray<TValue>);
    procedure AtLeast(const times : Cardinal);
    procedure AtMostWhen(const times : Cardinal; const Args : TArray<TValue>);
    procedure AtMost(const times : Cardinal);
    procedure BetweenWhen(const a,b : Cardinal; const Args : TArray<TValue>);
    procedure Between(const a,b : Cardinal);
    procedure ExactlyWhen(const times : Cardinal; const Args : TArray<TValue>);
    procedure Exactly(const times : Cardinal);
    procedure BeforeWhen(const ABeforeMethodName : string ; const Args : TArray<TValue>);
    procedure Before(const ABeforeMethodName : string);
    procedure AfterWhen(const AAfterMethodName : string;const Args : TArray<TValue>);
    procedure After(const AAfterMethodName : string);

  public
    constructor Create(const AMethodName : string);
    destructor Destroy;override;
  end;

implementation

uses
  Delphi.Mocks.Behavior,
  Delphi.Mocks.Expectation;



{ TMethodData }

procedure TMethodData.After(const AAfterMethodName: string);
begin

end;

procedure TMethodData.AfterWhen(const AAfterMethodName: string;const Args: TArray<TValue>);
begin

end;

procedure TMethodData.AtLeast(const times: Cardinal);
begin

end;

procedure TMethodData.AtLeastOnce;
begin

end;

procedure TMethodData.AtLeastOnceWhen(const Args: TArray<TValue>);
begin

end;

procedure TMethodData.AtLeastWhen(const times: Cardinal; const Args: TArray<TValue>);
begin

end;

procedure TMethodData.AtMost(const times: Cardinal);
begin

end;

procedure TMethodData.AtMostWhen(const times: Cardinal;
  const Args: TArray<TValue>);
begin

end;

procedure TMethodData.Before(const ABeforeMethodName: string);
begin

end;

procedure TMethodData.BeforeWhen(const ABeforeMethodName: string;
  const Args: TArray<TValue>);
begin

end;

procedure TMethodData.Between(const a, b: Cardinal);
begin

end;

procedure TMethodData.BetweenWhen(const a, b: Cardinal;
  const Args: TArray<TValue>);
begin

end;

constructor TMethodData.Create(const AMethodName : string);
begin
  FMethodName := AMethodName;
  FBehaviors := TList<IBehavior>.Create;
  FExpectations := TList<IExpectation>.Create;
  FReturnDefault := TValue.Empty;
  FHitCount := 0;
end;

destructor TMethodData.Destroy;
begin
  FBehaviors.Free;
  FExpectations.Free;
  inherited;
end;

procedure TMethodData.Exactly(const times: Cardinal);
begin

end;

procedure TMethodData.ExactlyWhen(const times: Cardinal;
  const Args: TArray<TValue>);
begin

end;

function TMethodData.FindBehavior(const behaviorType: TBehaviorType; const Args: TArray<TValue>): IBehavior;
var
  behavior : IBehavior;
begin
  result := nil;
  for behavior in FBehaviors do
  begin
    if behavior.BehaviorType = behaviorType then
    begin
      if behavior.Match(Args) then
      begin
        result := behavior;
        exit;
      end;
    end;
  end;
end;

function TMethodData.FindBehavior(const behaviorType: TBehaviorType): IBehavior;
var
  behavior : IBehavior;
begin
  result := nil;
  for behavior in FBehaviors do
  begin
    if behavior.BehaviorType = behaviorType then
    begin
      result := behavior;
      exit;
    end;
  end;
end;

function TMethodData.FindBestBehavior(const Args: TArray<TValue>): IBehavior;
begin
  //First see if we have an always throws;
  result := FindBehavior(TBehaviorType.WillRaiseAlways);
  if Result <> nil then
    exit;

  //then find an always execute
  result := FindBehavior(TBehaviorType.WillExecute);
  if Result <> nil then
    exit;

  result := FindBehavior(TBehaviorType.WillExecuteWhen,Args);
  if Result <> nil then
    exit;

  result := FindBehavior(TBehaviorType.WillReturn,Args);
  if Result <> nil then
    exit;

  result := FindBehavior(TBehaviorType.ReturnDefault,Args);
  if Result <> nil then
    exit;

  result := nil;

end;


function TMethodData.FindExpectation(const expectationType : TExpectationType; const Args: TArray<TValue>): IExpectation;
var
  expectation : IExpectation;
begin
  result := nil;
  for expectation in FExpectations do
  begin
    if expectation.ExpectationType = expectationType then
    begin
      if expectation.Match(Args) then
      begin
        result := expectation;
        exit;
      end;
    end;
  end;
end;

function TMethodData.FindExpectation(const expectationTypes : TExpectationTypes): IExpectation;
var
  expectation : IExpectation;
begin
  result := nil;
  for expectation in FExpectations do
  begin
    if expectation.ExpectationType in expectationTypes then
    begin
      result := expectation;
      exit;
    end;
  end;
end;

procedure TMethodData.Never;
var
  expectation : IExpectation;
begin
  expectation := FindExpectation([TExpectationType.Never ,TExpectationType.NeverWhen]);
  if expectation <> nil then
    raise EMockException.Create('Expectation Never already defined on method : ' + FMethodName);

  expectation := TExpectation.CreateNever(FMethodName);
  FExpectations.Add(expectation);
end;

procedure TMethodData.NeverWhen(const Args: TArray<TValue>);
var
  expectation : IExpectation;
begin
  expectation := FindExpectation(TExpectationType.NeverWhen,Args);
  if expectation <> nil then
    raise EMockException.Create('Expectation Never already defined for these args on method : ' + FMethodName);
  expectation := TExpectation.CreateNeverWhen(FMethodName,Args);
  FExpectations.Add(expectation);
end;

procedure TMethodData.Once;
var
  expectation : IExpectation;
begin
  expectation := FindExpectation([TExpectationType.Once,TExpectationType.OnceWhen]);
  if expectation <> nil then
    raise EMockException.Create('Expectation Once already defined on method : ' + FMethodName);
  expectation := TExpectation.CreateOnce(FMethodName);
  FExpectations.Add(expectation);
end;

procedure TMethodData.OnceWhen(const Args: TArray<TValue>);
var
  expectation : IExpectation;
begin
  expectation := FindExpectation(TExpectationType.OnceWhen,Args);
  if expectation <> nil then
    raise EMockException.Create('Expectation Once already defined for these args on method : ' + FMethodName);
  expectation := TExpectation.CreateOnceWhen(FMethodName,Args);
  FExpectations.Add(expectation);
end;

procedure TMethodData.RecordHit(const Args: TArray<TValue>; const returnType : TRttiType; out Result: TValue);
var
  behavior : IBehavior;
  returnVal : TValue;
begin
  Inc(FHitCount);
  behavior := FindBestBehavior(Args);
  if behavior <> nil then
    returnVal := behavior.Execute(Args,returnType)
  else
  begin
    if (returnType <> nil) and (FReturnDefault.IsEmpty) then
      raise EMockException.Create('No default return value defined for method ' + FMethodName);
    returnVal := FReturnDefault;
  end;
  if returnType <> nil then
    Result := returnVal;
end;

procedure TMethodData.WillExecute(const func: TExecuteFunc);
var
  behavior : IBehavior;
begin
  behavior := FindBehavior(TBehaviorType.WillExecute);
  if behavior <> nil then
    raise EMockSetupException.Create('WillExecute already defined for ' + FMethodName );
  behavior := TBehavior.CreateWillExecute(func);
  FBehaviors.Add(behavior);
end;

procedure TMethodData.WillExecuteWhen(const func: TExecuteFunc;const Args: TArray<TValue>);
var
  behavior : IBehavior;
begin
  behavior := FindBehavior(TBehaviorType.WillExecuteWhen,Args);
  if behavior <> nil then
    raise EMockSetupException.Create('WillExecute.When already defined with these parameters for method ' + FMethodName );
  behavior := TBehavior.CreateWillExecuteWhen(Args, func);
  FBehaviors.Add(behavior);
end;

procedure TMethodData.WillRaiseAlways(const exceptionClass: ExceptClass);
var
  behavior : IBehavior;
begin
  behavior := FindBehavior(TBehaviorType.WillRaiseAlways);
  if behavior <> nil then
    raise EMockSetupException.Create('WillRaise already defined for method ' + FMethodName );
  behavior := TBehavior.CreateWillRaise(exceptionClass);
  FBehaviors.Add(behavior);
end;

procedure TMethodData.WillRaiseWhen(const exceptionClass: ExceptClass; const Args: TArray<TValue>);
var
  behavior : IBehavior;
begin
  behavior := FindBehavior(TBehaviorType.WillRaise,Args);
  if behavior <> nil then
    raise EMockSetupException.Create('WillRaise.When already defined for method ' + FMethodName );
  behavior := TBehavior.CreateWillRaiseWhen(Args,exceptionClass);
  FBehaviors.Add(behavior);
end;

procedure TMethodData.WillReturnDefault(const returnValue: TValue);
begin
  if not FReturnDefault.IsEmpty then
    raise EMockSetupException.Create('Default return Value already specified for ' + FMethodName);
  FReturnDefault := returnValue;
end;

procedure TMethodData.WillReturnWhen(const Args: TArray<TValue>; const returnValue: TValue);
var
  behavior : IBehavior;
begin
  behavior := FindBehavior(TBehaviorType.WillReturn,Args);
  if behavior <> nil then
    raise EMockSetupException.Create('WillReturn.When already defined with these parameters for method ' + FMethodName );
  behavior := TBehavior.CreateWillReturnWhen(Args,returnValue);
  FBehaviors.Add(behavior);
end;

end.
