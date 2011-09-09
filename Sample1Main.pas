unit Sample1Main;

interface

uses
  Delphi.Mocks;


procedure Test;


implementation

uses
  SysUtils;

type
  {$M+}
  IFoo = interface
  ['{69162E72-8C1E-421B-B970-15230BBB3B2B}']
    function GetProp : string;
    procedure SetProp(const value : string);
    function GetIndexProp(index : integer) : string;
    procedure SetIndexedProp(index : integer; const value : string);
    function Bar(const param : integer) : string;overload;
    function Bar(const param : integer; const param2 : string) : string;overload;
    procedure TestMe;
    property MyProp : string read GetProp write SetProp;
    property IndexedProp[index : integer] : string read GetIndexProp write SetIndexedProp;
  end;

procedure Test;
var
  mock : TInterfaceMock<IFoo>;
  procedure TestImplicit(value : IFoo);
  begin
    value.TestMe;
    value.Bar(1234567);
  end;
begin
  mock := TInterfaceMock<IFoo>.Create;
//  mock.Setup;
  mock.Setup.WillReturn('blah blah').When.Bar(1);
  mock.Setup.WillReturn('goodbye world').When.Bar(2,'sdfsd');
  mock.Setup.WillRaise(Exception).When.TestMe;
  mock.Setup.WillReturn('hello').When.MyProp;
  mock.Setup.WillRaise(Exception).When.MyProp;
  mock.Setup.WillReturnDefault('Bar','hello world');




  //define that Bar must be called before TestMe and will return 'abc' when passed in 33
//  mock.Setup.Before('TestMe').WillReturn('abc').When.Bar(33);

  //mock.Setup.Expect.AtLeastOnce.&On('testMe');
  //mock.Setup.Expect.Once.When.Bar(99);

//  mock.Setup.Expect.Exactly(2).OnMethod('Bar');
//  mock.Setup.WillReturn('hello').When.MyProp;
  mock.Instance.MyProp := 'hello';
  mock.Instance.IndexedProp[1] := 'hello';
  WriteLn('Calling Bar(1) : ' + mock.Instance.Bar(1));
  WriteLn('Calling Bar(2) : ' + mock.Instance.Bar(2));
  WriteLn('Calling Bar(2,sdfsd) : ' + mock.Instance.Bar(2,'sdfsd'));
  TestImplicit(mock);
  try
    mock.Instance.TestMe;
  except
  end;
  mock.Verify('did it work???');
  //mock.Free;
end;

end.
