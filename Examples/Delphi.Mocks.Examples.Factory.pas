unit Delphi.Mocks.Examples.Factory;

interface

uses
  Rtti,
  TypInfo,
  SysUtils;

type
  {$M+}
  IFileService = interface
    ['{3BDAC049-F291-46CB-95A8-B177E3485752}']
    function OpenForAppend(const AFilename : string) : THandle;
    function WriteLineTo(const AHandle : THandle; const ALine : string) : boolean;
  end;

  IApplicationInfo = interface
    ['{43C0AE45-F57F-4620-A902-35CEAB370BC1}']
    function GetFileService : IFileService;
    property FileService : IFileService read GetFileService;
  end;

  ILogLine = interface
    ['{B230FBB5-EE90-4208-90A4-FF09274BD767}']
    function FormattedLine : string;
  end;

  ILogLines = interface
    ['{0CAF05DA-6828-4651-8431-F4E6815AF1C0}']
    function GetCount : Cardinal;
    function GetLine(const ALine: Cardinal) : ILogLine;

    property Line[const ALine : Cardinal] : ILogLine read GetLine;
    property Count : Cardinal read GetCount;
  end;

  ILogReceiver = interface
    ['{0EE8E9EC-0B2E-4052-827D-5EAF26AB08BC}']
    function GetLogsAbove(const ALogLevel : Integer) : ILogLines;
    function Log(const AMessage: string; const ALogLevel : Integer) : boolean;
  end;

  IMessage = interface
    ['{9955A5F2-3BC3-43DA-81FC-AD16E02BC93F}']
  end;

  IMessageChannel = interface
    ['{B2F9B8B0-93DD-4886-8141-CD043C32A9F1}']
    function SendMessage(const AMessage : IMessage) : boolean;
  end;

  ICoreService = interface
    ['{48584DC8-C425-4F6C-8FC5-438F04A90052}']
    function GetLogReciever : ILogReceiver;
    function GetApplication : IApplicationInfo;
    function GetAppMessageChannel : IMessageChannel;

    property Application : IApplicationInfo read GetApplication;
    property LogReciever : ILogReceiver read GetLogReciever;
    property AppMessageChannel : IMessageChannel read GetAppMessageChannel;
  end;

  ILogExporter = interface
    ['{037C6F9F-CA6A-4DE9-863C-0E3DC265B49B}']
    function ExportLog(const AMinLogLevel : Integer; const AFilename: TFilename) : integer;
  end;

  TLogExporter = class(TInterfacedObject, ILogExporter)
  private
    FLogReciever : ILogReceiver;
    FApplication : IApplicationInfo;
  public
    constructor Create(const AServices : ICoreService);
    destructor Destroy; override;
    function ExportLog(const AMinLogLevel : Integer; const AFilename: TFilename) : integer;
  end;
  {$M-}

  {$M+}
  TExample_MockFactoryTests = class
  published
    procedure Implement_Multiple_Interfaces;
    procedure Create_T_From_TypeInfo;
  end;
  {$M-}

  IFakeGeneric = interface
    ['{682057B0-E265-45F1-ABF7-12A25683AF63}']
    function Value : TValue;
  end;

  TFakeGeneric = class(TInterfacedObject, IFakeGeneric)
  private
    FValue : TValue;
  public
    constructor Create(const ATypeInfo : PTypeInfo);
    destructor Destroy; override;

    function Value : TValue;
  end;

  IFakeGeneric<T> = interface
    ['{87853316-A14D-4BC6-9124-D947662243F0}']
    function Value : T;
  end;

  TFakeGeneric<T> = class(TInterfacedObject, IFakeGeneric<T>)
  private
    FFakeGeneric : IFakeGeneric;
  public
    constructor Create;
    destructor Destroy; override;

    function Value : T;
  end;

implementation

uses
  Delphi.Mocks;

function CreateFakeGeneric(const TypeInfo: PTypeInfo) : TObject;
begin
  result := nil;
end;

{ TLogExporter }

constructor TLogExporter.Create(const AServices: ICoreService);
begin
  inherited Create;

  FLogReciever := AServices.LogReciever;
  FApplication := AServices.Application;
end;

