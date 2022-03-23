unit Delphi.Mocks.Tests.TValue;

interface

uses
  DUnitX.TestFramework;

type
  {$M+}
  TValueTests = class
  published
    procedure Test_IsRecord;
    procedure Test_IsArray;
  end;
  {$M-}

implementation

uses
  Delphi.Mocks.Helpers, System.Rtti;

{ TValueTests }

type
  TMyRec = record
    Value: String;
  end;

procedure TValueTests.Test_IsArray;
begin
  Assert.IsFalse(TValue.From<string>('test').IsArray);
  Assert.IsTrue(TValue.From<TArray<string>>(['a', 'b']).IsArray);
end;

procedure TValueTests.Test_IsRecord;
var
  r: TMyRec;
  o: TObject;
  i: IInterface;
begin
  o := TObject.Create;
  try
    Assert.IsFalse(TValue.From<string>('test').IsRecord);
    Assert.IsFalse(TValue.From<TObject>(o).IsRecord);
    Assert.IsFalse(TValue.From<IInterface>(i).IsRecord);
    Assert.IsTrue(TValue.From<TMyRec>(r).IsRecord);
  finally
    o.Free;
  end;
end;

initialization
  TDUnitX.RegisterTestFixture(TValueTests);
end.
