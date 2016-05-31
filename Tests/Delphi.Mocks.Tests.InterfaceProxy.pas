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

unit Delphi.Mocks.Tests.InterfaceProxy;

interface

uses
  DUnitX.TestFramework;

type
  {$M+}
  IInterfaceOne = Interface
    ['{F1731F12-2453-4818-A785-997AF7A3D51F}']
    procedure Execute1;
  End;

  {$M+}
  IInterfaceTwo = Interface
    ['{C7191239-2E89-4D3A-9D1B-F894BACBBB39}']
    procedure Execute2;
  End;

  {$M+}
  IInterfaceThree = interface
    ['{E3BE68FA-E318-49CA-B93F-DAB02C07B3A3}']
    procedure Execute3;
  end;

  {$M+}
  ICommand = interface
    ['{9742A11D-69A4-422E-A2F3-CCEC4934DFC0}']
    procedure Execute;
    procedure TestVarParam(var msg : string);
    procedure TestOutParam(out msg : string);
  end;
  {$M-}

  {$M+}
  [TestFixture]
  TTestInterfaceProxy = class
  published
    procedure After_Proxy_AddImplement_ProxyProxy_Implements_Original_Interface;
    procedure After_Proxy_AddImplement_ProxyProxy_Implements_New_Interface;
    procedure After_Proxy_AddImplement_ProxyFromType_Returns_Proxy_For_Implemented_Interface;
    procedure MockNoArgProcedureUsingOnce;
    procedure MockNoArgProcedureUsingOnceWhen;
    procedure MockNoArgProcedureUsingNeverWhen;
    procedure MockNoArgProcedureUsingAtLeastOnceWhen;
    procedure MockNoArgProcedureUsingAtLeastWhen;
    procedure MockNoArgProcedureUsingAtMostBetweenWhen;
    procedure MockNoArgProcedureUsingExactlyWhen;
    procedure TestOuParam;
    procedure TestVarParam;
  end;
  {$M-}

implementation

uses
  SysUtils,
  Delphi.Mocks,
  Delphi.Mocks.Proxy,
  System.Rtti;

{ TTestInterfaceProxy }

procedure TTestInterfaceProxy.After_Proxy_AddImplement_ProxyFromType_Returns_Proxy_For_Implemented_Interface;
var
  proxySUT : IProxy<IInterfaceOne>;
  newInterface : IInterfaceTwo;
  newProxy : IProxy;
begin
  //SETUP
  proxySUT := TProxy<IInterfaceOne>.Create;

  //SETUP - Added the implementation of Interface
  proxySUT.AddImplement(TProxy<IInterfaceTwo>.Create, TypeInfo(IInterfaceTwo));

  newProxy := proxySUT.ProxyFromType(TypeInfo(IInterfaceTwo));

  //TEST - Make sure proxy value implements IInterfaceTwo
  Assert.IsTrue(Supports(newProxy.ProxyInterface, IInterfaceTwo, newInterface));
end;

procedure TTestInterfaceProxy.After_Proxy_AddImplement_ProxyProxy_Implements_New_Interface;
var
  proxySUT : IProxy<IInterfaceOne>;
  newInterface : IInterfaceTwo;
begin
  //SETUP
  proxySUT := TProxy<IInterfaceOne>.Create;

  //SETUP - Added the implementation of Interface
  proxySUT.AddImplement(TProxy<IInterfaceTwo>.Create, TypeInfo(IInterfaceTwo));

  //TEST - Make sure proxy value implements IInterfaceTwo
  Assert.IsTrue(Supports(proxySUT.Proxy, IInterfaceTwo, newInterface));
end;

procedure TTestInterfaceProxy.After_Proxy_AddImplement_ProxyProxy_Implements_Original_Interface;
var
  proxySUT : IProxy<IInterfaceOne>;
  originalInterface : IInterfaceOne;
begin
  //SETUP
  proxySUT := TProxy<IInterfaceOne>.Create;

  //SETUP - Added the implementation of Interface
  proxySUT.AddImplement(TProxy<IInterfaceTwo>.Create, TypeInfo(IInterfaceTwo));

  //TEST - Make sure proxy value implements IInterfaceOne
  Assert.IsTrue(Supports(proxySUT.Proxy, IInterfaceOne, originalInterface));
  Assert.IsNotNull(originalInterface);
  Assert.IsTrue(originalInterface = proxySUT.Proxy);
