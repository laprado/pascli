unit TestCommandBuilder;

{$MODE DELPHI}{$H+}

interface

uses
  Classes, 
  SysUtils, 
  fpcunit, 
  testregistry,
  CustApp,
  Command.App,
  Command.Interfaces,
  Command.Builder;

type

  TTestCommandBuilder = class(TTestCase)
  private
    FApplication: TCommandApp;
    FBuilder: ICommandBuilder;
    FExeName: string;
  protected
    procedure SetUp; override;
    procedure TearDown; override;

    procedure BuilderConstructorNoName;
    procedure AddSecondDefaultCommand;
  published
    procedure TestConstructor;
    procedure TestConstructorExeNameNotProvided;
    procedure TestAddCommand;
    procedure TestAddCommandDefaultTwoTimes;    
    procedure TestAddCommandWithDescription;
    procedure TestAddCommandCheckConstraints;
    procedure TestAddCommandOnExecute;
    procedure TestAddCommandCallback;
    procedure TestAddArgument;
    procedure TestAddOption;
    procedure TestParseBasic;
    procedure TestParseOneArgumentNoCommand;    
    procedure TestParseOneArgumentOneCommand;
    procedure TestParseOneArgumentAndCommandWithOptions;
    procedure TestExecute;
    procedure TestParseCommandSelectedDefault;
    procedure TestParseCommandSelectedProvided;
    procedure TestParseCommandAsArgument;
    procedure TestParseCommandsFound;
    procedure TestParseCommandWithInvalidOption;
    procedure TestGetDefaultCommand;
    procedure TestParsedOptions;
    procedure TestCheckOption;
    procedure TestCheckOptionValueFollowedByOption;
    procedure TestCheckOptionValueShortFlag;
    procedure TestRunInvalidSetsExitCode;
    procedure TestParsedArguments;
    procedure TestGetRawArguments;
    procedure TestGetRawOptions;
    procedure TestHasCommands;
    procedure TestHasArguments;
    procedure TestHasOptions;
    procedure TestDefaultCommandWithOptionsWithoutProvidingCommand;
    procedure TestInputLn;
    procedure TestState;
  end;

implementation

uses
  TestMockCommandBuilder;

procedure TTestCommandBuilder.SetUp;
begin
  FApplication := TCommandApp.Create(nil);
  FApplication.Title := 'basic app';
  FExeName := ChangeFileExt(ExtractFileName(FApplication.ExeName), '');
  FBuilder := TCommandBuilder.Create(FExeName);
  FBuilder.InputLn := MockInputLn;
  FBuilder.Output := MockOutput;
  MockCommandCapture := '';
  MockInputLnResult := '';
end;

procedure TTestCommandBuilder.TearDown;
begin
  FApplication.Free;
end;

procedure TTestCommandBuilder.BuilderConstructorNoName;
begin
  TCommandBuilder.Create('');
end;

procedure TTestCommandBuilder.TestConstructor;
var
  LBuilder: ICommandBuilder;
begin
  LBuilder := TCommandBuilder.Create(FExeName);

  AssertTrue('Valid instance', Assigned(LBuilder));
  AssertTrue('Application instance exe name differs from FApplication.ExeName', LBuilder.ExeName = FExeName);
end;

procedure TTestCommandBuilder.TestConstructorExeNameNotProvided;
begin
  AssertException('Should raise error with no exe name provided for constructor.', 
    Exception,     
    BuilderConstructorNoName);
end;

procedure TTestCommandBuilder.TestAddCommand;
var
  LBuilder: ICommandBuilder;
begin
  LBuilder := TCommandBuilder.Create(FExeName);

  LBuilder
    .AddCommand('test1', 'first command', @MockCommand, [ccDefault])
    .AddCommand('test2', 'second command', @MockCommand, []);

  AssertEquals('Commands added should be 2', 2, Length(LBuilder.Commands));
  AssertEquals('Second command name should be "test2"', 'test2', LBuilder.Commands[1].Name);
end;

