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

unit Delphi.Mocks.Proxy.TypeInfo;

interface

uses
  Rtti,
  SysUtils,
  Generics.Collections,
  TypInfo,
  Delphi.Mocks,
  Delphi.Mocks.Proxy,
  Delphi.Mocks.WeakReference,
  Delphi.Mocks.Interfaces,
  Delphi.Mocks.Behavior;

type
  TProxy = class(TWeakReferencedObject, IWeakReferenceableObject, IInterface, IProxy, IVerify)
  private
    FTypeInfo               : PTypeInfo;
    FParentProxy            : IWeakReference<IProxy>;
    FInterfaceProxies       : TDictionary<TGUID, IProxy>;
    FAllowRedefineBehaviorDefinitions  : Boolean;

    FVirtualInterface       : IProxyVirtualInterface;
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

    FQueryingInterface      : boolean;
    FQueryingInternalInterface : boolean;

    FAutoMocker             : IAutoMock;

  protected type
    TProxyVirtualInterface = class(TVirtualInterface, IInterface, IProxyVirtualInterface)
    private
      FProxy : IWeakReference<IProxy>;
      function SupportsIInterface: Boolean;
    protected
      //IProxyVirtualInterface
      function QueryProxy(const IID: TGUID; out Obj : IProxy) : HRESULT;
      function QueryInterfaceWithOwner(const IID: TGUID; out Obj; const ACheckOwner : Boolean): HRESULT; overload;
      function QueryInterfaceWithOwner(const IID: TGUID; const ACheckOwner : Boolean): HRESULT; overload;
      function _AddRef: Integer; override; stdcall;
      function _Release: Integer; override; stdcall;
    public
      procedure AfterConstruction; override;
      //TVirtualInterface overrides
      constructor Create(const AProxy : IProxy; const AInterface: Pointer; const InvokeEvent: TVirtualInterfaceInvokeEvent);
      function QueryInterface(const IID: TGUID; out Obj): HRESULT; override; stdcall;
    end;

  protected
    procedure SetParentProxy(const AProxy : IProxy);
    function SupportsIInterface: Boolean;

    function QueryImplementedInterface(const IID: TGUID; out Obj): HRESULT; stdcall;
    function QueryInterface(const IID: TGUID; out Obj): HRESULT; virtual; stdcall;
    function _AddRef: Integer; override; stdcall;
    function _Release: Integer; override; stdcall;

    //IProxy
    function ProxyInterface : IInterface;

    function ProxySupports(const Instance: IInterface; const IID: TGUID) : boolean; virtual;
    function ProxyFromType(const ATypeInfo : PTypeInfo) : IProxy; virtual;
    procedure AddImplement(const AProxy : IProxy; const ATypeInfo : PTypeInfo); virtual;

    procedure DoInvoke(Method: TRttiMethod; const Args: TArray<TValue>; out Result: TValue);

    procedure SetBehaviorMustBeDefined(const AValue : Boolean);

    //IVerify
    procedure Verify(const message : string = '');
    procedure VerifyAll(const message : string = '');

    function CheckExpectations: string;

    function GetMethodData(const AMethodName : string; const ATypeName: string) : IMethodData; overload;

    procedure ClearSetupState;
  public
    procedure AfterConstruction; override;

    constructor Create(const ATypeInfo : PTypeInfo; const AAutoMocker : IAutoMock = nil; const AIsStubOnly : boolean = false); virtual;
    destructor Destroy; override;
  end;

implementation

uses
  Delphi.Mocks.Utils,
  Delphi.Mocks.When,
  Delphi.Mocks.MethodData,
  Delphi.Mocks.ParamMatcher;

{TProxy}

procedure TProxy.AddImplement(const AProxy: IProxy; const ATypeInfo : PTypeInfo);
begin

  if FInterfaceProxies.ContainsKey(GetTypeData(ATypeInfo).Guid) then
    raise EMockProxyAlreadyImplemented.Create('The mock already implements ' + ATypeInfo.NameStr);

  FInterfaceProxies.Add(GetTypeData(ATypeInfo).Guid, AProxy);
  AProxy.SetParentProxy(Self);
