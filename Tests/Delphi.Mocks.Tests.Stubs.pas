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
    procedure Test_CanStubInheritedMethods;
  end;
  {$M-}

  {$M+}
  ITestable = interface
    function DoSomething(const value : string) : string;
  end;
  {$M-}


implementation

uses
  Classes,
  Delphi.Mocks;
{ TUtilsTests }
{ TStubTests }

procedure TStubTests.Test_CanStubInheritedMethods;
var
  stub : TStub<TStringList>;
begin
  stub := TStub<TStringList>.Create;
  stub.Setup.BehaviorMustBeDefined := false;
  stub.Setup.WillReturnDefault('Add', 0);
//  stub.Setup.WillReturn(1).When.Add(It(0).IsAny<string>);
  stub.Instance.Add('2');
end;

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
