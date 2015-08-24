unit Delphi.Mocks.Tests.Utils;

interface
uses
  TestFramework,
  Rtti,
  Delphi.Mocks.Helpers;

type
  //Testing TValue helper methods in TValueHelper
  TTestTValue = class(TTestCase)
  published
    // INTERFACE
    procedure Test_TValue_Equals_Interfaces;
    procedure Test_TValue_NotEquals_Interfaces;

    // STRING
    procedure Test_TValue_Equals_Strings;
    procedure Test_TValue_NotEquals_Strings;

    // GUID
    procedure Test_TValue_Equals_SameGuid_Instance;
    procedure Test_TValue_Equals_DifferentGuid_Instance;
    procedure Test_TValue_NotEquals_Guid;

    // VARIANT
    // includes tests for VarArray of variant
    // when using Variants with varArray of Variant, you need to follow the code convention
    //  Assign to TValue using, TValue.From<Variant>(myVar)
    //  Do not use TValue.FromVariant, as this does not support varArray
    //  Otherwise, it will work as expected
    procedure Test_TValue_Equals_Variants;
    procedure Test_TValue_Equals_Variants_BothEmpty;
    procedure Test_TValue_Equals_Variants_BothUnAssigned;
    procedure Test_TValue_Equals_Variants_VarArray;
    procedure Test_TValue_Equals_Variants_VarArray_DifferentInstances;
    procedure Test_TValue_NotEquals_Variants;
    procedure Test_TValue_NotEquals_Variants_OneEmpty;
    procedure Test_TValue_NotEquals_Variants_OneUnAssigned;
    procedure Test_TValue_NotEquals_Variants_VarArray_DifferentLengths;
    procedure Test_TValue_NotEquals_Variants_VarArray_DifferentContent;

    procedure Test_TValue_Equals_Variants_VarArray_Of_Variant;
    procedure Test_TValue_NotEquals_Variants_VarArray_Of_Variant;

    // OLEVARIANT
    procedure Test_TValue_Equals_OLEVariants;
    procedure Test_TValue_Equals_OLEVariants_BothEmpty;
    procedure Test_TValue_Equals_OLEVariants_BothUnAssigned;
    procedure Test_TValue_Equals_OLEVariants_VarArray;
    procedure Test_TValue_Equals_OLEVariants_VarArray_DifferentInstances;
    procedure Test_TValue_NotEquals_OLEVariants;
    procedure Test_TValue_NotEquals_OLEVariants_OneEmpty;
    procedure Test_TValue_NotEquals_OLEVariants_OneUnAssigned;
    procedure Test_TValue_NotEquals_OLEVariants_VarArray_DifferentLengths;
    procedure Test_TValue_NotEquals_OLEVariants_VarArray_DifferentContent;
  end;

implementation

uses
  SysUtils,
  Variants;


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

  CheckTrue(v1.Equals(v2));
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
  CheckTrue(v1.Equals(v2));
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
  CheckTrue(v1.Equals(v2));
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
  CheckTrue(v1.Equals(v2));
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
  CheckFalse(v1.Equals(v2));
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
  CheckFalse(v1.Equals(v2));
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
  CheckFalse(v1.Equals(v2));
end;


procedure TTestTValue.Test_TValue_Equals_Variants;
var
  var1,var2 : variant;
  v1, v2 : TValue;
begin
  var1 := 'hello';
  var2 := 'hello';
  v1 := TValue.FromVariant( var1 );
  v2 := TValue.FromVariant( var2 );
  CheckTrue(v1.Equals(v2));
end;

procedure TTestTValue.Test_TValue_Equals_Variants_BothEmpty;
var
  var1,var2 : variant;
  v1, v2 : TValue;
begin
  var1 := varEmpty;
  var2 := varEmpty;
  v1 := TValue.FromVariant( var1 );
  v2 := TValue.FromVariant( var2 );
  CheckTrue(v1.Equals(v2));
end;

procedure TTestTValue.Test_TValue_Equals_Variants_BothUnAssigned;
var
  var1,var2 : variant;
  v1, v2 : TValue;
begin
  var1 := UnAssigned;
  var2 := UnAssigned;
  v1 := TValue.FromVariant( var1 );
  v2 := TValue.FromVariant( var2 );
  CheckTrue(v1.Equals(v2));
end;

procedure TTestTValue.Test_TValue_Equals_Variants_VarArray;
var
  var1,var2 : variant;
  v1, v2 : TValue;
begin
  var1 := VarArrayCreate( [0,3], varVariant );
  var1[0] := '0';
  var1[1] := '1';
  var1[2] := '2';
  var2 := VarArrayCreate( [0,3], varVariant );
  var2[0] := '0';
  var2[1] := '1';
  var2[2] := '2';

  v1 := TValue.From<Variant>( var1 );
  v2 := TValue.From<Variant>( var2 );
  CheckTrue(v1.Equals(v2));
end;

