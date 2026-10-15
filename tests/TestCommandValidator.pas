unit TestCommandValidator;

{$MODE DELPHI}{$H+}

interface

uses
  Classes, 
  SysUtils, 
  fpcunit, 
  testregistry,
  Command.App,
  Command.Interfaces,
  Command.Validator;

type

  TTestCommandValidator = class(TTestCase)
  private
    FApplication: TCommandApp;
    FBuilder: ICommandBuilder;
    FValidator: IValidatorBase;
    FArray: TArray<string>;

    procedure AddOptionInvalidNotAllowedFlag;
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestConfiguredCommandWithCallback;
    procedure TestDuplicateArgumentValidatorError;
    procedure TestDuplicateArgumentValidatorAllowedCommand;
    procedure TestDuplicateOptionValidatorError;
    procedure TestDuplicateOptionValidatorErrorUsingShortAndLongOption;
    procedure TestDuplicateOptionValidatorWorks;
    procedure TestDuplicateOptionValidatorNotOccurWithValue;
    procedure TestMultipleOptionsSameDash;
    procedure TestProvidedArgumentsAreNotValid;
    procedure TestProvidedArgumentsAreNotRequired;
    procedure TestProvidedArgumentsAreNotRequiredShouldNotRaise;
    procedure TestProvidedArgumentsAreNotValidWorksWithArgument;
    procedure TestProvidedArgumentsExceedsAcceptedLimit;
    procedure TestSelectedCommandDoesNotAcceptCommandAsArgument;
    procedure TestSelectedCommandRequiresValidCommandOrNothing;
    procedure TestSelectedCommandRequiresOneArgument;
    procedure TestSelectedCommandRequiresNoArguments;
    procedure TestSelectedCommandRequiresOneOption;
    procedure TestSelectedCommandValidateIfOptionsExists;
    procedure TestSelectedCommandValidateIfOptionsWithValueExists;
    procedure TestSelectedCommandValidateRejectNotAllowedOption;
    procedure TestSelectedCommandValidateRejectNotAllowedOptionLongName;
    procedure TestSelectedCommandValidateRejectNotAllowedOptionWithValue;
    procedure TestSelectedCommandValidateRejectNotAllowedOptionWithValueLast;
    procedure TestSelectedCommandOptionRequiresValueShortFlag;
    procedure TestSelectedCommandValidateRejectOptionOnlyWithFlags;    
    procedure TestSelectedCommandOptionDoesNotRequireValue;
    procedure TestSelectedCommandOptionRequiresValue;
  end;

implementation

procedure TTestCommandValidator.SetUp;
begin
  FApplication := TCommandApp.Create(nil);
  FApplication.Title := 'validator_app';
  FBuilder := FApplication.CommandBuilder;
end;

procedure TTestCommandValidator.TearDown;
begin
  FApplication.Free;
end;

procedure TTestCommandValidator.TestConfiguredCommandWithCallback;
begin
  // arrange
  FBuilder
    .AddCommand('test')
    .UseArguments(['test'])
    .Parse;

  // act
  FValidator := TConfiguredCommandWithCallback.Create;
  FArray := FValidator.Validate(FBuilder);

  // assert
  AssertEquals('Array length should be equals 1', 1, Length(FArray));
  if Length(FArray) > 0 then
    AssertEquals('Command test was configured without a callback.', FArray[0]);  
end;

procedure TTestCommandValidator.TestDuplicateArgumentValidatorError;
begin
  // arrange
  FBuilder
    .AddCommand('help', 'show help information', nil, [ccDefault, ccNoArgumentsButCommands])
    .AddCommand('other', 'other command', nil, [ccNoParameters])
    .UseArguments(['other', 'other'])
    .Parse;

  // act
  FValidator := TDuplicateArgumentValidator.Create;
  FArray := FValidator.Validate(FBuilder);

  // assert
  AssertEquals('Array length should be equals 1', 1, Length(FArray));
  if Length(FArray) > 0 then
    AssertEquals('Duplicate argument "other" was provided', FArray[0]);
