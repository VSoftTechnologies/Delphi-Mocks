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

uses
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



  //We use the Setup to configure our expected behaviour rules and to verify
  //that those expectations were met.
  ISetup<T> = interface
  ['{D6B21933-BF51-4937-877E-51B59A3B3268}']
    function GetBehaviorMustBeDefined : boolean;
    procedure SetBehaviorMustBeDefined(const value : boolean);

    //Set Expectations for methods
    function Expect : IExpect<T>;

//    //set a required order for methods, e.g A must have been called before B
//    function Before(const AMethodName : string) : ISetup<T>;
//
//    //set a required order for methods, e.g A must have been called After B
//    function After(const AMethodName : string) : ISetup<T>;

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
    function WillRaise(const exceptionClass : ExceptClass) : IWhen<T>;overload;

    //This method will always raise an exception.. this behavior will trump any other defined behaviors
    procedure WillRaise(const AMethodName : string; const exceptionClass : ExceptClass);overload;

    //If true, calls to methods for which we have not defined a behavior will cause verify to fail.
    property BehaviorMustBeDefined : boolean read GetBehaviorMustBeDefined write SetBehaviorMustBeDefined;
  end;


  //used by the mock - need to find another place to put this.. circular references
  //problem means we need it here for now.

  IProxy<T> = interface
  ['{1E3A98C5-78BA-4D65-A4BA-B6992B8B4783}']
    function Setup : ISetup<T>;
    function Proxy : T;
  end;


  //We use a record here to take advantage of operator overloading, the Implicit
  //operator allows us to use the mock as the interface without holding a reference
  //to the mock interface outside of the mock.
  TInterfaceMock<T> = record
  private
    FProxy : IProxy<T>;
  public
    class operator Implicit(const Value: TInterfaceMock<T>): T;
    function Setup : ISetup<T>;
    //Verify that our expectations were met.
    procedure Verify(const message : string = '');
    function Instance : T;
    class function Create: TInterfaceMock<T>; static;
    // explicit cleanup. Not sure if we really need this.
    procedure Free;
  end;

  //NOT ACTUALLY IMPLEMENTED YET
  TObjectMock<T : class> = record
  private
    FObject : T;
  public
    class operator Implicit(const Value: TObjectMock<T>): T;
    function Setup : ISetup<T>;
    //Verify that our expectations were met.
    procedure Verify(const message : string = '');
    function Instance : T;
    class function Create: TObjectMock<T>; static;
    // explicit cleanup.
    procedure Free;
  end;


  //Exception Types that the mocks will raise.
  EMockException = class(Exception);
  EMockSetupException = class(EMockException);
  EMockNoRTTIException = class(EMockException);
  EMockNoProxyException = class(EMockException);
  EMockVerificationException = class(EMockException);


implementation


uses
  TypInfo,
  Classes,
  Generics.Defaults,
  Delphi.Mocks.Utils,
  Delphi.Mocks.Interfaces,
  Delphi.Mocks.InterfaceProxy;


class function TInterfaceMock<T>.Create: TInterfaceMock<T>;
var
  proxy : IInterface;
  pInfo : PTypeInfo;
begin
  pInfo := TypeInfo(T);
  //Generics cannot have interface constraints so we have to resort to runtime checking.
  if pInfo.Kind <> tkInterface then
    raise EMockException.Create(string(pInfo.Name) + ' is not an Interface. TInterfaceMock<T> supports interfaces only');

  //Check to make sure we have
  if not CheckInterfaceHasRTTI(pInfo) then
    raise EMockNoRTTIException.Create(string(pInfo.Name) + ' does not have RTTI, specify {$M+} for the interface to enabled RTTI');

  //Create Our proxy object, which will implement our interface T
  proxy := TProxyBase<T>.Create;

  //Note we don't worry if there being no guid on the interface, we know that our proxy implements T
  //and it will treat an empty GUID as T;
  if proxy.QueryInterface(GetTypeData(TypeInfo(IProxy<T>)).Guid,result.FProxy) <> 0 then
    raise EMockNoProxyException.Create('Error casting to interface ' + string(pInfo.Name) + ' , proxy does not appear to implememnt T');

end;

procedure TInterfaceMock<T>.Free;
begin
  FProxy := nil;
end;

class operator TInterfaceMock<T>.Implicit(const Value: TInterfaceMock<T>): T;
begin
  result := Value.FProxy.Proxy;
end;

function TInterfaceMock<T>.Instance : T;
begin
  result := FProxy.Proxy;
end;

function TInterfaceMock<T>.Setup: ISetup<T>;
begin
  result := FProxy.Setup;
end;

procedure TInterfaceMock<T>.Verify(const message: string);
var
  su : ISetup<T>;
  v : IVerify;
begin
  if Supports(FProxy.Setup,IVerify,v) then
    v.Verify(message)
  else
    raise EMockException.Create('Could not cast Setup to IVerify interface!');
end;

{ TObjectMock<T> }

class function TObjectMock<T>.Create: TObjectMock<T>;
var
  pInfo : PTypeInfo;
begin
  pInfo := TypeInfo(T);
  //Generics cannot have interface constraints so we have to resort to runtime checking.
  if pInfo.Kind <> tkClass then
    raise EMockException.Create(string(pInfo.Name) + ' is not an Object. TObjectMock<T> supports objects only');

  result.FObject := Default(T);//just to stop the compiler hint for now.

  raise Exception.Create('Not implemented');
end;

procedure TObjectMock<T>.Free;
begin
  raise Exception.Create('Not implemented');
end;

class operator TObjectMock<T>.Implicit(const Value: TObjectMock<T>): T;
begin
  raise Exception.Create('Not implemented');
end;

function TObjectMock<T>.Instance: T;
begin
  raise Exception.Create('Not implemented');
end;

function TObjectMock<T>.Setup: ISetup<T>;
begin
  raise Exception.Create('Not implemented');
end;

procedure TObjectMock<T>.Verify(const message: string);
begin
  raise Exception.Create('Not implemented');
end;

end.
