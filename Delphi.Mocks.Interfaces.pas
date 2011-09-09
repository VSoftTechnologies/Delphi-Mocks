unit Delphi.Mocks.Interfaces;

interface

uses
  Rtti,
  SysUtils,
  Generics.Collections;

type
  {$M+}
  TBehaviorType = (WillReturn,ReturnDefault,WillRaise,WillRaiseAlways,WillExecute,WillExecuteWhen);

  IBehavior = interface
    ['{9F6FE14D-4522-48EE-B564-20E2BECF7992}']
    function GetBehaviorType : TBehaviorType;
    function Match(const Args: TArray<TValue>) : boolean;
    function Execute(const Args: TArray<TValue>;  const returnType : TRttiType) : TValue;
    property BehaviorType : TBehaviorType read GetBehaviorType;
  end;

  IVerify = interface
  ['{58C05610-4BDA-451E-9D61-17C6376C3B3F}']
    procedure Verify(const message : string = '');
  end;

  TExecuteFunc = reference to function (const args : TArray<TValue>; const ReturnType : TRttiType) : TValue;


  IMethodData = interface
  ['{640BFB71-85C2-4ED4-A863-5AF6535BD2E8}']
    function GetDefaultReturnValue : TValue;
    function GetBehaviors : TList<IBehavior>;
    function GetHitCount : integer;
    procedure RecordHit(const Args: TArray<TValue>; const returnType : TRttiType; out Result: TValue);

    procedure WillReturnDefault(const returnValue : TValue);
    procedure WillReturnWhen(const Args: TArray<TValue>; const returnValue : TValue);

    procedure WillRaiseAlways(const exceptionClass : ExceptClass);
    procedure WillRaiseWhen(const exceptionClass : ExceptClass;const Args: TArray<TValue>);

    procedure WillExecute(const func : TExecuteFunc);
    procedure WillExecuteWhen(const func : TExecuteFunc; const Args: TArray<TValue>);

    property Behaviors : TList<IBehavior> read GetBehaviors;
    property HitCount : integer read GetHitCount;
    property DefaultReturnValue : TValue read GetDefaultReturnValue;
  end;

  IExpectation = interface
    ['{960B95B2-581D-4C18-A320-7E19190F29EF}']

  end;






implementation

end.
