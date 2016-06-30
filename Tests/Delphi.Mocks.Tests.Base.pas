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

  IInterfaceThree = interface
    ['{AD09ED2F-7DEF-4B5E-90BB-CD1BF1385533}']
    procedure MethodThree;
  end;

  IBaseInterface = interface(IInterface)
    ['{BB7AD100-6288-419A-B2E0-CB42E38593DA}']
    procedure Method;
  end;

  ISecondInterface = interface(IBaseInterface)
    ['{76C4FB65-C8F2-4B38-9C61-CAE16C5F9144}']
    procedure MethodTwo;
  end;

  IThirdInterface = interface(ISecondInterface)
    ['{8D925311-D764-46F9-A701-7E941BDDB58B}']
    procedure MethodThree;
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


  {$M+}
  [TestFixture]
  TTestMock = class
  published
    procedure CreateMock_With_Object_Which_Has_No_RTTI_Raises_No_Exception;
    [Test, Ignore]
    procedure CreateMock_With_Object_Which_Has_RTTI_But_No_Exposed_Functions_Raises_Exception;

    procedure CreateMock_With_Interface_Which_Has_No_RTTI_Raises_Exception;
    procedure CreateMock_With_Interface_Which_Has_RTTI_Raises_No_Exception;
    procedure CreateMock_With_Interface_Which_Has_RTTI_But_No_Exposed_Functions_Raises_Exception;
    procedure CreateMock_With_Interface_We_Get_Valid_Proxy;

    procedure CreateMock_With_Interfaces_We_Can_Query_All_Interfaces_From_Mock;
    procedure CreateMock_With_Interfaces_We_Can_Query_All_Interfaces_From_Interface;
    procedure CreateMock_With_Interfaces_We_Get_SamePointers;
    procedure CreateMock_With_Inherited_Interfaces_We_Get_SamePointers;
    [Test]
    procedure CreateMock_With_Inherited_Interfaces_We_Get_SamePointers_BaseLine;

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
  {$M-}

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

procedure TTestMock.CreateMock_With_Interfaces_We_Can_Query_All_Interfaces_From_Mock;
var
  mock : TMock<IInterfaceOne>;
  IntfOne: IInterfaceOne;
  IntfTwo: IInterfaceTwo;
  IntfThree: IInterfaceThree;
  Intf: IInterface;
begin
  mock := TMock<IInterfaceOne>.Create;
  mock.Implement<IInterfaceTwo>;
  mock.Implement<IInterfaceThree>;

  Assert.WillNotRaiseAny(procedure
  begin
    IntfOne := mock;
    IntfTwo := IntfOne as IInterfaceTwo;
    IntfThree := IntfOne as IInterfaceThree;
    Intf := IntfOne as IInterface;
  end);

  Assert.IsNotNull(IntfOne);
  Assert.IsNotNull(IntfTwo);
  Assert.IsNotNull(IntfThree);
  Assert.IsNotNull(Intf);
end;

procedure TTestMock.CreateMock_With_Interfaces_We_Can_Query_All_Interfaces_From_Interface;
var
  mock : TMock<IInterfaceOne>;
  IntfOne: IInterfaceOne;
  IntfTwo: IInterfaceTwo;
  IntfThree: IInterfaceThree;
  Intf: IInterface;
  IntfOneBack: IInterfaceOne;
begin
  mock := TMock<IInterfaceOne>.Create;
  mock.Implement<IInterfaceTwo>;
  mock.Implement<IInterfaceThree>;

  Assert.WillNotRaiseAny(procedure
  begin
    IntfOne := mock;
    IntfTwo := IntfOne as IInterfaceTwo;
    IntfThree := IntfTwo as IInterfaceThree;
    Intf := IntfThree as IInterface;
    IntfOneBack := Intf as IInterfaceOne;
  end);

  Assert.IsNotNull(IntfOne);
  Assert.IsNotNull(IntfTwo);
  Assert.IsNotNull(IntfThree);
  Assert.IsNotNull(Intf);
  Assert.IsNotNull(IntfOneBack);
  Assert.AreSame(IntfOne, IntfOneBack, 'IntfOne = IntfOneBack');
end;

procedure TTestMock.CreateMock_With_Interfaces_We_Get_SamePointers;
var
  mock : TMock<IInterfaceOne>;
  IntfOne: IInterfaceOne;
  Intf1: IInterface;
  IntfTwo: IInterfaceTwo;
  Intf2: IInterface;
  IntfThree: IInterfaceThree;
  Intf3: IInterface;
  IntfOneBack: IInterfaceOne;
