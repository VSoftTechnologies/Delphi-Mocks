unit Delphi.Mocks.Examples.Objects;

interface

uses
  SysUtils,
  //DUnitX.TestFramework,
  Delphi.Mocks;

type
  ESimpleException = exception;
  {$M+}
  TSimpleMockedObject = class(TObject)
  public
    procedure SimpleMethod;virtual;
  end;
  {$M-}

  TSystemUnderTest = class(TObject)
  private
    FMocked : TSimpleMockedObject;
  public
    constructor Create(const AMock: TSimpleMockedObject);
    procedure CallsSimpleMethodOnMock;virtual;
  end;

  {$M+}
  TMockObjectTests = class
  published
    procedure MockObject_Can_Call_Function;virtual;
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
  try
    {Assert.WillRaise(procedure
    begin
      systemUnderTest.CallsSimpleMethodOnMock;
    end, ESimpleException);}
  finally
   systemUnderTest.Free;
  end;
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

end.
