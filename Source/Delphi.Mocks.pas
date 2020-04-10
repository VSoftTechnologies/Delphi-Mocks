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

unit Delphi.Mocks;

interface

{$I 'Delphi.Mocks.inc'}

uses
  TypInfo,
  Rtti,
  Sysutils,
  {$IFDEF SUPPORTS_REGEX}
  System.RegularExpressions,
  {$ENDIF}
  Delphi.Mocks.WeakReference;

type
  IWhen<T> = interface;

  //Records the expectations we have when our Mock is used. We can then verify
  //our expectations later.
  IExpect<T> = interface
    ['{8B9919F1-99AB-4526-AD90-4493E9343083}']
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
  end;

  IWhen<T> = interface
    ['{A8C2E07B-A5C1-463D-ACC4-BA2881E8419F}']
    function When : T;
  end;

  ///  This is the definition for an anonymous function you can pass into
  ///  WillExecute. The args array will be the arguments passed to the method
  ///  called on the Mock. If the method returns a value then your anon func must
  ///  return that.. and the return type must match. The return type is passed in
  ///  so that you can ensure tha.
  TExecuteFunc = reference to function (const args : TArray<TValue>; const ReturnType : TRttiType) : TValue;

  IStubSetup<T> = interface
    ['{3E6AD69A-11EA-47F1-B5C3-63F7B8C265B1}']
    function GetBehaviorMustBeDefined : boolean;
    procedure SetBehaviorMustBeDefined(const value : boolean);
    function GetAllowRedefineBehaviorDefinitions : boolean;
    procedure SetAllowRedefineBehaviorDefinitions(const value : boolean);

    //set the return value for a method when called with the parameters specified on the When
    function WillReturn(const value : TValue) : IWhen<T>; overload;

    //set the return value for a method when called with the parameters specified on the When
    //AllowNil flag allow to define: returning nil value is allowed or not.
    function WillReturn(const value : TValue; const AllowNil: Boolean) : IWhen<T>; overload;

    //set the nil as return value for a method when called with the parameters specified on the When
    function WillReturnNil : IWhen<T>;

    //Will exedute the func when called with the specified parameters
    function WillExecute(const func : TExecuteFunc) : IWhen<T>;overload;

    //will always execute the func no matter what parameters are specified.
    procedure WillExecute(const AMethodName : string; const func : TExecuteFunc);overload;

    //set the default return value for a method when it is called with parameter values we
    //haven't specified
    procedure WillReturnDefault(const AMethodName : string; const value : TValue);

    //set the Exception class that will be raised when the method is called with the parmeters specified
    function WillRaise(const exceptionClass : ExceptClass; const message : string = '') : IWhen<T>;overload;

    //This method will always raise an exception.. this behavior will trump any other defined behaviors
    procedure WillRaise(const AMethodName : string; const exceptionClass : ExceptClass; const message : string = '');overload;

    //set the Exception class that will be raised when the method is called with the parmeters specified
    function WillRaiseWhen(const exceptionClass: ExceptClass; const message: string = ''): IWhen<T>;

    //If true, calls to methods for which we have not defined a behavior will cause verify to fail.
    property BehaviorMustBeDefined : boolean read GetBehaviorMustBeDefined write SetBehaviorMustBeDefined;

    //If true, it is possible to overwrite a already defined behaviour.
    property AllowRedefineBehaviorDefinitions: boolean read GetAllowRedefineBehaviorDefinitions write SetAllowRedefineBehaviorDefinitions;
  end;

  //We use the Setup to configure our expected behaviour rules and to verify
  //that those expectations were met.
  IMockSetup<T> = interface(IStubSetup<T>)
    ['{D6B21933-BF51-4937-877E-51B59A3B3268}']
    //Set Expectations for methods
    function Expect : IExpect<T>;
  end;

  IStubProxy<T> = interface
    ['{578BAF90-4155-4C0F-AAED-407057C6384F}']
    function Setup : IStubSetup<T>;
    function Proxy : T;
  end;

  {$IFOPT M+}
    {$M-}
    {$DEFINE ENABLED_M+}
  {$ENDIF}
  IProxy = interface(IWeakReferenceableObject)
    ['{C97DC7E8-BE99-46FE-8488-4B356DD4AE29}']
    function ProxyInterface : IInterface;
    function ProxyFromType(const ATypeInfo : PTypeInfo) : IProxy;
    procedure AddImplement(const AProxy : IProxy; const ATypeInfo : PTypeInfo);
    function QueryImplementedInterface(const IID: TGUID; out Obj): HRESULT; stdcall;
    procedure SetParentProxy(const AProxy : IProxy);
    function SupportsIInterface: Boolean;
  end;
  {$IFDEF ENABLED_M+}
    {$M+}
  {$ENDIF}

  //used by the mock - need to find another place to put this.. circular references
  //problem means we need it here for now.
  IProxy<T> = interface(IProxy)
    ['{1E3A98C5-78BA-4D65-A4BA-B6992B8B4783}']
    function Setup : IMockSetup<T>;
    function Proxy : T;
  end;

  IAutoMock = interface
    ['{9C7113DF-6F93-496D-A223-61D30782C7D8}']
    function Mock(const ATypeInfo : PTypeInfo) : IProxy;
    procedure Add(const ATypeName : string; const AMock: IProxy);
  end;

  TStub<T> = record
  private
    FProxy : IStubProxy<T>;
    FAutomocker : IAutoMock;
  public
    class operator Implicit(const Value: TStub<T>): T;
    function Setup : IStubSetup<T>;
    function Instance : T;
    function InstanceAsValue : TValue;
    class function Create: TStub<T>; overload; static;
    class function Create(const ACreateObjectFunc: TFunc<T>): TStub<T>; overload; static;
    // explicit cleanup. Not sure if we really need this.
    procedure Free;
  end;

  //We use a record here to take advantage of operator overloading, the Implicit
  //operator allows us to use the mock as the interface without holding a reference
  //to the mock interface outside of the mock.
  TMock<T> = record
  private
    FProxy : IProxy<T>;
    FCreated : Boolean;
    FAutomocker : IAutoMock;

    procedure CheckCreated;

  public
    class operator Implicit(const Value: TMock<T>): T;
    class function Create(const AAutoMock: IAutoMock; const ACreateObjectFunc: TFunc<T>): TMock<T>; overload; static;

    function Setup : IMockSetup<T>; overload;
    function Setup<I : IInterface> : IMockSetup<I>; overload;

    //Verify that our expectations were met.
    procedure Verify(const message : string = ''); overload;
    procedure Verify<I : IInterface>(const message : string = ''); overload;
    procedure VerifyAll(const message : string = '');

    function CheckExpectations: string;
    procedure Implement<I : IInterface>; overload;
    function Instance : T; overload;
    function Instance<I : IInterface> : I; overload;
    function InstanceAsValue : TValue; overload;
    function InstanceAsValue<I : IInterface> : TValue; overload;

    class function Create: TMock<T>; overload; static;
    class function Create(const ACreateObjectFunc: TFunc<T>): TMock<T>; overload; static;

    //Explicit cleanup. Not sure if we really need this.
    procedure Free;
  end;

  TAutoMockContainer = record
  private
    FAutoMocker : IAutoMock;
  public
    function Mock<T> : TMock<T>; overload;
    procedure Mock(const ATypeInfo : PTypeInfo); overload;

    class function Create : TAutoMockContainer; static;
  end;

  ///  Used for defining permissable parameter values during method setup.
  ///  Inspired by Moq
  ItRec = record
    var
      ParamIndex : cardinal;

    constructor Create(const AParamIndex : Integer);

    function IsAny<T>() : T ;
    function Matches<T>(const predicate: TPredicate<T>) : T;
    function IsNotNil<T> : T;
    function IsEqualTo<T>(const value : T) : T;
    function IsInRange<T>(const fromValue : T; const toValue : T) : T;
    function IsIn<T>(const values : TArray<T>) : T; overload;
    function IsIn<T>(const values : IEnumerable<T>) : T; overload;
    function IsNotIn<T>(const values : TArray<T>) : T; overload;
    function IsNotIn<T>(const values : IEnumerable<T>) : T; overload;
    {$IFDEF SUPPORTS_REGEX} //XE2 or later
    function IsRegex(const regex : string; const options : TRegExOptions = []) : string;
    {$ENDIF}
    function AreSamePropertiesThat<T>(const Value: T): T;
    function AreSameFieldsThat<T>(const Value: T): T;
    function AreSameFieldsAndPropertiedThat<T>(const Value: T): T;
  end;

  TComparer = class
  public
    class function CompareFields<T>(Param1, Param2: T): Boolean;
    class function CompareMembers<T: TRttiMember; T2>(Members: TArray<T>; Param1, Param2: T2): Boolean;
    class function CompareProperties<T>(Param1, Param2: T): Boolean;
  end;

  //Exception Types that the mocks will raise.
  EMockException = class(Exception);
  EMockProxyAlreadyImplemented = class(EMockException);
  EMockSetupException = class(EMockException);
  EMockNoRTTIException = class(EMockException);
  EMockNoProxyException = class(EMockException);
  EMockVerificationException = class(EMockException);

  TTypeInfoHelper = record helper for TTypeInfo
    function NameStr : string; inline;
  end;

  function It(const AParamIndx : Integer) : ItRec;
  function It0 : ItRec;
  function It1 : ItRec;
  function It2 : ItRec;
  function It3 : ItRec;
  function It4 : ItRec;
  function It5 : ItRec;
  function It6 : ItRec;
  function It7 : ItRec;
  function It8 : ItRec;
  function It9 : ItRec;