procedure TTestTValue.Test_TValue_Equals_Variants_VarArray_DifferentInstances;
var
  var1,var2 : variant;
  v1, v2 : TValue;
begin
  var1 := VarArrayCreate( [0,3], varVariant );
  var1[0] := '0';
  var1[1] := '1';
  var1[2] := '2';
  var2 := VarArrayCreate( [0,3], varVariant );
  var2[0] := '0';
  var2[1] := '1';
  var2[2] := '2';

  v1 := TValue.From<Variant>( var1 );
  v2 := TValue.From<Variant>( var2 );
  CheckTrue(v1.Equals(v2));
end;

procedure TTestTValue.Test_TValue_NotEquals_Variants;
var
  var1,var2 : variant;
  v1, v2 : TValue;
begin
  var1 := 'hello';
  var2 := 'goodbye';
  v1 := TValue.FromVariant( var1 );
  v2 := TValue.FromVariant( var2 );
  CheckFalse(v1.Equals(v2));
end;

procedure TTestTValue.Test_TValue_NotEquals_Variants_OneEmpty;
var
  var1,var2 : variant;
  v1, v2 : TValue;
begin
  var1 := 'hello';
  var2 := varEmpty;
  v1 := TValue.FromVariant( var1 );
  v2 := TValue.FromVariant( var2 );
  CheckFalse(v1.Equals(v2));
end;

procedure TTestTValue.Test_TValue_NotEquals_Variants_OneUnAssigned;
var
  var1,var2 : variant;
  v1, v2 : TValue;
begin
  var1 := 'hello';
  var2 := UnAssigned;
  v1 := TValue.FromVariant( var1 );
  v2 := TValue.FromVariant( var2 );
  CheckFalse(v1.Equals(v2));
end;

procedure TTestTValue.Test_TValue_NotEquals_Variants_VarArray_DifferentLengths;
var
  var1,var2 : variant;
  v1, v2 : TValue;
begin
  var1 := VarArrayCreate( [0,3], varVariant );
  var1[0] := '0';
  var1[1] := '1';
  var1[2] := '2';
  var2 := VarArrayCreate( [0,2], varVariant );
  var2[0] := '0';
  var2[1] := '1';

  v1 := TValue.From<Variant>( var1 );
  v2 := TValue.From<Variant>( var2 );
  CheckFalse(v1.Equals(v2));
end;
procedure TTestTValue.Test_TValue_NotEquals_Variants_VarArray_DifferentContent;
var
  var1,var2 : variant;
  v1, v2 : TValue;
begin
  var1 := VarArrayCreate( [0,3], varVariant );
  var1[0] := 'a';
  var1[1] := 'b';
  var1[2] := 'c';
  var2 := VarArrayCreate( [0,3], varVariant );
  var2[0] := '0';
  var2[1] := '1';
  var2[2] := '2';

  v1 := TValue.From<Variant>( var1 );
  v2 := TValue.From<Variant>( var2 );
  CheckFalse(v1.Equals(v2));
end;

procedure TTestTValue.Test_TValue_Equals_Variants_VarArray_Of_Variant;
var
  var1,var2, inner1, inner2 : variant;
  v1, v2 : TValue;
begin
  var1   := VarArrayCreate( [0,3], varVariant );
  inner1 := VarArrayCreate( [0,3], varVariant );
  inner1[0] := '1';
  inner1[1] := '1';
  inner1[2] := '1';
  var1[0] := inner1;
  var1[1] := inner1;
  var1[2] := inner1;

  var2   := VarArrayCreate( [0,3], varVariant );
  inner2 := VarArrayCreate( [0,3], varVariant );
  inner2[0] := '1';
  inner2[1] := '1';
  inner2[2] := '1';
  var2[0] := inner2;
  var2[1] := inner2;
  var2[2] := inner2;

  v1 := TValue.From<Variant>( var1 );
  v2 := TValue.From<Variant>( var2 );
  CheckTrue(v1.Equals(v2));
end;

procedure TTestTValue.Test_TValue_NotEquals_Variants_VarArray_Of_Variant;
var
  var1,var2, inner1, inner2 : variant;
  v1, v2 : TValue;
begin
  var1   := VarArrayCreate( [0,3], varVariant );
  inner1 := VarArrayCreate( [0,3], varVariant );
  inner1[0] := '1';
  inner1[1] := '1';
  inner1[2] := '1';
  var1[0] := inner1;
  var1[1] := inner1;
  var1[2] := inner1;

  var2   := VarArrayCreate( [0,3], varVariant );
  inner2 := VarArrayCreate( [0,3], varVariant );
  inner2[0] := '22';
  inner2[1] := '22';
  inner2[2] := '22';
  var2[0] := inner2;
  var2[1] := inner2;
  var2[2] := inner2;

  v1 := TValue.From<Variant>( var1 );
  v2 := TValue.From<Variant>( var2 );
  CheckFalse(v1.Equals(v2));
end;


