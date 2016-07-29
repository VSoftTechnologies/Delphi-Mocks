unit Delphi.Mocks.Examples.Matchers;

interface

uses
  DUnitX.TestFramework;

type
  TObjectToTest = class
  private
    FPropertyToTest: Integer;
  public
    FieldToTest: Integer;

    property PropertyToTest: Integer read FPropertyToTest write FPropertyToTest;
  end;

  {$M+}
  IInterfaceToTest = interface
    ['{2AB032A9-ED5B-4FDC-904B-E3F1B2C78978}']
    function TakesTwoParams(const A: integer; const B: boolean) : integer;
    function TakesFourParams(const A: string; const B: boolean; const C: integer; const D: string) : integer;
  end;

  ILoan = interface
  end;

  TEnumerator = (Value1, Value2, Value3);

  IInterfaceToTestWithEnumerator = interface
    ['{45799970-833E-4419-A683-24E07AD742C2}']
    function AnyFuntionWithEnumerator(Enumerator: TEnumerator): Integer;
    function AnyFuntionWithInteger(Value: Integer): Integer;
  end;

  IInterfaceToTestWithObjects = interface
    ['{45799970-833E-4419-A683-24E07AD742C2}']
    function AnyFuntionWithObject(AObject: TObjectToTest): Integer;
  end;
  {$M-}

  {$M+}
  [TestFixture]
  TExample_MatchersTests = class
  published
    [Test]
    procedure Match_parameter_values;
    [Test]
    procedure Match_parameter_with_enumerators;
    [Test]
    procedure Match_parameter_with_diferent_values;
    [Test]
    procedure Match_parameter_with_objects;
  end;
  {$M-}

implementation

uses
  Rtti,
  SysUtils,
  TypInfo,
  Delphi.Mocks;


{ TExample_MatchersTests }


procedure TExample_MatchersTests.Match_parameter_values;
var
  mockCredit: TMock<IInterfaceToTest>;
begin
  mockCredit := TMock<IInterfaceToTest>.Create;

  mockCredit.Setup.WillReturn(6).When.TakesTwoParams(It(0).IsEqualTo<integer>(1), It(1).IsEqualTo<boolean>(true));
  mockCredit.Setup.WillReturn(12).When.TakesTwoParams(It(0).IsEqualTo<integer>(2), It(1).IsEqualTo<boolean>(true));
  mockCredit.Setup.WillReturn(8).When.TakesTwoParams(It(0).IsAny<integer>(), It(1).IsEqualTo<boolean>(false));

  mockCredit.Setup.WillReturn(1).When.TakesFourParams(It0.IsAny<string>(), It1.IsEqualTo<boolean>(false), It2.IsEqualTo<integer>(1), It3.IsEqualTo<string>('hello'));

  Assert.AreEqual(6, mockCredit.Instance.TakesTwoParams(1, true));
  Assert.AreEqual(12, mockCredit.Instance.TakesTwoParams(2, true));
  Assert.AreEqual(8, mockCredit.Instance.TakesTwoParams(1, false));

  Assert.AreEqual(1, mockCredit.Instance.TakesFourParams('asdfasfasdf', false, 1, 'hello'));
  Assert.AreEqual(1, mockCredit.Instance.TakesFourParams('asdfjkljklsdfjf', false, 1, 'hello'));
end;

{ TScorer }

procedure TExample_MatchersTests.Match_parameter_with_diferent_values;
var
  Mock: TMock<IInterfaceToTestWithEnumerator>;

begin
  Mock := TMock<IInterfaceToTestWithEnumerator>.Create;

  Mock.Setup.WillReturn(-1).When.AnyFuntionWithInteger(It0.IsEqualTo(0));
  Mock.Setup.WillReturn(10).When.AnyFuntionWithInteger(It0.IsEqualTo(1));
  Mock.Setup.WillReturn(20).When.AnyFuntionWithInteger(It0.IsEqualTo(2));
  Mock.Setup.WillReturn(30).When.AnyFuntionWithInteger(It0.IsEqualTo(3));

  Assert.AreEqual(-1, Mock.Instance.AnyFuntionWithInteger(0));
  Assert.AreEqual(10, Mock.Instance.AnyFuntionWithInteger(1));
  Assert.AreEqual(20, Mock.Instance.AnyFuntionWithInteger(2));
  Assert.AreEqual(30, Mock.Instance.AnyFuntionWithInteger(3));
end;

procedure TExample_MatchersTests.Match_parameter_with_enumerators;
var
  Mock: TMock<IInterfaceToTestWithEnumerator>;

begin
  Mock := TMock<IInterfaceToTestWithEnumerator>.Create;

  Mock.Setup.WillReturn(10).When.AnyFuntionWithEnumerator(It0.IsEqualTo(Value1));
  Mock.Setup.WillReturn(20).When.AnyFuntionWithEnumerator(It0.IsEqualTo(Value2));
  Mock.Setup.WillReturn(30).When.AnyFuntionWithEnumerator(It0.IsEqualTo(Value3));

  Assert.AreEqual(10, Mock.Instance.AnyFuntionWithEnumerator(Value1));
  Assert.AreEqual(20, Mock.Instance.AnyFuntionWithEnumerator(Value2));
  Assert.AreEqual(30, Mock.Instance.AnyFuntionWithEnumerator(Value3));
end;

procedure TExample_MatchersTests.Match_parameter_with_objects;
var
  Mock: TMock<IInterfaceToTestWithObjects>;

  Object1,
  Object2,
  Object3,
  ObjectToCompare1,
  ObjectToCompare2,
  ObjectToCompare3: TObjectToTest;

begin
  Mock := TMock<IInterfaceToTestWithObjects>.Create;
  Object1 := TObjectToTest.Create;
  Object1.FieldToTest := 10;
  Object1.PropertyToTest := 20;
  Object2 := TObjectToTest.Create;
  Object2.FieldToTest := 30;
  Object2.PropertyToTest := 40;
  Object3 := TObjectToTest.Create;
  Object3.FieldToTest := 50;
  Object3.PropertyToTest := 60;
  ObjectToCompare1 := TObjectToTest.Create;
  ObjectToCompare1.FieldToTest := 10;
  ObjectToCompare1.PropertyToTest := 20;
  ObjectToCompare2 := TObjectToTest.Create;
  ObjectToCompare2.FieldToTest := 30;
  ObjectToCompare2.PropertyToTest := 40;
  ObjectToCompare3 := TObjectToTest.Create;
  ObjectToCompare3.FieldToTest := 50;
  ObjectToCompare3.PropertyToTest := 60;

  Mock.Setup.WillReturn(10).When.AnyFuntionWithObject(It0.AreSameFieldsThat<TObjectToTest>(nil));
  Mock.Setup.WillReturn(20).When.AnyFuntionWithObject(It0.AreSameFieldsThat(Object1));
  Mock.Setup.WillReturn(30).When.AnyFuntionWithObject(It0.AreSamePropertiesThat(Object2));
  Mock.Setup.WillReturn(40).When.AnyFuntionWithObject(It0.AreSameFieldsAndPropertiedThat(Object3));

  Assert.AreEqual(10, Mock.Instance.AnyFuntionWithObject(nil));
  Assert.AreEqual(20, Mock.Instance.AnyFuntionWithObject(ObjectToCompare1));
  Assert.AreEqual(30, Mock.Instance.AnyFuntionWithObject(ObjectToCompare2));
  Assert.AreEqual(40, Mock.Instance.AnyFuntionWithObject(ObjectToCompare3));
end;

initialization
  TDUnitX.RegisterTestFixture(TExample_MatchersTests);

end.