implementation

uses
  Classes,
  Generics.Defaults,
  Delphi.Mocks.Utils,
  Delphi.Mocks.Interfaces,
  Delphi.Mocks.Proxy,
  Delphi.Mocks.ObjectProxy,
  Delphi.Mocks.ParamMatcher,
  Delphi.Mocks.AutoMock,
  Delphi.Mocks.Validation,
  Delphi.Mocks.Helpers;

procedure TMock<T>.CheckCreated;
var
  pInfo : PTypeInfo;
begin
  pInfo := TypeInfo(T);

  if not FCreated then
    raise EMockException.CreateFmt('Create for TMock<%s> was not called before use.', [pInfo.Name]);

  if (FProxy = nil) then
    raise EMockException.CreateFmt('Internal Error : Internal Proxy for TMock<%s> was nil.', [pInfo.Name]);

end;

function TMock<T>.CheckExpectations: string;
var
  su : IMockSetup<T>;
  v : IVerify;
begin
  CheckCreated;

  if Supports(FProxy.Setup,IVerify,v) then
    Result := v.CheckExpectations
  else
    raise EMockException.Create('Could not cast Setup to IVerify interface!');
end;

class function TMock<T>.Create: TMock<T>;
begin
  Result := Create(nil);
end;

class function TMock<T>.Create(const ACreateObjectFunc: TFunc<T>): TMock<T>;
begin
  Result := Create(nil, ACreateObjectFunc);
