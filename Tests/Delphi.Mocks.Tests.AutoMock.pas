unit Delphi.Mocks.Tests.AutoMock;

interface

uses
  SysUtils,
  DUnitX.TestFramework,
  Delphi.Mocks;

type
  {$M+}
  TReturnedObject = class(TObject)
  end;
  {$M-}

  {$M+}
  IReturnedInterface = interface
    ['{8C9AA0D8-5788-4B40-986A-46422BB05E9A}']
    procedure Dud;
  end;
  {$M-}

  {$M+}
  IReturnedInterfaceWhichAlsoReturns = interface
    ['{8E3D166F-ED6A-40D9-8C0A-4EC8FF969AF9}']
    procedure Dud;
  end;
  {$M-}

  {$M+}
  IAutoMockedInterface = interface
    ['{CC254E0F-63D0-49CB-9918-63AE5D388842}']
    function FuncToReturnInterface : IReturnedInterface;
    function FuncToReturnClass : TReturnedObject;
    function FuncToReturnInterfaceWhichAlsoReturn : IReturnedInterfaceWhichAlsoReturns;
  end;
  {$M-}

  {$M+}
  [TestFixture]
  TAutoMockTests = class
  published
    procedure AutoMock_Can_Mock_Interface;
    [Test, Ignore]
    procedure AutoMock_Automatically_Mocks_Contained_Returned_Interface;
  end;
  {$M-}

implementation

{ TAutoMockTests }

procedure TAutoMockTests.AutoMock_Automatically_Mocks_Contained_Returned_Interface;
var
  automockSUT : TAutoMockContainer;
  mock : TMock<IAutoMockedInterface>;
  mockInterface : IReturnedInterface;
  mockObject : TReturnedObject;
begin
  automockSUT := TAutoMockContainer.Create;

  mock := automockSUT.Mock<IAutoMockedInterface>;

  mockInterface := mock.Instance.FuncToReturnInterface;
  mockObject := mock.Instance.FuncToReturnClass;

  Assert.IsNotNull(mockInterface, 'Expected the interface off the mock to be automatically created and the instance returned.');
  Assert.IsNotNull(mockObject, 'Expected the object off the mock to be automatically created and the instance returned.');
end;

procedure TAutoMockTests.AutoMock_Can_Mock_Interface;
var
  automockSUT : TAutoMockContainer;
  mock : TMock<IAutoMockedInterface>;
begin
  automockSUT := TAutoMockContainer.Create;

  mock := automockSUT.Mock<IAutoMockedInterface>;

  Assert.IsNotNull(mock.Instance, 'Expect the interface returned from mock is not null');
end;

initialization
  TDUnitX.RegisterTestFixture(TAutoMockTests);

end.
