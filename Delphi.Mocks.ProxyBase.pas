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

unit Delphi.Mocks.ProxyBase;

interface

uses
  Rtti,
  SysUtils,
  Generics.Collections,
  Delphi.Mocks,
  Delphi.Mocks.Interfaces,
  Delphi.Mocks.Behavior;

type
  TProxyBaseInvokeEvent = procedure (Method: TRttiMethod; const Args: TArray<TValue>; out Result: TValue) of object;

  TSetupMode = (None, Behavior, Expectation);

  TBaseProxy<T> = class(TInterfacedObject, IInterface, IProxy<T>, IStubProxy<T>, IMockSetup<T>, IStubSetup<T>, IExpect<T>, IVerify)
  private
    FMethodData             : TDictionary<string,IMethodData>;
    FBehaviorMustBeDefined  : Boolean;
    FSetupMode              : TSetupMode;
    //behavior setup
    FNextBehavior           : TBehaviorType;
    FReturnValue            : TValue;
    FNextFunc               : TExecuteFunc;
    FExceptClass            : ExceptClass;
    FExceptionMessage       : string;
    //expectation setup
    FNextExpectation        : TExpectationType;
    FTimes                  : Cardinal;
    FBetween                : array[0..1] of Cardinal;
    FIsStubOnly             : boolean;
  protected

    function QueryInterface(const IID: TGUID; out Obj): HRESULT;virtual; stdcall;
    function InternalQueryInterface(const IID: TGUID; out Obj): HRESULT; stdcall;
    function _AddRef: Integer; stdcall;
    function _Release: Integer; stdcall;

    //IProxy<T>
    function MockSetup : IMockSetup<T>;
    function StubSetup : IStubSetup<T>;
    function IProxy<T>.Setup = MockSetup;
    function IStubProxy<T>.Setup = StubSetup;
    function Proxy : T;virtual;abstract;



    //ISetup<T>
    function GetBehaviorMustBeDefined : boolean;
    procedure SetBehaviorMustBeDefined(const value : boolean);
    function Expect : IExpect<T>;
//    function Before(const AMethodName : string) : ISetup<T>;
//    function After(const AMethodName : string) : ISetup<T>;
    function WillReturn(const value : TValue) : IWhen<T>;
    procedure WillReturnDefault(const AMethodName : string; const value : TValue);
    function WillRaise(const exceptionClass : ExceptClass; const message : string = '') : IWhen<T>;overload;
    procedure WillRaise(const AMethodName : string; const exceptionClass : ExceptClass; const message : string = '');overload;

    function WillExecute(const func : TExecuteFunc) : IWhen<T>;overload;
    procedure WillExecute(const AMethodName : string; const func : TExecuteFunc);overload;

    procedure DoInvoke(Method: TRttiMethod; const Args: TArray<TValue>; out Result: TValue);

    //IVerify
    procedure Verify(const message : string = '');
    function CheckExpectations: string;

    function GetMethodData(const AMethodName : string) : IMethodData;overload;

    procedure ClearSetupState;

    //IExpect<T>
    function Once : IWhen<T>;overload;
    procedure Once(const AMethodName : string);overload;

    function Never : IWhen<T>;overload;
    procedure Never(const AMethodName : string);overload;

    function AtLeastOnce : IWhen<T>;overload;
    procedure AtLeastOnce(const AMethodName : string);overload;

    function AtLeast(const times : Cardinal) : IWhen<T>;overload;
    procedure AtLeast(const AMethodName : string; const times : Cardinal);overload;

    function AtMost(const times : Cardinal) : IWhen<T>;overload;
    procedure AtMost(const AMethodName : string; const times : Cardinal);overload;

    function Between(const a,b : Cardinal) : IWhen<T>;overload;
    procedure Between(const AMethodName : string; const a,b : Cardinal);overload;

    function Exactly(const times : Cardinal) : IWhen<T>;overload;
    procedure Exactly(const AMethodName : string; const times : Cardinal);overload;

    function Before(const AMethodName : string) : IWhen<T>;overload;
    procedure Before(const AMethodName : string; const ABeforeMethodName : string);overload;

    function After(const AMethodName : string) : IWhen<T>;overload;
    procedure After(const AMethodName : string; const AAfterMethodName : string);overload;
  public
    constructor Create(const AIsStubOnly : boolean);virtual;
    destructor Destroy;override;
  end;


