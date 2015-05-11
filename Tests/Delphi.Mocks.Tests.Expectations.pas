unit Delphi.Mocks.Tests.Expectations;

interface

uses
  TestFramework,
  Delphi.Mocks.Interfaces,
  Delphi.Mocks.Expectation;


type
  TTestExpectations = class(TTestCase)
  published

    //Created with correct exception type set
    procedure CreateOnceWhen_Expectation_Type_Set_To_OnceWhen;
    procedure CreateOnce_Expectation_Type_Set_To_Once;
    procedure CreateNeverWhen_Expectation_Type_Set_To_NeverWhen;
    procedure CreateNever_Expectation_Type_Set_To_Never;
    procedure CreateAtLeastOnceWhen_Expectation_Type_Set_To_AtLeastOnceWhen;
    procedure CreateAtLeastOnce_Expectation_Type_Set_To_AtLeastOnce;
    procedure CreateAtLeastWhen_Expectation_Type_Set_To_AtLeastWhen;
    procedure CreateAtLeast_Expectation_Type_Set_To_AtLeast;
    procedure CreateAtMostWhen_Expectation_Type_Set_To_AtMostWhen;
    procedure CreateAtMost_Expectation_Type_Set_To_AtMost;
    procedure CreateBetweenWhen_Expectation_Type_Set_To_BetweenWhen;
    procedure CreateBetween_Expectation_Type_Set_To_Between;
    procedure CreateExactlyWhen_Expectation_Type_Set_To_ExactlyWhen;
    procedure CreateExactly_Expectation_Type_Set_To_Exactly;
    procedure CreateBeforeWhen_Expectation_Type_Set_To_BeforeWhen;
    procedure CreateBefore_Expectation_Type_Set_To_Before;
    procedure CreateAfterWhen_Expectation_Type_Set_To_AfterWhen;
    procedure CreateAfter_Expectation_Type_Set_To_After;

    //ExpectationMet after record hit tests
    procedure ExpectationMet_With_OnceWhen_CalledOnce;
    procedure ExpectationNotMet_With_OnceWhen_CalledNever;

    procedure ExpectationMet_With_Never_CalledNever;
    procedure ExpectationNotMet_With_Never_CalledOnce;

    procedure ExpectationMet_With_AtLeastOnce_CalledOnceAndTwoTimes;
    procedure ExpectationNotMet_With_AtLeastOnce_CalledNever;

    procedure ExpectationMet_With_AtLeast2_CalledTwoTimeAndThreeTimes;
    procedure ExpectationNotMet_With_AtLeast2_CalledNeverAndOnce;

    procedure ExpectationMet_With_AtMost2_CalledNeverOnceAndTwoTimes;
    procedure ExpectationNotMet_With_AtMost2_CalledThreeTimes;

    procedure ExpectationMet_With_Between_0to4_CalledNever;
    procedure ExpectationMet_With_Between_1to4_CalledOnce;
    procedure ExpectationNotMet_With_Between_1to4_CalledNever;

    procedure ExpectationMet_With_Exactly2_Called2Times;
    procedure ExpectationMet_With_Exactly2_CalledNever;
    procedure ExpectationMet_With_Exactly2_CalledOnceAnd3Times;

    procedure ExpectationMet_With_After;
    procedure ExpectationNotMet_With_After;

    procedure ExpectationMet_With_Before;
    procedure ExpectationNotMet_With_Before;
  end;


implementation

{ TTestExpectations }


{ TTestExpectations }

procedure TTestExpectations.CreateAfterWhen_Expectation_Type_Set_To_AfterWhen;
var
  expectation : IExpectation;
begin
  expectation := TExpectation.CreateAfterWhen('', '', nil);

  Check(expectation.ExpectationType = TExpectationType.AfterWhen, 'CreateAfterWhen expectation type isn''t set to AfterWhen');
end;

procedure TTestExpectations.CreateAfter_Expectation_Type_Set_To_After;
var
  expectation : IExpectation;
begin
  expectation := TExpectation.CreateAfter('', '');

  Check(expectation.ExpectationType = TExpectationType.After, 'CreateAfter expectation type isn''t set to After');

end;

