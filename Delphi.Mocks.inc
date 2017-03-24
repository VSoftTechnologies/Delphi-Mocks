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

 //Basic Version of Compiler Supported
{$IFDEF CONDITIONALEXPRESSIONS}  //Started being defined with D2009
   {$IF CompilerVersion < 21.0} // Before RAD Studio 2010
      {$DEFINE UNSUPPORTED_COMPILER_VERSION}
   {$IFEND}
   {$IF CompilerVersion > 22.0} // XE2 or later
      {$DEFINE SUPPORTS_REGEX}
   {$IFEND}
{$ELSE}
  {$DEFINE UNSUPPORTED_COMPILER_VERSION}
{$ENDIF}

{$IFDEF UNSUPPORTED_COMPILER_VERSION}
  Unsupported Compiler Version (Delphi 2010 or later required!)
{$ENDIF}

{$IFDEF VER210} // RAD Studio 2010
  {$DEFINE DELPHI_2010}
  {$DEFINE DELPHI_2010_UP}
{$ENDIF VER210}

{$IFDEF VER220} // RAD Studio XE
  {$DEFINE DELPHI_2010_UP}
  {$DEFINE DELPHI_XE}
  {$DEFINE DELPHI_XE_UP}
{$ENDIF VER220}

{$IFDEF VER230} // RAD Studio XE2
  {$DEFINE DELPHI_2010_UP}
  {$DEFINE DELPHI_XE_UP}
  {$DEFINE DELPHI_XE2}
  {$DEFINE DELPHI_XE2_UP}
{$ENDIF VER230}

{$IFDEF VER240} // RAD Studio XE3
  {$DEFINE DELPHI_2010_UP}
  {$DEFINE DELPHI_XE_UP}
  {$DEFINE DELPHI_XE2_UP}
  {$DEFINE DELPHI_XE3}
  {$DEFINE DELPHI_XE3_UP}
{$ENDIF VER240}

{$IFDEF VER250} // RAD Studio XE4
  {$DEFINE DELPHI_2010_UP}
  {$DEFINE DELPHI_XE_UP}
  {$DEFINE DELPHI_XE2_UP}
  {$DEFINE DELPHI_XE3_UP}
  {$DEFINE DELPHI_XE4}
  {$DEFINE DELPHI_XE4_UP}
{$ENDIF VER250}

{$IFDEF VER260} // RAD Studio XE5
  {$DEFINE DELPHI_2010_UP}
  {$DEFINE DELPHI_XE_UP}
  {$DEFINE DELPHI_XE2_UP}
  {$DEFINE DELPHI_XE3_UP}
  {$DEFINE DELPHI_XE4}
  {$DEFINE DELPHI_XE4_UP}
  {$DEFINE DELPHI_XE5}
  {$DEFINE DELPHI_XE5_UP}
{$ENDIF VER260}

{$IFDEF VER270} // RAD Studio XE6
  {$DEFINE DELPHI_2010_UP}
  {$DEFINE DELPHI_XE_UP}
  {$DEFINE DELPHI_XE2_UP}
  {$DEFINE DELPHI_XE3_UP}
  {$DEFINE DELPHI_XE4_UP}
  {$DEFINE DELPHI_XE5_UP}
  {$DEFINE DELPHI_XE6}
  {$DEFINE DELPHI_XE6_UP}
{$ENDIF VER270}

{$IFDEF VER280} // RAD Studio XE7
  {$DEFINE DELPHI_2010_UP}
  {$DEFINE DELPHI_XE_UP}
  {$DEFINE DELPHI_XE2_UP}
  {$DEFINE DELPHI_XE3_UP}
  {$DEFINE DELPHI_XE4_UP}
  {$DEFINE DELPHI_XE5_UP}
  {$DEFINE DELPHI_XE6_UP}
  {$DEFINE DELPHI_XE7}
  {$DEFINE DELPHI_XE7_UP}
{$ENDIF VER280}

{$IFDEF VER290} // RAD Studio XE8
  {$DEFINE DELPHI_2010_UP}
  {$DEFINE DELPHI_XE_UP}
  {$DEFINE DELPHI_XE2_UP}
  {$DEFINE DELPHI_XE3_UP}
  {$DEFINE DELPHI_XE4_UP}
  {$DEFINE DELPHI_XE5_UP}
  {$DEFINE DELPHI_XE6_UP}
  {$DEFINE DELPHI_XE7_UP}
  {$DEFINE DELPHI_XE8}
  {$DEFINE DELPHI_XE8_UP}
{$ENDIF VER290}

{$IFDEF VER300} // RAD Studio 10 Seattle
  {$DEFINE DELPHI_2010_UP}
  {$DEFINE DELPHI_XE_UP}
  {$DEFINE DELPHI_XE2_UP}
  {$DEFINE DELPHI_XE3_UP}
  {$DEFINE DELPHI_XE4_UP}
  {$DEFINE DELPHI_XE5_UP}
  {$DEFINE DELPHI_XE6_UP}
  {$DEFINE DELPHI_XE7_UP}
  {$DEFINE DELPHI_XE8_UP}
  {$DEFINE DELPHI_SEATTLE_UP}
  {$DEFINE DELPHI_SEATTLE}
{$ENDIF VER300}

{$IFDEF VER310} // RAD Studio 10 Berlin
  {$DEFINE DELPHI_2010_UP}
  {$DEFINE DELPHI_XE_UP}
  {$DEFINE DELPHI_XE2_UP}
  {$DEFINE DELPHI_XE3_UP}
  {$DEFINE DELPHI_XE4_UP}
  {$DEFINE DELPHI_XE5_UP}
  {$DEFINE DELPHI_XE6_UP}
  {$DEFINE DELPHI_XE7_UP}
  {$DEFINE DELPHI_XE8_UP}
  {$DEFINE DELPHI_SEATTLE_UP}
  {$DEFINE DELPHI_BERLIN_UP}
  {$DEFINE DELPHI_BERLIN}
{$ENDIF VER310}

{$IFDEF VER320} // RAD Studio 10 Tokyo
  {$DEFINE DELPHI_2010_UP}
  {$DEFINE DELPHI_XE_UP}
  {$DEFINE DELPHI_XE2_UP}
  {$DEFINE DELPHI_XE3_UP}
  {$DEFINE DELPHI_XE4_UP}
  {$DEFINE DELPHI_XE5_UP}
  {$DEFINE DELPHI_XE6_UP}
  {$DEFINE DELPHI_XE7_UP}
  {$DEFINE DELPHI_XE8_UP}
  {$DEFINE DELPHI_SEATTLE_UP}
  {$DEFINE DELPHI_BERLIN_UP}
  {$DEFINE DELPHI_TOKYO_UP}
  {$DEFINE DELPHI_TOKYO}
{$ENDIF VER310}

