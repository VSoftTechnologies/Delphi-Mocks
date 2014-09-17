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
  // key: string;
  I: Integer;
begin
  //  for key in FMocks.Keys do
  //    FMocks[key] := nil;

  for I := 0 to FMocks.Count - 1 do
    FMocks[I] := nil;

  FMocks.Clear;

  inherited;
end;

function TAutoMock.Mock(const ATypeInfo : PTypeInfo) : IProxy;
var
  newMock: IProxy;
begin
  //We create new mocks using ourself as the auto mocking reference
  newMock := TProxy.Create(ATypeInfo, Self);
  FMocks.Add(newMock);
  result := newMock;
end;

end.
