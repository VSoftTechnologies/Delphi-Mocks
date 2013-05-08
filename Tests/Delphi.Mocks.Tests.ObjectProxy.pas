unit Delphi.Mocks.Tests.ObjectProxy;

interface

uses
  Rtti,
  SysUtils,
  TestFramework,
  Delphi.Mocks;

type
  TSimpleObject = class(TObject)
  private
    FCreateCalled: Cardinal;
  public
    constructor Create;
    property CreateCalled: Cardinal read FCreateCalled;
  end;

  TTestObjectProxy = class(TTestCase)
  published
    procedure ProxyObject_Calls_The_Create_Of_The_Object_Type;
  end;

implementation

uses
  Delphi.Mocks.ObjectProxy;

const
  G_CREATE_CALLED_UNIQUE_ID = 909090;

{ TTestObjectProxy }

procedure TTestObjectProxy.ProxyObject_Calls_The_Create_Of_The_Object_Type;
var
  objectProxy: IProxy<TSimpleObject>;
begin
  objectProxy := TObjectProxy<TSimpleObject>.Create;

  CheckEquals(objectProxy.Proxy.CreateCalled, G_CREATE_CALLED_UNIQUE_ID);
end;

{ TSimpleObject }

constructor TSimpleObject.Create;
begin
  FCreateCalled := G_CREATE_CALLED_UNIQUE_ID;
end;

initialization
  TestFramework.RegisterTest(TTestObjectProxy.Suite);
end.
