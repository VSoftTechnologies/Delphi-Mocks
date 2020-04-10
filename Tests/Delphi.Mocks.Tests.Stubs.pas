unit Delphi.Mocks.Tests.Stubs;

interface

uses
  DUnitX.TestFramework;
type
  {$M+}
  [TestFixture]
  TStubTests = class
  published
    procedure Test_WillReturnDefault;
  end;
  {$M-}

  {$M+}
  ITestable = interface
    function DoSomething(const value : string) : string;
  end;
  {$M-}


implementation

uses
  Delphi.Mocks;
{ TUtilsTests }
{ TStubTests }

procedure TStubTests.Test_WillReturnDefault;
var
  stub : TStub<ITestable>;
  intf : ITestable;
  actual : string;
begin
  stub := TStub<ITestable>.Create;
  stub.Setup.WillReturnDefault('DoSomething','hello');
  intf := stub.Instance;
  actual := intf.DoSomething('world');
  Assert.AreEqual('hello', actual);
end;

initialization
  TDUnitX.RegisterTestFixture(TStubTests);


end.