procedure TTestCommandBuilder.AddSecondDefaultCommand;
begin
  TCommandBuilder.New('my command test')
    .AddCommand('test1', 'first default command', @MockCommand, [ccDefault])
    .AddCommand('test2', 'second default command', @MockCommand, [ccDefault]);
end;

procedure TTestCommandBuilder.TestAddCommandDefaultTwoTimes;
begin
  AssertException(
    'Should raise error with two default commands added.', 
    Exception,     
    AddSecondDefaultCommand);
end;

procedure TTestCommandBuilder.TestAddCommandWithDescription;
begin
  FBuilder
    .AddCommand('test')
      .Description('test command')
    .AddCommand('withoutdescription');

  AssertEquals('Commands added should be 2', 2, Length(FBuilder.Commands));
  AssertEquals('Command test should have description', 'test command', FBuilder.Commands[0].Description);
  AssertEquals('Command withoutdescription should have no description', '', FBuilder.Commands[1].Description);
end;

procedure TTestCommandBuilder.TestAddCommandCheckConstraints;
begin
  FBuilder
    .AddCommand('test')
      .Description('test command')
      .CheckConstraints([ccDefault, ccRequiresOneArgument]);

  AssertEquals('Commands added should be 1', 1, Length(FBuilder.Commands));
  AssertTrue('Command test should have constraint ccDefault', 
    ccDefault in FBuilder.Commands[0].Constraints);
  AssertTrue('Command test should have constraint ccRequiresOneArgument', 
    ccRequiresOneArgument in FBuilder.Commands[0].Constraints);
end;

procedure TTestCommandBuilder.TestAddCommandOnExecute;
begin
  FBuilder
    .AddCommand('test')
      .Description('test command')
      .OnExecute(@MockCommand);

  AssertEquals('Commands added should be 1', 1, Length(FBuilder.Commands));
  AssertTrue('Command test should have callback', Assigned(FBuilder.Commands[0].Callback));
end;

procedure TTestCommandBuilder.TestAddCommandCallback;
begin
  FBuilder
    .AddCommand(@MockRegistryCommand);

  AssertEquals('Commands added should be 1', 1, Length(FBuilder.Commands));
  AssertTrue('Command test should have callback', Assigned(FBuilder.Commands[0].Callback));
end;

procedure TTestCommandBuilder.TestAddArgument;
var
  LBuilder: ICommandBuilder;
begin
  // arrange
  LBuilder := TCommandBuilder.Create(FExeName);
  LBuilder.AddArgument('file name', acOptional);

  AssertEquals('Number of arguments expected to be 1.', 1, Length(LBuilder.Arguments));
  AssertEquals('Argument name does not match', 'file name', LBuilder.Arguments[0].Description);
  AssertTrue('Argument constraint does not match. Should be acOptional.', 
    LBuilder.Arguments[0].Constraint = acOptional);
end;

procedure TTestCommandBuilder.TestAddOption;
var
  LBuilder: ICommandBuilder;
begin
  LBuilder := TCommandBuilder.Create(FExeName);

  LBuilder
    .AddCommand('test1', 'first command', @MockCommand, [ccDefault])
      .AddOption('a', 'a_option', 'option a for command test1', [])
    .AddCommand('test2', 'second command', @MockCommand, [])
      .AddOption('b', 'b_option', 'option b for command test1', []);

  AssertEquals('Number of options for command test1 does not match', 1, Length(LBuilder.Commands[0].Options));
  AssertEquals('First option for command "test1" should be "a"', 'a', LBuilder.Commands[0].Options[0].Flag);
  AssertEquals('Number of options for command test2 does not match', 1, Length(LBuilder.Commands[1].Options));
  AssertEquals('First option for command "test2" should be "b"', 'b', LBuilder.Commands[1].Options[0].Flag);
end;

procedure TTestCommandBuilder.TestParseBasic;
begin
  // arrange
  FBuilder
    .AddCommand('test', 'first command', @MockCommand, [ccDefault])
      .AddOption('d', 'doption', 'option d for command test', [])
    .AddArgument('file argument', acOptional)
    .UseArguments(['test', '-d', 'test1.txt']);

  // act
  FBuilder.Parse;

  // assert
  AssertTrue('Selected command should be assigned.', Assigned(FBuilder.CommandSelected));
  AssertEquals('Number of options does not match.', 1, Length(FBuilder.GetParsedOptions));
  AssertEquals('Number of arguments does not match.', 1, Length(FBuilder.GetParsedArguments));
