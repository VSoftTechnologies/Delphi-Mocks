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

unit Delphi.Mocks.Proxy;

interface

uses
  Rtti,
  SysUtils,
  TypInfo,
  Generics.Collections,
  Delphi.Mocks,
  Delphi.Mocks.WeakReference,
  Delphi.Mocks.Interfaces,
  Delphi.Mocks.Behavior;

type
  TProxyBaseInvokeEvent = procedure (Method: TRttiMethod; const Args: TArray<TValue>; out Result: TValue) of object;

  TSetupMode = (None, Behavior, Expectation);

  TProxy<T> = class(TWeakReferencedObject, IWeakReferenceableObject, IInterface, IProxy, IProxy<T>, IStubProxy<T>, IMockSetup<T>, IStubSetup<T>, IExpect<T>, IVerify)
  private
    //Implements members.
    //Can't define TProxy<T> or any other generic type as that type will be defined at runtime.
    FParentProxy            : IWeakReference<IProxy>;
    FInterfaceProxies       : TDictionary<TGUID, IProxy>;

    FVirtualInterface       : TVirtualInterface;
    FName : string;

    FMethodData             : TDictionary<string, IMethodData>;
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

  // protected type

    //GENERAL INFO:
    //An interface proxy is the external facing proxy for interfaces. The proxy virtual interfaces are
    //what implement each of the interfaces implemented by the interface proxy. The first interface implemented
    //is always the one of which we are at generic for. Subsequent ones can be added through the Implements
    //method which will add another ProxyVirtualInterface to the list of interfaces held by the external facing
    //InterfaceProxy.

    //HOW ALL INTERFACES SUPPORT EACH OTHER
    //When QueryInterface is called on any ProxyVirtualInterface, if they don't support the interface in question
    //they ask the creating InterfaceProxy if has that interface in its list of interfaces. If it does then the
    //InterfaceProxy will return the instance of that interface. Therefore ANY interface which is "Implemented"
    //but the InterfaceProxy is "Supported" by all interfaces "Implemented" and the "T" interface.

    //        TProxyVirtualInterface = class(TVirtualInterface)
    //        private
    //          FProxy : TInterfacedObject;
    //          FRootProxy : TProxy<T>;
    //        protected
    //        public
    //          function QueryInterface(const IID: TGUID; out Obj): HRESULT; override; stdcall;
    //          constructor Create(const AInterfaceProxy : TInterfacedObject; const ARootProxy : TProxy<T>; const AInterface: Pointer; const InvokeEvent: TVirtualInterfaceInvokeEvent);
    //        end;

  protected
    procedure SetParentProxy(const AProxy : IProxy);

    function QueryInterface(const IID: TGUID; out Obj): HRESULT;virtual; stdcall;
    // function InternalQueryInterface(const IID: TGUID; out Obj): HRESULT; stdcall;
    function _AddRef: Integer; stdcall;
    function _Release: Integer; stdcall;

    //IProxy
    function SetupFromTypeInfo(const ATypeInfo : PTypeInfo) : IInterface; virtual;
    procedure AddImplements(const AProxy : IProxy; const ATypeInfo : PTypeInfo); virtual;

    //IProxy<T>
    function MockSetup : IMockSetup<T>;
    function StubSetup : IStubSetup<T>;

    function IProxy<T>.Setup = MockSetup;
    function IStubProxy<T>.Setup = StubSetup;

    function Proxy : T; virtual;
    
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
    constructor Create(const AIsStubOnly : boolean = false); virtual;
    destructor Destroy; override;
  end;


implementation

uses
  Delphi.Mocks.Utils,
  Delphi.Mocks.When,
  Delphi.Mocks.MethodData,
  Windows;


{ TProxyBase }

procedure TProxy<T>.AddImplements(const AProxy: IProxy; const ATypeInfo : PTypeInfo);
begin
  inherited;

  if FInterfaceProxies.ContainsKey(GetTypeData(ATypeInfo).Guid) then
    raise EMockProxyAlreadyImplemented.Create('The mock already implements ' + ATypeInfo.NameStr);

  FInterfaceProxies.Add(GetTypeData(ATypeInfo).Guid, AProxy);
  AProxy.SetParentProxy(Self);
end;

procedure TProxy<T>.After(const AMethodName, AAfterMethodName: string);
begin
  raise Exception.Create('Not implemented');
end;

function TProxy<T>.After(const AMethodName: string): IWhen<T>;
begin
  raise Exception.Create('Not implemented');
end;

procedure TProxy<T>.AtLeast(const AMethodName: string; const times: Cardinal);
var
  methodData : IMethodData;
