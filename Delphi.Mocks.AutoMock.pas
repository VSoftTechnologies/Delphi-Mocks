unit Delphi.Mocks.AutoMock;

interface

uses
  TypInfo,
  System.Generics.Collections,
  Delphi.Mocks,
  Delphi.Mocks.WeakReference;

type
  TAutoMock = class(TWeakReferencedObject, IAutoMock)
  private
    FMocks : TList<IProxy>;
  public
    function Mock(const ATypeInfo : PTypeInfo) : IProxy;
    procedure Add(const ATypeName : string; const AMock: IProxy);
    constructor Create;
    destructor Destroy; override;
  end;

//TODO: Add getting out a previously added mock. This would be done in the RecordHit of the method data object.

implementation

uses
  Windows,
  Delphi.Mocks.Validation,
  Delphi.Mocks.Proxy.TypeInfo;

{ TAutoMock }

procedure TAutoMock.Add(const ATypeName : string; const AMock: IProxy);
begin
  FMocks.Add(AMock);
end;

constructor TAutoMock.Create;
begin
  inherited Create;
  FMocks := TList<IProxy>.Create;
end;

destructor TAutoMock.Destroy;
var
  I: Integer;
begin
  for I := 0 to FMocks.Count - 1 do
    FMocks[I] := nil;

  FMocks.Clear;

  inherited;
end;

function TAutoMock.Mock(const ATypeInfo : PTypeInfo) : IProxy;
var
  proxy: IProxy;
  proxyAsType: IProxy;
begin
  //Raise exceptions if the mock doesn't meet the requirements.
  TMocksValidation.CheckMockType(ATypeInfo);

  //We create new mocks using ourself as the auto mocking reference
  proxy := TProxy.Create(ATypeInfo, Self, false);
  proxyAsType := proxy.ProxyFromType(ATypeInfo);

  FMocks.Add(proxy);

  //Push the proxy into the result we are returning.
  if proxyAsType.QueryInterface(GetTypeData(TypeInfo(IProxy)).Guid, result) <> 0 then
    //TODO: This raise seems superfluous as the only types which are created are controlled by us above. They all implement IProxy<T>
    raise EMockNoProxyException.Create('Error casting to interface ' + ATypeInfo.NameStr + ' , proxy does not appear to implememnt IProxy');
end;

end.