end;
//
//procedure TProxy.After(const AMethodName, AAfterMethodName: string);
//begin
//  raise Exception.Create('Not implemented');
//end;
//
//function TProxy.After(const AMethodName: string): IWhen<T>;
//begin
//  raise Exception.Create('Not implemented');
//end;
//
//procedure TProxy.AtLeast(const AMethodName: string; const times: Cardinal);
//var
//  methodData : IMethodData;
//begin
//  pInfo := TypeInfo(T);
//  methodData := GetMethodData(AMethodName,pInfo.NameStr);
//  Assert(methodData <> nil);
//  methodData.AtLeast(times);
//  ClearSetupState;
//end;
//
//function TProxy.AtLeast(const times: Cardinal): IWhen<T>;
//begin
//  FSetupMode := TSetupMode.Expectation;
//  FNextExpectation := TExpectationType.AtLeastWhen;
//  FTimes := times;
//  result := TWhen<T>.Create(Self.Proxy);
//end;
//
//procedure TProxy.AtLeastOnce(const AMethodName: string);
//var
//  methodData : IMethodData;
//begin
//  pInfo := TypeInfo(T);
//  methodData := GetMethodData(AMethodName,pInfo.NameStr);
//  Assert(methodData <> nil);
//  methodData.AtLeastOnce;
//  ClearSetupState;
//end;
//
//function TProxy.AtLeastOnce: IWhen<T>;
//begin
//  FSetupMode := TSetupMode.Expectation;
//  FNextExpectation := TExpectationType.AtLeastOnceWhen;
//  FTimes := 1;
//  result := TWhen<T>.Create(Self.Proxy);
//end;
//
//procedure TProxy.AtMost(const AMethodName: string; const times: Cardinal);
//var
//  methodData : IMethodData;
//begin
//  pInfo := TypeInfo(T);
//  methodData := GetMethodData(AMethodName,pInfo.NameStr);
//  Assert(methodData <> nil);
//  methodData.AtMost(times);
//  ClearSetupState;
//end;
//
//function TProxy.AtMost(const times: Cardinal): IWhen<T>;
//begin
//  FSetupMode := TSetupMode.Expectation;
//  FNextExpectation := TExpectationType.AtMostWhen;
//  FTimes := times;
//  result := TWhen<T>.Create(Self.Proxy);
//end;
//
//procedure TProxy.Before(const AMethodName, ABeforeMethodName: string);
//begin
//  raise Exception.Create('not implemented');
//end;
//
//function TProxy.Before(const AMethodName: string): IWhen<T>;
//begin
//  raise Exception.Create('not implemented');
//end;
//
//procedure TProxy.Between(const AMethodName: string; const a,  b: Cardinal);
//var
//  methodData : IMethodData;
//begin
//  pInfo := TypeInfo(T);
//  methodData := GetMethodData(AMethodName,pInfo.NameStr);
//  Assert(methodData <> nil);
//  methodData.Between(a,b);
//  ClearSetupState;
//end;
//
//function TProxy.Between(const a, b: Cardinal): IWhen<T>;
//begin
//  FSetupMode := TSetupMode.Expectation;
//  FNextExpectation := TExpectationType.BetweenWhen;
//  FBetween[0] := a;
//  FBetween[1] := b;
//  result := TWhen<T>.Create(Self.Proxy);
//
//end;

procedure TProxy.AfterConstruction;
begin
  inherited;
end;

function TProxy.CheckExpectations: string;
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

procedure TProxy.ClearSetupState;
begin
  FSetupMode := TSetupMode.None;
  FReturnValue := TValue.Empty;
  FExceptClass := nil;
  FNextFunc := nil;
end;

constructor TProxy.Create(const ATypeInfo : PTypeInfo; const AAutoMocker : IAutoMock; const AIsStubOnly : boolean);
var
  selfProxy : IProxy;
begin
  inherited Create;

  FName := ATypeInfo.NameStr;

  FAutoMocker := AAutoMocker;
  FParentProxy := nil;
  FVirtualInterface := nil;

  FSetupMode := TSetupMode.None;
  FBehaviorMustBeDefined := False;
  FMethodData := TDictionary<string,IMethodData>.Create;
  FIsStubOnly := AIsStubOnly;

  FInterfaceProxies := TDictionary<TGUID, IProxy>.Create;

  FTypeInfo := ATypeInfo;

  case FTypeInfo.Kind of
    //Create our proxy interface object, which will implement our interface T
    tkInterface :
    begin
      selfProxy := Self;
      FVirtualInterface := TProxyVirtualInterface.Create(selfProxy, FTypeInfo, Self.DoInvoke);

    end;
  end;
