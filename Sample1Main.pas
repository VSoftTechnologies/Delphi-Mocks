unit Sample1Main;

interface

uses
  Delphi.Mocks;


procedure Test;


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
  {$M-} //important because otherwise the code below will fail!


implementation

uses
  SysUtils,
  Rtti;


procedure Test;
var
  mock : TInterfaceMock<IFoo>; //our mock object

  procedure TestImplicit(value : IFoo);
  begin
    value.Bar(1234567);
  end;
begin
  //Create our mock
  mock := TInterfaceMock<IFoo>.Create;

  //Setup the behavior of our mock.

  //setup a default return value for method Bar
  mock.Setup.WillReturnDefault('Bar','hello world');
  //setup explicit return values when parameters are matched
  mock.Setup.WillReturn('blah blah').When.Bar(1);
  mock.Setup.WillReturn('goodbye world').When.Bar(2,'sdfsd');
  //method TestMe will raise an exception - using one that the debugger won't break on here!
  mock.Setup.WillRaise(EMockException).When.TestMe;

  //MyProp return value - note it really sets up the return value
  //for the getter method
  mock.Setup.WillReturn('hello').When.MyProp;

  //Why doesn't this compile!
  mock.Setup.WillExecute(
    function (const args : TArray<TValue>; const ReturnType : TRttiType) : TValue
    begin
      //Note - args[0] is the Self interface reference for the anon method, our first arg is [1]
      result := 'The result is ' + IntToStr(args[1].AsOrdinal);
    end
    ).When.Bar(200);


  //Define our expectations - mostly about how many times we expect a method to be called.

  //we expect the TestMe method to be called at least once.
  mock.Setup.Expect.AtLeastOnce('TestMe');

  //we expecte Bar to be called at lease once with a param value of 1
  mock.Setup.Expect.AtLeastOnce.When.Bar(1);

  mock.Setup.Expect.AtLeastOnce.When.Bar(99);

 //Now use our mock object
  mock.Instance.MyProp := 'hello';
  mock.Instance.IndexedProp[1] := 'hello';

  WriteLn('Calling Bar(1) : ' + mock.Instance.Bar(1));
  WriteLn('Calling Bar(2) : ' + mock.Instance.Bar(2));
  WriteLn('Calling Bar(2,sdfsd) : ' + mock.Instance.Bar(2,'sdfsd'));
  WriteLn('Calling Bar(200) : ' + mock.Instance.Bar(200));


  //Test the implicit operator by calling a method that expects IFoo
  TestImplicit(mock);
  try
    // test a method that we have setup to throw an exception
    mock.Instance.TestMe;
  except
    on e : Exception do
    begin
      WriteLn('We caught an exception : ' + e.Message);
    end;
  end;
  mock.Verify('did it work???');
  mock.Free;
end;

end.
