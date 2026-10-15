/// <summary> Main unit of the library, contains the implementation of the main interfaces. 
/// </summary>
unit Command.Builder;

{$MODE DELPHI}{$H+}

interface

uses
  Classes,
  SysUtils,
  Command.Interfaces;

type

  /// <summary> Class that implements the IOption interface that represents an option that 
  /// can be configured as expected for a command.
  /// </summary>
  TOption = class(TInterfacedObject, IOption)
  private 
    FFlag: string;
    FName: string;
    FDescription: string;
    FNotAllowedFlags: TArray<string>;
    FConstraint: TOptionConstraint;
    FValue: string;

    function GetFlag: string;
    procedure SetFlag(const AValue: string);
    function GetName: string;
    procedure SetName(const AValue: string);
    function GetDescription: string;
    procedure SetDescription(const AValue: string);
    procedure SetNotAllowedFlags(const Value: TArray<string>);
    function GetNotAllowedFlags: TArray<string>;
    function GetConstraint: TOptionConstraint;
    procedure SetConstraint(const AValue: TOptionConstraint);
    function GetValue: string;
    procedure SetValue(const AValue: string);
  public 

    /// <summary> Represents the option as a single letter, i.e. a short option </summary>
    property Flag: string read GetFlag write SetFlag;

    /// <summary> Represents the option as a word, that is, a long option, it does not accept 
    /// spaces, but "-' can be used for compound names. </summary>
    property Name: string read GetName write SetName;

    /// <summary> Description of the option that best defines your objective. It can be 
    /// displayed to the user when the user requests information through the help command 
    /// for example.</summary>
    property Description: string read GetDescription write SetDescription;     

    /// <summary> Array of flags not supported for use in conjunction with this option. 
    /// Only the short option without the "-" is accepted.</summary>
    property NotAllowedFlags: TArray<string> read GetNotAllowedFlags write SetNotAllowedFlags;

    /// <summary> Option constrains that will be validated against the options provided 
    /// by the user in order to guarantee that the command is being used correctly. </summary>
    property Constraint: TOptionConstraint read GetConstraint write SetConstraint;

    /// <summary> Returns the value of an option after parsing the parameters informed 
    /// via the command line. The value of an option shoud be passed on right side of 
    /// an equal sign after the option name or flag.
    /// </summary>
    property Value: string read GetValue write SetValue;

    /// <summary> Class factory recommended as first choice for class construction. Allows 
    /// initialization with initial parameters.</summary>
    /// <param name="AFlag">Short option, accepts only a single letter. Do not use leading dash.</param>
    /// <param name="AName">Long option, accepts words, do not use leading dashes or spaces</param>
    /// <param name="ADescription">Description of the option that best defines your objective. 
    /// It can be displayed to the user when the user requests information through the help 
    /// command for example.</param>
    /// <param name="ANotAllowedFlags">Array of flags not supported for use in conjunction with 
    /// this option. Only the short option without the "-" is accepted.</param>
    /// <param name="AConstraint">Option constraint that will be validated against the options provided
    /// by the user in order to guarantee that the command is being used correctly. </param>
    class function New(const AFlag, AName, ADescription: string; ANotAllowedFlags: TArray<string>; 
      AConstraint: TOptionConstraint = ocNoValue): IOption;

  end;

  /// <summary> Class that implements the ICommand interface that represents a command that can 
  /// be registered in CommandBuilder for later use by the user. </summary>
  TCommand = class(TInterfacedObject, ICommand)
  private
    FName: string;
    FDescription: string;
    FCallback: TCommandCallback;
    FConstraints: TCommandConstraints;
    FOptions: TArray<IOption>;

    function GetName: string;
    procedure SetName(const AValue: string);
    function GetDescription: string;
    procedure SetDescription(const AValue: string);
    function GetCallback: TCommandCallback;
    procedure SetCallback(AValue: TCommandCallback);
    function GetConstraints: TCommandConstraints;
    procedure SetConstraints(const AValue: TCommandConstraints); 
    function GetOption(const AIndex: string): IOption;   
    function GetOptions: TArray<IOption>;

  public
    /// <summary> Basic class constructor. Use @link(TCommand.New) class factory as first option. </summary>
    constructor Create;

    /// <summary> Name of the command that will be used via the command line by the user.
    /// </summary>
    property Name: string read GetName write SetName;

    /// <summary> Description of the command that best describes its purpose. It can be 
    /// displayed to the user when he requests help information for the application.
    /// </summary>
    property Description: string read GetDescription write SetDescription;    

    /// <summary> Procedure that will be invoked by the builder after validation of the 
    /// arguments provided by the user and the correct match of this command as the 
    /// requested one. </summary>
    property Callback: TCommandCallback read GetCallback write SetCallback;

    /// <summary> Command constrains that will be validated against the arguments provided 
    /// by the user in order to guarantee that the command is being used correctly. </summary>
    property Constraints: TCommandConstraints read GetConstraints write SetConstraints;

    /// <summary> Retrieves an option given the index provided as a parameter. </summary>
    /// <param name="AIndex">Desired option index position</param>
    property Option[const AIndex: string]: IOption read GetOption;

    /// <summary> Property that returns the array of options defined for the command. </summary>
    property Options: TArray<IOption> read GetOptions;

    /// <summary> Function that returns true if the command has at least one option configured.
    /// </summary>
    function HasOptions: Boolean;    

    /// <summary> Creates and adds the option to the command's list of options as given parameters.
    /// </summary>
    /// <param name="AFlag">Represents the option as a single letter, i.e. a short option</param>
    /// <param name="AName">Represents the option as a word, that is, a long option, it does not accept 
    /// spaces, but "-' can be used for compound names. Ex: no-build</param>
    /// <param name="ADescription">Description of the option that best defines your objective. It can be 
    /// displayed to the user when the user requests information through the help command 
    /// for example</param>
    /// <param name="ANotAllowedFlags">Array of flags not supported for use in conjunction with this option. 
    /// Only the short option without the "-" is accepted.</param>
    /// <param name="AConstraint">Option constraint that will be validated against the options provided
    /// by the user in order to guarantee that the command is being used correctly. </param>
    function AddOption(const AFlag, AName, ADescription: string; ANotAllowedFlags: TArray<string> = nil;
      AConstraint: TOptionConstraint = ocNoValue): IOption;

    /// <summary> Class factory recommended as first choice for class construction. Allows 
    /// initialization with initial parameters.</summary>
    /// <param name="AName">Command name as it will be used via command line</param>
    /// <param name="ADescription">Command description that will be displayed to the user</param>
    /// <param name="ACallback">Callback procedure that will be invoked if this command was selected</param>
    /// <param name="AConstraints">Constraints check to validate correct command usage by the user.</param>
    class function New(const AName, ADescription: string; ACallback: TCommandCallback; 
      AConstraints: TCommandConstraints): ICommand;

  end;

  /// <summary>Class that implements the IArgument interface that represents an argument that can be 
  /// registered in CommandBuilder for later use by the user. </summary>
  TArgument = class(TInterfacedObject, IArgument)
  private
    FDescription: string;
    FConstraint: TArgumentConstraint;
    FValue: string;

    function GetDescription: string;
    procedure SetDescription(const AValue: string);
    function GetConstraint: TArgumentConstraint;
    procedure SetConstraint(const AValue: TArgumentConstraint); 
    function GetValue: string;
    procedure SetValue(const AValue: string);
    
  public

    /// <summary> Description of the argument that best describes its purpose. It can be 
    /// displayed to the user when he requests help information for the application.
    /// </summary>
    property Description: string read GetDescription write SetDescription;    

    /// <summary> Argument constraints that will be validated against the arguments provided 
    /// by the user in order to guarantee that the command is being used correctly. </summary>
    property Constraint: TArgumentConstraint read GetConstraint write SetConstraint;

    /// <summary> Returns the value of an argument after parsing the parameters informed 
    /// via the command line. If a given command line parameter has not been classified 
    /// as a command, it will be assigned to an argument in the order of configuration.
    /// 
    /// A command callback procedure receives a parameter name ABuilder of type @link(TCommandBuilder),
    /// using its property Arguments is possible to retrieve an argument that was passed as a parameter
    /// by the application's user. 
    ///
    /// Ex: get a filename from parameters:
    /// @longCode(
    /// procedure MyCommand(ABuilder: ICommandBuilder);
    /// var
    ///   LFileName: string = '';
    /// begin
    ///   LFileName := ABuilder.Arguments[0].Value;
    /// end;)
    /// </summary>
    property Value: string read GetValue write SetValue;    

    /// <summary> Class factory recommended as first choice for class construction. Allows 
    /// initialization with initial parameters.</summary>
    /// <param name="ADescription">Argument description that will be displayed to the user</param>
    /// <param name="AConstraint">Constraints check to validate correct argument usage by the user.</param>
    class function New(const ADescription: string; AConstraint: TArgumentConstraint): IArgument;

  end;  

  /// <summary> Class that implements the ICommandBuilder interface, its main 
  /// purpose is to configure the arguments, commands and options accepted by the tool. Central 
  /// point of the library, responsible for comparing and validating the parameters passed by 
  /// the command line with the configured parameters, later executing the callback linked to 
  /// the localized command. </summary>
  TCommandBuilder = class(TInterfacedObject, ICommandBuilder)
  private
    FExeName: string;
    FInputLn: TInputLnCallback;
    FOutput: TOutputCallback;
    FOutputColor: TOutputColorCallback;
    FColorTheme: TColorTheme;
    FCommands: TArray<ICommand>;
    FArguments: TArray<IArgument>;
    FUseExternalArguments: Boolean;
    FExternalArguments: TArray<string>;
    FProvidedArgs: TArray<string>;
    FProvidedOptions: TArray<string>;
    FParsedErrors: TArray<string>;
    FCommandSelected: ICommand;
    FCommandAsArgument: ICommand;
    FParsedOptions: TArray<IOption>;
    FCommandsFound: Integer;
    FTitle: String;
    FUseShortDescriptions: Boolean;
    FState: string;

    procedure AppendProvidedOptions(const AParam: string);

    function GetCommand(const AName: string): ICommand;

    /// returns a list of commands configured on builder
    function GetCommands: TArray<ICommand>;

    /// returns a list of argumetns configured on builder
    function GetArguments: TArray<IArgument>;

    function GetArgument(const AName: string): IArgument;

    function GetInputLn: TInputLnCallback;
    procedure SetInputLn(AValue: TInputLnCallback);

    function GetOutput: TOutputCallback;
    procedure SetOutput(AValue: TOutputCallback);

    function GetOutputColor: TOutputColorCallback;
    procedure SetOutputColor(AValue: TOutputColorCallback);

    function GetColorTheme: TColorTheme;
    procedure SetColorTheme(AValue: TColorTheme);

    function GetTitle: string;
    procedure SetTitle(AValue: string);

    function GetUseShortDescriptions: boolean;
    procedure SetUseShortDescriptions(AValue: boolean);

    procedure ParseArguments;
    procedure ParseCommands;
    procedure ParseOptions;

    function ParsedErrorsShow: Boolean;
    function GetParsedOptions: TArray<IOption>;

    function GetParsedArguments: TArray<IArgument>;

    function GetState: string;
    procedure SetState(AValue: string);

  public

    /// <summary> Default class constructor. Creates an instance with a exe name that will be 
    /// displayed to the user when using commands like @link(UsageCommand) or @link(VersionCommand).
    /// </summary>
    /// <param name="AExeName">Program name without extension. It´s automatically provided 
    /// by @link(TCommandApp) during the initialization.</param>
    constructor Create(AExeName: String);

    /// <summary> A class factory for command builder. It allows the initialization of the
    /// builder with a brief description and will extract the application executable name
    /// that will be used to display usage info on how to use the tool. </summary>
    /// <param name="ATitle">Brief description of the tool. It will be displayed on the
    /// @link(UsageCommand) command.</param>
    class function New(ATitle: String): ICommandBuilder;

    /// <summary> Adds a command that will be available to the user of the command line 
    /// application. This command will be added to the @link(TCommandBuilder.Commands) property.
    /// </summary>
    /// <param name="ACommand">Command name as it will be provided by the user via command 
    /// line parameter. </param>
    /// <param name="ADescription">Command description that will be displayed to the user
    /// as usage info. </param>
    /// <param name="ACallback">Callback procedure that will be invoked by the CommandBuilder 
    /// if the validation was successful and the command informed match the command name.</param>
    /// <param name="AConstraints">Validation constraints for command usage, may set to default, 
    /// may require a required argument, a required option. Check @link(TCommandConstraint) for 
    /// existing constraints. Ex: @code([ccDefault, ccNoArgumentsButCommands])</param>
    function AddCommand(const ACommand: string; const ADescription: string = ''; 
      ACallback: TCommandCallback = nil; AConstraints: TCommandConstraints = []): ICommandBuilder; overload;

    /// <summary> Using a callback to add a command to the CommandBuilder. The main purpose of this
    /// method is to allow the use of the fluent interface.
    /// Ex: CommandBuilder.AddCommand(@@Command.Usage.Registry);
    /// </summary>
    /// <param name="ACommand">Command callback that will be invoked by CommandBuilder to add the
    /// command. </param>
    function AddCommand(const ACommand: TAddCommandCallback): ICommandBuilder; overload;

    /// <summary> Returns the list of commands configured in CommandBuilder.
    /// </summary>
    property Commands: TArray<ICommand> read GetCommands;

    /// <summary> Set the description for the last command that was added. </summary>
    /// <paran ame="ADescription">Description of the command that best describes its purpose.</summay
    function Description(const ADescription: string): ICommandBuilder;

    /// <summary> Set the constraints for the last command that was added. </summary>
    /// <param name="AConstraints">Validation constraints for command usage, may set to default, 
    /// may require a required argument, a required option. Check TCommandConstraint for 
    /// existing constraints.</param>
    function CheckConstraints(AConstraints: TCommandConstraints): ICommandBuilder;

    /// <summary> Set the callback for the last command that was added. </summary>
    /// <param name="ACallback">Callback procedure that will be invoked by the CommandBuilder</summary>
    function OnExecute(ACallback: TCommandCallback): ICommandBuilder;

    /// <summary> Adds an argument to allow the user to pass a text argument via the command line. 
    /// This argument will be added to the @link(TCommandBuilder.Arguments) property. After parse 
    /// the value can be obtained through the value property of an item in the arguments array.
    /// </summary>
    /// <param name="ADescription">Description of the argument to inform the user of the 
    /// correct usage info about it. </param>
    /// <param name="AConstraint">Constraints to check if the argument is optional or mandatory.
    /// </param>
    function AddArgument(const ADescription: string; AConstraint: TArgumentConstraint): ICommandBuilder;

    /// <summary> Returns the list of arguments configured in CommandBuilder. </summary>
    property Arguments: TArray<IArgument> read GetArguments;

    /// <summary>Adds an option to the last added command. For both the short and long 
    /// options. @note(Do not use leading "-" for short or long options)</summary>
    /// <param name="AFlag">Represents the option as a single letter, i.e. a short option. </param>
    /// <param name="AName">Represents the option as a word, that is, a long option, it does not accept 
    /// spaces, but "-' can be used for compound names. </param>
    /// <param name="ADescription">Description of the option that best defines your objective. 
    /// It can be displayed to the user when the user requests information through the help 
    /// command for example.</param>
    /// <param name="ANotAllowedFlags">Array of flags not supported for use in conjunction with 
    /// this option. Only the short option without the "-" is accepted.</param>
    /// <param name="AConstraint">Option constraint that will be validated against the options provided
    /// by the user in order to guarantee that the command is being used correctly. </param>
    function AddOption(const AFlag, AName, ADescription: string; ANotAllowedFlags: TArray<string> = nil;
      AConstraint: TOptionConstraint = ocNoValue): ICommandBuilder;

    /// <summary> Parses parameters passed via command line, matching command names and arguments 
    /// for further validation. </summary>
    procedure Parse;

    /// <summary> Validates the parsed parameters, checking the configured constraints and other 
    /// validations such as duplicity, excess arguments, combination of existing options, 
    /// invalid options, etc. </summary>
    function Validate: TArray<string>;   

    /// <summary> Invokes the @link(TCommandCallback callback) procedure configured for the command found once parse 
    /// and validation have been successful. It passes the @link(TCommandBuilder) itself as a parameter 
    /// to the callback so that it is possible to call the @link(TCommandBuilder.CheckOption CheckOption) 
    /// method to validate the presence of a certain option, or to obtain the value of an expected argument 
    /// through the Arguments[n].Value property. </summary>
    procedure Execute;

    /// <summary> Executes the @link(TCommandBuilder.Parse), @link(TCommandBuilder.Validate) and
    /// @link(TCommandBuilder.Execute) methods to process all parameters provided by the user
    /// and call the correct callback command or to print validation messages. </summary>
    function Run: ICommandBuilder;

    /// <summary> Returns the selected command after Parse. </summary>
    function CommandSelected: ICommand;

    /// <summary> Manually set the selected command. Mostly used for test purpose. </summary>
    function SetCommandSelected(ACommand: ICommand): ICommandBuilder;

    /// <summary> Returns a possible command that was passed as an argument to another command. 
    /// Value is available after Parse. </summary>
    function CommandAsArgument: ICommand;

    /// <summary> Manually set the command as argument. Mostly used for test purpose. </summary>
    function SetCommandAsArgument(ACommand: ICommand): ICommandBuilder;

    /// <summary> Returns the number of commands found among the arguments passed as 
    /// parameters after Parse.</summary>
    function GetCommandsFound: Integer;

    /// <summary> Returns the default command if one has been configured. </summary>
    function GetDefaultCommand: ICommand;

    /// <summary> Returns the list of valid options found after parse. </summary>
    property ParsedOptions: TArray<IOption> read GetParsedOptions;    

    /// <summary> Returns true if the option provided through command line by user matches the
    /// the parameter AOption. This method is usually used within the callback procedure of a 
    /// given command to customize its processing.</summary>
    ///
    /// Ex:
    /// @longCode(#
    ///   if ABuilder.CheckOption('v') then 
    ///   begin
    ///     // do something
    ///   end; 
    /// #)
    /// <param name="AOption">Can be provided short option or long option without leading dashes.
    /// </param>
    function CheckOption(const AOption: string): Boolean; overload;

    /// <summary> Returns true if the option provided through command line by user matches the
    /// the parameter AOption. This method is usually used within the callback procedure of a 
    /// given command to customize its processing.</summary>
    ///
    /// Ex:
    /// @longCode(#
    /// var
    ///   LValue: string;
    /// begin
    ///   if ABuilder.CheckOption('v', LValue) then 
    ///   begin
    ///     // do something
    ///     WriteLn('Option d value is ', LValue);
    ///   end; 
    /// #)
    /// <param name="AOption">Can be provided short option or long option without leading dashes.
    /// </param>
    /// <param name="AValue">Returns the value of the option if it was provided by the user. </param>
    function CheckOption(const AOption: string; out AValue: string): Boolean; overload;

    /// <summary> Build a list of IArguments related to selected command, if there are more than 
    /// one argument provided the list will match one argument parameter by order of the command 
    /// builder configuration </summary>
    property ParsedArguments: TArray<IArgument> read GetParsedArguments;

    /// <summary> Returns a list of raw arguments passed as parameters, including invalid arguments.</summary>
    function GetRawArguments: TArray<string>;

    /// <summary> Returns a list of raw options passed as parameters, including invalid options.</summary>
    function GetRawOptions: TArray<string>;

    /// <summary> Returns exe name that will be used as command line shell name to start 
    /// the application. It´s used to outputs usage info. </summary>
    function ExeName: string;

    /// <summary> Returns True if CommandBuilder has at least one command configured. </summary>
    function HasCommands: Boolean;

    /// <summary> Returns True if CommandBuilder has at least one argument configured. </summary>
    function HasArguments: Boolean;

    /// <summary> Returns True if CommandBuilder has any option configured in any command. </summary>
    function HasOptions: Boolean;

    /// <summary> Callback procedure used to capture user input. A default callback is provided 
    /// by the library, but it can be overridden for testing purposes primarily. 
    /// Should return user input. </summary>
    property InputLn: TInputLnCallback read GetInputLn write SetInputLn;

    /// <summary> Callback procedure that is intended to output text to the console, or other 
    /// desired output. The library provides a standard callback that simply calls WriteLn, 
    /// but it can be overridden so that the output is redirected to a file, a test function, etc.
    /// </summary>
    property Output: TOutputCallback read GetOutput write SetOutput;

    /// <summary> Callback procedure that is intended to output text to the console usings colors. 
    /// The library provides a standard callback that simply calls Write before change console 
    /// color, but it can be overridden so that the output is redirected to a file, 
    /// a test function, etc. </summary>
    property OutputColor: TOutputColorCallback read GetOutputColor write SetOutputColor;        

    /// <summary> Allows to inject external arguments instead of reading from ParamStr().
    /// Mainly used for testing purposes. </summary>
    /// <param name="AArguments"> Array of strings containing the arguments, the options 
    /// must be passed with the leading dashes.</param>
    function UseArguments(AArguments: TArray<string>): ICommandBuilder;

    /// <summary> Allows to use a different color theme for the too. Returns the CommandBuilder
    /// to allow the use of fluent interface.</summary>
    /// <param name="ATheme">Color theme to be used. </param>
    function UseColorTheme(ATheme: TColorTheme): ICommandBuilder;

    /// <summary> Color theme that should be used to output colors of commands, a standard 
    /// theme is provided by Command.Colors unit. Should be changed prior to application
    /// execution </summary>
    property ColorTheme: TColorTheme read GetColorTheme write SetColorTheme;      

    /// <summary> Application title, can be customized and is displayed as part usage info
    /// to the user through the command @link(UsageCommand).</summary>
    property Title: string read GetTitle write SetTitle;  

    /// <summary> Display only the first line usage description for command usage, the user needs
    /// to use help command to see full command description. Default value is false to
    /// preserve original function. </summary>
    property UseShortDescriptions: boolean read GetUseShortDescriptions write SetUseShortDescriptions;

    /// <summary> State that can be set by user commands allowing better communication 
    /// between commands and the application. </summary>
    property State: string read GetState write SetState;

  end;

  /// <summary> Standard callback function to read input from user. Automatically configured 
  /// on CommandBuilder startup. </summary>
  function StandardConsoleInputLn: string;

  /// <summary> Standard callback procedure that outputs the given text to the console. 
  /// In this implementation it just mirrors the use of the WriteLn function. It is expected 
  /// for this type of callback that the output will be performed with a line break at the 
  /// end of it. </summary>
  procedure StandardConsoleOutput(const AMessage: string);

  /// <summary> Standard callback procedure that outputs the given text to the console using 
  /// colors. In this implementation it only mirrors the use of the Write function, but before 
  /// that it changes the color of the console. It is expected for this type of callback that 
  /// the output is performed without a line break at the end of it. The original color is 
  /// not restored impacting future outputs. </summary>
  procedure ColorConsoleOutput(const AMessage: string; const AColor: byte);

