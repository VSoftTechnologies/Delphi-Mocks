unit Delphi.Mocks.Tests.MethodData;

interface

uses
  SysUtils,
  TestFramework,
  Rtti,
  Delphi.Mocks,
  Delphi.Mocks.Interfaces;

type
  {$M+}
  ISimpleInterface = interface
    function MissingArg(Value: Integer): Integer;
  end;
  {$M-}

  TTestMethodData = class(TTestCase)
  public
    {TODO Implement test}
    procedure Expectation_Before_Verifies_To_True_When_Prior_Method_Called_Atleast_Once;
  published
    procedure RaiseExceptionWhenMissingArgsAndDontHaveDefaultValue;
  end;

implementation

uses
  Delphi.Mocks.Helpers,
  Delphi.Mocks.MethodData,
  classes, System.StrUtils;


{ TTestMethodData }

procedure TTestMethodData.Expectation_Before_Verifies_To_True_When_Prior_Method_Called_Atleast_Once;
begin
  Check(False, 'Not implemented');
end;

procedure TTestMethodData.RaiseExceptionWhenMissingArgsAndDontHaveDefaultValue;
const
  EXPECTED_ERROR_MESSAGE = 'method [MissingArg] with args ( 4 )';
var
  vMock: TMock<ISimpleInterface>;
begin
  vMock := TMock<ISimpleInterface>.Create;
  vMock.Setup.Expect.Once.When.MissingArg(123);

  try
    vMock.Instance.MissingArg(4);
    Fail('Do not raise Exception');
  except
    on E: Exception do
    begin
      CheckEquals(EMockException.ClassName, E.ClassName, 'Expect a MockException');
      CheckTrue(ContainsText(E.Message, EXPECTED_ERROR_MESSAGE),
                Format('Expect the string <%s> contains the substring <%s>',[E.Message, EXPECTED_ERROR_MESSAGE]));
    end;
  end;
end;

initialization
  TestFramework.RegisterTest(TTestMethodData.Suite);

end.
