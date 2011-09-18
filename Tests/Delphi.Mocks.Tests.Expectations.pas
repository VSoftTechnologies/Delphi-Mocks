unit Delphi.Mocks.Tests.Expectations;

interface

uses
  TestFramework,
  Rtti,
  Delphi.Mocks,
  Delphi.Mocks.InterfaceProxy;


type
  TTestExpectations = class(TTestCase)
  private
    FContext : TRttiContext;
  protected
    procedure SetUp; override;
  published

  end;


implementation

{ TTestExpectations }

procedure TTestExpectations.SetUp;
begin
  inherited;
  FContext := TRttiContext.Create;
end;


initialization
  TestFramework.RegisterTest(TTestExpectations.Suite);

end.