implementation

uses
  Delphi.Mocks.Utils,
  Delphi.Mocks.When,
  Delphi.Mocks.MethodData,
  TypInfo;


{ TProxyBase }
procedure TBaseProxy<T>.After(const AMethodName, AAfterMethodName: string);
begin
  raise Exception.Create('Not implemented');
end;

function TBaseProxy<T>.After(const AMethodName: string): IWhen<T>;
begin
  raise Exception.Create('Not implemented');
end;

procedure TBaseProxy<T>.AtLeast(const AMethodName: string; const times: Cardinal);
var
  methodData : IMethodData;
begin
  methodData := GetMethodData(AMethodName);
  Assert(methodData <> nil);
  methodData.AtLeast(times);
  ClearSetupState;
end;

function TBaseProxy<T>.AtLeast(const times: Cardinal): IWhen<T>;
begin
  FSetupMode := TSetupMode.Expectation;
  FNextExpectation := TExpectationType.AtLeastWhen;
  FTimes := times;
  result := TWhen<T>.Create(Self.Proxy);
end;

procedure TBaseProxy<T>.AtLeastOnce(const AMethodName: string);
var
  methodData : IMethodData;
begin
  methodData := GetMethodData(AMethodName);
  Assert(methodData <> nil);
  methodData.AtLeastOnce;
  ClearSetupState;
end;

function TBaseProxy<T>.AtLeastOnce: IWhen<T>;
begin
  FSetupMode := TSetupMode.Expectation;
  FNextExpectation := TExpectationType.AtLeastOnceWhen;
  FTimes := 1;
  result := TWhen<T>.Create(Self.Proxy);
end;

procedure TBaseProxy<T>.AtMost(const AMethodName: string; const times: Cardinal);
var
  methodData : IMethodData;
begin
  methodData := GetMethodData(AMethodName);
  Assert(methodData <> nil);
  methodData.AtMost(times);
  ClearSetupState;
end;

function TBaseProxy<T>.AtMost(const times: Cardinal): IWhen<T>;
begin
  FSetupMode := TSetupMode.Expectation;
  FNextExpectation := TExpectationType.AtMostWhen;
  FTimes := times;
  result := TWhen<T>.Create(Self.Proxy);
end;

procedure TBaseProxy<T>.Before(const AMethodName, ABeforeMethodName: string);
begin
  raise Exception.Create('not implemented');
end;

function TBaseProxy<T>.Before(const AMethodName: string): IWhen<T>;
begin
  raise Exception.Create('not implemented');
end;

procedure TBaseProxy<T>.Between(const AMethodName: string; const a,  b: Cardinal);
var
  methodData : IMethodData;
begin
  methodData := GetMethodData(AMethodName);
  Assert(methodData <> nil);
  methodData.Between(a,b);
  ClearSetupState;
end;

function TBaseProxy<T>.Between(const a, b: Cardinal): IWhen<T>;
begin
  FSetupMode := TSetupMode.Expectation;
  FNextExpectation := TExpectationType.BetweenWhen;
  FBetween[0] := a;
  FBetween[1] := b;
  result := TWhen<T>.Create(Self.Proxy);

end;

function TBaseProxy<T>.CheckExpectations: string;
var
  methodData : IMethodData;
  report : string;
begin
  Result := '';
  for methodData in FMethodData.Values do
  begin
    report := '';
    if not methodData.Verify(report) then
    begin
      if Result <> '' then
        Result := Result + #13#10;
      Result := Result + report ;
    end;
  end;
end;

procedure TBaseProxy<T>.ClearSetupState;
begin
  FSetupMode := TSetupMode.None;
  FReturnValue := TValue.Empty;
  FExceptClass := nil;
  FNextFunc := nil;
end;