end;


class function TMock<T>.Create(const AAutoMock: IAutoMock; const ACreateObjectFunc: TFunc<T>): TMock<T>;
var
  proxy : IInterface;
  pInfo : PTypeInfo;
begin
  //Make sure that we start off with a clean mock
  FillChar(Result, SizeOf(Result), 0);

  //By default we don't auto mock TMock<T>. It changes when TAutoMock is used.
  Result.FAutomocker := AAutoMock;

  pInfo := TypeInfo(T);

  //Raise exceptions if the mock doesn't meet the requirements.
  TMocksValidation.CheckMockType(pInfo);

  case pInfo.Kind of
    //Create our proxy object, which will implement our object T
    tkClass : proxy := TObjectProxy<T>.Create(ACreateObjectFunc, Result.FAutomocker, false);
    //Create our proxy interface object, which will implement our interface T
    tkInterface : proxy := TProxy<T>.Create(Result.FAutomocker, false);
  end;

  //Push the proxy into the result we are returning.
  if proxy.QueryInterface(GetTypeData(TypeInfo(IProxy<T>)).Guid, Result.FProxy) <> 0 then
    //TODO: This raise seems superfluous as the only types which are created are controlled by us above. They all implement IProxy<T>
    raise EMockNoProxyException.Create('Error casting to interface ' + pInfo.NameStr + ' , proxy does not appear to implememnt IProxy<T>');

  //The record has been created!
  Result.FCreated := True;
