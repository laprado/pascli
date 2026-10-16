unit TestMockCommandBuilder;

{$MODE DELPHI}{$H+}

// the mock is a TVirtualInterface, which needs the Rtti unit, marked as experimental by FPC
{$WARN 5079 OFF}

interface

uses
  SysUtils, 
  Classes,
  rtti, 
  typinfo,
  Command.Interfaces;

type
  TCommandBuildMock = class(TVirtualInterface)
  private
    FName: String;
    FData: TStringList;
    procedure HandleInvoke(aMethod: TRttiMethod; const aArgs: TValueArray; out aResult: TValue);
  public
    constructor Create(aTypeInfo: PTypeInfo; AData: TStringList);

    class function New<T: IInterface>(AData: TStringList): T;
  end;

  procedure MockCommand(ABuilder: ICommandBuilder);
  function MockRegistryCommand(ABuilder: ICommandBuilder): Boolean;
  function MockInputLn: string;
  procedure MockOutput(const AMessage: string);
  procedure MockOutputColor(const AMessage: string; const AColor: Byte);

var
  MockCommandCapture, MockInputLnResult, CapturedOutput: string;

implementation

procedure MockCommand(ABuilder: ICommandBuilder);
begin  
  MockCommandCapture := 'executed';
end;

function MockRegistryCommand(ABuilder: ICommandBuilder): Boolean;
begin
  ABuilder
    .AddCommand('mock')
      .Description('mock command')
      .OnExecute(MockCommand);
  Result := True;
end;

function MockInputLn: string;
begin
  Result := MockInputLnResult;
end;

procedure MockOutput(const AMessage: string);
begin
  CapturedOutput := CapturedOutput + AMessage + #13#10;
end;

procedure MockOutputColor(const AMessage: string; const AColor: Byte);
begin
  CapturedOutput := CapturedOutput + AMessage;
end;

procedure TCommandBuildMock.HandleInvoke(aMethod: TRttiMethod; const aArgs: TValueArray; 
  out aResult: TValue);
var
  LResult: TArray<string>;
begin
  SetLength(LResult, 0);
  FData.Add(aMethod.Name);
  if SameText(aMethod.Name, 'validate') then
    aResult := TValue.From<TStringArray>(LResult);
end;

constructor TCommandBuildMock.Create(aTypeInfo: PTypeInfo; AData: TStringList);
begin
  inherited Create(aTypeInfo, HandleInvoke);
  FName := aTypeInfo^.Name;
  FData := AData;
end;

class function TCommandBuildMock.New<T>(AData: TStringList): T;
var
  LResult: TCommandBuildMock;
  td: PTypeData;
begin
  LResult := TCommandBuildMock.Create(PTypeInfo(TypeInfo(T)), AData);
  td := GetTypeData(PTypeInfo(TypeInfo(T)));
  LResult.QueryInterface(td^.GUID, Result);
end;

end.