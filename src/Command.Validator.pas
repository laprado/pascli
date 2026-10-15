/// <summary> This unit contains classes to perform the validation of the parameters informed by the 
/// user against those defined in the CommandBuilder. To make the code clearer and easier to maintain, 
/// the validator pattern was used. </summary>
unit Command.Validator;

{$MODE DELPHI}{$H+}

interface

uses
  Classes,
  SysUtils,
  Command.Interfaces,
  Command.Helpers;

type
  /// <summary> Class that groups all validators, as well as establishes the validation order.
  /// </summary>
  TValidatorContext = class(TInterfacedObject, IValidatorContext)
  private
    FStartValidator: IValidatorBase;
    FPreviousValidator: IValidatorBase;
  public
    /// <summary> Default class constructor just to create a basic instance of it. It does not require 
    /// a call to the desctructor as it is interface-based.</summary>
    constructor Create;

    /// <summary> Successive calls to the add method are responsible for creating the validation context. 
    /// This method adds an IValidatorBase and sets it as the successor if a previous IValidatorBase exists.
    /// </summary>
    /// <param name="AValidator"> A valid instance of IValidatorBase responsible for processing a specific 
    /// type of validation.</param>
    function Add(AValidator: IValidatorBase): IValidatorContext;

    /// <summary> Executes the validation of the first added IValidatorBase, being the responsibility 
    /// of this object to call its successor IValidatorBase and so on. </summary>
    /// <param name="ACommand"> CommandBuilder instance containing the arguments, commands and options 
    /// configured to be validated against the arguments passed to it.</param>
    function HandleValidation(ACommand: ICommandBuilder): TArray<string>;    

    /// <summary> Builds the validation context by adding each class of type IValidatorBase. It then 
    /// calls the first validator triggering the validator pattern. </summary>
    /// <param name="ACommand"> CommandBuilder instance containing the arguments, commands and options 
    /// configured to be validated against the arguments passed to it.</param>
    function Validate(ACommand: ICommandBuilder): TArray<string>;
  end;

  /// <summary> Base class for any validation that needs to be implemented. Specification validations 
  /// need to inherit from this class by convention from this library. It already has control for the 
  /// successor validator as well as its automatic call at the appropriate time. </summary>
  TValidatorBase = class(TInterfacedObject, IValidatorBase)
  private
    FSucessor: IValidatorBase;
    FResult: TArray<string>;

    function GetSucessor: IValidatorBase;
    procedure SetSucessor(const AValue: IValidatorBase);

  public

    /// <summary> Default class constructor just to create a basic instance of it. It does not require 
    /// a call to the desctructor as it is interface-based.</summary>
    constructor Create;

    /// <summary> Allows you to set or access the successor validator. </summary>
    property Sucessor: IValidatorBase read GetSucessor write SetSucessor;

    /// <summary> Validates a single specific case. It must be implemented by the child class. 
    /// If the validation is successful and there is a successor, the successor's validation method 
    /// will be called. A TArry<string> will be returned with errors detected whether they are from 
    /// the current or successor validation. </summary>
    /// <param name="ACommand"> CommandBuilder instance containing the arguments, commands and options 
    /// configured to be validated against the arguments passed to it.</param>
    function Validate(ACommand: ICommandBuilder): TArray<string>; virtual; 

  end;

  /// <summary> Returns an error if a command was configured without a callback </summary>
  TConfiguredCommandWithCallback = class(TValidatorBase)
    function Validate(ACommand: ICommandBuilder): TArray<string>; override;
  end;  

  /// <summary> Returns an error if a command has been passed twice. A duplicity is accepted if 
  /// a command accepts another command as an argument through the @link(ccNoArgumentsButCommands)
  /// constraint.
  /// </summary>
  TDuplicateArgumentValidator = class(TValidatorBase)
    function Validate(ACommand: ICommandBuilder): TArray<string>; override; 
  end;

  /// <summary> Returns an error if an option was passed twice.</summary>
  TDuplicateOptionValidator = class(TValidatorBase)
    function Validate(ACommand: ICommandBuilder): TArray<string>; override; 
  end;

  /// <summary> Returns an error if there are commands configured for the CommandBuilder and arguments 
  /// were passed via the command line, but no command was found. </summary>
  TProvidedArgumentsAreNotValid = class(TValidatorBase)
    function Validate(ACommand: ICommandBuilder): TArray<string>; override; 
  end;

  /// <summary> Returns an error if not required arguments were passed to the command and the
  /// constraint @link(ccNoArgumentsButCommands) is active for the command.
  /// </summary>
  TProvidedArgumentsAreNotRequired = class(TValidatorBase)
    function Validate(ACommand: ICommandBuilder): TArray<string>; override; 
  end;

  /// <summary> Returns an error if more arguments were passed than what was set for the command.
  /// </summary>
  TProvidedArgumentsExceedsAcceptedLimit = class(TValidatorBase)
    function Validate(ACommand: ICommandBuilder): TArray<string>; override; 
  end;

  /// <summary> Returns an error if a command was passed to a command that does 
  /// ot accept this type of parameter. Only works if @link(ccNoArgumentsButCommands) constraint
  /// is set for the command. </summary>
  TSelectedCommandDoesNotAcceptCommandAsArgument = class(TValidatorBase)
    function Validate(ACommand: ICommandBuilder): TArray<string>; override;
  end;

  /// <summary> Returns an error if an invalid command was passed to a command that only accepts 
  /// command as an argument. Only works if @link(ccNoArgumentsButCommands) is set for the
  /// command.</summary>
  TSelectedCommandRequiresValidCommandOrNothing = class(TValidatorBase)
    function Validate(ACommand: ICommandBuilder): TArray<string>; override;
  end;

  /// <summary> Returns an error if no argument has been passed to a command that requires parameters.
  /// Only works if @link(ccRequiresOneArgument) is set for the command.</summary>
  TSelectedCommandRequiresOneArguments = class(TValidatorBase)
    function Validate(ACommand: ICommandBuilder): TArray<string>; override;
  end;

  /// <summary> Returns an error if an argument has been passed to a command that does not require 
  /// parameters. Only works if @link(ccNoParameters) is set for the command. </summary>
  TSelectedCommandRequiresNoArguments = class(TValidatorBase)
    function Validate(ACommand: ICommandBuilder): TArray<string>; override;
  end;

  /// <summary> Returns an error if an argument has been passed to a command with out at least one 
  /// option. Only works if @link(ccRequiresOneOption) is not set for the command. </summary>
  TSelectedCommandRequiresOneOption = class(TValidatorBase)
    function Validate(ACommand: ICommandBuilder): TArray<string>; override;
  end;

  /// <summary> Returns an error if a non-existent option was passed to a command. </summary>
  TSelectedCommandValidateIfOptionsExists = class(TValidatorBase)
    function Validate(ACommand: ICommandBuilder): TArray<string>; override;
  end;
 
  /// <summary> Returns an error if an option has been passed that cannot be used together with another 
  /// option for a given command. </summary>
  TSelectedCommandValidateRejectedOption = class(TValidatorBase)
    function Validate(ACommand: ICommandBuilder): TArray<string>; override;
  end;

  /// <summary> Returns an error if an option has been passed with a value and it is configured to not 
  /// accept a value. </summary>
  TSelectedCommandValidateOptionValueNotRequired = class(TValidatorBase)
    function Validate(ACommand: ICommandBuilder): TArray<string>; override;
  end;

  /// <summary> Returns an error if an option has been passed without a value and it is configured to  
  /// require a value. </summary>
  TSelectedCommandValidateOptionValueRequired = class(TValidatorBase)
    function Validate(ACommand: ICommandBuilder): TArray<string>; override;
  end;