begin
  mock := TMock<IInterfaceOne>.Create;
  mock.Implement<IInterfaceTwo>;
  mock.Implement<IInterfaceThree>;

  Assert.WillNotRaiseAny(procedure
  begin
    IntfOne := mock;
    Intf1 := IntfOne as IInterface;
    IntfTwo := Intf1 as IInterfaceTwo;
    Intf2 := IntfTwo as IInterface;
    IntfThree := Intf2 as IInterfaceThree;
    Intf3 := IntfThree as IInterface;
    IntfOneBack := Intf3 as IInterfaceOne;
  end);

  Assert.IsNotNull(IntfOne);
  Assert.IsNotNull(IntfTwo);
  Assert.IsNotNull(IntfThree);
  Assert.IsNotNull(Intf1);
  Assert.IsNotNull(Intf2);
  Assert.IsNotNull(Intf3);
  Assert.IsNotNull(IntfOneBack);

  Assert.AreSame(Intf1, Intf2, 'Intf1 = Intf2');
  Assert.AreSame(Intf2, Intf3, 'Intf2 = Intf3');
  Assert.AreSame(Intf3, Intf1, 'Intf3 = Intf1');
  Assert.AreSame(IntfOne, IntfOneBack, 'IntfOne = IntfOneBack');
end;

procedure TTestMock.CreateMock_With_Inherited_Interfaces_We_Get_SamePointers;
var
  mock : TMock<IThirdInterface>;
  IntfOne: IThirdInterface;
  Intf1: IInterface;
  IntfTwo: ISecondInterface;
  Intf2: IInterface;
  IntfThree: IBaseInterface;
  Intf3: IInterface;
  IntfOneBack: IThirdInterface;
begin
  mock := TMock<IThirdInterface>.Create;
  mock.Implement<ISecondInterface>;
  mock.Implement<IBaseInterface>;

  Assert.WillNotRaiseAny(procedure
  begin
    IntfOne := mock;
    Intf1 := IntfOne as IInterface;
    IntfTwo := Intf1 as ISecondInterface;
    Intf2 := IntfTwo as IInterface;
    IntfThree := Intf2 as IBaseInterface;
    Intf3 := IntfThree as IInterface;
    IntfOneBack := Intf3 as IThirdInterface;
  end);

  Assert.IsNotNull(IntfOne);
  Assert.IsNotNull(IntfTwo);
  Assert.IsNotNull(IntfThree);
  Assert.IsNotNull(Intf1);
  Assert.IsNotNull(Intf2);
  Assert.IsNotNull(Intf3);
  Assert.IsNotNull(IntfOneBack);

  Assert.AreSame(Intf1, Intf2, 'Intf1 = Intf2');
  Assert.AreSame(Intf2, Intf3, 'Intf2 = Intf3');
  Assert.AreSame(Intf3, Intf1, 'Intf3 = Intf1');
  Assert.AreSame(IntfOne, IntfOneBack, 'IntfOne = IntfOneBack');
end;

type
  TBaseTestObject = class(TInterfacedObject, IBaseInterface)
    procedure Method;
  end;

  TSecondTestObject = class(TBaseTestObject, ISecondInterface)
    procedure MethodTwo;
  end;

  TThirdTestObject = class(TSecondTestObject, IThirdInterface)
    procedure MethodThree;
  end;

procedure TBaseTestObject.Method;
begin
end;

procedure TSecondTestObject.MethodTwo;
begin
end;

procedure TThirdTestObject.MethodThree;
begin
end;


procedure TTestMock.CreateMock_With_Inherited_Interfaces_We_Get_SamePointers_BaseLine;
var
  Obj : TThirdTestObject;
  IntfOne: IThirdInterface;
  Intf1: IInterface;
  IntfTwo: ISecondInterface;
  Intf2: IInterface;
  IntfThree: IBaseInterface;
  Intf3: IInterface;
  IntfOneBack: IThirdInterface;
begin
  Obj := TThirdTestObject.Create;

  Assert.WillNotRaiseAny(procedure
  begin
    IntfOne := Obj;
    Intf1 := IntfOne as IInterface;
    IntfTwo := Intf1 as ISecondInterface;
    Intf2 := IntfTwo as IInterface;
    IntfThree := Intf2 as IBaseInterface;
    Intf3 := IntfThree as IInterface;
    IntfOneBack := Intf3 as IThirdInterface;
  end);

  Assert.IsNotNull(IntfOne);
  Assert.IsNotNull(IntfTwo);
  Assert.IsNotNull(IntfThree);
  Assert.IsNotNull(Intf1);
  Assert.IsNotNull(Intf2);
  Assert.IsNotNull(Intf3);
  Assert.IsNotNull(IntfOneBack);

  Assert.AreSame(Intf1, Intf2, 'Intf1 = Intf2');
  Assert.AreSame(Intf2, Intf3, 'Intf2 = Intf3');
  Assert.AreSame(Intf3, Intf1, 'Intf3 = Intf1');
  Assert.AreSame(IntfOne, IntfOneBack, 'IntfOne = IntfOneBack');
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
  Assert.Pass;
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
  Assert.Pass;
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
