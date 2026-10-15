/// <summary> This unit contains the TCommandApp class responsible for running the application. 
/// Through this class it is possible to configure all the parameters available to the user.
/// </summary>
unit Command.App;

{$MODE DELPHI}{$H+}

interface

uses
  Classes,
  SysUtils,
  CustApp,
  Command.Interfaces,
  Command.Builder;

type
  /// <summary> This class allows you to define which arguments, commands, and options will 
  /// be accepted as parameters by executing the application via the command line. For that 
  /// it is necessary to use the @link(TCommandApp.CommandBuilder) property.
  /// </summary>  
  /// 
  /// Ex: 
  /// @longCode(#
  /// 
  /// uses Command.Interfaces, Command.App, Command.Usage, Command.Version;
  /// 
  /// begin
  ///   Application := TCommandApp.Create(nil);
  ///   Application.Title := 'a basic cli tool sample project';
  /// 
  ///   Command.Usage.Registry(Application.CommandBuilder);
  ///   Command.Version.Registry(Application.CommandBuilder);
  /// 
  ///   Application.Run;
  ///   Application.Free;
  /// end.
  /// #)
  TCommandApp = class(TCustomApplication)
  private
    FCommandBuilder: ICommandBuilder;

    /// <summary> Read an environment variable named COLORFGBG that should be filled with the following
    /// pattern "foreground color;background color". If the background color is white (15), default 
    /// color theme will be changed to LightColorTheme. 
    /// To change this variable on windows powershell you may use $ENV:COLORFGBG="0;15" and to change
    /// on linux you may use COLORFGBG="0;15" directly on bash terminal.
    /// </summary>
    procedure SetDefaultThemeColor;

  protected

    /// <summary> Parse the parameters passed via the command line, validate them, execute the command 
    /// informed if one was found according to the same parameters and finish the application execution.
    /// </summary>
    procedure DoRun; override;

  public
    /// <summary> Constructor of the class responsible for initializing it and its dependencies. The 
    /// main dependency is the CommandBuilder.
    /// </summary>
    constructor Create(TheOwner: TComponent); override;

    /// <summary> The CommandBuilder is the main property of the class, through which the commands, 
    /// arguments and options that will be accepted as parameters via the command line can be configured.
    /// It is automatically launched when the application is created.
    /// </summary>    
    property CommandBuilder: ICommandBuilder read FCommandBuilder write FCommandBuilder;
  end;

implementation

uses
  StrUtils,
  Types,
  Command.Colors;

{ TCommandApp }

procedure TCommandApp.DoRun;
begin
  SetDefaultThemeColor;
  CommandBuilder.Title := Title;
  CommandBuilder.Parse;
  // the command does not run, a script calling the tool must notice it
  if Length(CommandBuilder.Validate) > 0 then
    ExitCode := 1;
  CommandBuilder.Execute;
  Terminate;
end;

constructor TCommandApp.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
  StopOnException := True;
  FCommandBuilder := TCommandBuilder.Create(ExtractFileName(Self.ExeName));
end;

procedure TCommandApp.SetDefaultThemeColor;
var
  LColor: string;
  LColors: TStringDynArray ;
begin
  LColor := GetEnvironmentVariable('COLORFGBG');
  if LColor = '' then 
    exit;
  LColors := SplitString(LColor, ';');
  if (Length(LColors) > 0) and (LColors[1] = '15') then
  begin
    FCommandBuilder.ColorTheme := LightColorTheme;
    StartupColor := 0;
  end;
end;

end.