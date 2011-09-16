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

unit Delphi.Mocks.InterfaceProxy;

interface

uses
  Rtti,
  SysUtils,
  Generics.Collections,
  Delphi.Mocks,
  Delphi.Mocks.Interfaces,
  Delphi.Mocks.Behavior,
  Delphi.Mocks.VirtualInterface;

type
  TProxyBaseInvokeEvent = procedure (Method: TRttiMethod; const Args: TArray<TValue>; out Result: TValue) of object;

  TSetupMode = (None,Behavior,Expectation);

  TProxyBase<T> = class(TInterfacedObject,IInterface,IProxy<T>,ISetup<T>,IExpect<T>, IVerify)
  private type
   TProxyVirtualInterface = class(TVirtualInterface)
    private
      FProxyBase : TProxyBase<T>;
    protected
      function _AddRef: Integer; override; stdcall;
      function _Release: Integer; override; stdcall;
    public
      constructor Create(AProxy : TProxyBase<T>; AInterface: Pointer; InvokeEvent: TVirtualInterfaceInvokeEvent);
      function QueryInterface(const IID: TGUID; out Obj): HRESULT; override; stdcall;
    end;

  private
    FVirtualInterface : IInterface;

    FMethodData : TDictionary<string,IMethodData>;
    //
    FSetupMode : TSetupMode;

    FNextBehavior : TBehaviorType;
    FNextExpectationType : TExpectationType;
    FReturnValue : TValue;
    FBehaviorMustBeDefined : Boolean;
    FNextFunc : TExecuteFunc;
    FExceptClass : ExceptClass;

  protected
    function QueryInterface(const IID: TGUID; out Obj): HRESULT; stdcall;
    function InternalQueryInterface(const IID: TGUID; out Obj): HRESULT; stdcall;
    function _AddRef: Integer; stdcall;
    function _Release: Integer; stdcall;

    //IProxy<T>
    function Setup : ISetup<T>;
    function Proxy : T;

    //ISetup<T>
    function GetBehaviorMustBeDefined : boolean;
    procedure SetBehaviorMustBeDefined(const value : boolean);
    function Expect : IExpect<T>;
//    function Before(const AMethodName : string) : ISetup<T>;
//    function After(const AMethodName : string) : ISetup<T>;
    function WillReturn(const value : TValue) : IWhen<T>;
    procedure WillReturnDefault(const AMethodName : string; const value : TValue);
    function WillRaise(const exceptionClass : ExceptClass) : IWhen<T>;overload;
    procedure WillRaise(const AMethodName : string; const exceptionClass : ExceptClass);overload;

    function WillExecute(const func : TExecuteFunc) : IWhen<T>;overload;
    procedure WillExecute(const AMethodName : string; const func : TExecuteFunc);overload;

    procedure DoInvoke(Method: TRttiMethod; const Args: TArray<TValue>; out Result: TValue);
    //IVerify
    procedure Verify(const message : string = '');

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
    constructor Create;
    destructor Destroy;override;
  end;



{
  TSetup<T> = class(TInterfacedObject,ISetup<T>,ISetupControl)
  private
    FProxy : T;
    FSetupMode : boolean;
    FNextBehavior : TBehaviourType;
    FRetVal : TValue;
    FBehaviors : TDictionary<string,IBehavior>;
    FBehaviorMustBeDefined : boolean;
  protected
    function GetBehaviorMustBeDefined : boolean;
    procedure SetBehaviorMustBeDefined(const value : boolean);
    function Expect : IExpect<T>;
    function WillReturn(const value : TValue) : IWhen<T>;
    function WillReturnDefault(const AMethodName : string; const value : TValue) : ISetup<T>;
    function WillRaise(const exceptionClass : ExceptClass) : IWhen<T>;
    function Before(const AMethodName : string) : ISetup<T>;
    function After(const AMethodName : string) : ISetup<T>;

    procedure Verify(const message : string = '');
    procedure DoInvoke(Method: TRttiMethod; const Args: TArray<TValue>; out Result: TValue);
    function GetSetupMode : boolean;
    procedure SetSetupMode(const value : boolean);

  public
    constructor Create(const AProxy : T);
    destructor Destroy;override;
  end;
 }


implementation

