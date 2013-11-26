unit Delphi.Mocks.Tests.Base;

interface

uses
  Rtti,
  SysUtils,
  TestFramework,
  Delphi.Mocks;

type
  //With RTTI--
  {$M+}
  ISimpleTestInterface_WithRTTI = interface
    ['{42D4CEDF-5982-4427-9F1F-D58E1F82FB82}']
    procedure Dud;
  end;

  IBlankTestInterface_WithRTTI = interface
    ['{C8726C8B-D695-4F19-823C-CE1FFBE59BED}']
  end;

  //Objects
  TSimpleTestObject_WithRTTI = class(TObject)
  public
    procedure Dud;
  end;

  TBlankTestObject_WithRTTI = class(TObject)
  end;
  {$M-}
  //--With RTTI


  //Without RTTI--
  ISimpleTestInterface_WithoutRTTI = interface
    ['{10405ECB-0AB1-4DBB-B673-7056683A4284}']
  end;

 {$M-}
  TSimpleTestObject_WithoutRTTI = class(TObject)
  public
    procedure blah;
  end;

  TSimpleRecord_WithoutRTTI = record
  end;
  //--Without RTTI


  TTestMock = class(TTestCase)
  published
    procedure CreateMock_With_Object_Which_Has_No_RTTI_Raises_No_Exception;
    procedure CreateMock_With_Object_Which_Has_RTTI_But_No_Exposed_Functions_Raises_Exception;

    procedure CreateMock_With_Interface_Which_Has_No_RTTI_Raises_Exception;
    procedure CreateMock_With_Interface_Which_Has_RTTI_Raises_No_Exception;
    procedure CreateMock_With_Interface_Which_Has_RTTI_But_No_Exposed_Functions_Raises_Exception;
    procedure CreateMock_With_Interface_We_Get_Valid_Proxy;

    procedure CreateMock_With_Record_Structure_Raises_Exception;
  end;

implementation

uses
  Delphi.Mocks.Helpers,
  Delphi.Mocks.Interfaces,
  Delphi.Mocks.InterfaceProxy,
  classes;

{ TTestMock }

procedure TTestMock.CreateMock_With_Object_Which_Has_No_RTTI_Raises_No_Exception;
var
  mock : TMock<TSimpleTestObject_WithOutRTTI>;
  exceptionRaised : Boolean;
  exceptionMsg: widestring;
begin
  exceptionRaised := False;
  exceptionMsg := '';
  try
    mock := TMock<TSimpleTestObject_WithOutRTTI>.Create;
  except
    on E: Exception do
    begin
       exceptionRaised := True;
       exceptionMsg := E.Message;
    end;
  end;

  CheckFalse(exceptionRaised, exceptionMsg);
end;

procedure TTestMock.CreateMock_With_Interface_We_Get_Valid_Proxy;
var
  mock : TMock<ISimpleTestInterface_WithRTTI>;
begin
  mock := TMock<ISimpleTestInterface_WithRTTI>.Create;

  CheckNotNull(mock.Instance);
end;

procedure TTestMock.CreateMock_With_Interface_Which_Has_No_RTTI_Raises_Exception;
var
  mock : TMock<ISimpleTestInterface_WithoutRTTI>;
begin
  StartExpectingException(EMockNoRTTIException);

  mock := TMock<ISimpleTestInterface_WithoutRTTI>.Create;

  //Would also like to test the exception string.
  StopExpectingException;
end;

procedure TTestMock.CreateMock_With_Interface_Which_Has_RTTI_But_No_Exposed_Functions_Raises_Exception;
var
  mock : TMock<IBlankTestInterface_WithRTTI>;
begin
  StartExpectingException(EMockNoRTTIException);

  mock := TMock<IBlankTestInterface_WithRTTI>.Create;

  //Would also like to test the exception string.
  StopExpectingException;
end;

procedure TTestMock.CreateMock_With_Interface_Which_Has_RTTI_Raises_No_Exception;
var
  mock : TMock<ISimpleTestInterface_WithRTTI>;
  exceptionRaised : Boolean;
  exceptionMsg: widestring;
begin
  exceptionRaised := False;
  exceptionMsg := '';

  try
    mock := TMock<ISimpleTestInterface_WithRTTI>.Create;
  except
    on E: Exception do
    begin
       exceptionRaised := True;
       exceptionMsg := E.Message;
    end;
  end;

  CheckFalse(exceptionRaised, exceptionMsg);
end;

procedure TTestMock.CreateMock_With_Object_Which_Has_RTTI_But_No_Exposed_Functions_Raises_Exception;
var
  mock : TMock<TBlankTestObject_WithRTTI>;
begin
  StartExpectingException(EMockNoRTTIException);

  mock := TMock<TBlankTestObject_WithRTTI>.Create;

  //Would also like to test the exception string.
  StopExpectingException;
end;

procedure TTestMock.CreateMock_With_Record_Structure_Raises_Exception;
var
  mock : TMock<TSimpleRecord_WithoutRTTI>;
begin
  StartExpectingException(EMockException);

  mock := TMock<TSimpleRecord_WithoutRTTI>.Create;

  //Would also like to test the exception string.
  StopExpectingException;
end;

{ TSimpleTestObject_WithRTTI }

procedure TSimpleTestObject_WithRTTI.Dud;
begin
  //Does nothing. Required to test condition of having methods.
  Exit;
end;

{ TSimpleTestObject_WithoutRTTI }

procedure TSimpleTestObject_WithoutRTTI.blah;
begin

end;

initialization
  TestFramework.RegisterTest(TTestMock.Suite);

end.