end;

procedure TMock<T>.Free;
begin
  CheckCreated;
  FProxy := nil;
  FAutomocker := nil;
end;

procedure TMock<T>.Implement<I>;
var
  proxy : IProxy<I>;
  pInfo : PTypeInfo;
begin
  CheckCreated;

  if FProxy is TObjectProxy<T> then
    raise ENotSupportedException.Create('Adding interface implementation to non interfaced objects not supported at this time');

  pInfo := TypeInfo(I);

  TMocksValidation.CheckMockInterface(pInfo);

  proxy := TProxy<I>.Create;

  FProxy.AddImplement(proxy, pInfo);
end;

class operator TMock<T>.Implicit(const Value: TMock<T>): T;
begin
  Value.CheckCreated;

  result := Value.FProxy.Proxy;
end;

function TMock<T>.Instance : T;
begin
  CheckCreated;

  result := FProxy.Proxy;
end;

function TMock<T>.Instance<I>: I;
var
  prox : IInterface;
  proxyI : IProxy<I>;
  pInfo : PTypeInfo;
begin
  result := nil;

  CheckCreated;

  //Does the proxy we have, or any of its children support a proxy for the passed
  //in interface type?
  pInfo := TypeInfo(I);
  prox := FProxy.ProxyFromType(pInfo);

  if prox = nil then
    raise EMockException.CreateFmt('Mock does not implement [%s]', [pInfo.NameStr]);

  if (prox = nil) or (not Supports(prox, IProxy<I>, proxyI)) then
    raise EMockException.CreateFmt('Proxy for [%s] does not support [IProxy<T>].', [pInfo.NameStr]);

  //Return the interface for the requested implementation.
  result := proxyI.Proxy;
end;

function TMock<T>.InstanceAsValue: TValue;
begin
  CheckCreated;

  result := TValue.From<T>(Self);
end;

function TMock<T>.InstanceAsValue<I>: TValue;
begin
  CheckCreated;

  result := TValue.From<I>(Self.Instance<I>);
end;

function TMock<T>.Setup: IMockSetup<T>;
begin
  CheckCreated;

  result := FProxy.Setup;
end;

{$O-}
function TMock<T>.Setup<I>: IMockSetup<I>;
var
  setup : IProxy;
  pInfo : PTypeInfo;
  pMockSetupInfo : PTypeInfo;
begin
  CheckCreated;
  //We have to ask for the proxy who owns the implementation of the interface/object
  //in question. The reason for this it that all proxies implement IProxy<T> and
  //therefore we will just get the first proxy always.
  //E.g. IProxy<IInterfaceOne> and IProxy<IInterfaceTwo> have the same GUID. Makes
  //generic interfaces hard to use.
  pInfo := TypeInfo(I);

  //Get the proxy which implements
  setup := FProxy.ProxyFromType(pInfo);

  //If nill is returned then we don't implement the defined type.
  if setup = nil then
    raise EMockNoProxyException.CreateFmt('[%s] is not implement.', [pInfo.NameStr]);

  //Now get it as the mocksetup that we requrie. Note that this doesn't ensure
  //that I is actually implemented as all proxies implment IMockSetup<I>. This
  //is what we only return the error that IMockSetup isn't implemented.
  if not Supports(setup, IMockSetup<I>, result) then
  begin
    pMockSetupInfo := TypeInfo(IMockSetup<I>);
    raise EMockNoProxyException.CreateFmt('[%s] Proxy does not implement [%s]', [pInfo.NameStr, pMockSetupInfo.NameStr]);
  end;
end;
{$O+}


procedure TMock<T>.Verify(const message: string);
var
  v : IVerify;
begin
  CheckCreated;

  if Supports(FProxy.Setup, IVerify, v) then
    v.Verify(message)
  else
    raise EMockException.Create('Could not cast Setup to IVerify interface!');
end;

{$O-}
procedure TMock<T>.Verify<I>(const message: string);
var
  prox : IInterface;
  interfaceV : IVerify;
  pInfo : PTypeInfo;
