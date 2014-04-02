unit Delphi.Mocks.Tests.ObjectProxy;

interface

uses
  Rtti,
  SysUtils,
  TestFramework,
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
  public
    procedure Execute;virtual;abstract;
    procedure Run(value: Integer);virtual;abstract;
    procedure TestVarParam(var msg : string);virtual;abstract;
    procedure TestOutParam(out msg : string);virtual;abstract;
  end;

  TTestObjectProxy = class(TTestCase)
  published
    procedure ProxyObject_Calls_The_Create_Of_The_Object_Type;
    procedure ProxyObject_MultipleConstructor;

    procedure MockWithArgProcedureUsingOnce;
    procedure MockNoArgProcedureUsingOnce;
    procedure MockNoArgProcedureUsingOnceWhen;
    procedure MockNoArgProcedureUsingNeverWhen;
    procedure MockNoArgProcedureUsingAtLeastOnceWhen;
    procedure MockNoArgProcedureUsingAtLeastWhen;
    procedure MockNoArgProcedureUsingAtMostBetweenWhen;
    procedure MockNoArgProcedureUsingExactlyWhen;
    procedure TestOuParam;
    procedure TestVarParam;
  end;

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
  objectProxy := TObjectProxy<TSimpleObject>.Create;

  CheckEquals(objectProxy.Proxy.CreateCalled, G_CREATE_CALLED_UNIQUE_ID);
end;

procedure TTestObjectProxy.ProxyObject_MultipleConstructor;
var
  objectProxy: IProxy<TMultipleConstructor>;
begin
  objectProxy := TObjectProxy<TMultipleConstructor>.Create;

  CheckEquals(objectProxy.Proxy.CreateCalled, G_CREATE_CALLED_UNIQUE_ID);
end;

procedure TTestObjectProxy.TestOuParam;
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
      CheckEquals(2, Length(Args), 'Args Length');
      //Argument Zero is Self Instance
      args[1] := RETURN_MSG;
    end
    ).When.TestOutParam(msg);

  msg := EmptyStr;
  mock.Instance.TestOutParam(msg);

  CheckEquals(RETURN_MSG, msg);

  mock.Verify;
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
      CheckEquals(2, Length(Args), 'Args Length');
      //Argument Zero is Self Instance
      args[1] := RETURN_MSG;
    end
    ).When.TestVarParam(msg);

  msg := EmptyStr;
  mock.Instance.TestVarParam(msg);

  CheckEquals(RETURN_MSG, msg);

  mock.Verify;
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
end;

procedure TTestObjectProxy.MockNoArgProcedureUsingNeverWhen;
var
  mock : TMock<TCommand>;
begin
  ExpectedException := EMockVerificationException;

  mock := TMock<TCommand>.Create;
  mock.Setup.Expect.Never.When.Execute;

  mock.Instance.Execute;

  mock.Verify;
end;

procedure TTestObjectProxy.MockNoArgProcedureUsingOnce;
var
  mock : TMock<TCommand>;
begin
  mock := TMock<TCommand>.Create;
  mock.Setup.Expect.Once('Execute');
  mock.Instance.Execute;
  mock.Verify;
end;

procedure TTestObjectProxy.MockNoArgProcedureUsingOnceWhen;
var
  mock : TMock<TCommand>;
begin
  mock := TMock<TCommand>.Create;
  mock.Setup.Expect.Once.When.Execute;
  mock.Instance.Execute;
  mock.Verify;
end;

procedure TTestObjectProxy.MockWithArgProcedureUsingOnce;
var
  mock : TMock<TCommand>;
begin
  mock := TMock<TCommand>.Create;
  mock.Setup.Expect.Once.When.Run(3);
  mock.Instance.Run(3);
  mock.Verify;
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

initialization
  TestFramework.RegisterTest(TTestObjectProxy.Suite);
end.