end;

procedure TTestCommandBuilder.TestParseOneArgumentNoCommand;
begin
  // act
  FBuilder
    .AddArgument('single argument', acOptional)
    .UseArguments(['test'])
    .Parse;

  // assert
  AssertTrue('Selected command cannot be assigned.', not Assigned(FBuilder.CommandSelected));
  AssertEquals('Should have 1 parsed argument.', 1, Length(FBuilder.GetParsedArguments));
  AssertEquals('Should have ''test'' parsed argument.', 'test', FBuilder.GetParsedArguments[0].Value);
end;

procedure TTestCommandBuilder.TestParseOneArgumentOneCommand;
begin
  // act
  FBuilder
    .AddCommand('cmd', 'cmd command', MockCommand, [ccDefault, ccRequiresOneArgument])
    .AddArgument('single argument', acOptional)
    .UseArguments(['cmd', 'argforcmd'])
    .Parse;

  // assert
  AssertTrue('Selected command cannot be assigned.', Assigned(FBuilder.CommandSelected));
  AssertEquals('Selected command name should be "cmd".', 'cmd', FBuilder.CommandSelected.Name);
  AssertEquals('Should have 1 parsed argument.', 1, Length(FBuilder.GetParsedArguments));
  AssertEquals('Should have ''argforcmd'' parsed argument.', 'argforcmd', FBuilder.GetParsedArguments[0].Value);
end;

procedure TTestCommandBuilder.TestParseOneArgumentAndCommandWithOptions;
begin
  // arrange
  FBuilder
    .AddCommand('cmd', 'cmd command', MockCommand, [ccDefault, ccRequiresOneArgument])
      .AddOption('a', 'a-first', 'a is the first option', [])
      .AddOption('b', 'b-second', 'b is the second option', [])
    .AddArgument('single argument', acOptional)
    .UseArguments(['cmd', '-a', '-b', 'argforcmd'])
    .Parse;

  // assert
  AssertTrue('Selected must be assigned.', Assigned(FBuilder.CommandSelected));
  AssertEquals('Selected command name should be "cmd".', 'cmd', FBuilder.CommandSelected.Name);
  AssertEquals('Number of parsed options should be 2', 2, Length(FBuilder.ParsedOptions));
  AssertEquals('Should have 1 parsed argument.', 1, Length(FBuilder.GetParsedArguments));
  AssertEquals('Should have ''argforcmd'' parsed argument.', 'argforcmd', FBuilder.GetParsedArguments[0].Value);  
end;

procedure TTestCommandBuilder.TestExecute;
begin
  // arrange
  FBuilder
    .AddCommand('cmd', 'cmd command', MockCommand, [ccDefault, ccNoParameters])
    .UseArguments(['cmd'])
    .Parse;
  FBuilder.Validate;

  // act
  FBuilder.Execute;

  // assert 
  AssertEquals('MockCommandCapture should has value "executed"', 'executed', MockCommandCapture);
end;

procedure TTestCommandBuilder.TestParseCommandSelectedDefault;
begin
  // arrange
  FBuilder
    .AddCommand('cmd', 'cmd command', MockCommand, [ccDefault, ccNoParameters])
    .UseArguments([])
    .Parse;
  
  // act
  FBuilder.Validate;

  // assert 
  AssertTrue('CommandSelected should assigned', Assigned(FBuilder.CommandSelected)); 
  AssertEquals('Command selected name must match default command', 'cmd', FBuilder.CommandSelected.Name);
end;

