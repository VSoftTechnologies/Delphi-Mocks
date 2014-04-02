unit Delphi.Mocks.Tests.ProxyBase;

interface

uses
  Rtti,
  SysUtils,
  TestFramework,
  Delphi.Mocks;

type
  {$M+}
  TSimpleTestObject = class(TObject);
  {$M-}

  TTestProxyBase = class(TTestCase)
  published
    procedure SetUp;override;
  end;

implementation

uses
  Delphi.Mocks.Helpers,
  Delphi.Mocks.Interfaces,
  Delphi.Mocks.InterfaceProxy,
  classes;

{ TTestProxyBase }

procedure TTestProxyBase.Setup;
begin

//  Check(False, 'Not Implemented');
end;

initialization
  TestFramework.RegisterTest(TTestProxyBase.Suite);

end.
