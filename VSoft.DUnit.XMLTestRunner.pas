{***************************************************************************}
{                                                                           }
{           VSoft.DUnit.XMLTestRunner                                       }
{                                                                           }
{           Copyright (C) 2012 Vincent Parrett                              }
{                                                                           }
{           http://www.finalbuilder.com                                     }
{                                                                           }
{                                                                           }
{***************************************************************************}
{                                                                           }
{  Licensed under the Apache License, Version 2.0 (the "License");          }
{  you may not use this file except in compliance with the License.         }
{  You may obtain a copy of the License at                                  }
{                                                                           }
{      http://www.apache.org/licenses/LICENSE-2.0                           }
{                                                                           }
{  Unless required by applicable law or agreed to in writing, software      }
{  distributed under the License is distributed on an "AS IS" BASIS,        }
{  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. }
{  See the License for the specific language governing permissions and      }
{  limitations under the License.                                           }
{                                                                           }
{***************************************************************************}


//  This is am modified XMLTestRunner which outputs in NUnit format
//  so that it can be used with FinalBuilder and Continua CI.
unit VSoft.DUnit.XMLTestRunner;

interface
uses
  SysUtils,
  Classes,
  VSoft.MSXML6,
  TestFramework;

const
   DEFAULT_FILENAME = 'dunit-report.xml';

type
  TSuiteData = class
    Name : string;
    SuiteElement : IXMLDOMElement;
    ResultsElement : IXMLDOMElement;
    FailureCount : integer;
    ErrorCount   : integer;
  end;

  TXMLTestListener = class(TInterfacedObject, ITestListener, ITestListenerX)
  private
    FSuiteDataStack : TList;
    FMessageList   : TStringList;

    FFileName : String;
    FStartDateTime : TDateTime;
    FEndDateTime : TDateTime;

    FXMLDoc : IXMLDOMDocument;
    FTestResultsElement : IXMLDOMElement;
    FCurrentTestElement : IXMLDOMElement;

    FErrorCount : integer;
    FFailureCount : integer;
    procedure PushSuite(const suiteElement, resultsElement : IXMLDOMElement; const name : string);
    procedure PopSuite(var suiteElement, resultsElement : IXMLDOMElement; var name : string );
    function CurrentSuiteElement : IXMLDOMElement;
    function CurrentResultsElement : IXMLDOMElement;
  protected






    function  PrintErrors(r: TTestResult): string; virtual;
    function  PrintFailures(r: TTestResult): string; virtual;
    function  PrintHeader(r: TTestResult): string; virtual;
    function  PrintFailureItems(r :TTestResult): string; virtual;
    function  PrintErrorItems(r :TTestResult): string; virtual;
    function  Report(r: TTestResult): string;

    function IsNamespaceSuite(suite : ITest) : boolean;

  public

    // implement the ITestListener interface
    procedure AddSuccess(test: ITest); virtual;
    procedure AddError(error: TTestFailure); virtual;
    procedure AddFailure(failure: TTestFailure); virtual;
    function  ShouldRunTest(test :ITest):boolean; virtual;
    procedure StartSuite(suite: ITest); virtual;
    procedure EndSuite(suite: ITest); virtual;
    procedure StartTest(test: ITest); virtual;
    procedure EndTest(test: ITest); virtual;
    procedure TestingStarts; virtual;
    procedure TestingEnds(testResult: TTestResult); virtual;
    procedure Status(test :ITest; const Msg :string);

    constructor Create; overload;
    constructor Create(outputFile : String); overload;
    destructor Destroy; override;

    class function RunTest(suite: ITest; outputFile:String): TTestResult; overload;
    class function RunRegisteredTests(outputFile:String): TTestResult;
    class function text2sgml(text : String) : String;
    class function StringReplaceAll (text,byt,mot : string ) :string;

    //:Report filename. If an empty string, then standard output is used (compile with -CC option)
    property FileName : String read FFileName write FFileName;
  end;

{: Run the given test suite
}
function RunTest(suite: ITest; outputFile:String=DEFAULT_FILENAME) : TTestResult; overload;
function RunRegisteredTests(outputFile:String=DEFAULT_FILENAME) : TTestResult; overload;

var
  PrintReportToConsole : boolean = true;

implementation

uses Forms, Windows, ActiveX;

const
   CRLF = #13#10;
   MAX_DEEP = 5;

function IsValidXMLChar(wc: WideChar): Boolean;
begin
  case Word(wc) of
    $0009, $000A, $000C, $000D,
      $0020..$D7FF,
      $E000..$FFFD, // Standard Unicode chars below $FFFF
      $D800..$DBFF, // High surrogate of Unicode character  = $10000 - $10FFFF
      $DC00..$DFFF: // Low surrogate of Unicode character  = $10000 - $10FFFF
      result := True;
  else
    result := False;
  end;
end;


function StripInvalidXML(const s: string): string;
var
  i, count: Integer;
begin
  count := Length(s);
  setLength(result, count);
  for i := 1 to Count do // Iterate
  begin
    if IsValidXMLChar(WideChar(s[i])) then
      result[i] := s[i]
    else
      result[i] := ' ';
  end; // for}
end;


function EscapeForXML(const value: string; const isAttribute: boolean = True; const isCDATASection : Boolean = False): string;
begin
  result := StripInvalidXML(value);
  if isCDATASection  then
  begin
    Result := StringReplace(Result, ']]>', ']>',[rfReplaceAll]);
    exit;
  end;

  //note we are avoiding replacing &amp; with &amp;amp; !!
  Result := StringReplace(result, '&amp;', '[[-xy-amp--]]',[rfReplaceAll]);
  Result := StringReplace(result, '&', '&amp;',[rfReplaceAll]);
  Result := StringReplace(result, '[[-xy-amp--]]', '&amp;amp;',[rfReplaceAll]);
  Result := StringReplace(result, '<', '&lt;',[rfReplaceAll]);
  Result := StringReplace(result, '>', '&gt;',[rfReplaceAll]);

  if isAttribute then
  begin
    Result := StringReplace(result, '''', '&#39;',[rfReplaceAll]);
    Result := StringReplace(result, '"', '&quot;',[rfReplaceAll]);
  end;
end;



{ TXMLTestListener }

constructor TXMLTestListener.Create;
begin
   Create(DEFAULT_FILENAME);
end;

constructor TXMLTestListener.Create(outputFile : String);
var
  pi : IXMLDOMProcessingInstruction;
begin
   inherited Create;
   FileName     := outputFile;
   FMessageList    := TStringList.Create;
   CoInitializeEx(nil,COINIT_MULTITHREADED);
   FXMLDoc := ComsFreeThreadedDOMDocument.Create;
   {$IFDEF UNICODE}
   pi := FXmlDoc.createProcessingInstruction('xml' ,'version="1.0" encoding="UTF-8"');
   {$ELSE}
   pi := FXmlDoc.createProcessingInstruction('xml' ,'version="1.0" encoding="ISO-8859-1"');
   {$ENDIF}
   FXMLDoc.appendChild(pi);

   FTestResultsElement := FXMLDoc.createElement('test-results');
   FXMLDoc.appendChild(FTestResultsElement);
   FSuiteDataStack := TList.Create;
end;


function TXMLTestListener.CurrentResultsElement: IXMLDOMElement;
begin
  Assert(FSuiteDataStack.Count > 0);
  result := TSuiteData(FSuiteDataStack.Items[0]).ResultsElement;
end;


function TXMLTestListener.CurrentSuiteElement: IXMLDOMElement;
begin
  Assert(FSuiteDataStack.Count > 0);
  result := TSuiteData(FSuiteDataStack.Items[0]).SuiteElement;
end;

const
  TrueFalse : array[Boolean] of string = ('False', 'True');

procedure TXMLTestListener.AddSuccess(test: ITest);
var
  msgElement : IXMLDOMElement;
  reasonElement : IXMLDOMElement;
  cData : IXMLDOMCDATASection;
  sMessage : string;
  i : integer;
begin
  if FCurrentTestElement <> nil then
  begin
    FCurrentTestElement.setAttribute('success','True');
    FCurrentTestElement.setAttribute('result','Success  ');
    FCurrentTestElement.setAttribute('time',Format('%1.3f',[test.ElapsedTestTime / 1000]));
    if FMessageList.Count > 0 then
    begin
      reasonElement := FXMLDoc.createElement('reason');
      FCurrentTestElement.appendChild(reasonElement);
      msgElement := FXMLDoc.createElement('message');
      reasonElement.appendChild(msgElement);
      for i := 0 to FMessageList.Count - 1 do
          sMessage := sMessage + EscapeForXML(FMessageList.Strings[i],false) + #13#10;
      cData := FXMLDoc.createCDATASection(sMessage);
      msgElement.appendChild(cData);
    end;
    FMessageList.Clear;
  end;
end;

procedure TXMLTestListener.AddError(error: TTestFailure);
var
  msgElement : IXMLDOMElement;
  failureElement : IXMLDOMElement;
  cData : IXMLDOMCDATASection;
begin
  if FCurrentTestElement <> nil then
  begin
    FCurrentTestElement.setAttribute('success','False');
    FCurrentTestElement.setAttribute('result','Error');
    FCurrentTestElement.setAttribute('time',Format('%1.3f',[error.FailedTest.ElapsedTestTime / 1000]));
    failureElement := FXMLDoc.createElement('failure');
    FCurrentTestElement.appendChild(failureElement);
    msgElement := FXMLDoc.createElement('message');
    failureElement.appendChild(msgElement);
    cData := FXMLDoc.createCDATASection(EscapeForXML(error.ThrownExceptionMessage,false));
    msgElement.appendChild(cData);
  end;
  Inc(FErrorCount);
end;

procedure TXMLTestListener.AddFailure(failure: TTestFailure);
var
  msgElement : IXMLDOMElement;
  failureElement : IXMLDOMElement;
  cData : IXMLDOMCDATASection;
begin
  if FCurrentTestElement <> nil then
  begin
    FCurrentTestElement.setAttribute('success','False');
    FCurrentTestElement.setAttribute('result','Failure');
    FCurrentTestElement.setAttribute('time',Format('%1.3f',[failure.FailedTest.ElapsedTestTime / 1000]));
    failureElement := FXMLDoc.createElement('failure');
    FCurrentTestElement.appendChild(failureElement);
    msgElement := FXMLDoc.createElement('message');
    failureElement.appendChild(msgElement);
    cData := FXMLDoc.createCDATASection(EscapeForXML(failure.ThrownExceptionMessage,false));
    msgElement.appendChild(cData);
  end;
  Inc(FFailureCount);
end;


procedure TXMLTestListener.StartTest(test: ITest);
begin
  FMessageList.Clear;
  if Supports(test,ITestSuite) then
    exit;


  FCurrentTestElement := FXMLDoc.createElement('test-case');
  FCurrentTestElement.setAttribute('name',test.Name);
  FCurrentTestElement.setAttribute('executed','True');
  CurrentResultsElement.appendChild(FCurrentTestElement);
end;

procedure TXMLTestListener.EndTest(test: ITest);
begin
  FCurrentTestElement := nil;
end;

procedure TXMLTestListener.TestingStarts;
var
  sFileName : string;
begin
   FStartDateTime := Now;
   sFileName := ExtractFileName(ParamStr(0));

end;

procedure TXMLTestListener.TestingEnds(testResult: TTestResult);
var
  dtRunTime : TDateTime;
  h, m, s, l :Word;
begin
   FTestResultsElement.setAttribute('total',IntToStr(RegisteredTests.CountTestCases));
   FTestResultsElement.setAttribute('not-run',IntToStr(RegisteredTests.CountTestCases - RegisteredTests.CountEnabledTestCases));
   FTestResultsElement.setAttribute('errors',IntToStr(testResult.errorCount));
   FTestResultsElement.setAttribute('failures',IntToStr(testResult.FailureCount));
   FTestResultsElement.setAttribute('date',DateToStr(Now));

   FTestResultsElement.setAttribute('time',Format('%1.3f',[testResult.TotalTime / 1000]));

   FXMLDoc.save(FFileName);
   if PrintReportToConsole then
   begin
      FEndDateTime := now;
      dtRunTime := Now-FStartDateTime;
      writeln;
      DecodeTime(dtRunTime, h,  m, s, l);
      writeln(Format('Time: %d:%2.2d:%2.2d.%d', [h, m, s, l]));
      writeln(Report(testResult));
      writeln;
   end;


end;

class function TXMLTestListener.RunTest(suite: ITest; outputFile:String): TTestResult;
begin
   Result := TestFramework.RunTest(suite, [TXMLTestListener.Create(outputFile)]);
end;


function TXMLTestListener.Report(r: TTestResult): string;
begin
  result := PrintHeader(r) +
            PrintErrors(r) +
            PrintFailures(r);
end;

class function TXMLTestListener.RunRegisteredTests(outputFile:String): TTestResult;
begin
  Result := RunTest(registeredTests, outputFile);
end;

function RunTest(suite: ITest; outputFile:String=DEFAULT_FILENAME): TTestResult;
begin
   Result := TestFramework.RunTest(suite, [TXMLTestListener.Create(outputFile)]);
end;

function RunRegisteredTests(outputFile:String=DEFAULT_FILENAME): TTestResult;
begin
   Result := RunTest(registeredTests, outputFile);
end;


procedure TXMLTestListener.Status(test: ITest; const Msg: string);
begin
  FMessageList.Add(Format('STATUS: %s: %s', [test.Name, Msg]));
end;

function TXMLTestListener.ShouldRunTest(test: ITest): boolean;
begin
  Result := test.Enabled;
  (*
  if not Result then
    writeReport(Format('<test-case name="%s%s" executed="False"/>',
                       [GetCurrentSuiteName, test.GetName]));
  *)
end;

procedure TXMLTestListener.EndSuite(suite: ITest);
var
  suiteElement : IXMLDOMElement;
  resultsElement : IXMLDOMElement;
  name : string;
begin
  //update the current suite.. then pop.
  CurrentSuiteElement.setAttribute('time',Format('%1.3f',[suite.ElapsedTestTime / 1000]));
  if (FErrorCount > 0) or (FFailureCount > 0) then
  begin
    CurrentSuiteElement.setAttribute('result','Failure');
    CurrentSuiteElement.setAttribute('success','False');
  end
  else
  begin
    CurrentSuiteElement.setAttribute('result','Success');
    CurrentSuiteElement.setAttribute('success','True');
  end;

  PopSuite(suiteElement,resultsElement,name);
//  Assert(name = suite.Name);


end;

procedure TXMLTestListener.StartSuite(suite: ITest);
var
  suiteElement : IXMLDOMElement;
  resultsElement : IXMLDOMElement;
  sType : string;
  sNameSpace : string;
begin
  sNameSpace := ExtractFileName(ParamStr(0));
  //treat the application suite as the assembly.
  if CompareText(suite.Name, sNameSpace) = 0 then
  begin
    suiteElement := FXMLDoc.createElement('test-suite');
    suiteElement.setAttribute('type','Assembly');
    suiteElement.setAttribute('name',suite.Name);
    FTestResultsElement.appendChild(suiteElement);
    resultsElement := FXMLDoc.createElement('results');
    suiteElement.appendChild(resultsElement);
    PushSuite(suiteElement,resultsElement,suite.Name);
    exit;
  end;

  //treat suites that only have other suites as children as namespaces.
  if IsNamespaceSuite(suite) then
    sType := 'Namespace'
  else
    sType := 'TestFixture';

  //make sure we have a parent namespace for the testfixture
  if sType = 'TestFixture' then
  begin
    if CurrentSuiteElement.getAttribute('type') <> 'Namespace' then
    begin
      sNameSpace := ChangeFileExt(sNameSpace,'');
      suiteElement := FXMLDoc.createElement('test-suite');
      suiteElement.setAttribute('type','Namespace');
      suiteElement.setAttribute('name',sNameSpace);
      CurrentResultsElement.appendChild(suiteElement);
      resultsElement := FXMLDoc.createElement('results');
      suiteElement.appendChild(resultsElement);
      PushSuite(suiteElement,resultsElement,suite.Name);
    end;
  end;

  suiteElement := FXMLDoc.createElement('test-suite');
  suiteElement.setAttribute('type',sType);
  suiteElement.setAttribute('name',suite.Name);
  CurrentResultsElement.appendChild(suiteElement);
  resultsElement := FXMLDoc.createElement('results');
  suiteElement.appendChild(resultsElement);
  PushSuite(suiteElement,resultsElement,suite.Name);

end;

{:
 Replace byt string by mot in text string
 }
class function TXMLTestListener.StringReplaceAll (text,byt,mot : string ) :string;
var
   plats : integer;
begin
  While pos(byt,text) > 0 do
  begin
    plats := pos(byt,text);
    delete (text,plats,length(byt));
    insert (mot,text,plats);
  end;
  result := text;
end;

{:
 Replace special character by sgml compliant characters
 }
class function TXMLTestListener.text2sgml(text : String) : String;
begin
  text := stringreplaceall (text,'<','&lt;');
  text := stringreplaceall (text,'>','&gt;');
  result := text;
end;

destructor TXMLTestListener.Destroy;
begin
  FMessageList.Free;
  FSuiteDataStack.Destroy;
  inherited Destroy;
end;


//A namespace suite will only have test suites as children.
function TXMLTestListener.IsNamespaceSuite(suite: ITest): boolean;
var
  i: Integer;
  test : ITest;
begin
  result := True;
  for i := 0 to suite.Tests.Count -1 do
  begin
    test := suite.Tests.Items[i] as ITest;
    if not Supports(test,ITestSuite) then
    begin
      result := False;
      exit;
    end;
  end;
end;


procedure TXMLTestListener.PopSuite(var suiteElement, resultsElement : IXMLDOMElement; var name : string);
var
  data : TSuiteData;
begin
  Assert(FSuiteDataStack.Count > 0);
  data := TSuiteData(FSuiteDataStack.Items[0]);
  suiteElement := data.SuiteElement;
  resultsElement := data.ResultsElement;
  name := data.Name;
  FSuiteDataStack.Delete(0);
  FErrorCount := FErrorCount + data.ErrorCount;
  FFailureCount := FFailureCount + data.FailureCount;
  data.Free;
end;

function TXMLTestListener.PrintErrorItems(r: TTestResult): string;
var
  i: Integer;
  failure: TTestFailure;
begin
  result := '';
  for i := 0 to r.ErrorCount-1 do begin
    failure := r.Errors[i];
    result := result + format('%3d) %s: %s'#13#10'     at %s'#13#10'      "%s"',
                               [
                               i+1,
                               failure.failedTest.name,
                               failure.thrownExceptionName,
                               failure.LocationInfo,
                               failure.thrownExceptionMessage
                               ]) + CRLF;
  end;
end;

function TXMLTestListener.PrintErrors(r: TTestResult): string;
begin
  result := '';
  if (r.errorCount <> 0) then begin
    if (r.errorCount = 1) then
      result := result + format('There was %d error:', [r.errorCount]) + CRLF
    else
      result := result + format('There were %d errors:', [r.errorCount]) + CRLF;

    result := result + PrintErrorItems(r);
    result := result + CRLF
  end
end;

function TXMLTestListener.PrintFailureItems(r: TTestResult): string;
var
  i: Integer;
  failure: TTestFailure;
begin
  result := '';
  for i := 0 to r.FailureCount-1 do begin
    failure := r.Failures[i];
    result := result + format('%3d) %s: %s'#13#10'     at %s'#13#10'      "%s"',
                               [
                               i+1,
                               failure.failedTest.name,
                               failure.thrownExceptionName,
                               failure.LocationInfo,
                               failure.thrownExceptionMessage
                               ]) + CRLF;
  end;
end;

function TXMLTestListener.PrintFailures(r: TTestResult): string;
begin
  result := '';
  if (r.failureCount <> 0) then begin
    if (r.failureCount = 1) then
      result := result + format('There was %d failure:', [r.failureCount]) + CRLF
    else
      result := result + format('There were %d failures:', [r.failureCount]) + CRLF;

    result := result + PrintFailureItems(r);
    result := result + CRLF
  end
end;

function TXMLTestListener.PrintHeader(r: TTestResult): string;
begin
  result := '';
  if r.wasSuccessful then
  begin
    result := result + CRLF;
    result := result + format('OK: %d tests'+CRLF, [r.runCount]);
  end
  else
  begin
    result := result + CRLF;
    result := result + 'FAILURES!!!'+CRLF;
    result := result + 'Test Results:'+CRLF;
    result := result + format('Run:      %8d'+CRLF+'Failures: %8d'+CRLF+'Errors:   %8d'+CRLF,
                      [r.runCount, r.failureCount, r.errorCount]
                      );
  end
end;

procedure TXMLTestListener.PushSuite(const suiteElement, resultsElement : IXMLDOMElement; const name : string);
var
  data : TSuiteData;
begin
  data := TSuiteData.Create;
  data.SuiteElement := suiteElement;
  data.ResultsElement := resultsElement;
  data.ErrorCount := FErrorCount;
  data.FailureCount := FFailureCount;
  FSuiteDataStack.Insert(0,data);
  FFailureCount := 0;
  FErrorCount := 0;
end;


end.
