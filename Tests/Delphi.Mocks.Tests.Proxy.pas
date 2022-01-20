unit Delphi.Mocks.Tests.Proxy;

interface

uses
  Rtti,
  SysUtils,
  DUnitX.TestFramework,
  Delphi.Mocks;

type
  {$M+}
  [TestFixture]
  TTestMock = class
  published
    [Test, Ignore]
    procedure Expectation_Before_Verifies_To_True_When_Prior_Method_Called_Atleast_Once;
    [Test]
    procedure VerifyAllRespectsMessage;
    [Test]
    procedure ResetCallsWorks;
    [Test]
    procedure ClearExpectationsWorks;
  end;
  {$M-}

implementation

uses
  Delphi.Mocks.Helpers,
  Delphi.Mocks.Interfaces,
  Delphi.Mocks.MethodData,
  classes;

type
  TSimpleClass = class
  public
    procedure DoTest; virtual; abstract;
  end;

{ TTestMock }

procedure TTestMock.ClearExpectationsWorks;
var
  m: TMock<TSimpleClass>;
begin
  m := TMock<TSimpleClass>.Create;
  m.Setup.Expect.Once.When.DoTest;
  Assert.WillRaise(procedure begin m.VerifyAll() end, EMockVerificationException);
  m.Setup.Expect.Clear;
  Assert.WillNotRaise(procedure begin m.VerifyAll() end);
end;

procedure TTestMock.Expectation_Before_Verifies_To_True_When_Prior_Method_Called_Atleast_Once;
begin
  Assert.NotImplemented;
end;

procedure TTestMock.ResetCallsWorks;
var
  m: TMock<TSimpleClass>;
begin
  m := TMock<TSimpleClass>.Create;
  m.Setup.Expect.Once.When.DoTest;
  m.Instance.DoTest;
  Assert.WillNotRaise(procedure begin m.VerifyAll() end);
  m.ResetCalls;
  Assert.WillRaise(procedure begin m.VerifyAll() end, EMockVerificationException);
end;

procedure TTestMock.VerifyAllRespectsMessage;
var
  m: TMock<TSimpleClass>;
begin
  m := TMock<TSimpleClass>.Create;
  m.Setup.Expect.Once.When.DoTest;
  try
    m.VerifyAll('test');
  except
    on E: EMockVerificationException do begin
      Assert.IsTrue(E.Message.StartsWith('test'));
      Exit;
    end;
  end;
  Assert.Fail('Verifyall does not respect message');
end;

initialization
  TDUnitX.RegisterTestFixture(TTestMock);
end.
