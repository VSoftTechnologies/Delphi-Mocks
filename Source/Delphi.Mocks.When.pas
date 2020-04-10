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

unit Delphi.Mocks.When;

interface

uses
  Delphi.Mocks;

type
  TWhen<T> = class(TInterfacedObject,IWhen<T>)
  private
   FProxy : T;
  protected
   function When : T;
  public
    constructor Create(const AProxy : T);
    destructor Destroy;override;
  end;

implementation

uses
  SysUtils;

{ TWhen<T> }

constructor TWhen<T>.Create(const AProxy: T);
begin
  FProxy := AProxy;
end;

destructor TWhen<T>.Destroy;
begin
  FProxy := Default(T);
  inherited;
end;

function TWhen<T>.When: T;
begin
  result := FProxy;
end;

end.
