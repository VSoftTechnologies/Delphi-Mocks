unit Delphi.Mocks.Tests.Base;

interface

uses
  Rtti,
  SysUtils,
  DUnitX.TestFramework,
  Delphi.Mocks;

type
  //With RTTI--
  {$M+}
  IInterfaceOne = interface
    ['{CB03941B-5A46-440A-BBBE-99C5C206C4F6}']
    procedure Method;
  end;

  IInterfaceTwo = interface
    ['{7AB79C05-302A-4627-B680-159F04FDB3EC}']
    procedure MethodTwo;
  end;

  ISimpleTestInterface_WithRTTI = interface
    ['{42D4CEDF-5982-4427-9F1F-D58E1F82FB82}']
    procedure Dud;
  end;

  ISecondTestInterface = interface
    ['{2C2D10F4-0FE3-4B48-9834-276C654DF161}']
    procedure One;
    procedure Two;
  end;

  IBlankTestInterface_WithRTTI = interface
    ['{C8726C8B-D695-4F19-823C-CE1FFBE59BED}']
  end;

  //Objects
  TSimpleTestObject_WithRTTI = class(TObject)
  public
    procedure Dud;
  end;

  TBlankTestObject_WithRTTI = class(TObject)
  end;
  {$M-}
  //--With RTTI


  //Without RTTI--
  ISimpleTestInterface_WithoutRTTI = interface
    ['{10405ECB-0AB1-4DBB-B673-7056683A4284}']
  end;

 {$M-}
  TSimpleTestObject_WithoutRTTI = class(TObject)
  public
    procedure blah;
  end;

  TSimpleRecord_WithoutRTTI = record
  end;
  //--Without RTTI


  TTestMock = class
  published
    procedure CreateMock_With_Object_Which_Has_No_RTTI_Raises_No_Exception;
    procedure CreateMock_With_Object_Which_Has_RTTI_But_No_Exposed_Functions_Raises_Exception;

    procedure CreateMock_With_Interface_Which_Has_No_RTTI_Raises_Exception;
    procedure CreateMock_With_Interface_Which_Has_RTTI_Raises_No_Exception;
    procedure CreateMock_With_Interface_Which_Has_RTTI_But_No_Exposed_Functions_Raises_Exception;
    procedure CreateMock_With_Interface_We_Get_Valid_Proxy;

    procedure CreateMock_With_Record_Structure_Raises_Exception;

    procedure After_Implement_MockSetupT_Returns_ISetup_Of_The_Implemented_Type;
    procedure After_AddImplement_ProxyFromType_Returns_Proxy_Which_Implements_Passed_Interface;
    procedure After_AddImplement_And_ExpectT_For_New_Type_VerifyT_Succeeds;
    procedure After_AddImplement_And_Expects_Both_Interfaces_VerifyAll_Succeeds;


    procedure Proxy_Should_Not_Support_IProxy;

    procedure When_Proxy_With_Implemented_Interface_Returns_That_Interface;
    procedure When_Proxy_With_Implemented_Interface_Returns_IProxy_From_Instance_For_Implemented_Interface;
    procedure When_Proxy_With_Implmeneted_Interface_Returns_IExpect_Of_Interface_From_Instance_For_Implemented_Interface;
  end;

implementation

uses
  TypInfo,
  Delphi.Mocks.Helpers,
  Delphi.Mocks.Interfaces,
  Delphi.Mocks.Proxy,
  classes;

{ TTestMock }

procedure TTestMock.CreateMock_With_Object_Which_Has_No_RTTI_Raises_No_Exception;
var
  mock : TMock<TSimpleTestObject_WithOutRTTI>;
  exceptionRaised : Boolean;
  exceptionMsg: widestring;
begin
  exceptionRaised := False;
  exceptionMsg := '';
  try
    mock := TMock<TSimpleTestObject_WithOutRTTI>.Create;
  except
    on E: Exception do
    begin
       exceptionRaised := True;
       exceptionMsg := E.Message;
    end;
  end;

  Assert.IsFalse(exceptionRaised, exceptionMsg);
end;

procedure TTestMock.CreateMock_With_Interface_We_Get_Valid_Proxy;
var
  mock : TMock<ISimpleTestInterface_WithRTTI>;
begin
  mock := TMock<ISimpleTestInterface_WithRTTI>.Create;

  Assert.IsNotNull(mock.Instance);
end;

procedure TTestMock.CreateMock_With_Interface_Which_Has_No_RTTI_Raises_Exception;
var
  mock : TMock<ISimpleTestInterface_WithoutRTTI>;
