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

unit Delphi.Mocks.Expectation;

interface


uses
  Rtti,
  Delphi.Mocks,
  Delphi.Mocks.ParamMatcher,
  Delphi.Mocks.Interfaces,
  Delphi.Mocks.Utils;


//disable warnings about c++ compatibility, since we don't intend to support it.
{$WARN DUPLICATE_CTOR_DTOR OFF}
//for some reason this doesn't work.. this should override the project settings.

type
  TExpectation = class(TInterfacedObject,IExpectation)
  private
    FExpectationType        : TExpectationType;
    FArgs                   : TArray<TValue>;
    FExpectationMet         : boolean;
    FBeforeAfterMethodName  : string;
    FBetween                : array[0..1] of Cardinal;
    FTimes                  : Cardinal;
    FHitCount               : Cardinal;
    FMethodName             : string;
    FMatchers                : TArray<IMatcher>;
  protected
    function GetExpectationType : TExpectationType;
    function GetExpectationMet : boolean;
    function Match(const Args : TArray<TValue>) : boolean;
    procedure RecordHit;
    procedure CheckExpectationMet;
    function Report : string;
    function ArgsToString : string;
    procedure CopyArgs(const Args: TArray<TValue>);
    constructor Create(const AMethodName : string);
    constructor CreateWhen(const AMethodName : string; const Args: TArray<TValue>; const matchers : TArray<IMatcher>);
  public
    constructor CreateOnceWhen(const AMethodName : string; const Args : TArray<TValue>; const matchers : TArray<IMatcher>);
    constructor CreateOnce(const AMethodName : string);

    constructor CreateNeverWhen(const AMethodName : string; const Args : TArray<TValue>; const matchers : TArray<IMatcher>);
    constructor CreateNever(const AMethodName : string);

    constructor CreateAtLeastOnceWhen(const AMethodName : string; const Args : TArray<TValue>; const matchers : TArray<IMatcher>);
    constructor CreateAtLeastOnce(const AMethodName : string);

    constructor CreateAtLeastWhen(const AMethodName : string; const times : Cardinal; const Args : TArray<TValue>; const matchers : TArray<IMatcher>);
    constructor CreateAtLeast(const AMethodName : string; const times : Cardinal);

    constructor CreateAtMostWhen(const AMethodName : string; const times : Cardinal; const Args : TArray<TValue>; const matchers : TArray<IMatcher>);
    constructor CreateAtMost(const AMethodName : string; const times : Cardinal);

    constructor CreateBetweenWhen(const AMethodName : string; const a,b : Cardinal; const Args : TArray<TValue>; const matchers : TArray<IMatcher>);
    constructor CreateBetween(const AMethodName : string; const a,b : Cardinal);

    constructor CreateExactlyWhen(const AMethodName : string; const times : Cardinal; const Args : TArray<TValue>; const matchers : TArray<IMatcher>);
    constructor CreateExactly(const AMethodName : string; const times : Cardinal);

    constructor CreateBeforeWhen(const AMethodName : string; const ABeforeMethodName : string ; const Args : TArray<TValue>; const matchers : TArray<IMatcher>);
    constructor CreateBefore(const AMethodName : string; const ABeforeMethodName : string);

    constructor CreateAfterWhen(const AMethodName : string; const AAfterMethodName : string;const Args : TArray<TValue>; const matchers : TArray<IMatcher>);
    constructor CreateAfter(const AMethodName : string; const AAfterMethodName : string);

    procedure AfterConstruction; override;
  end;


implementation

uses
  SysUtils,
  Delphi.Mocks.Helpers;

{ TExpectation }

procedure TExpectation.AfterConstruction;
begin
  inherited;
  CheckExpectationMet;
end;

function TExpectation.ArgsToString: string;
begin
  Result := Delphi.Mocks.Utils.ArgsToString(FArgs);
end;

procedure TExpectation.CopyArgs(const Args: TArray<TValue>);
var
  l : integer;
begin
  l := Length(Args) -1;
  if l > 0  then
  begin
    SetLength(FArgs,l);
    CopyArray(@FArgs[0],@args[1],TypeInfo(TValue),l);
  end;
end;

constructor TExpectation.Create(const AMethodName : string);
begin
  SetLength(FMatchers, 0);

  FExpectationMet := False;
  FHitCount := 0;
  FMethodName := AMethodName;
end;

constructor TExpectation.CreateWhen(const AMethodName: string; const Args: TArray<TValue>; const matchers : TArray<IMatcher>);
begin
  FExpectationMet := False;
  FHitCount := 0;
  FMethodName := AMethodName;
  CopyArgs(Args);
  FMatchers := matchers;
end;

constructor TExpectation.CreateAfter(const AMethodName : string; const AAfterMethodName: string);
begin
  Create(AMethodName);
  FExpectationType := TExpectationType.After;
  FBeforeAfterMethodName := AAfterMethodName;
end;