implementation

uses
  StrUtils,
  Command.Helpers,
  Command.Validator,
  Command.Colors;

class function TOption.New(const AFlag, AName, ADescription: string; ANotAllowedFlags: TArray<string>; 
  AConstraint: TOptionConstraint = ocNoValue): IOption;
var
  LFlag: string;
begin
  if AFlag = '' then
    raise Exception.CreateFmt(
      'A valid flag parameter for Command "--%s" should be provided.', [AName]);

  if (Copy(AFlag, 1, 1) = '-') or (Copy(AName, 1, 1) = '-')  then      
    raise Exception.CreateFmt(
      'A valid flag or name option should not start with a "-"', [AFlag]);

  for LFlag in ANotAllowedFlags do
    if Length(LFlag) <> 1 then
      raise Exception.CreateFmt(
          'Not allowed option "%s" invalid for Command "--%s". Only flags should be used.',
          [LFlag, AName]);

  Result := TOption.Create as IOption;
  Result.Flag := AFlag;
  Result.Name := AName;
  Result.Description := ADescription;
  Result.NotAllowedFlags := ANotAllowedFlags;
  Result.Constraint := AConstraint;
  Result.Value := '';
end;

function TOption.GetFlag: string;
begin
  Result := FFlag;
end;

procedure TOption.SetFlag(const AValue: string);
begin
  FFlag := AValue;
