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

unit Delphi.Mocks.ParamMatcher;

interface

uses
  Generics.Collections,
  SysUtils,
  TypInfo,
  Rtti;


type
  IMatcher = interface
    ['{C0F66756-F6DF-44D2-B3FC-E6B60F843D23}']
    function Match(const value : TValue) : boolean;
  end;

  TMatcher<T> = class(TInterfacedObject, IMatcher)
  private
    FPredicate : TPredicate<T>;
  protected
    function Match(const value : TValue) : boolean;
  public
    constructor Create(const predicate : TPredicate<T>);
  end;

  TMatcherFactory = class
  private
    class var
       FMatchers : TObjectDictionary<TThreadID,TList<IMatcher>>;
       FLock     : TObject;
  protected
    class constructor Create;
    class destructor Destroy;
    class procedure AddMatcher(const paramIndex : integer;  const matcher : IMatcher);
  public
    class procedure Create<T>(const paramIndex : integer; const predicate: TPredicate<T>);
    class function  GetMatchers : TArray<IMatcher>;
  end;


implementation

uses
  Classes,
  SyncObjs;


{ TMatcherFactory }

class procedure TMatcherFactory.Create<T>(const paramIndex : integer; const predicate: TPredicate<T>);
var
  matcher : IMatcher;
begin
  matcher := TMatcher<T>.Create(predicate);
  AddMatcher(paramIndex, matcher);
end;

{ TMatcher<T> }

constructor TMatcher<T>.Create(const predicate: TPredicate<T>);
begin
  FPredicate := predicate;
end;

function TMatcher<T>.Match(const value: TValue): boolean;
begin
  result := FPredicate(value.AsType<T>);
end;

class constructor TMatcherFactory.Create;
begin
  FMatchers := TObjectDictionary<TThreadID,TList<IMatcher>>.Create([doOwnsValues]);
  FLock     := TObject.Create;
end;

class destructor TMatcherFactory.Destroy;
var
  pair : TPair<TThreadID,TList<IMatcher>>;
begin
  for pair in FMatchers do
    pair.Value.Free;
  FMatchers.Free;
  FLock.Free;
end;

class function TMatcherFactory.GetMatchers : TArray<IMatcher>;
var
  threadMatchers : TList<IMatcher>;
begin
  SetLength(result,0);
  MonitorEnter(FLock);
  try
    if FMatchers.TryGetValue(TThread.CurrentThread.ThreadID,threadMatchers) then
    begin
      result := threadMatchers.ToArray;
      FMatchers.Remove(TThread.CurrentThread.ThreadID);
    end;
  finally
    MonitorExit(FLock);
  end;
end;

class procedure TMatcherFactory.AddMatcher(const paramIndex : integer; const matcher : IMatcher);
var
  threadMatchers : TList<IMatcher>;
begin
  MonitorEnter(FLock);
  try
    if not FMatchers.TryGetValue(TThread.CurrentThread.ThreadID,threadMatchers) then
    begin
      threadMatchers := TList<IMatcher>.Create;
      FMatchers.Add(TThread.CurrentThread.ThreadID,threadMatchers);
    end;

    while paramIndex > threadMatchers.Count - 1 do
      threadMatchers.Add(nil);

    if threadMatchers[paramIndex] = nil then
      threadMatchers[paramIndex] := matcher
    else
      threadMatchers.Insert(paramIndex, matcher);

  finally
    MonitorExit(FLock);
  end;
end;

end.
