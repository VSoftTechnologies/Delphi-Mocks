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
  end;
  {$M-}


implementation

uses
  Rtti;

{ TMockObjectTests }

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
