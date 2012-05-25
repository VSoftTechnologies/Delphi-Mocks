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
  TypInfo;

function CheckInterfaceHasRTTI(const info : PTypeInfo) : boolean;

function GetVirtualMethodCount(AClass: TClass): Integer;

implementation

uses
  SysUtils,
  RTTI;

function CheckInterfaceHasRTTI(const info : PTypeInfo) : boolean;
var
  rType : TRttiType;
  ctx : TRttiContext;
  methods : TArray<TRttiMethod>;
begin
  ctx := TRttiContext.Create;
  rType := ctx.GetType(info);
  methods := rType.GetDeclaredMethods;
  result := Length(methods) > 0;
end;

//courtesy of Allen Bauer on stackoverflow
//http://stackoverflow.com/questions/760513/where-can-i-find-information-on-the-structure-of-the-delphi-vmt
function GetVirtualMethodCount(AClass: TClass): Integer;
begin
  Result := (PInteger(Integer(AClass) + vmtClassName)^ -
    (Integer(AClass) + vmtParent) - SizeOf(Pointer)) div SizeOf(Pointer);
end;




end.
