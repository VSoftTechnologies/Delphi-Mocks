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

unit Delphi.Mocks.Behavior;

interface

uses
  Rtti,
  SysUtils,
  Delphi.Mocks,
  Delphi.Mocks.Interfaces,
  Delphi.Mocks.ParamMatcher;

type
  TBehavior = class(TInterfacedObject,IBehavior)
  private
    FAction : TExecuteFunc;
    FExceptClass : ExceptClass;
    FExceptionMessage : string;
    FReturnValue : TValue;
    FArgs : TArray<TValue>;
    FBehaviorType : TBehaviorType;
    FHitCount : integer;
    FMatchers : TArray<IMatcher>;
  protected
    function GetBehaviorType: TBehaviorType;
    function Match(const Args: TArray<TValue>): Boolean;
    function Execute(const Args: TArray<TValue>; const returnType: TRttiType): TValue;
    procedure CopyArgs(const Args: TArray<TValue>);
  public
    //disable warnings about c++ compatibility, since we don't intend to support it.
    {$WARN DUPLICATE_CTOR_DTOR OFF}
    constructor CreateWillExecute(const AAction: TExecuteFunc);
    constructor CreateWillExecuteWhen(const Args: TArray<TValue>; const AAction: TExecuteFunc; const matchers : TArray<IMatcher>);
    constructor CreateWillReturnWhen(const Args: TArray<TValue>; const ReturnValue: TValue; const matchers : TArray<IMatcher>);
    constructor CreateReturnDefault(const ReturnValue: TValue);
    constructor CreateWillRaise(const AExceptClass : ExceptClass; const message : string);
    constructor CreateWillRaiseWhen(const Args: TArray<TValue>; const AExceptClass : ExceptClass; const message : string; const matchers : TArray<IMatcher>);
  end;

implementation

uses
  Delphi.Mocks.Helpers;

{ TBehavior }

procedure TBehavior.CopyArgs(const Args: TArray<TValue>);
var
  l : integer;
begin
  //Note : Args[0] is the Self Ptr for the proxy, we do not want to keep
  //a reference to it so it is ignored here.
  l := Length(args);
  if l > 0 then
  begin
    SetLength(FArgs,l);
    CopyArray(@FArgs[0],@args[0],TypeInfo(TValue),l);
  end;
end;

constructor TBehavior.CreateReturnDefault(const ReturnValue: TValue);
begin
  FBehaviorType := TBehaviorType.ReturnDefault;
  FReturnValue := ReturnValue;
end;

constructor TBehavior.CreateWillExecute(const AAction: TExecuteFunc);
begin
  FBehaviorType := TBehaviorType.WillExecute;
  FAction := AAction;
  FHitCount := 0;
end;

constructor TBehavior.CreateWillExecuteWhen(const Args: TArray<TValue>; const AAction: TExecuteFunc; const matchers : TArray<IMatcher>);
begin
  FBehaviorType := TBehaviorType.WillExecuteWhen;
  CopyArgs(Args);
  FAction := AAction;
  FHitCount := 0;
  FMatchers := matchers;
end;

constructor TBehavior.CreateWillRaise(const AExceptClass: ExceptClass; const message : string);
begin
  FBehaviorType := TBehaviorType.WillRaiseAlways;
  FExceptClass := AExceptClass;
  FExceptionMessage := message;
  FHitCount := 0;
end;

constructor TBehavior.CreateWillRaiseWhen(const Args: TArray<TValue>; const AExceptClass: ExceptClass; const message : string; const matchers : TArray<IMatcher>);
begin
  FBehaviorType := TBehaviorType.WillRaise;
  FExceptClass := AExceptClass;
  FExceptionMessage := message;
  CopyArgs(Args);
  FHitCount := 0;
  FMatchers := matchers;
end;

constructor TBehavior.CreateWillReturnWhen(const Args: TArray<TValue>; const ReturnValue: TValue; const matchers : TArray<IMatcher>);
begin
  FBehaviorType := TBehaviorType.WillReturn;
  CopyArgs(Args);
  FReturnValue := ReturnValue;
  FHitCount := 0;
  FMatchers := matchers;
end;

function TBehavior.Execute(const Args: TArray<TValue>; const returnType: TRttiType): TValue;
var
  msg : string;
begin
  result := TValue.Empty;
  try
    case FBehaviorType of
      WillReturn: result := FReturnValue;
      ReturnDefault: result := FReturnValue;
      WillRaise,WillRaiseAlways:
      begin
         if FExceptClass <> nil then
         begin
           if FExceptionMessage <> '' then
             msg := FExceptionMessage
           else
             msg := 'raised by mock';
           raise FExceptClass.Create(msg);
         end;
      end;
      WillExecute,WillExecuteWhen:
      begin
        if Assigned(FAction) then
          result := FAction(args,returnType);
      end;
    else
      // Hitcount Only
    end;
  finally
    //needs the finally as we may raise an exception above!
    Inc(FHitCount);
  end;

end;

function TBehavior.GetBehaviorType: TBehaviorType;
begin
  Result := FBehaviorType;
end;

function TBehavior.Match(const Args: TArray<TValue>): Boolean;

  function MatchArgs : boolean;
  var
    i : integer;
  begin
    result := False;
    if Length(Args) <> (Length(FArgs)) then
      exit;
    for i := 0 to Length(args) -1 do
    begin
      if not FArgs[i].Equals(args[i]) then
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

  if (Length(FMatchers) > 0) and (Length(Args) = (Length(FMatchers) + 1)) then
  begin
    result := MatchWithMatchers;
    exit;
  end;

  case FBehaviorType of
    WillReturn      : result := MatchArgs;
    ReturnDefault   : result := True;
    WillRaise       :
    begin
      result := MatchArgs;
      if FExceptClass <> nil then
        raise FExceptClass.Create('Raised by Mock');
    end;
    WillRaiseAlways : result := True;
    WillExecuteWhen : result := MatchArgs;
    WillExecute     : result := True;
  end;
end;

end.
