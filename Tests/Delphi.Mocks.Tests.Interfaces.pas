unit Delphi.Mocks.Tests.Interfaces;

interface

uses
  TestFramework,
  Delphi.Mocks;

type
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

  TSafeCallTest = class(TTestcase)
  published
    procedure CanMockSafecallFunction;
    procedure CanMockSafecallProc;
    procedure CanMockSimpleProcedureCall;
    procedure CanMockProcedureWithVariantParam;
  end;


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
end;

procedure TSafeCallTest.CanMockSafecallFunction;
var
  mock : TMock<ISafeCallInterface>;

begin
  mock := TMock<ISafeCallInterface>.Create;
  mock.Setup.WillReturn(123).When.DoSomething('hello');

  CheckEquals(123, mock.Instance.DoSomething('hello'));
end;

procedure TSafeCallTest.CanMockSafecallProc;
var
  mock : TMock<ISafeCallInterface>;
begin
  mock := TMock<ISafeCallInterface>.Create;

  //  mock.Setup.WillExecute(
  //    function (const args : TArray<TValue>; const ReturnType : TRttiType) : TValue
  //    begin
  //       Result := TValue.Empty;
  //    end
  //  ).When.Foo('hello');

  // mock.Instance.Foo;

  // mock.Free;
end;


procedure TSafeCallTest.CanMockSimpleProcedureCall;
var
  mock : TMock<ISimpleInterface>;
begin
  mock := TMock<ISimpleInterface>.Create;

  // mock.Setup.Expect.Exactly(1).When.SimpleProcedure('');

  //  mock.Setup.WillExecute(
  //    function (const args : TArray<TValue>; const ReturnType : TRttiType) : TValue
  //    begin
  //      Result := TValue.Empty;
  //    end
  //  ).When.SimpleProcedure('hello');

  mock.Instance.SimpleProcedure('hello');
end;

initialization
  TestFramework.RegisterTest(TSafeCallTest.Suite);

end.