begin
  CheckCreated;

  //Does the proxy we have, or any of its children support a proxy for the passed
  //in interface type?

  pInfo := TypeInfo(I);

  prox := FProxy.ProxyFromType(pInfo);

  if (prox = nil) or (not Supports(prox, IVerify, interfaceV)) then
    raise EMockException.Create('Could not cast Setup to IVerify interface!');

  interfaceV.Verify(message);
end;
{$O+}

procedure TMock<T>.VerifyAll(const message: string);
var
  interfaceV : IVerify;
begin
  CheckCreated;

  if Supports(FProxy.Setup, IVerify, interfaceV) then
    interfaceV.VerifyAll(message)
  else
    raise EMockException.Create('Could not cast Setup to IVerify interface!');
end;

{ TStub<T> }

class function TStub<T>.Create(): TStub<T>;
begin
  result := TStub<T>.Create(nil);
end;


class function TStub<T>.Create(const ACreateObjectFunc: TFunc<T>): TStub<T>;
var
  proxy : IInterface;
  pInfo : PTypeInfo;
begin
  //Make sure that we start off with a clean mock
  FillChar(Result, SizeOf(Result), 0);

  //By default we don't auto mock TMock<T>. It changes when TAutoMock is used.
  Result.FAutomocker := nil;

  pInfo := TypeInfo(T);

  if not (pInfo.Kind in [tkInterface,tkClass]) then
    raise EMockException.Create(pInfo.NameStr + ' is not an Interface or Class. TStub<T> supports interfaces and classes only');

  case pInfo.Kind of
    //NOTE: We have a weaker requirement for an object proxy opposed to an interface proxy.
    //NOTE: Object proxy doesn't require more than zero methods on the object.
    tkClass :
    begin
      //Check to make sure we have
      if not CheckClassHasRTTI(pInfo) then
          raise EMockNoRTTIException.Create(pInfo.NameStr + ' does not have RTTI, specify {$M+} for the object to enabled RTTI');

      //Create our proxy object, which will implement our object T
      proxy := TObjectProxy<T>.Create(ACreateObjectFunc, Result.FAutomocker, true);
    end;
    tkInterface :
    begin
      //Check to make sure we have
      if not CheckInterfaceHasRTTI(pInfo) then
        raise EMockNoRTTIException.Create(pInfo.NameStr + ' does not have RTTI, specify {$M+} for the interface to enabled RTTI');

      //Create our proxy interface object, which will implement our interface T
      proxy := TProxy<T>.Create(Result.FAutomocker, true);
    end;
  else
    raise EMockException.Create('Invalid type kind T');
  end;

  //Push the proxy into the result we are returning.
  if proxy.QueryInterface(GetTypeData(TypeInfo(IStubProxy<T>)).Guid, Result.FProxy) <> 0 then
    //TODO: This raise seems superfluous as the only types which are created are controlled by us above. They all implement IProxy<T>
    raise EMockNoProxyException.Create('Error casting to interface ' + pInfo.NameStr + ' , proxy does not appear to implememnt IProxy<T>');
end;

procedure TStub<T>.Free;
begin
  FProxy := nil;
end;

class operator TStub<T>.Implicit(const Value: TStub<T>): T;
begin
  result := Value.FProxy.Proxy;
end;

function TStub<T>.Instance: T;
begin
  result := FProxy.Proxy;
end;

function TStub<T>.InstanceAsValue: TValue;
begin
  result := TValue.From<T>(Self);
end;

function TStub<T>.Setup: IStubSetup<T>;
begin
  result := FProxy.Setup;
end;

{ TTypeInfoHelper }

function TTypeInfoHelper.NameStr: string;
begin
{$IFNDEF NEXTGEN}
  result := string(Self.Name);
{$ELSE}
  result := Self.NameFld.ToString;
{$ENDIF}
end;

{ TAutoMockContainer }

class function TAutoMockContainer.Create: TAutoMockContainer;
begin
  FillChar(Result, SizeOf(Result), 0);

  Result.FAutoMocker := TAutoMock.Create;
end;

procedure TAutoMockContainer.Mock(const ATypeInfo: PTypeInfo);
begin
  FAutoMocker.Mock(ATypeInfo);