procedure TTestCommandBuilder.TestParseCommandSelectedProvided;
begin
  // arrange
  FBuilder
    .AddCommand('cmd', 'cmd command', MockCommand, [ccNoParameters])
    .UseArguments(['cmd'])
    .Parse;
  
  // act
  FBuilder.Validate;

  // assert 
  AssertTrue('CommandSelected should assigned', Assigned(FBuilder.CommandSelected)); 
  AssertEquals(
    'Command selected name must match command provided as parameter', 
    'cmd', 
    FBuilder.CommandSelected.Name);  
end;

procedure TTestCommandBuilder.TestParseCommandAsArgument;
begin
  // arrange
  FBuilder
    .AddCommand('cmd', 'cmd command', MockCommand, [ccNoArgumentsButCommands])
    .AddCommand('another', 'another command that can be used as argument', MockCommand, [ccNoParameters])
    .UseArguments(['cmd', 'another'])
    .Parse;
  
  // act
  FBuilder.Validate;

  // assert 
  AssertTrue('CommandSelected should assigned', Assigned(FBuilder.CommandSelected)); 
  AssertEquals(
    'Command selected name must match command provided as parameter', 
    'cmd', 
    FBuilder.CommandSelected.Name);  
  AssertTrue('CommandAsArgument should assigned', Assigned(FBuilder.CommandAsArgument)); 
  AssertEquals(
    'Command as argument name must match command provided as argument', 
    'another', 
    FBuilder.CommandAsArgument.Name);      
end;

procedure TTestCommandBuilder.TestParseCommandsFound;
begin
  // arrange
  FBuilder
    .AddCommand('cmd', 'cmd command', MockCommand, [ccNoArgumentsButCommands])
    .AddCommand('another', 'another command that can be used as argument', MockCommand, [ccNoParameters])
    .UseArguments(['cmd', 'another'])
    .Parse;
  
  // act
  FBuilder.Validate;

  // assert 
  AssertEquals(
    'Command found must match number of commands provided as parameters', 
    2, 
    FBuilder.GetCommandsFound);  
end;

procedure TTestCommandBuilder.TestParseCommandWithInvalidOption;
var
  LErrors: TArray<string>;
begin
  // arrange
  FBuilder
    .AddCommand('cmd', 'cmd command', MockCommand, [ccNoArgumentsButCommands])
    .AddCommand('another', 'another command that can be used as argument', MockCommand, [ccNoParameters])
    .UseArguments(['cmd', 'anotherddd'])
    .Parse;
  
  // act
  LErrors := FBuilder.Validate;

  // assert 
  AssertEquals('Should return an error', 1, Length(LErrors));
end;

procedure TTestCommandBuilder.TestGetDefaultCommand;
begin
  // arrange
  FBuilder
    .AddCommand('cmd', 'cmd command', MockCommand, [])
    .AddCommand('default', 'default command', MockCommand, [ccDefault]);  

  // assert
  AssertEquals('Default command name must be "default"', 'default', FBuilder.GetDefaultCommand.Name);
end;

procedure TTestCommandBuilder.TestParsedOptions;
var
  LOptions: TArray<IOption> = [];
begin
  // arrange
  FBuilder
    .AddCommand('cmd', 'cmd command', MockCommand, [ccDefault])
      .AddOption('a', 'a-option', 'a option', [])
      .AddOption('b', 'long-option', 'long option name to be used as argument', [])
      .AddOption('c', 'c-option', 'shoud not be used is this test')
    .UseArguments(['cmd', '-a', '--long-option', '--invalidoption'])
    .Parse;

  // act
  LOptions := FBuilder.GetParsedOptions;

  // assert
  AssertEquals('Must match number of options found', 2, Length(LOptions));
  AssertEquals('First option should be', 'a', LOptions[0].Flag);
  AssertEquals('Second option should be', 'b', LOptions[1].Flag);
end;