uses
  Delphi.Mocks.Utils,
  Delphi.Mocks.When,
  Delphi.Mocks.MethodData,
  TypInfo;


{ TProxyBase }

//function TProxyBase<T>.After(const AMethodName: string): ISetup<T>;
//begin
//  result := Self;
//end;

//function TProxyBase<T>.Before(const AMethodName: string): ISetup<T>;
//begin
//  result := Self;
//end;

procedure TProxyBase<T>.After(const AMethodName, AAfterMethodName: string);
begin

end;

function TProxyBase<T>.After(const AMethodName: string): IWhen<T>;
begin

end;

procedure TProxyBase<T>.AtLeast(const AMethodName: string;
  const times: Cardinal);
begin

end;

function TProxyBase<T>.AtLeast(const times: Cardinal): IWhen<T>;
begin

end;

procedure TProxyBase<T>.AtLeastOnce(const AMethodName: string);
begin

end;

function TProxyBase<T>.AtLeastOnce: IWhen<T>;
begin

end;

procedure TProxyBase<T>.AtMost(const AMethodName: string;
  const times: Cardinal);
begin

end;

function TProxyBase<T>.AtMost(const times: Cardinal): IWhen<T>;
begin

end;

procedure TProxyBase<T>.Before(const AMethodName, ABeforeMethodName: string);
begin

end;

function TProxyBase<T>.Before(const AMethodName: string): IWhen<T>;
begin

end;

procedure TProxyBase<T>.Between(const AMethodName: string; const a,
  b: Cardinal);
begin

end;

function TProxyBase<T>.Between(const a, b: Cardinal): IWhen<T>;
begin

end;

procedure TProxyBase<T>.ClearSetupState;
begin
  FSetupMode := TSetupMode.None;
  FReturnValue := TValue.Empty;
  FExceptClass := nil;
  FNextFunc := nil;
end;

constructor TProxyBase<T>.Create;
begin
   FVirtualInterface := TProxyVirtualInterface.Create(Self,TypeInfo(T),procedure(Method: TRttiMethod; const Args: TArray<TValue>; out Result: TValue)
   begin
     Self.DoInvoke(Method,Args,Result);
   end);
   //remove reference created in this constructor, the virtual interface and proxy's lifetime are now the same.
   FVirtualInterface._Release;
   FSetupMode := TSetupMode.None;
   FBehaviorMustBeDefined := False;
   FMethodData := TDictionary<string,IMethodData>.Create;
end;

destructor TProxyBase<T>.Destroy;
begin
  WriteLn('destroy proxy');
  FVirtualInterface := nil;
  FMethodData.Free;
  inherited;
end;

procedure TProxyBase<T>.DoInvoke(Method: TRttiMethod; const Args: TArray<TValue>; out Result: TValue);
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
            methodData.WillRaiseAlways(FExceptClass);
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

        //

      finally
        ClearSetupState;
      end;
    end;
  end;

end;

procedure TProxyBase<T>.Exactly(const AMethodName: string;
  const times: Cardinal);
begin

end;

function TProxyBase<T>.Exactly(const times: Cardinal): IWhen<T>;
begin

end;

function TProxyBase<T>.Expect: IExpect<T>;
begin
  result := Self as IExpect<T> ;
//  raise Exception.Create('Not implemented yet!');
end;

function TProxyBase<T>.GetBehaviorMustBeDefined: boolean;
begin
  result := FBehaviorMustBeDefined;
end;


function TProxyBase<T>.GetMethodData(const AMethodName: string): IMethodData;
var
  methodName : string;
begin
  methodName := LowerCase(AMethodName);
  if FMethodData.TryGetValue(methodName,Result) then
    exit;

  Result := TMethodData.Create(AMethodName);
  FMethodData.Add(methodName,Result);

end;


function TProxyBase<T>.InternalQueryInterface(const IID: TGUID;
  out Obj): HRESULT;
begin
  Result := E_NOINTERFACE;
  if (IsEqualGUID(IID,IInterface)) then
    if GetInterface(IID, Obj) then
      Result := 0;
end;

procedure TProxyBase<T>.Never(const AMethodName: string);
begin

end;

function TProxyBase<T>.Never: IWhen<T>;
begin

end;

function TProxyBase<T>.Once: IWhen<T>;
begin

end;

procedure TProxyBase<T>.Once(const AMethodName: string);
begin

