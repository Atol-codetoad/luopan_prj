unit gua_func;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants,
  FMX.Types;

function CalcGuaNum(DateBirth: TDateTime; sex: boolean): Integer; // sex True=M

implementation

function CalcGuaNum(DateBirth: TDateTime; sex: boolean): Integer;
var
  myYear, myMonth, myDay: word;
  // ------------- inner func
  function Twoin1(digit: Integer): Integer;
  var
    tmp: Integer;
  begin
    // tmp:=digit div 10;
    if digit div 10 > 0 then
      tmp := (digit mod 10) + (digit div 10)
    else
      tmp := digit;
    // Todo: при сложении может возникнуть болше десяти тогда опять рекурсию!
    if tmp div 10 > 0 then
      result := Twoin1(tmp)
    else
      result := tmp;

  end;

  function Last2digit1(Year: word): Integer;
  var
    l2d: Integer;
  begin
    l2d := Year mod 100;
    result := Twoin1(l2d); // ?
  end;

  function res5(num: Integer; sex: boolean): Integer;
  begin
    if num = 5 then
    begin
      if sex then
        result := 2
      else
        result := 8;
    end
    else
    begin
      if num = 0 then
        result := 9
      else
        result := num;
    end;
  end;

// -------------
begin
  DecodeDate(DateBirth, myYear, myMonth, myDay);
  if myYear < 2000 then
  begin
    if sex then
    begin
      result := res5(10 - Last2digit1(myYear), sex);
    end
    else
    begin
      result := res5(Twoin1(5 + Last2digit1(myYear)), sex);
    end;
  end
  else
  begin
    if sex then
    begin
      result := res5(10 - 1 - Last2digit1(myYear), sex);
    end
    else
    begin
      result := res5(Twoin1(5 + 1 + Last2digit1(myYear)), sex);
    end;
  end;

end;

end.