begin
  methodData := GetMethodData(AMethodName);
  Assert(methodData <> nil);
  methodData.AtLeast(times);
  ClearSetupState;
end;

function TProxy<T>.AtLeast(const times: Cardinal): IWhen<T>;
begin
  FSetupMode := TSetupMode.Expectation;
  FNextExpectation := TExpectationType.AtLeastWhen;
  FTimes := times;
  result := TWhen<T>.Create(Self.Proxy);
end;

procedure TProxy<T>.AtLeastOnce(const AMethodName: string);
var
  methodData : IMethodData;
begin
  methodData := GetMethodData(AMethodName);
  Assert(methodData <> nil);
  methodData.AtLeastOnce;
  ClearSetupState;
end;

function TProxy<T>.AtLeastOnce: IWhen<T>;
begin
  FSetupMode := TSetupMode.Expectation;
  FNextExpectation := TExpectationType.AtLeastOnceWhen;
  FTimes := 1;
  result := TWhen<T>.Create(Self.Proxy);
end;

procedure TProxy<T>.AtMost(const AMethodName: string; const times: Cardinal);
var
  methodData : IMethodData;
begin
  methodData := GetMethodData(AMethodName);
  Assert(methodData <> nil);
  methodData.AtMost(times);
  ClearSetupState;
end;

function TProxy<T>.AtMost(const times: Cardinal): IWhen<T>;
begin
  FSetupMode := TSetupMode.Expectation;
  FNextExpectation := TExpectationType.AtMostWhen;
  FTimes := times;
  result := TWhen<T>.Create(Self.Proxy);
end;

procedure TProxy<T>.Before(const AMethodName, ABeforeMethodName: string);
begin
  raise Exception.Create('not implemented');
end;

function TProxy<T>.Before(const AMethodName: string): IWhen<T>;
begin
  raise Exception.Create('not implemented');
end;

procedure TProxy<T>.Between(const AMethodName: string; const a,  b: Cardinal);
var
  methodData : IMethodData;
begin
  methodData := GetMethodData(AMethodName);
  Assert(methodData <> nil);
  methodData.Between(a,b);
  ClearSetupState;
end;

function TProxy<T>.Between(const a, b: Cardinal): IWhen<T>;
begin
  FSetupMode := TSetupMode.Expectation;
  FNextExpectation := TExpectationType.BetweenWhen;
  FBetween[0] := a;
  FBetween[1] := b;
  result := TWhen<T>.Create(Self.Proxy);

end;

function TProxy<T>.CheckExpectations: string;
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

procedure TProxy<T>.ClearSetupState;
begin
  FSetupMode := TSetupMode.None;
  FReturnValue := TValue.Empty;
  FExceptClass := nil;
  FNextFunc := nil;
end;

constructor TProxy<T>.Create(const AIsStubOnly : boolean);
var
  pInfo : PTypeInfo;
begin
  inherited Create;

  FParentProxy := nil;
  FVirtualInterface := nil;

  FSetupMode := TSetupMode.None;
  FBehaviorMustBeDefined := False;
  FMethodData := TDictionary<string,IMethodData>.Create;
  FIsStubOnly := AIsStubOnly;

  FInterfaceProxies := TDictionary<TGUID, IProxy>.Create;

  pInfo := TypeInfo(T);

  case pInfo.Kind of
    //Create our proxy interface object, which will implement our interface T
    tkInterface : FVirtualInterface := TVirtualInterface.Create(TypeInfo(T), Self.DoInvoke);
  end;

  FName := pInfo.Name;
end;

destructor TProxy<T>.Destroy;
begin
  if FVirtualInterface <> nil then
    FVirtualInterface.Free;

  FMethodData.Clear;
  FMethodData.Free;
  FInterfaceProxies.Clear;
  FInterfaceProxies.Free;

  FParentProxy := nil;

  inherited;
end;

procedure TProxy<T>.DoInvoke(Method: TRttiMethod; const Args: TArray<TValue>; out Result: TValue);
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

procedure TProxy<T>.Exactly(const AMethodName: string; const times: Cardinal);
var
  methodData : IMethodData;
begin
  methodData := GetMethodData(AMethodName);
  Assert(methodData <> nil);
  methodData.Exactly(times);
  ClearSetupState;
end;

function TProxy<T>.Exactly(const times: Cardinal): IWhen<T>;
begin
  FSetupMode := TSetupMode.Expectation;
  FNextExpectation := TExpectationType.ExactlyWhen;
  FTimes := times;
  result := TWhen<T>.Create(Self.Proxy);
end;

