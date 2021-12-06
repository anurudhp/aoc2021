(⎕FR ⎕PP)←1287 34 ⍝ setting for exact integer arithmetic up to 34 digits
x←,⍎¨⎕CSV'inputs/day06.in' ⍝ parse input into single row
{+/({(1⌽⍵)+(1⍴⍵)×{⍵=7}⍳9}⍣⍵){+/x=⍵-1}¨⍳9}¨80 256 ⍝ compute both parts