begin
  Assert.WillRaise(procedure
  begin
    mock := TMock<ISimpleTestInterface_WithoutRTTI>.Create;
  end, EMockNoRTTIException);
end;

procedure TTestMock.CreateMock_With_Interface_Which_Has_RTTI_But_No_Exposed_Functions_Raises_Exception;
var
  mock : TMock<IBlankTestInterface_WithRTTI>;
begin
  Assert.WillRaise(procedure
  begin
    mock := TMock<IBlankTestInterface_WithRTTI>.Create;
  end, EMockNoRTTIException);
end;

procedure TTestMock.CreateMock_With_Interface_Which_Has_RTTI_Raises_No_Exception;
var
  mock : TMock<ISimpleTestInterface_WithRTTI>;
  exceptionRaised : Boolean;
  exceptionMsg: widestring;
begin
  exceptionRaised := False;
  exceptionMsg := '';

  try
    mock := TMock<ISimpleTestInterface_WithRTTI>.Create;
  except
    on E: Exception do
    begin
       exceptionRaised := True;
       exceptionMsg := E.Message;
    end;
  end;

  Assert.IsFalse(exceptionRaised, exceptionMsg);
end;

procedure TTestMock.CreateMock_With_Object_Which_Has_RTTI_But_No_Exposed_Functions_Raises_Exception;
var
  mock : TMock<TBlankTestObject_WithRTTI>;
begin
  Assert.WillRaise(procedure
  begin
    mock := TMock<TBlankTestObject_WithRTTI>.Create;
  end, EMockNoRTTIException);
end;

procedure TTestMock.CreateMock_With_Record_Structure_Raises_Exception;
var
  mock : TMock<TSimpleRecord_WithoutRTTI>;
begin
  Assert.WillRaise(procedure
  begin
    mock := TMock<TSimpleRecord_WithoutRTTI>.Create;
  end, EMockException);
end;

procedure TTestMock.After_AddImplement_And_Expects_Both_Interfaces_VerifyAll_Succeeds;
var
  mock : TMock<IInterfaceOne>;
begin
  mock := TMock<IInterfaceOne>.Create;

  //SETUP - Added the implemenation of IInterfaceTwo and an expects for methodTwo to be calleds
  mock.Implement<IInterfaceTwo>;
  mock.Setup.Expect.Once.When.Method;
  mock.Setup<IInterfaceTwo>.Expect.Once.When.MethodTwo;

  //SETUP - Get the interface two instance
  mock.Instance.Method;
  mock.Instance<IInterfaceTwo>.MethodTwo;

  mock.VerifyAll('Mock should have expectations for both Interfaces.');
end;

procedure TTestMock.After_AddImplement_And_ExpectT_For_New_Type_VerifyT_Succeeds;
var
  mock : TMock<IInterfaceOne>;
  interfaceTwo : IInterfaceTwo;
begin
  mock := TMock<IInterfaceOne>.Create;

  //SETUP - Added the implemenation of IInterfaceTwo and an expects for methodTwo to be calleds
  mock.Implement<IInterfaceTwo>;
  mock.Setup<IInterfaceTwo>.Expect.Once.When.MethodTwo;

  //SETUP - Get the interface two instance
  interfaceTwo := mock.Instance<IInterfaceTwo>;
  interfaceTwo.MethodTwo;

  mock.Verify<IInterfaceTwo>('Mock Expect<IInterfaceTwo> should add expectations for verify to check.');
end;

procedure TTestMock.After_AddImplement_ProxyFromType_Returns_Proxy_Which_Implements_Passed_Interface;
var
  simpleProxy : IProxy<IInterfaceOne>;
  prox : IProxy;
  secondProxy : IProxy<IInterfaceTwo>;
  pInfo : PTypeInfo;
begin
  simpleProxy := TProxy<IInterfaceOne>.Create;
  secondProxy := TProxy<IInterfaceTwo>.Create;

  pInfo := TypeInfo(IInterfaceTwo);

  simpleProxy.AddImplement(secondProxy, pInfo);

  prox := simpleProxy.ProxyFromType(pInfo);

  //The proxy should implement all the interfaces its defined with. Can't test
  //for IProxy<IInterfaceTwo> as this has the same GUID as IProxy<IInterfaceOne>
  //Therefore test that the instance of the proxy implements IInterfaceTwo.
  Assert.IsTrue(Supports(prox.ProxyInterface, IInterfaceTwo));
end;

procedure TTestMock.After_Implement_MockSetupT_Returns_ISetup_Of_The_Implemented_Type;
var
  mock : TMock<ISimpleTestInterface_WithRTTI>;
  mockSetup : IMockSetup<ISecondTestInterface>;
  proxy : IProxy<ISecondTestInterface>;
