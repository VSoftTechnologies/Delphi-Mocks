unit Delphi.Mocks.Tests.Behavior;

interface

uses
  TestFramework,
  Rtti,
  Delphi.Mocks,
  Delphi.Mocks.InterfaceProxy;

type
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
  end;

implementation

uses
  SysUtils,
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
  testValue : TValue;
  args : TArray<TValue>;
  rType : TRttiType;
begin
  //testValue := 123;
  SetLength(args,1);
  args[0] := 999;
  rType := FContext.GetType(TypeInfo(string));
  behavior := TBehavior.CreateWillExecute(
    function (const args : TArray<TValue>; const returnType : TRttiType) : TValue
    begin
      result := 'hello world';
    end
    );


//  args[1] := 2;
//  args[2] := 3;

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

initialization
  TestFramework.RegisterTest(TTestBehaviors.Suite);
end.