end;

destructor TProxy.Destroy;
begin
  FVirtualInterface := nil;

  FMethodData.Clear;
  FMethodData.Free;
  FInterfaceProxies.Clear;
  FInterfaceProxies.Free;

  FParentProxy := nil;

  inherited;
end;

procedure TProxy.DoInvoke(Method: TRttiMethod; const Args: TArray<TValue>; out Result: TValue);
var
  methodData : IMethodData;
  pInfo : PTypeInfo;
  matchers : TArray<IMatcher>;
begin
  pInfo := FTypeInfo;

  case FSetupMode of
    TSetupMode.None:
    begin
      //record actual behavior
      methodData := GetMethodData(method.Name,pInfo.NameStr);
      Assert(methodData <> nil);
      methodData.RecordHit(Args,Method.ReturnType,Result);
    end;
    TSetupMode.Behavior:
    begin
      try
        matchers := TMatcherFactory.GetMatchers;
        if Length(matchers) > 0 then
          if Length(matchers) < Length(Args) -1 then
            raise EMockSetupException.Create('Setup called with Matchers but on on all parameters : ' + Method.Name);

        //record desired behavior
        //first see if we know about this method
        methodData := GetMethodData(method.Name,pInfo.NameStr);
        Assert(methodData <> nil);
        case FNextBehavior of
          TBehaviorType.WillReturn:
          begin
            case Method.MethodKind of
              mkProcedure,
              mkDestructor,
              mkClassProcedure,
              mkClassDestructor,
              mkSafeProcedure : raise EMockSetupException.CreateFmt('Setup.WillReturn called on [%s] method [%s] which does not have a return value.', [MethodKindToStr(Method.MethodKind), Method.Name]);

              //Method kinds which have a return value.
              mkFunction, mkConstructor, mkClassFunction,
              mkClassConstructor, mkOperatorOverload, mkSafeFunction: ;
            end;

            //We don't test for the return type being valid as XE5 and below have a RTTI bug which does not return
            //a return type for function which reference their own class/interface. Even when RTTI is specified on
            //the declaration and forward declaration.
            if (FReturnValue.IsEmpty) then
              raise EMockSetupException.CreateFmt('Setup.WillReturn call on method [%s] was not passed a return value.', [Method.Name]);

            methodData.WillReturnWhen(Args, FReturnValue, matchers);
          end;
          TBehaviorType.WillRaise:
          begin
            methodData.WillRaiseAlways(FExceptClass,FExceptionMessage);
          end;
          TBehaviorType.WillExecuteWhen :
          begin
            methodData.WillExecuteWhen(FNextFunc,Args, matchers);
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
        methodData := GetMethodData(method.Name,pInfo.NameStr);
        Assert(methodData <> nil);

        matchers := TMatcherFactory.GetMatchers;

        case FNextExpectation of
          OnceWhen        : methodData.OnceWhen(Args, matchers);
          NeverWhen       : methodData.NeverWhen(Args, matchers) ;
          AtLeastOnceWhen : methodData.AtLeastOnceWhen(Args, matchers);
          AtLeastWhen     : methodData.AtLeastWhen(FTimes,args, matchers);
          AtMostOnceWhen  : methodData.AtLeastOnceWhen(Args, matchers);
          AtMostWhen      : methodData.AtMostWhen(FTimes,args, matchers);
          BetweenWhen     : methodData.BetweenWhen(FBetween[0],FBetween[1],Args, matchers) ;
          ExactlyWhen     : methodData.ExactlyWhen(FTimes,Args, matchers);
          BeforeWhen      : raise exception.Create('not implemented') ;
          AfterWhen       : raise exception.Create('not implemented');
        end;

      finally
        ClearSetupState;
      end;
    end;
  end;

end;

