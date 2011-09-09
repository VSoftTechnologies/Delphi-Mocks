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
  protected
    function GetDefaultReturnValue : TValue;
    function GetBehaviors : TList<IBehavior>;
    function GetHitCount : integer;

    procedure RecordHit(const Args: TArray<TValue>; const returnType : TRttiType; out Result : TValue);

    procedure WillReturnDefault(const returnValue : TValue);
    procedure WillReturnWhen(const Args: TArray<TValue>; const returnValue : TValue);

    procedure WillRaiseAlways(const exceptionClass : ExceptClass);
    procedure WillRaiseWhen(const exceptionClass : ExceptClass;const Args: TArray<TValue>);

    procedure WillExecute(const func : TExecuteFunc);
    procedure WillExecuteWhen(const func : TExecuteFunc; const Args: TArray<TValue>);

    function FindBehavior(const behaviorType : TBehaviorType; const Args: TArray<TValue>) : IBehavior;overload;
    function FindBehavior(const behaviorType : TBehaviorType) : IBehavior; overload;

    function FindBestBehavior(const Args: TArray<TValue>) : IBehavior;


  public
    constructor Create(const AMethodName : string);
    destructor Destroy;override;
  end;

implementation

uses
  Delphi.Mocks.Behavior;

{ TMethodData }

constructor TMethodData.Create(const AMethodName : string);
begin
  FMethodName := AMethodName;
  FBehaviors := TList<IBehavior>.Create;
  FReturnDefault := TValue.Empty;
  FHitCount := 0;
end;

destructor TMethodData.Destroy;
begin
  FBehaviors.Free;
  inherited;
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

  result := nil;

end;

function TMethodData.GetBehaviors: TList<IBehavior>;
begin
  result := FBehaviors;
end;

function TMethodData.GetDefaultReturnValue: TValue;
begin
  result := FReturnDefault;
end;

function TMethodData.GetHitCount: Integer;
begin
  result := FHitCount;
end;

procedure TMethodData.RecordHit(const Args: TArray<TValue>; const returnType : TRttiType; out Result: TValue);
var
  behavior : IBehavior;
  returnVal : TValue;
begin
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