procedure TTestExpectations.CreateAtLeastOnceWhen_Expectation_Type_Set_To_AtLeastOnceWhen;
var
  expectation : IExpectation;
begin
  expectation := TExpectation.CreateAtLeastOnceWhen('', nil);

  Check(expectation.ExpectationType = TExpectationType.AtLeastOnceWhen, 'CreateAtLeastOnceWhen expectation type isn''t set to AtLeastOnceWhen');

end;

procedure TTestExpectations.CreateAtLeastOnce_Expectation_Type_Set_To_AtLeastOnce;
var
  expectation : IExpectation;
begin
  expectation := TExpectation.CreateAtLeastOnce('');

  Check(expectation.ExpectationType = TExpectationType.AtLeastOnce, 'CreateAtLeastOnce expectation type isn''t set to AtLeastOnce');

end;

procedure TTestExpectations.CreateAtLeastWhen_Expectation_Type_Set_To_AtLeastWhen;
var
  expectation : IExpectation;
begin
  expectation := TExpectation.CreateAtLeastWhen('', 0, nil);

  Check(expectation.ExpectationType = TExpectationType.AtLeastWhen, 'CreateAtLeastWhen expectation type isn''t set to AtLeastWhen');

end;

procedure TTestExpectations.CreateAtLeast_Expectation_Type_Set_To_AtLeast;
var
  expectation : IExpectation;
begin
  expectation := TExpectation.CreateAtLeast('', 0);

  Check(expectation.ExpectationType = TExpectationType.AtLeast, 'CreateAtLeast expectation type isn''t set to AtLeast');


end;

procedure TTestExpectations.CreateAtMostWhen_Expectation_Type_Set_To_AtMostWhen;
var
  expectation : IExpectation;
begin
  expectation := TExpectation.CreateAtMostWhen('', 0, nil);

  Check(expectation.ExpectationType = TExpectationType.AtMostWhen, 'CreateAtMostWhen expectation type isn''t set to AtMostWhen');


end;

procedure TTestExpectations.CreateAtMost_Expectation_Type_Set_To_AtMost;
var
  expectation : IExpectation;
begin
  expectation := TExpectation.CreateAtMost('', 0);

  Check(expectation.ExpectationType = TExpectationType.AtMost, 'CreateAtMost expectation type isn''t set to AtMost');

end;

procedure TTestExpectations.CreateBeforeWhen_Expectation_Type_Set_To_BeforeWhen;
var
  expectation : IExpectation;
begin
  expectation := TExpectation.CreateBeforeWhen('', '', nil);

  Check(expectation.ExpectationType = TExpectationType.BeforeWhen, 'CreateBeforeWhen expectation type isn''t set to BeforeWhen');

end;

procedure TTestExpectations.CreateBefore_Expectation_Type_Set_To_Before;
var
  expectation : IExpectation;
begin
  expectation := TExpectation.CreateBefore('', '');

  Check(expectation.ExpectationType = TExpectationType.Before, 'CreateBefore expectation type isn''t set to Before');

end;

procedure TTestExpectations.CreateBetweenWhen_Expectation_Type_Set_To_BetweenWhen;
var
  expectation : IExpectation;
begin
  expectation := TExpectation.CreateBetweenWhen('', 0, 0, nil);

  Check(expectation.ExpectationType = TExpectationType.BetweenWhen, 'CreateBetweenWhen expectation type isn''t set to BetweenWhen');
end;

procedure TTestExpectations.CreateBetween_Expectation_Type_Set_To_Between;
var
  expectation : IExpectation;
begin
  expectation := TExpectation.CreateBetween('', 0, 0);

  Check(expectation.ExpectationType = TExpectationType.Between, 'CreateBetween expectation type isn''t set to Between');
end;

procedure TTestExpectations.CreateExactlyWhen_Expectation_Type_Set_To_ExactlyWhen;
var
  expectation : IExpectation;
begin
  expectation := TExpectation.CreateExactlyWhen('', 0, nil);

  Check(expectation.ExpectationType = TExpectationType.ExactlyWhen, 'CreateExactlyWhen expectation type isn''t set to ExactlyWhen');
end;

procedure TTestExpectations.CreateExactly_Expectation_Type_Set_To_Exactly;
var
  expectation : IExpectation;