implementation

uses
  StrUtils;

constructor TValidatorContext.Create;
begin
  FStartValidator := nil;
  FPreviousValidator := nil;
end;

function TValidatorContext.Add(AValidator: IValidatorBase): IValidatorContext;
begin
  if not Assigned(FStartValidator) then
    FStartValidator := AValidator;

  if Assigned(FPreviousValidator) then
    FPreviousValidator.SetSucessor(AValidator);

  FPreviousValidator := AValidator;
  
  Result := Self; 
end;

function TValidatorContext.HandleValidation(ACommand: ICommandBuilder): TArray<string>;    
begin
  Result := FStartValidator.Validate(ACommand);
end;

function TValidatorContext.Validate(ACommand: ICommandBuilder): TArray<string>;
begin
  Result := Self
    .Add(TConfiguredCommandWithCallback.Create)
    .Add(TDuplicateArgumentValidator.Create)
    .Add(TDuplicateOptionValidator.Create)
    .Add(TProvidedArgumentsAreNotValid.Create)
    .Add(TProvidedArgumentsAreNotRequired.Create)
    .Add(TProvidedArgumentsExceedsAcceptedLimit.Create)
    .Add(TSelectedCommandDoesNotAcceptCommandAsArgument.Create)
    .Add(TSelectedCommandRequiresValidCommandOrNothing.Create)
    .Add(TSelectedCommandRequiresOneArguments.Create)
    .Add(TSelectedCommandRequiresNoArguments.Create)
    .Add(TSelectedCommandRequiresOneOption.Create)
    .Add(TSelectedCommandValidateIfOptionsExists.Create)
    .Add(TSelectedCommandValidateRejectedOption.Create)
    .Add(TSelectedCommandValidateOptionValueNotRequired.Create)
    .Add(TSelectedCommandValidateOptionValueRequired.Create)
    .HandleValidation(ACommand);
