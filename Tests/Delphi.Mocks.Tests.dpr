program Delphi.Mocks.Tests;
{

  Delphi DUnit Test Project
  -------------------------
  This project contains the DUnit test framework and the GUI/Console test runners.
  Add "CONSOLE_TESTRUNNER" to the conditional defines entry in the project options
  to use the console test runner.  Otherwise the GUI test runner will be used by
  default.

}

{.$DEFINE XMLOUTPUT}
{.$DEFINE ISCONSOLE}

{$IFDEF ISCONSOLE}
{$APPTYPE CONSOLE}
{$ENDIF}

{$WARN DUPLICATE_CTOR_DTOR OFF}

uses
  Forms,
  DUnitX.TestFramework,
  DUnitX.Loggers.Console,
  DUnitX.Windows.Console,
  DUnitX.Loggers.XML.NUnit,
  SysUtils,
  Sample1Main in '..\Examples\Sample1Main.pas',
  Delphi.Mocks.Tests.AutoMock in 'Delphi.Mocks.Tests.AutoMock.pas',
  Delphi.Mocks.Tests.Base in 'Delphi.Mocks.Tests.Base.pas',
  Delphi.Mocks.Tests.Behavior in 'Delphi.Mocks.Tests.Behavior.pas',
  Delphi.Mocks.Tests.Expectations in 'Delphi.Mocks.Tests.Expectations.pas',
  Delphi.Mocks.Tests.InterfaceProxy in 'Delphi.Mocks.Tests.InterfaceProxy.pas',
  Delphi.Mocks.Tests.Interfaces in 'Delphi.Mocks.Tests.Interfaces.pas',
  Delphi.Mocks.Tests.MethodData in 'Delphi.Mocks.Tests.MethodData.pas',
  Delphi.Mocks.Tests.ObjectProxy in 'Delphi.Mocks.Tests.ObjectProxy.pas',
  Delphi.Mocks.Tests.Objects in 'Delphi.Mocks.Tests.Objects.pas',
  Delphi.Mocks.Tests.OpenArrayIntf in 'Delphi.Mocks.Tests.OpenArrayIntf.pas',
  Delphi.Mocks.Tests.Proxy in 'Delphi.Mocks.Tests.Proxy.pas',
  Delphi.Mocks.Tests.ProxyBase in 'Delphi.Mocks.Tests.ProxyBase.pas',
  Delphi.Mocks.Tests.TValue in 'Delphi.Mocks.Tests.TValue.pas',
  Delphi.Mocks.Tests.Utils in 'Delphi.Mocks.Tests.Utils.pas',
  Delphi.Mocks.Utils.Tests in 'Delphi.Mocks.Utils.Tests.pas',
  Delphi.Mocks.Examples.Matchers in 'Delphi.Mocks.Examples.Matchers.pas',
  Delphi.Mocks.Tests.Stubs in 'Delphi.Mocks.Tests.Stubs.pas';

{$R *.RES}


//{$IFDEF XMLOUTPUT}
//var
//  OutputFile : string = 'dunit-report.xml';
//
//var
//  ConfigFile : string;
//{$ENDIF}
//
//{$IFDEF ISCONSOLE}
//var
//  ExitBehavior: TRunnerExitBehavior;
//{$EndIf}
//
//begin
//  {$IFDEF ISCONSOLE}
//    {$IFDEF XMLOUTPUT}
//      if ConfigFile <> '' then
//      begin
//        RegisteredTests.LoadConfiguration(ConfigFile, False, True);
//        WriteLn('Loaded config file ' + ConfigFile);
//      end;
//      if ParamCount > 0 then
//        OutputFile := ParamStr(1);
//      WriteLn('Writing output to ' + OutputFile);
//      WriteLn('Running ' + IntToStr(RegisteredTests.CountEnabledTestCases) + ' of ' + IntToStr(RegisteredTests.CountTestCases) + ' test cases');
//      TXMLTestListener.RunRegisteredTests(OutputFile);
//    {$ELSE}
//      WriteLn('To run with rxbPause, use -p switch');
//      WriteLn('To run with rxbHaltOnFailures, use -h switch');
//      WriteLn('No switch runs as rxbContinue');
//
//      if FindCmdLineSwitch('p', ['-', '/'], true) then
//        ExitBehavior := rxbPause
//      else if FindCmdLineSwitch('h', ['-', '/'], true) then
//        ExitBehavior := rxbHaltOnFailures
//      else
//        ExitBehavior := rxbContinue;
//
//      TextTestRunner.RunRegisteredTests(ExitBehavior);
//    {$ENDIF}
//  {$ELSE}
//  ReportMemoryLeaksOnShutdown := True;
//  Application.Initialize;
//  TGUITestRunner.RunRegisteredTests;
//  {$ENDIF}

var
  runner : ITestRunner;
  results : IRunResults;
  logger : ITestLogger;
  nunitLogger : ITestLogger;
begin
{$IFDEF TESTINSIGHT}
  TestInsight.DUnitX.RunRegisteredTests;
  exit;
{$ENDIF}
  try
    //Check command line options, will exit if invalid
    TDUnitX.CheckCommandLine;
    //Create the test runner
    runner := TDUnitX.CreateRunner;
    //Tell the runner to use RTTI to find Fixtures
    runner.UseRTTI := True;
    //tell the runner how we will log things
    //Log to the console window
    logger := TDUnitXConsoleLogger.Create(true);
    runner.AddLogger(logger);
    //Generate an NUnit compatible XML File
    if (TDUnitX.Options.XMLOutputFile <> '') then
    begin
      nunitLogger := TDUnitXXMLNUnitFileLogger.Create(TDUnitX.Options.XMLOutputFile);
      runner.AddLogger(nunitLogger);
    end;
    runner.FailsOnNoAsserts := False; //When true, Assertions must be made during tests;

    //Run tests
    results := runner.Execute;
    if not results.AllPassed then
      System.ExitCode := EXIT_ERRORS;

    {$IFNDEF CI}
    //We don't want this happening when running under CI.
    if TDUnitX.Options.ExitBehavior = TDUnitXExitBehavior.Pause then
    begin
      System.Write('Done.. press <Enter> key to quit.');
      System.Readln;
    end;
    {$ENDIF}
  except
    on E: Exception do
      System.Writeln(E.ClassName, ': ', E.Message);
  end;



end.

