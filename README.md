# Delphi Mocks

![ Delphi Support ](https://img.shields.io/badge/Delphi%20Support-%20XE2%20...%2010.3%20Rio-blue.svg)
![ version ](https://img.shields.io/badge/version-%2010.0-a040ff.svg)

## Overview

Delphi Mocks is a mocking framework that allows to replace class dependencies with a light implementation of it. This light objects are called test doubles and they are used in unit testing.

Automated testing is mandatory this days and usually technical debt is measured with unit tests coverage. High test coverage allows to apply advanced refactorings and improve even very old code. However in object-oriented world, writing high quality unit test is challenging because of the composition. Object composition is the most popular way of building complex systems. It increases code reusability, but also makes automated testing much more difficult. Why? Because methods of such composed object can not be executed without its dependencies. Delphi Mocks framework enables dynamic substitution of this dependency and provides the opportunity to improve code test coverage.

## Coding to the interfaces

Known also as interface-based programming is a technique for writing interface-based classes and creating composed classes from interfaces - usually uses dependency injection to provide these dependent interfaces to encapsulated private fields of the class.

Delphi Mocks requires an interface to build test double and if you are not using interfaces too much you should start from changeing your coding style and then try this framework. Coding to the interfaces in Delphi is not difficult one and is just a matter of habit. To refactor existing code to interface-based approach is not that much difficult, of course it requires some experience, but can be easily adopted. This can be done with low risk refactoring, even without any test coverage.

## Why Delphi Mocks?

The main purpose of using this framework is to work faster. Manually writing fake classes for each dependency is a laborious work. Using Delphi Mocks this task be done much faster and in a much dynamic way. 

The ultimate goal of this framework is to write unit tests faster, ensure better test coverage and allow you to build more solid test harness. Using Delphi Mocks leads to higher system quality and greater developer satisfaction.

## What Delphi Mocks gives you?

Delphi Mocks can:

1) Creates an empty interface implementation with null methods that return predefined values only.
2) Creates the interface implementation with methods that have some logic - this is useful in legacy projects where the code is more complex and tightly coupled.
3) Verifies the behavior of the mocked interface - it means: how many times a particular method was called or what parameter values were given in the method call.
4) Mix all three above implementations in the one mock class.

# Original Example

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
