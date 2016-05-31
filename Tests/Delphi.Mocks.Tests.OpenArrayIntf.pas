unit Delphi.Mocks.Tests.OpenArrayIntf;

interface

uses
  DUnitX.TestFramework;

type
  {$M+}
  [TestFixture]
  TestIOpenArray = class
  published
    procedure TestMyMethodDynamicArray;
    procedure TestMyMethodTypedArray;
  end;
  {$M-}

  TMyArray = array of Integer;

  {$M+}
  IDynamicArray = interface
    // This crashes: One open array + one more parameter. Only the open array works.
    function MyMethod(MyArray: array of Integer; Number: Integer): Integer;
  end;

  ITypedArray = interface
    function MyMethod(MyArray: TMyArray; Number: Integer): Integer;

  end;
  {$M-}

implementation

uses
  Delphi.Mocks;

procedure TestIOpenArray.TestMyMethodDynamicArray;
var
  Mock: TMock<IDynamicArray>;
  Intf: IDynamicArray;
  returnValue: integer;
begin
  Mock := TMock<IDynamicArray>.Create;

  Mock.Setup.WillReturn(3).When.MyMethod([123], 1);

  Intf := Mock;

  // in XE6 there was only an access violation, when using the Method inside the "Assert.AreEqual" method
  // Using a local variable fixed this AV
  returnValue := Intf.MyMethod([123], 1);
  Assert.AreEqual(3, returnValue);
end;

procedure TestIOpenArray.TestMyMethodTypedArray;
var
  Mock: TMock<ITypedArray>;
  Intf: ITypedArray;
  MyArray: TMyArray;
begin
  Mock := TMock<ITypedArray>.Create;

  // Setup our typed array
  SetLength(MyArray, 1);
  MyArray[0] := 123;

  Mock.Setup.WillReturn(2).When.MyMethod(MyArray, 1);

  Intf := Mock;

  // This works! yay :D
  Assert.AreEqual(2, Intf.MyMethod(MyArray, 1));
end;

initialization
  TDUnitX.RegisterTestFixture(TestIOpenArray);
end.
