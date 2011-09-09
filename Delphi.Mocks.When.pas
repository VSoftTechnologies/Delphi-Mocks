unit Delphi.Mocks.When;

interface

uses
  Delphi.Mocks,
  Delphi.Mocks.InterfaceProxy;

type
  TWhen<T> = class(TInterfacedObject,IWhen<T>)
  private
   FProxy : T;
  protected
   function When : T;
  public
    constructor Create(const AProxy : T);
    destructor Destroy;override;
  end;




implementation

uses
  SysUtils;

{ TWhen<T> }

constructor TWhen<T>.Create(const AProxy: T);
begin
  FProxy := AProxy;
end;

destructor TWhen<T>.Destroy;
begin
  FProxy := Default(T);
  inherited;
end;

function TWhen<T>.When: T;
begin
  result := FProxy;
end;

end.
