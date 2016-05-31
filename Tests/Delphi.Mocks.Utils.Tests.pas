unit Delphi.Mocks.Utils.Tests;

interface
uses
  DUnitX.TestFramework;
type
  {$M+}
  [TestFixture]
  TUtilsTests = class
  published
    procedure CheckInterfaceHasRTTIWithoutRTTI;
    procedure CheckInterfaceHasRTTIWithNonInterface;
    procedure CheckInterfaceHasRTTIWithInterfaceRTTI;
  end;
  {$M-}

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
  Assert.IsTrue(CheckInterfaceHasRTTI(TypeInfo(ITestable)));
end;

procedure TUtilsTests.CheckInterfaceHasRTTIWithNonInterface;
begin
  Assert.IsTrue(CheckInterfaceHasRTTI(TypeInfo(TObject)));
end;

procedure TUtilsTests.CheckInterfaceHasRTTIWithoutRTTI;
begin
  Assert.IsFalse(CheckInterfaceHasRTTI(TypeInfo(IInterface)));
end;


initialization
  TDUnitX.RegisterTestFixture(TUtilsTests);
end.
