unit Delphi.Mocks.Tests.Utils;

interface
uses
  DUnitX.TestFramework,
  Rtti,
  Delphi.Mocks.Helpers;

type
  //Testing TValue helper methods in TValueHelper
  {$M+}
  [TestFixture]
  TTestTValue = class
  published
    procedure Test_TValue_Equals_Interfaces;
    procedure Test_TValue_NotEquals_Interfaces;
    procedure Test_TValue_Equals_Strings;
    procedure Test_TValue_NotEquals_Strings;

    procedure Test_TValue_Equals_SameGuid_Instance;
    procedure Test_TValue_Equals_DifferentGuid_Instance;
    procedure Test_TValue_NotEquals_Guid;

    procedure Test_TRttiMethod_IsAbstract;
    procedure Test_TRttiMethod_IsVirtual;

    procedure Test_CompareValue_RecordEquals;
    procedure Test_CompareValue_RecordNotEquals;
    procedure Test_CompareValue_RecordNoEqualsOperator;

    procedure Test_CompareValue_ArrayEquals;
    procedure Test_CompareValue_ArrayNotEquals;

    procedure Test_CompareValue_ObjectEquals;
    procedure Test_CompareValue_ObjectNotEquals;

    procedure Test_CompareValue_InterfaceNotEquals_AddressesFarApart;
  end;
  {$M-}

implementation

uses
  {$IFDEF CPU64BITS}
  Windows,
  {$ENDIF}
  SysUtils;

{$IFDEF CPU64BITS}
// Fake interface: an IInterface method table whose methods do nothing. It allows creating an interface reference
// at any chosen address without creating a real object.
function FakeQueryInterface(Self: Pointer; const IID: TGUID; out Obj): HResult; stdcall;
begin
  Pointer(Obj) := nil;
  Result := E_NOINTERFACE;
end;

function FakeAddRef(Self: Pointer): Integer; stdcall;
begin
  Result := 1;
end;

function FakeRelease(Self: Pointer): Integer; stdcall;
begin
  Result := 1;
end;

const
  FakeVTable: array[0..2] of Pointer = (@FakeQueryInterface, @FakeAddRef, @FakeRelease);

// The comparison is in a separate function so that the temporary TValues (and their references) are released before the
// memory of the fakes is freed in the test.
function CompareFakeInterfaces(const AInterface1, AInterface2: IInterface): Integer;
begin
  Result := CompareValue(TValue.From<IInterface>(AInterface1), TValue.From<IInterface>(AInterface2));
end;
{$ENDIF}

type
  TMyClass = class
  private
    FValue: Integer;
  public
    procedure NormalMethod;
    procedure AbstractMethod; virtual; abstract;
    procedure VirtualMethod; virtual;

    constructor Create(AValue: Integer);

    function Equals(AItem: TObject): Boolean; override;
  end;

  TMyRec = record
    Value: String;

    class operator Equal(a, b: TMyRec): Boolean;
  end;

  TMySimpleRec = record
    Value: String;
  end;

{ TTestTValue }

procedure TTestTValue.Test_TValue_Equals_Interfaces;
var
  i1,i2 : IInterface;
  v1, v2 : TValue;
begin
  i1 := TInterfacedObject.Create;
  i2 := i1;
  v1 := TValue.From<IInterface>(i1);
  v2 := TValue.From<IInterface>(i2);

  Assert.IsTrue(v1.Equals(v2));
end;

procedure TTestTValue.Test_TValue_Equals_Strings;
var
  s1,s2 : string;
  v1, v2 : TValue;
begin
  s1 := 'hello';
  s2 := 'hello';
  v1 := s1;
  v2 := s2;
  Assert.IsTrue(v1.Equals(v2));
end;

procedure TTestTValue.Test_TValue_Equals_SameGuid_Instance;
var
  s1,s2 : TGUID;
  v1, v2 : TValue;
begin
  s1 := StringToGUID( '{2933052C-79D0-48C9-86D3-8FF29416033C}' );
  s2 := s1;
  v1 := TValue.From<TGUID>( s1 );
  v2 := TValue.From<TGUID>( s2 );
  Assert.IsTrue(v1.Equals(v2));
end;

procedure TTestTValue.Test_CompareValue_ArrayEquals;
var
  a1, a2: TArray<string>;
