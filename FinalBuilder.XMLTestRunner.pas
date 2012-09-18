///  This is a modified XMLTestRunner which outputs in NUnit format
///  so that it can be used with FinalBuilder.

(*
 * The contents of this file are subject to the Mozilla Public
 * License Version 1.1 (the "License"); you may not use this file
 * except in compliance with the License. You may obtain a copy of
 * the License at http://www.mozilla.org/MPL/
 *
 * Software distributed under the License is distributed on an "AS
 * IS" basis, WITHOUT WARRANTY OF ANY KIND, either express or
 * implied. See the License for the specific language governing
 * rights and limitations under the License.
 *
 * The Original Code is DUnit.
 *
 * The Initial Developers of the Original Code are Kent Beck, Erich Gamma,
 * and Juancarlo Aez.
 * Portions created The Initial Developers are Copyright (C) 1999-2000.
 * Portions created by The DUnit Group are Copyright (C) 2000-2003.
 * All rights reserved.
 *
 * Contributor(s):
 * Kent Beck <kentbeck@csi.com>
 * Erich Gamma <Erich_Gamma@oti.com>
 * Juanco Aez <juanco@users.sourceforge.net>
 * Chris Morris <chrismo@users.sourceforge.net>
 * Jeff Moore <JeffMoore@users.sourceforge.net>
 * Kris Golko <neuromancer@users.sourceforge.net>
 * The DUnit group at SourceForge <http://dunit.sourceforge.net>
 *
 *)

{
 Contributor : Laurent Laffont <llaffont@altaiire.fr>
}

unit FinalBuilder.XMLTestRunner;

interface
uses
  SysUtils,
  Classes,
  TestFramework;

const
   DEFAULT_FILENAME = 'dunit-report.xml';

type
  TXMLTestListener = class(TInterfacedObject, ITestListener, ITestListenerX)
  private
     FOutputBuffer : TMemoryStream;
     FFileName : String;

  protected
     startTime : Cardinal;
     dtStartTime : TDateTime;
     dtEndTime : TDateTime;

     testStart : TDateTime;
     FSuiteStack : TStringList;
     FInfoList   : TStringList;
     FWarningList : TStringList;

     procedure writeReport(str: String);

     function GetCurrentSuiteName : string;
    function  PrintErrors(r: TTestResult): string; virtual;
    function  PrintFailures(r: TTestResult): string; virtual;
    function  PrintHeader(r: TTestResult): string; virtual;
    function  PrintFailureItems(r :TTestResult): string; virtual;
    function  PrintErrorItems(r :TTestResult): string; virtual;
    function  Report(r: TTestResult): string;

  public
    function HasInfoOrWarnings : boolean;
    procedure WriteInfoAndWarnings;

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
    procedure Warning(test :ITest; const Msg :string);

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

uses Forms, Windows;

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
begin
   inherited Create;
   FileName     := outputFile;
   FSuiteStack  := TStringList.Create;
   FInfoList    := TStringList.Create;
   FWarningList := TStringList.Create;
end;


procedure TXMLTestListener.writeReport(str : String);
{$IFDEF UNICODE}
var
  Buffer : TBytes;
{$ENDIF}
begin
  str := str + CRLF;
  {$IFDEF UNICODE}
  if FOutputBuffer <> nil then
  begin
    buffer := TEncoding.UTF8.GetBytes(str);
    FOutputBuffer.WriteBuffer(buffer[0],Length(buffer));
  end;
  {$ELSE}
  if FOutputBuffer <> nil then
    FOutputBuffer.Write(PChar(str)^,Length(str))
  else
    Writeln(str);
  {$ENDIF}
end;

const
  TrueFalse : array[Boolean] of string = ('False', 'True');

procedure TXMLTestListener.AddSuccess(test: ITest);
var
  endTag : string;
begin
   if test.tests.Count<=0 then
   begin
      if HasInfoOrWarnings then
        endTag := '>'
      else
        endTag := '/>';

      writeReport(Format('<test-case name="%s%s" executed="%s" success="True" time="%1.3f" result="Pass" %s',
                         [EscapeForXML(GetCurrentSuiteName), EscapeForXML(test.GetName), TrueFalse[test.Enabled], test.ElapsedTestTime / 1000,endTag]));
      if HasInfoOrWarnings then
      begin
        WriteInfoAndWarnings;
        writeReport('</test-case>');
      end;

   end;
