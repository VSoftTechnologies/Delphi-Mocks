{***************************************************************************}
{                                                                           }
{           Delphi.Mocks                                                    }
{                                                                           }
{           Copyright (C) 2011 Vincent Parrett                              }
{                                                                           }
{           http://www.finalbuilder.com                                     }
{                                                                           }
{                                                                           }
{***************************************************************************}
{                                                                           }
{  Licensed under the Apache License, Version 2.0 (the "License");          }
{  you may not use this file except in compliance with the License.         }
{  You may obtain a copy of the License at                                  }
{                                                                           }
{      http://www.apache.org/licenses/LICENSE-2.0                           }
{                                                                           }
{  Unless required by applicable law or agreed to in writing, software      }
{  distributed under the License is distributed on an "AS IS" BASIS,        }
{  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. }
{  See the License for the specific language governing permissions and      }
{  limitations under the License.                                           }
{                                                                           }
{***************************************************************************}

unit Delphi.Mocks.MethodData;

{$I 'Delphi.Mocks.inc'}


interface

uses
  Rtti,
  SysUtils,
  Generics.Collections,
  Delphi.Mocks,
  Delphi.Mocks.Interfaces,
  Delphi.Mocks.ParamMatcher;

type
  TSetupMethodDataParameters = record
    BehaviorMustBeDefined  : boolean;
    AllowRedefineBehaviorDefinitions: boolean;
    IsStub: boolean;
    class function Create(const AIsStub: boolean; const ABehaviorMustBeDefined, AAllowRedefineBehaviorDefinitions: boolean): TSetupMethodDataParameters; static;
  end;

  TMethodData = class(TInterfacedObject,IMethodData)
  private
    FTypeName      : string;
    FMethodName     : string;
    FBehaviors      : TList<IBehavior>;
    FReturnDefault  : TValue;
    FExpectations   : TList<IExpectation>;
    FSetupParameters: TSetupMethodDataParameters;
    FAutoMocker     : IAutoMock;
    procedure StubNoBehaviourRecordHit(const Args: TArray<TValue>; const AExpectationHitCtr : Integer; const returnType : TRttiType; out Result : TValue);
    procedure MockNoBehaviourRecordHit(const Args: TArray<TValue>; const AExpectationHitCtr : Integer; const returnType : TRttiType; out Result : TValue);
  protected

    //Behaviors
    procedure WillReturnDefault(const returnValue : TValue);
    procedure WillReturnWhen(const Args: TArray<TValue>; const returnValue : TValue; const matchers : TArray<IMatcher>);
    procedure WillRaiseAlways(const exceptionClass : ExceptClass; const message : string);
    procedure WillRaiseWhen(const exceptionClass : ExceptClass; const message : string;const Args: TArray<TValue>; const matchers : TArray<IMatcher>);
    procedure WillExecute(const func : TExecuteFunc);
    procedure WillExecuteWhen(const func : TExecuteFunc; const Args: TArray<TValue>; const matchers : TArray<IMatcher>);

    function FindBehavior(const behaviorType : TBehaviorType; const Args: TArray<TValue>) : IBehavior; overload;
    function FindBehavior(const behaviorType : TBehaviorType) : IBehavior; overload;
    function FindBestBehavior(const Args: TArray<TValue>) : IBehavior;
    procedure RecordHit(const Args: TArray<TValue>; const returnType : TRttiType; out Result : TValue);

    //Expectations
    function FindExpectation(const expectationType : TExpectationType; const Args: TArray<TValue>) : IExpectation;overload;
    function FindExpectation(const expectationTypes : TExpectationTypes) : IExpectation;overload;

    procedure OnceWhen(const Args : TArray<TValue>; const matchers : TArray<IMatcher>);
    procedure Once;
    procedure NeverWhen(const Args : TArray<TValue>; const matchers : TArray<IMatcher>);
    procedure Never;
    procedure AtLeastOnceWhen(const Args : TArray<TValue>; const matchers : TArray<IMatcher>);
    procedure AtLeastOnce;
    procedure AtLeastWhen(const times : Cardinal; const Args : TArray<TValue>; const matchers : TArray<IMatcher>);
    procedure AtLeast(const times : Cardinal);
    procedure AtMostWhen(const times : Cardinal; const Args : TArray<TValue>; const matchers : TArray<IMatcher>);
    procedure AtMost(const times : Cardinal);
    procedure BetweenWhen(const a,b : Cardinal; const Args : TArray<TValue>; const matchers : TArray<IMatcher>);
    procedure Between(const a,b : Cardinal);
    procedure ExactlyWhen(const times : Cardinal; const Args : TArray<TValue>; const matchers : TArray<IMatcher>);
    procedure Exactly(const times : Cardinal);
    procedure BeforeWhen(const ABeforeMethodName : string ; const Args : TArray<TValue>; const matchers : TArray<IMatcher>);
    procedure Before(const ABeforeMethodName : string);
    procedure AfterWhen(const AAfterMethodName : string;const Args : TArray<TValue>; const matchers : TArray<IMatcher>);
    procedure After(const AAfterMethodName : string);

    function Verify(var report : string) : boolean;
  public
    constructor Create(const ATypeName : string; const AMethodName : string; const ASetupParameters: TSetupMethodDataParameters; const AAutoMocker : IAutoMock = nil);
    destructor Destroy;override;
  end;

  {$IFNDEF DELPHI_XE_UP}
  ENotImplemented = class(Exception);
  {$ENDIF}

implementation

uses
  Windows,
  System.TypInfo,
  Delphi.Mocks.Utils,
  Delphi.Mocks.Behavior,
  Delphi.Mocks.Expectation;



{ TMethodData }


constructor TMethodData.Create(const ATypeName : string; const AMethodName : string; const ASetupParameters: TSetupMethodDataParameters; const AAutoMocker : IAutoMock = nil);
begin
  FTypeName := ATypeName;
  FMethodName := AMethodName;
  FBehaviors := TList<IBehavior>.Create;
  FExpectations := TList<IExpectation>.Create;
  FReturnDefault := TValue.Empty;
  FSetupParameters := ASetupParameters;
  FAutoMocker := AAutoMocker;
end;

destructor TMethodData.Destroy;
begin
  FBehaviors.Free;
  FExpectations.Free;
  inherited;
end;

procedure TMethodData.Exactly(const times: Cardinal);
var
  expectation : IExpectation;
begin
  expectation := FindExpectation([TExpectationType.Exactly,TExpectationType.ExactlyWhen]);
  if (expectation <> nil)  AND (not FSetupParameters.AllowRedefineBehaviorDefinitions)  then
    raise EMockException.Create(Format('[%s] already defines Expectation Exactly for method [%s]', [FTypeName, FMethodName]))
  else if expectation <> nil then
    FExpectations.Remove(expectation);

  expectation := TExpectation.CreateExactly(FMethodName,times);
  FExpectations.Add(expectation);
end;

procedure TMethodData.ExactlyWhen(const times: Cardinal; const Args: TArray<TValue>; const matchers : TArray<IMatcher>);
var
  expectation : IExpectation;
begin
  expectation := FindExpectation(TExpectationType.ExactlyWhen,Args);
  if (expectation <> nil) AND (not FSetupParameters.AllowRedefineBehaviorDefinitions)  then
    raise EMockException.Create(Format('[%s] already defines Expectation Exactly for method [%s] with args.', [FTypeName, FMethodName]))
  else if expectation <> nil then
    FExpectations.Remove(expectation);

  expectation := TExpectation.CreateExactlyWhen(FMethodName, times, Args, matchers);
  FExpectations.Add(expectation);
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

  result := FindBehavior(TBehaviorType.WillRaise, Args);
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

procedure TMethodData.MockNoBehaviourRecordHit(const Args: TArray<TValue>; const AExpectationHitCtr : Integer; const returnType: TRttiType; out Result: TValue);
var
  behavior : IBehavior;
  mock : IProxy;
begin
  Result := TValue.Empty;

  //If auto mocking has been turned on and this return type is either a class or interface, mock it.
  if FAutoMocker <> nil then
  begin
    //TODO: Add more options for how to handle properties and procedures.
    if returnType = nil then
      Exit;

    case returnType.TypeKind of
      tkClass,
      tkRecord,
      tkInterface:
      begin
        mock := FAutoMocker.Mock(returnType.Handle);
        result := TValue.From<IProxy>(mock);

        //Add a behaviour to return the value next time.
        behavior := TBehavior.CreateWillReturnWhen(Args, Result, TArray<IMatcher>.Create());
        FBehaviors.Add(behavior);
      end
    else
      Result := FReturnDefault;
    end;

    Exit;
  end;

  //If we have no return type defined, and the default return type is empty
  if (returnType <> nil) and (FReturnDefault.IsEmpty) then
    //Say we didn't have a default return value
    raise EMockException.Create(Format('[%s] has no default return value or return type was defined for method [%s]', [FTypeName, FMethodName]));

  //If we have either a return type, or a default return value then check whether behaviour must be defined.
  if FSetupParameters.BehaviorMustBeDefined and (AExpectationHitCtr = 0) and (FReturnDefault.IsEmpty) then
    //If we must have default behaviour defined, and there was nothing defined raise a mock exception.
    raise EMockException.Create(Format('[%s] has no behaviour or expectation defined for method [%s]', [FTypeName, FMethodName]));

  Result := FReturnDefault;
end;

procedure TMethodData.After(const AAfterMethodName: string);
begin
  raise ENotImplemented.Create('After not implented');
end;

procedure TMethodData.AfterWhen(const AAfterMethodName: string; const Args: TArray<TValue>; const matchers : TArray<IMatcher>);
begin
  raise ENotImplemented.Create('AfterWhen not implented');
end;

procedure TMethodData.AtLeast(const times: Cardinal);
var
  expectation : IExpectation;
begin
  expectation := FindExpectation([TExpectationType.AtLeast,TExpectationType.AtLeastOnce,TExpectationType.AtLeastOnceWhen,TExpectationType.AtLeastWhen]);
  if (expectation <> nil) AND (not FSetupParameters.AllowRedefineBehaviorDefinitions)  then
    raise EMockException.Create(Format('[%s] already defines Expectation At Least for method [%s]', [FTypeName, FMethodName]))
  else if expectation <> nil then
    FExpectations.Remove(expectation);

  expectation := TExpectation.CreateAtLeast(FMethodName,times);
  FExpectations.Add(expectation);
end;

procedure TMethodData.AtLeastOnce;
var
  expectation : IExpectation;
begin
  expectation := FindExpectation([TExpectationType.AtLeast,TExpectationType.AtLeastOnce,TExpectationType.AtLeastOnceWhen,TExpectationType.AtLeastWhen]);
  if (expectation <> nil) AND (not FSetupParameters.AllowRedefineBehaviorDefinitions)  then
    raise EMockException.Create(Format('[%s] already defines Expectation At Least Once for method [%s]', [FTypeName, FMethodName]))
  else if expectation <> nil then
    FExpectations.Remove(expectation);

  expectation := TExpectation.CreateAtLeastOnce(FMethodName);
  FExpectations.Add(expectation);
end;

procedure TMethodData.AtLeastOnceWhen(const Args: TArray<TValue>; const matchers : TArray<IMatcher>);
var
  expectation : IExpectation;
begin
  expectation := FindExpectation(TExpectationType.AtLeastOnceWhen,Args);
  if (expectation <> nil) AND (not FSetupParameters.AllowRedefineBehaviorDefinitions)  then
    raise EMockException.Create(Format('[%s] already defines Expectation At Least Once When for method [%s]', [FTypeName, FMethodName]))
  else if expectation <> nil then
    FExpectations.Remove(expectation);

  expectation := TExpectation.CreateAtLeastOnceWhen(FMethodName, Args, matchers);
  FExpectations.Add(expectation);
end;

procedure TMethodData.AtLeastWhen(const times: Cardinal; const Args: TArray<TValue>; const matchers : TArray<IMatcher>);
var
  expectation : IExpectation;
begin
  expectation := FindExpectation(TExpectationType.AtLeastWhen,Args);
  if (expectation <> nil) AND (not FSetupParameters.AllowRedefineBehaviorDefinitions)  then
    raise EMockException.Create(Format('[%s] already defines Expectation At Least When for method [%s]', [FTypeName, FMethodName]))
  else if expectation <> nil then
    FExpectations.Remove(expectation);

  expectation := TExpectation.CreateAtLeastWhen(FMethodName, times, Args, matchers);
  FExpectations.Add(expectation);
end;

procedure TMethodData.AtMost(const times: Cardinal);
var
  expectation : IExpectation;
begin
  expectation := FindExpectation([TExpectationType.AtMost,TExpectationType.AtMostWhen]);
  if (expectation <> nil) AND (not FSetupParameters.AllowRedefineBehaviorDefinitions)  then
    raise EMockException.Create(Format('[%s] already defines Expectation At Most for method [%s]', [FTypeName, FMethodName]))
  else if expectation <> nil then
    FExpectations.Remove(expectation);

  expectation := TExpectation.CreateAtMost(FMethodName, times);
  FExpectations.Add(expectation);
end;

procedure TMethodData.AtMostWhen(const times: Cardinal; const Args: TArray<TValue>; const matchers : TArray<IMatcher>);
var
  expectation : IExpectation;
begin
  expectation := FindExpectation(TExpectationType.AtMostWhen,Args);
  if (expectation <> nil) AND (not FSetupParameters.AllowRedefineBehaviorDefinitions)  then
    raise EMockException.Create(Format('[%s] already defines Expectation At Most When for method [%s]', [FTypeName, FMethodName]))
  else if expectation <> nil then
    FExpectations.Remove(expectation);

  expectation := TExpectation.CreateAtMostWhen(FMethodName, times, Args, matchers);
  FExpectations.Add(expectation);
end;

procedure TMethodData.Before(const ABeforeMethodName: string);
begin
  raise ENotImplemented.Create('Before not implented');
end;

procedure TMethodData.BeforeWhen(const ABeforeMethodName: string; const Args: TArray<TValue>; const matchers : TArray<IMatcher>);
begin
  raise ENotImplemented.Create('BeforeWhen not implented');
end;

procedure TMethodData.Between(const a, b: Cardinal);
var
  expectation : IExpectation;
begin
  expectation := FindExpectation([TExpectationType.Between,TExpectationType.BetweenWhen]);
  if (expectation <> nil) AND (not FSetupParameters.AllowRedefineBehaviorDefinitions)  then
    raise EMockException.Create(Format('[%s] already defines Expectation Between for method [%s]', [FTypeName, FMethodName]))
  else if expectation <> nil then
    FExpectations.Remove(expectation);

  expectation := TExpectation.CreateBetween(FMethodName,a,b);
  FExpectations.Add(expectation);
end;

procedure TMethodData.BetweenWhen(const a, b: Cardinal;const Args: TArray<TValue>; const matchers : TArray<IMatcher>);
var
  expectation : IExpectation;
begin
  expectation := FindExpectation(TExpectationType.BetweenWhen,Args);
  if (expectation <> nil) AND (not FSetupParameters.AllowRedefineBehaviorDefinitions)  then
    raise EMockException.Create(Format('[%s] already defines Expectation Between When for method [%s]', [FTypeName, FMethodName]))
  else if expectation <> nil then
    FExpectations.Remove(expectation);

  expectation := TExpectation.CreateBetweenWhen(FMethodName, a, b, Args, matchers);
  FExpectations.Add(expectation);
end;

procedure TMethodData.Never;
var
  expectation : IExpectation;
begin
  expectation := FindExpectation([TExpectationType.Never ,TExpectationType.NeverWhen]);
  if (expectation <> nil) AND (not FSetupParameters.AllowRedefineBehaviorDefinitions)  then
    raise EMockException.Create(Format('[%s] already defines Expectation Never for method [%s]', [FTypeName, FMethodName]))
  else if expectation <> nil then
    FExpectations.Remove(expectation);


  expectation := TExpectation.CreateNever(FMethodName);
  FExpectations.Add(expectation);
end;

procedure TMethodData.NeverWhen(const Args: TArray<TValue>; const matchers : TArray<IMatcher>);
var
  expectation : IExpectation;
begin
  expectation := FindExpectation(TExpectationType.NeverWhen,Args);
  if (expectation <> nil) AND (not FSetupParameters.AllowRedefineBehaviorDefinitions)  then
    raise EMockException.Create(Format('[%s] already defines Expectation Never When for method [%s]', [FTypeName, FMethodName]))
  else if expectation <> nil then
    FExpectations.Remove(expectation);

  expectation := TExpectation.CreateNeverWhen(FMethodName, Args, matchers);
  FExpectations.Add(expectation);
end;

procedure TMethodData.Once;
var
  expectation : IExpectation;
begin
  expectation := FindExpectation([TExpectationType.Once,TExpectationType.OnceWhen]);
  if (expectation <> nil) AND (not FSetupParameters.AllowRedefineBehaviorDefinitions)  then
    raise EMockException.Create(Format('[%s] already defines Expectation Once for method [%s]', [FTypeName, FMethodName]))
  else if expectation <> nil then
    FExpectations.Remove(expectation);

  expectation := TExpectation.CreateOnce(FMethodName);
  FExpectations.Add(expectation);
end;

procedure TMethodData.OnceWhen(const Args: TArray<TValue>; const matchers : TArray<IMatcher>);
var
  expectation : IExpectation;
begin
  expectation := FindExpectation(TExpectationType.OnceWhen,Args);
  if (expectation <> nil) AND (not FSetupParameters.AllowRedefineBehaviorDefinitions)  then
    raise EMockException.Create(Format('[%s] already defines Expectation Once When for method [%s]', [FTypeName, FMethodName]))
  else if expectation <> nil then
    FExpectations.Remove(expectation);

  expectation := TExpectation.CreateOnceWhen(FMethodName, Args, matchers);
  FExpectations.Add(expectation);
end;


procedure TMethodData.RecordHit(const Args: TArray<TValue>; const returnType : TRttiType; out Result: TValue);
var
  behavior : IBehavior;
  expectation : IExpectation;
  expectationHitCtr: integer;
  returnValue : TValue;
begin
  expectationHitCtr := 0;
  for expectation in FExpectations do
  begin
    if expectation.Match(Args) then
    begin
      expectation.RecordHit;
      inc(expectationHitCtr);
    end;
  end;

  behavior := FindBestBehavior(Args);
  if behavior <> nil then
    returnValue := behavior.Execute(Args, returnType)
  else
  begin
    if FSetupParameters.IsStub then
      StubNoBehaviourRecordHit(Args, expectationHitCtr, returnType, returnValue)
    else
      MockNoBehaviourRecordHit(Args, expectationHitCtr, returnType, returnValue);
  end;

  if returnType <> nil then
    Result := returnValue;

end;

procedure TMethodData.StubNoBehaviourRecordHit(const Args: TArray<TValue>; const AExpectationHitCtr : Integer; const returnType: TRttiType; out Result: TValue);
begin
  //If we have no return type defined, and the default return type is empty
  if (returnType <> nil) and (FReturnDefault.IsEmpty) then
  begin
    //Return the default value for the passed in return type
    Result := GetDefaultValue(returnType);
  end
  else if FSetupParameters.BehaviorMustBeDefined and (AExpectationHitCtr = 0) and (FReturnDefault.IsEmpty) then
  begin
    //If we must have default behaviour defined, and there was nothing defined raise a mock exception.
    raise EMockException.Create(Format('[%s] has no behaviour or expectation defined for method [%s]', [FTypeName, FMethodName]));
  end;
end;

function TMethodData.Verify(var report : string) : boolean;
var
  expectation : IExpectation;
begin
  result := true;
  report := '';
  for expectation in FExpectations do
  begin
    if not expectation.ExpectationMet then
    begin
      result := False;
      if report <> '' then
        report := report + #13#10 + '    '
      else
        report :=  '    ';
      report := report +  expectation.Report;
    end;
  end;
  if not result then
    report := '  Method : ' + FMethodName + #13#10 +  report;
end;

//Behaviors

procedure TMethodData.WillExecute(const func: TExecuteFunc);
var
  behavior : IBehavior;
begin
  behavior := FindBehavior(TBehaviorType.WillExecute);
  if (behavior <> nil) AND (not FSetupParameters.AllowRedefineBehaviorDefinitions) then
    raise EMockSetupException.Create(Format('[%s] already defines WillExecute for method [%s]', [FTypeName, FMethodName]))
  else if behavior <> nil then
    FBehaviors.Remove(behavior);

  behavior := TBehavior.CreateWillExecute(func);
  FBehaviors.Add(behavior);
end;

procedure TMethodData.WillExecuteWhen(const func: TExecuteFunc;const Args: TArray<TValue>; const matchers : TArray<IMatcher>);
var
  behavior : IBehavior;
begin
  behavior := FindBehavior(TBehaviorType.WillExecuteWhen,Args);
  if (behavior <> nil) AND (not FSetupParameters.AllowRedefineBehaviorDefinitions)  then
    raise EMockSetupException.Create(Format('[%s] already defines WillExecute When for method [%s]', [FTypeName, FMethodName]))
  else if behavior <> nil then
    FBehaviors.Remove(behavior);

  behavior := TBehavior.CreateWillExecuteWhen(Args, func, matchers);
  FBehaviors.Add(behavior);
end;

procedure TMethodData.WillRaiseAlways(const exceptionClass: ExceptClass; const message : string);
var
  behavior : IBehavior;
begin
  behavior := FindBehavior(TBehaviorType.WillRaiseAlways);
  if (behavior <> nil) AND (not FSetupParameters.AllowRedefineBehaviorDefinitions)  then
    raise EMockSetupException.Create(Format('[%s] already defines Will Raise Always for method [%s]', [FTypeName, FMethodName]))
  else if behavior <> nil then
    FBehaviors.Remove(behavior);

  behavior := TBehavior.CreateWillRaise(exceptionClass, message);
  FBehaviors.Add(behavior);
end;

procedure TMethodData.WillRaiseWhen(const exceptionClass: ExceptClass; const message : string; const Args: TArray<TValue>; const matchers : TArray<IMatcher>);
var
  behavior : IBehavior;
begin
  behavior := FindBehavior(TBehaviorType.WillRaise,Args);
  if (behavior <> nil) AND (not FSetupParameters.AllowRedefineBehaviorDefinitions)  then
    raise EMockSetupException.Create(Format('[%s] already defines Will Raise When for method [%s]', [FTypeName, FMethodName]))
  else if behavior <> nil then
    FBehaviors.Remove(behavior);

  behavior := TBehavior.CreateWillRaiseWhen(Args,exceptionClass, message, matchers);
  FBehaviors.Add(behavior);
end;

procedure TMethodData.WillReturnDefault(const returnValue: TValue);
begin
  if (not FReturnDefault.IsEmpty) AND (not FSetupParameters.AllowRedefineBehaviorDefinitions) then
    raise EMockSetupException.Create(Format('[%s] already defines Will Return Default for method [%s]', [FTypeName, FMethodName]));
  FReturnDefault := returnValue;
end;

procedure TMethodData.WillReturnWhen(const Args: TArray<TValue>; const returnValue: TValue; const matchers : TArray<IMatcher>);
var
  behavior : IBehavior;
begin
  behavior := FindBehavior(TBehaviorType.WillReturn,Args);
  if (behavior <> nil) AND (not FSetupParameters.AllowRedefineBehaviorDefinitions)  then
    raise EMockSetupException.Create(Format('[%s] already defines Will Return When for method [%s]', [FTypeName, FMethodName]))
  else if behavior <> nil then
    FBehaviors.Remove(behavior);

  behavior := TBehavior.CreateWillReturnWhen(Args, returnValue, matchers);
  FBehaviors.Add(behavior);
end;

{ TSetupMethodDataParameters }
class function TSetupMethodDataParameters.Create(const AIsStub: boolean; const ABehaviorMustBeDefined, AAllowRedefineBehaviorDefinitions: boolean): TSetupMethodDataParameters;
begin
  result.IsStub := AIsStub;
  result.BehaviorMustBeDefined := ABehaviorMustBeDefined;
  result.AllowRedefineBehaviorDefinitions := AAllowRedefineBehaviorDefinitions;
end;

end.

