 test_APLProcess port;client;p
 :If 0=⎕NC'Debug' ⋄ Debug←0 ⋄ :EndIf
 :Trap Debug↓223
     assertFail assert'0=LoadConga'
     p←⎕NEW APLProcess
     p.Ws←##.TESTSOURCE,'rpc.dws'
     p.Args←'RPCPort=',⍕port
     p.Run
     ⎕DL 2
     assertFail assert'1=p.(IsRunning Proc.Id)'
     client←RPCInit port
     assertFail assert'(⎕DR client)∊80 82'
     assertFail assert'(⍳10)≡ client RPCDo ''⍳10'''
     assertFail assert'1=p.Kill'
     ⎕DL 2
     assertFail assert'0=p.(IsRunning Proc.Id)'
     ⎕←'Test completed'
 :Else
     ⎕←'Test failed'
 :EndTrap
 {}{0::1 ⋄ ##.DRC.Close client}⍬