begin
  mock := TMock<ISimpleTestInterface_WithRTTI>.Create;

  mock.Implement<ISecondTestInterface>;

  mockSetup := mock.Setup<ISecondTestInterface>;

  //Checking that the mocksetup supports IProxy<ISecondInterface> does nothing much.
  //It simply will return the first IProxy<T> that it finds from QueryInterface. Therefore
  //we need to double check that the actual proxy can return a ISecondTestInterface
  //to make sure that the correct proxy has been returned for mocksetup.
  Assert.IsTrue(Supports(mockSetup, IProxy<ISecondTestInterface>, proxy));
  Assert.IsTrue(Supports(proxy.Proxy, ISecondTestInterface));
end;

procedure TTestMock.Proxy_Should_Not_Support_IProxy;
var
  proxyOne : IProxy<IInterfaceOne>;
  outProxyTwo : IProxy;
begin
  proxyOne := TProxy<IInterfaceOne>.Create;

  Assert.IsFalse(Supports(proxyOne.Proxy, IProxy, outProxyTwo), 'IProxy<T>.Proxy should support IProxy');
end;

procedure TTestMock.When_Proxy_With_Implemented_Interface_Returns_IProxy_From_Instance_For_Implemented_Interface;
var
  proxyOne : IProxy<IInterfaceOne>;
  proxyTwo : IProxy<IInterfaceTwo>;
  outProxyTwo : IProxy<IInterfaceTwo>;
  bSupports: Boolean;
begin
  proxyOne := TProxy<IInterfaceOne>.Create;
  proxyTwo := TProxy<IInterfaceTwo>.Create;

  proxyOne.AddImplement(proxyTwo, TypeInfo(IInterfaceTwo));

  bSupports := Supports(proxyOne.ProxyFromType(TypeInfo(IInterfaceTwo)), IProxy<IInterfaceTwo>, outProxyTwo);

  Assert.IsTrue(bSupports, 'IProxy<T>.Proxy should support IProxy<I> after AddImplements called');
  Assert.IsTrue((proxyTwo as IProxy<IInterfaceTwo>) = outProxyTwo, 'IProxy<T>.Proxy should return the same IProxy<I> as was added through AddImplements');
end;

procedure TTestMock.When_Proxy_With_Implemented_Interface_Returns_That_Interface;
var
  proxyOne : IProxy<IInterfaceOne>;
  proxyTwo : IProxy<IInterfaceTwo>;
  outProxyTwo : IInterfaceTwo;
begin
  proxyOne := TProxy<IInterfaceOne>.Create;
  proxyTwo := TProxy<IInterfaceTwo>.Create;

  proxyOne.AddImplement(proxyTwo, TypeInfo(IInterfaceTwo));

  Assert.IsTrue(Supports(proxyOne.Proxy, IInterfaceTwo, outProxyTwo));
  Assert.IsTrue(proxyTwo.Proxy = outProxyTwo);
end;

procedure TTestMock.When_Proxy_With_Implmeneted_Interface_Returns_IExpect_Of_Interface_From_Instance_For_Implemented_Interface;
var
  proxyOne : IProxy<IInterfaceOne>;
  proxyTwo : IProxy<IInterfaceTwo>;
  outProxyTwo : IExpect<IInterfaceTwo>;
  bSupports: Boolean;
begin
  proxyOne := TProxy<IInterfaceOne>.Create;
  proxyTwo := TProxy<IInterfaceTwo>.Create;

  proxyOne.AddImplement(proxyTwo, TypeInfo(IInterfaceTwo));

  bSupports := Supports(proxyOne.ProxyFromType(TypeInfo(IInterfaceTwo)), IExpect<IInterfaceTwo>, outProxyTwo);

  Assert.IsTrue(bSupports, 'IProxy<T>.Proxy should support IExpect<I> after AddImplements called');
  Assert.IsTrue((proxyTwo as IExpect<IInterfaceTwo>) = outProxyTwo, 'IProxy<T>.Proxy should return the same IExpect<I> as was added through AddImplements');
end;

{ TSimpleTestObject_WithRTTI }

procedure TSimpleTestObject_WithRTTI.Dud;
begin
  //Does nothing. Required to test condition of having methods.
  Exit;
end;

{ TSimpleTestObject_WithoutRTTI }

procedure TSimpleTestObject_WithoutRTTI.blah;
begin
end;

initialization
  TDUnitX.RegisterTestFixture(TTestMock);

end.
