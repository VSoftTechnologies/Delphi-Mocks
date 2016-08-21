unit Delphi.Mocks.Examples.Matchers;

interface

//uses
  //DUnitX.TestFramework;

type
  {$M+}
  IInterfaceToTest = interface
    ['{2AB032A9-ED5B-4FDC-904B-E3F1B2C78978}']
    function TakesTwoParams(const A: integer; const B: boolean) : integer;
    function TakesFourParams(const A: string; const B: boolean; const C: integer; const D: string) : integer;
  end;

  ILoan = interface

  end;
  {$M-}

  {$M+}
  TExample_MatchersTests = class
  published
    procedure Match_parameter_values;
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

  {Assert.AreEqual(6, mockCredit.Instance.TakesTwoParams(1, true));
  Assert.AreEqual(12, mockCredit.Instance.TakesTwoParams(2, true));
  Assert.AreEqual(8, mockCredit.Instance.TakesTwoParams(1, false));

  Assert.AreEqual(1, mockCredit.Instance.TakesFourParams('asdfasfasdf', false, 1, 'hello'));
  Assert.AreEqual(1, mockCredit.Instance.TakesFourParams('asdfjkljklsdfjf', false, 1, 'hello')); }
end;

{ TScorer }

initialization
  //TDUnitX.RegisterTestFixture(TExample_MatchersTests);

end.
