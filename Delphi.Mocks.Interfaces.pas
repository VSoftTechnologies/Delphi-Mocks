unit Delphi.Mocks.Interfaces;

interface

uses
  SysUtils,
  Generics.Collections,
  Delphi.Mocks,
  //Delphi.Mocks.Types,
  Rtti;

type
  TBehaviorType = (WillReturn,ReturnDefault,WillRaise,WillRaiseAlways,WillExecute,WillExecuteWhen);

  IBehavior = interface
  ['{9F6FE14D-4522-48EE-B564-20E2BECF7992}']
    function GetHitCount : integer;
    function GetBehaviorType : TBehaviorType;
    function Match(const Args: TArray<TValue>) : boolean;
    function Execute(const Args: TArray<TValue>;  const returnType : TRttiType) : TValue;
    property BehaviorType : TBehaviorType read GetBehaviorType;
    property HitCount : integer read GetHitCount;
  end;

  TExpectationType = (Once,           //Called once only
                      OnceWhen,       //Called once only with specified params
                      Never,          //Never called
                      NeverWhen,      //Never called with specified params
                      AtLeastOnce,    //1 or more times
                      AtLeastOnceWhen,//1 or more times with specified params
                      AtLeastX,       //x or more times
                      AtLeastXWhen,   //x or more times with specified params
                      AtMostOnce,     //0 or 1 times
                      AtMostOnceWhen, //0 or 1 times with specified params
                      AtMostX,        //0 to X times
                      AtMostXWhen,    //0 to X times with specified params
                      Between,        //Between X & Y Inclusive times
                      BetweenWhen,    //Between X & Y Inclusive times with specified params
                      Exactly,        //Exactly X times
                      ExactlyWhen,    //Exactly X times with specified params
                      Before,         //Must be called before Method X is called
                      BeforeWhen,     //Must be called before Method x is called with specified params
                      After,          //Must be called after Method X is called
                      AfterWhen);     //Must be called after Method x is called with specified params

  IExpectation = interface
  ['{960B95B2-581D-4C18-A320-7E19190F29EF}']
    function GetExpectationType : TExpectationType;

  end;


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

  IVerify = interface
  ['{58C05610-4BDA-451E-9D61-17C6376C3B3F}']
    procedure Verify(const message : string = '');
  end;

implementation

end.