procedure TTestCommandBuilder.TestCheckOption;
begin
   // arrange
  FBuilder
    .AddCommand('cmd', 'cmd command', MockCommand, [ccDefault])
      .AddOption('a', 'a-option', 'a option', [])
      .AddOption('b', 'long-option', 'long option name to be used as argument', [])
      .AddOption('c', 'c-option', 'shoud not be used is this test')
    .UseArguments(['cmd', '-a', '--long-option', '--invalidoption'])
    .Parse;

  // assert
  AssertTrue('Must find option "a"', FBuilder.CheckOption('a'));
  AssertTrue('Must find option "a-option"', FBuilder.CheckOption('a-option'));
  AssertTrue('Must find option "b"', FBuilder.CheckOption('b'));
  AssertTrue('Must find option "long-option"', FBuilder.CheckOption('long-option'));  
  AssertFalse('Must ignore "invalidoption"', FBuilder.CheckOption('invalidoption'));
  AssertFalse('Must not find "c-option"', FBuilder.CheckOption('c-option'));
end;

procedure TTestCommandBuilder.TestParsedArguments;
var
  LArguments: TArray<IArgument> = [];
begin
  // arrange
  FBuilder
    .AddCommand('cmd', 'cmd command', MockCommand, [ccDefault])
      .AddOption('a', 'a-option', 'a option', [])
      .AddOption('b', 'long-option', 'long option name to be used as argument', [])
      .AddOption('c', 'c-option', 'shoud not be used is this test')
    .AddArgument('file name', acOptional)
    .UseArguments(['cmd', '-a', '--long-option', 'project.lpr', '--invalidoption'])
    .Parse;

  // act
  LArguments := FBuilder.GetParsedArguments;

  // assert
  AssertEquals('Must match number of arguments found', 1, Length(LArguments));
  AssertEquals('Must match argument description', 'file name', LArguments[0].Description);
  AssertEquals('Must match argument value', 'project.lpr', LArguments[0].Value);
end;

procedure TTestCommandBuilder.TestGetRawArguments;
var
  LArguments: TArray<string> = [];
begin
  // arrange
  FBuilder
    .AddCommand('cmd', 'cmd command', MockCommand, [ccDefault])
      .AddOption('a', 'a-option', 'a option', [])
      .AddOption('b', 'long-option', 'long option name to be used as argument', [])
      .AddOption('c', 'c-option', 'shoud not be used is this test')
    .AddArgument('file name', acOptional)
    .UseArguments(['cmd', '-a', '--long-option', 'project.lpr', 'another argument'])
    .Parse;

  // act
  LArguments := FBuilder.GetRawArguments;

  // assert
  AssertEquals('Must match number of arguments found', 3, Length(LArguments));
  AssertEquals('Must match first argument name', 'cmd', LArguments[0]);
  AssertEquals('Must match second argument name', 'project.lpr', LArguments[1]);
  AssertEquals('Must match third argument name', 'another argument', LArguments[2]);
  
end;

procedure TTestCommandBuilder.TestCheckOptionValueFollowedByOption;
var
  LValue: string;
begin
  FBuilder
    .AddCommand('cmd', 'cmd command', MockCommand, [ccDefault])
      .AddOption('n', 'name', 'name option', [], ocRequiresValue)
      .AddOption('v', 'verbose', 'verbose option', [])
    .UseArguments(['cmd', '--name=pascli', '--verbose'])
    .Parse;

  AssertTrue('Must find option "name"', FBuilder.CheckOption('name', LValue));
  AssertEquals('The following option must not reset the value', 'pascli', LValue);
  AssertTrue('Must find option "verbose"', FBuilder.CheckOption('verbose'));
end;

procedure TTestCommandBuilder.TestCheckOptionValueShortFlag;
var
  LValue: string;
begin
  FBuilder
    .AddCommand('cmd', 'cmd command', MockCommand, [ccDefault])
      .AddOption('n', 'name', 'name option', [], ocRequiresValue)
      .AddOption('v', 'verbose', 'verbose option', [])
    .UseArguments(['cmd', '-vn=pascli'])
    .Parse;

  AssertEquals('Raw options must keep the dash of each flag', '-v', FBuilder.GetRawOptions[0]);
  AssertEquals('Raw options must keep the dash of the flag with value', '-n=pascli', FBuilder.GetRawOptions[1]);
  AssertTrue('Must find option "n"', FBuilder.CheckOption('n', LValue));
  AssertEquals('pascli', LValue);
  AssertTrue('Must find option "v"', FBuilder.CheckOption('v'));