end;

procedure TTestCommandValidator.TestDuplicateArgumentValidatorAllowedCommand;
begin
  // arrange
  FBuilder
      .AddCommand('help', 'show help information', nil, [ccDefault, ccNoArgumentsButCommands])
      .AddCommand('other', 'other command', nil, [ccNoParameters])
      .UseArguments(['help', 'help'])
      .Parse;

  // act
  FValidator := TDuplicateArgumentValidator.Create;
  FArray := FValidator.Validate(FBuilder);

  // assert
  AssertEquals('No error validation should be generated', 0, Length(FArray));
end;

procedure TTestCommandValidator.TestDuplicateOptionValidatorError;
begin
  // arrange
  FBuilder
      .AddCommand('help', 'show help information', nil, [ccDefault, ccNoArgumentsButCommands])
      .AddCommand('other', 'other command', nil, [])
        .AddOption('d', 'debug', 'debug option', [])
        .AddOption('r', 'run', 'run option', [])
      .UseArguments(['other', '-d', '-d'])
      .Parse;

  // act
  FValidator := TDuplicateOptionValidator.Create;
  FArray := FValidator.Validate(FBuilder);

  // assert
  AssertEquals('Array length should be equals 1', 1, Length(FArray));
  if Length(FArray) > 0 then
    AssertEquals('Duplicate options "-d", "-d" provided', FArray[0]);
end;

procedure TTestCommandValidator.TestDuplicateOptionValidatorErrorUsingShortAndLongOption;
begin
  // arrange
  FBuilder
      .AddCommand('help', 'show help information', nil, [ccDefault, ccNoArgumentsButCommands])
      .AddCommand('other', 'other command', nil, [])
        .AddOption('d', 'debug', 'debug option', [])
        .AddOption('r', 'run', 'run option', [])
      .UseArguments(['other', '-d', '--debug'])
      .Parse;

  // act
  FValidator := TDuplicateOptionValidator.Create;
  FArray := FValidator.Validate(FBuilder);

  // assert
  AssertEquals('Array length should be equals 1', 1, Length(FArray));
  if Length(FArray) > 0 then
    AssertEquals(
      'Duplicate options "-d", "--debug" provided. Option -d is equivalent to --debug', 
      FArray[0]);  
end;

procedure TTestCommandValidator.TestDuplicateOptionValidatorWorks;
begin
  // arrange
  FBuilder
      .AddCommand('help', 'show help information', nil, [ccDefault, ccNoArgumentsButCommands])
      .AddCommand('other', 'other command', nil, [])
        .AddOption('d', 'debug', 'debug option', [])
        .AddOption('r', 'run', 'run option', [])
      .UseArguments(['other', '-d', '-r']) // should work
      .Parse;

  // act
  FValidator := TDuplicateOptionValidator.Create;
  FArray := FValidator.Validate(FBuilder);

  // assert
  AssertEquals('Array length should be equals 0', 0, Length(FArray));
end;

procedure TTestCommandValidator.TestDuplicateOptionValidatorNotOccurWithValue;
begin
  // arrange
  FBuilder
      .AddCommand('help', 'show help information', nil, [ccDefault, ccNoArgumentsButCommands])
      .AddCommand('other', 'other command', nil, [])
        .AddOption('d', 'debug', 'debug option', [])
        .AddOption('r', 'run', 'run option', [], ocOptionalValue)
      .UseArguments(['other', '-r="debug teste"']) // should work
      .Parse;

  // act
  FValidator := TDuplicateOptionValidator.Create;
  FArray := FValidator.Validate(FBuilder);

  // assert
  AssertEquals('Array length should be equals 0', 0, Length(FArray));
end;

procedure TTestCommandValidator.TestProvidedArgumentsAreNotValid;
begin
  // arrange
  FBuilder
      .AddCommand('help', 'show help information', nil, [ccDefault, ccNoArgumentsButCommands])
      .AddCommand('other', 'other command', nil, [])
      .UseArguments(['invalidcommand']) // should work
      .Parse;

  // act
  FValidator := TProvidedArgumentsAreNotValid.Create;
  FArray := FValidator.Validate(FBuilder);

  // assert
  AssertEquals('Array length should be equals 0', 1, Length(FArray)); 
  if Length(FArray) > 0 then
    AssertEquals('Provided arguments are not valid.', FArray[0]);    
