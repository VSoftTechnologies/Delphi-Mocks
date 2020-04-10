unit Delphi.Mocks.VirtualMethodInterceptor;

interface
{$I 'Delphi.Mocks.inc'}

uses
  Rtti,
  TypInfo,
  Generics.Collections,
  SysUtils;
  {$IFDEF DELPHI_XE_UP} //TVirtualMethodInterceptor introduced in DelphiXE
type
  TVirtualMethodInterceptor = System.Rtti.TVirtualMethodInterceptor;
  {$ELSE}
    //Attempt to create a cleanish room implementation of this class for D2010??
    //Difficult to do having seen the implementation of TVirtualMethodInterceptor
    //in XE/XE2
  {$ENDIF}

implementation
{$IFNDEF DELPHI_XE_UP}

{$ENDIF}
end.