end;

procedure TTestInterfaceProxy.MockNoArgProcedureUsingAtLeastOnceWhen;
var
  mock : TMock<ICommand>;
begin
  mock := TMock<ICommand>.Create;
  mock.Setup.Expect.AtLeastOnce.When.Execute;
  mock.Instance.Execute;
  mock.Instance.Execute;
  mock.Verify;
  Assert.Pass;
end;

procedure TTestInterfaceProxy.MockNoArgProcedureUsingAtLeastWhen;
var
  mock : TMock<ICommand>;
begin
  mock := TMock<ICommand>.Create;
  mock.Setup.Expect.AtLeast(3).When.Execute;
  mock.Instance.Execute;
  mock.Instance.Execute;
  mock.Instance.Execute;
  mock.Verify;
  Assert.Pass;
end;

procedure TTestInterfaceProxy.MockNoArgProcedureUsingAtMostBetweenWhen;
var
  mock : TMock<ICommand>;
begin
  mock := TMock<ICommand>.Create;
  mock.Setup.Expect.AtMost(2).When.Execute;
  mock.Instance.Execute;
  mock.Instance.Execute;
  mock.Verify;
  Assert.Pass;
end;

procedure TTestInterfaceProxy.MockNoArgProcedureUsingExactlyWhen;
var
  mock : TMock<ICommand>;
begin
  mock := TMock<ICommand>.Create;
  mock.Setup.Expect.Exactly(2).When.Execute;
  mock.Instance.Execute;
  mock.Instance.Execute;
  mock.Verify;
  Assert.Pass;
end;

procedure TTestInterfaceProxy.MockNoArgProcedureUsingNeverWhen;
var
  mock : TMock<ICommand>;
begin
  mock := TMock<ICommand>.Create;
  mock.Setup.Expect.Never.When.Execute;

  mock.Verify;
  Assert.Pass;
end;

procedure TTestInterfaceProxy.MockNoArgProcedureUsingOnce;
var
  mock : TMock<ICommand>;
begin
  mock := TMock<ICommand>.Create;
  mock.Setup.Expect.Once('Execute');
  mock.Instance.Execute;
  mock.Verify;
  Assert.Pass;
end;

procedure TTestInterfaceProxy.MockNoArgProcedureUsingOnceWhen;
var
  mock : TMock<ICommand>;
begin
  mock := TMock<ICommand>.Create;
  mock.Setup.Expect.Once.When.Execute;
  mock.Instance.Execute;
  mock.Verify;
  Assert.Pass;
end;

procedure TTestInterfaceProxy.TestOuParam;
const
  RETURN_MSG = 'hello Delphi Mocks! - With out Param';
var
  mock : TMock<ICommand>;
  msg: string;
begin
  mock := TMock<ICommand>.Create;

  mock.Setup.WillExecute(
    function (const args : TArray<TValue>; const ReturnType : TRttiType) : TValue
    begin
      Assert.AreEqual(2, Length(Args), 'Args Length');
      //Argument Zero is Self Instance
      args[1] := RETURN_MSG;
    end
    ).When.TestOutParam(msg);

  msg := EmptyStr;
  mock.Instance.TestOutParam(msg);

  Assert.AreEqual(RETURN_MSG, msg);

  mock.Verify;
  Assert.Pass;
end;

procedure TTestInterfaceProxy.TestVarParam;
const
  RETURN_MSG = 'hello Delphi Mocks!';
var
  mock : TMock<ICommand>;
  msg: string;
begin
  mock := TMock<ICommand>.Create;

  mock.Setup.WillExecute(
    function (const args : TArray<TValue>; const ReturnType : TRttiType) : TValue
    begin
      Assert.AreEqual(2, Length(Args), 'Args Length');
      //Argument Zero is Self Instance
      args[1] := RETURN_MSG;
    end
    ).When.TestVarParam(msg);

  msg := EmptyStr;
  mock.Instance.TestVarParam(msg);

  Assert.AreEqual(RETURN_MSG, msg);

  mock.Verify;
  Assert.Pass;
end;


initialization
  TDUnitX.RegisterTestFixture(TTestInterfaceProxy);


end.