end;

procedure TTestCommandValidator.TestProvidedArgumentsAreNotRequired;
begin
  // arrange
  FBuilder
      .AddCommand('help', 'show help information', nil, [ccDefault, ccNoArgumentsButCommands])
      .AddCommand('other', 'other command', nil, [])
      .UseArguments(['invalidcommand']) // should work
      .Parse;

  // act
  FValidator := TProvidedArgumentsAreNotRequired.Create;
  FArray := FValidator.Validate(FBuilder);

  // assert
  AssertEquals('Array length should be equals 0', 1, Length(FArray)); 
  if Length(FArray) > 0 then
    AssertEquals('Provided arguments are not required.', FArray[0]);    
end;

procedure TTestCommandValidator.TestProvidedArgumentsAreNotRequiredShouldNotRaise;
begin
  // arrange
  FBuilder
      .AddCommand('help', 'show help information', nil, [ccDefault, ccNoArgumentsButCommands])
      .AddCommand('other', 'other command', nil, [])
      .AddArgument('any argument', acOptional)
      .UseArguments(['invalidcommand']) // should work
      .Parse;

  // act
  FValidator := TProvidedArgumentsAreNotRequired.Create;
  FArray := FValidator.Validate(FBuilder);

  // assert
  AssertEquals('Array length should be equals 0', 0, Length(FArray));
end;

procedure TTestCommandValidator.TestProvidedArgumentsAreNotValidWorksWithArgument;
begin
  // arrange
  FBuilder
      .AddCommand('help', 'show help information', nil, [ccDefault, ccNoArgumentsButCommands])
      .AddCommand('other', 'other command', nil, [ccRequiresOneArgument])
      .AddArgument('some argument', acOptional)
      .UseArguments(['other', 'file.txt']) // should work
      .Parse;

  // act
  FValidator := TProvidedArgumentsAreNotValid.Create;
  FArray := FValidator.Validate(FBuilder);

  // assert
  AssertEquals('Array length should be equals 0', 0, Length(FArray)); 
end;

procedure TTestCommandValidator.TestProvidedArgumentsExceedsAcceptedLimit;
begin
  // arrange
  FBuilder
      .AddCommand('help', 'show help information', nil, [ccDefault, ccNoArgumentsButCommands])
      .AddCommand('other', 'other command', nil, [ccRequiresOneArgument])
      .AddArgument('some argument', acOptional)
      .UseArguments(['other', 'file.txt', 'extra_arg'])
      .Parse;

  // act
  FValidator := TProvidedArgumentsExceedsAcceptedLimit.Create;
  FArray := FValidator.Validate(FBuilder);

  // assert
  AssertEquals('Should return one error after validation', 1, Length(FArray));   
  if Length(FArray) > 0 then
    AssertEquals('Return error is invalid', 
      'Provided arguments for "other" is greater thant accepted number', FArray[0]);
end;

procedure TTestCommandValidator.TestSelectedCommandDoesNotAcceptCommandAsArgument;
begin
  // arrange
  FBuilder
      .AddCommand('help', 'show help information', nil, [ccDefault, ccNoArgumentsButCommands])
      .AddCommand('other', 'other command', nil, [ccNoParameters])
      .UseArguments(['other', 'help'])
      .Parse;

  // act
  FValidator := TSelectedCommandDoesNotAcceptCommandAsArgument.Create;
  FArray := FValidator.Validate(FBuilder);

  // assert
  AssertEquals('Should return one error after validation', 1, Length(FArray));   
  AssertEquals('Command "other" does not accept another command as argument', FArray[0]);
end;

