unit Delphi.Mocks.Tests.ObjectProxy;

interface

uses
  Rtti,
  SysUtils,
  DUnitX.TestFramework,
  Delphi.Mocks;

type
  TSimpleObject = class(TObject)
  private
    FCreateCalled: Cardinal;
  public
    constructor Create;
    property CreateCalled: Cardinal read FCreateCalled;
  end;

  TMultipleConstructor = class
  private
    FCreateCalled: Cardinal;
  public
    constructor Create(Dummy: Integer);overload;
    constructor Create;overload;
    property CreateCalled: Cardinal read FCreateCalled;
  end;

  TCommand = class
  private
    FVirtualMethodCalled: Boolean;
  public
    constructor Create;

    procedure Execute;virtual;abstract;
    procedure Run(value: Integer);virtual;abstract;
    procedure TestVarParam(var msg : string);virtual;abstract;
    procedure TestOutParam(out msg : string);virtual;abstract;
    function VirtualMethod: Integer; overload; virtual;
    function VirtualMethod(const Arg: String): Integer; overload; virtual;
    function NonVirtualMethod: Integer;

    property VirtualMethodCalled: Boolean read FVirtualMethodCalled;
  end;

  {$M+}
  [TestFixture]
  TTestObjectProxy = class
  published
    [Test]
    procedure ProxyObject_Calls_The_Create_Of_The_Object_Type;
    [Test]
    procedure ProxyObject_MultipleConstructor;
    [Test]
    procedure MockWithArgProcedureUsingOnce;
    [Test]
    procedure MockNoArgProcedureUsingOnce;
    [Test]
    procedure MockNoArgProcedureUsingOnceWhen;
    [Test]
    procedure MockNoArgProcedureUsingNeverWhen;
    [Test]
    procedure MockNoArgProcedureUsingAtLeastOnceWhen;
    [Test]
    procedure MockNoArgProcedureUsingAtLeastWhen;
    [Test]
    procedure MockNoArgProcedureUsingAtMostBetweenWhen;
    [Test]
    procedure MockNoArgProcedureUsingExactlyWhen;
    [Test]
    procedure TestOutParam;
    [Test]
    procedure TestVarParam;
    [Test]
    procedure MockNoBehaviorDefined;
    [Test]
    procedure WillRaiseMockNonVirtualMethod;
    [Test]
    procedure VirtualMethodNotCalledDuringMockSetup;
    [Test]
    procedure VirtualMethodCalledIfNoBehaviorDefined;
    [Test]
    procedure VirtualMethodNotCalledIfBehaviorMatches;
    [Test]
    procedure VirtualMethodCalledIfBehaviorNotMatches;
  end;
  {$M-}

implementation

uses
  Delphi.Mocks.ObjectProxy;

const
  G_CREATE_CALLED_UNIQUE_ID = 909090;

{ TTestObjectProxy }

procedure TTestObjectProxy.ProxyObject_Calls_The_Create_Of_The_Object_Type;
var
  objectProxy: IProxy<TSimpleObject>;
begin
  objectProxy := TObjectProxy<TSimpleObject>.Create(function: TSimpleObject
                                                    begin 
                                                      result := TSimpleObject.Create; 
                                                    end);

  Assert.AreEqual(objectProxy.Proxy.CreateCalled, G_CREATE_CALLED_UNIQUE_ID);
end;

procedure TTestObjectProxy.ProxyObject_MultipleConstructor;
var
  objectProxy: IProxy<TMultipleConstructor>;
begin
  objectProxy := TObjectProxy<TMultipleConstructor>.Create(function: TMultipleConstructor
                                                           begin 
                                                             result := TMultipleConstructor.Create; 
                                                           end);

  Assert.AreEqual(objectProxy.Proxy.CreateCalled, G_CREATE_CALLED_UNIQUE_ID);
end;

procedure TTestObjectProxy.TestOutParam;
const
  RETURN_MSG = 'hello Delphi Mocks! - With out Param';
var
  mock : TMock<TCommand>;
  msg: string;
begin
  mock := TMock<TCommand>.Create;

  mock.Setup.WillExecute(
    function (const args : TArray<TValue>; const ReturnType : TRttiType) : TValue
    begin
      Assert.AreEqual(2, Length(Args), 'Args Length');
      //Argument Zero is Self Instance
      args[1] := RETURN_MSG;
    end
    ).When.TestOutParam(msg);

  msg := EmptyStr;
  mock.Instance.TestOutParam(msg);

  Assert.AreEqual(RETURN_MSG, msg);

  mock.Verify;
  Assert.Pass;
end;

procedure TTestObjectProxy.TestVarParam;
const
  RETURN_MSG = 'hello Delphi Mocks!';
var
  mock : TMock<TCommand>;
  msg: string;
begin
  mock := TMock<TCommand>.Create;

  mock.Setup.WillExecute(
    function (const args : TArray<TValue>; const ReturnType : TRttiType) : TValue
    begin
      Assert.AreEqual(2, Length(Args), 'Args Length');
      //Argument Zero is Self Instance
      args[1] := RETURN_MSG;
    end
    ).When.TestVarParam(msg);

  msg := EmptyStr;
  mock.Instance.TestVarParam(msg);

  Assert.AreEqual(RETURN_MSG, msg);

  mock.Verify;
  Assert.Pass;
end;

procedure TTestObjectProxy.VirtualMethodCalledIfBehaviorNotMatches;
var
  mock : TMock<TCommand>;
begin
  mock := TMock<TCommand>.Create;
  mock.Setup.WillReturn(2).When.VirtualMethod('test');

  Assert.AreEqual(1, mock.Instance.VirtualMethod('test2'));
  Assert.IsTrue(mock.Instance.VirtualMethodCalled);
end;

