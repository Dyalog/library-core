 setup;⎕ML;⎕IO;t
 (⎕IO ⎕ML)←1
 :If 0=##.⎕NC'TESTSOURCE'
     :If ~0∊⍴t←4⊃5179⌶⊃⎕XSI
         ##.TESTSOURCE←⊃1 ⎕NPARTS t
     :Else
         ##.TESTSOURCE←'/git/library-core/tests/'
     :EndIf
 :EndIf
 2 ⎕FIX'file://',##.TESTSOURCE,'../APLProcess.dyalog'
 2 ⎕FIX'file://',##.TESTSOURCE,'assert.dyalog'
 2 ⎕FIX'file://',##.TESTSOURCE,'LoadConga.aplf'