end;

constructor TValidatorBase.Create;
begin
  SetLength(FResult, 0);
end;

function TValidatorBase.GetSucessor: IValidatorBase;
begin
  Result := FSucessor;
end;

procedure TValidatorBase.SetSucessor(const AValue: IValidatorBase);
begin
  FSucessor := AValue;
end;

function TValidatorBase.Validate(ACommand: ICommandBuilder): TArray<string>;
begin
  Result := FResult;
  if Assigned(FSucessor) then
    Result := FSucessor.Validate(ACommand);
end;


function TConfiguredCommandWithCallback.Validate(ACommand: ICommandBuilder): TArray<string>;
var
  LCommand: ICommand;
begin
  for LCommand in ACommand.Commands do
    if not Assigned(LCommand.Callback) then
    begin
      AppendToArray(
          FResult, 
          Format('Command %s was configured without a callback.', [LCommand.Name]));
          Exit(FResult);
    end;
  Result := inherited Validate(ACommand);
end;

function TDuplicateArgumentValidator.Validate(ACommand: ICommandBuilder): TArray<string>;
var
  LArray: TArray<string>;
  I, J: Integer;
  LAllowedDuplicate: string = '';
  LArgumentCount: integer;
begin
  LArray := ACommand.GetRawArguments;

  if (Assigned(ACommand.CommandSelected)) and
     (ccNoArgumentsButCommands in ACommand.CommandSelected.Constraints) and 
     (Assigned(ACommand.CommandAsArgument)) and
     (ACommand.CommandSelected.Name = ACommand.CommandAsArgument.Name) then 
    LAllowedDuplicate := ACommand.CommandSelected.Name;

  for I := 0 to Length(LArray) - 1 do
  begin
    LArgumentCount := Length(ACommand.Arguments);
    for J := 0 to Length(LArray) - 1 do
      if (I <> J) and (SameText(LArray[I], LArray[J])) and (not SameText(LAllowedDuplicate, LArray[J])) then
      begin
        if LArgumentCount > 0 then
          Dec(LArgumentCount)
        else
        begin
          AppendToArray(FResult, Format('Duplicate argument "%s" was provided', [LArray[I]]));
          Exit(FResult);
        end;
      end;
  end;

  Result := inherited Validate(ACommand);
end;

function TDuplicateOptionValidator.Validate(ACommand: ICommandBuilder): TArray<string>;
var
  LArray: TArray<string>;
  I, J: Integer;
  LCommand: ICommand;
  LOption: IOption;
  LShort, LLong, LMessage, LRawOption: string;