end;

function TAutoMockContainer.Mock<T>: TMock<T>;
var
  mock : TMock<T>;
  pInfo : PTypeInfo;
begin
  pInfo := TypeInfo(T);

  mock := TMock<T>.Create(FAutoMocker, nil);
  FAutoMocker.Add(pInfo.NameStr, mock.FProxy);

  result := mock;
end;

{ It }

function ItRec.AreSameFieldsAndPropertiedThat<T>(const Value: T): T;
begin
  Result := Value;

  TMatcherFactory.Create<T>(ParamIndex,
    function(Param: T): Boolean
    begin
      Result := TComparer.CompareFields<T>(Param, Value) and TComparer.CompareProperties<T>(Param, Value);
    end);
end;

function ItRec.AreSameFieldsThat<T>(const Value: T): T;
begin
  Result := Value;

  TMatcherFactory.Create<T>(ParamIndex,
    function(Param: T): Boolean
    begin
      Result := TComparer.CompareFields<T>(Param, Value);
    end);
end;

function ItRec.AreSamePropertiesThat<T>(const Value: T): T;
begin
  Result := Value;

  TMatcherFactory.Create<T>(ParamIndex,
    function(Param: T): Boolean
    begin
      Result := TComparer.CompareProperties<T>(Param, Value);
    end);
end;

constructor ItRec.Create(const AParamIndex : Integer);
begin
  ParamIndex := AParamIndex;
end;

function ItRec.IsAny<T>: T;
begin
  result := Default(T);
  TMatcherFactory.Create<T>(ParamIndex,
    function(value : T) : boolean
    begin
      result := true;
    end);
end;

function ItRec.IsEqualTo<T>(const value : T) : T;
begin
  Result := Value;

  TMatcherFactory.Create<T>(ParamIndex,
    function(param : T) : boolean
    var
      comparer : IEqualityComparer<T>;
    begin
      comparer := TEqualityComparer<T>.Default;
      result := comparer.Equals(param,value);
    end);
end;

function ItRec.IsIn<T>(const values: TArray<T>): T;
begin
  result := Default(T);
  TMatcherFactory.Create<T>(ParamIndex,
    function(param : T) : boolean
    var
      comparer : IEqualityComparer<T>;
      value : T;
    begin
      result := false;
      comparer := TEqualityComparer<T>.Default;
      for value in values do
      begin
        result := comparer.Equals(param,value);
        if result then
          exit;
      end;
    end);
end;

function ItRec.IsIn<T>(const values: IEnumerable<T>): T;
begin
  result := Default(T);
  TMatcherFactory.Create<T>(ParamIndex,
    function(param : T) : boolean
    var
      comparer : IEqualityComparer<T>;
      value : T;
    begin
      result := false;
      comparer := TEqualityComparer<T>.Default;
      for value in values do
      begin
        result := comparer.Equals(param,value);
        if result then
          exit;
      end;
    end);
end;

function ItRec.IsInRange<T>(const fromValue, toValue: T): T;
begin
  result := Default(T);
end;

function ItRec.IsNotIn<T>(const values: TArray<T>): T;
begin
  result := Default(T);
  TMatcherFactory.Create<T>(ParamIndex,
    function(param : T) : boolean
    var
      comparer : IEqualityComparer<T>;
      value : T;
    begin
      result := true;
      comparer := TEqualityComparer<T>.Default;
      for value in values do
      begin
        if comparer.Equals(param,value) then
          exit(false);
      end;
    end);

end;

function ItRec.IsNotIn<T>(const values: IEnumerable<T>): T;
begin
  result := Default(T);
  TMatcherFactory.Create<T>(ParamIndex,
    function(param : T) : boolean
    var
      comparer : IEqualityComparer<T>;
      value : T;
    begin
      result := true;
      comparer := TEqualityComparer<T>.Default;
      for value in values do
      begin
        if comparer.Equals(param,value) then
          exit(false);
      end;
    end);
end;

