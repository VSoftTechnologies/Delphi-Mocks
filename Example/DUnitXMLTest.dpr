program DUnitXMLTest;

{$Define ISCONSOLE}
{$Define XMLOUTPUT}

{$IfDef ISCONSOLE}
{$APPTYPE CONSOLE}
{$EndIf}


uses
  SysUtils,
  TextTestRunner,
  TestFramework,
  GUITestRunner,
  Forms,
  VSoft.DUnit.XMLTestRunner in '..\VSoft.DUnit.XMLTestRunner.pas',
  VSoft.MSXML6 in '..\VSoft.MSXML6.pas',
  SampleTests in 'SampleTests.pas';

{$IfDef XMLOUTPUT}
var
  OutputFile : string = DEFAULT_FILENAME;

var
  ConfigFile : string;
{$EndIf}

{$IFDEF ISCONSOLE}
var
  ExitBehavior: TRunnerExitBehavior;
{$EndIf}

begin
  {$IfDef ISCONSOLE}
    {$IfDef XMLOUTPUT}
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
    {$else}
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
    {$endif}
  {$Else}
    Application.Initialize;
    TGUITestRunner.RunRegisteredTests;
  {$EndIf}
end.