end;

function TOption.GetName: string;
begin
  Result := FName;
end;

procedure TOption.SetName(const AValue: string);
begin
  FName := AValue;
end;

function TOption.GetDescription: string;
begin
  Result := FDescription;
end;

procedure TOption.SetDescription(const AValue: string);
begin
  FDescription := AValue;
end;

procedure TOption.SetNotAllowedFlags(const Value: TArray<string>);
begin
  FNotAllowedFlags := Value;
end;

function TOption.GetNotAllowedFlags: TArray<string>;
begin
  Result := FNotAllowedFlags;
end;

function TOption.GetConstraint: TOptionConstraint;
begin
  Result := FConstraint;
end;

procedure TOption.SetConstraint(const AValue: TOptionConstraint);
begin
  FConstraint := AValue;
end;

procedure TOption.SetValue(const AValue: string);
begin
  FValue := AValue;
end;

function TOption.GetValue: string;
begin
  Result := FValue;
end;

constructor TCommand.Create;
begin
  SetLength(FOptions, 0);
end;

class function TCommand.New(const AName, ADescription: string; ACallback: TCommandCallback; 
  AConstraints: TCommandConstraints): ICommand;
begin
  Result := TCommand.Create as ICommand;
  Result.Name := AName;
  Result.Description := ADescription;
  Result.Callback := ACallback;
  Result.Constraints := AConstraints;