procedure TTestCommandValidator.TestSelectedCommandRequiresValidCommandOrNothing;
begin
  // arrange
  FBuilder
      .AddCommand('help', 'show help information', nil, [ccDefault, ccNoArgumentsButCommands])
      .AddCommand('other', 'other command', nil, [ccNoParameters])
      .AddArgument('some argument', acOptional)
      .UseArguments(['help', 'nocommand'])
      .Parse;

  // act
  FValidator := TSelectedCommandRequiresValidCommandOrNothing.Create;
  FArray := FValidator.Validate(FBuilder);

  // assert
  AssertEquals('Should return one error after validation', 1, Length(FArray));   
  AssertEquals('Command "help" requires one valid command as an argument or nothing', FArray[0]); 
end;

procedure TTestCommandValidator.TestSelectedCommandRequiresOneArgument;
begin
  // arrange
  FBuilder
      .AddCommand('help', 'show help information', nil, [ccDefault, ccNoArgumentsButCommands])
      .AddCommand('other', 'other command', nil, [ccRequiresOneArgument])
      .AddArgument('some argument', acOptional)
      .UseArguments(['other'])
      .Parse;

  // act
  FValidator := TSelectedCommandRequiresOneArguments.Create;
  FArray := FValidator.Validate(FBuilder);

  // assert
  AssertEquals('Should return one error after validation', 1, Length(FArray));
  AssertEquals('Command "other" requires an argument as parameter', FArray[0]);  
end;

procedure TTestCommandValidator.TestSelectedCommandRequiresNoArguments;
begin
  // arrange
  FBuilder
      .AddCommand('help', 'show help information', nil, [ccDefault, ccNoArgumentsButCommands])
      .AddCommand('other', 'other command', nil, [ccNoParameters])
      .AddArgument('some argument', acOptional)
      .UseArguments(['other', 'nocommand'])
      .Parse;

  // act
  FValidator := TSelectedCommandRequiresNoArguments.Create;
  FArray := FValidator.Validate(FBuilder);

  // assert
  AssertEquals('Should return one error after validation', 1, Length(FArray));
  AssertEquals('Command "other" requires no arguments.', FArray[0]);
end;

procedure TTestCommandValidator.TestSelectedCommandRequiresOneOption;
begin
  // arrange
  FBuilder
      .AddCommand('add', 'add a feature to the project', nil, [ccRequiresOneOption, ccNoParameters])
        .AddOption('f', 'feature-one', 'feature one description', [])
        .AddOption('s', 'second-feature', 'second feature description', [])
      .UseArguments(['add'])
      .Parse;  
  
  // act for ccRequiresOneOption
  FValidator := TSelectedCommandRequiresOneOption.Create;
  FArray := FValidator.Validate(FBuilder);

  // assert for ccRequiresOneOption
  AssertEquals('Should return one error after validation', 1, Length(FArray));
  AssertEquals('Command "add" requires one valid option', FArray[0]);  

  // act for ccNoParameters
  FValidator := TSelectedCommandRequiresNoArguments.Create;
  FArray := FValidator.Validate(FBuilder);

  // assert for ccNoParameters
  AssertEquals('Should not return an error after validation', 0, Length(FArray));
end;

procedure TTestCommandValidator.TestSelectedCommandValidateIfOptionsExists;
begin
  // arrange
  FBuilder
      .AddCommand('help', 'show help information', nil, [ccDefault, ccNoArgumentsButCommands])
      .AddCommand('other', 'other command', nil, [])
        .AddOption('v', 'valid', 'valid option', [])
      .AddArgument('some argument', acOptional)
      .UseArguments(['other', '--valid', '-i'])
      .Parse;

  // act
  FValidator := TSelectedCommandValidateIfOptionsExists.Create;
  FArray := FValidator.Validate(FBuilder);

  // assert
  AssertEquals('Should return one error after validation', 1, Length(FArray));
  AssertEquals('Command "other" invalid. Option not found: -i', FArray[0]);  
end;

