 assert←{
     ⍺←'assertion failed'
     0={0::0 ⋄ ⍎⍵}⍵:⍺,': ',⍵,' ⍝ at ',(2⊃⎕XSI,⊂'(immediate execution)'),'[',(⍕2⊃2↑⎕LC),']'
     ''
 }