begin
  LCommand := ACommand.CommandSelected;
  if not Assigned(LCommand) then
    LCommand := ACommand.GetDefaultCommand;

  LArray := ACommand.GetRawOptions;
  for I := 0 to Length(LArray) - 1 do
  begin
    LRawOption := RemoveStartingDashes(LArray[I]);
    SplitOptionAndValue(LRawOption);
    
    LOption := LCommand.Option[LRawOption];
    if Assigned(LOption) then
    begin
      LShort := LOption.Flag;
      LLong := LOption.Name;
    end
    else
    begin
      LShort := RemoveStartingDashes(LArray[I]);
      LLong := RemoveStartingDashes(LArray[I]);
      SplitOptionAndValue(LShort);
      SplitOptionAndValue(LLong);
    end;

    for J := 0 to Length(LArray) - 1 do
    begin
      LRawOption := RemoveStartingDashes(LArray[J]);
      SplitOptionAndValue(LRawOption);
      if (I <> J) and (SameText(LShort, LRawOption) or SameText(LLong, LRawOption)) then
      begin
        LMessage := Format('Duplicate options "%s", "%s" provided', [LArray[I], LArray[J]]);
        if (LShort <> LLong) and (LArray[I] <> LArray[J]) then
          LMessage := LMessage +
            Format('. Option -%s is equivalent to --%s', [LShort, LLong]);
          
        AppendToArray(FResult, LMessage);
        Exit(FResult);
      end;
    end;
  end;

  Result := inherited Validate(ACommand);
end;

function TProvidedArgumentsAreNotValid.Validate(ACommand: ICommandBuilder): TArray<string>;
begin
  if (Length(ACommand.Commands) > 0) and 
     (ACommand.GetCommandsFound = 0) and 
     (Length(ACommand.GetRawArguments) > 0) then
  begin
    AppendToArray(FResult, 'Provided arguments are not valid.');
    Exit(FResult);
  end;

  Result := inherited Validate(ACommand);
end;

function TProvidedArgumentsAreNotRequired.Validate(ACommand: ICommandBuilder): TArray<string>;
begin
  if (Length(ACommand.Commands) > 0) and
     (Assigned(ACommand.CommandSelected)) and
     (ccNoArgumentsButCommands in ACommand.CommandSelected.Constraints) and
     ( (Length(ACommand.GetRawArguments)  
        - ACommand.GetCommandsFound 
        - Length(ACommand.Arguments)) > 0) then
  begin
    AppendToArray(FResult, 'Provided arguments are not required.');
    Exit(FResult);
  end;

  Result := inherited Validate(ACommand);
end;

function TProvidedArgumentsExceedsAcceptedLimit.Validate(ACommand: ICommandBuilder): TArray<string>;
var
  LCommandCount: Integer = 1;
begin
  If Assigned(ACommand.CommandAsArgument) Then Inc(LCommandCount);
  if (Length(ACommand.Commands) > 0) and 
     ((Length(ACommand.GetRawArguments) - LCommandCount) > Length(ACommand.Arguments)) then     
  begin
    AppendToArray(FResult, 
        Format('Provided arguments for "%s" is greater thant accepted number',
        [ACommand.CommandSelected.Name]));
    Exit(FResult);
  end;

  Result := inherited Validate(ACommand);
end;

function TSelectedCommandDoesNotAcceptCommandAsArgument.Validate(ACommand: ICommandBuilder): TArray<string>;
begin
  if (Length(ACommand.Commands) > 0) and 
     ((ACommand.GetCommandsFound - Length(ACommand.Arguments)) > 1) and 
     (not (ccNoArgumentsButCommands in ACommand.CommandSelected.Constraints)) then
  begin
    AppendToArray(FResult, 
        Format('Command "%s" does not accept another command as argument',
        [ACommand.CommandSelected.Name]));
    Exit(FResult);
  end;

  Result := inherited Validate(ACommand);
end;

