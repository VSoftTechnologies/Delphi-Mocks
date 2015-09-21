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


unit Delphi.Mocks.Utils;

interface

uses
  TypInfo,
  RTTI;

function CheckInterfaceHasRTTI(const info : PTypeInfo) : boolean;

function CheckClassHasRTTI(const info: PTypeInfo): boolean;

function GetVirtualMethodCount(AClass: TClass): Integer;

function GetDefaultValue(const rttiType : TRttiType) : TValue;

function ArgsToString(const Args: TArray<TValue>; OffSet: Integer = 0): string;

implementation

uses
  Variants,
  SysUtils;

function CheckInterfaceHasRTTI(const info : PTypeInfo) : boolean;
var
  rType : TRttiType;
  ctx : TRttiContext;
  methods : TArray<TRttiMethod>;
begin
  ctx := TRttiContext.Create;
  rType := ctx.GetType(info);
  methods := rType.GetMethods;

  result := Length(methods) > 0;
end;

function CheckClassHasRTTI(const info: PTypeInfo): boolean;
var
  rType : TRttiType;
  ctx : TRttiContext;
  rttiMethods : TArray<TRttiMethod>;
  rttiTObjectMethods : TArray<TRttiMethod>;
  virtualMethods : Integer;

  rTObjectType : TRttiType;

begin
  ctx := TRttiContext.Create;
  rType := ctx.GetType(info);
  rttiMethods := rType.GetMethods;

  rTObjectType := ctx.GetType(TypeInfo(TObject));

  rttiTObjectMethods := rTObjectType.GetMethods;


  virtualMethods := GetVirtualMethodCount(GetTypeData(info).ClassType);

  result := (virtualMethods > 12);// and (Length(rttiMethods) > Length(rttiTObjectMethods));
end;


//courtesy of Allen Bauer on stackoverflow
//http://stackoverflow.com/questions/760513/where-can-i-find-information-on-the-structure-of-the-delphi-vmt
function GetVirtualMethodCount(AClass: TClass): Integer;
begin
  //Note that this returns all virtual methods in the class, including those from the base class.
  //Therefore anything that inherits from TObject will have atleast 12 virtual methods already
  Result := (PInteger(Integer(AClass) + vmtClassName)^ -
    (Integer(AClass) + vmtParent) - SizeOf(Pointer)) div SizeOf(Pointer);
end;

//TODO : There must be a better way than this. How does Default(X) work? Couldn't find the implementation.
function GetDefaultValue(const rttiType : TRttiType) : TValue;
begin
  result := TValue.Empty;
  case rttiType.TypeKind of
    tkUnknown: ;
    tkInteger:  result := TValue.From<integer>(0);
    tkChar: result := TValue.From<Char>(#0);
    tkEnumeration: result := TValue.FromOrdinal(rttiType.Handle,rttiType.AsOrdinal.MinValue);
    tkFloat: result := TValue.From<Extended>(0);
    tkString: result := TValue.From<string>('');
    tkSet: result := TValue.FromOrdinal(rttiType.Handle,rttiType.AsOrdinal.MinValue);
    tkClass: result := TValue.From<TObject>(nil);
    tkMethod: result := TValue.From<TObject>(nil);
    tkWChar: result := TValue.From<WideChar>(#0);
    tkLString: result := TValue.From<string>('');
    tkWString: result := TValue.From<string>('');
    tkVariant: result := TValue.From<Variant>(null);
    tkArray: ;
    tkRecord: ;
    tkInterface: result := TValue.From<IInterface>(nil);
    tkInt64: result := TValue.FromOrdinal(rttiType.Handle,0);
    tkDynArray: ;
    tkUString: result := TValue.From<string>('');
    tkClassRef: result := TValue.From<TClass>(nil);
    tkPointer: result := TValue.From<Pointer>(nil);
    tkProcedure: result := TValue.From<Pointer>(nil);
  end;
end;

function ArgsToString(const Args: TArray<TValue>; OffSet: Integer = 0): string;
var
  i : integer;
begin
  result := EmptyStr;
  for i := Low(Args) + OffSet to High(Args) do
  begin
    if (result <> EmptyStr) then
      result := result + ', ';
    result := result + Args[i].ToString;
  end;
  result := '( ' + result + ' )';
end;

end.
