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
  Generics.Collections,
  Delphi.Mocks,
  Delphi.Mocks.Interfaces,
  Delphi.Mocks.ProxyBase;

type
  TProxyBaseInvokeEvent = procedure (Method: TRttiMethod; const Args: TArray<TValue>; out Result: TValue) of object;

  TSetupMode = (None, Behavior, Expectation);

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
    FVirtualInterfaces : TDictionary<TGUID, IInterface>;
  protected
    function InternalQueryInterface(const IID: TGUID; out Obj): HRESULT; stdcall;
    function QueryInterface(const IID: TGUID; out Obj): HRESULT; override;
    function Proxy : T;override;
    function CastAs<I: IInterface> : I;
  public
    constructor Create(const AIsStubOnly : boolean = false);override;
    destructor Destroy;override;
  end;


implementation

uses
  TypInfo;

{ TInterfaceProxy<T> }

function TInterfaceProxy<T>.CastAs<I>: I;
var
  virtualProxy : TProxyVirtualInterface;
begin
  virtualProxy := TProxyVirtualInterface.Create(Self, TypeInfo(I), Self.DoInvoke);
  FVirtualInterfaces.Add(GetTypeData(TypeInfo(I)).Guid, virtualProxy);
  virtualProxy.QueryInterface(GetTypeData(TypeInfo(I)).Guid,result);
end;

constructor TInterfaceProxy<T>.Create(const AIsStubOnly : boolean);
var
  virtualProxy : TProxyVirtualInterface;
begin
  inherited Create(AIsStubOnly);

  FVirtualInterfaces := TDictionary<TGUID, IInterface>.Create;

  virtualProxy := TProxyVirtualInterface.Create(Self, TypeInfo(T), Self.DoInvoke);

  FVirtualInterfaces.Add(GetTypeData(TypeInfo(T)).Guid, virtualProxy);
end;

destructor TInterfaceProxy<T>.Destroy;
begin
  FVirtualInterfaces.Clear;
  FreeAndNil(FVirtualInterfaces);

  inherited;
end;

function TInterfaceProxy<T>.InternalQueryInterface(const IID: TGUID; out Obj): HRESULT;
begin
  Result := E_NOINTERFACE;
  if (IsEqualGUID(IID, IInterface)) then
    if GetInterface(IID, Obj) then
      Result := 0;
end;

function TInterfaceProxy<T>.Proxy: T;
var
  pInfo : PTypeInfo;
  virtualProxy : IInterface;
begin
  pInfo := TypeInfo(T);

  if FVirtualInterfaces.ContainsKey(GetTypeData(pInfo).Guid) then
    virtualProxy := FVirtualInterfaces.Items[GetTypeData(pInfo).Guid]
  else
    raise EMockNoProxyException.Create('Error proxy casting to interface');

  if virtualProxy.QueryInterface(GetTypeData(pInfo).Guid,result) <> 0 then
	raise EMockNoProxyException.Create('Error casting to interface ' + pInfo.NameStr + ' , proxy does not appear to implememnt T');
end;

function TInterfaceProxy<T>.QueryInterface(const IID: TGUID; out Obj): HRESULT;
var
  virtualProxy : IInterface;
begin
  Result := E_NOINTERFACE;

  if (FVirtualInterfaces <> nil) then
    if (FVirtualInterfaces.Count <> 0) then
      if (FVirtualInterfaces.ContainsKey(IID)) then
      begin
        virtualProxy := FVirtualInterfaces.Items[IID];
        Result := virtualProxy.QueryInterface(IID, Obj);
      end;

  if result <> 0 then
    Result := inherited;
end;

{ TInterfaceProxy<T>.TProxyVirtualInterface }

constructor TInterfaceProxy<T>.TProxyVirtualInterface.Create(AProxy: TInterfaceProxy<T>;
  AInterface: Pointer; InvokeEvent: TVirtualInterfaceInvokeEvent);
begin
  FProxy := AProxy;
  inherited Create(Ainterface, InvokeEvent);
end;


function TInterfaceProxy<T>.TProxyVirtualInterface.QueryInterface(const IID: TGUID; out Obj): HRESULT;
begin
  Result := inherited;
  if Result <> 0 then
    Result := FProxy.InternalQueryInterface(IID, Obj);
end;


end.