constructor TExpectation.CreateAfterWhen(const AMethodName : string; const AAfterMethodName: string;  const Args: TArray<TValue>; const matchers : TArray<IMatcher>);
begin
  CreateWhen(AMethodName, Args, matchers);
  FExpectationType := TExpectationType.AfterWhen;
  FBeforeAfterMethodName := AAfterMethodName;
end;

constructor TExpectation.CreateAtLeast(const AMethodName : string; const times: Cardinal);
begin
  Create(AMethodName);
  FExpectationType := TExpectationType.AtLeast;
  FTimes := times;
end;

constructor TExpectation.CreateAtLeastOnce(const AMethodName : string);
begin
  Create(AMethodName);
  FExpectationType := TExpectationType.AtLeastOnce;
  FTimes := 1;
end;

constructor TExpectation.CreateAtLeastOnceWhen(const AMethodName : string; const Args: TArray<TValue>; const matchers : TArray<IMatcher>);
begin
  CreateWhen(AMethodName, Args, matchers);
  FExpectationType := TExpectationType.AtLeastOnceWhen;
  FTimes := 1;
end;

constructor TExpectation.CreateAtLeastWhen(const AMethodName : string; const times: Cardinal; const Args: TArray<TValue>; const matchers : TArray<IMatcher>);
begin
  CreateWhen(AMethodName, Args, matchers);
  FExpectationType := TExpectationType.AtLeastWhen;
  FTimes := times;
end;

constructor TExpectation.CreateAtMost(const AMethodName : string; const times: Cardinal);
begin
  Create(AMethodName);
  FExpectationType := TExpectationType.AtMost;
  FTimes := times;
end;

constructor TExpectation.CreateAtMostWhen(const AMethodName : string; const times: Cardinal; const Args: TArray<TValue>; const matchers : TArray<IMatcher>);
begin
  CreateWhen(AMethodName, Args, matchers);
  FExpectationType := TExpectationType.AtMostWhen;
  FTimes := times;
end;

constructor TExpectation.CreateBefore(const AMethodName : string; const ABeforeMethodName: string);
begin
  Create(AMethodName);
  FExpectationType  := TExpectationType.Before;
  FBeforeAfterMethodName  := ABeforeMethodName;
end;

constructor TExpectation.CreateBeforeWhen(const AMethodName : string; const ABeforeMethodName: string; const Args: TArray<TValue>; const matchers : TArray<IMatcher>);
begin
  CreateWhen(AMethodName, Args, matchers);
  FExpectationType := TExpectationType.BeforeWhen;
  FBeforeAfterMethodName := ABeforeMethodName;
end;

constructor TExpectation.CreateBetween(const AMethodName : string; const a, b: Cardinal);
begin
  Create(AMethodName);
  FExpectationType := TExpectationType.Between;
  FBetween[0] := a;
  FBetween[1] := b;
end;

constructor TExpectation.CreateBetweenWhen(const AMethodName : string; const a, b: Cardinal; const Args: TArray<TValue>; const matchers : TArray<IMatcher>);
begin
  CreateWhen(AMethodName, Args, matchers);
  FExpectationType := TExpectationType.BetweenWhen;
  FBetween[0] := a;
  FBetween[1] := b;
end;

constructor TExpectation.CreateExactly(const AMethodName : string; const times: Cardinal);
begin
  Create(AMethodName);
  FExpectationType := TExpectationType.Exactly;
  FTimes := times;
end;

constructor TExpectation.CreateExactlyWhen(const AMethodName : string; const times: Cardinal; const Args: TArray<TValue>; const matchers : TArray<IMatcher>);
begin
  CreateWhen(AMethodName, Args, matchers);
  FExpectationType := TExpectationType.ExactlyWhen;
  FTimes := times;
end;

constructor TExpectation.CreateNever(const AMethodName : string) ;
begin
  Create(AMethodName);
  FExpectationType := TExpectationType.Never;
end;

constructor TExpectation.CreateNeverWhen(const AMethodName : string; const Args: TArray<TValue>; const matchers : TArray<IMatcher>);
begin
  CreateWhen(AMethodName, Args, matchers);
  FExpectationType := TExpectationType.NeverWhen;
end;

constructor TExpectation.CreateOnce(const AMethodName : string );
begin
  Create(AMethodName);
  FExpectationType := TExpectationType.Once;
  FTimes := 1;
end;

constructor TExpectation.CreateOnceWhen(const AMethodName : string; const Args: TArray<TValue>; const matchers : TArray<IMatcher>);
begin
  CreateWhen(AMethodName, Args, matchers);
  FExpectationType := TExpectationType.OnceWhen;
  FTimes := 1;
end;

function TExpectation.GetExpectationMet: boolean;
begin
  result := FExpectationMet;
end;

function TExpectation.GetExpectationType: TExpectationType;
begin
  result := FExpectationType;
end;

