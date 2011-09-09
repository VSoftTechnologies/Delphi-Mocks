unit Delphi.Mocks.Behavior;

interface

uses
  Rtti,
  SysUtils,
  Delphi.Mocks,
  Delphi.Mocks.Interfaces;

type
  TBehavior = class(TInterfacedObject,IBehavior)
  private
    FAction : TExecuteFunc;
    FExceptClass : ExceptClass;
    FReturnValue : TValue;
    FArgs : TArray<TValue>;
    FBehaviorType : TBehaviorType;
  protected
    function GetBehaviorType: TBehaviorType;
    function Match(const Args: TArray<TValue>): Boolean;
    function Execute(const Args: TArray<TValue>; const returnType: TRttiType): TValue;
    procedure CopyArgs(const Args: TArray<TValue>);
  public
    constructor CreateWillExecute(const AAction: TExecuteFunc);
    constructor CreateWillExecuteWhen(const Args: TArray<TValue>; const AAction: TExecuteFunc );
    constructor CreateWillReturnWhen(const Args: TArray<TValue>; const ReturnValue: TValue);
    constructor CreateReturnDefault(const ReturnValue: TValue);
    constructor CreateWillRaise(const AExceptClass : ExceptClass);
    constructor CreateWillRaiseWhen(const Args: TArray<TValue>; const AExceptClass : ExceptClass);
  end;

implementation

uses
  Delphi.Mocks.Helpers;

{ TBehavior }

procedure TBehavior.CopyArgs(const Args: TArray<TValue>);
begin
  SetLength(FArgs,Length(args));
  if Length(args) > 0 then
    CopyArray(@FArgs[0],@args[0],TypeInfo(TValue),Length(args));
end;

constructor TBehavior.CreateReturnDefault(const ReturnValue: TValue);
begin
  FBehaviorType := TBehaviorType.ReturnDefault;
  FReturnValue := ReturnValue;
end;

constructor TBehavior.CreateWillExecute(const AAction: TExecuteFunc);
begin
  FBehaviorType := TBehaviorType.WillExecute;
  FAction := AAction;
end;

constructor TBehavior.CreateWillExecuteWhen(const Args: TArray<TValue>; const AAction: TExecuteFunc);
begin
  FBehaviorType := TBehaviorType.WillExecuteWhen;
  CopyArgs(Args);
  FAction := AAction;
end;

constructor TBehavior.CreateWillRaise(const AExceptClass: ExceptClass);
begin
  FBehaviorType := TBehaviorType.WillRaiseAlways;
  FExceptClass := AExceptClass;
end;

constructor TBehavior.CreateWillRaiseWhen(const Args: TArray<TValue>; const AExceptClass: ExceptClass);
begin
  FBehaviorType := TBehaviorType.WillRaise;
  FExceptClass := AExceptClass;
  CopyArgs(Args);

end;

constructor TBehavior.CreateWillReturnWhen(const Args: TArray<TValue>; const ReturnValue: TValue);
begin
  FBehaviorType := TBehaviorType.WillReturn;
  CopyArgs(Args);
  FReturnValue := ReturnValue;
end;

function TBehavior.Execute(const Args: TArray<TValue>; const returnType: TRttiType): TValue;
begin
  result := TValue.Empty;
  case FBehaviorType of
    WillReturn: result := FReturnValue;
    ReturnDefault: result := FReturnValue;
    WillRaise,WillRaiseAlways:
    begin
       if FExceptClass <> nil then
        raise FExceptClass.Create('raised by mock');
    end;
    WillExecute,WillExecuteWhen:
    begin
      if Assigned(FAction) then
        result := FAction(args,returnType);
    end;
  end;

end;

function TBehavior.GetBehaviorType: TBehaviorType;
begin
  Result := FBehaviorType;
end;



function TBehavior.Match(const Args: TArray<TValue>): Boolean;

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
  result := False;
  case FBehaviorType of
    WillReturn      : result := MatchArgs;
    ReturnDefault   : result := True;
    WillRaise       :
    begin
      result := MatchArgs;
      if FExceptClass <> nil then
        raise FExceptClass.Create('Raised by Mock');
    end;
    WillRaiseAlways : result := True;
    WillExecuteWhen :  result := MatchArgs;
    WillExecute     : result := True;
  end;
end;

end.