function ItRec.IsNotNil<T>: T;
begin
  result := Default(T);
  TMatcherFactory.Create<T>(ParamIndex,
    function(param : T) : boolean
    var
      comparer : IEqualityComparer<T>;
    begin
      comparer := TEqualityComparer<T>.Default;
      result := not comparer.Equals(param,Default(T));
    end);

end;

function ItRec.Matches<T>(const predicate: TPredicate<T>): T;
begin
  result := Default(T);
  TMatcherFactory.Create<T>(ParamIndex, predicate);
end;

//class function It.ParamIndex: integer;
//begin
//  result := 0;
//end;

{$IFDEF SUPPORTS_REGEX} //XE2 or later
function ItRec.IsRegex(const regex : string; const options : TRegExOptions) : string;
begin
  result := '';
  TMatcherFactory.Create<string>(ParamIndex,
    function(param : string) : boolean
    begin
      result := TRegEx.IsMatch(param,regex,options)
    end);
end;
{$ENDIF}

function It(const AParamIndx : Integer) : ItRec;
begin
  result := ItRec.Create(AParamIndx);
end;

function It0 : ItRec;
begin
  result := ItRec.Create(0);
end;

function It1 : ItRec;
begin
  result := ItRec.Create(1);
end;

function It2 : ItRec;
begin
  result := ItRec.Create(2);
end;

function It3 : ItRec;
begin
  result := ItRec.Create(3);
end;

function It4 : ItRec;
begin
  result := ItRec.Create(4);
end;

function It5 : ItRec;
begin
  result := ItRec.Create(5);
end;

function It6 : ItRec;
begin
  result := ItRec.Create(6);
end;

function It7 : ItRec;
begin
  result := ItRec.Create(7);
end;

function It8 : ItRec;
begin
  result := ItRec.Create(8);
end;

function It9 : ItRec;
begin
  result := ItRec.Create(9);
end;

{ TComparer }

class function TComparer.CompareFields<T>(Param1, Param2: T): Boolean;
var
  RTTI: TRttiContext;

begin
  RTTI := TRttiContext.Create;
  Result := CompareMembers<TRttiField, T>(RTTI.GetType(TypeInfo(T)).GetFields, Param1, Param2);
end;

class function TComparer.CompareMembers<T, T2>(Members: TArray<T>; Param1, Param2: T2): Boolean;
var
  PublicMember: TRttiMember;

  Instance1, Instance2, MemberValue1, MemberValue2: TValue;

  MemberType: TTypeKind;

begin
  Instance1 := TValue.From<T2>(Param1);
  Instance2 := TValue.From<T2>(Param2);
  Result := SameValue(Instance1, Instance2);

  if not Result and not Instance1.IsEmpty and not Instance2.IsEmpty then
  begin
    Result := True;

    for PublicMember in Members do
      if PublicMember.Visibility in [mvPublic, mvPublished] then
      begin
        if PublicMember is TRttiProperty then
        begin
          MemberValue1 := TRttiProperty(PublicMember).GetValue(Instance1.AsPointer);
          MemberValue2 := TRttiProperty(PublicMember).GetValue(Instance2.AsPointer);

          MemberType := TRttiProperty(PublicMember).PropertyType.TypeKind;
        end
        else
        begin
          MemberValue1 := TRttiField(PublicMember).GetValue(Instance1.AsPointer);
          MemberValue2 := TRttiField(PublicMember).GetValue(Instance2.AsPointer);

          MemberType := TRttiField(PublicMember).FieldType.TypeKind;
        end;

        if MemberType = tkClass then
          Result := Result and CompareMembers<TRttiField, TObject>(MemberValue1.RttiType.GetFields, MemberValue1.AsObject, MemberValue2.AsObject)
            and CompareMembers<TRttiProperty, TObject>(MemberValue1.RttiType.GetProperties, MemberValue1.AsObject, MemberValue2.AsObject)
        else
          Result := Result and SameValue(MemberValue1, MemberValue2);
      end;
  end;
end;

class function TComparer.CompareProperties<T>(Param1, Param2: T): Boolean;
var
  RTTI: TRttiContext;

begin
  RTTI := TRttiContext.Create;
  Result := CompareMembers<TRttiProperty, T>(RTTI.GetType(TypeInfo(T)).GetProperties, Param1, Param2);
end;

end.

