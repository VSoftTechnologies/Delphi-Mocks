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

unit Delphi.Mocks.InterfaceProxy;

interface

uses
  Rtti,
  SysUtils,
  Delphi.Mocks,
  Delphi.Mocks.Interfaces,
  Delphi.Mocks.VirtualInterface,
  Delphi.Mocks.ProxyBase;

type
  TProxyBaseInvokeEvent = procedure (Method: TRttiMethod; const Args: TArray<TValue>; out Result: TValue) of object;

  TSetupMode = (None,Behavior,Expectation);

  TInterfaceProxy<T> = class(TBaseProxy<T>)
  private type
   TProxyVirtualInterface = class(TVirtualInterface)
    private
      FProxy : TInterfaceProxy<T>;
    protected
    public
      function QueryInterface(const IID: TGUID; out Obj): HRESULT; override; stdcall;
      constructor Create(AProxy : TInterfaceProxy<T>; AInterface: Pointer; InvokeEvent: TVirtualInterfaceInvokeEvent);
    end;
  private
    FVirtualInterface : IInterface;
  protected
    function InternalQueryInterface(const IID: TGUID; out Obj): HRESULT; stdcall;
    function QueryInterface(const IID: TGUID; out Obj): HRESULT; override;
    function Proxy : T;override;
  public
    constructor Create;override;
    destructor Destroy;override;
  end;


implementation

uses
  TypInfo;

{ TInterfaceProxy<T> }

constructor TInterfaceProxy<T>.Create;
begin
  inherited;
  FVirtualInterface := TProxyVirtualInterface.Create(Self,TypeInfo(T),Self.DoInvoke);
end;

destructor TInterfaceProxy<T>.Destroy;
begin
  FVirtualInterface := nil;
  inherited;
end;

function TInterfaceProxy<T>.InternalQueryInterface(const IID: TGUID; out Obj): HRESULT;
begin
  Result := E_NOINTERFACE;
  if (IsEqualGUID(IID,IInterface)) then
    if GetInterface(IID, Obj) then
      Result := 0;
end;

function TInterfaceProxy<T>.Proxy: T;
var
  pInfo : PTypeInfo;
begin
  pInfo := TypeInfo(T);
  if FVirtualInterface.QueryInterface(GetTypeData(pInfo).Guid,result) <> 0 then
    raise EMockNoProxyException.Create('Error casting to interface ' + string(pInfo.Name) + ' , proxy does not appear to implememnt T');
end;

function TInterfaceProxy<T>.QueryInterface(const IID: TGUID; out Obj): HRESULT;
begin
  Result := E_NOINTERFACE;
  if (FVirtualInterface <> nil) then
    Result := FVirtualInterface.QueryInterface(IID, Obj);
  if result <> 0 then
    Result := inherited;

end;

{ TInterfaceProxy<T>.TProxyVirtualInterface }

constructor TInterfaceProxy<T>.TProxyVirtualInterface.Create(
  AProxy: TInterfaceProxy<T>; AInterface: Pointer;
  InvokeEvent: TVirtualInterfaceInvokeEvent);
begin
  FProxy := AProxy;
  inherited Create(Ainterface,InvokeEvent);
end;


function TInterfaceProxy<T>.TProxyVirtualInterface.QueryInterface(const IID: TGUID; out Obj): HRESULT;
begin
  Result := inherited;
  if Result <> 0 then
    Result := FProxy.InternalQueryInterface(IID, Obj);
end;


end.