//procedure TProxy.Exactly(const AMethodName: string; const times: Cardinal);
//var
//  methodData : IMethodData;
//begin
//  methodData := GetMethodData(AMethodName, FTypeInfo.NameStr);
//  Assert(methodData <> nil);
//  methodData.Exactly(times);
//  ClearSetupState;
//end;
//
//function TProxy.GetBehaviorMustBeDefined: boolean;
//begin
//  Result := FBehaviorMustBeDefined;
//end;

function TProxy.GetMethodData(const AMethodName: string; const ATypeName: string): IMethodData;
var
  methodName : string;
  setupParams: TSetupMethodDataParameters;
begin
  methodName := LowerCase(AMethodName);
  if FMethodData.TryGetValue(methodName,Result) then
    exit;

  setupParams := TSetupMethodDataParameters.Create(FIsStubOnly, FBehaviorMustBeDefined, FAllowRedefineBehaviorDefinitions);
{$IFNDEF NEXTGEN}
  Result := TMethodData.Create(string(FTypeInfo.Name), AMethodName, setupParams, FAutoMocker);
{$ELSE}
  Result := TMethodData.Create(FTypeInfo.NameFld.ToString, AMethodName, setupParams, FAutoMocker);
{$ENDIF}
  FMethodData.Add(methodName,Result);
end;

function TProxy.QueryImplementedInterface(const IID: TGUID; out Obj): HRESULT;
var
  virtualProxy : IProxy;
begin
  Result := E_NOINTERFACE;

  if FQueryingInternalInterface then
    Exit;

  FQueryingInternalInterface := True;
  try
    //Otherwise look in the list of interface proxies that might have been implemented
    if (FInterfaceProxies.ContainsKey(IID)) then
    begin
      virtualProxy := FInterfaceProxies.Items[IID];
      Result := virtualProxy.ProxyInterface.QueryInterface(IID, Obj);

      if result = S_OK then
        Exit;
    end;

    {$Message 'TODO: Need to query the parent, but exclude ourselves and any other children which have already been called.'}

    //Call the parent.
    if FParentProxy <> nil then
      Result := FParentProxy.Data.QueryInterface(IID, obj);
  finally
    FQueryingInternalInterface := False;
  end;
end;

//procedure TProxy.Never(const AMethodName: string);
//var
//  methodData : IMethodData;
//begin
//  pInfo := TypeInfo(T);
//  methodData := GetMethodData(AMethodName, pInfo.NameStr);
//  Assert(methodData <> nil);
//  methodData.Never;
//  ClearSetupState;
//end;
//
//function TProxy.Never: IWhen<T>;
//begin
//  FSetupMode := TSetupMode.Expectation;
//  FNextExpectation := TExpectationType.NeverWhen;
//  result := TWhen<T>.Create(Self.Proxy);
//end;
//
//function TProxy.Once: IWhen<T>;
//begin
//  FSetupMode := TSetupMode.Expectation;
//  FNextExpectation := TExpectationType.OnceWhen;
//  result := TWhen<T>.Create(Self.Proxy);
//end;
//
//procedure TProxy.Once(const AMethodName: string);
//var
//  methodData : IMethodData;
//begin
//  methodData := GetMethodData(AMethodName,pInfo.NameStr);
//  Assert(methodData <> nil);
//  methodData.Once;
//  ClearSetupState;
//end;

//function TProxy.Proxy: TObject;
//var
//  virtualProxy : IInterface;
//begin
//  if FVirtualInterface = nil then
//    raise EMockNoProxyException.CreateFmt('Error casting to interface [%s], proxy does not appear to implememnt T', [FTypeInfo.NameStr]);
//
//  if FVirtualInterface.QueryInterface(GetTypeData(FTypeInfo).Guid, result) <> 0 then
//    raise EMockNoProxyException.CreateFmt('Error casting to interface, proxy does not appear to implememnt T', [FTypeInfo.NameStr]);
//end;

function TProxy.QueryInterface(const IID: TGUID; out Obj): HRESULT;
begin
  Result := E_NOINTERFACE;

  //If we are already querying this interface, leave.
  if FQueryingInterface then
    Exit;

  FQueryingInterface := True;
  try
    //The interface requested might be one of this classes interfaces. E.g. IProxy
    Result := inherited QueryInterface(IID, Obj);

    //If we have found the interface then return it.
    if Result = S_OK then
      Exit;
  finally
    FQueryingInterface := False;
  end;