procedure TTestCommandValidator.TestSelectedCommandValidateIfOptionsWithValueExists;
begin
  // arrange
  FBuilder
      .AddCommand('help', 'show help information', nil, [ccDefault, ccNoArgumentsButCommands])
      .AddCommand('other', 'other command', nil, [])
        .AddOption('v', 'valid', 'valid option with value', [], ocRequiresValue)
      .UseArguments(['other', '--v="custom value"'])
      .Parse;

  // act
  FValidator := TSelectedCommandValidateIfOptionsExists.Create;
  FArray := FValidator.Validate(FBuilder);

  // assert
  AssertEquals('Should not return error after validation', 0, Length(FArray));
end;

procedure TTestCommandValidator.TestSelectedCommandValidateRejectNotAllowedOption;
begin
  // arrange
  FBuilder
      .AddCommand('help', 'show help information', nil, [ccDefault, ccNoArgumentsButCommands])
      .AddCommand('other', 'other command', nil, [])
        .AddOption('v', 'valid', 'valid option', ['r'])
        .AddOption('r', 'rejected', 'rejected option with valid option', [])
      .AddArgument('some argument', acOptional)
      .UseArguments(['other', '--valid', '-r'])
      .Parse;

  // act
  FValidator := TSelectedCommandValidateRejectedOption.Create;
  FArray := FValidator.Validate(FBuilder);

  // assert
  AssertEquals('Should return one error after validation', 1, Length(FArray));
  AssertEquals('Command "other" invalid. Option "-v" cannot be used with "-r"', FArray[0]);
end;

procedure TTestCommandValidator.TestSelectedCommandValidateRejectNotAllowedOptionLongName;
begin
  // arrange
  FBuilder
      .AddCommand('help', 'show help information', nil, [ccDefault, ccNoArgumentsButCommands])
      .AddCommand('other', 'other command', nil, [])
        .AddOption('v', 'valid', 'valid option', ['r'])
        .AddOption('r', 'rejected', 'rejected option with valid option', ['v'])
      .AddArgument('some argument', acOptional)
      .UseArguments(['other', '--valid', '--rejected'])
      .Parse;

  // act
  FValidator := TSelectedCommandValidateRejectedOption.Create;
  FArray := FValidator.Validate(FBuilder);

  // assert
  AssertEquals('Should return one error after validation', 1, Length(FArray));
  AssertEquals('Command "other" invalid. Option "-v" cannot be used with "-r"', FArray[0]);  
end;

procedure TTestCommandValidator.TestSelectedCommandValidateRejectNotAllowedOptionWithValue;
begin
  // arrange
  FBuilder
      .AddCommand('help', 'show help information', nil, [ccDefault, ccNoArgumentsButCommands])
      .AddCommand('other', 'other command', nil, [])
        .AddOption('t', 'template', 'option with value', ['w'], ocRequiresValue)
        .AddOption('w', 'workspace', 'option not allowed with template', ['t'])
      .AddArgument('some argument', acOptional)
      .UseArguments(['other', '--template=cli', '--workspace'])
      .Parse;

  // act
  FValidator := TSelectedCommandValidateRejectedOption.Create;
  FArray := FValidator.Validate(FBuilder);

  // assert
  AssertEquals('Should return one error after validation', 1, Length(FArray));
  AssertEquals('Command "other" invalid. Option "-t" cannot be used with "-w"', FArray[0]);
end;

procedure TTestCommandValidator.TestSelectedCommandValidateRejectNotAllowedOptionWithValueLast;
begin
  // arrange
  FBuilder
      .AddCommand('help', 'show help information', nil, [ccDefault, ccNoArgumentsButCommands])
      .AddCommand('other', 'other command', nil, [])
        .AddOption('t', 'template', 'option with value', ['w'], ocRequiresValue)
        .AddOption('w', 'workspace', 'option not allowed with template', ['t'])
      .AddArgument('some argument', acOptional)
      .UseArguments(['other', '-w', '-t=cli'])
      .Parse;

  // act
  FValidator := TSelectedCommandValidateRejectedOption.Create;
  FArray := FValidator.Validate(FBuilder);

  // assert
  AssertEquals('Should return one error after validation', 1, Length(FArray));
  AssertEquals('Command "other" invalid. Option "-w" cannot be used with "-t"', FArray[0]);
