/// <summary>This unit contains a set of simple functions that help to perform repetitive 
/// actions related to parsing the arguments passed by the command line. </summary>
unit Command.Helpers;

{$MODE DELPHI}{$H+}

interface

  /// <summary>Appends a string to an array of string automatically increasing its size </summary>
  /// <param name="AArray">Variable of type TArray<string> to which an item will be added.</param>
  /// <param name="AText">String to be added to the array.</param>
  procedure AppendToArray(var AArray: TArray<string>; const AText: string);

  /// <summary>Removes the first "-" and second "-" characters if found from the string passed
  /// as a parameter. Returns a new string without these characters.</summary>
  /// <param name="LOption">String option passed as an argument via the command line that will 
  /// be processed to remove the leading "-".</param>
  function RemoveStartingDashes(const LOption: string): string;

  /// <summary>Given an option with value, split the option in two parts: the option name and the
  /// value. The option name is the part before the "=" character. The value is the part after the
  /// "=" character. If the option doesn't contain the "=" character, the value is empty. 
  /// The function returns the value and keeps the only the option name in the parameter AOption. </summary>
  /// <param name="AOption">String option passed as an argument via the command line that will 
  /// be processed split a possible value from the option name.</param>
  function SplitOptionAndValue(var AOption: string): string;
  
implementation

uses
  StrUtils;

procedure AppendToArray(var AArray: TArray<string>; const AText: string);
begin
  SetLength(AArray, Length(AArray) + 1);
  AArray[Length(AArray) - 1] := AText;
end;

function RemoveStartingDashes(const LOption: string): string;
begin
  Result := LOption;
  if StartsText('-', Result) then
  begin
    Result := Copy(LOption, 2, Length(LOption));
    if StartsText('-', Result) then
      Result := Copy(Result, 2, Length(Result));
  end;
end;

function SplitOptionAndValue(var AOption: string): string;
var
  I: Integer;
  LRawOption: string;
begin
  Result := '';
  LRawOption := AOption;
  for I := 1 to Length(LRawOption) do
    if LRawOption[I] = '=' then
    begin
      Result := Copy(LRawOption, I + 1, Length(LRawOption) - I);
      AOption := Copy(LRawOption, 0, I - 1);
      Exit;
    end;
end;

end.