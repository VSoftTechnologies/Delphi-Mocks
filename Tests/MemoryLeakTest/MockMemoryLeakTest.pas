unit MockMemoryLeakTest;

interface

uses
  DUnitX.TestFramework, Delphi.Mocks;

type
  {$M+}
  IMyInterface = interface
    procedure MyMethod;
  end;
  {$M-}

  TMockMemoryLeakTest = class(TTestCase)
  published
    procedure ItMakesMemoryLeaks;
  end;

implementation

{ TMockMemoryLeakTest }

procedure TMockMemoryLeakTest.ItMakesMemoryLeaks;
var
  I: TMock<IMyInterface>;
begin
  I := TMock<IMyInterface>.Create;
  //I.Instance; // Uncomment and get rid of leaks
  I.Free; // Not really needed
end;

initialization
  RegisterTest(TMockMemoryLeakTest.Suite);
end.
