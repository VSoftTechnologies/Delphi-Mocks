unit Delphi.Mocks.Validation;

interface

uses
  typInfo;

type
  TMocksValidation = class(TObject)
    class procedure CheckMockType(const ATypeInfo : PTypeInfo); static;
    class procedure CheckMockInterface(const ATypeInfo : PTypeInfo); static;
    class procedure CheckMockObject(const ATypeInfo : PTypeInfo); static;
  end;

implementation

uses
  Delphi.Mocks.Utils,
  Delphi.Mocks;

{ MocksValidation }

class procedure TMocksValidation.CheckMockInterface(const ATypeInfo : PTypeInfo);
begin
  //Check to make sure we have
  if not CheckInterfaceHasRTTI(ATypeInfo) then
    raise EMockNoRTTIException.Create(ATypeInfo.NameStr + ' does not have RTTI, specify {$M+} for the interface to enabled RTTI');
end;

class procedure TMocksValidation.CheckMockObject(const ATypeInfo: PTypeInfo);
begin
  //Check to make sure we have
  if not CheckClassHasRTTI(ATypeInfo) then
    raise EMockNoRTTIException.Create(ATypeInfo.NameStr + ' does not have RTTI, specify {$M+} for the object to enabled RTTI');
end;

class procedure TMocksValidation.CheckMockType(const ATypeInfo: PTypeInfo);
begin
  if not (ATypeInfo.Kind in [tkInterface,tkClass]) then
    raise EMockException.Create(ATypeInfo.NameStr + ' is not an Interface or Class. TMock<T> supports interfaces and classes only');

  case ATypeInfo.Kind of
    //NOTE: We have a weaker requirement for an object proxy opposed to an interface proxy.
    //NOTE: Object proxy doesn't require more than zero methods on the object.
    tkClass : CheckMockObject(ATypeInfo);
    tkInterface : CheckMockInterface(ATypeInfo);
  else
    raise EMockException.Create('Invalid type kind T');
  end;
end;


end.
