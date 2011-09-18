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

uses
  TypInfo,
  Rtti,
  RIO,
  Generics.Collections;

type
  {$IFDEF VER230}
    TVirtualInterface = System.Rtti.TVirtualInterface;
  {$ELSE}

  /// This is intended to be a relatively clean room implementation of
  /// TVirtualInterface, so that we can use Delphi.Mocks with D2009+
  ///  but it's not going to be easy..
    TVirtualInterfaceInvokeEvent = reference to procedure(Method: TRttiMethod;
      const Args: TArray<TValue>; out Result: TValue);

    TMethodImplementationCallback = reference to procedure(UserData: Pointer;
                                    const Args: TArray<TValue>; out Result: TValue);

    TVirtualInterface = class(TInterfacedObject, IInterface)
    private type
      TMethodImpl = class
      private
        FMethod : TRttiMethod;
        FCallBack : TMethodImplementationCallback;
        FCodeAddress : Pointer;
        function GetCodeAddress: Pointer;
        function GetVirtualIndex: SmallInt;

        procedure GenerateStub;
      public
        constructor Create(const AMethod : TRttiMethod; const ACallBack : TMethodImplementationCallback);
        destructor Destroy;override;
        property Method : TRttiMethod read FMethod;
        property CodeAddress : Pointer read GetCodeAddress;
        property VirtualIndex: SmallInt read GetVirtualIndex;
      end;

    private
      FVirtualMethodTable : Pointer;
      FOnInvoke           : TVirtualInterfaceInvokeEvent; // Invoke Event
      FInterfaceIID       : TGUID;
      FContext            : TRttiContext; // Local reference to Context so metadata doesn't expire
      FMethodIntercepts   : TObjectList<TMethodImpl>;
    protected

      function VI_AddRef: Integer; virtual; stdcall;
      function VI_Release: Integer; virtual; stdcall;
      function VIQueryInterface(const IID: TGUID; out Obj): HResult; virtual; stdcall;


      function _AddRef: Integer; virtual; stdcall;
      function _Release: Integer; virtual; stdcall;
      function QueryInterface(const IID: TGUID; out Obj): HResult; virtual; stdcall;

    // Stub function called by all methods in the interface.
      procedure RawCallback(UserData: Pointer {TMethodImpl}; const Args: TArray<TValue>; out Result: TValue); virtual;

      procedure ErrorProc;

    public
    { Create an instance of TVirtualInterface that implements the methods of
      an interface.  PIID is the PTypeInfo for the Interface that is to be
      implemented. The Interface must have TypeInfo ($M+). Either inherit from
      IInvokable, or enable TypeInfo for the interface. Because this is an
      TInterfacedObject, it is reference counted and it should not be Freed directly.
      }
    constructor Create(PIID: PTypeInfo); overload;
    constructor Create(PIID: PTypeInfo; InvokeEvent: TVirtualInterfaceInvokeEvent); overload;
    destructor Destroy; override;
    { OnInvoke: Event raised when a method of the implemented interface is called.
      Assign a OnInvoke handler to perform some action on invoked methods.}
    property OnInvoke: TVirtualInterfaceInvokeEvent read FOnInvoke write FOnInvoke;

    end;


  {$ENDIF}



implementation

uses
  RTLConsts,
  SysUtils;

{$IFNDEF VER230}

type
  TCodeGenerator = class
  private
    FBuffer : array[0..1024] of Byte;
    FIndex  : integer;
  public
    constructor Create;
    procedure WriteByte(const value : Byte);
    function Allocate : Pointer;
  end;



{ TVirtualInterface }

constructor TVirtualInterface.Create(PIID: PTypeInfo);
var
  maxVirtualIndex : integer;
  methods: TArray<TRttiMethod>;
  method: TRttiMethod;
  typ: TRttiType;
  i : integer;
