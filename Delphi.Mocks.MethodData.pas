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
  Delphi.Mocks.Interfaces;

type
  TMethodData = class(TInterfacedObject,IMethodData)
  private
    FMethodName     : string;
    FBehaviors      : TList<IBehavior>;
    FReturnDefault  : TValue;
    FExpectations   : TList<IExpectation>;
    FIsStub         : boolean;
  protected

    //Behaviors
    procedure WillReturnDefault(const returnValue : TValue);
    procedure WillReturnWhen(const Args: TArray<TValue>; const returnValue : TValue);
    procedure WillRaiseAlways(const exceptionClass : ExceptClass; const message : string);
    procedure WillRaiseWhen(const exceptionClass : ExceptClass; const message : string;const Args: TArray<TValue>);
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

    function Verify(var report : string) : boolean;
  public
    constructor Create(const AMethodName : string; const AIsStub : boolean);
    destructor Destroy;override;
  end;

  {$IFNDEF DELPHI_XE_UP}
  ENotImplemented = class(Exception);
  {$ENDIF}

implementation

uses
  Delphi.Mocks.Utils,
  Delphi.Mocks.Behavior,
  Delphi.Mocks.Expectation;



{ TMethodData }


constructor TMethodData.Create(const AMethodName : string; const AIsStub : boolean);
begin
  FMethodName := AMethodName;
  FBehaviors := TList<IBehavior>.Create;
  FExpectations := TList<IExpectation>.Create;
  FReturnDefault := TValue.Empty;
  FIsStub := AIsStub;
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
  if expectation <> nil then
    raise EMockException.Create('Expectation Exactly already defined on method : ' + FMethodName);
  expectation := TExpectation.CreateExactly(FMethodName,times);
  FExpectations.Add(expectation);
end;

procedure TMethodData.ExactlyWhen(const times: Cardinal;
  const Args: TArray<TValue>);
var
  expectation : IExpectation;
begin
  expectation := FindExpectation(TExpectationType.ExactlyWhen,Args);
  if expectation <> nil then
    raise EMockException.Create('Expectation Exactly already defined for these args on method : ' + FMethodName);
  expectation := TExpectation.CreateExactlyWhen(FMethodName,times,Args);
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

procedure TMethodData.After(const AAfterMethodName: string);
begin
  raise ENotImplemented.Create('After not implented');
end;

procedure TMethodData.AfterWhen(const AAfterMethodName: string;const Args: TArray<TValue>);
begin
  raise ENotImplemented.Create('AfterWhen not implented');
end;

procedure TMethodData.AtLeast(const times: Cardinal);
var
  expectation : IExpectation;
begin
  expectation := FindExpectation([TExpectationType.AtLeast,TExpectationType.AtLeastOnce,TExpectationType.AtLeastOnceWhen,TExpectationType.AtLeastWhen]);
  if expectation <> nil then
    raise EMockException.Create('Expectation At Least already defined on method : ' + FMethodName);
  expectation := TExpectation.CreateAtLeast(FMethodName,times);
  FExpectations.Add(expectation);
end;

procedure TMethodData.AtLeastOnce;
var
  expectation : IExpectation;
begin
  expectation := FindExpectation([TExpectationType.AtLeast,TExpectationType.AtLeastOnce,TExpectationType.AtLeastOnceWhen,TExpectationType.AtLeastWhen]);
  if expectation <> nil then
    raise EMockException.Create('Expectation At Least already defined on method : ' + FMethodName);
  expectation := TExpectation.CreateAtLeastOnce(FMethodName);
  FExpectations.Add(expectation);
end;

procedure TMethodData.AtLeastOnceWhen(const Args: TArray<TValue>);
var
  expectation : IExpectation;
begin
  expectation := FindExpectation(TExpectationType.AtLeastOnceWhen,Args);
  if expectation <> nil then
    raise EMockException.Create('Expectation At Least Once already defined for these args on method : ' + FMethodName);
  expectation := TExpectation.CreateAtLeastOnceWhen(FMethodName,Args);
  FExpectations.Add(expectation);
end;

