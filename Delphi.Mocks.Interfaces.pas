{***************************************************************************}
{                                                                           }
{           Delphi.Mocks                                                    }
{                                                                           }
{           Copyright (C) 2011 Vincent Parrett                              }
{                                                                           }
{           http://www.finalbuilder.com                                     }
{                                                                           }
{                                                                           }
{***************************************************************************}
{                                                                           }
{  Licensed under the Apache License, Version 2.0 (the "License");          }
{  you may not use this file except in compliance with the License.         }
{  You may obtain a copy of the License at                                  }
{                                                                           }
{      http://www.apache.org/licenses/LICENSE-2.0                           }
{                                                                           }
{  Unless required by applicable law or agreed to in writing, software      }
{  distributed under the License is distributed on an "AS IS" BASIS,        }
{  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. }
{  See the License for the specific language governing permissions and      }
{  limitations under the License.                                           }
{                                                                           }
{***************************************************************************}

unit Delphi.Mocks.Interfaces;

interface

uses
  SysUtils,
  TypInfo,
  Generics.Collections,
  Delphi.Mocks,
  Delphi.Mocks.ParamMatcher,
  Rtti;

type
  TBehaviorType = (WillReturn,ReturnDefault,WillRaise,WillRaiseAlways,WillExecute,WillExecuteWhen);

  IBehavior = interface
  ['{9F6FE14D-4522-48EE-B564-20E2BECF7992}']
    function GetBehaviorType : TBehaviorType;
    function Match(const Args: TArray<TValue>) : boolean;
    function Execute(const Args: TArray<TValue>;  const returnType : TRttiType) : TValue;
    property BehaviorType : TBehaviorType read GetBehaviorType;
  end;

  TExpectationType = (Once,           //Called once only
                      OnceWhen,       //Called once only with specified params
                      Never,          //Never called
                      NeverWhen,      //Never called with specified params
                      AtLeastOnce,    //1 or more times
                      AtLeastOnceWhen,//1 or more times with specified params
                      AtLeast,       //x or more times
                      AtLeastWhen,   //x or more times with specified params
                      AtMostOnce,     //0 or 1 times
                      AtMostOnceWhen, //0 or 1 times with specified params
                      AtMost,        //0 to X times
                      AtMostWhen,    //0 to X times with specified params
                      Between,        //Between X & Y Inclusive times
                      BetweenWhen,    //Between X & Y Inclusive times with specified params
                      Exactly,        //Exactly X times
                      ExactlyWhen,    //Exactly X times with specified params
                      Before,         //Must be called before Method X is called
                      BeforeWhen,     //Must be called before Method x is called with specified params
                      After,          //Must be called after Method X is called
                      AfterWhen);     //Must be called after Method x is called with specified params
  TExpectationTypes = set of TExpectationType;

  IExpectation = interface
  ['{960B95B2-581D-4C18-A320-7E19190F29EF}']
    function GetExpectationType : TExpectationType;
    function GetExpectationMet : boolean;
    function Match(const Args : TArray<TValue>) : boolean;
    procedure RecordHit;
    function Report : string;
    property ExpectationType : TExpectationType read GetExpectationType;
    property ExpectationMet : boolean read GetExpectationMet;
  end;


  IMethodData = interface
  ['{640BFB71-85C2-4ED4-A863-5AF6535BD2E8}']
    procedure RecordHit(const Args: TArray<TValue>; const returnType : TRttiType; out Result: TValue);

    //behaviors
    procedure WillReturnDefault(const returnValue : TValue);
    procedure WillReturnWhen(const Args: TArray<TValue>; const returnValue : TValue; const matchers : TArray<IMatcher>);
    procedure WillRaiseAlways(const exceptionClass : ExceptClass; const message : string);
    procedure WillRaiseWhen(const exceptionClass : ExceptClass; const message : string; const Args: TArray<TValue>; const matchers : TArray<IMatcher>);
    procedure WillExecute(const func : TExecuteFunc);
    procedure WillExecuteWhen(const func : TExecuteFunc; const Args: TArray<TValue>; const matchers : TArray<IMatcher>);

    //expectations
    procedure OnceWhen(const Args : TArray<TValue>; const matchers : TArray<IMatcher>);
    procedure Once;
    procedure NeverWhen(const Args : TArray<TValue>; const matchers : TArray<IMatcher>);
    procedure Never;
    procedure AtLeastOnceWhen(const Args : TArray<TValue>; const matchers : TArray<IMatcher>);
    procedure AtLeastOnce;
    procedure AtLeastWhen(const times : Cardinal; const Args : TArray<TValue>; const matchers : TArray<IMatcher>);
    procedure AtLeast(const times : Cardinal);
    procedure AtMostWhen(const times : Cardinal; const Args : TArray<TValue>; const matchers : TArray<IMatcher>);
    procedure AtMost(const times : Cardinal);
    procedure BetweenWhen(const a,b : Cardinal; const Args : TArray<TValue>; const matchers : TArray<IMatcher>);
    procedure Between(const a,b : Cardinal);
    procedure ExactlyWhen(const times : Cardinal; const Args : TArray<TValue>; const matchers : TArray<IMatcher>);
    procedure Exactly(const times : Cardinal);
    procedure BeforeWhen(const ABeforeMethodName : string ; const Args : TArray<TValue>; const matchers : TArray<IMatcher>);
    procedure Before(const ABeforeMethodName : string);
    procedure AfterWhen(const AAfterMethodName : string;const Args : TArray<TValue>; const matchers : TArray<IMatcher>);
    procedure After(const AAfterMethodName : string);

    //Verification
    function Verify(var report : string) : boolean;
  end;

  IVerify = interface
  ['{58C05610-4BDA-451E-9D61-17C6376C3B3F}']
    procedure Verify(const message : string = '');
    procedure VerifyAll(const message : string = '');
    function CheckExpectations: string;
  end;

implementation

end.
