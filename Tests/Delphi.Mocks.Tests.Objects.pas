unit Delphi.Mocks.Tests.Objects;

interface

uses
  SysUtils,
  TestFramework,
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

  TMockObjectTests = class(TTestcase)
  published
    procedure MockObject_Can_Call_Function;
  end;

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
end;

{ TSimpleObject }

procedure TSimpleMockedObject.SimpleMethod;
begin
 //Does nothing;
end;

{ TSystemUnderTest }

constructor TSystemUnderTest.Create(const AMock: TSimpleMockedObject);
begin
  FMocked := AMock;
end;

initialization
  TestFramework.RegisterTest(TMockObjectTests.Suite);
end.