begin
  typ := FContext.GetType(PIID);
  FInterfaceIID := TRttiInterfaceType(Typ).GUID;
  FMethodIntercepts := TObjectList<TMethodImpl>.Create(true);

  //how many virtual method entries do we need?
  maxVirtualIndex := 2; //queryinterface = 0, _addref = 2, _release = 2
  methods := typ.GetMethods;
  for method in methods do
  begin
    if method.VirtualIndex > maxVirtualIndex then
      maxVirtualIndex := method.VirtualIndex;
    FMethodIntercepts.Add(TMethodImpl.Create(method,Self.RawCallback));
  end;

  //allocated our method table
  FVirtualMethodTable := AllocMem(SizeOf(Pointer)* (maxVirtualIndex+1));
  {$POINTERMATH ON} //neede so we can treat the methodtable as an array.
  //the first 3 slots are the IInterface methods
  PPointer(FVirtualMethodTable)[0] := @TVirtualInterface.VIQueryInterface;
  PPointer(FVirtualMethodTable)[1] := @TVirtualInterface.VI_AddRef;
  PPointer(FVirtualMethodTable)[2] := @TVirtualInterface.VI_Release;

  //hook up our generated methods
  for I := 0 to FMethodIntercepts.Count-1 do
    PPointer(FVirtualMethodTable)[FMethodIntercepts[I].VirtualIndex] := FMethodIntercepts[I].CodeAddress;

  //if any method generation failed then hook up to a method that will raise an exception when it's called.
  for I := 3 to maxVirtualIndex do
  	if PPointer(FVirtualMethodTable)[I] = nil then
			PPointer(FVirtualMethodTable)[I] := @TVirtualInterface.ErrorProc;
end;

constructor TVirtualInterface.Create(PIID: PTypeInfo; InvokeEvent: TVirtualInterfaceInvokeEvent);
begin
  Create(PIID);
  FOnInvoke := InvokeEvent;
end;

destructor TVirtualInterface.Destroy;
begin
  FMethodIntercepts.Free;
  if FVirtualMethodTable <> nil then
    FreeMem(FVirtualMethodTable);
  inherited;
end;

procedure TVirtualInterface.ErrorProc;
begin
  raise EInsufficientRtti.CreateRes(@SInsufficientRtti)
end;


function TVirtualInterface.QueryInterface(const IID: TGUID; out Obj): HResult;
begin
  if IsEqualGUID(IID,FInterfaceIID) then
  begin
    _AddRef; //important, add a reference to the interface we are returning
    Pointer(Obj) := @FVirtualMethodTable;
    Result := S_OK;
  end
  else
    result := inherited QueryInterface(IID,Obj);
end;

procedure TVirtualInterface.RawCallback(UserData: Pointer; const Args: TArray<TValue>; out Result: TValue);
begin

end;

function TVirtualInterface.VIQueryInterface(const IID: TGUID; out Obj): HResult;
begin
  //Note - we have to adjust the Self point to call the TVirtualInterface methods, because when this is called
  //it's pointing to the virtual method tables self pointer. must be a better way????
  Result := TVirtualInterface(PByte(Self) - (PByte(@Self.FVirtualMethodTable) - PByte(Self))).QueryInterface(IID, Obj);
end;

function TVirtualInterface.VI_AddRef: Integer;
begin

  Result := TVirtualInterface(PByte(Self) - (PByte(@Self.FVirtualMethodTable) - PByte(Self)))._AddRef;
end;

function TVirtualInterface.VI_Release: Integer;
begin
  Result := TVirtualInterface(PByte(Self) - (PByte(@Self.FVirtualMethodTable) - PByte(Self)))._Release;
end;

function TVirtualInterface._AddRef: Integer;
begin
  result := inherited;
end;

function TVirtualInterface._Release: Integer;
begin
  result := inherited;
end;



{ TVirtualInterface.TMethodImpl }

constructor TVirtualInterface.TMethodImpl.Create(const AMethod: TRttiMethod; const ACallBack: TMethodImplementationCallback);
begin
  FMethod := AMethod;
  FCallBack := ACallBack;
  //Now to create the actual implementation stub!!
  GenerateStub;


end;

destructor TVirtualInterface.TMethodImpl.Destroy;
begin
  if FCodeAddress <> nil then
    CodeHeap.FreeMem(FCodeAddress);
  inherited;
end;

procedure TVirtualInterface.TMethodImpl.GenerateStub;
begin
  //Generate the actual method implementation here.
  //Assembler will be needed.
  case FMethod.CallingConvention of
    ccReg: ;
    ccCdecl: ;
    ccPascal: ;
    ccStdCall: ;
    ccSafeCall: ;
  end;

  //Use CodeHeap to allocate the memory for the stub.

end;

function TVirtualInterface.TMethodImpl.GetCodeAddress: Pointer;
begin
  raise Exception.Create('not implemented');
end;

function TVirtualInterface.TMethodImpl.GetVirtualIndex: SmallInt;
begin
  result := FMethod.VirtualIndex;
end;

{ TCodeGenerator }

function TCodeGenerator.Allocate: Pointer;
begin
  result := nil;
  CodeHeap.GetMem(result,FIndex + 1);
end;

constructor TCodeGenerator.Create;
begin
  FIndex := -1;
end;


procedure TCodeGenerator.WriteByte(const value: Byte);
begin

end;

{$ENDIF}
end.