end;

function TCommand.GetName: string;
begin
  Result := FName;
end;

procedure TCommand.SetName(const AValue: string);
begin
  FName := AValue;
end;

function TCommand.GetDescription: string;
begin
  Result := FDescription;
end;

procedure TCommand.SetDescription(const AValue: string);
begin
  FDescription := AValue;
end;

function TCommand.GetCallback: TCommandCallback;
begin
  Result := FCallback;
end;

procedure TCommand.SetCallback(AValue: TCommandCallback);
begin
  FCallback := AValue;
end;

function TCommand.GetConstraints: TCommandConstraints;
begin
  Result := FConstraints;
end;

procedure TCommand.SetConstraints(const AValue: TCommandConstraints); 
begin
  FConstraints := AValue;
end;

function TCommand.GetOption(const AIndex: string): IOption;   
var 
  I: integer;
begin
  Result := nil;
  for I := 0 to Length(FOptions) - 1 do
    if SameText(FOptions[I].Name, AIndex) or SameText(FOptions[I].Flag, AIndex) then
      Exit(FOptions[I]);
end;

function TCommand.GetOptions: TArray<IOption>;
begin
  Result := FOptions;
end;

function TCommand.AddOption(const AFlag, AName, ADescription: string; ANotAllowedFlags: TArray<string> = nil;
  AConstraint: TOptionConstraint = ocNoValue): IOption;
