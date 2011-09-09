program Delphi.Mocks.Tests;
{

  Delphi DUnit Test Project
  -------------------------
  This project contains the DUnit test framework and the GUI/Console test runners.
  Add "CONSOLE_TESTRUNNER" to the conditional defines entry in the project options
  to use the console test runner.  Otherwise the GUI test runner will be used by
  default.

}

{.$DEFINE CONSOLE_TESTRUNNER}

{$IFDEF CONSOLE_TESTRUNNER}
{$APPTYPE CONSOLE}
{$ENDIF}

uses
  Forms,
  TestFramework,
  GUITestRunner,
  TextTestRunner,
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
  Delphi.Mocks.MethodData in '..\Delphi.Mocks.MethodData.pas';

{$R *.RES}

begin
  Application.Initialize;
  if IsConsole then
  begin
    with TextTestRunner.RunRegisteredTests do
      Free;
  end
  else
    GUITestRunner.RunRegisteredTests;
end.

