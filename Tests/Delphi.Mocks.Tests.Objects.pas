unit Delphi.Mocks.Tests.Objects;

interface

uses
  SysUtils,
  DUnitX.TestFramework,
  Delphi.Mocks;

type
  ESimpleException = exception;

  TSimpleMockedObject = class(TObject)
  public
    procedure SimpleMethod;
    function VirtualAbstract: Integer; virtual; abstract;
  end;

  TSystemUnderTest = class(TObject)
  private
    FMocked : TSimpleMockedObject;
  public
    constructor Create(const AMock: TSimpleMockedObject);
    procedure CallsSimpleMethodOnMock;
  end;

  {$M+}
  [TestFixture]
  TMockObjectTests = class
  published
    procedure MockObject_Can_Call_Function;
    [Test]
    procedure CanMockVirtualAbstractCallBehavior;
    [Test]
    procedure CanMockVirtualAbstractCallDefault;
  end;
  {$M-}


implementation

uses
  Rtti;

{ TMockObjectTests }

procedure TMockObjectTests.CanMockVirtualAbstractCallBehavior;
var
  Mock: TMock<TSimpleMockedObject>;
begin
  Mock := TMock<TSimpleMockedObject>.Create;
  Mock.Setup.WillReturn(2).When.VirtualAbstract;
  Assert.AreEqual(2, Mock.Instance.VirtualAbstract);
end;

procedure TMockObjectTests.CanMockVirtualAbstractCallDefault;
var
  Mock: TMock<TSimpleMockedObject>;
begin
  Mock := TMock<TSimpleMockedObject>.Create;
  Mock.Setup.WillReturnDefault('VirtualAbstract', 2);
  Assert.AreEqual(2, Mock.Instance.VirtualAbstract);
end;

procedure TMockObjectTests.MockObject_Can_Call_Function;
var
  mock : TMock<TSimpleMockedObject>;
  systemUnderTest : TSystemUnderTest;
begin
  //var mock = new Mock<IFoo>();
  //mock.Setup(foo => foo.DoSomething("ping")).Returns(true);
  mock := TMock<TSimpleMockedObject>.Create;

  mock.Setup.WillRaise('SimpleMethod', ESimpleException);

  systemUnderTest := TSystemUnderTest.Create(mock.Instance);

  systemUnderTest.CallsSimpleMethodOnMock;

  mock.VerifyAll;

  Assert.Pass;
end;

{ TSimpleObject }

procedure TSimpleMockedObject.SimpleMethod;
begin
 //Does nothing;
end;

{ TSystemUnderTest }

procedure TSystemUnderTest.CallsSimpleMethodOnMock;
begin
  FMocked.SimpleMethod;
end;

constructor TSystemUnderTest.Create(const AMock: TSimpleMockedObject);
begin
  FMocked := AMock;
end;

initialization
  TDUnitX.RegisterTestFixture(TMockObjectTests);
end.
