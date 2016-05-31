unit Delphi.Mocks.Tests.Behavior;

interface

uses
  SysUtils,
  DUnitX.TestFramework,
  Rtti,
  Delphi.Mocks,
  Delphi.Mocks.ParamMatcher;

type
  ETestBehaviourException = class(Exception);

  {$M+}
  [TestFixture]
  TTestBehaviors = class
  private
    FContext : TRttiContext;
    FMatchers : TArray<IMatcher>;
  protected
    procedure SetUp;
  published
    procedure Test_WillReturnBehavior_Match;
    procedure Test_WillReturnBehavior_NoMatch;
    procedure Test_WillReturnBehavior_Default;
    procedure Test_WillExecute;

    // WillRaise-Execute tests
    procedure CreateWillRaise_Execute_Raises_Exception_Of_Our_Choice;
    procedure CreateWillRaise_Execute_Raises_Exception_Message_Of_Our_Choice;
    procedure CreateWillRaise_Execute_Raises_No_Exception_If_Passed_Nil_For_Exception_Class;
    procedure CreateWillRaise_Execute_Raises_Exception_Of_Our_Choice_With_Default_Message;

    // WillRaiseWhen-Exexute tests
    procedure CreateWillRaiseWhen_Execute_Raises_Exception_Of_Our_Choice;
    procedure CreateWillRaiseWhen_Execute_Raises_Exception_Message_Of_Our_Choice;
    procedure CreateWillRaiseWhen_Execute_Raises_No_Exception_If_Passed_Nil_For_Exception_Class;
    procedure CreateWillRaiseWhen_Execute_Raises_Exception_Of_Our_Choice_With_Default_Message;

    // Test Behavior Types After Construction.
    procedure CreateWillExecute_Behavior_Type_Set_To_WillExecute;
    procedure CreateWillExecuteWhen_Behavior_Type_Set_To_WillExecuteWhen;
    procedure CreateWillReturnWhen_Behavior_Type_Set_To_WillReturn;
    procedure CreateReturnDefault_Behavior_Type_Set_To_ReturnDefault;
    procedure CreateWillRaise_Behavior_Type_Set_To_WillAlwaysRaise;
    procedure CreateWillRaiseWhen_Behavior_Type_Set_To_WillRaise;
  end;
  {$M-}

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
  returnValue: TValue;
begin
  behavior := TBehavior.CreateWillExecute(
    function (const args : TArray<TValue>; const returnType : TRttiType) : TValue
    begin
      result := 'hello world';
    end
    );

  returnValue := behavior.Execute(nil,nil);

  Assert.IsTrue(SameText(returnValue.AsString,'hello world'));
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
  Assert.IsTrue(returnValue.AsInt64 = 123);
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
  behavior := TBehavior.CreateWillReturnWhen(args,returnValue,Fmatchers);
  args[0] := 1;
  args[1] := 2;
  args[2] :=  'hello';
  Assert.IsTrue(behavior.Match(args));
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
  behavior := TBehavior.CreateWillReturnWhen(args,returnValue,FMatchers);
  args[0] := 1;
  args[1] := 2;
  args[2] :=  'hello world';
  Assert.IsFalse(behavior.Match(args));
end;

procedure TTestBehaviors.CreateReturnDefault_Behavior_Type_Set_To_ReturnDefault;
var
  behavior: IBehavior;
begin
  behavior := TBehavior.CreateReturnDefault(nil);

  Assert.IsTrue(behavior.BehaviorType = TBehaviorType.ReturnDefault, 'CreateReturnDefault behavior type isn''t ReturnDefault');
end;

procedure TTestBehaviors.CreateWillExecuteWhen_Behavior_Type_Set_To_WillExecuteWhen;
var
  behavior: IBehavior;
begin
  behavior := TBehavior.CreateWillExecuteWhen(nil, nil,FMatchers);

  Assert.IsTrue(behavior.BehaviorType = TBehaviorType.WillExecuteWhen, 'CreateWillExecuteWhen behavior type isn''t WillExecuteWhen');
end;

procedure TTestBehaviors.CreateWillExecute_Behavior_Type_Set_To_WillExecute;
var
  behavior: IBehavior;
begin
  behavior := TBehavior.CreateWillExecute(nil);

  Assert.IsTrue(behavior.BehaviorType = TBehaviorType.WillExecute, 'CreateWillExecute behavior type isn''t WillExecute');
end;

procedure TTestBehaviors.CreateWillRaiseWhen_Behavior_Type_Set_To_WillRaise;
var
  behavior: IBehavior;
