program Sample1;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  SysUtils,
  Sample1Main in 'Sample1Main.pas',
  Delphi.Mocks.Example.ProjectSaveCheckVisitor in 'Delphi.Mocks.Example.ProjectSaveCheckVisitor.pas',
  Delphi.Mocks.Examples.Factory in 'Delphi.Mocks.Examples.Factory.pas',
  Delphi.Mocks.Examples.Implement in 'Delphi.Mocks.Examples.Implement.pas',
  Delphi.Mocks.Examples.Interfaces in 'Delphi.Mocks.Examples.Interfaces.pas';

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
