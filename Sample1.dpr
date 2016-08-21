program Sample1;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  SysUtils,
  Delphi.Mocks.AutoMock in 'Delphi.Mocks.AutoMock.pas',
  Delphi.Mocks.Behavior in 'Delphi.Mocks.Behavior.pas',
  Delphi.Mocks.Expectation in 'Delphi.Mocks.Expectation.pas',
  Delphi.Mocks.Helpers in 'Delphi.Mocks.Helpers.pas',
  Delphi.Mocks.Interfaces in 'Delphi.Mocks.Interfaces.pas',
  Delphi.Mocks.MethodData in 'Delphi.Mocks.MethodData.pas',
  Delphi.Mocks.ObjectProxy in 'Delphi.Mocks.ObjectProxy.pas',
  Delphi.Mocks.ParamMatcher in 'Delphi.Mocks.ParamMatcher.pas',
  Delphi.Mocks in 'Delphi.Mocks.pas',
  Delphi.Mocks.Proxy in 'Delphi.Mocks.Proxy.pas',
  Delphi.Mocks.Proxy.TypeInfo in 'Delphi.Mocks.Proxy.TypeInfo.pas',
  Delphi.Mocks.ReturnTypePatch in 'Delphi.Mocks.ReturnTypePatch.pas',
  Delphi.Mocks.Utils in 'Delphi.Mocks.Utils.pas',
  Delphi.Mocks.Validation in 'Delphi.Mocks.Validation.pas',
  Delphi.Mocks.VirtualInterface in 'Delphi.Mocks.VirtualInterface.pas',
  Delphi.Mocks.VirtualMethodInterceptor in 'Delphi.Mocks.VirtualMethodInterceptor.pas',
  Delphi.Mocks.WeakReference in 'Delphi.Mocks.WeakReference.pas',
  Delphi.Mocks.When in 'Delphi.Mocks.When.pas',
  Sample1Main in 'Sample1Main.pas',
  Delphi.Mocks.Example.ProjectSaveCheckVisitor in 'Examples\Delphi.Mocks.Example.ProjectSaveCheckVisitor.pas',
  Delphi.Mocks.Examples.Factory in 'Examples\Delphi.Mocks.Examples.Factory.pas',
  Delphi.Mocks.Examples.Implement in 'Examples\Delphi.Mocks.Examples.Implement.pas',
  Delphi.Mocks.Examples.Interfaces in 'Examples\Delphi.Mocks.Examples.Interfaces.pas';

begin
  try
    TesTObjectMock;
    Writeln('--------------');
    Test;
    ReadLn;
  except
    on E: Exception do
    begin
      Writeln(E.ClassName, ': ', E.Message);
      ReadLn;
    end;
  end;
end.
