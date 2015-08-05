unit Sample1Main;

interface

uses
  Delphi.Mocks;


procedure Test;

procedure TesTObjectMock;


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
    function ReturnObject : TObject;
    procedure TestMe;
    procedure TestVarParam(var msg : string);
    procedure TestOutParam(out msg : string);
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
  mock : TMock<IFoo>; //our mock object
  stub : TStub<IFoo>; //our stub object;
  msg  : string;


  procedure TestImplicit(value : IFoo);
  begin
    WriteLn('Calling Bar(1234567) : ' + value.Bar(1234567));
  end;

begin
  //Create our mock
  mock := TMock<IFoo>.Create;
  stub := TStub<IFoo>.Create;

  //Setup the behavior of our mock.

  //setup a default return value for method Bar
  mock.Setup.WillReturnDefault('Bar','hello world');
  //setup explicit return values when parameters are matched
  mock.Setup.WillReturn('blah blah').When.Bar(1);
  mock.Setup.WillReturn('goodbye world').When.Bar(2,'sdfsd');
  //method TestMe will raise an exception - using one that the debugger won't break on here!
  mock.Setup.WillRaise(EMockException,'You called me when I told you not to!').When.TestMe;

  //MyProp return value - note it really sets up the return value
  //for the getter method
  mock.Setup.WillReturn('hello').When.MyProp;

  mock.Setup.WillExecute(
    function (const args : TArray<TValue>; const ReturnType : TRttiType) : TValue
    begin
      //Note - args[0] is the Self interface reference for the anon method, our first arg is [1]
      result := 'The result is ' + IntToStr(args[1].AsOrdinal);
    end
    ).When.Bar(200);

  mock.Setup.WillExecute(
    function (const args : TArray<TValue>; const ReturnType : TRttiType) : TValue
    begin
      args[1] := 'hello Delphi Mocks!';
    end
    ).When.TestVarParam(msg);

  mock.Setup.WillExecute(
    function (const args : TArray<TValue>; const ReturnType : TRttiType) : TValue
    begin
      args[1] := 'hello Delphi Mocks! - With out Param';
    end
    ).When.TestOutParam(msg);


  mock.Setup.WillExecute(
    function (const args : TArray<TValue>; const ReturnType : TRttiType) : TValue
    begin
      //Note - args[0] is the Self interface reference for the anon method, our first arg is [1]
      result := TObject.Create;
    end
    ).When.ReturnObject;


  mock.Setup.WillReturn('helloooooooo').When.Bar(It(0).IsAny<integer>,It(1).IsAny<string>);

  //Define our expectations - mostly about how many times we expect a method to be called.
//
  //we expect the TestMe method to never be called
  mock.Setup.Expect.Never.When.TestMe;

  //we expecte Bar to be called at lease once with a param value of 1
  mock.Setup.Expect.AtLeastOnce.When.Bar(1);

  mock.Setup.Expect.AtLeastOnce.When.Bar(99);
  mock.Setup.Expect.Between(2,4).When.Bar(23);

  mock.Setup.Expect.Exactly('Bar',5);

 //Now use our mock object
  mock.Instance.MyProp := 'hello';
  mock.Instance.IndexedProp[1] := 'hello';

  mock.Instance.TestVarParam(msg);
  WriteLn('Calling TestVarParam set msg to : ' + msg);

  mock.Instance.TestOutParam(msg);
  WriteLn('Calling TestOutParam set msg to : ' + msg);


  WriteLn('Calling Bar(1) : ' + mock.Instance.Bar(1));
  WriteLn('Calling Bar(2) : ' + mock.Instance.Bar(2));
  WriteLn('Calling Bar(2,sdfsd) : ' + mock.Instance.Bar(999,'sdfsd'));
  WriteLn('Calling Bar(2,sdfsd) : ' + mock.Instance.Bar(2,'sdfsd'));
  WriteLn('Calling Bar(200) : ' + mock.Instance.Bar(200));

  WriteLn('Calling1 ReturnObject : ' + mock.Instance.ReturnObject.ClassName);


  stub.Instance.Bar(1234);


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
  try
    mock.Verify('did it work???');
  finally
    mock.Free;
  end;
end;

type
  TFoo = class
  public
    function Bar(const param : integer) : string;overload;virtual;
    function Bar(const param : integer; const param2 : string) : string;overload;virtual;
    procedure TestMe;virtual;
    function ReadString(const AName: string): string; virtual; abstract;
  end;

procedure TesTObjectMock;
var
  mock : TMock<TFoo>;
begin
  mock := TMock<TFoo>.Create;
  mock.Setup.WillReturn('hello world').When.Bar(99);
  mock.Setup.WillReturn('hello world2').When.Bar(99,'abc');
  mock.Setup.WillReturn('..\datadefinitions\').When.ReadString('DefinitionPath');
  mock.Setup.WillReturn('test\').When.ReadString('Path');
  WriteLn('Bar(99) returned : ' +  mock.Instance.Bar(99));
  WriteLn('Bar(99,abc) returned : ' +  mock.Instance.Bar(99,'abc'));
  Writeln('ReadString(''DefinitionPath'') returned : ' + mock.Instance.ReadString('DefinitionPath'));
  Writeln('ReadString(''Path'') returned : ' + mock.Instance.ReadString('Path'));
  mock.Free;
end;

{ TFoo }

function TFoo.Bar(const param: integer): string;
begin
  result := IntToStr(param);
end;

function TFoo.Bar(const param: integer; const param2: string): string;
begin
  result := IntToStr(param) + '-' + param2;
end;



procedure TFoo.TestMe;
begin
  //do nothing
end;

end.