begin
  a1 := [];
  a2 := [];
  Assert.AreEqual(0, CompareValue(TValue.From(a1), TValue.From(a2)));

  a1 := ['a', 'b'];
  a2 := ['a', 'b'];
  Assert.AreEqual(0, CompareValue(TValue.From(a1), TValue.From(a2)));
end;

procedure TTestTValue.Test_CompareValue_ArrayNotEquals;
var
  a1, a2: TArray<string>;
begin
  a1 := ['a'];
  a2 := ['a', 'b'];
  Assert.AreNotEqual(0, CompareValue(TValue.From(a1), TValue.From(a2)));

  a1 := ['a', 'b'];
  a2 := ['a'];
  Assert.AreNotEqual(0, CompareValue(TValue.From(a1), TValue.From(a2)));

  a1 := [];
  a2 := ['a'];
  Assert.AreNotEqual(0, CompareValue(TValue.From(a1), TValue.From(a2)));

  a1 := ['a'];
  a2 := [];
  Assert.AreNotEqual(0, CompareValue(TValue.From(a1), TValue.From(a2)));
end;

procedure TTestTValue.Test_CompareValue_ObjectEquals;
var
  o1, o2: TMyClass;
begin
  o1 := TMyClass.Create(1);
  o2 := TMyClass.Create(1);
  try
    Assert.AreEqual(0, CompareValue(TValue.From<TMyClass>(o1), TValue.From<TMyClass>(o1)));
    Assert.AreEqual(0, CompareValue(TValue.From<TMyClass>(o2), TValue.From<TMyClass>(o2)));
    Assert.AreEqual(0, CompareValue(TValue.From<TMyClass>(o1), TValue.From<TMyClass>(o2)));
  finally
    o1.Free;
    o2.Free;
  end;
end;

procedure TTestTValue.Test_CompareValue_ObjectNotEquals;
var
  o1, o2: TMyClass;
begin
  o1 := TMyClass.Create(1);
  o2 := TMyClass.Create(2);
  try
    Assert.AreEqual(0, CompareValue(TValue.From<TMyClass>(o1), TValue.From<TMyClass>(o1)));
    Assert.AreEqual(0, CompareValue(TValue.From<TMyClass>(o2), TValue.From<TMyClass>(o2)));
    Assert.AreNotEqual(0, CompareValue(TValue.From<TMyClass>(o1), TValue.From<TMyClass>(o2)));
  finally
    o1.Free;
    o2.Free;
  end;
end;

procedure TTestTValue.Test_CompareValue_InterfaceNotEquals_AddressesFarApart;
{$IFDEF CPU64BITS}
const
  cBaseAddress = UInt64($20000000);
  cFarAddress = UInt64($120000000); // exactly 4 GB further: truncating the address difference to 32 bits gives 0
var
  lFake1, lFake2: PPointer;
  lIntf1, lIntf2: IInterface;
begin
  // The address difference does not fit in an Integer. With range checking enabled this raises ERangeError, without it the
  // truncated difference is 0 and different interfaces would be considered equal.
  lFake1 := VirtualAlloc(Pointer(NativeUInt(cBaseAddress)), 4096, MEM_RESERVE or MEM_COMMIT, PAGE_READWRITE);
  lFake2 := VirtualAlloc(Pointer(NativeUInt(cFarAddress)), 4096, MEM_RESERVE or MEM_COMMIT, PAGE_READWRITE);
  try
    if (lFake1 = nil) or (lFake2 = nil) then
      Assert.Pass('Could not reserve memory at the required addresses');
    lFake1^ := @FakeVTable;
    lFake2^ := @FakeVTable;
    Pointer(lIntf1) := lFake1;
    Pointer(lIntf2) := lFake2;
    try
      Assert.AreNotEqual(0, CompareFakeInterfaces(lIntf1, lIntf2));
      Assert.IsTrue(CompareFakeInterfaces(lIntf1, lIntf2) < 0);
      Assert.IsTrue(CompareFakeInterfaces(lIntf2, lIntf1) > 0);
      Assert.AreEqual(0, CompareFakeInterfaces(lIntf1, lIntf1));
    finally
      Pointer(lIntf1) := nil;
      Pointer(lIntf2) := nil;
    end;
  finally
    if lFake1 <> nil then
      VirtualFree(lFake1, 0, MEM_RELEASE);
    if lFake2 <> nil then
      VirtualFree(lFake2, 0, MEM_RELEASE);
  end;
end;
{$ELSE}
begin
  Assert.Pass('This test applies to Win64 only');
