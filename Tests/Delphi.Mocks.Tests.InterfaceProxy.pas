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
  TestFramework;

type
  {$M+}
  ISimpleInterface = Interface
    ['{F1731F12-2453-4818-A785-997AF7A3D51F}']
    procedure Execute1;
  End;

  {$M+}
  ISecondSimpleInterface = Interface
    ['{C7191239-2E89-4D3A-9D1B-F894BACBBB39}']
    procedure Execute2;
  End;

  {$M+}
  IOneMethodInterface = interface
    ['{E3BE68FA-E318-49CA-B93F-DAB02C07B3A3}']
    procedure Execute3;
  end;

  {$M+}
  ICommand = interface
    procedure Execute;
    procedure TestVarParam(var msg : string);
    procedure TestOutParam(out msg : string);
  end;
  {$M-}

  TTestInterfaceProxy = class(TTestCase)
  published
    procedure Does_A_Proxy_Implement_Two_Interfaces_After_An_Implements;
    procedure Does_Implement_Then_Setup_Of_Interface_Return_Setup_Of_Interface;
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

implementation

uses
  SysUtils,
  Delphi.Mocks,
  Delphi.Mocks.Proxy,
  System.Rtti;

{ TTestInterfaceProxy }

procedure TTestInterfaceProxy.Does_A_Proxy_Implement_Two_Interfaces_After_An_Implements;
var
  simpleInterface: IProxy<ISimpleInterface>;
  secondInterface: ISecondSimpleInterface;
begin
  simpleInterface := TProxy<ISimpleInterface>.Create;
  try
    simpleInterface.AddImplements(TProxy<ISecondSimpleInterface>.Create, TypeInfo(ISecondSimpleInterface));

    simpleInterface.QueryInterface(ISecondSimpleInterface, secondInterface);

    CheckNotNull(secondInterface, 'The second interface is not implemented!');
  finally
    simpleInterface := nil;
  end;
end;

procedure TTestInterfaceProxy.Does_Implement_Then_Setup_Of_Interface_Return_Setup_Of_Interface;
var
  command : IOneMethodInterface;
  proxy : IProxy<ISimpleInterface>;

  bSupports : boolean;
  something : IInterface;
begin
  proxy := TProxy<ISimpleInterface>.Create;

  proxy.AddImplements(TProxy<IOneMethodInterface>.Create, TypeInfo(IOneMethodInterface));

  something := proxy.SetupFromTypeInfo(TypeInfo(IOneMethodInterface));

  bSupports := Supports(something, IOneMethodInterface, command);

  Check(bSupports);
  Check(command <> nil);
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
end;

procedure TTestInterfaceProxy.MockNoArgProcedureUsingNeverWhen;
var
  mock : TMock<ICommand>;
begin
  mock := TMock<ICommand>.Create;
  mock.Setup.Expect.Never.When.Execute;

  mock.Verify;
end;

procedure TTestInterfaceProxy.MockNoArgProcedureUsingOnce;
var
  mock : TMock<ICommand>;
begin
  mock := TMock<ICommand>.Create;
  mock.Setup.Expect.Once('Execute');
  mock.Instance.Execute;
  mock.Verify;
end;

procedure TTestInterfaceProxy.MockNoArgProcedureUsingOnceWhen;
var
  mock : TMock<ICommand>;
begin
  mock := TMock<ICommand>.Create;
  mock.Setup.Expect.Once.When.Execute;
  mock.Instance.Execute;
  mock.Verify;
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
      CheckEquals(2, Length(Args), 'Args Length');
      //Argument Zero is Self Instance
      args[1] := RETURN_MSG;
    end
    ).When.TestOutParam(msg);

  msg := EmptyStr;
  mock.Instance.TestOutParam(msg);

  CheckEquals(RETURN_MSG, msg);

  mock.Verify;
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
      CheckEquals(2, Length(Args), 'Args Length');
      //Argument Zero is Self Instance
      args[1] := RETURN_MSG;
    end
    ).When.TestVarParam(msg);

  msg := EmptyStr;
  mock.Instance.TestVarParam(msg);

  CheckEquals(RETURN_MSG, msg);

  mock.Verify;
end;

initialization
  TestFramework.RegisterTest(TTestInterfaceProxy.Suite);
end.
