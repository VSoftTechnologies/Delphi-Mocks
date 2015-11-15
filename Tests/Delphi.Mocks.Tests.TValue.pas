unit Delphi.Mocks.Tests.TValue;

interface

uses
  DUnitX.TestFramework;

type
  {$M+}
  TValueTests = class
  end;
  {$M-}

implementation

uses
  Delphi.Mocks.Helpers;

initialization
  TDUnitX.RegisterTestFixture(TValueTests);
end.