var 
  LOption: IOption;
begin
  LOption := TOption.New(AFlag, AName, ADescription, ANotAllowedFlags, AConstraint);
  SetLength(FOptions, Length(FOptions) + 1);
  FOptions[Length(FOptions) - 1] := LOption;
  Result := FOptions[Length(FOptions) - 1];
end;

function TCommand.HasOptions: Boolean;
begin
  Result := Length(FOptions) > 0;
end;

class function TArgument.New(const ADescription: string; AConstraint: TArgumentConstraint): IArgument;
begin
  Result := TArgument.Create as IArgument;
  Result.Description := ADescription;
  Result.Constraint := AConstraint;  
end;

function TArgument.GetDescription: string;
begin
  Result := FDescription;
end;

procedure TArgument.SetDescription(const AValue: string);
begin
  FDescription := AValue;
end;

function TArgument.GetConstraint: TArgumentConstraint;
begin
  Result := FConstraint;
end;

procedure TArgument.SetConstraint(const AValue: TArgumentConstraint); 
begin
  FConstraint := AValue;
end;

function TArgument.GetValue: string;
begin
  Result := FVAlue;
end;

procedure TArgument.SetValue(const AValue: string);
begin
  FValue := AValue;
end;

constructor TCommandBuilder.Create(AExeName: String);
begin
  if AExeName = '' then
    raise Exception.Create('AExeName cannot be empty.');

  FExeName := AExeName;
  FCommandSelected := nil;
  FCommandAsArgument := nil;
  FUseExternalArguments := False;
  FUseShortDescriptions := False;
  FState := '';
  FColorTheme := StartColorTheme;
  SetLength(FExternalArguments, 0);
  FInputLn := StandardConsoleInputLn;
  FOutput := StandardConsoleOutput;
  FOutputColor := ColorConsoleOutput;