begin
  //What is passed here shouldn't affect the result of the behavior being set. No way to avoid it however.
  behavior := TBehavior.CreateWillRaiseWhen(nil, ETestBehaviourException, '',FMatchers);

  Assert.IsTrue(behavior.BehaviorType = TBehaviorType.WillRaise, 'CreateWillRaiseWhen behavior type isn''t WillRaise');
end;

procedure TTestBehaviors.CreateWillRaiseWhen_Execute_Raises_Exception_Message_Of_Our_Choice;
var
  behavior: IBehavior;
const
  EXCEPTION_STRING = 'Exception!';
begin
  behavior := TBehavior.CreateWillRaiseWhen(nil, ETestBehaviourException, EXCEPTION_STRING,FMatchers);

  //Passing nils as we don't care about these values for the exception
  Assert.WillRaise(procedure
    begin
     behavior.Execute(nil, nil);
    end, ETestBehaviourException);
end;

procedure TTestBehaviors.CreateWillRaiseWhen_Execute_Raises_Exception_Of_Our_Choice;
var
  behavior: IBehavior;
begin
  behavior := TBehavior.CreateWillRaiseWhen(nil, ETestBehaviourException, '',FMatchers);

  Assert.WillRaise(procedure
  begin
    //Passing nils as we don't care about these values for the exception
    behavior.Execute(nil, nil);
  end, ETestBehaviourException);

end;

procedure TTestBehaviors.CreateWillRaiseWhen_Execute_Raises_Exception_Of_Our_Choice_With_Default_Message;
var
  behavior: IBehavior;
const
  EXCEPTION_STRING = 'raised by mock';
begin
  behavior := TBehavior.CreateWillRaiseWhen(nil, ETestBehaviourException, '',FMatchers);

  Assert.WillRaiseWithMessage(procedure
  begin
    //Passing nils as we don't care about these values for the exception
    behavior.Execute(nil, nil);
  end, ETestBehaviourException, EXCEPTION_STRING);

end;

procedure TTestBehaviors.CreateWillRaiseWhen_Execute_Raises_No_Exception_If_Passed_Nil_For_Exception_Class;
var
  behavior: IBehavior;
begin
  behavior := TBehavior.CreateWillRaise(nil, '');

  //No exception coverage. Therefore we shouldn't get an exception
  behavior.Execute(nil, nil);

  //If we have gotten here no exception was recieved.
  Assert.IsTrue(True);
end;

procedure TTestBehaviors.CreateWillRaise_Behavior_Type_Set_To_WillAlwaysRaise;
begin
  Assert.Pass;
end;

procedure TTestBehaviors.CreateWillRaise_Execute_Raises_Exception_Message_Of_Our_Choice;
var
  behavior: IBehavior;
const
  EXCEPTION_STRING = 'Exception!';
begin
  behavior := TBehavior.CreateWillRaise(ETestBehaviourException, EXCEPTION_STRING);

  Assert.WillRaise(procedure
  begin
    //Passing nils as we don't care about these values for the exception
    behavior.Execute(nil, nil);
  end, ETestBehaviourException);
end;

procedure TTestBehaviors.CreateWillRaise_Execute_Raises_Exception_Of_Our_Choice;
var
  behavior: IBehavior;
begin
  behavior := TBehavior.CreateWillRaise(ETestBehaviourException, '');

  Assert.WillRaise(procedure
  begin
    //Passing nils as we don't care about these values for the exception
    behavior.Execute(nil, nil);
  end, ETestBehaviourException);
end;


procedure TTestBehaviors.CreateWillRaise_Execute_Raises_Exception_Of_Our_Choice_With_Default_Message;
var
  behavior: IBehavior;
const
  EXCEPTION_STRING = 'raised by mock';
begin
  behavior := TBehavior.CreateWillRaise(ETestBehaviourException, '');

  Assert.WillRaiseWithMessage(procedure
  begin
  //Passing nils as we don't care about these values for the exception
  behavior.Execute(nil, nil);
  end, ETestBehaviourException, EXCEPTION_STRING);
end;

procedure TTestBehaviors.CreateWillRaise_Execute_Raises_No_Exception_If_Passed_Nil_For_Exception_Class;
var
  behavior: IBehavior;
begin
  behavior := TBehavior.CreateWillRaise(nil, '');

  //No exception coverage. Therefore we shouldn't get an exception
  behavior.Execute(nil, nil);

  //If we have gotten here no exception was recieved.
  Assert.IsTrue(True);
end;

procedure TTestBehaviors.CreateWillReturnWhen_Behavior_Type_Set_To_WillReturn;
begin
  Assert.Pass;
end;


initialization
  TDUnitX.RegisterTestFixture(TTestBehaviors);

end.