end;

procedure TTestCommandBuilder.TestRunInvalidSetsExitCode;
begin
  FBuilder
    .AddCommand('cmd', 'cmd command', MockCommand, [ccDefault, ccRequiresOneArgument])
    .AddArgument('file name', acOptional)
    .UseArguments(['cmd']);

  ExitCode := 0;
  FBuilder.Run;
  try
    AssertEquals('A command that fails the validation must set the exit code', 1, ExitCode);
  finally
    ExitCode := 0;
  end;
end;

procedure TTestCommandBuilder.TestGetRawOptions;
var
  LOptions: TArray<string> = [];
begin
  // arrange
  FBuilder
    .AddCommand('cmd', 'cmd command', MockCommand, [ccDefault])
      .AddOption('a', 'a-option', 'a option', [])
      .AddOption('b', 'long-option', 'long option name to be used as argument', [])
      .AddOption('c', 'c-option', 'shoud not be used is this test')
    .AddArgument('file name', acOptional)
    .UseArguments(['cmd', '-a', '--long-option', 'project.lpr', '--another-option'])
    .Parse;

  // act
  LOptions := FBuilder.GetRawOptions;

  // assert
  AssertEquals('Must match number of options found', 3, Length(LOptions));
  AssertEquals('Must match first argument name', '-a', LOptions[0]);
  AssertEquals('Must match second argument name', '--long-option', LOptions[1]);
  AssertEquals('Must match third argument name', '--another-option', LOptions[2]); 
end;

procedure TTestCommandBuilder.TestHasCommands;
begin
  AssertFalse('FBuilder does not have commands', FBuilder.HasArguments);
  FBuilder.AddCommand('cmd', 'cmd', MockCommand, [ccDefault]);
  AssertTrue('Builder has commands.', FBuilder.HasCommands);
end;

procedure TTestCommandBuilder.TestHasArguments;
begin
  AssertFalse('FBuilder does not have arguments', FBuilder.HasCommands);
  FBuilder.AddArgument('file name', acOptional);
  AssertTrue('Builder has arguments.', FBuilder.HasArguments);  
end;

procedure TTestCommandBuilder.TestHasOptions;
begin
  AssertFalse('FBuilder does not have options', FBuilder.HasOptions);
  FBuilder.AddCommand('cmd', 'cmd', MockCommand, [ccDefault]);
  FBuilder.AddOption('a', 'a-option', 'a option', []);
  AssertTrue('Builder has options.', FBuilder.HasOptions);    
end;

procedure TTestCommandBuilder.TestDefaultCommandWithOptionsWithoutProvidingCommand;
var
  LOptions: TArray<IOption> = [];
begin
  // arrange
  FBuilder
    .AddCommand('default', 'default command', MockCommand, [ccDefault])
      .AddOption('a', 'a-option', 'a option', [])
      .AddOption('b', 'long-option', 'long option name to be used as argument', [])
    .UseArguments(['-a', '--long-option'])
    .Parse;  

  // act
  FBuilder.Validate;
  LOptions := FBuilder.GetParsedOptions;

  // assert
  AssertTrue('Default command shoud be assigned.', Assigned(FBuilder.CommandSelected));
  AssertEquals('CommandSelect name should match.', 'default', FBuilder.CommandSelected.Name);
  AssertEquals('Should match number of parsed options', 2, Length(LOptions));
  AssertEquals('Should match first option flag', 'a', LOptions[0].Flag);
  AssertEquals('Should match second option flag', 'b', LOptions[1].Flag);
end;

procedure TTestCommandBuilder.TestInputLn;
var
  LActual, LExpected: string;
begin
  LExpected := 'sample mock string';
  MockInputLnResult := LExpected;
  LActual := FBuilder.InputLn;

  AssertEquals(LExpected, LActual);
end;

procedure TTestCommandBuilder.TestState;
begin
  FBuilder.State := 'error';
  AssertEquals(FBuilder.State, 'error');
end;

initialization
  RegisterTest(TTestCommandBuilder);

end.