procedure TTestObjectProxy.VirtualMethodCalledIfNoBehaviorDefined;
var
  mock : TMock<TCommand>;
begin
  mock := TMock<TCommand>.Create;

  Assert.AreEqual(1, mock.Instance.VirtualMethod('test'));
  Assert.IsTrue(mock.Instance.VirtualMethodCalled);
end;

procedure TTestObjectProxy.VirtualMethodNotCalledDuringMockSetup;
var
  mock : TMock<TCommand>;
begin
  mock := TMock<TCommand>.Create;
  mock.Setup.Expect.AtLeastOnce.When.VirtualMethod;
  mock.Setup.WillReturn(1).When.VirtualMethod;
  mock.Setup.WillReturnDefault('VirtualMethod', 1);

  Assert.IsFalse(mock.Instance.VirtualMethodCalled);
end;

procedure TTestObjectProxy.VirtualMethodNotCalledIfBehaviorMatches;
var
  mock : TMock<TCommand>;
begin
  mock := TMock<TCommand>.Create;
  mock.Setup.WillReturn(2).When.VirtualMethod('test');
  Assert.AreEqual(2, mock.Instance.VirtualMethod('test'));

  Assert.IsFalse(mock.Instance.VirtualMethodCalled);
end;

procedure TTestObjectProxy.MockNoArgProcedureUsingAtLeastOnceWhen;
var
  mock : TMock<TCommand>;
begin
  mock := TMock<TCommand>.Create;
  mock.Setup.Expect.AtLeastOnce.When.Execute;
  mock.Instance.Execute;
  mock.Instance.Execute;
  mock.Verify;
  Assert.Pass;
end;

procedure TTestObjectProxy.MockNoArgProcedureUsingAtLeastWhen;
var
  mock : TMock<TCommand>;
begin
  mock := TMock<TCommand>.Create;
  mock.Setup.Expect.AtLeast(3).When.Execute;
  mock.Instance.Execute;
  mock.Instance.Execute;
  mock.Instance.Execute;
  mock.Verify;
  Assert.Pass;
end;

procedure TTestObjectProxy.MockNoArgProcedureUsingAtMostBetweenWhen;
var
  mock : TMock<TCommand>;
begin
  mock := TMock<TCommand>.Create;
  mock.Setup.Expect.AtMost(2).When.Execute;
  mock.Instance.Execute;
  mock.Instance.Execute;
  mock.Verify;
  Assert.Pass;
end;

procedure TTestObjectProxy.MockNoArgProcedureUsingExactlyWhen;
var
  mock : TMock<TCommand>;
begin
  mock := TMock<TCommand>.Create;
  mock.Setup.Expect.Exactly(2).When.Execute;
  mock.Instance.Execute;
  mock.Instance.Execute;
  mock.Verify;
  Assert.Pass;
end;

procedure TTestObjectProxy.MockNoArgProcedureUsingNeverWhen;
var
  mock : TMock<TCommand>;
begin
  mock := TMock<TCommand>.Create;
  mock.Setup.Expect.Never.When.Execute;
  mock.Instance.Execute;
  Assert.WillRaiseAny(procedure
    begin
      mock.Verify;
    end);
end;

procedure TTestObjectProxy.MockNoArgProcedureUsingOnce;
var
  mock : TMock<TCommand>;
begin
  mock := TMock<TCommand>.Create;
  mock.Setup.Expect.Once('Execute');
  mock.Instance.Execute;
  Assert.Pass;
end;

procedure TTestObjectProxy.MockNoArgProcedureUsingOnceWhen;
var
  mock : TMock<TCommand>;
begin
  mock := TMock<TCommand>.Create;
  mock.Setup.Expect.Once.When.Execute;
  mock.Instance.Execute;
  mock.Verify;
  Assert.Pass;
end;

procedure TTestObjectProxy.MockNoBehaviorDefined;
var
  mock : TMock<TCommand>;
begin
  mock := TMock<TCommand>.Create;
  mock.Setup.Expect.Once.When.VirtualMethod;
  Assert.AreEqual(1, mock.Instance.VirtualMethod);
  mock.Verify;
end;

procedure TTestObjectProxy.WillRaiseMockNonVirtualMethod;
var
  mock : TMock<TCommand>;
begin
  mock := TMock<TCommand>.Create;
  Assert.WillRaise(procedure begin mock.Setup.Expect.Once.When.NonVirtualMethod; end);
  Assert.WillRaise(procedure begin mock.Setup.WillReturn(2).When.NonVirtualMethod; end);
end;

procedure TTestObjectProxy.MockWithArgProcedureUsingOnce;
var
  mock : TMock<TCommand>;
begin
  mock := TMock<TCommand>.Create;
  mock.Setup.Expect.Once.When.Run(3);
  mock.Instance.Run(3);
  mock.Verify;
  Assert.Pass;
end;

{ TSimpleObject }

constructor TSimpleObject.Create;
begin
  FCreateCalled := G_CREATE_CALLED_UNIQUE_ID;
end;

{ TMultipleConstructor }

constructor TMultipleConstructor.Create(Dummy: Integer);
begin

end;

constructor TMultipleConstructor.Create;
begin
  FCreateCalled := G_CREATE_CALLED_UNIQUE_ID;
end;


{ TCommand }

constructor TCommand.Create;
begin
  FVirtualMethodCalled := False;
end;

function TCommand.NonVirtualMethod: Integer;
begin
  Result := 1;
end;

function TCommand.VirtualMethod(const Arg: String): Integer;
begin
  FVirtualMethodCalled := True;
  Result := 1;
end;

function TCommand.VirtualMethod: Integer;
begin
  FVirtualMethodCalled := True;
  Result := 1;
end;

initialization
  TDUnitX.RegisterTestFixture(TTestObjectProxy);

end.
