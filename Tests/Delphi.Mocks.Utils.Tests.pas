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
implementation
uses
  Delphi.Mocks.Utils;
{ TUtilsTests }

procedure TUtilsTests.CheckInterfaceHasRTTIWithInterfaceRTTI;

begin
  CheckTrue(CheckInterfaceHasRTTI(TypeInfo(IInvokable)));
end;

procedure TUtilsTests.CheckInterfaceHasRTTIWithNonInterface;
begin
  CheckFalse(CheckInterfaceHasRTTI(TypeInfo(TObject)));
end;

procedure TUtilsTests.CheckInterfaceHasRTTIWithoutRTTI;
begin
  CheckFalse(CheckInterfaceHasRTTI(TypeInfo(IInterface)));
end;
initialization
  RegisterTest(TUtilsTests.Suite);
end.
