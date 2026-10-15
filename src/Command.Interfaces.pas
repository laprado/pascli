/// <summary> This unit contains interfaces and types used by the library to build and process 
/// commands, arguments, options, validations, themes and callback functions that leverage 
/// library customization as well as make testing it easier.
/// </summary>
unit Command.Interfaces;

{$MODE DELPHI}{$H+}

interface

uses
  Classes;

type
  {$M+}
  IOption = interface;
  ICommand = interface;
  IArgument = interface;
  ICommandBuilder = interface;
  IValidatorContext = interface;
  IValidatorBase = interface;

  /// <summary> Color theme structure used across the library. All fields in this record 
  /// represent colors that can be defined from the color constants found in the 
  /// Command.Colors unit. </summary>
  TColorTheme = record
    /// <summary> Holds color for text representing titles. </summary>
    Title: Byte;
    /// <summary> Holds color for text representing values. </summary>
    Value: Byte;
    /// <summary> Holds color for normal text. </summary>
    Text: Byte;
    /// <summary> Holds color for error messages. </summary>
    Error: Byte;
    /// <summary> Holds color for other text that does not require highlighting. </summary>
    Other: Byte;
  end;  

  /// <summary> Enumerated type that defines constraints that apply on commands. It is used 
  /// to indicate to the CommandBuilder the rules for using the command, allowing its validation 
  /// to be done automatically. </summary>
  TCommandConstraint = (
    /// <summary> Indicates the default command that will be invoked by the CommandBuilder 
    /// when a command is not informed through the command line by the user. </summary>
    ccDefault,
    /// <summary> Indicates that the command requires at least one given argument to be used. 
    /// </summary>
    ccRequiresOneArgument, 
    /// <summary> Indicates that the command requires at least one option entered to be used.
    /// </summary>
    ccRequiresOneOption, 
    /// <summary> Indicates that the command requires another command to function and does not 
    /// accept arguments. A clear example of usage is the help command itself, which can 
    /// provide instructions for using other commands.
    /// </summary>
    ccNoArgumentsButCommands,
    /// <summary> Indicates that the command should be used without any parameters.
    /// </summary>
    ccNoParameters);

  /// <summary> Set type of constraints, as they can have their combined use when configuring 
  /// a command. </summary>
  TCommandConstraints = set of TCommandConstraint;

  /// <summary> Enumerated type that defines constraints that apply on options. It is used 
  /// to indicate to the CommandBuilder the rules for using options, allowing its validation 
  /// to be done automatically. </summary>
  TOptionConstraint = (
    /// <summary> Indicates that a value is not accepted for the option.</summary>
    ocNoValue,
    /// <summary> Indicates that a value is required for the option. </summary>
    ocRequiresValue, 
    /// <summary> Indicates that a value is optional for the option. </summary>
    ocOptionalValue);

  /// <summary> Enumerated type that defines constraints that apply on arguments. It is used 
  /// to indicate to the CommandBuilder the rules for using arguments, allowing its validation 
  /// to be done automatically. </summary>
  TArgumentConstraint = (
    /// <summary> Indicates that the argument is required. Do not use it if one command doest not 
    /// require any parameters. </summary>
    acRequired, 
    /// <summary> Indicates that the argument is optional. </summary>
    acOptional);

  /// <summary> Callback procedure signature that represents a command defined in the program.
  /// </summary>
  /// <param name="ABuilder"> Instance of CommandBuilder that processed, validated, and identified
  /// the callback command being called. </param>
  TCommandCallback = procedure (ABuilder: ICommandBuilder);

  /// <summary> Callback function signature need to add a command using the overloaded version
  /// of CommandBuilder.AddCommand. This signature is different to avoid collision with the
  /// TCommandCallback signature. The return result is not required. </summary>
  /// <param name="ABuilder"> Instance of CommandBuilder used to add the command. </param>
  TAddCommandCallback = function (ABuilder: ICommandBuilder): Boolean;

  /// <summary> Callback procedure signature that is intended to output text to the console, 
  /// or other desired output. The library provides a standard callback that simply calls WriteLn, 
  /// but it can be overridden so that the output is redirected to a file, a test function, etc.
  /// </summary>
  /// <param name="AMessage"> Text that will be printed on output. </param>
  TOutputCallback = procedure (const AMessage: string);

  /// <summary> Callback procedure signature that is intended to output text to the console
  /// usings colors. The library provides a standard callback that simply calls Write before 
  /// change console color, but it can be overridden so that the output is redirected to a file, 
  /// a test function, etc.
  /// </summary>
  /// <param name="AMessage"> Text that will be printed on output. </param>
  /// <param name="AColor"> Color that should be used to print the text. </param>
  TOutputColorCallback = procedure (const AMessage: string; const AColor: byte);

  /// <summary> Callback procedure signature used by the library to capture user input. 
  /// A default callback is provided by the library, but it can be overridden for testing 
  /// purposes primarily. Should return user input. </summary>
  TInputLnCallback = function: string;

  /// <summary> Interface representing an option that can be set as expected for a command.
  /// </summary>
  IOption = interface
    ['{C24CC7B9-946E-44AA-BF92-CE89592F0940}']  

    function GetFlag: string;
    procedure SetFlag(const AValue: string);

    /// <summary> Represents the option as a single letter, i.e. a short option </summary>
    property Flag: string read GetFlag write SetFlag;

    function GetName: string;
    procedure SetName(const AValue: string);

    /// <summary> Represents the option as a word, that is, a long option, it does not accept 
    /// spaces, but "-' can be used for compound names. </summary>
    property Name: string read GetName write SetName;

    function GetDescription: string;
    procedure SetDescription(const AValue: string);

    /// <summary> Description of the option that best defines your objective. It can be 
    /// displayed to the user when the user requests information through the help command 
    /// for example.</summary>
    property Description: string read GetDescription write SetDescription;     

    procedure SetNotAllowedFlags(const Value: TArray<string>);
    function GetNotAllowedFlags: TArray<string>;

    /// <summary> Array of flags not supported for use in conjunction with this option. 
    /// Only the short option without the "-" is accepted.</summary>
    property NotAllowedFlags: TArray<string> read GetNotAllowedFlags write SetNotAllowedFlags;

    function GetConstraint: TOptionConstraint;
    procedure SetConstraint(const AValue: TOptionConstraint);

    /// <summary> Option constrains that will be validated against the options provided 
    /// by the user in order to guarantee that the command is being used correctly. </summary>
    property Constraint: TOptionConstraint read GetConstraint write SetConstraint;

    /// returns the value of the option provided via parameter, this value should assigned after parse
    function GetValue: string;
    procedure SetValue(const AValue: string);

    /// <summary> Returns the value of an option after parsing the parameters informed 
    /// via the command line. The value of an option shoud be passed on right side of 
    /// an equal sign after the option name or flag.
    /// </summary>
    property Value: string read GetValue write SetValue;

  end;

  /// <summary>Interface representing a command that can be registered in CommandBuilder 
  /// for later use by the user.
  /// </summary>
  ICommand = interface
    ['{AD920381-6441-48B1-B035-19694D0417A2}']

    function GetName: string;
    procedure SetName(const AValue: string);

    /// <summary> Name of the command that will be used via the command line by the user.
    /// </summary>
    property Name: string read GetName write SetName;

    function GetDescription: string;
    procedure SetDescription(const AValue: string);

    /// <summary> Description of the command that best describes its purpose. It can be 
    /// displayed to the user when he requests help information for the application.
    /// </summary>
    property Description: string read GetDescription write SetDescription;    

    function GetCallback: TCommandCallback;
    procedure SetCallback(AValue: TCommandCallback);

    /// <summary> Procedure that will be invoked by the builder after validation of the 
    /// arguments provided by the user and the correct match of this command as the 
    /// requested one. </summary>
    property Callback: TCommandCallback read GetCallback write SetCallback;

    function GetConstraints: TCommandConstraints;
    procedure SetConstraints(const AValue: TCommandConstraints);

    /// <summary> Command constrains that will be validated against the arguments provided 
    /// by the user in order to guarantee that the command is being used correctly. </summary>
    property Constraints: TCommandConstraints read GetConstraints write SetConstraints;

    /// <summary> Retrieves an option given the index provided as a parameter. </summary>
    /// <param name="AIndex">Desired option index position</param>
    function GetOption(const AIndex: string): IOption;

    /// <summary> Retrieves an option given the index provided as a parameter. </summary>
    /// <param name="AIndex">Desired option index position</param>
    property Option[const AIndex: string]: IOption read GetOption;

    /// <summary> Function that returns the array of options defined for the command. </summary>
    function GetOptions: TArray<IOption>;    

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

  end;

  /// <summary>Interface representing an argument that can be registered in CommandBuilder 
  /// for later use by the user.
  /// </summary>
  IArgument = interface
    ['{930DA68E-6B31-4A05-A20E-C0056BFDE1AA}']

    function GetDescription: string;
    procedure SetDescription(const AValue: string);

    /// <summary> Description of the argument that best describes its purpose. It can be 
    /// displayed to the user when he requests help information for the application.
    /// </summary>
    property Description: string read GetDescription write SetDescription;    

    function GetConstraint: TArgumentConstraint;
    procedure SetConstraint(const AValue: TArgumentConstraint);

    /// <summary> Argument constraints that will be validated against the arguments provided 
    /// by the user in order to guarantee that the command is being used correctly. </summary>
    property Constraint: TArgumentConstraint read GetConstraint write SetConstraint;

    /// returns the value of argument provided via parameter, this value should assigned after parse
    function GetValue: string;
    procedure SetValue(const AValue: string);

    /// <summary> Returns the value of an argument after parsing the parameters informed 
    /// via the command line. If a given command line parameter has not been classified 
    /// as a command, it will be assigned to an argument in the order of configuration.
    /// </summary>
    property Value: string read GetValue write SetValue;

  end;

  /// <summary> Interface that represents the CommandBuilder, its main purpose is to configure
  /// the arguments, commands and options accepted by the tool. Central point of the library, 
  /// responsible for comparing and validating the parameters passed via the command line against 
  /// the configured parameters, later executing the callback linked to the localized command.
  /// </summary>
  ICommandBuilder = interface
    ['{5CD580B0-B965-4467-B665-CDFDF61651F1}']

    /// <summary> Adds a command that will be available to the user of the command line 
    /// application.
    /// </summary>
    /// <param name="ACommand">Command name as it will be provided by the user via command 
    /// line parameter. </param>
    /// <param name="ADescription">Command description that will be displayed to the user
    /// as usage info. </param>
    /// <param name="ACallback">Callback procedure that will be invoked by the CommandBuilder 
    /// if the validation was successful and the command informed match the command name.</param>
    /// <param name="AConstraints">Validation constraints for command usage, may set to default, 
    /// may require a required argument, a required option. Check TCommandConstraint for 
    /// existing constraints.</param>
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
    function GetCommands: TArray<ICommand>;    

    /// <summary> Returns the list of commands configured in CommandBuilder.
    /// </summary>
    property Commands: TArray<ICommand> read GetCommands;

    /// <summary> Returns the number of commands found among the arguments passed as 
    /// parameters after Parse.</summary>
    function GetCommandsFound: Integer;

    /// <summary> Returns the default command if one has been configured. </summary>
    function GetDefaultCommand: ICommand;

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

    /// <summary> Adds an argument to allow the user to pass a text argument via the command 
    /// line.</summary>
    /// <param name="ADescription">Description of the argument to inform the user of the 
    /// correct usage info about it. </param>
    /// <param name="AConstraint">Constraints to check if the argument is optional or mandatory.
    /// </param>
    function AddArgument(const ADescription: string; AConstraint: TArgumentConstraint): ICommandBuilder;    

    /// <summary> Returns the list of arguments configured in CommandBuilder. </summary>
    function GetArguments: TArray<IArgument>;

    /// <summary> Returns the list of arguments configured in CommandBuilder. </summary>
    property Arguments: TArray<IArgument> read GetArguments;

    /// <summary>Adds an option to the last added command. For both the short and long 
    /// options, "-" must not be entered at the beginning of them.</summary>
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

    /// <summary> Invokes the callback procedure configured for the command found once parse 
    /// and validation have been successful. It passes the CommandBuilder itself as a parameter 
    /// to the callback so that it is possible to call the CheckOption method to validate the 
    /// presence of a certain option, or to obtain the value of an expected argument through 
    /// the Arguments[n].Value property. </summary>
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

    /// <summary> Returns the list of valid options found after parse. </summary>
    function GetParsedOptions: TArray<IOption>;    

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
    function GetParsedArguments: TArray<IArgument>;    

    /// <summary> Build a list of IArguments related to selected command, if there are more than 
    /// one argument provided the list will match one argument parameter by order of the command 
    /// builder configuration </summary>
    property ParsedArguments: TArray<IArgument> read GetParsedArguments;

    /// <summary> Returns a list of raw arguments passed as parameters </summary>
    function GetRawArguments: TArray<string>;

    /// <summary> Returns a list of raw options passed as parameters </summary>
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

    function GetInputLn: TInputLnCallback;
    procedure SetInputLn(AValue: TInputLnCallback);

    /// <summary> Callback procedure used to capture user input. A default callback is provided 
    /// by the library, but it can be overridden for testing purposes primarily. 
    /// Should return user input. </summary>
    property InputLn: TInputLnCallback read GetInputLn write SetInputLn;

    function GetOutput: TOutputCallback;
    procedure SetOutput(AValue: TOutputCallback);

    /// <summary> Callback procedure that is intended to output text to the console, or other 
    /// desired output. The library provides a standard callback that simply calls WriteLn, 
    /// but it can be overridden so that the output is redirected to a file, a test function, etc.
    /// </summary>
    property Output: TOutputCallback read GetOutput write SetOutput;

    function GetOutputColor: TOutputColorCallback;
    procedure SetOutputColor(AValue: TOutputColorCallback);

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

    function GetColorTheme: TColorTheme;
    procedure SetColorTheme(AValue: TColorTheme);

    /// <summary> Color theme that should be used to output colors of commands, a standard 
    /// theme is provided by Command.Colors unit. Should be changed prior to application
    /// execution </summary>
    property ColorTheme: TColorTheme read GetColorTheme write SetColorTheme;

    function GetTitle: string;
    procedure SetTitle(AValue: string);

    /// <summary> Application title, should be customized and is displayer on usage info
    /// to the user </summary>
    property Title: string read GetTitle write SetTitle;

    function GetUseShortDescriptions: boolean;
    procedure SetUseShortDescriptions(AValue: boolean);

    /// <summary> Display only the first line usage description for command usage, the user needs
    /// to use help command to see full command description. Default value is false to
    /// preserve original function. </summary>
    property UseShortDescriptions: boolean read GetUseShortDescriptions write SetUseShortDescriptions;

    function GetState: string;
    procedure SetState(AValue: string);

    /// <summary> State that can be set by user commands allowing better communication 
    /// between commands and the application. </summary>
    property State: string read GetState write SetState;

  end;

  /// <summary> Interface that groups all validators, as well as establishes the validation order.
  /// </summary>
  IValidatorContext = interface
    ['{72A67B7E-E243-447D-9AB1-D1A6883FE425}']

    /// <summary> Successive calls to the add method are responsible for creating the validation context. 
    /// This method adds an IValidatorBase and sets it as the successor if a previous IValidatorBase exists.
    /// </summary>
    /// <param Name="AValidator"> A valid instance of IValidatorBase responsible for processing a specific 
    /// type of validation.</param>
    function Add(AValidator: IValidatorBase): IValidatorContext;

    /// <summary> Executes the validation of the first added IValidatorBase, being the responsibility 
    /// of this object to call its successor IValidatorBase and so on.
    /// <param Name="ACommand"> CommandBuilder instance containing the arguments, commands and options 
    /// configured to be validated against the arguments passed to it.</param>
    function HandleValidation(ACommand: ICommandBuilder): TArray<string>;

    /// <summary> Builds the validation context by adding each class of type IValidatorBase. It then 
    /// calls the first validator triggering the validator pattern. </summary>
    /// <param Name="ACommand"> CommandBuilder instance containing the arguments, commands and options 
    /// configured to be validated against the arguments passed to it.</param>
    function Validate(ACommand: ICommandBuilder): TArray<string>;

  end;

  /// <summary> Base interface for any validation that needs to be implemented. Specification 
  /// validations need to inherit from this interface by convention from this library. 
  /// It already has control for the successor validator as well as its automatic call at the 
  /// appropriate time. </summary>
  IValidatorBase = interface
    ['{223310E5-CDB9-4BCF-B87B-599384ADF983}']

    function GetSucessor: IValidatorBase;
    procedure SetSucessor(const AValue: IValidatorBase);

    /// <summary> Allows you to set or access the successor validator. </summary>
    property Sucessor: IValidatorBase read GetSucessor write SetSucessor;

    /// <summary> Validates a single specific case. It must be implemented by the child class. 
    /// If the validation is successful and there is a successor, the successor's validation method 
    /// will be called. A TArry<string> will be returned with errors detected whether they are from 
    /// the current or successor validation. </summary>
    /// <param Name="ACommand"> CommandBuilder instance containing the arguments, commands and options 
    /// configured to be validated against the arguments passed to it.</param>
    function Validate(ACommand: ICommandBuilder): TArray<string>;

  end;

implementation

end.