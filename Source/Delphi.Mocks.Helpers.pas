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

(*
  SameValue/CompareValue Copyright (c) 2011, Stefan Glienke
  Used with permission.
*)

unit Delphi.Mocks.Helpers;

interface

uses
  Rtti;

type
  //TValue really needs to have an Equals operator overload!
  TValueHelper = record helper for TValue
    private
    function GetRttiType: TRttiType;
  public
    function Equals(const value : TValue) : boolean;
    function IsFloat: Boolean;
    function IsNumeric: Boolean;
    function IsPointer: Boolean;
    function IsString: Boolean;
    function IsBoolean: Boolean;
    function IsByte: Boolean;
    function IsCardinal: Boolean;
    function IsCurrency: Boolean;
    function IsDate: Boolean;
    function IsDateTime: Boolean;
    function IsDouble: Boolean;
    function IsInteger: Boolean;
    function IsInt64: Boolean;
    function IsShortInt: Boolean;
    function IsSingle: Boolean;
    function IsSmallInt: Boolean;
    function IsTime: Boolean;
    function IsUInt64: Boolean;
    function IsVariant: Boolean;
    function IsWord: Boolean;
  	function IsGuid: Boolean;
    function IsInterface : Boolean;
    function AsDouble: Double;
    function AsFloat: Extended;
    function AsSingle: Single;
    function AsPointer: Pointer;
    property RttiType: TRttiType read GetRttiType;
  end;


  TRttiTypeHelper = class helper for TRttiType
    function TryGetMethod(const AName: string; out AMethod: TRttiMethod): Boolean;
    function FindConstructor : TRttiMethod;
  end;


function CompareValue(const Left, Right: TValue): Integer;
function SameValue(const Left, Right: TValue): Boolean;


implementation

uses
  SysUtils,
  Math,
  TypInfo,
  Variants,
  StrUtils;

var
  Context : TRttiContext;

//adapted from Spring4D

function CompareValue(const Left, Right: TValue): Integer;
const
  EmptyResults: array[Boolean, Boolean] of Integer = ((0, -1), (1, 0));
var
  leftIsEmpty, rightIsEmpty: Boolean;
begin
  leftIsEmpty := left.IsEmpty;
  rightIsEmpty := right.IsEmpty;
  if leftIsEmpty or rightIsEmpty then
    Result := EmptyResults[leftIsEmpty, rightIsEmpty]
  else if left.IsOrdinal and right.IsOrdinal then
    Result := Math.CompareValue(left.AsOrdinal, right.AsOrdinal)
  else if left.IsFloat and right.IsFloat then
    Result := Math.CompareValue(left.AsExtended, right.AsExtended)
  else if left.IsString and right.IsString then
    Result := SysUtils.AnsiCompareStr(left.AsString, right.AsString)
  else if left.IsObject and right.IsObject then
    Result := NativeInt(left.AsObject) - NativeInt(right.AsObject) // TODO: instance comparer
  else if Left.IsInterface and Right.IsInterface then
    Result := NativeInt(left.AsInterface) - NativeInt(right.AsInterface) // TODO: instance comparer
  else if left.IsVariant and right.IsVariant then
  begin
    case VarCompareValue(left.AsVariant, right.AsVariant) of
      vrEqual: Result := 0;
      vrLessThan: Result := -1;
      vrGreaterThan: Result := 1;
      vrNotEqual: Result := -1;
    else
      Result := 0;
    end;
  end else
    Result := 0;
end;

function SameValue(const Left, Right: TValue): Boolean;
begin
  if Left.IsGuid and Right.IsGuid then
    Result := IsEqualGuid( Left.AsType<TGUID>, Right.AsType<TGUID> )
  else
    result := CompareValue(left, right) = 0;
end;

{ TValueHelper }

function TValueHelper.AsDouble: Double;
begin
  Result := AsType<Double>;
end;

function TValueHelper.AsFloat: Extended;
begin
  Result := AsType<Extended>;
