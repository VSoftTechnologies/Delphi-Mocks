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
  TestFramework,
  GUITestRunner,
  TextTestRunner,
  SysUtils,
  Delphi.Mocks.InterfaceProxy in '..\Delphi.Mocks.InterfaceProxy.pas',
  Delphi.Mocks in '..\Delphi.Mocks.pas',
  Delphi.Mocks.Utils in '..\Delphi.Mocks.Utils.pas',
  Delphi.Mocks.VirtualInterface in '..\Delphi.Mocks.VirtualInterface.pas',
  Delphi.Mocks.Tests.Utils in 'Delphi.Mocks.Tests.Utils.pas',
  Delphi.Mocks.Behavior in '..\Delphi.Mocks.Behavior.pas',
  Delphi.Mocks.Helpers in '..\Delphi.Mocks.Helpers.pas',
  Delphi.Mocks.When in '..\Delphi.Mocks.When.pas',
  Delphi.Mocks.Tests.Behavior in 'Delphi.Mocks.Tests.Behavior.pas',
  Delphi.Mocks.Interfaces in '..\Delphi.Mocks.Interfaces.pas',
  Delphi.Mocks.MethodData in '..\Delphi.Mocks.MethodData.pas',
  Delphi.Mocks.Tests.Expectations in 'Delphi.Mocks.Tests.Expectations.pas',
  Delphi.Mocks.Expectation in '..\Delphi.Mocks.Expectation.pas',
  Delphi.Mocks.ObjectProxy in '..\Delphi.Mocks.ObjectProxy.pas',
  Delphi.Mocks.ProxyBase in '..\Delphi.Mocks.ProxyBase.pas',
  Delphi.Mocks.Utils.Tests in 'Delphi.Mocks.Utils.Tests.pas',
  Delphi.Mocks.VirtualMethodInterceptor in '..\Delphi.Mocks.VirtualMethodInterceptor.pas',
  Delphi.Mocks.Tests.TValue in 'Delphi.Mocks.Tests.TValue.pas',
  Delphi.Mocks.Tests.Interfaces in 'Delphi.Mocks.Tests.Interfaces.pas',
  Delphi.Mocks.Tests.OpenArrayIntf in 'Delphi.Mocks.Tests.OpenArrayIntf.pas',
  Delphi.Mocks.Tests.MethodData in 'Delphi.Mocks.Tests.MethodData.pas',
  Delphi.Mocks.Tests.ProxyBase in 'Delphi.Mocks.Tests.ProxyBase.pas',
  Delphi.Mocks.Tests.Base in 'Delphi.Mocks.Tests.Base.pas',
  Delphi.Mocks.Tests.ObjectProxy in 'Delphi.Mocks.Tests.ObjectProxy.pas',
  Delphi.Mocks.Examples.Objects in 'Delphi.Mocks.Examples.Objects.pas',
  Delphi.Mocks.ReturnTypePatch in '..\Delphi.Mocks.ReturnTypePatch.pas',
  Delphi.Mocks.Tests.InterfaceProxy in 'Delphi.Mocks.Tests.InterfaceProxy.pas',
  VSoft.DUnit.XMLTestRunner in '..\DUnitXML\VSoft.DUnit.XMLTestRunner.pas',
  VSoft.MSXML6 in '..\DUnitXML\VSoft.MSXML6.pas';

{$R *.RES}


{$IFDEF XMLOUTPUT}
var
  OutputFile : string = 'dunit-report.xml';

var
  ConfigFile : string;
{$ENDIF}

{$IFDEF ISCONSOLE}
var
  ExitBehavior: TRunnerExitBehavior;
{$EndIf}

begin
  {$IFDEF ISCONSOLE}
    {$IFDEF XMLOUTPUT}
      if ConfigFile <> '' then
      begin
        RegisteredTests.LoadConfiguration(ConfigFile, False, True);
        WriteLn('Loaded config file ' + ConfigFile);
      end;
      if ParamCount > 0 then
        OutputFile := ParamStr(1);
      WriteLn('Writing output to ' + OutputFile);
      WriteLn('Running ' + IntToStr(RegisteredTests.CountEnabledTestCases) + ' of ' + IntToStr(RegisteredTests.CountTestCases) + ' test cases');
      TXMLTestListener.RunRegisteredTests(OutputFile);
    {$ELSE}
      WriteLn('To run with rxbPause, use -p switch');
      WriteLn('To run with rxbHaltOnFailures, use -h switch');
      WriteLn('No switch runs as rxbContinue');

      if FindCmdLineSwitch('p', ['-', '/'], true) then
        ExitBehavior := rxbPause
      else if FindCmdLineSwitch('h', ['-', '/'], true) then
        ExitBehavior := rxbHaltOnFailures
      else
        ExitBehavior := rxbContinue;

      TextTestRunner.RunRegisteredTests(ExitBehavior);
    {$ENDIF}
  {$ELSE}
  ReportMemoryLeaksOnShutdown := True;
  Application.Initialize;
  TGUITestRunner.RunRegisteredTests;
  {$ENDIF}
end.

