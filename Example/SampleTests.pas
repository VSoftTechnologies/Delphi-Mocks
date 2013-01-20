unit SampleTests;

interface

uses
  TestFramework;

type
  TSampleTests = class(TTestCase)

  published
    procedure Test1;
    procedure Test2;
    procedure Test3;
    procedure Test4;
    procedure Test5;

  end;

implementation

{ TSampleTests }

procedure TSampleTests.Test1;
begin
  Check(true);
end;

procedure TSampleTests.Test2;
begin
  Check(false,'Test2 should fail');
end;

procedure TSampleTests.Test3;
begin
  Check(true);
end;

procedure TSampleTests.Test4;
begin
  Check(true);
end;

procedure TSampleTests.Test5;
begin
  Check(false,'Test should fail');
end;


initialization
  // Register any test cases with the test runner
  RegisterTest(TSampleTests.Suite);

end.