end;

class function TCommandBuilder.New(ATitle: String): ICommandBuilder;
begin
  Result := TCommandBuilder.Create(ChangeFileExt(ExtractFileName(ParamStr(0)), ''));
  Result.Title := ATitle;
end;

function TCommandBuilder.AddCommand(const ACommand, ADescription: string; ACallback: TCommandCallback; 
  AConstraints: TCommandConstraints): ICommandBuilder;
begin
  if (ccDefault in AConstraints) and Assigned(GetDefaultCommand) then
    raise Exception.Create('Cannot add a second default command.');

  SetLength(FCommands, Length(FCommands) + 1);
  FCommands[Length(FCommands) - 1] := TCommand.New(ACommand, ADescription, ACallback, AConstraints);
  Result := Self;
end;

function TCommandBuilder.AddCommand(const ACommand: TAddCommandCallback): ICommandBuilder;
begin
  ACommand(Self);
  Result := Self;  
end;

function TCommandBuilder.Description(const ADescription: string): ICommandBuilder;
begin
  if Length(FCommands) = 0 then
    raise Exception.Create('No command to add description.');
  FCommands[Length(FCommands) - 1].Description := ADescription;
  Result := Self;
end;

function TCommandBuilder.CheckConstraints(AConstraints: TCommandConstraints): ICommandBuilder;
begin
  if Length(FCommands) = 0 then
    raise Exception.Create('No command to set a constraint.');
  FCommands[Length(FCommands) - 1].Constraints := AConstraints;
  Result := Self;
end;

function TCommandBuilder.OnExecute(ACallback: TCommandCallback): ICommandBuilder;
begin
  if Length(FCommands) = 0 then
    raise Exception.Create('No command to set a callback.');
  if not Assigned(ACallback) then
    raise Exception.Create('Callback cannot be nil.');
  FCommands[Length(FCommands) - 1].Callback := ACallback;
  Result := Self;
end;

function TCommandBuilder.AddArgument(const ADescription: string; AConstraint: TArgumentConstraint): ICommandBuilder;
begin
  SetLength(FArguments, Length(FArguments) + 1);
  FArguments[Length(FArguments) - 1] := TArgument.New(ADescription, AConstraint);
  Result := Self;
end;

function TCommandBuilder.GetCommand(const AName: string): ICommand;
var 
  I: integer;
begin
  Result := nil;
  for I := 0 to Length(FCommands) - 1 do
    if FCommands[I].Name = AName then
      Exit(FCommands[I]);
end;

function TCommandBuilder.GetCommands: TArray<ICommand>;
begin
  Result := FCommands;
end;

function TCommandBuilder.GetArgument(const AName: string): IArgument;
var 
  I: integer;
begin
  Result := nil;
  for I := 0 to Length(FArguments) - 1 do
    if FArguments[I].Description = AName then
      Exit(FArguments[I]);
end;