procedure TMethodData.AtLeastWhen(const times: Cardinal; const Args: TArray<TValue>);
var
  expectation : IExpectation;
begin
  expectation := FindExpectation(TExpectationType.AtLeastWhen,Args);
  if expectation <> nil then
    raise EMockException.Create('Expectation At Least already defined for these args on method : ' + FMethodName);
  expectation := TExpectation.CreateAtLeastWhen(FMethodName,times,Args);
  FExpectations.Add(expectation);
end;

procedure TMethodData.AtMost(const times: Cardinal);
var
  expectation : IExpectation;
begin
  expectation := FindExpectation([TExpectationType.AtMost,TExpectationType.AtMostWhen]);
  if expectation <> nil then
    raise EMockException.Create('Expectation At Most already defined on method : ' + FMethodName);
  expectation := TExpectation.CreateAtMost(FMethodName,times);
  FExpectations.Add(expectation);
end;

procedure TMethodData.AtMostWhen(const times: Cardinal;
  const Args: TArray<TValue>);
var
  expectation : IExpectation;
begin
  expectation := FindExpectation(TExpectationType.AtMostWhen,Args);
  if expectation <> nil then
    raise EMockException.Create('Expectation At Most already defined for these args on method : ' + FMethodName);
  expectation := TExpectation.CreateAtMostWhen(FMethodName,times,Args);
  FExpectations.Add(expectation);
end;

procedure TMethodData.Before(const ABeforeMethodName: string);
begin
  raise ENotImplemented.Create('Before not implented');
end;

procedure TMethodData.BeforeWhen(const ABeforeMethodName: string; const Args: TArray<TValue>);
begin
  raise ENotImplemented.Create('BeforeWhen not implented');
end;

procedure TMethodData.Between(const a, b: Cardinal);
var
  expectation : IExpectation;
begin
  expectation := FindExpectation([TExpectationType.Between,TExpectationType.BetweenWhen]);
  if expectation <> nil then
    raise EMockException.Create('Expectation Between already defined on method : ' + FMethodName);
  expectation := TExpectation.CreateBetween(FMethodName,a,b);
  FExpectations.Add(expectation);
end;

procedure TMethodData.BetweenWhen(const a, b: Cardinal;const Args: TArray<TValue>);
var
  expectation : IExpectation;
begin
  expectation := FindExpectation(TExpectationType.BetweenWhen,Args);
  if expectation <> nil then
    raise EMockException.Create('Expectation Between already defined for these args on method : ' + FMethodName);
  expectation := TExpectation.CreateBetweenWhen(FMethodName,a,b,Args);
  FExpectations.Add(expectation);
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
  expectation : IExpectation;
begin
  for expectation in FExpectations do
  begin
    if expectation.Match(Args) then
      expectation.RecordHit;
  end;

  behavior := FindBestBehavior(Args);
  if behavior <> nil then
    returnVal := behavior.Execute(Args,returnType)
  else
  begin
    if (returnType <> nil) and (FReturnDefault.IsEmpty) then
      if FIsStub then
        result := GetDefaultValue(returnType)
      else
        raise EMockException.Create('No default return value defined for method ' + FMethodName);
    returnVal := FReturnDefault;
  end;
  if returnType <> nil then
    Result := returnVal;
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

procedure TMethodData.WillRaiseAlways(const exceptionClass: ExceptClass; const message : string);
var
  behavior : IBehavior;
begin
  behavior := FindBehavior(TBehaviorType.WillRaiseAlways);
  if behavior <> nil then
    raise EMockSetupException.Create('WillRaise already defined for method ' + FMethodName );
  behavior := TBehavior.CreateWillRaise(exceptionClass,message);
  FBehaviors.Add(behavior);
end;

procedure TMethodData.WillRaiseWhen(const exceptionClass: ExceptClass; const message : string; const Args: TArray<TValue>);
var
  behavior : IBehavior;
begin
  behavior := FindBehavior(TBehaviorType.WillRaise,Args);
  if behavior <> nil then
    raise EMockSetupException.Create('WillRaise.When already defined for method ' + FMethodName );
  behavior := TBehavior.CreateWillRaiseWhen(Args,exceptionClass,message);
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
