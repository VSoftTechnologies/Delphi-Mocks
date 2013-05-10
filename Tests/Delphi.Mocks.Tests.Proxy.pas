unit Delphi.Mocks.Tests.Proxy;

interface

uses
  Rtti,
  SysUtils,
  TestFramework,
  Delphi.Mocks;

type
  TTestMock = class(TTestCase)
  published
    procedure Expectation_Before_Verifies_To_True_When_Prior_Method_Called_Atleast_Once;
  end;

implementation

uses
  Delphi.Mocks.Helpers,
  Delphi.Mocks.Interfaces,
  Delphi.Mocks.MethodData,
  classes;



end.
