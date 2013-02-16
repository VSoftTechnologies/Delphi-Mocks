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
    procedure Foo(const value : WideString);safecall;
  end;
  {$M-}

  TSafeCallTest = class(TTestcase)
  published
    procedure CanMockSafecallFunction;
    procedure CanMockSafecallProc;


  end;


implementation
uses
  Rtti;


{ TValueTests }

procedure TSafeCallTest.CanMockSafecallFunction;
var
  mock : TMock<ISafeCallInterface>;

begin
  mock := TMock<ISafeCallInterface>.Create;
  mock.Setup.WillReturn(123).When.DoSomething('hello');

  mock.Instance.DoSomething('hello');
end;



procedure TSafeCallTest.CanMockSafecallProc;
var
  mock : TMock<ISafeCallInterface>;
begin
  mock := TMock<ISafeCallInterface>.Create;

   { mock.Setup.WillExecute( function (const args : TArray<TValue>; const ReturnType : TRttiType) : TValue
                            begin
                              //Note - args[0] is the Self interface reference for the anon method, our first arg is [1]
                              result := 'The result is ' + args[1].AsString;
                            end
    ).When.Foo('hello'); }

    mock.Instance.Foo('hello');
  mock.Free;

end;

initialization
  TestFramework.RegisterTest(TSafeCallTest.Suite);

end.
