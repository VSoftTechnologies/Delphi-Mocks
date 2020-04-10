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
  TypInfo,
  Generics.Collections,
  Delphi.Mocks,
  Delphi.Mocks.Interfaces,
  Delphi.Mocks.Proxy,
  Delphi.Mocks.VirtualMethodInterceptor;

type
  TObjectProxy<T> = class(TProxy<T>)
  private
    FInstance : T;
    FVMInterceptor : TVirtualMethodInterceptor;
  protected
    procedure DoBefore(Instance: TObject; Method: TRttiMethod; const Args: TArray<TValue>; out DoInvoke: Boolean; out Result: TValue);
    function Proxy : T; override;
  public
    constructor Create( const ACreateFunc: TFunc<T>; const AAutoMocker : IAutoMock = nil; const AIsStubOnly : boolean = false); reintroduce;
    destructor Destroy; override;
  end;

implementation

uses
  Delphi.Mocks.Helpers;

{ TObjectProxy<T> }

constructor TObjectProxy<T>.Create(const ACreateFunc: TFunc<T>; const AAutoMocker : IAutoMock; const AIsStubOnly : boolean);
var
  ctx   : TRttiContext;
  rType : TRttiType;
  ctor : TRttiMethod;
  instance : TValue;
begin
  inherited Create(AAutoMocker, AIsStubOnly);
  ctx := TRttiContext.Create;
  rType := ctx.GetType(TypeInfo(T));
  if rType = nil then
    raise EMockNoRTTIException.Create('No TypeInfo found for T');

  if not Assigned(ACreateFunc) then
  begin
    ctor := rType.FindConstructor;
    if ctor = nil then
      raise EMockException.Create('Could not find constructor Create on type ' + rType.Name);

    instance := ctor.Invoke(rType.AsInstance.MetaclassType, []);
  end
  else
    instance := TValue.From<T>(ACreateFunc);
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
  i, l: Integer;
begin
  //don't intercept the TObject methods like BeforeDestruction etc.
  if Method.Parent.AsInstance.MetaclassType <> TObject then
  begin
    DoInvoke := False; //don't call the actual method.

    //Included instance as first argument because TExpectation.Match
    //deduces that the first argument is the object instance.
    l := Length(Args);
    SetLength(vArgs, l+1);
    vArgs[0] := Instance;

    for i := 1 to l do
    begin
      vArgs[i] := Args[i-1];
    end;

    Self.DoInvoke(Method,vArgs,Result);

    for i := 1 to l do
    begin
      Args[i-1] := vArgs[i];
    end;
  end;
end;

function TObjectProxy<T>.Proxy: T;
begin
  result := FInstance;
end;

end.

