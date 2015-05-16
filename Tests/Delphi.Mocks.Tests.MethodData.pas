unit Delphi.Mocks.Tests.MethodData;

interface

uses
  SysUtils,
  TestFramework,
  Rtti,
  Delphi.Mocks,
  Delphi.Mocks.Interfaces;

type
  {$M+}
  ISimpleInterface = interface
    function MissingArg(Value: Integer): Integer;
  end;
  {$M-}

  TTestMethodData = class(TTestCase)
  published
    procedure Expectation_Before_Verifies_To_True_When_Prior_Method_Called_Atleast_Once;

    procedure AllowRedefineBehaviorDefinitions_IsTrue_RedefinedIsAllowed;
    procedure AllowRedefineBehaviorDefinitions_IsFalse_ExceptionIsThrown_WhenRedefining;
    procedure AllowRedefineBehaviorDefinitions_IsFalse_NoExceptionIsThrown_WhenAddingNormal;
    procedure AllowRedefineBehaviorDefinitions_IsTrue_OldBehaviorIsDeleted;

    procedure BehaviourMustBeDefined_IsFalse_AndBehaviourIsNotDefined_RaisesNoException;
    procedure BehaviourMustBeDefined_IsTrue_AndBehaviourIsNotDefined_RaisesException;

    procedure RaiseExceptionWhenMissingArgsAndDontHaveDefaultValue;
  end;

implementation

uses
  Delphi.Mocks.Helpers,
  Delphi.Mocks.MethodData,
  classes, System.TypInfo, StrUtils;


{ TTestMethodData }

procedure TTestMethodData.Expectation_Before_Verifies_To_True_When_Prior_Method_Called_Atleast_Once;
begin
  Check(False, 'Not implemented');
end;

procedure TTestMethodData.RaiseExceptionWhenMissingArgsAndDontHaveDefaultValue;
const
  EXPECTED_ERROR_MESSAGE = 'method [MissingArg] with args ( 4 )';
var
  vMock: TMock<ISimpleInterface>;
begin
  vMock := TMock<ISimpleInterface>.Create;
  vMock.Setup.Expect.Once.When.MissingArg(123);

  try
    vMock.Instance.MissingArg(4);
    Fail('Do not raise Exception');
  except
    on E: Exception do
    begin
      CheckEquals(EMockException.ClassName, E.ClassName, 'Expect a MockException');
      CheckTrue(ContainsText(E.Message, EXPECTED_ERROR_MESSAGE),
                Format('Expect the string <%s> contains the substring <%s>',[E.Message, EXPECTED_ERROR_MESSAGE]));
    end;
  end;
end;

procedure TTestMethodData.AllowRedefineBehaviorDefinitions_IsTrue_RedefinedIsAllowed;
var
  methodData  : IMethodData;
  someValue1,
  someValue2  : TValue;
begin
  someValue1 := TValue.From<Integer>(1);
  someValue2 := TValue.From<Integer>(2);

  methodData := TMethodData.Create('x', 'x', TSetupMethodDataParameters.Create(FALSE, False, TRUE));
  methodData.WillReturnWhen(TArray<TValue>.Create(someValue1), someValue1);
  methodData.WillReturnWhen(TArray<TValue>.Create(someValue1), someValue2);

  // no exception is raised
  CheckTrue(True);
end;

procedure TTestMethodData.AllowRedefineBehaviorDefinitions_IsFalse_ExceptionIsThrown_WhenRedefining;
var
  methodData  : IMethodData;
  someValue1,
  someValue2  : TValue;
begin
  someValue1 := TValue.From<Integer>(1);
  someValue2 := TValue.From<Integer>(2);

  methodData := TMethodData.Create('x', 'x', TSetupMethodDataParameters.Create(FALSE, FALSE, FALSE));
  methodData.WillReturnWhen(TArray<TValue>.Create(someValue1), someValue1);

  StartExpectingException(EMockException);
  methodData.WillReturnWhen(TArray<TValue>.Create(someValue1), someValue2);
  StopExpectingException;
end;

procedure TTestMethodData.AllowRedefineBehaviorDefinitions_IsFalse_NoExceptionIsThrown_WhenAddingNormal;
var
  methodData  : IMethodData;
  someValue1,
  someValue2  : TValue;
begin
  someValue1 := TValue.From<Integer>(1);
  someValue2 := TValue.From<Integer>(2);
  methodData := TMethodData.Create('x', 'x', TSetupMethodDataParameters.Create(FALSE, FALSE, FALSE));
  methodData.WillReturnWhen(TArray<TValue>.Create(someValue1), someValue1);
  methodData.WillReturnWhen(TArray<TValue>.Create(someValue2), someValue2);

  CheckTrue(True);
end;

procedure TTestMethodData.AllowRedefineBehaviorDefinitions_IsTrue_OldBehaviorIsDeleted;
var
  methodData  : IMethodData;
  someValue1,
  someValue2  : TValue;
  outValue    : TValue;
begin
  someValue1 := TValue.From<Integer>(1);
  someValue2 := TValue.From<Integer>(2);
  methodData := TMethodData.Create('x', 'x', TSetupMethodDataParameters.Create(TRUE, TRUE, TRUE));
  methodData.WillReturnWhen(TArray<TValue>.Create(someValue1), someValue1);
  methodData.WillReturnWhen(TArray<TValue>.Create(someValue1), someValue2);

  methodData.RecordHit(TArray<TValue>.Create(someValue1), TrttiContext.Create.GetType(TypeInfo(integer)), outValue);

  CheckEquals(someValue2.AsInteger, outValue.AsInteger );
end;


procedure TTestMethodData.BehaviourMustBeDefined_IsFalse_AndBehaviourIsNotDefined_RaisesNoException;
var
  methodData  : IMethodData;
  someValue   : TValue;
begin
  methodData := TMethodData.Create('x', 'x', TSetupMethodDataParameters.Create(FALSE, FALSE, FALSE));
  methodData.RecordHit(TArray<TValue>.Create(), nil, someValue);
  // no exception should be raised
  CheckTrue(True);
end;

procedure TTestMethodData.BehaviourMustBeDefined_IsTrue_AndBehaviourIsNotDefined_RaisesException;
var
  methodData  : IMethodData;
  someValue   : TValue;
begin
  methodData := TMethodData.Create('x', 'x', TSetupMethodDataParameters.Create(FALSE, TRUE, FALSE));

  StartExpectingException(EMockException);
  methodData.RecordHit(TArray<TValue>.Create(), TRttiContext.Create.GetType(TypeInfo(Integer)), someValue);
  StopExpectingException;
end;

initialization
  TestFramework.RegisterTest(TTestMethodData.Suite);


end.