function TCommandBuilder.AddOption(const AFlag, AName, ADescription: string; ANotAllowedFlags: TArray<string> = nil;
  AConstraint: TOptionConstraint = ocNoValue): ICommandBuilder;
begin
  if Length(FCommands) = 0 then
    raise Exception.Create('Must add a command to add an option.');

  FCommands[Length(FCommands) - 1].AddOption(AFlag, AName, ADescription, ANotAllowedFlags, AConstraint);
  Result := Self;
end;

function TCommandBuilder.ParsedErrorsShow: Boolean;
var
  I: Integer;
  LTitle: string;
begin
  if Length(FParsedErrors) <= 0 then Exit(False);

  LTitle := FExeName + ': ';
  for I := 0 to Length(FParsedErrors) - 1 do
  begin
    Output(LTitle + FParsedErrors[I]);
    LTitle := '';
  end;

  Result := True;
end;

function TCommandBuilder.GetDefaultCommand: ICommand;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to Length(FCommands) - 1 do
    if ccDefault in FCommands[I].Constraints then
      Exit(FCommands[I]);
end;

procedure TCommandBuilder.ParseArguments;
var
  I: Integer;
begin
  FCommandSelected := nil;
  FCommandAsArgument := nil;
  SetLength(FProvidedArgs, 0); 
  SetLength(FParsedErrors, 0);
  FCommandsFound := 0;
  FState := '';

  for I := 0 to Length(FArguments) - 1 do
    FArguments[I].Value := '';

  for I := 0 to Length(FParsedOptions) - 1 do
    FParsedOptions[I].Value := '';

  if FUseExternalArguments then
  begin
    for I := 0 to Length(FExternalArguments) - 1 do
      if Copy(FExternalArguments[I], 1, 1) <> '-' then
        AppendToArray(FProvidedArgs, FExternalArguments[I])
      else
        AppendProvidedOptions(FExternalArguments[I]);
  end
  else
  begin
    for I := 1 to ParamCount do
      if Copy(ParamStr(I), 1, 1) <> '-' then
        AppendToArray(FProvidedArgs, ParamStr(I))
      else
        AppendProvidedOptions(ParamStr(I));
  end;
end;

procedure TCommandBuilder.ParseCommands;
var
  I, J: Integer;
begin
  for I := 0 to Length(FProvidedArgs) - 1 do
    for J := 0 to Length(FCommands) - 1 do
      if SameText(FCommands[J].Name, FProvidedArgs[I]) then
      begin
        if not Assigned(FCommandSelected) then 
          FCommandSelected := FCommands[J]
        else if ccNoArgumentsButCommands in FCommandSelected.Constraints then
          FCommandAsArgument := FCommands[J];
        Inc(FCommandsFound);
      end;
  
  if not Assigned(FCommandSelected) then
    FCommandSelected := GetDefaultCommand;

end;

procedure TCommandBuilder.ParseOptions;
var
  LOption: IOption;
  LRawOption, LOptionCleaned, LValue: string;
begin
  SetLength(FParsedOptions, 0);
  if not Assigned(CommandSelected) then 
    Exit;

  for LOption in CommandSelected.Options do
    for LRawOption in FProvidedOptions do
    begin
      LOptionCleaned := RemoveStartingDashes(LRawOption);
      LValue := SplitOptionAndValue(LOptionCleaned);
      // only the raw option of this option sets its value, the others must not reset it
      if AnsiMatchText(LOptionCleaned, [LOption.Flag, LOption.Name]) then
      begin
        LOption.Value := LValue;
        SetLength(FParsedOptions, Length(FParsedOptions) + 1);
        FParsedOptions[Length(FParsedOptions) - 1] := LOption;
      end;
    end;
end;

procedure TCommandBuilder.Parse; 
begin
  ParseArguments;
  ParseCommands;
  ParseOptions;  
end;

function TCommandBuilder.Validate: TArray<string>;  
var
  LValidatorContext: IValidatorContext;
begin
  LValidatorContext := TValidatorContext.Create;
  FParsedErrors := LValidatorContext.Validate(Self);
  Result := FParsedErrors;
   
  if ParsedErrorsShow then
    Exit;
end;

procedure TCommandBuilder.Execute;
begin
  if Length(FParsedErrors) = 0 then
    CommandSelected.Callback(Self);
end;

function TCommandBuilder.Run: ICommandBuilder;
begin
  Parse;
  // the command does not run, a script calling the tool must notice it
  if Length(Validate) > 0 then
    ExitCode := 1;
  Execute;
  Result := Self;
end;

function TCommandBuilder.CommandSelected: ICommand;
begin
  Result := FCommandSelected;
end;

function TCommandBuilder.SetCommandSelected(ACommand: ICommand): ICommandBuilder;
begin
  FCommandSelected := ACommand;
  Result := Self;
end;

function TCommandBuilder.CommandAsArgument: ICommand;    
begin
  Result := FCommandAsArgument;
end;

function TCommandBuilder.SetCommandAsArgument(ACommand: ICommand): ICommandBuilder;
begin
  FCommandAsArgument := ACommand;
  Result := Self;
end;

function TCommandBuilder.GetParsedOptions: TArray<IOption>;
begin
  Result := FParsedOptions;
end;

procedure TCommandBuilder.AppendProvidedOptions(const AParam: string);
var
  I: Integer;
