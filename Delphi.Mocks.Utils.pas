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


unit Delphi.Mocks.Utils;

interface

uses
  TypInfo;



function CheckInterfaceHasRTTI(const info : PTypeInfo) : boolean;

implementation

uses
  SysUtils,
  IntfInfo;

function CheckInterfaceHasRTTI(const info : PTypeInfo) : boolean;
var
  IntfMetaData: TIntfMetaData;
begin
  result := False;
  case info.Kind of
    tkInterface :
    begin
      try
        GetIntfMetaData(info, IntfMetaData, True);
        result := True;
      except
      end;
    end;
  end;

end;



end.