function TSelectedCommandRequiresValidCommandOrNothing.Validate(ACommand: ICommandBuilder): TArray<string>;
begin
  if (Assigned(ACommand.CommandSelected)) and 
     (ccNoArgumentsButCommands in ACommand.CommandSelected.Constraints) and
     ((not Assigned(ACommand.CommandAsArgument)) or (Length(ACommand.GetRawArguments) > 2)) and 
     (Length(ACommand.GetRawArguments) > 1) then
  begin
    AppendToArray(FResult, 
        Format('Command "%s" requires one valid command as an argument or nothing',
        [ACommand.CommandSelected.Name]));
    Exit(FResult);
  end;

  Result := inherited Validate(ACommand);
end;

function TSelectedCommandRequiresOneArguments.Validate(ACommand: ICommandBuilder): TArray<string>;
begin
  if (Assigned(ACommand.CommandSelected)) and 
     (ccRequiresOneArgument in ACommand.CommandSelected.Constraints) and
     (
       ((Assigned(ACommand.CommandAsArgument)) and (Length(ACommand.GetRawArguments) < 3)) or
       ((not Assigned(ACommand.CommandAsArgument)) and (Length(ACommand.GetRawArguments) < 2))
     ) then
  begin
    AppendToArray(FResult, 
        Format('Command "%s" requires an argument as parameter',
        [ACommand.CommandSelected.Name]));
    Exit(FResult);
  end;

  Result := inherited Validate(ACommand);
end;

function TSelectedCommandRequiresNoArguments.Validate(ACommand: ICommandBuilder): TArray<string>;
begin
  if Assigned(ACommand.CommandSelected) and 
     (ccNoParameters in ACommand.CommandSelected.Constraints) and 
     (Length(ACommand.GetRawArguments) > 1) then
  begin
    AppendToArray(FResult, 
        Format('Command "%s" requires no arguments.',
        [ACommand.CommandSelected.Name]));
    Exit(FResult);
  end;
  Result := inherited Validate(ACommand);
end;

function TSelectedCommandValidateIfOptionsExists.Validate(ACommand: ICommandBuilder): TArray<string>;
var
  I: Integer;
  LParsedOptions: TArray<string>;
  LOptionCleaned: string;
  LOptionFound: Boolean;
  LOption: IOption;
  LCommand: ICommand;
begin
  LCommand := ACommand.CommandSelected;
  if not Assigned(LCommand) then
    LCommand := ACommand.GetDefaultCommand;

  if Assigned(LCommand) then
  begin
    LParsedOptions := ACommand.GetRawOptions;
    
    for I := 0 to Length(LParsedOptions) - 1 do
    begin
      LOptionCleaned := RemoveStartingDashes(LParsedOptions[I]);
      SplitOptionAndValue(LOptionCleaned);

      LOptionFound := False;
      for LOption in LCommand.Options do
      begin
        if SameText(LOptionCleaned, LOption.Flag) or SameText(LOptionCleaned, LOption.Name) then
        begin
          LOptionFound := True;
          Break;
        end;
      end;

      if not LOptionFound then
      begin
        AppendToArray(FResult, 
          Format('Command "%s" invalid. Option not found: %s',
          [LCommand.Name, LParsedOptions[I]])
        );
        Exit(FResult); 
      end;
    end;
  end;

  Result := inherited Validate(ACommand);
end;

function TSelectedCommandValidateRejectedOption.Validate(ACommand: ICommandBuilder): TArray<string>;
var
  I: Integer;
  LParsedOptions: TArray<string>;
  LOptionCleaned: string;
  LOption, LNotAllowedOption: IOption;
  LCommand: ICommand;
  LReject: string;
begin
  LCommand := ACommand.CommandSelected;
  if not Assigned(LCommand) then
    LCommand := ACommand.GetDefaultCommand;

  if Assigned(LCommand) then
  begin
    // the option names without dashes and values, so an option with a value, like
    // --name=value, is found as well
    LParsedOptions := Copy(ACommand.GetRawOptions);
    for I := 0 to Length(LParsedOptions) - 1 do
    begin
      LParsedOptions[I] := RemoveStartingDashes(LParsedOptions[I]);
      SplitOptionAndValue(LParsedOptions[I]);
    end;

    for I := 0 to Length(LParsedOptions) - 1 do
    begin
      LOptionCleaned := LParsedOptions[I];

      for LOption in LCommand.Options do
      begin
        if AnsiMatchText(LOptionCleaned, [LOption.Flag, LOption.Name]) then
        begin
          for LReject in LOption.NotAllowedFlags do
          begin
            LNotAllowedOption := LCommand.GetOption(LReject);
            if not Assigned(LNotAllowedOption) then continue;
            
            if AnsiMatchText(LNotAllowedOption.Flag, LParsedOptions)
               or AnsiMatchText(LNotAllowedOption.Name, LParsedOptions) then
            begin
              AppendToArray(FResult, 
                Format('Command "%s" invalid. Option "-%s" cannot be used with "-%s"',
                [LCommand.Name, LOption.Flag, LReject])
              );
              Exit(FResult); 
            end;
          end;
        end;
      end;
    end;
  end;
  Result := inherited Validate(ACommand);