end;

procedure TTestCommandValidator.TestSelectedCommandOptionRequiresValueShortFlag;
begin
  // arrange
  FBuilder
      .AddCommand('help', 'show help information', nil, [ccDefault, ccNoArgumentsButCommands])
      .AddCommand('other', 'other command', nil, [])
        .AddOption('d', 'debug', 'debug option', [], ocRequiresValue)
      .UseArguments(['other', '-d=1'])
      .Parse;

  // act
  FValidator := TSelectedCommandValidateOptionValueRequired.Create;
  FArray := FValidator.Validate(FBuilder);

  // assert
  AssertEquals('A short flag with a value should be valid', 0, Length(FArray));
end;

procedure TTestCommandValidator.AddOptionInvalidNotAllowedFlag;
begin
  FBuilder.AddOption('v', 'valid', 'valid option', ['debug']);
end;

procedure TTestCommandValidator.TestSelectedCommandValidateRejectOptionOnlyWithFlags;
begin
  // arrange
  FBuilder
      .AddCommand('help', 'show help information', nil, [ccDefault, ccNoArgumentsButCommands])
      .AddCommand('other', 'other command', nil, []);

  // act and assert error
  AssertException(
      Exception, 
      AddOptionInvalidNotAllowedFlag,
      'Not allowed option "debug" invalid for Command "--valid". Only flags should be used.');        
end;

procedure TTestCommandValidator.TestMultipleOptionsSameDash;
begin
  // arrange
  FBuilder
      .AddCommand('help', 'show help information', nil, [ccDefault, ccNoArgumentsButCommands])
      .AddCommand('other', 'other command', nil, [])
        .AddOption('d', 'debug', 'debug option', [])
        .AddOption('r', 'run', 'run option', [])
      .UseArguments(['other', '-dra'])
      .Parse;

  // act
  FValidator := TSelectedCommandValidateIfOptionsExists.Create;
  FArray := FValidator.Validate(FBuilder);

  // assert
  AssertEquals('Array length should be equals 1', 1, Length(FArray));
  if Length(FArray) > 0 then
    AssertEquals('Command "other" invalid. Option not found: -a', FArray[0]);
end;

procedure TTestCommandValidator.TestSelectedCommandOptionDoesNotRequireValue;
begin
  // arrange
  FBuilder
      .AddCommand('help', 'show help information', nil, [ccDefault, ccNoArgumentsButCommands])
      .AddCommand('other', 'other command', nil, [])
        .AddOption('d', 'debug', 'debug option', [])
        .AddOption('r', 'run', 'run option', [])
      .UseArguments(['other', '-d=1'])
      .Parse;

  // act
  FValidator := TSelectedCommandValidateOptionValueNotRequired.Create;
  FArray := FValidator.Validate(FBuilder);

  // assert
  AssertEquals('Array length should be equals 1', 1, Length(FArray));
  if Length(FArray) > 0 then
    AssertEquals('Command "other" invalid. Option "d" does not require a value', FArray[0]);
end;

procedure TTestCommandValidator.TestSelectedCommandOptionRequiresValue;
begin
  // arrange
  FBuilder
      .AddCommand('help', 'show help information', nil, [ccDefault, ccNoArgumentsButCommands])
      .AddCommand('other', 'other command', nil, [])
        .AddOption('d', 'debug', 'debug option', [], ocRequiresValue)
        .AddOption('r', 'run', 'run option', [])
      .UseArguments(['other', '-d'])
      .Parse;

  // act
  FValidator := TSelectedCommandValidateOptionValueRequired.Create;
  FArray := FValidator.Validate(FBuilder);

  // assert
  AssertEquals('Array length should be equals 1', 1, Length(FArray));
  if Length(FArray) > 0 then
    AssertEquals('Command "other" invalid. Option "d" requires a value', FArray[0]);
end;

initialization
  RegisterTest(TTestCommandValidator);

end.