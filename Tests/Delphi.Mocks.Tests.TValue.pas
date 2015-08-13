unit Delphi.Mocks.Tests.TValue;

interface

uses
  DUnitX.TestFramework;

type
  TValueTests = class
  published
  end;

implementation

uses
  Delphi.Mocks.Helpers;

initialization
  TDUnitX.RegisterTestFixture(TValueTests);
end.