end;
{$ENDIF}

procedure TTestTValue.Test_CompareValue_RecordEquals;
var
  r1, r2: TMyRec;
begin
  r1.Value := 'test';
  r2.Value := 'test';

  Assert.AreEqual(0, CompareValue(TValue.From(r1), TValue.From(r2)));
end;

procedure TTestTValue.Test_CompareValue_RecordNoEqualsOperator;
var
  r1, r2: TMySimpleRec;
begin
  r1.Value := 'test';
  r2.Value := 'test1';

  Assert.AreEqual(0, CompareValue(TValue.From(r1), TValue.From(r2)));
end;

procedure TTestTValue.Test_CompareValue_RecordNotEquals;
var
  r1, r2: TMyRec;
begin
  r1.Value := 'test';
  r2.Value := 'test1';

  Assert.AreNotEqual(0, CompareValue(TValue.From(r1), TValue.From(r2)));
end;

procedure TTestTValue.Test_TRttiMethod_IsAbstract;
var
  LCtx: TRttiContext;
begin
  Assert.IsFalse(LCtx.GetType(TMyClass).GetMethod('NormalMethod').IsAbstract);
  Assert.IsTrue(LCtx.GetType(TMyClass).GetMethod('AbstractMethod').IsAbstract);
  Assert.IsFalse(LCtx.GetType(TMyClass).GetMethod('VirtualMethod').IsAbstract);
end;

procedure TTestTValue.Test_TRttiMethod_IsVirtual;
var
  LCtx: TRttiContext;
begin
  Assert.IsFalse(LCtx.GetType(TMyClass).GetMethod('NormalMethod').IsVirtual);
  Assert.IsTrue(LCtx.GetType(TMyClass).GetMethod('AbstractMethod').IsVirtual);
  Assert.IsTrue(LCtx.GetType(TMyClass).GetMethod('VirtualMethod').IsVirtual);
end;

procedure TTestTValue.Test_TValue_Equals_DifferentGuid_Instance;
var
  s1,s2 : TGUID;
  v1, v2 : TValue;
begin
  s1 := StringToGUID( '{2933052C-79D0-48C9-86D3-8FF29416033C}' );
  s2 := StringToGUID( '{2933052C-79D0-48C9-86D3-8FF29416033C}' );
  v1 := TValue.From<TGUID>( s1 );
  v2 := TValue.From<TGUID>( s2 );
  Assert.IsTrue(v1.Equals(v2));
end;

procedure TTestTValue.Test_TValue_NotEquals_Guid;
var
  s1,s2 : TGUID;
  v1, v2 : TValue;
begin
  s1 := StringToGUID( '{2933052C-79D0-48C9-86D3-8FF294160000}' );
  s2 := StringToGUID( '{2933052C-79D0-48C9-86D3-8FF29416FFFF}' );
  v1 := TValue.From<TGUID>( s1 );
  v2 := TValue.From<TGUID>( s2 );
  Assert.IsFalse(v1.Equals(v2));
end;

procedure TTestTValue.Test_TValue_NotEquals_Interfaces;
var
  i1,i2 : IInterface;
  v1, v2 : TValue;
begin
  i1 := TInterfacedObject.Create;
  i2 := TInterfacedObject.Create;
  v1 := TValue.From<IInterface>(i1);
  v2 := TValue.From<IInterface>(i2);
  Assert.IsFalse(v1.Equals(v2));
end;

procedure TTestTValue.Test_TValue_NotEquals_Strings;
var
  s1,s2 : string;
  v1, v2 : TValue;
begin
  s1 := 'hello';
  s2 := 'goodbye';
  v1 := s1;
  v2 := s2;
  Assert.IsFalse(v1.Equals(v2));
end;

{ TMyClass }

constructor TMyClass.Create(AValue: Integer);
begin
  FValue := AValue;
end;

function TMyClass.Equals(AItem: TObject): Boolean;
begin
  Result := AItem is TMyClass;
  if Result then
    Result := TMyClass(AItem).FValue = Self.FValue;
end;

procedure TMyClass.NormalMethod;
begin
  //No op
end;

procedure TMyClass.VirtualMethod;
begin
  //No op
end;

{ TMyRec }

class operator TMyRec.Equal(a, b: TMyRec): Boolean;
begin
  Result := a.Value = b.Value;
end;

initialization
  TDUnitX.RegisterTestFixture(TTestTValue);

end.
