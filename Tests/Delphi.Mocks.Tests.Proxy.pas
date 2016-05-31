unit Delphi.Mocks.Tests.Proxy;

interface

uses
  Rtti,
  SysUtils,
  DUnitX.TestFramework,
  Delphi.Mocks;

type
  {$M+}
  [TestFixture]
  TTestMock = class
  published
    [Test, Ignore]
    procedure Expectation_Before_Verifies_To_True_When_Prior_Method_Called_Atleast_Once;
  end;
  {$M-}

implementation

uses
  Delphi.Mocks.Helpers,
  Delphi.Mocks.Interfaces,
  Delphi.Mocks.MethodData,
  classes;



{ TTestMock }

procedure TTestMock.Expectation_Before_Verifies_To_True_When_Prior_Method_Called_Atleast_Once;
begin
  Assert.NotImplemented;
end;

initialization
  TDUnitX.RegisterTestFixture(TTestMock);
end.
