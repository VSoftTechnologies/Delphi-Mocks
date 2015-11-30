unit Delphi.Mocks.Examples.Implement;

interface

uses
  Delphi.Mocks.Example.ProjectSaveCheckVisitor,
  DUnitX.TestFramework;

type
  TExample_InterfaceImplementTests = class
  published
    procedure Implement_Single_Interface;
    procedure Implement_Multiple_Interfaces;
    procedure SetupAndVerify_Mulitple_Interfaces;
    procedure SetupAndVerify_Object_And_Interfaces;
  end;


implementation

uses
  Rtti,
  TypInfo,
  SysUtils,
  Delphi.Mocks;


{ TExample_InterfaceImplementTests }

procedure TExample_InterfaceImplementTests.Implement_Single_Interface;
var
  visitorSUT : IVisitor;
  mockElement : TMock<IElement>;
  mockProject : TMock<IProject>;
  projectAsValue : TValue;
  pInfo : PTypeInfo;
  dud : IProject;
begin
  //Test that when we visit a project, and its dirty, we save.

  //CREATE - The visitor system under test.
  visitorSUT := TProjectSaveCheck.Create;

  //CREATE - Element mock we require.
  mockElement := TMock<IElement>.Create;
  mockProject := TMock<IProject>.Create;

  projectAsValue := TValue.From(mockProject.Instance);

  //SETUP - return mock project when IProject is asked for.
  pInfo := TypeInfo(IProject);
  mockElement.Setup.WillReturn(projectAsValue).When.QueryInterface(GetTypeData(pInfo).GUID, dud);

  //SETUP - mock project will show as dirty and will expect to be saved.
  mockProject.Setup.WillReturn(true).When.IsDirty;
  mockProject.Setup.Expect.Once.When.Save;

  try
    //TEST - Visit the mock element with
    visitorSUT.Visit(mockElement);

    //VERIFY - Make sure that save was indeed called.
    mockProject.Verify;

    //I don't expect to get here as an exception will be raised in Visit. The
    //mock can't return project via query interface as this is overriden internally
    //by the mocking library.

    //Didn't use CheckException to simpilfy this test.
    Assert.Fail;
  except
    Assert.Pass;
  end;
end;

procedure TExample_InterfaceImplementTests.Implement_Multiple_Interfaces;
var
  visitorSUT : IVisitor;
  mockElement : TMock<IElement>;
begin
  //Test that when we visit a project, and its dirty, we save.

  //CREATE - The visitor system under test.
  visitorSUT := TProjectSaveCheck.Create;

  //CREATE - Element mock we require.
  mockElement := TMock<IElement>.Create;

  //SETUP - Add the IProject interface as an implementation for the mock
  mockElement.Implement<IProject>;

  //SETUP - mock project will show as dirty and will expect to be saved.
  mockElement.Setup<IProject>.WillReturn(true).When.IsDirty;
  mockElement.Setup<IProject>.Expect.Once.When.Save;

  //TEST - Visit the mock element with
  visitorSUT.Visit(mockElement);

  //VERIFY - Make sure that save was indeed called.
  mockElement.VerifyAll;
end;

procedure TExample_InterfaceImplementTests.SetupAndVerify_Mulitple_Interfaces;
begin
end;

//This test fails at this time. Something to implement later. Need to make TObjectProxy pass
//the query interface call to the TProxyVirtualInterface list to be queried.
procedure TExample_InterfaceImplementTests.SetupAndVerify_Object_And_Interfaces;
var
  visitorSUT : IVisitor;
  mockElement : TMock<TElement>;
  setup : IMockSetup<IProject>;
begin
  //Test that when we visit a project, and its dirty, we save.

  //CREATE - The visitor system under test.
  visitorSUT := TProjectSaveCheck.Create;

  //CREATE - Element mock we require.
  mockElement := TMock<TElement>.Create;

  //SETUP - Add the IProject interface as an implementation for the mock
  mockElement.Implement<IProject>;

  //SETUP - mock project will show as dirty and will expect to be saved.
  setup := mockElement.Setup<IProject>;

  setup.WillReturn(true).When.IsDirty;
  setup.Expect.Once.When.Save;

  //TEST - Visit the mock element with
  visitorSUT.Visit(mockElement);

  //VERIFY - Make sure that save was indeed called.
  mockElement.VerifyAll;
end;



initialization

end.
