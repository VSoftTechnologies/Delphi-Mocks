unit Delphi.Mocks.Tests.MethodData;

interface

uses
  SysUtils,
  TestFramework,
  Rtti,
  Delphi.Mocks,
  Delphi.Mocks.Interfaces;

type
  TTestMethodData = class(TTestCase)
  published
    procedure Expectation_Before_Verifies_To_True_When_Prior_Method_Called_Atleast_Once;
  end;

implementation

uses
  Delphi.Mocks.Helpers,
  Delphi.Mocks.MethodData,
  classes;


{ TTestMethodData }

procedure TTestMethodData.Expectation_Before_Verifies_To_True_When_Prior_Method_Called_Atleast_Once;
begin
  Check(False, 'Not implemented');
end;

end.