end;

procedure TProxy.SetBehaviorMustBeDefined(const AValue: boolean);
begin
  FBehaviorMustBeDefined := AValue;
end;

procedure TProxy.SetParentProxy(const AProxy : IProxy);
begin
  FParentProxy := TWeakReference<IProxy>.Create(AProxy);
end;

function TProxy.SupportsIInterface: Boolean;
begin
  Result := (FParentProxy = nil);
end;

function TProxy.ProxyFromType(const ATypeInfo: PTypeInfo): IProxy;
var
  interfaceID : TGUID;
begin
  //Get the GUID of the type the proxy needs to support
  interfaceID := GetTypeData(ATypeInfo).Guid;

  //If we support the passed in type then return ourselves.
  if ProxySupports(FVirtualInterface, interfaceID) then
  begin
    Result := Self;
    Exit;
  end;

  //Are our children the proxy for this type?
  if FInterfaceProxies.ContainsKey(interfaceID) then
  begin
    //Remember that the virtual interface will be of the passed in type, therefore
    //return its proxy.
    Result := FInterfaceProxies.Items[interfaceID].ProxyFromType(ATypeInfo);
    Exit;
  end;

  raise EMockNoProxyException.CreateFmt('Error - No Proxy of type [%s] was found.', [ATypeInfo.NameStr]);
end;

function TProxy.ProxySupports(const Instance: IInterface; const IID: TGUID): boolean;
begin
  //We support the proxy if we have a virtual interface, which supports the passed in
  //interface. As the virtual interface is built to support mulitple interfaces we
  //need to ask it not check the other implementations.
  Result := (FVirtualInterface <> nil) and Supports(FVirtualInterface, IID, False);
end;

function TProxy.ProxyInterface: IInterface;
begin
  if FVirtualInterface = nil then
    raise EMockNoProxyException.CreateFmt('Error casting to interface [%s], proxy does not appear to implememnt T', [FTypeInfo.NameStr]);

  if FVirtualInterface.QueryInterface(GetTypeData(FTypeInfo).Guid, result) <> 0 then
    raise EMockNoProxyException.CreateFmt('Error casting to interface [%s], proxy does not appear to implememnt T', [FTypeInfo.NameStr]);
end;

procedure TProxy.Verify(const message: string);
var
  msg : string;
