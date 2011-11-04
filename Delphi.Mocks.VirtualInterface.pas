{***************************************************************************}
{                                                                           }
{           Delphi.Mocks                                                    }
{                                                                           }
{           Copyright (C) 2011 Vincent Parrett                              }
{                                                                           }
{           http://www.finalbuilder.com                                     }
{                                                                           }
{                                                                           }
{***************************************************************************}
{                                                                           }
{  Licensed under the Apache License, Version 2.0 (the "License");          }
{  you may not use this file except in compliance with the License.         }
{  You may obtain a copy of the License at                                  }
{                                                                           }
{      http://www.apache.org/licenses/LICENSE-2.0                           }
{                                                                           }
{  Unless required by applicable law or agreed to in writing, software      }
{  distributed under the License is distributed on an "AS IS" BASIS,        }
{  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. }
{  See the License for the specific language governing permissions and      }
{  limitations under the License.                                           }
{                                                                           }
{***************************************************************************}

unit Delphi.Mocks.VirtualInterface;

interface
{$I 'Delphi.Mocks.inc'}


uses
  TypInfo,
  Rtti,
  Generics.Collections;

type
  {$IFDEF DELPHI_XE2_UP}
    TVirtualInterface = System.Rtti.TVirtualInterface;
  {$ELSE}
    //Attempt to create a cleanish room implementation of this class for D2010??
  {$ENDIF}



implementation

uses
  RTLConsts,
  SysUtils
  {$IFDEF DELPHI_XE2_UP}
   ;
  {$ELSE}
  ,PrivateHeap;
  {$ENDIF}

{$IFNDEF DELPHI_XE2_UP}

{$ENDIF}

end.