procedure TTestTValue.Test_TValue_Equals_OLEVariants;
var
  var1,var2 : OLEVariant;
  v1, v2 : TValue;
begin
  var1 := 'hello';
  var2 := 'hello';
  v1 := TValue.FromVariant( var1 );
  v2 := TValue.FromVariant( var2 );
  CheckTrue(v1.Equals(v2));
end;

procedure TTestTValue.Test_TValue_Equals_OLEVariants_BothEmpty;
var
  var1,var2 : OLEVariant;
  v1, v2 : TValue;
begin
  var1 := varEmpty;
  var2 := varEmpty;
  v1 := TValue.FromVariant( var1 );
  v2 := TValue.FromVariant( var2 );
  CheckTrue(v1.Equals(v2));
end;

procedure TTestTValue.Test_TValue_Equals_OLEVariants_BothUnAssigned;
var
  var1,var2 : OLEVariant;
  v1, v2 : TValue;
begin
  var1 := UnAssigned;
  var2 := UnAssigned;
  v1 := TValue.FromVariant( var1 );
  v2 := TValue.FromVariant( var2 );
  CheckTrue(v1.Equals(v2));
end;

procedure TTestTValue.Test_TValue_Equals_OLEVariants_VarArray;
var
  var1,var2 : OLEVariant;
  v1, v2 : TValue;
begin
  var1 := VarArrayCreate( [0,3], varVariant );
  var1[0] := '0';
  var1[1] := '1';
  var1[2] := '2';
  var2 := VarArrayCreate( [0,3], varVariant );
  var2[0] := '0';
  var2[1] := '1';
  var2[2] := '2';

  v1 := TValue.From<Variant>( var1 );
  v2 := TValue.From<Variant>( var2 );
  CheckTrue(v1.Equals(v2));
end;

procedure TTestTValue.Test_TValue_Equals_OLEVariants_VarArray_DifferentInstances;
var
  var1,var2 : OLEVariant;
  v1, v2 : TValue;
begin
  var1 := VarArrayCreate( [0,3], varVariant );
  var1[0] := '0';
  var1[1] := '1';
  var1[2] := '2';
  var2 := VarArrayCreate( [0,3], varVariant );
  var2[0] := '0';
  var2[1] := '1';
  var2[2] := '2';

  v1 := TValue.From<Variant>( var1 );
  v2 := TValue.From<Variant>( var2 );
  CheckTrue(v1.Equals(v2));
end;

procedure TTestTValue.Test_TValue_NotEquals_OLEVariants;
var
  var1,var2 : OLEVariant;
  v1, v2 : TValue;
begin
  var1 := 'hello';
  var2 := 'goodbye';
  v1 := TValue.FromVariant( var1 );
  v2 := TValue.FromVariant( var2 );
  CheckFalse(v1.Equals(v2));
end;

procedure TTestTValue.Test_TValue_NotEquals_OLEVariants_OneEmpty;
var
  var1,var2 : OLEVariant;
  v1, v2 : TValue;
begin
  var1 := 'hello';
  var2 := varEmpty;
  v1 := TValue.FromVariant( var1 );
  v2 := TValue.FromVariant( var2 );
  CheckFalse(v1.Equals(v2));
end;

procedure TTestTValue.Test_TValue_NotEquals_OLEVariants_OneUnAssigned;
var
  var1,var2 : OLEVariant;
  v1, v2 : TValue;
begin
  var1 := 'hello';
  var2 := UnAssigned;
  v1 := TValue.FromVariant( var1 );
  v2 := TValue.FromVariant( var2 );
  CheckFalse(v1.Equals(v2));
end;

procedure TTestTValue.Test_TValue_NotEquals_OLEVariants_VarArray_DifferentLengths;
var
  var1,var2 : OLEVariant;
  v1, v2 : TValue;
begin
  var1 := VarArrayCreate( [0,3], varVariant );
  var1[0] := '0';
  var1[1] := '1';
  var1[2] := '2';
  var2 := VarArrayCreate( [0,2], varVariant );
  var2[0] := '0';
  var2[1] := '1';

  v1 := TValue.From<Variant>( var1 );
  v2 := TValue.From<Variant>( var2 );
  CheckFalse(v1.Equals(v2));
end;
procedure TTestTValue.Test_TValue_NotEquals_OLEVariants_VarArray_DifferentContent;
var
  var1,var2 : OLEVariant;
  v1, v2 : TValue;
begin
  var1 := VarArrayCreate( [0,3], varVariant );
  var1[0] := 'a';
  var1[1] := 'b';
  var1[2] := 'c';
  var2 := VarArrayCreate( [0,3], varVariant );
  var2[0] := '0';
  var2[1] := '1';
  var2[2] := '2';

  v1 := TValue.From<Variant>( var1 );
  v2 := TValue.From<Variant>( var2 );
  CheckFalse(v1.Equals(v2));
end;


initialization
  TestFramework.RegisterTest(TTestTValue.Suite);

end.