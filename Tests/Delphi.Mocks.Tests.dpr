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
  {$IFDEF TESTINSIGHT}
  TestInsight.DUnitX,
  {$ENDIF }
  Delphi.Mocks.AutoMock in '..\Delphi.Mocks.AutoMock.pas',
  Delphi.Mocks.Behavior in '..\Delphi.Mocks.Behavior.pas',
  Delphi.Mocks.Expectation in '..\Delphi.Mocks.Expectation.pas',
  Delphi.Mocks.Helpers in '..\Delphi.Mocks.Helpers.pas',
  Delphi.Mocks.Interfaces in '..\Delphi.Mocks.Interfaces.pas',
  Delphi.Mocks.MethodData in '..\Delphi.Mocks.MethodData.pas',
  Delphi.Mocks.ObjectProxy in '..\Delphi.Mocks.ObjectProxy.pas',
  Delphi.Mocks.ParamMatcher in '..\Delphi.Mocks.ParamMatcher.pas',
  Delphi.Mocks in '..\Delphi.Mocks.pas',
  Delphi.Mocks.Proxy in '..\Delphi.Mocks.Proxy.pas',
  Delphi.Mocks.Proxy.TypeInfo in '..\Delphi.Mocks.Proxy.TypeInfo.pas',
  Delphi.Mocks.ReturnTypePatch in '..\Delphi.Mocks.ReturnTypePatch.pas',
  Delphi.Mocks.Utils in '..\Delphi.Mocks.Utils.pas',
  Delphi.Mocks.Validation in '..\Delphi.Mocks.Validation.pas',
  Delphi.Mocks.VirtualInterface in '..\Delphi.Mocks.VirtualInterface.pas',
  Delphi.Mocks.VirtualMethodInterceptor in '..\Delphi.Mocks.VirtualMethodInterceptor.pas',
  Delphi.Mocks.WeakReference in '..\Delphi.Mocks.WeakReference.pas',
  Delphi.Mocks.When in '..\Delphi.Mocks.When.pas',
  Sample1Main in '..\Sample1Main.pas',
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
  Delphi.Mocks.Utils.Tests in 'Delphi.Mocks.Utils.Tests.pas';

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
  try
    //note - text logger not implemented yet
    TestInsight.DUnitX.RunRegisteredTests;
  except
    on e : Exception do
    begin
      Writeln(e.Message);
      ReadLn;
    end;
  end;
  exit;
{$ENDIF}
  try
    try
      //Create the runner
      TDUnitX.CheckCommandLine;
      runner := TDUnitX.CreateRunner;
      runner.UseRTTI := True;
      runner.FailsOnNoAsserts := true;
      //tell the runner how we will log things
      logger := TDUnitXConsoleLogger.Create(false);
      runner.AddLogger(logger);
      nunitLogger := TDUnitXXMLNUnitFileLogger.Create(TDUnitX.Options.XMLOutputFile);
      runner.AddLogger(nunitLogger);

      //Run tests
      results := runner.Execute;
      //Let the CI Server know that something failed.
      if results.AllPassed then
        System.ExitCode := 0
      else
        System.ExitCode := EXIT_ERRORS;

      System.Writeln;
    except
      on E: Exception do
        Writeln(E.ClassName, ': ', E.Message);
    end;

  finally
    {$IFNDEF CI}
    //We don;t want this happening when running under CI.
    if TDUnitX.Options.ExitBehavior = TDUnitXExitBehavior.Pause then
    begin
      System.Write('Done.. press <Enter> key to quit.');
      System.Readln;
    end;
    {$ENDIF}
  end;


end.

