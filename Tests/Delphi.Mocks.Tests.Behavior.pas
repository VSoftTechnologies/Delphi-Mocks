unit Delphi.Mocks.Tests.Behavior;

interface

uses
  SysUtils,
  TestFramework,
  Rtti,
  Delphi.Mocks,
  Delphi.Mocks.InterfaceProxy;

type
  ETestBehaviourException = class(Exception);

  TTestBehaviors = class(TTestCase)
  private
    FContext : TRttiContext;
  protected
    procedure SetUp; override;
  published
    procedure Test_WillReturnBehavior_Match;
    procedure Test_WillReturnBehavior_NoMatch;
    procedure Test_WillReturnBehavior_Default;
    procedure Test_WillExecute;

    // WillRaise-Execute tests
    procedure CreateWillRaise_Execute__Raises_Exception_Of_Our_Choice;
    procedure CreateWillRaise_Execute__Raises_Exception_Message_Of_Our_Choice;
    procedure CreateWillRaise_Execute__Raises_No_Exception_If_Passed_Nil_For_Exception_Class;
    procedure CreateWillRaise_Execute__Raises_Exception_Of_Our_Choice_With_Default_Message;
  end;

implementation

uses
  Delphi.Mocks.Helpers,
  Delphi.Mocks.Interfaces,
  Delphi.Mocks.Behavior,
  classes;

{ TTestBehaviors }


procedure TTestBehaviors.SetUp;
begin
  inherited;
  FContext := TRttiContext.Create;
end;

procedure TTestBehaviors.Test_WillExecute;
var
  behavior : IBehavior;
  returnValue : TValue;
  args : TArray<TValue>;
  rType : TRttiType;
begin
  SetLength(args,1);
  args[0] := 999;
  rType := FContext.GetType(TypeInfo(string));

  behavior := TBehavior.CreateWillExecute(
    function (const args : TArray<TValue>; const returnType : TRttiType) : TValue
    begin
      result := 'hello world';
    end
    );

  returnValue := behavior.Execute(args,rType);

  CheckTrue(SameText(returnValue.AsString,'hello world'));
end;

procedure TTestBehaviors.Test_WillReturnBehavior_Default;
var
  behavior : IBehavior;
  args : TArray<TValue>;
  returnValue : TValue;
  rType : TRttiType;
begin
  returnValue := 123;
  behavior := TBehavior.CreateReturnDefault(returnValue);
  SetLength(args,3);
  args[0] := 1;
  args[1] := 2;
  args[2] := 3;
  rType := FContext.GetType(TypeInfo(Int64));
  returnValue := behavior.Execute(args,rType);
  CheckTrue(returnValue.AsInt64 = 123);
end;

procedure TTestBehaviors.Test_WillReturnBehavior_Match;
var
  behavior : IBehavior;
  args : TArray<TValue>;
  returnValue : TValue;
begin
  SetLength(args,3);
  args[0] := 1;
  args[1] := 2;
  args[2] :=  'hello';
  behavior := TBehavior.CreateWillReturnWhen(args,returnValue);
  args[0] := 1;
  args[1] := 2;
  args[2] :=  'hello';
  CheckTrue(behavior.Match(args));
end;

procedure TTestBehaviors.Test_WillReturnBehavior_NoMatch;
var
  behavior : IBehavior;
  args : TArray<TValue>;
  returnValue : TValue;
begin
  SetLength(args,3);
  args[0] := 1;
  args[1] := 2;
  args[2] := 'hello';
  behavior := TBehavior.CreateWillReturnWhen(args,returnValue);
  args[0] := 1;
  args[1] := 2;
  args[2] :=  'hello world';
  CheckFalse(behavior.Match(args));
end;

procedure TTestBehaviors.CreateWillRaise_Execute__Raises_Exception_Message_Of_Our_Choice;
var
  behavior: IBehavior;
const
  EXCEPTION_STRING = 'Exception!';
begin
  behavior := TBehavior.CreateWillRaise(ETestBehaviourException, EXCEPTION_STRING);

  StartExpectingException(ETestBehaviourException);

  //Passing nils as we don't care about these values for the exception
  behavior.Execute(nil, nil);

  StopExpectingException('');
end;

procedure TTestBehaviors.CreateWillRaise_Execute__Raises_Exception_Of_Our_Choice;
var
  behavior: IBehavior;
begin
  behavior := TBehavior.CreateWillRaise(ETestBehaviourException, '');

  StartExpectingException(ETestBehaviourException);

  behavior.Execute(nil, nil);

  StopExpectingException;
end;


procedure TTestBehaviors.CreateWillRaise_Execute__Raises_Exception_Of_Our_Choice_With_Default_Message;
var
  behavior: IBehavior;
const
  EXCEPTION_STRING = 'raised by mock';
begin
  behavior := TBehavior.CreateWillRaise(ETestBehaviourException, '');

  StartExpectingException(ETestBehaviourException);

  //Passing nils as we don't care about these values for the exception
  behavior.Execute(nil, nil);

  StopExpectingException(EXCEPTION_STRING);
end;

procedure TTestBehaviors.CreateWillRaise_Execute__Raises_No_Exception_If_Passed_Nil_For_Exception_Class;
var
  behavior: IBehavior;
begin
  behavior := TBehavior.CreateWillRaise(nil, '');

  //No exception coverage. Therefore we shouldn't get an exception
  behavior.Execute(nil, nil);

  //If we have gotten here no exception was recieved.
  Check(True);
end;

initialization
  TestFramework.RegisterTest(TTestBehaviors.Suite);
end.
