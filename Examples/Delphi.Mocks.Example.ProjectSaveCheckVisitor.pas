unit Delphi.Mocks.Example.ProjectSaveCheckVisitor;

interface

type
  {$M+}
  IVisitor = interface;

  IElement = interface
    ['{A2F4744E-7ED3-4DE3-B1E4-5D6C256ACBF0}']
    procedure Accept(const AVisitor : IVisitor);
  end;

  IVisitor = interface
    ['{0D150F9C-909A-413E-B29E-4B869C6BC309}']
    procedure Visit(const AElement : IElement);
  end;

  IProject = interface
    ['{807AF964-E937-4A8A-A3D2-34074EF66EE8}']
    procedure Save;
    function IsDirty : boolean;
  end;

  TElement = class(TInterfacedObject, IElement)
  public
    procedure Accept(const AVisitor : IVisitor);
  end;

  TProject = class(TInterfacedObject, IProject, IElement)
  protected
    function IsDirty : boolean;
    procedure Accept(const AVisitor : IVisitor);
  public
    procedure Save;
  end;

  TProjectSaveCheck = class(TInterfacedObject, IVisitor)
  public
    procedure Visit(const AElement : IElement);
  end;
  {$M-}

implementation

uses
  Rtti,
  SysUtils,
  TypInfo;

{ TProjectSaveCheckVisitor }

procedure TProjectSaveCheck.Visit(const AElement: IElement);
var
  project : IProject;
begin
  if not Supports(AElement, IProject, project) then
    raise Exception.Create('Element passed to Visit was not a IProject.');

  if project.IsDirty then
    project.Save;
end;

{ TProject }

procedure TProject.Accept(const AVisitor: IVisitor);
begin
  AVisitor.Visit(Self);
end;

function TProject.IsDirty: boolean;
begin
  Result := True;
end;

procedure TProject.Save;
begin
end;

{ TElement }

procedure TElement.Accept(const AVisitor: IVisitor);
begin

end;


end.