destructor TLogExporter.Destroy;
begin
  FLogReciever := nil;
  FApplication := nil;

  inherited;
end;

function TLogExporter.ExportLog(const AMinLogLevel : Integer; const AFilename: TFilename) : integer;
var
  fileService : IFileService;
  fileHandle: THandle;
  logs: ILogLines;
  iLine: Integer;
begin
  //Very simplistic ExportLog function which uses a number of other services to
  //set its job done. The logic is simplistic, but the implementation over uses
  //services to show the power of AutoMocking, and the Factory.

  fileService := FApplication.FileService;

  //Create or open requested file.
  fileHandle := fileService.OpenForAppend(AFilename);

  //Make sure the got a valid handle from the file serice.
  if fileHandle = 0 then
    raise Exception.CreateFmt('The fileservice failed to return a handle for [%s]', [AFilename]);

  //Get the log from the log receiver for the passed in min log level.
  logs := FLogReciever.GetLogsAbove(AMinLogLevel - 1);

  //Write each line out with the formatting from the log.
  for iLine := 0 to logs.Count - 1 do
    fileService.WriteLineTo(fileHandle, logs.Line[iLine].FormattedLine);

  result := 0;
end;

{ TExample_MockFactoryTests }

procedure TExample_MockFactoryTests.Create_T_From_TypeInfo;
var
  fakeExporter : IFakeGeneric<TLogExporter>;
  fakeLine : IFakeGeneric<ILogLine>;
begin
  fakeExporter := TFakeGeneric<TLogExporter>.Create;

//  Assert.AreEqual(fakeExporter.Value.ClassName, 'TLogExporter');

  fakeLine := TFakeGeneric<ILogLine>.Create;

  //Assert.AreEqual(fakeLine.Value.FormattedLine, 'TLogExporter');
end;

procedure TExample_MockFactoryTests.Implement_Multiple_Interfaces;
  //var
  //  logExporterSUT : ILogExporter;
  //
  //  // mockFactory : TMockFactory;
  //  mockContainer : TAutoMockContainer;
  //  mockCoreService : TMock<ICoreService>;
begin
  //CREATE - Create a mock of the CoreService which we require for the LogExporter
  //         We do this through creating a MockFactory to generate the Mock

  //  mockFactory := TMockFactory.Create;
  //  mockContainer := TAutoMockContainer.Create(mockFactory);
  //
  //  mockCoreService := mockContainer.Mock<ICoreService>;
  //
  //  //CREATE - The log exporter ExportLog function is what we are looking at testing.
  //  logExporterSUT := TLogExporter.Create(mockCoreService);
  //
  //  //TEST - See if we can export a log.
  //  logExporterSUT.ExportLog(0, '');
  //
  //  //VERIFY - Make sure that everything we have attached to the factory and its mocks
  //  //         has correctly run.
  //  mockFactory.VerifyAll;
end;

{ TFakeGeneric }

constructor TFakeGeneric.Create(const ATypeInfo: PTypeInfo);
var
  ctx: TRttiContext;
  rType: TRttiType;
  AMethCreate: TRttiMethod;
  instanceType: TRttiInstanceType;
begin
  ctx := TRttiContext.Create;
  rType := ctx.GetType(ATypeInfo);

  for AMethCreate in rType.GetMethods do
  begin
    {$Message 'TODO Handle constructors with params.'}

    if (AMethCreate.IsConstructor) and (Length(AMethCreate.GetParameters) = 0) then
    begin
      instanceType := rType.AsInstance;

      FValue := AMethCreate.Invoke(instanceType.MetaclassType, []);

      Exit;
    end;
  end;
end;

destructor TFakeGeneric.Destroy;
begin
  FreeAndNil(FValue);
  inherited;
end;

function TFakeGeneric.Value: TValue;
begin
  Result := FValue;
end;

{ TFakeGeneric<T> }

constructor TFakeGeneric<T>.Create;
begin
  FFakeGeneric := TFakeGeneric.Create(TypeInfo(T));
end;

destructor TFakeGeneric<T>.Destroy;
begin
  FFakeGeneric := nil;
  inherited;
end;

function TFakeGeneric<T>.Value: T;
begin
  Result := FFakeGeneric.Value.AsType<T>;
end;


end.