function TExpectation.Match(const Args: TArray<TValue>): boolean;

  function MatchArgs : boolean;
  var
    i : integer;
  begin
    result := False;
    if Length(Args) <> (Length(FArgs) + 1 ) then
      exit;
    //start at 1 as we don't care about matching the first arg (self)
    for i := 1 to Length(args) -1 do
    begin
      if not FArgs[i -1].Equals(args[i]) then
        exit;
    end;
    result := True;
  end;

  function MatchWithMatchers: Boolean;
  var
    i : integer;
  begin
    result := False;
    for i := 0 to High(FMatchers) do
    begin
      if not FMatchers[i].Match(Args[i+1]) then
        exit;
    end;
    result := True;
  end;
begin
  result := False;
  case FExpectationType of
    Once,
    Never,
    AtLeastOnce,
    AtLeast,
    AtMostOnce,
    AtMost,
    Between,
    Exactly,
    Before,
    After: result := True ;

    OnceWhen,
    NeverWhen,
    AtLeastOnceWhen,
    AtLeastWhen,
    AtMostOnceWhen,
    AtMostWhen,
    BetweenWhen,
    ExactlyWhen,
    BeforeWhen,
    AfterWhen:
    begin
      if Length(FMatchers) > 0 then
        result := MatchWithMatchers
      else
        result := MatchArgs;
    end;
  end;
end;

procedure TExpectation.RecordHit;
begin
  Inc(FHitCount);
  CheckExpectationMet;
end;

procedure TExpectation.CheckExpectationMet;
begin
  case FExpectationType of
    Once,
    OnceWhen: FExpectationMet := FHitCount = 1;
    Never,
    NeverWhen: FExpectationMet := FHitCount = 0;
    AtLeastOnce,
    AtLeastOnceWhen: FExpectationMet := FHitCount >= 1;
    AtLeast,
    AtLeastWhen: FExpectationMet := FHitCount >= FTimes;
    AtMostOnce,
    AtMostOnceWhen: FExpectationMet := FHitCount <= 1;
    AtMost,
    AtMostWhen: FExpectationMet := FHitCount <= FTimes;
    Between,
    BetweenWhen: FExpectationMet := (FHitCount >= FBetween[0]) and (FHitCount <= FBetween[1]);
    Exactly,
    ExactlyWhen: FExpectationMet := FHitCount = FTimes;

    //haven't figure out how to handle these yet.. might need to rethink ordered expectations
    Before,
    BeforeWhen: FExpectationMet := False;
    After,
    AfterWhen: FExpectationMet := False;
  end;

end;

function TExpectation.Report: string;
begin
  result := '';
  if not FExpectationMet then
  begin
     case FExpectationType of
       Once: result := 'Once - Was ' + IntToStr(FHitCount);
       Never: result := 'Never - Was ' + IntToStr(FHitCount);
       AtLeastOnce: result := 'At Least Once';
       AtLeast: result := 'At Least ' + IntToStr(FTimes) + ' Times - Was ' + IntToStr(FHitCount);
       AtMost: result := 'At Most ' + IntToStr(FTimes) + ' Times - Was ' + IntToStr(FHitCount);
       AtMostOnce: result := 'At Most Once - Was ' + IntToStr(FHitCount);
       Between: result := 'Between ' + IntToStr(FBetween[0]) + ' and ' + IntToStr(FBetween[1]) + ' Times - Was ' + IntToStr(FHitCount);
       Exactly: result := 'Exactly ' + IntToStr(FTimes) + ' Times - Was ' + IntToStr(FHitCount);
       Before: result := 'Before Method : ' + FBeforeAfterMethodName;
       After: result := 'After Method : ' + FBeforeAfterMethodName;

       OnceWhen: result := 'Once When' + ArgsToString + ' - Was ' + IntToStr(FHitCount);
       NeverWhen: result := 'Never When' + ArgsToString + ' - Was ' + IntToStr(FHitCount);
       AtLeastOnceWhen: result := 'At Least Once When' + ArgsToString;
       AtLeastWhen: result := 'At Least ' + IntToStr(FTimes) + ' Times When ' + ArgsToString + ' - Was ' + IntToStr(FHitCount);
       AtMostOnceWhen: result := 'At Most Once When' + ArgsToString + ' - Was ' + IntToStr(FHitCount);
       AtMostWhen: result := 'At Most ' + IntToStr(FTimes) + ' Times When ' + ArgsToString + ' - Was ' + IntToStr(FHitCount);
       BetweenWhen: result := 'Between ' + IntToStr(FBetween[0]) + ' and ' + IntToStr(FBetween[1]) + ' Times When' + ArgsToString + ' - Was ' + IntToStr(FHitCount);
       ExactlyWhen: result := 'Exactly ' + IntToStr(FTimes) + ' Times When' + ArgsToString + ' - Was ' + IntToStr(FHitCount);
       BeforeWhen: result := 'Before Method : ' + FBeforeAfterMethodName + ' When ' + ArgsToString;
       AfterWhen: result := 'After Method : ' + FBeforeAfterMethodName + ' When ' + ArgsToString;
     end;
    result := 'Expectation [ ' + result + ' ] was not met.';
  end;

end;

end.
