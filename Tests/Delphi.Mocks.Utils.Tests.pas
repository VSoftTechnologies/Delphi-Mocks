unit Delphi.Mocks.Utils.Tests;

interface
uses
  TestFramework;
type
  TUtilsTests = class(TTestcase)
  published
    procedure CheckInterfaceHasRTTIWithoutRTTI;
    procedure CheckInterfaceHasRTTIWithNonInterface;
    procedure CheckInterfaceHasRTTIWithInterfaceRTTI;
  end;

  {$M+}
  ITestable = interface
    procedure DoSomething;
  end;
  {$M-}


implementation
uses
  Delphi.Mocks.Utils;
{ TUtilsTests }

procedure TUtilsTests.CheckInterfaceHasRTTIWithInterfaceRTTI;

begin
  CheckTrue(CheckInterfaceHasRTTI(TypeInfo(ITestable)));
end;

procedure TUtilsTests.CheckInterfaceHasRTTIWithNonInterface;
begin
  CheckTrue(CheckInterfaceHasRTTI(TypeInfo(TObject)));
end;

procedure TUtilsTests.CheckInterfaceHasRTTIWithoutRTTI;
begin
  CheckFalse(CheckInterfaceHasRTTI(TypeInfo(IInterface)));
end;

initialization
  RegisterTest(TUtilsTests.Suite);
end.
