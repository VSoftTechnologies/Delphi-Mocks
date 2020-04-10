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
  This unit courtesy of Stefen Glienke.

  This unit is a work around for QC98687 where RTTI is not generated for
  return types which are alias's of a generic type.

  http://qc.embarcadero.com/wc/qcmain.aspx?d=98687

  Usage :

  TOnFinalizedEvent = TMulticastEvent<TEventArgs>;

type // <- mandatory otherwise you get: E2086 Type 'TMulticastEvent<T>' is not yet completely defined
  {$M+}
  ISomeInterface = interface
    ['{7620908B-6DB7-4616-9A6F-AB2934F67077}']
    [ReturnTypePatch(TypeInfo(TOnFinalizedEvent))] //<<<
    function GetOnFinalized: TOnFinalizedEvent;
    property OnFinalized: TOnFinalizedEvent read GetOnFinalized;
  end;

initialization
  PatchMethodReturnType(TypeInfo(ISomeInterface));

*)

unit Delphi.Mocks.ReturnTypePatch;

interface

uses
  Rtti,
  TypInfo;

type
  ReturnTypePatchAttribute = class(TCustomAttribute)
  private
    FReturnType: PTypeInfo;
  public
    constructor Create(ATypeInfo: PTypeInfo);
  end;

procedure PatchMethodReturnType(ATypeInfo: PTypeInfo); overload;
procedure PatchMethodReturnType(const ATypeInfo: PTypeInfo; const AMethodName : string; const AReturnType: PTypeInfo); overload;
procedure PatchMethodReturnType(AMethod: TRttiMethod; AReturnType: PTypeInfo); overload;

implementation

uses
  Windows;

type
  TRttiIntfMethod = class(TRttiMethod)
  public
    FTail: PIntfMethodEntryTail;
    FParameters: TArray<TRttiParameter>;
    FReturnType: PTypeInfo;
  end;

var
  ReturnTypes: array of PPTypeInfo;

procedure Finalize;
var
  i: Integer;
begin
  for i := High(ReturnTypes) downto Low(ReturnTypes) do
    Dispose(ReturnTypes[i]);
end;

function NeedsPatch(AMethod: TRttiMethod): Boolean;
begin
  Result := (AMethod.MethodKind = mkFunction) and (AMethod.ReturnType = nil);
end;

procedure PatchMethodReturnType(const ATypeInfo: PTypeInfo; const AMethodName : string; const AReturnType: PTypeInfo); overload;
var
  LContext: TRttiContext;
  LMethod: TRttiMethod;
begin
  for LMethod in LContext.GetType(ATypeInfo).GetDeclaredMethods do
  begin
    if LMethod.Name = AMethodName then
    begin
      if NeedsPatch(LMethod) then
      begin
        PatchMethodReturnType(LMethod, AReturnType);
      end;
    end;
  end;
  LContext.Free;
end;


procedure PatchMethodReturnType(ATypeInfo: PTypeInfo);
var
  LContext: TRttiContext;
  LMethod: TRttiMethod;
  LAttribute: TCustomAttribute;
begin
  for LMethod in LContext.GetType(ATypeInfo).GetDeclaredMethods do
  begin
    if NeedsPatch(LMethod) then
    begin
      for LAttribute in LMethod.GetAttributes do
      begin
        if LAttribute is ReturnTypePatchAttribute then
          PatchMethodReturnType(LMethod, ReturnTypePatchAttribute(LAttribute).FReturnType);
      end;
    end;
  end;
  LContext.Free;
end;

procedure PatchMethodReturnType(AMethod: TRttiMethod; AReturnType: PTypeInfo);
var
  p: PByte;
  i: Integer;
  LByteCount: NativeUInt;
  LReturnType: PPTypeInfo;

  procedure SkipShortString(var p: PByte);
  begin
    Inc(p, p[0] + 1);
  end;

begin
  if not NeedsPatch(AMethod) then
    Exit;

  Pointer(p) := TRttiIntfMethod(AMethod).FTail;
  Inc(p, SizeOf(TIntfMethodEntryTail));

  for i := 0 to TRttiIntfMethod(AMethod).FTail.ParamCount - 1 do
  begin
    Inc(p);                     // Flags
    SkipShortString(p);         // ParamName
    SkipShortString(p);         // TypeName
    Inc(p, SizeOf(PTypeInfo));  // ParamType
    Inc(p, PWord(p)^);          // AttrData
  end;

  LReturnType := nil;

  for i := Low(ReturnTypes) to High(ReturnTypes) do
  begin
    if ReturnTypes[i]^ = AReturnType then
    begin
      LReturnType := ReturnTypes[i];
      Break;
    end;
  end;

  if LReturnType = nil then
  begin
    i := Length(ReturnTypes);
    SetLength(ReturnTypes, i + 1);
    New(LReturnType);
    LReturnType^ := AReturnType;
    ReturnTypes[i] := LReturnType;
  end;

  SkipShortString(p);
  WriteProcessMemory(GetCurrentProcess, p, @LReturnType, SizeOf(Pointer), LByteCount);
  TRttiIntfMethod(AMethod).FReturnType := LReturnType^;
end;

constructor ReturnTypePatchAttribute.Create(ATypeInfo: PTypeInfo);
begin
  FReturnType := ATypeInfo;
end;

initialization

finalization
  Finalize;

end.