end;

function TValueHelper.AsPointer: Pointer;
begin
  ExtractRawDataNoCopy(@Result);
end;

function TValueHelper.AsSingle: Single;
begin
  Result := AsType<Single>;
end;

function TValueHelper.Equals(const value : TValue) : boolean;
begin
  result := SameValue(Self, value);
end;

function TValueHelper.GetRttiType: TRttiType;
begin
   Result := Context.GetType(TypeInfo);

end;

function TValueHelper.IsBoolean: Boolean;
begin
  Result := TypeInfo = System.TypeInfo(Boolean);
end;

function TValueHelper.IsByte: Boolean;
begin
  Result := TypeInfo = System.TypeInfo(Byte);
end;

function TValueHelper.IsCardinal: Boolean;
begin
  Result := TypeInfo = System.TypeInfo(Cardinal);
end;

function TValueHelper.IsCurrency: Boolean;
begin
  Result := TypeInfo = System.TypeInfo(Currency);
end;

function TValueHelper.IsDate: Boolean;
begin
  Result := TypeInfo = System.TypeInfo(TDate);
end;

function TValueHelper.IsDateTime: Boolean;
begin
  Result := TypeInfo = System.TypeInfo(TDateTime);
end;

function TValueHelper.IsDouble: Boolean;
begin
  Result := TypeInfo = System.TypeInfo(Double);
end;

function TValueHelper.IsFloat: Boolean;
begin
  Result := Kind = tkFloat;
end;

function TValueHelper.IsInt64: Boolean;
begin
  Result := TypeInfo = System.TypeInfo(Int64);
end;

function TValueHelper.IsInteger: Boolean;
begin
  Result := TypeInfo = System.TypeInfo(Integer);
end;

function TValueHelper.IsInterface: Boolean;
begin
  Result := Kind = tkInterface;
end;

function TValueHelper.IsNumeric: Boolean;
begin
  Result := Kind in [tkInteger, tkChar, tkEnumeration, tkFloat, tkWChar, tkInt64];
end;

function TValueHelper.IsPointer: Boolean;
begin
  Result := Kind = tkPointer;
end;

function TValueHelper.IsShortInt: Boolean;
begin
  Result := TypeInfo = System.TypeInfo(ShortInt);
end;

function TValueHelper.IsSingle: Boolean;
begin
  Result := TypeInfo = System.TypeInfo(Single);
end;

function TValueHelper.IsSmallInt: Boolean;
begin
  Result := TypeInfo = System.TypeInfo(SmallInt);
end;

function TValueHelper.IsString: Boolean;
begin
  Result := Kind in [tkChar, tkString, tkWChar, tkLString, tkWString, tkUString];
end;

function TValueHelper.IsTime: Boolean;
begin
  Result := TypeInfo = System.TypeInfo(TTime);
end;

function TValueHelper.IsUInt64: Boolean;
begin
  Result := TypeInfo = System.TypeInfo(UInt64);
end;

function TValueHelper.IsVariant: Boolean;
begin
  Result := TypeInfo = System.TypeInfo(Variant);
end;

function TValueHelper.IsWord: Boolean;
begin
  Result := TypeInfo = System.TypeInfo(Word);
end;


function TValueHelper.IsGuid: Boolean;
begin
  Result := TypeInfo = System.TypeInfo(TGUID);
end;



{ TRttiTypeHelper }

function TRttiTypeHelper.FindConstructor: TRttiMethod;
var
  candidateCtor: TRttiMethod;
begin
  Result := nil;
  for candidateCtor in GetMethods('Create') do
  begin
    if Length(candidateCtor.GetParameters) = 0 then
    begin
      Result := candidateCtor;
      Break;
    end;
  end;
end;

function TRttiTypeHelper.TryGetMethod(const AName: string; out AMethod: TRttiMethod): Boolean;
begin
  AMethod := GetMethod(AName);
  Result := Assigned(AMethod);
end;

end.