end;

function TProxyBase<T>.Proxy: T;
var
  pInfo : PTypeInfo;
begin
  pInfo := TypeInfo(T);
  if FVirtualInterface.QueryInterface(GetTypeData(pInfo).Guid,result) <> 0 then
    raise EMockNoProxyException.Create('Error casting to interface ' + string(pInfo.Name) + ' , proxy does not appear to implememnt T');
end;

function TProxyBase<T>.QueryInterface(const IID: TGUID; out Obj): HRESULT;
begin
  Result := E_NOINTERFACE;
  if (FVirtualInterface <> nil) then
    Result := FVirtualInterface.QueryInterface(IID, Obj);
  if result <> 0 then
    Result := inherited;
end;

procedure TProxyBase<T>.SetBehaviorMustBeDefined(const value: boolean);
begin
  FBehaviorMustBeDefined := value;
end;


function TProxyBase<T>.Setup: ISetup<T>;
begin
  result := Self;
end;

procedure TProxyBase<T>.Verify(const message: string);
var
  methodData : IMethodData;
begin
  for methodData in FMethodData.Values do
  begin
    methodData.Verify;
  end;
  WriteLn('Verifying..' + message);
end;

function TProxyBase<T>.WillExecute(const func: TExecuteFunc): IWhen<T>;
begin
  FSetupMode := TSetupMode.Behavior;
  FNextBehavior := TBehaviorType.WillExecuteWhen;
  FNextFunc := func;
  result := TWhen<T>.Create(Self.Proxy);
end;

procedure TProxyBase<T>.WillExecute(const AMethodName: string; const func: TExecuteFunc);
var
  methodData : IMethodData;
begin
  //actually record the behaviour here!
  methodData := GetMethodData(AMethodName);
  Assert(methodData <> nil);
  methodData.WillExecute(func);
  ClearSetupState;
end;

function TProxyBase<T>.WillRaise(const exceptionClass: ExceptClass): IWhen<T>;
begin
  FSetupMode := TSetupMode.Behavior;
  FNextBehavior := TBehaviorType.WillRaise;
  FExceptClass := exceptionClass;
  result := TWhen<T>.Create(Self.Proxy);
end;

procedure TProxyBase<T>.WillRaise(const AMethodName: string; const exceptionClass: ExceptClass);
var
  methodData : IMethodData;
begin
  //actually record the behaviour here!
  methodData := GetMethodData(AMethodName);
  Assert(methodData <> nil);
  methodData.WillRaiseAlways(exceptionClass);
  ClearSetupState;
end;

function TProxyBase<T>.WillReturn(const value: TValue): IWhen<T>;
begin
  FSetupMode := TSetupMode.Behavior;
  FReturnValue := value;
  FNextBehavior := TBehaviorType.WillReturn;
  result := TWhen<T>.Create(Self.Proxy);
end;

procedure TProxyBase<T>.WillReturnDefault(const AMethodName : string; const value : TValue);
var
  methodData : IMethodData;
begin
  //actually record the behaviour here!
  methodData := GetMethodData(AMethodName);
  Assert(methodData <> nil);
  methodData.WillReturnDefault(value);
  ClearSetupState;
end;

function TProxyBase<T>._AddRef: Integer;
begin
  result := inherited;
end;

function TProxyBase<T>._Release: Integer;
begin
  result := inherited;
end;

{ TProxyBase<T>.TProxyVirtualInterface }

constructor TProxyBase<T>.TProxyVirtualInterface.Create(AProxy: TProxyBase<T>; AInterface: Pointer; InvokeEvent: TVirtualInterfaceInvokeEvent);
begin
  FProxyBase := AProxy;
  inherited Create(Ainterface,InvokeEvent);
end;

function TProxyBase<T>.TProxyVirtualInterface.QueryInterface(const IID: TGUID; out Obj): HRESULT;
begin
  Result := inherited;
  if Result <> 0 then
    Result := FProxyBase.InternalQueryInterface(IID, Obj);
end;

function TProxyBase<T>.TProxyVirtualInterface._AddRef: Integer;
begin
  result := FProxyBase._AddRef;
end;

function TProxyBase<T>.TProxyVirtualInterface._Release: Integer;
begin
  result := FProxyBase._Release;
end;



end.

