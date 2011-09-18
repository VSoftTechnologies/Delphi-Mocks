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

unit Delphi.Mocks.Helpers;

interface

uses
  Rtti;

type
  TValueHelper = record helper for TValue
    function Equals(const value : TValue) : boolean;
  end;


  TRttiTypeHelper = class helper for TRttiType
    function TryGetMethod(const AName: string; out AMethod: TRttiMethod): Boolean;
  end;


implementation

uses
  SysUtils,
  TypInfo;

{ TValueHelper }

function TValueHelper.Equals(const value : TValue) : boolean;
begin
  if Self.IsEmpty and value.IsEmpty then
    exit(true);

  //Is this too simplistic??
  Exit(SameText(Self.ToString, value.ToString));


//
//  if value.IsEmpty then
//    exit;
//
//  //check the type
//  if Self.Kind <> value.Kind then
//    exit;
//
//  if (Self.IsObject and Value.IsObject) then
//    Exit(Self.AsObject = Value.AsObject);
//
//  if (Self.IsOrdinal and Value.IsOrdinal) then
//    Exit(Self.AsOrdinal = Value.AsOrdinal);
//
//  if (Self.IsClass and value.IsClass) then
//    Exit(Self.AsClass = value.AsClass);
//
//  //not sure if this is right.
//  if (Self.Kind = tkInterface) and (value.Kind = tkInterface) then
//    Exit(Pointer(Self.AsInterface) = Pointer(Value.AsInterface));
//
//  if (Self.Kind in [tkUString,tkString]) and (value.Kind in [tkUString,tkString]) then
//    Exit(SameText(Self.AsString,value.AsString));
//
//  if (Self.Kind = tkVariant) and (value.Kind = tkVariant) then
//    result := Self.AsVariant = value.AsVariant;
//

end;

{ TRttiTypeHelper }

function TRttiTypeHelper.TryGetMethod(const AName: string; out AMethod: TRttiMethod): Boolean;
begin
  AMethod := GetMethod(AName);
  Result := Assigned(AMethod);
end;

end.