end;

procedure TXMLTestListener.AddError(error: TTestFailure);
begin
   writeReport(Format('<test-case name="%s%s" executed="%s" success="False" time="%1.3f" result="Error">',
                      [EscapeForXML(GetCurrentSuiteName), EscapeForXML(error.FailedTest.GetName), TrueFalse[error.FailedTest.Enabled], error.FailedTest.ElapsedTestTime / 1000]));
   writeReport(Format('<failure name="%s" location="%s">', [EscapeForXML(error.ThrownExceptionName), EscapeForXML(error.LocationInfo)]));
   writeReport('<message>' + EscapeForXML(error.ThrownExceptionMessage,false) + '</message>');
   writeReport('</failure>');
   WriteInfoAndWarnings;
   writeReport('</test-case>');
end;

procedure TXMLTestListener.AddFailure(failure: TTestFailure);
begin
   writeReport(Format('<test-case name="%s%s" executed="%s" success="False" time="%1.3f" result="Failure">',
                      [EscapeForXML(GetCurrentSuiteName), EscapeForXML(failure.FailedTest.GetName), TrueFalse[failure.FailedTest.Enabled], failure.FailedTest.ElapsedTestTime / 1000]));
   writeReport(Format('<failure name="%s" location="%s">', [EscapeForXML(failure.ThrownExceptionName), EscapeForXML(failure.LocationInfo)]));
   writeReport('<message>' + EscapeForXML(failure.ThrownExceptionMessage,false) + '</message>');
   writeReport('</failure>');
   WriteInfoAndWarnings;
   writeReport('</test-case>');
end;


procedure TXMLTestListener.StartTest(test: ITest);
begin
  FInfoList.Clear;
  FWarningList.Clear;
end;

procedure TXMLTestListener.EndTest(test: ITest);
begin
end;

procedure TXMLTestListener.TestingStarts;
var
  sFileName : string;
begin
   startTime := GetTickCount;
   dtStartTime := Now;
   FOutputBuffer := TMemoryStream.Create;
   sFileName := ExtractFileName(ParamStr(0));
   writeReport(Format('<application name="%s" />',[sFileName]));
end;

procedure TXMLTestListener.TestingEnds(testResult: TTestResult);
var
{$IFDEF UNICODE}
  Preamble: TBytes;
  Buffer : TBytes;
{$ENDIF}
  runTime : Double;
  dtRunTime : TDateTime;
  successRate : Integer;
  h, m, s, l :Word;
  fs : TFileStream;
  sResult : string;
  sFileName : string;
  sNameSpace : string;

  procedure writeHeader(str : String);
{$IFDEF UNICODE}
  var
    Buffer : TBytes;
{$ENDIF}
  begin
    str := str + CRLF;
    {$IFDEF UNICODE}
    buffer := TEncoding.UTF8.GetBytes(str);
    fs.WriteBuffer(buffer[0],Length(buffer));
    {$ELSE}
    fs.Write(PChar(str)^,Length(str))
    {$ENDIF}
  end;


