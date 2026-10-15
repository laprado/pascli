unit TestCommandHelper;

{$MODE DELPHI}{$H+}

interface

uses
  Classes, 
  SysUtils, 
  fpcunit, 
  testutils, 
  testregistry,
  Command.Helpers;

type

  TTestCommandHelper = class(TTestCase)
  published
    procedure TestAppendToArray;
    procedure TestRemoveStartingDashes;
    procedure TestSplitOptionAndValue;
  end;

implementation

procedure TTestCommandHelper.TestAppendToArray;
var
  LArray: TArray<string> = [];
begin
  SetLength(LArray, 0);
  AppendToArray(LArray, 'new string');
  AssertEquals('String not added to array variable', 'new string', LArray[0]);
  AssertEquals('Array length should be 1', 1, Length(LArray));
end;

procedure TTestCommandHelper.TestRemoveStartingDashes;
begin
  AssertEquals('Remove first one dash not work.', 'd', RemoveStartingDashes('-d'));
  AssertEquals('Remove first two dashes not work.', 'debug', RemoveStartingDashes('--debug'));
  AssertEquals('Remove third dash.', '-d', RemoveStartingDashes('---d'));
  AssertEquals('Remove middle dashes.', 'debug-no-compile', RemoveStartingDashes('--debug-no-compile'));
  AssertEquals('Keep a long option with its value.',
    'package=a-package-name-longer-than-thirty-chars',
    RemoveStartingDashes('--package=a-package-name-longer-than-thirty-chars'));
end;

procedure TTestCommandHelper.TestSplitOptionAndValue;
var
  LExpectedOption, LExpectedValue, LActualOption, LActualValue: string;
begin
  LExpectedOption := 'debug';
  LExpectedValue := 'myproject.lpr';
  
  LActualOption := LExpectedOption + '=' + LExpectedValue;
  LActualValue := SplitOptionAndValue(LActualOption);

  AssertEquals('Option with value', LExpectedOption, LActualOption);
  AssertEquals('Option with value', LExpectedValue, LActualValue);

  LExpectedOption := 'debug';
  LExpectedValue := '';
  
  LActualOption := LExpectedOption + '=' + LExpectedValue;
  LActualValue := SplitOptionAndValue(LActualOption);

  AssertEquals('Option with empty value', LExpectedOption, LActualOption);
  AssertEquals('Option with empty value', LExpectedValue, LActualValue);

  LExpectedOption := 'debug';
  LExpectedValue := '';
  
  LActualOption := LExpectedOption;
  LActualValue := SplitOptionAndValue(LActualOption);

  AssertEquals('Option with no value, no equal sign', LExpectedOption, LActualOption);
  AssertEquals('Option with no value, no equal sign', LExpectedValue, LActualValue);
end;

initialization
  RegisterTest(TTestCommandHelper);

end.