constructor TBaseProxy<T>.Create(const AIsStubOnly : boolean);
begin
   FSetupMode := TSetupMode.None;
   FBehaviorMustBeDefined := False;
   FMethodData := TDictionary<string,IMethodData>.Create;
   FIsStubOnly := AIsStubOnly;
end;

destructor TBaseProxy<T>.Destroy;
begin
  FMethodData.Free;
  inherited;
end;

procedure TBaseProxy<T>.DoInvoke(Method: TRttiMethod; const Args: TArray<TValue>; out Result: TValue);
var
  returnVal : TValue;
  methodData : IMethodData;
  behavior : IBehavior;
begin
  case FSetupMode of
    TSetupMode.None:
    begin
      //record actual behavior
      methodData := GetMethodData(method.Name);
      Assert(methodData <> nil);
      methodData.RecordHit(Args,Method.ReturnType,Result);
    end;
    TSetupMode.Behavior:
    begin
      try
        //record desired behavior
        //first see if we know about this method
        methodData := GetMethodData(method.Name);
        Assert(methodData <> nil);
        case FNextBehavior of
          TBehaviorType.WillReturn:
          begin
            if (Method.ReturnType = nil) and (not FReturnValue.IsEmpty) then
              raise EMockSetupException.Create('Setup.WillReturn called on procedure : ' + Method.Name );
            methodData.WillReturnWhen(Args,FReturnValue);
          end;
          TBehaviorType.WillRaise:
          begin
            methodData.WillRaiseAlways(FExceptClass,FExceptionMessage);
          end;
          TBehaviorType.WillExecuteWhen :
          begin
            methodData.WillExecuteWhen(FNextFunc,Args);
          end;
        end;
      finally
        ClearSetupState;
      end;
    end;
    TSetupMode.Expectation:
    begin
      try
        //record expectations
        //first see if we know about this method
        methodData := GetMethodData(method.Name);
        Assert(methodData <> nil);
        case FNextExpectation of
          OnceWhen        : methodData.OnceWhen(Args);
          NeverWhen       : methodData.NeverWhen(Args) ;
          AtLeastOnceWhen : methodData.AtLeastOnceWhen(Args);
          AtLeastWhen     : methodData.AtLeastWhen(FTimes,args);
          AtMostOnceWhen  : methodData.AtLeastOnceWhen(Args);
          AtMostWhen      : methodData.AtMostWhen(FTimes,args);
          BetweenWhen     : methodData.BetweenWhen(FBetween[0],FBetween[1],Args) ;
          ExactlyWhen     : methodData.ExactlyWhen(FTimes,Args);
          BeforeWhen      : raise exception.Create('not implemented') ;
          AfterWhen       : raise exception.Create('not implemented');
        end;

      finally
        ClearSetupState;
      end;
    end;
  end;

end;

procedure TBaseProxy<T>.Exactly(const AMethodName: string; const times: Cardinal);
var
  methodData : IMethodData;
begin
  methodData := GetMethodData(AMethodName);
  Assert(methodData <> nil);
  methodData.Exactly(times);
  ClearSetupState;
end;

function TBaseProxy<T>.Exactly(const times: Cardinal): IWhen<T>;
begin
  FSetupMode := TSetupMode.Expectation;
  FNextExpectation := TExpectationType.ExactlyWhen;
  FTimes := times;
  result := TWhen<T>.Create(Self.Proxy);
end;

function TBaseProxy<T>.Expect: IExpect<T>;
begin
  result := Self as IExpect<T> ;
end;

function TBaseProxy<T>.GetBehaviorMustBeDefined: boolean;
begin
  result := FBehaviorMustBeDefined;
end;

function TBaseProxy<T>.GetMethodData(const AMethodName: string): IMethodData;
var
  methodName : string;
begin
  methodName := LowerCase(AMethodName);
  if FMethodData.TryGetValue(methodName,Result) then
    exit;

  Result := TMethodData.Create(AMethodName,FIsStubOnly);
  FMethodData.Add(methodName,Result);

end;


function TBaseProxy<T>.InternalQueryInterface(const IID: TGUID;
  out Obj): HRESULT;