begin
   writeReport('</results>');
   writeReport('</test-suite>');
   writeReport('</results>');
   writeReport('</test-suite>');

   runtime := (GetTickCount - startTime) / 1000;
   if testResult.RunCount > 0 then
     successRate :=  Trunc(
        ((testResult.runCount - testResult.failureCount - testResult.errorCount)
         /testResult.runCount)
        *100)
   else
     successRate := 100;

   writeReport('<statistics>'+CRLF+
                  '<stat name="tests" value="'+intToStr(testResult.runCount)+'" />'+CRLF+
                  '<stat name="failures" value="'+intToStr(testResult.failureCount)+'" />'+CRLF+
                  '<stat name="errors" value="'+intToStr(testResult.errorCount)+'" />'+CRLF+
                  '<stat name="success-rate" value="'+intToStr(successRate)+'%" />'+CRLF+
                  '<stat name="started-at" value="'+DateTimeToStr(dtStartTime)+'" />'+CRLF+
                  '<stat name="finished-at" value="'+DateTimeToStr(now)+'" />'+CRLF+
                  Format('<stat name="runtime" value="%1.3f"/>', [runtime])+CRLF+
                  '</statistics>'+CRLF+
              '</test-results>');

   fs := TFileStream.Create(FFileName,fmCreate);
   try
    {$IFDEF UNICODE}
       //write the byte order mark
       Preamble := TEncoding.UTF8.GetPreamble;
       if Length(Preamble) > 0 then
          fs.WriteBuffer(Preamble[0], Length(Preamble));
       writeHeader('<?xml version="1.0" encoding="UTF-8" standalone="yes" ?>');
    {$ELSE}
       writeHeader('<?xml version="1.0" encoding="ISO-8859-1" standalone="yes" ?>');
    {$ENDIF}
       writeHeader(Format('<test-results total="%d" not-run="%d" errors="%d" failures="%d" date="%s" time="%s" >',
                      [RegisteredTests.CountTestCases,
                        RegisteredTests.CountTestCases - RegisteredTests.CountEnabledTestCases,
                          testResult.errorCount,testResult.FailureCount,
                          DateToStr(Now),
                            TimeToStr(Now)]));
       sFileName := ExtractFileName(ParamStr(0));
       sNameSpace := ChangeFileExt(sFileName,'');

       writeHeader(Format('<test-suite name="%s" type="Assembly" time="%1.3f">', [sFileName,runtime]));
       writeHeader('<results>');
       writeHeader(Format('<test-suite name="%s" type="Namespace" time="%1.3f">', [sNameSpace,runtime]));
       writeHeader('<results>');

      //write the memory stream to the file.
      FOutputBuffer.SaveToStream(fs);
   finally
      FreeAndNil(FOutputBuffer);
      fs.Free;
   end;


   if PrintReportToConsole then
   begin
      dtEndTime := now;
      dtRunTime := Now-dtStartTime;
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
  FInfoList.Add(Format('STATUS: %s: %s', [test.Name, Msg]));
end;

procedure TXMLTestListener.Warning(test :ITest; const Msg :string);
begin
  FWarningList.Add(Format('WARNING: %s: %s', [test.Name, Msg]));
end;

procedure TXMLTestListener.WriteInfoAndWarnings;
var
  i: Integer;
begin
  if FInfoList.Count > 0 then
  begin
    for i := 0 to FInfoList.Count - 1 do
        writeReport('<status>' + EscapeForXML(FInfoList.Strings[i],false) + '</status>');
  end;
  if FWarningList.Count > 0 then
  begin
    for i := 0 to FInfoList.Count - 1 do
        writeReport('<warning>' + EscapeForXML(FWarningList.Strings[i],false) + '</warning>');
  end;
end;

function TXMLTestListener.ShouldRunTest(test: ITest): boolean;
begin
  Result := test.Enabled;
  if not Result then
    writeReport(Format('<test-case name="%s%s" executed="False"/>',
                       [GetCurrentSuiteName, test.GetName]));
end;

procedure TXMLTestListener.EndSuite(suite: ITest);
begin
     if CompareText(suite.Name, ExtractFileName(Application.ExeName)) = 0 then
       Exit;
     writeReport('</results>');
     writeReport('</test-suite>');
     FSuiteStack.Delete(0);
end;

procedure TXMLTestListener.StartSuite(suite: ITest);
var
  s : string;
begin
   if CompareText(suite.Name, ExtractFileName(Application.ExeName)) = 0 then
     Exit;
   s := GetCurrentSuiteName + suite.Name;
   writeReport(Format('<test-suite name="%s" total="%d" notrun="%d" type="TestFixture">', [s, suite.CountTestCases, suite.CountTestCases - suite.CountEnabledTestCases]));
   FSuiteStack.Insert(0, suite.getName);
   writeReport('<results>');
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
  FSuiteStack.Free;
  FInfoList.Free;
  FWarningList.Free;
  if FOutputBuffer <> nil then
    FOutputBuffer.Free;
  inherited Destroy;
end;

function TXMLTestListener.GetCurrentSuiteName: string;
var
  c : Integer;
begin
  Result := '';
  for c := 0 to FSuiteStack.Count - 1 do
    Result := FSuiteStack[c] + '.' + Result;
end;

function TXMLTestListener.HasInfoOrWarnings: boolean;
begin
  result := (FInfoList.Count > 0) or (FWarningList.Count > 0);
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

end.
