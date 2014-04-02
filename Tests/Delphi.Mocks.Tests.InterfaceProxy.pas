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
  End;

  ISecondSimpleInterface = Interface
  ['{C7191239-2E89-4D3A-9D1B-F894BACBBB39}']
  End;

  ICommand = interface
    procedure Execute;
  end;
  {$M-}

  TTestInterfaceProxy = class(TTestCase)
  published
    procedure Does_A_Proxy_Implement_Two_Interfaces_After_A_Cast;
    procedure After_Destruction_Are_All_The_Interfaces_Cleaned_Up;
    procedure MockNoArgProcedureUsingOnce;
    procedure MockNoArgProcedureUsingOnceWhen;
    procedure MockNoArgProcedureUsingNeverWhen;
    procedure MockNoArgProcedureUsingAtLeastOnceWhen;
    procedure MockNoArgProcedureUsingAtLeastWhen;
    procedure MockNoArgProcedureUsingAtMostBetweenWhen;
    procedure MockNoArgProcedureUsingExactlyWhen;
  end;

//TODO: IProxy<T> will not allow a function of CastAs<I> on it, class does however.

implementation

uses
  SysUtils,
  Delphi.Mocks,
  Delphi.Mocks.InterfaceProxy;

{ TTestInterfaceProxy }

procedure TTestInterfaceProxy.After_Destruction_Are_All_The_Interfaces_Cleaned_Up;
var
  simpleInterface: TInterfaceProxy<ISimpleInterface>;
  secondInterface: ISecondSimpleInterface;
begin
  simpleInterface := TInterfaceProxy<ISimpleInterface>.Create;

  secondInterface := simpleInterface.CastAs<ISecondSimpleInterface>;

  CheckNotNull(secondInterface, 'The second interface is not implemented!');
end;

procedure TTestInterfaceProxy.Does_A_Proxy_Implement_Two_Interfaces_After_A_Cast;
var
  simpleInterface: TInterfaceProxy<ISimpleInterface>;
  secondInterface : ISecondSimpleInterface;
begin
  simpleInterface := TInterfaceProxy<ISimpleInterface>.Create;
  try
    secondInterface := simpleInterface.CastAs<ISecondSimpleInterface>;
    CheckNotNull(secondInterface, 'The second interface is not implemented!');
  finally
    FreeAndNil(simpleInterface);
  end;
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

initialization
  TestFramework.RegisterTest(TTestInterfaceProxy.Suite);
end.
