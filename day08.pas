PROGRAM Day07;
uses Classes, SysUtils;

PROCEDURE split(const aDelimiter, s: String; aList: TStringList);
BEGIN
  aList.Clear;
  aList.LineBreak := aDelimiter;
  aList.Text := s;
END;

FUNCTION common(a, b : String) : Integer;
VAR
  i, j : Integer;
BEGIN
  common := 0;
  for i := 1 to length(a) do
    for j := 1 to length(b) do
      if (a[i] = b[j]) then common := common + 1;
END;

FUNCTION equal(a, b : String) : Boolean;
BEGIN
  equal := (length(a) = length(b)) and (common(a, b) = length(a));
END;

VAR
  buf : String[100];
  digits, targets, lbuf : TStringList;
  i, j, d, s, v : Integer;
  idx : Array[0..9] of Integer;
  answer1, answer2 : Int64;

BEGIN
  digits := TStringList.Create;
  targets := TStringList.Create;
  lbuf := TStringList.Create;
  answer1 := 0;
  answer2 := 0;

  while not eof() do begin
    readln(buf);
    split(' | ', buf, lbuf);
    split(' ', lbuf[0], digits);
    split(' ', lbuf[1], targets);

    (* part 1 *)
    for i := 0 to 3 do begin
      s := length(targets[i]);
      if (s = 2) or (s = 3) or (s = 4) or (s = 7) then answer1 := answer1 + 1;
    end;

    (* part 2 *)
    for d := 0 to 9 do idx[d] := -1;
    for j := 0 to 9 do begin
      s := length(digits[j]);
      if s = 2 then idx[1] := j;
      if s = 4 then idx[4] := j;
      if s = 3 then idx[7] := j;
      if s = 7 then idx[8] := j;
    end;
    for j := 0 to 9 do begin
      s := length(digits[j]);
      if (s = 5) then begin
        if common(digits[j], digits[idx[1]]) = 2 then idx[3] := j
        else if common(digits[j], digits[idx[4]]) = 2 then idx[2] := j
        else idx[5] := j;
      end;
      if (s = 6) then begin
        if common(digits[j], digits[idx[1]]) = 1 then idx[6] := j
        else if common(digits[j], digits[idx[4]]) = 4 then idx[9] := j
        else idx[0] := j;
      end;
    end;

    v := 0;
    for i := 0 to 3 do
      for d := 0 to 9 do
        if equal(targets[i], digits[idx[d]]) then v := v * 10 + d;
    answer2 := answer2 + v;
  end;

  writeln(answer1, ' ', answer2);
END.
