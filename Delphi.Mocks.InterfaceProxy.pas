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
  TypInfo,
  Generics.Collections,
  Delphi.Mocks,
  Delphi.Mocks.Interfaces,
  Delphi.Mocks.ProxyBase;

type
  TProxyBaseInvokeEvent = procedure (Method: TRttiMethod; const Args: TArray<TValue>; out Result: TValue) of object;

  TSetupMode = (None, Behavior, Expectation);

  TInterfaceProxy<T> = class(TBaseProxy<T>)
  private type

    //GENERAL INFO:
    //An interface proxy is the external facing proxy for interfaces. The proxy virtual interfaces are
    //what implement each of the interfaces implemented by the interface proxy. The first interface implemented
    //is always the one of which we are at generic for. Subsequent ones can be added through the Implements
    //method which will add another ProxyVirtualInterface to the list of interfaces held by the external facing
    //InterfaceProxy.

    //HOW ALL INTERFACES SUPPORT EACH OTHER
    //When QueryInterface is called on any ProxyVirtualInterface, if they don't support the interface in question
    //they ask the creating InterfaceProxy if has that interface in its list of interfaces. If it does then the
    //InterfaceProxy will return the instance of that interface. Therefore ANY interface which is "Implemented"
    //but the InterfaceProxy is "Supported" by all interfaces "Implemented" and the "T" interface.

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
    procedure Implements(const ATypeInfo: PTypeInfo); override;
  public
    constructor Create(const AIsStubOnly : boolean = false);override;
    destructor Destroy;override;
  end;

implementation

{ TInterfaceProxy<T> }

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

procedure TInterfaceProxy<T>.Implements(const ATypeInfo: PTypeInfo);
var
  virtualProxy : TProxyVirtualInterface;
begin
  inherited;

  if FVirtualInterfaces.ContainsKey(GetTypeData(ATypeInfo).Guid) then
    raise EMockProxyAlreadyImplemented.Create('The mock already implements ' + ATypeInfo.NameStr);

  virtualProxy := TProxyVirtualInterface.Create(Self, ATypeInfo, Self.DoInvoke);
  FVirtualInterfaces.Add(GetTypeData(ATypeInfo).Guid, virtualProxy);
end;

function TInterfaceProxy<T>.InternalQueryInterface(const IID: TGUID; out Obj): HRESULT;
var
  virtualProxy : IInterface;
begin
  Result := E_NOINTERFACE;

  if not FVirtualInterfaces.ContainsKey(IID) then
    Exit;

  virtualProxy := FVirtualInterfaces.Items[IID];
  result := virtualProxy.QueryInterface(IID, Obj);
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

  if virtualProxy.QueryInterface(GetTypeData(pInfo).Guid, result) <> 0 then
	  raise EMockNoProxyException.Create('Error casting to interface ' + pInfo.NameStr + ' , proxy does not appear to implememnt T');
end;

function TInterfaceProxy<T>.QueryInterface(const IID: TGUID; out Obj): HRESULT;
var
  virtualProxy : IInterface;
begin
  Result := E_NOINTERFACE;

  if (FVirtualInterfaces.ContainsKey(IID)) then
  begin
    virtualProxy := FVirtualInterfaces.Items[IID];
    Result := virtualProxy.QueryInterface(IID, Obj);
  end;

  if result <> S_OK then
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

