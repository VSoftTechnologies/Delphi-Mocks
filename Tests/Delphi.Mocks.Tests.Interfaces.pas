unit Delphi.Mocks.Tests.Interfaces;

interface

uses
  DUnitX.TestFramework,
  Delphi.Mocks;

type
  {$M+}
  IA = interface
    ['{551FA8FF-E038-49BB-BCBC-E1F82544CA97}']
    procedure Method1;
  end;

  IB = interface
    ['{956B7421-7F45-4E22-BD5F-E5898EC186F4}']
    procedure Method2;
  end;

  IC = interface
    ['{4B52C6FE-43EE-44B5-AC01-B4371944322D}']
    procedure Method3;
  end;

  ID = interface
    ['{E222BB8F-6E89-4E54-B2DC-E54C5F280E86}']
    procedure Method4;
  end;
  {$M-}


  {$M+}
  ISafeCallInterface = interface
    ['{50960499-4347-421A-B28B-3C05AE9CB351}']
    function DoSomething(const value : WideString) : integer;safecall;
    function Foo2(const value : WideString): string; safecall;
    procedure Foo; safecall;
  end;

  ISimpleInterface = interface
    ['{35DA1428-5183-43FE-BEE8-1010C75EF4D6}']
    procedure SimpleProcedure(const value: widestring);
  end;

  IVariant = interface
    procedure VariantParam(Value: Variant);
  end;
  {$M-}

  {$M+}
  [TestFixture]
  TSafeCallTest = class
  published
    [Test]
    procedure CanMockSafecallFunction;
    [Test, Ignore]
    procedure CanMockSafecallProc;
    [Test, Ignore]
    procedure CanMockSimpleProcedureCall;
    [Test]
    procedure CanMockProcedureWithVariantParam;
  end;
  {$M-}

  {$M+}
  TInterfaceTests = class
    published
    [Test]
    procedure Cast_Mock_As_Interfaces_It_Implements;
    [Test]
    procedure Cast_MockInstance_As_Interfaces_It_Implements;
    [Test]
    procedure MockInstance_As_Interfaces_It_Implements;
  end;
  {$M-}

implementation
uses
  Rtti,
  System.Variants;


{ TValueTests }

procedure TSafeCallTest.CanMockProcedureWithVariantParam;
var
  mock : TMock<IVariant>;
begin
  mock := TMock<IVariant>.Create;

  mock.Setup.Expect.Once.When.VariantParam(Null);

  mock.Instance.VariantParam(Null);
  mock.Verify;
  Assert.Pass;
end;

procedure TSafeCallTest.CanMockSafecallFunction;
var
  mock : TMock<ISafeCallInterface>;
  value: Integer;
begin
  mock := TMock<ISafeCallInterface>.Create;
  mock.Setup.WillReturn(123).When.DoSomething('hello');

  value := mock.Instance.DoSomething('hello');

  Assert.AreEqual(123, value);
end;

procedure TSafeCallTest.CanMockSafecallProc;
var
  mock : TMock<ISafeCallInterface>;
begin
  mock := TMock<ISafeCallInterface>.Create;

  Assert.NotImplemented;
end;


procedure TSafeCallTest.CanMockSimpleProcedureCall;
var
  mock : TMock<ISimpleInterface>;
begin
  mock := TMock<ISimpleInterface>.Create;

  mock.Instance.SimpleProcedure('hello');

  Assert.NotImplemented;
end;

procedure TInterfaceTests.Cast_Mock_As_Interfaces_It_Implements;
var
  mock : TMock<IA>;
  a : IA;
  b : IB;
  c : IC;
  d : ID;
  i : IInterface;
begin
  mock := TMock<IA>.Create;
  mock.Setup.Expect.Exactly(2).When.Method1;

  mock.Implement<IB>;
  mock.Setup<IB>.Expect.Exactly(2).When.Method2;

  mock.Implement<IC>;
  mock.Setup<IC>.Expect.Exactly(2).When.Method3;

  mock.Implement<ID>;
  mock.Setup<ID>.Expect.Exactly(2).When.Method4;

  //Transfer through mock references.
  a := mock;
  a.Method1;

  b := a as IB;
  b.Method2;

  c := a as IC;
  c.Method3;

  d := a as ID;
  d.Method4;

  i := a as IInterface;


  //Transfer through interfaces references.
  a := mock;
  a.Method1;

  b := a as IB;
  b.Method2;

  c := b as IC;
  c.Method3;

  d := c as ID;
  d.Method4;

  i := d as IInterface;

  mock.VerifyAll();
  Assert.Pass();
end;

procedure TInterfaceTests.MockInstance_As_Interfaces_It_Implements;
var
  mock : TMock<IA>;
  a : IA;
  b : IB;
  c : IC;
  d : ID;
  i : IInterface;
begin
  mock := TMock<IA>.Create;
  mock.Setup.Expect.Exactly(1).When.Method1;

  mock.Implement<IB>;
  mock.Setup<IB>.Expect.Exactly(1).When.Method2;

  mock.Implement<IC>;
  mock.Setup<IC>.Expect.Exactly(1).When.Method3;

  mock.Implement<ID>;
  mock.Setup<ID>.Expect.Exactly(1).When.Method4;

  //Transfer through mock instance.
  a := mock.Instance;
  a.Method1;

  b := mock.Instance<IB>;
  b.Method2;

  c := mock.Instance<IC>;
  c.Method3;

  d := mock.Instance<ID>;
  d.Method4;

  i := a as IInterface;

  mock.VerifyAll();
  Assert.Pass();
end;

procedure TInterfaceTests.Cast_MockInstance_As_Interfaces_It_Implements;
var
  mock : TMock<IA>;
  a : IA;
  b : IB;
  c : IC;
  d : ID;
  i : IInterface;
begin
  mock := TMock<IA>.Create;
  mock.Setup.Expect.Exactly(2).When.Method1;

  mock.Implement<IB>;
  mock.Setup<IB>.Expect.Exactly(2).When.Method2;

  mock.Implement<IC>;
  mock.Setup<IC>.Expect.Exactly(2).When.Method3;

  mock.Implement<ID>;
  mock.Setup<ID>.Expect.Exactly(2).When.Method4;

  //Transfer through mock instance.
  a := mock.Instance;
  a.Method1;

  b := a as IB;
  b.Method2;

  c := a as IC;
  c.Method3;

  d := a as ID;
  d.Method4;

  i := a as IInterface;

  a := mock.Instance;
  a.Method1;

  b := a as IB;
  b.Method2;

  c := b as IC;
  c.Method3;

  d := c as ID;
  d.Method4;

  i := d as IInterface;

  mock.VerifyAll();
  Assert.Pass();
end;

initialization
  TDUnitX.RegisterTestFixture(TSafeCallTest);
  TDUnitX.RegisterTestFixture(TInterfaceTests);

end.