function TProxy<T>.Expect: IExpect<T>;
begin
  result := Self as IExpect<T> ;
end;

function TProxy<T>.GetBehaviorMustBeDefined: boolean;
begin
  Result := FBehaviorMustBeDefined;
end;

function TProxy<T>.GetMethodData(const AMethodName: string): IMethodData;
var
  methodName : string;
begin
  methodName := LowerCase(AMethodName);
  if FMethodData.TryGetValue(methodName,Result) then
    exit;

  Result := TMethodData.Create(AMethodName,FIsStubOnly);
  FMethodData.Add(methodName,Result);
end;

//procedure TProxy<T>.Implements<I>;
//var
//  virtualProxy : TProxyVirtualInterface;
//begin
//  inherited;
//
//  if FVirtualInterfaces.ContainsKey(GetTypeData(TypeInfo(I)).Guid) then
//    raise EMockProxyAlreadyImplemented.Create('The mock already implements ' + TypeInfo(I).NameStr);
//
//  virtualProxy := TProxyVirtualInterface.Create(Self, TypeInfo(I), Self.DoInvoke);
//  FVirtualInterfaces.Add(GetTypeData(TypeInfo(I)).Guid, virtualProxy);
//
//  //  if FVirtualInterfaces.ContainsKey(GetTypeData(ATypeInfo).Guid) then
//  //    raise EMockProxyAlreadyImplemented.Create('The mock already implements ' + ATypeInfo.NameStr);
//  //
//  //  virtualProxy := TProxyVirtualInterface.Create( Self, ATypeInfo, Self.DoInvoke);
//  //  FVirtualInterfaces.Add(GetTypeData(ATypeInfo).Guid, virtualProxy);
//end;

//function TProxy<T>.InternalQueryInterface(const IID: TGUID; out Obj): HRESULT;
//var
//  virtualProxy : IInterface;
//begin
//  Result := E_NOINTERFACE;
//
//  if (IsEqualGUID(IID,IInterface)) then
//    if GetInterface(IID, Obj) then
//      Result := 0;
//
//  if result = S_OK then
//    Exit;
//
//  if not FVirtualInterfaces.ContainsKey(IID) then
//    Exit;
//
//  virtualProxy := FVirtualInterfaces.Items[IID];
//  result := virtualProxy.QueryInterface(IID, Obj);
//end;

procedure TProxy<T>.Never(const AMethodName: string);
var
  methodData : IMethodData;
begin
  methodData := GetMethodData(AMethodName);
  Assert(methodData <> nil);
  methodData.Never;
  ClearSetupState;
end;

function TProxy<T>.Never: IWhen<T>;
begin
  FSetupMode := TSetupMode.Expectation;
  FNextExpectation := TExpectationType.NeverWhen;
  result := TWhen<T>.Create(Self.Proxy);
end;

function TProxy<T>.Once: IWhen<T>;
begin
  FSetupMode := TSetupMode.Expectation;
  FNextExpectation := TExpectationType.OnceWhen;
  result := TWhen<T>.Create(Self.Proxy);
end;

procedure TProxy<T>.Once(const AMethodName: string);
var
  methodData : IMethodData;
begin
  methodData := GetMethodData(AMethodName);
  Assert(methodData <> nil);
  methodData.Once;
  ClearSetupState;
end;


function TProxy<T>.Proxy: T;
var
  pInfo : PTypeInfo;
  virtualProxy : IInterface;
begin
  pInfo := TypeInfo(T);

  if FVirtualInterface = nil then
    raise EMockNoProxyException.Create('Error casting to interface ' + pInfo.NameStr + ' , proxy does not appear to implememnt T');

  if FVirtualInterface.QueryInterface(GetTypeData(pInfo).Guid, result) <> 0 then
    raise EMockNoProxyException.Create('Error casting to interface ' + pInfo.NameStr + ' , proxy does not appear to implememnt T');

//  if FInterfaceProxies.ContainsKey(GetTypeData(pInfo).Guid) then
//    virtualProxy := FInterfaceProxies.Items[GetTypeData(pInfo).Guid]
//  else
//    raise EMockNoProxyException.Create('Error proxy casting to interface');
//
//  if virtualProxy.QueryInterface(GetTypeData(pInfo).Guid, result) <> 0 then
//	  raise EMockNoProxyException.Create('Error casting to interface ' + pInfo.NameStr + ' , proxy does not appear to implememnt T');

end;

function TProxy<T>.QueryInterface(const IID: TGUID; out Obj): HRESULT;
var
  virtualProxy : IInterface;
