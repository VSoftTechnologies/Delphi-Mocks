unit Delphi.Mocks.Tests.MethodData;

interface

uses
  SysUtils,
  DUnitX.TestFramework,
  Rtti,
  Delphi.Mocks,
  Delphi.Mocks.Interfaces;

type
  {$M+}
  ISimpleInterface = interface
    function MissingArg(Value: Integer): Integer;
  end;
  {$M-}

  {$M+}
  [TestFixture]
  TTestMethodData = class
  published
    [Test, Ignore]
    procedure Expectation_Before_Verifies_To_True_When_Prior_Method_Called_Atleast_Once;
    [Test]
    procedure AllowRedefineBehaviorDefinitions_IsTrue_RedefinedIsAllowed;
    [Test]
    procedure AllowRedefineBehaviorDefinitions_IsFalse_ExceptionIsThrown_WhenRedefining;
    [Test]
    procedure AllowRedefineBehaviorDefinitions_IsFalse_NoExceptionIsThrown_WhenAddingNormal;
    [Test]
    procedure AllowRedefineBehaviorDefinitions_IsTrue_OldBehaviorIsDeleted;
    [Test]
    procedure BehaviourMustBeDefined_IsFalse_AndBehaviourIsNotDefined_RaisesNoException;
    [Test]
    procedure BehaviourMustBeDefined_IsTrue_AndBehaviourIsNotDefined_RaisesException;
  end;
  {$M-}

implementation

uses
  Delphi.Mocks.Helpers,
  Delphi.Mocks.MethodData,
  classes, System.TypInfo, StrUtils;


{ TTestMethodData }

procedure TTestMethodData.Expectation_Before_Verifies_To_True_When_Prior_Method_Called_Atleast_Once;
begin
  Assert.IsTrue(False, 'Not implemented');
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
  methodData.WillReturnWhen(TArray<TValue>.Create(someValue1), someValue1, nil);
  methodData.WillReturnWhen(TArray<TValue>.Create(someValue1), someValue2, nil);

  // no exception is raised
  Assert.IsTrue(True);
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
  methodData.WillReturnWhen(TArray<TValue>.Create(someValue1), someValue1, nil);

  Assert.WillRaise(procedure
  begin
    methodData.WillReturnWhen(TArray<TValue>.Create(someValue1), someValue2, nil);
  end, EMockSetupException);
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
  methodData.WillReturnWhen(TArray<TValue>.Create(someValue1), someValue1, nil);
  methodData.WillReturnWhen(TArray<TValue>.Create(someValue2), someValue2, nil);

  Assert.IsTrue(True);
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
  methodData.WillReturnWhen(TArray<TValue>.Create(someValue1), someValue1, nil);
  methodData.WillReturnWhen(TArray<TValue>.Create(someValue1), someValue2, nil);

  methodData.RecordHit(TArray<TValue>.Create(someValue1), TrttiContext.Create.GetType(TypeInfo(integer)), outValue);

  Assert.AreEqual(someValue2.AsInteger, outValue.AsInteger );
end;


procedure TTestMethodData.BehaviourMustBeDefined_IsFalse_AndBehaviourIsNotDefined_RaisesNoException;
var
  methodData  : IMethodData;
  someValue   : TValue;
begin
  methodData := TMethodData.Create('x', 'x', TSetupMethodDataParameters.Create(FALSE, FALSE, FALSE));
  methodData.RecordHit(TArray<TValue>.Create(), nil, someValue);
  // no exception should be raised
  Assert.IsTrue(True);
end;

procedure TTestMethodData.BehaviourMustBeDefined_IsTrue_AndBehaviourIsNotDefined_RaisesException;
var
  methodData  : IMethodData;
  someValue   : TValue;
begin
  methodData := TMethodData.Create('x', 'x', TSetupMethodDataParameters.Create(FALSE, TRUE, FALSE));

  Assert.WillRaise(procedure
  begin
  methodData.RecordHit(TArray<TValue>.Create(), TRttiContext.Create.GetType(TypeInfo(Integer)), someValue);
  end, EMockException);
end;


initialization
  TDUnitX.RegisterTestFixture(TTestMethodData);

end.