begin
  expectation := TExpectation.CreateExactly('', 0);

  Check(expectation.ExpectationType = TExpectationType.Exactly, 'CreateExactly expectation type isn''t set to Exactly');
end;

procedure TTestExpectations.CreateNeverWhen_Expectation_Type_Set_To_NeverWhen;
var
  expectation : IExpectation;
begin
  expectation := TExpectation.CreateNeverWhen('', nil);

  Check(expectation.ExpectationType = TExpectationType.NeverWhen, 'CreateNeverWhen expectation type isn''t set to NeverWhen');
end;

procedure TTestExpectations.CreateNever_Expectation_Type_Set_To_Never;
var
  expectation : IExpectation;
begin
  expectation := TExpectation.CreateNever('');

  Check(expectation.ExpectationType = TExpectationType.Never, 'CreateNever expectation type isn''t set to Never');
end;

procedure TTestExpectations.CreateOnceWhen_Expectation_Type_Set_To_OnceWhen;
var
  expectation : IExpectation;
begin
  expectation := TExpectation.CreateOnceWhen('', nil);

  Check(expectation.ExpectationType = TExpectationType.OnceWhen, 'CreateOnceWhen expectation type isn''t set to OnceWhen');
end;

procedure TTestExpectations.CreateOnce_Expectation_Type_Set_To_Once;
var
  expectation : IExpectation;
begin
  expectation := TExpectation.CreateOnce('');

  Check(expectation.ExpectationType = TExpectationType.Once, 'CreateOnce expectation type isn''t set to Once');
end;

procedure TTestExpectations.ExpectationMet_With_OnceWhen_CalledOnce;
var
  expectation : IExpectation;
begin
  expectation := TExpectation.CreateOnceWhen('', nil);

  expectation.RecordHit;

  CheckTrue(expectation.ExpectationMet, 'Exception not met for OnceWhen being called once');
end;

procedure TTestExpectations.ExpectationNotMet_With_OnceWhen_CalledNever;
var
  expectation : IExpectation;
begin
  expectation := TExpectation.CreateOnceWhen('', nil);

  CheckFalse(expectation.ExpectationMet, 'Exception met for OnceWhen being not called');
end;


procedure TTestExpectations.ExpectationNotMet_With_Between_1to4_CalledNever;
var
  expectation : IExpectation;
begin
  expectation := TExpectation.CreateBetween('', 1, 4);

  CheckFalse(expectation.ExpectationMet, 'Exception met for Between 1 to 4 being not called');
end;


procedure TTestExpectations.ExpectationMet_With_Between_0to4_CalledNever;
var
  expectation : IExpectation;
begin
  expectation := TExpectation.CreateBetween('', 0, 4);

  CheckTrue(expectation.ExpectationMet, 'Exception not met for Between 0 to 4 being not called');
end;


procedure TTestExpectations.ExpectationMet_With_Between_1to4_CalledOnce;
var
  expectation : IExpectation;
begin
  expectation := TExpectation.CreateBetween('', 1, 4);

  CheckFalse(expectation.ExpectationMet, 'Exception met for Between 1 to 4 being not called');

  expectation.RecordHit;

  CheckTrue(expectation.ExpectationMet, 'Exception not met for Between 1 to 4 being called once');
end;

procedure TTestExpectations.ExpectationMet_With_Never_CalledNever;
var
  expectation : IExpectation;
begin
  expectation := TExpectation.CreateNever('');

  CheckTrue(expectation.ExpectationMet, 'Exception not met for Never being not called');
end;

procedure TTestExpectations.ExpectationNotMet_With_Never_CalledOnce;
var
  expectation : IExpectation;
begin
  expectation := TExpectation.CreateNever('');

  expectation.RecordHit;

  CheckFalse(expectation.ExpectationMet, 'Exception met for Never being called once');
end;

procedure TTestExpectations.ExpectationMet_With_Exactly2_Called2Times;
var
  expectation : IExpectation;
begin
  expectation := TExpectation.CreateExactly('', 2);

  expectation.RecordHit;
  expectation.RecordHit;

  CheckTrue(expectation.ExpectationMet, 'Exception not met for Exaclty 2 being called 2 times');
end;