begin
  //Try our parent first. The interface requested might be one of this classes interfaces. E.g. IProxy
  Result := inherited QueryInterface(IID, Obj);

  //If we have found the interface then return it.
  if Result = S_OK then
    Exit;

  //Otherwise look at the virtual interface we have if there is one.
  if FVirtualInterface <> nil then
  begin
    Result := FVirtualInterface.QueryInterface(IID, Obj);

    //Return that virtual interface if there was one.
    if Result = S_OK then
      Exit;
  end;

  //Otherwise look in the list of interface proxies that might have been implemented
  if (FInterfaceProxies.ContainsKey(IID)) then
  begin
    virtualProxy := FInterfaceProxies.Items[IID];
    Result := virtualProxy.QueryInterface(IID, Obj);

    if result = S_OK then
      Exit;
  end;
end;

procedure TProxy<T>.SetBehaviorMustBeDefined(const value: boolean);
begin
  FBehaviorMustBeDefined := value;
end;

procedure TProxy<T>.SetParentProxy(const AProxy : IProxy);
begin
  FParentProxy := TWeakReference<IProxy>.Create(AProxy);
end;

function TProxy<T>.SetupFromTypeInfo(const ATypeInfo: PTypeInfo): IInterface;
begin
  QueryInterface(GetTypeData(ATypeInfo).Guid, Result);
end;

function TProxy<T>.StubSetup: IStubSetup<T>;
begin
  result := Self;
end;

function TProxy<T>.MockSetup: IMockSetup<T>;
begin
  result := Self;
end;

procedure TProxy<T>.Verify(const message: string);
var
  msg : string;
begin
  msg := CheckExpectations;
  if msg <> '' then
    raise EMockVerificationException.Create(message + #13#10 + msg);

end;

function TProxy<T>.WillExecute(const func: TExecuteFunc): IWhen<T>;
begin
  FSetupMode := TSetupMode.Behavior;
  FNextBehavior := TBehaviorType.WillExecuteWhen;
  FNextFunc := func;
  result := TWhen<T>.Create(Self.Proxy);
end;

procedure TProxy<T>.WillExecute(const AMethodName: string; const func: TExecuteFunc);
var
  methodData : IMethodData;
begin
  //actually record the behaviour here!
  methodData := GetMethodData(AMethodName);
  Assert(methodData <> nil);
  methodData.WillExecute(func);
  ClearSetupState;
end;

function TProxy<T>.WillRaise(const exceptionClass: ExceptClass;const message : string): IWhen<T>;
begin
  FSetupMode := TSetupMode.Behavior;
  FNextBehavior := TBehaviorType.WillRaise;
  FExceptClass := exceptionClass;
  FExceptionMessage := message;
  result := TWhen<T>.Create(Self.Proxy);
end;

procedure TProxy<T>.WillRaise(const AMethodName: string; const exceptionClass: ExceptClass;const message : string);
var
  methodData : IMethodData;
begin
  //actually record the behaviour here!
  methodData := GetMethodData(AMethodName);
  Assert(methodData <> nil);
  methodData.WillRaiseAlways(exceptionClass,message);
  ClearSetupState;
end;

function TProxy<T>.WillReturn(const value: TValue): IWhen<T>;
begin
  FSetupMode := TSetupMode.Behavior;
  FReturnValue := value;
  FNextBehavior := TBehaviorType.WillReturn;
  result := TWhen<T>.Create(Self.Proxy);
end;

procedure TProxy<T>.WillReturnDefault(const AMethodName : string; const value : TValue);
var
  methodData : IMethodData;
begin
  //actually record the behaviour here!
  methodData := GetMethodData(AMethodName);
  Assert(methodData <> nil);
  methodData.WillReturnDefault(value);
  ClearSetupState;
end;

function TProxy<T>._AddRef: Integer;
begin
  result := inherited;
end;

function TProxy<T>._Release: Integer;
begin
  result := inherited;
end;

//{ TProxy<T>.TProxyVirtualInterface }
//
//constructor TProxy<T>.TProxyVirtualInterface.Create(const AInterfaceProxy : TProxy<I>;
//  const ARootProxy : TProxy<T>; const AInterface: Pointer; const InvokeEvent: TVirtualInterfaceInvokeEvent);
//begin
//  FProxy := AInterfaceProxy;
//  FRootProxy := ARootProxy;
//
//  inherited Create(Ainterface, InvokeEvent);
//end;
//
//function TProxy<T>.TProxyVirtualInterface.QueryInterface(const IID: TGUID; out Obj): HRESULT;
//begin
//  Result := inherited;
//  if Result <> 0 then
//    Result := FProxy.InternalQueryInterface(IID, Obj);
//end;

end.
