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
  sysutils;

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
    //set the return value for a method when called with the parameters specified on the When
    function WillReturn(const value : TValue) : IWhen<T>;

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

    //If true, calls to methods for which we have not defined a behavior will cause verify to fail.
    property BehaviorMustBeDefined : boolean read GetBehaviorMustBeDefined write SetBehaviorMustBeDefined;

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

  //used by the mock - need to find another place to put this.. circular references
  //problem means we need it here for now.
  IProxy<T> = interface
  ['{1E3A98C5-78BA-4D65-A4BA-B6992B8B4783}']
    function Setup : IMockSetup<T>;
    function Proxy : T;
  end;


  TStub<T> = record
  private
    FProxy : IStubProxy<T>;
  public
    class operator Implicit(const Value: TStub<T>): T;
    function Setup : IStubSetup<T>;
    function Instance : T;
    function InstanceAsValue : TValue;
    class function Create: TStub<T>; static;
    // explicit cleanup. Not sure if we really need this.
    procedure Free;
  end;



  //We use a record here to take advantage of operator overloading, the Implicit
  //operator allows us to use the mock as the interface without holding a reference
  //to the mock interface outside of the mock.
  TMock<T> = record
  private
    FProxy : IProxy<T>;
  public
    class operator Implicit(const Value: TMock<T>): T;
    function Setup : IMockSetup<T>;
    //Verify that our expectations were met.
    procedure Verify(const message : string = '');
    function CheckExpectations: string;
    function Instance : T;
    function InstanceAsValue : TValue;
    class function Create: TMock<T>; static;
    // explicit cleanup. Not sure if we really need this.
    procedure Free;
  end;

  //Exception Types that the mocks will raise.
  EMockException = class(Exception);
  EMockSetupException = class(EMockException);
  EMockNoRTTIException = class(EMockException);
  EMockNoProxyException = class(EMockException);
  EMockVerificationException = class(EMockException);

  TTypeInfoHelper = record helper for TTypeInfo
    function NameStr : string; inline;
  end;

implementation

uses
  Classes,
  Generics.Defaults,
  Delphi.Mocks.Utils,
  Delphi.Mocks.Interfaces,
  Delphi.Mocks.InterfaceProxy,
  Delphi.Mocks.ObjectProxy;

function TMock<T>.CheckExpectations: string;
var
  su : IMockSetup<T>;
  v : IVerify;
begin
  if Supports(FProxy.Setup,IVerify,v) then
    Result := v.CheckExpectations
  else
    raise EMockException.Create('Could not cast Setup to IVerify interface!');
end;

class function TMock<T>.Create: TMock<T>;
var
  proxy : IInterface;
  pInfo : PTypeInfo;
begin
  //Make sure that we start off with a clean mock
  FillChar(Result, SizeOf(Result), 0);

  pInfo := TypeInfo(T);

  if not (pInfo.Kind in [tkInterface,tkClass]) then
    raise EMockException.Create(pInfo.NameStr + ' is not an Interface or Class. TMock<T> supports interfaces and classes only');

  case pInfo.Kind of
    //NOTE: We have a weaker requirement for an object proxy opposed to an interface proxy.
    //NOTE: Object proxy doesn't require more than zero methods on the object.
    tkClass :
    begin
      //Check to make sure we have
      if not CheckClassHasRTTI(pInfo) then
          raise EMockNoRTTIException.Create(pInfo.NameStr + ' does not have RTTI, specify {$M+} for the object to enabled RTTI');

      //Create our proxy object, which will implement our object T
      proxy := TObjectProxy<T>.Create(false);
    end;
    tkInterface :
    begin
      //Check to make sure we have
      if not CheckInterfaceHasRTTI(pInfo) then
        raise EMockNoRTTIException.Create(pInfo.NameStr + ' does not have RTTI, specify {$M+} for the interface to enabled RTTI');

      //Create our proxy interface object, which will implement our interface T
      proxy := TInterfaceProxy<T>.Create(false);
    end;
  else
    raise EMockException.Create('Invalid type kind T');
  end;

  //Push the proxy into the result we are returning.
  if proxy.QueryInterface(GetTypeData(TypeInfo(IProxy<T>)).Guid, Result.FProxy) <> 0 then
    //TODO: This raise seems superfluous as the only types which are created are controlled by us above. They all implement IProxy<T>
    raise EMockNoProxyException.Create('Error casting to interface ' + pInfo.NameStr + ' , proxy does not appear to implememnt IProxy<T>');
end;

procedure TMock<T>.Free;
begin
  FProxy := nil;
end;

class operator TMock<T>.Implicit(const Value: TMock<T>): T;
begin
  result := Value.FProxy.Proxy;
end;

function TMock<T>.Instance : T;
begin
  result := FProxy.Proxy;
end;

function TMock<T>.InstanceAsValue: TValue;
begin
  result := TValue.From<T>(Self);
end;

function TMock<T>.Setup: IMockSetup<T>;
begin
  result := FProxy.Setup;
end;

procedure TMock<T>.Verify(const message: string);
var
  su : IMockSetup<T>;
  v : IVerify;
begin
  if Supports(FProxy.Setup,IVerify,v) then
    v.Verify(message)
  else
    raise EMockException.Create('Could not cast Setup to IVerify interface!');
end;

{ TStub<T> }

class function TStub<T>.Create: TStub<T>;
var
  proxy : IInterface;
  pInfo : PTypeInfo;
begin
  //Make sure that we start off with a clean mock
  FillChar(Result, SizeOf(Result), 0);

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
      proxy := TObjectProxy<T>.Create(true);
    end;
    tkInterface :
    begin
      //Check to make sure we have
      if not CheckInterfaceHasRTTI(pInfo) then
        raise EMockNoRTTIException.Create(pInfo.NameStr + ' does not have RTTI, specify {$M+} for the interface to enabled RTTI');

      //Create our proxy interface object, which will implement our interface T
      proxy := TInterfaceProxy<T>.Create(true);
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

end.