end;

function TSelectedCommandRequiresOneOption.Validate(ACommand: ICommandBuilder): TArray<string>;
var
  LCommand: ICommand;
  LParsedOptions: TArray<IOption>;
begin
  LCommand := ACommand.CommandSelected;
  if not Assigned(LCommand) then
    LCommand := ACommand.GetDefaultCommand;

  if (Assigned(LCommand)) and (ccRequiresOneOption in LCommand.Constraints) then
  begin
    LParsedOptions := ACommand.GetParsedOptions;
    if Length(LParsedOptions) < 1 then
    begin
      AppendToArray(FResult, 
          Format('Command "%s" requires one valid option',
          [LCommand.Name]));
      Exit(FResult);
    end;
  end;

  Result := inherited Validate(ACommand);
end;

function TSelectedCommandValidateOptionValueNotRequired.Validate(ACommand: ICommandBuilder): TArray<string>;
var
  I: Integer;
  LParsedOptions: TArray<string>;
  LOptionCleaned, LOptionValue: string;
  LCommand: ICommand;
  LOption: IOption;
begin
  LCommand := ACommand.CommandSelected;
  if not Assigned(LCommand) then
    LCommand := ACommand.GetDefaultCommand;

  if Assigned(LCommand) then
  begin
    LParsedOptions := ACommand.GetRawOptions;
    
    for I := 0 to Length(LParsedOptions) - 1 do
    begin
      LOptionCleaned := RemoveStartingDashes(LParsedOptions[I]);
      LOptionValue := SplitOptionAndValue(LOptionCleaned);

      for LOption in LCommand.Options do
        if (AnsiMatchText(LOptionCleaned, [LOption.Flag, LOption.Name])) and (LOptionValue <> '') and
           (ocNoValue = LOption.Constraint) then
          begin
            AppendToArray(FResult, 
              Format('Command "%s" invalid. Option "%s" does not require a value',
              [LCommand.Name, LOption.Flag])
            );
            Exit(FResult);
          end;
    end;
  end;
  Result := inherited Validate(ACommand);
end;

function TSelectedCommandValidateOptionValueRequired.Validate(ACommand: ICommandBuilder): TArray<string>;
var
  I: Integer;
  LParsedOptions: TArray<string>;
  LOptionCleaned, LOptionValue: string;
  LCommand: ICommand;
  LOption: IOption;
begin
  LCommand := ACommand.CommandSelected;
  if not Assigned(LCommand) then
    LCommand := ACommand.GetDefaultCommand;

  if Assigned(LCommand) then
  begin
    LParsedOptions := ACommand.GetRawOptions;
    
    for I := 0 to Length(LParsedOptions) - 1 do
    begin
      LOptionCleaned := RemoveStartingDashes(LParsedOptions[I]);
      LOptionValue := SplitOptionAndValue(LOptionCleaned);

      for LOption in LCommand.Options do
        if (AnsiMatchText(LOptionCleaned, [LOption.Flag, LOption.Name])) and 
           (LOptionValue = '') and (ocRequiresValue = LOption.Constraint) then
        begin
          AppendToArray(FResult, 
            Format('Command "%s" invalid. Option "%s" requires a value',
            [LCommand.Name, LOption.Flag])
          );
          Exit(FResult);
        end;
    end;
  end;
  Result := inherited Validate(ACommand);
end;

end.