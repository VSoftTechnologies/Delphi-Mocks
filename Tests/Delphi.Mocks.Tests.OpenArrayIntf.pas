unit Delphi.Mocks.Tests.OpenArrayIntf;

interface

uses
  TestFramework;

type
  TestIOpenArray = class(TTestCase)
  published
    procedure TestMyMethodDynamicArray;
    procedure TestMyMethodTypedArray;
  end;

  TMyArray = array of TObject;

  {$M+}
  IDynamicArray = interface
    // This crashes: One open array + one more parameter. Only the open array works.
    function MyMethod(MyArray: array of TObject; Number: Integer): Integer;
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
  Obj: TObject;
begin
  Mock := TMock<IDynamicArray>.Create;

  Obj := TObject.Create;
  Mock.Setup.WillReturn(3).When.MyMethod([Obj], 1);

  Intf := Mock;

  //TODO: Fix the privileged instruction. Something to do with TValue not liking Dynamic Arrays
  CheckEquals(3, Intf.MyMethod([Obj], 1));
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
  MyArray[0] := TObject.Create;

  Mock.Setup.WillReturn(2).When.MyMethod(MyArray, 1);

  Intf := Mock;

  // This works! yay :D
  CheckEquals(2, Intf.MyMethod(MyArray, 1));
end;

initialization

RegisterTest(TestIOpenArray.Suite);

end.