procedure TTestExpectations.ExpectationMet_With_Exactly2_CalledNever;
var
  expectation : IExpectation;
begin
  expectation := TExpectation.CreateExactly('', 2);

  CheckFalse(expectation.ExpectationMet, 'Exception met for Exaclty 2 being not called');
end;

procedure TTestExpectations.ExpectationMet_With_Exactly2_CalledOnceAnd3Times;
var
  expectation : IExpectation;
begin
  expectation := TExpectation.CreateExactly('', 2);

  expectation.RecordHit;

  CheckFalse(expectation.ExpectationMet, 'Exception met for Exaclty 2 being called once');

  expectation.RecordHit;
  expectation.RecordHit;

  CheckFalse(expectation.ExpectationMet, 'Exception met for Exaclty 2 being called 3 times');
end;


procedure TTestExpectations.ExpectationMet_With_AtLeastOnce_CalledOnceAndTwoTimes;
var
  expectation : IExpectation;
begin
  expectation := TExpectation.CreateAtLeastOnce('');

  expectation.RecordHit;

  CheckTrue(expectation.ExpectationMet, 'Exception not met for AtLeastOnce being called once');

  expectation.RecordHit;

  CheckTrue(expectation.ExpectationMet, 'Exception not met for AtLeastOnce being called once');
end;

procedure TTestExpectations.ExpectationNotMet_With_AtLeastOnce_CalledNever;
var
  expectation : IExpectation;
begin
  expectation := TExpectation.CreateAtLeastOnce('');

  CheckFalse(expectation.ExpectationMet, 'Exception met for AtLeastOnce being not called');
end;

procedure TTestExpectations.ExpectationMet_With_AtLeast2_CalledTwoTimeAndThreeTimes;
var
  expectation : IExpectation;
begin
  expectation := TExpectation.CreateAtLeast('', 2);

  expectation.RecordHit;
  expectation.RecordHit;

  CheckTrue(expectation.ExpectationMet, 'Exception not met for AtLeast2 being called two times');

  expectation.RecordHit;

  CheckTrue(expectation.ExpectationMet, 'Exception not met for AtLeast2 being called three times');
end;

procedure TTestExpectations.ExpectationNotMet_With_AtLeast2_CalledNeverAndOnce;
var
  expectation : IExpectation;
begin
  expectation := TExpectation.CreateAtLeast('', 2);

  CheckFalse(expectation.ExpectationMet, 'Exception met for AtLeast2 being never called');

  expectation.RecordHit;

  CheckFalse(expectation.ExpectationMet, 'Exception met for AtLeast2 being called once');
end;


procedure TTestExpectations.ExpectationMet_With_AtMost2_CalledNeverOnceAndTwoTimes;
var
  expectation : IExpectation;
begin
  expectation := TExpectation.CreateAtMost('', 2);

  CheckTrue(expectation.ExpectationMet, 'Exception not met for AtMost2 being called never');

  expectation.RecordHit;

  CheckTrue(expectation.ExpectationMet, 'Exception not met for AtMost2 being called once');

  expectation.RecordHit;

  CheckTrue(expectation.ExpectationMet, 'Exception not met for AtMost2 being called two times');
end;

procedure TTestExpectations.ExpectationNotMet_With_AtMost2_CalledThreeTimes;
var
  expectation : IExpectation;
begin
  expectation := TExpectation.CreateAtMost('', 2);

  expectation.RecordHit;
  expectation.RecordHit;
  expectation.RecordHit;

  CheckFalse(expectation.ExpectationMet, 'Exception met for AtMost2 being called three times');
end;

procedure TTestExpectations.ExpectationMet_With_After;
begin
  Fail('Expectation for After/AfterWhen doesn''t work yet');
end;

procedure TTestExpectations.ExpectationNotMet_With_After;
begin
  Fail('Expectation for After/AfterWhen doesn''t work yet');
end;

procedure TTestExpectations.ExpectationMet_With_Before;
begin
  Fail('Expectation for Before/BeforeWhen doesn''t work yet');
end;

procedure TTestExpectations.ExpectationNotMet_With_Before;
begin
  Fail('Expectation for Before/BeforeWhen doesn''t work yet');
end;



initialization
  TestFramework.RegisterTest(TTestExpectations.Suite);

end.