begin
  msg := CheckExpectations;
  if msg <> '' then
    raise EMockVerificationException.Create(message + #13#10 + msg);
end;

//function TProxy.WillExecute(const func: TExecuteFunc): IWhen<T>;
//begin
//  FSetupMode := TSetupMode.Behavior;
//  FNextBehavior := TBehaviorType.WillExecuteWhen;
//  FNextFunc := func;
//  result := TWhen<T>.Create(Self.Proxy);
//end;
//
//procedure TProxy.WillExecute(const AMethodName: string; const func: TExecuteFunc);
//var
//  methodData : IMethodData;
//  pInfo : PTypeInfo;
//begin
//  //actually record the behaviour here!
//  pInfo := TypeInfo(T);
//  methodData := GetMethodData(AMethodName,pInfo.NameStr);
//  Assert(methodData <> nil);
//  methodData.WillExecute(func);
//  ClearSetupState;
//end;
//
//function TProxy.WillRaise(const exceptionClass: ExceptClass;const message : string): IWhen<T>;
//begin
//  FSetupMode := TSetupMode.Behavior;
//  FNextBehavior := TBehaviorType.WillRaise;
//  FExceptClass := exceptionClass;
//  FExceptionMessage := message;
//  result := TWhen<T>.Create(Self.Proxy);
//end;
//
//procedure TProxy.WillRaise(const AMethodName: string; const exceptionClass: ExceptClass;const message : string);
//var
//  methodData : IMethodData;
//  pInfo : PTypeInfo;
//begin
//  //actually record the behaviour here!
//  pInfo := TypeInfo(T);
//  methodData := GetMethodData(AMethodName, pInfo.NameStr);
//  Assert(methodData <> nil);
//  methodData.WillRaiseAlways(exceptionClass,message);
//  ClearSetupState;
//end;
//
//function TProxy.WillReturn(const value: TValue): IWhen<T>;
//begin
//  FSetupMode := TSetupMode.Behavior;
//  FReturnValue := value;
//  FNextBehavior := TBehaviorType.WillReturn;
//  result := TWhen<T>.Create(Self.Proxy);
//end;
//
//procedure TProxy.WillReturnDefault(const AMethodName : string; const value : TValue);
//var
//  methodData : IMethodData;
//  pInfo : PTypeInfo;
//begin
//  //actually record the behaviour here!
//  pInfo := TypeInfo(T);
//  methodData := GetMethodData(AMethodName,pInfo.NameStr);
//  Assert(methodData <> nil);
//  methodData.WillReturnDefault(value);
//  ClearSetupState;
//end;

function TProxy._AddRef: Integer;
begin
  result := inherited;
end;

function TProxy._Release: Integer;
begin
  result := inherited;
end;

{ TProxy.TProxyVirtualInterface }

procedure TProxy.TProxyVirtualInterface.AfterConstruction;
begin
  inherited;
end;

constructor TProxy.TProxyVirtualInterface.Create(const AProxy : IProxy;
  const AInterface: Pointer; const InvokeEvent: TVirtualInterfaceInvokeEvent);
begin
  //Create a weak reference to our owner proxy. This is the proxy who implements
  //all the mocking interfaces required to setup, and verify us.
  FProxy := TWeakReference<IProxy>.Create(AProxy);

  inherited Create(Ainterface, InvokeEvent);
end;

function TProxy.TProxyVirtualInterface.QueryInterface(const IID: TGUID; out Obj): HRESULT;
begin
  //The default query interface will ask the owner for the implementing virtual
  //interface for the type being queried for. This allows a virtual interface of
  //IInterfaceOne to support IInterfaceTwo when asked. Use this when looking for
  //the implementing virtual interface, use QueryProxy when looking for the
  //owning proxy of the implemented type.
  Result := QueryInterfaceWithOwner(IID, Obj, True);
end;

function TProxy.TProxyVirtualInterface.QueryInterfaceWithOwner(const IID: TGUID; out Obj; const ACheckOwner: Boolean): HRESULT;
begin
  //See if we support the passed in interface.
  if IsEqualGUID(IID, IInterface) and not SupportsIInterface then
    Result := E_NOINTERFACE
  else
    Result := inherited QueryInterface(IID, Obj);

  //If we don't support the interface, then we need to look to our owner to see
  //who does implement it. This allows for a single proxy to implement multiple
  //interfaces at once.
  if (ACheckOwner) and (Result <> 0) then
  begin
    if FProxy <> nil then
      Result := FProxy.Data.QueryImplementedInterface(IID, Obj);
  end;
end;

function TProxy.TProxyVirtualInterface.QueryInterfaceWithOwner(const IID: TGUID; const ACheckOwner: Boolean): HRESULT;
var
  dud : IInterface;
begin
  Result := QueryInterfaceWithOwner(IID, dud, ACheckOwner);
end;

function TProxy.TProxyVirtualInterface.QueryProxy(const IID: TGUID; out Obj : IProxy): HRESULT;
begin
  Result := E_NOINTERFACE;

  //If this virtual proxy (and only this virtual proxy) supports the passed in
  //interface, return the proxy who owns us.
  if QueryInterfaceWithOwner(IID, Obj, False) <> 0 then
    Result := FProxy.QueryInterface(IProxy, Obj);
end;

function TProxy.TProxyVirtualInterface.SupportsIInterface: Boolean;
begin
  if FProxy <> nil then
    Result := FProxy.Data.SupportsIInterface
  else
    Result := True;
end;

function TProxy.TProxyVirtualInterface._AddRef: Integer;
begin
  result := inherited;
end;

function TProxy.TProxyVirtualInterface._Release: Integer;
begin
  result := inherited;
end;

procedure TProxy.VerifyAll(const message: string);
var
  proxy : IProxy;
  interfaceV : IVerify;
begin
  //Verify ourselves.
  Verify;

  //Now verify all our children.
  for proxy in FInterfaceProxies.Values.ToArray do
    if Supports(proxy, IVerify, interfaceV) then
      interfaceV.Verify(message);
end;

end.