begin
  if StartsText('--', AParam) then
    AppendToArray(FProvidedOptions, AParam)
  else
    for I := 2 to Length(AParam) do
    begin
      if Copy(AParam, I + 1, 1) = '=' then
      begin
        // the last flag of the group takes the value, with its dash like the others: -abc=1
        // is -a, -b and -c=1
        AppendToArray(FProvidedOptions, '-' + Copy(AParam, I, Length(AParam) - I + 1));
        break;
      end
      else
      begin
        AppendToArray(FProvidedOptions, '-' + Copy(AParam, I, 1));
      end;
    end;
end;

function TCommandBuilder.CheckOption(const AOption: string): Boolean;
var
  LOption: IOption;
begin
  Result := False;
  for LOption in FParsedOptions do
    if AnsiMatchText(AOption, [LOption.Flag, LOption.Name]) then
      Exit(True);
end;

function TCommandBuilder.CheckOption(const AOption: string; out AValue: string): Boolean;
var
  LOption: IOption;
begin
  Result := False;
  AValue := '';
  for LOption in FParsedOptions do
    if AnsiMatchText(AOption, [LOption.Flag, LOption.Name]) then
    begin
      AValue := LOption.Value;
      Exit(True);
    end;
end;

function TCommandBuilder.GetParsedArguments: TArray<IArgument>;
var
  LArray: TArray<IArgument> = [];
  I, J, LStart: Integer;
  LCmdSel: String = '';
  LCmdArg: String = '';
begin
  if Assigned(CommandSelected) then
    LCmdSel := CommandSelected.Name;
  if Assigned(CommandAsArgument) then
    LCmdArg := CommandAsArgument.Name;

  LStart := 0;
  for I := 0 to Length(FArguments) - 1 do
  begin
    // busca pelo primeiro argumento que não é um comando
    for J := LStart to Length(FProvidedArgs) - 1 do
      if (not SameText(FProvidedArgs[J], LCmdSel)) and (not SameText(FProvidedArgs[J], LCmdArg)) then
      begin
        SetLength(LArray, Length(LArray) + 1);
        LArray[Length(LArray) - 1] := FArguments[I];
        FArguments[I].Value := FProvidedArgs[J];
        LStart := J + 1;
      end;
  end;

  Result := LArray;
end;

function TCommandBuilder.GetRawArguments: TArray<string>;
begin
  Result := FProvidedArgs;
end;

function TCommandBuilder.GetRawOptions: TArray<string>;
begin
  Result := FProvidedOptions;
end;

function TCommandBuilder.GetCommandsFound: Integer;
begin
  Result := FCommandsFound;
end;

function TCommandBuilder.GetArguments: TArray<IArgument>;
begin
  Result := FArguments;
end;

function TCommandBuilder.ExeName: string;
begin
  Result := ChangeFileExt(FExeName, '');
end;

function TCommandBuilder.HasCommands: Boolean;
begin
  Result := Length(FCommands) > 0;
end;

function TCommandBuilder.HasArguments: Boolean;
begin
  Result := Length(FArguments) > 0;
end;

function TCommandBuilder.HasOptions: Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 0 to Length(FCommands) - 1 do
    if (Length(FCommands[I].Options) > 0) then
      Exit(True);
end;

procedure TCommandBuilder.SetInputLn(AValue: TInputLnCallback);
begin
  FInputLn := AValue; 
end;

function TCommandBuilder.GetInputLn: TInputLnCallback;
begin
  Result := FInputLn;
end;

function TCommandBuilder.GetOutput: TOutputCallback;
begin
  Result := FOutput;
end;

procedure TCommandBuilder.SetOutput(AValue: TOutputCallback);
begin
  FOutput := AValue;
end;

function TCommandBuilder.GetOutputColor: TOutputColorCallback;
begin
  Result := FOutputColor;
end;

procedure TCommandBuilder.SetOutputColor(AValue: TOutputColorCallback);
begin
  FOutputColor := AValue;
end;

function TCommandBuilder.GetColorTheme: TColorTheme;
begin
  Result := FColorTheme;
end;

procedure TCommandBuilder.SetColorTheme(AValue: TColorTheme);
begin
  FColorTheme := AValue;
end;

function TCommandBuilder.UseArguments(AArguments: TArray<string>): ICommandBuilder;
begin
  FExternalArguments := AArguments;
  FUseExternalArguments := True;
  Result := Self;
end;

function TCommandBuilder.UseColorTheme(ATheme: TColorTheme): ICommandBuilder;
begin
  FColorTheme := ATheme;
  Result := Self;
end;

function TCommandBuilder.GetTitle: string;
begin
  Result := FTitle;
end;

procedure TCommandBuilder.SetTitle(AValue: string);
begin
  FTitle := AValue;
end;

function TCommandBuilder.GetUseShortDescriptions: boolean;
begin
  Result := FUseShortDescriptions;
end;

procedure TCommandBuilder.SetUseShortDescriptions(AValue: boolean);
begin
  FUseShortDescriptions := AValue;
end;

function TCommandBuilder.GetState: string;
begin
  Result := FState;
end;

procedure TCommandBuilder.SetState(AValue: string);
begin
  FState := AValue;
end;

function StandardConsoleInputLn: string;
var
  LResult: string = '';
begin
  ReadLn(LResult);
  Result := LResult;
end;

procedure StandardConsoleOutput(const AMessage: string);
begin
  WriteLn(AMessage);
end;

procedure ColorConsoleOutput(const AMessage: string; const AColor: byte);
begin
  ChangeConsoleColor(AColor);
  Write(AMessage);
end;

end.