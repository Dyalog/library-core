 assertFail msg
 :If ~0∊⍴msg
     223 ⎕SIGNAL⍨⎕←msg
 :EndIf