begin
  Result := E_NOINTERFACE;
  if (IsEqualGUID(IID,IInterface)) then
    if GetInterface(IID, Obj) then
      Result := 0;
end;

procedure TBaseProxy<T>.Never(const AMethodName: string);
var
  methodData : IMethodData;
begin
  methodData := GetMethodData(AMethodName);
  Assert(methodData <> nil);
  methodData.Never;
  ClearSetupState;
end;

function TBaseProxy<T>.Never: IWhen<T>;
begin
  FSetupMode := TSetupMode.Expectation;
  FNextExpectation := TExpectationType.NeverWhen;
  result := TWhen<T>.Create(Self.Proxy);
end;

function TBaseProxy<T>.Once: IWhen<T>;
begin
  FSetupMode := TSetupMode.Expectation;
  FNextExpectation := TExpectationType.OnceWhen;
  result := TWhen<T>.Create(Self.Proxy);
end;

procedure TBaseProxy<T>.Once(const AMethodName: string);
var
  methodData : IMethodData;
begin
  methodData := GetMethodData(AMethodName);
  Assert(methodData <> nil);
  methodData.Once;
  ClearSetupState;
end;


function TBaseProxy<T>.QueryInterface(const IID: TGUID; out Obj): HRESULT;
begin
  Result := inherited;
end;

procedure TBaseProxy<T>.SetBehaviorMustBeDefined(const value: boolean);
begin
  FBehaviorMustBeDefined := value;
end;


function TBaseProxy<T>.StubSetup: IStubSetup<T>;
begin
  result := Self;
end;

function TBaseProxy<T>.MockSetup: IMockSetup<T>;
begin
  result := Self;
end;

procedure TBaseProxy<T>.Verify(const message: string);
var
  msg : string;
begin
  msg := CheckExpectations;
  if msg <> '' then
    raise EMockVerificationException.Create(message + #13#10 + msg);

end;

function TBaseProxy<T>.WillExecute(const func: TExecuteFunc): IWhen<T>;
begin
  FSetupMode := TSetupMode.Behavior;
  FNextBehavior := TBehaviorType.WillExecuteWhen;
  FNextFunc := func;
  result := TWhen<T>.Create(Self.Proxy);
end;

procedure TBaseProxy<T>.WillExecute(const AMethodName: string; const func: TExecuteFunc);
var
  methodData : IMethodData;
begin
  //actually record the behaviour here!
  methodData := GetMethodData(AMethodName);
  Assert(methodData <> nil);
  methodData.WillExecute(func);
  ClearSetupState;
end;

function TBaseProxy<T>.WillRaise(const exceptionClass: ExceptClass;const message : string): IWhen<T>;
begin
  FSetupMode := TSetupMode.Behavior;
  FNextBehavior := TBehaviorType.WillRaise;
  FExceptClass := exceptionClass;
  FExceptionMessage := message;
  result := TWhen<T>.Create(Self.Proxy);
end;

procedure TBaseProxy<T>.WillRaise(const AMethodName: string; const exceptionClass: ExceptClass;const message : string);
var
  methodData : IMethodData;
begin
  //actually record the behaviour here!
  methodData := GetMethodData(AMethodName);
  Assert(methodData <> nil);
  methodData.WillRaiseAlways(exceptionClass,message);
  ClearSetupState;
end;

function TBaseProxy<T>.WillReturn(const value: TValue): IWhen<T>;
begin
  FSetupMode := TSetupMode.Behavior;
  FReturnValue := value;
  FNextBehavior := TBehaviorType.WillReturn;
  result := TWhen<T>.Create(Self.Proxy);
end;

procedure TBaseProxy<T>.WillReturnDefault(const AMethodName : string; const value : TValue);
var
  methodData : IMethodData;
begin
  //actually record the behaviour here!
  methodData := GetMethodData(AMethodName);
  Assert(methodData <> nil);
  methodData.WillReturnDefault(value);
  ClearSetupState;
end;

function TBaseProxy<T>._AddRef: Integer;
begin
  result := inherited;
end;

function TBaseProxy<T>._Release: Integer;
begin
  result := inherited;
end;


end.
