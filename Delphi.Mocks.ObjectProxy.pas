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

unit Delphi.Mocks.ObjectProxy;

interface

uses
  Rtti,
  SysUtils,
  Generics.Collections,
  Delphi.Mocks,
  Delphi.Mocks.Interfaces,
  Delphi.Mocks.ProxyBase,
  Delphi.Mocks.VirtualMethodInterceptor;

type
  TObjectProxy<T> = class(TBaseProxy<T>)
  private
    FInstance : T;
    FVMInterceptor : TVirtualMethodInterceptor;
    function FindConstructor(ARttiType: TRttiType): TRttiMethod;
  protected
     procedure DoBefore(Instance: TObject; Method: TRttiMethod; const Args: TArray<TValue>; out DoInvoke: Boolean; out Result: TValue);
     function Proxy : T;override;
  public
    constructor Create(const AIsStubOnly : boolean = false);override;
    destructor Destroy;override;
  end;


implementation

uses
  TypInfo;

{ TObjectProxy<T> }

constructor TObjectProxy<T>.Create(const AIsStubOnly : boolean);
var
  ctx   : TRttiContext;
  rType : TRttiType;
  ctor : TRttiMethod;
  instance : TValue;
begin
  inherited Create(AIsStubOnly);
  ctx := TRttiContext.Create;
  rType := ctx.GetType(TypeInfo(T));
  if rType = nil then
    raise EMockNoRTTIException.Create('No TypeInfo found for T');

  ctor := FindConstructor(rType);
  if ctor = nil then
    raise EMockException.Create('Could not find constructor Create on type ' + rType.Name);

  instance := ctor.Invoke(rType.AsInstance.MetaclassType, []);

  FInstance := instance.AsType<T>();
  FVMInterceptor := TVirtualMethodInterceptor.Create(rType.AsInstance.MetaclassType);

  FVMInterceptor.Proxify(instance.AsObject);
  FVMInterceptor.OnBefore := DoBefore;
end;

destructor TObjectProxy<T>.Destroy;
begin
  TObject(Pointer(@FInstance)^).Free;//always destroy the instance before the interceptor.
  FVMInterceptor.Free;
  inherited;
end;

procedure TObjectProxy<T>.DoBefore(Instance: TObject; Method: TRttiMethod; const Args: TArray<TValue>; out DoInvoke: Boolean; out Result: TValue);
var
  vArgs: TArray<TValue>;
  i: Integer;
begin
  //don't intercept the TObject methods like BeforeDestruction etc.
  if Method.Parent.AsInstance.MetaclassType <> TObject then
  begin
    DoInvoke := False; //don't call the actual method.

    //Included instance as first argument because TExpectation.Match
    //deduces that the first argument is the object instance.
    SetLength(vArgs, Length(Args)+1);
    vArgs[0] := Instance;
    for i := Low(Args) to High(Args) do
    begin
      vArgs[i+1] := Args[i];
    end;

    Self.DoInvoke(Method,VArgs,Result);
  end;
end;

function TObjectProxy<T>.FindConstructor(ARttiType: TRttiType): TRttiMethod;
var
  candidateCtor: TRttiMethod;
begin
  Result := nil;
  for candidateCtor in ARttiType.GetMethods('Create') do
  begin
    if Length(candidateCtor.GetParameters) = 0 then
    begin
      Result := candidateCtor;
      Break;
    end;
  end;
end;

function TObjectProxy<T>.Proxy: T;
begin
  result := FInstance;
end;

end.

