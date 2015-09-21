# Delphi Mocks

Delphi Mocks is a simple mocking framework for Delphi XE2 or later. It makes use of RTTI features that are only available in Delphi XE2, however I do hope to be able to get it working with earlier versions of Delphi (2010 or later) at some stage.

# Example

```Pascal
unit Delphi.Mocks.Examples.Interfaces;

interface

uses
  SysUtils,
  DUnitX.TestFramework,
  Delphi.Mocks;

type
  {$M+}
  TSimpleInterface = Interface
    ['{4131D033-2D80-42B8-AAA1-3C2DF0AC3BBD}']
    procedure SimpleMethod;
  end;

  TSystemUnderTestInf = Interface
    ['{5E21CA8E-A4BB-4512-BCD4-22D7F10C5A0B}']
    procedure CallsSimpleInterfaceMethod;
  end;
  {$M-}

  TSystemUnderTest = class(TInterfacedObject, TSystemUnderTestInf)
  private
    FInternalInf : TSimpleInterface;
  public
    constructor Create(const ARequiredInf: TSimpleInterface);
    procedure CallsSimpleInterfaceMethod;
  end;

  TMockObjectTests = class
  published
    procedure Simple_Interface_Mock;
  end;

implementation

uses
  Rtti;

{ TMockObjectTests }

procedure TMockObjectTests.Simple_Interface_Mock;
var
  mock : TMock<TSimpleInterface>;
  sutObject : TSystemUnderTestInf;
begin
  //SETUP: Create a mock of the interface that is required by our system under test object.
  mock := TMock<TSimpleInterface>.Create;

  //SETUP: Add a check that SimpleMethod is called atleast once.
  mock.Setup.Expect.AtLeastOnce.When.SimpleMethod;

  //SETUP: Create the system under test object passing an instance of the mock interface it requires.
  sutObject := TSystemUnderTest.Create(mock.Instance);

  //TEST: Call CallsSimpleInterfaceMethod on the system under test.
  sutObject.CallsSimpleInterfaceMethod;

  //VERIFY: That our passed in interface was called at least once when CallsSimpleInterfaceMethod was called.
  mock.Verify('CallsSimpleInterfaceMethod should call SimpleMethod');
end;

{ TSystemUnderTest }

procedure TSystemUnderTest.CallsSimpleInterfaceMethod;
begin
  FInternalInf.SimpleMethod;
end;

constructor TSystemUnderTest.Create(const ARequiredInf: TSimpleInterface);
begin
  FInternalInf := ARequiredInf;
end;

end.
```