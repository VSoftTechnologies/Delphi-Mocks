unit Delphi.Mocks.Tests.TValue;

interface

uses
  TestFramework;

type
  TValueTests = class(TTestcase)
  published
  end;

implementation

uses
  Delphi.Mocks.Helpers;

initialization
  RegisterTest(TValueTests.Suite);
end.
