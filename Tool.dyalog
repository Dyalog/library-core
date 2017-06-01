:Namespace Tool  
⍝ Tool loader fo Dyalog APL
⍝ Currently supports Conga, SQAPL, RConnect, SharpPlot

⍝   ref←Tool.New 'toolname' [rarg] [larg] [minver] [target]
⍝       Returns a ref to an instance of the tool, read for use
⍝       Optional rarg is passed to constructor or initialisation function
⍝       Optional larg is passed if not '' 
⍝       Optional minver is minimum version required (NOT SUPPORTED YET)
⍝       Optional target is ref to namespace to load into

⍝   ref←Tool.Prepare 'toolname' [minver] [target]
⍝       Returns a ref to the main namespace or class which implements the tool   
⍝       See Tool.New for a description of arguments

    lc←0∘(819⌶)          ⍝ lowercase
    ge←{(1000⊥⍺)≥1000⊥⍵} ⍝ compare version numbers

    ∇ r←findws ws;DYALOG
    ⍝ Look for workpace in the current directory, then in the DYALOG folder
     
      :If ~⎕NEXISTS r←ws,'.dws'
          DYALOG←{⍵,'/'↓⍨'/\'∊⍨¯1↑⍵}2 ⎕NQ'.' 'GetEnvironment' 'DYALOG'
      :AndIf ~⎕NEXISTS r←DYALOG,'/ws/',r
          ('Unable to locate workspace "',ws,'"')⎕SIGNAL 11
      :EndIf
    ∇

    ∇ r←New args;module;rarg;larg;minver;target;z;ns
     ⍝ Initialise a Core Dyalog Application Component
     ⍝ args[1] - or simple argument: Conga|SQAPL|SharpPlot (more to come)
     ⍝ The rest are optional
     ⍝ args[2] - right argument to Init function of the component (default = '')
     ⍝     [3] - left argument to Init function (missing or '' = monadic call)
     ⍝     [4] - Minimum version required in the form (major minor svnrev)
     ⍝     [5] - Terget namespace to materialise namespaces or classes in (default = #)
     
      (module rarg larg minver target)←args←{⍵,(≢⍵)↓'' '' ''(0 0 0)#},⊆args
     
      :If larg≡''
          z←⎕EX'larg' ⋄ larg←⊢
      :EndIf
     
      :Trap 999
          ns←Prepare args[1 4 5]
      :Else
          (⊃⎕DMX.DM)⎕SIGNAL ⎕DMX.EN
      :EndTrap
     
      ⍝ Now initialise
      :Select lc module                                       

      :Case 'conga' 
          :If 9.2=⎕NC ⊂'ns'           ⍝ Instance (of Conga)
              r←ns
          :ElseIf 3=ns.⎕NC 'FindInst' ⍝ Looks like the Conga namespace
              r←larg ns.Init rarg
          :ElseIf 3=ns.⎕NC 'IWAAuth'  ⍝ Looks like old style DRC
              :If (⊃z←larg ns.Init rarg)∊0
                  r←ns
              :Else
                  ('DRC.Init returned: ',⍕z)⎕SIGNAL 11
              :EndIf  
          :Else
              ('Unable to determine Conga version of ',ns) ⎕SIGNAL 11
          :EndIf
      
      :Case 'sqapl'
         :If 0=⊃z←ns.Init rarg
             r←ns
         :Else
             ('SQA.Init returned: ',⍕z)⎕SIGNAL 11
         :EndIf
      
      :Case 'sharpplot'
          r←#.⎕NEW ns
      
      :Case 'rconnect'
          r←#.⎕NEW ns
          {}r.init
      :Else
          ('Unknown module: ',module)⎕SIGNAL 6
      :EndSelect
    ∇

    ∇ r←Prepare args;module;minver;target
     ⍝ Load, but do not initialise a Core Dyalog Application Component
     ⍝ Return a reference to the namespace/class that was loaded
     
     ⍝ args[1] - or simple argument: Conga|SQAPL|SharpPlot|RConnect
     
     ⍝ Optional arguments:
     ⍝     [2] - Minimum version required in the form (major minor svnrev)
     ⍝     [3] - Terget namespace to materialise namespaces or classes in (default = #)
     
      (module minver target)←{⍵,(≢⍵)↓''(0 0 0)#},⊆args 
      'Minimum Version not yet supported' ⎕SIGNAL (0 0 0≢3↑minver)/11      
     
      :Select lc module
      :Case 'conga'
          r←LoadConga minver target
      :Case 'sqapl'
          r←LoadSQAPL minver target
      :Case 'sharpplot'
          r←LoadSharpPlot minver target
      :Case 'rconnect'
          r←LoadRConnect minver target
      :Else
          ('Unknown module: ',module)⎕SIGNAL 6
      :EndSelect
    ∇

    ∇ r←LoadRConnect(minver target)
    ⍝ Unable to verify version, rconnect doesn't expose one
      :If 9≠target.⎕NC'R'
          target.⎕CY findws'rconnect'
      :EndIf
      r←target.R
    ∇

    ∇ r←LoadSQAPL(minver target)
      :If 9≠target.⎕NC'SQA'
          'SQA'target.⎕CY findws'sqapl'
      :EndIf
      r←target.SQA
    ∇

    :Section Conga

    ∇ r←LoadConga(minver target);ns;m;nss;copied;ws
     
      r←copied←''
     
      :If ∨/m←0≠target.⎕NC nss←'Conga' 'DRC'
          r←target⍎ns←(m⍳1)⊃nss
      :Else
          (ns←'Conga')target.⎕CY ws←findws 'conga'
          copied←' copied from "',ws,'"'
          r←target.Conga
      :EndIf
     
⍝      :If ~r.Version ge minver
⍝          ('LoadConga: ',ns,copied,' has version ',⍕minver)⎕SIGNAL 11
⍝      :EndIf
    ∇

    :EndSection Conga

    :Section SharpPlot

    ∇ r←{apl}LoadSharpPlot(minver target);nc;version
    ⍝ note that ns may be an array of references
     
      HASDOTNET←HasDotNet
      CAUSEWAY←⎕NULL       ⍝ reference to APL ⎕CY of sharpplot
     
      :If 0=⎕NC'apl' ⋄ apl←0 ⋄ :EndIf  ⍝ do not force APL unless told to
      :If HASDOTNET∧(~apl)
          target.⎕USING,←',system.drawing.dll' ',sharpplot.dll'
      :Else
          target.System.Drawing←target.System←target.Causeway←GetAplCauseway
      :EndIf
      nc←target.⎕NC⊂'Causeway.SharpPlot.Version'
      :If ¯2.6=nc  ⍝ .Net
      :OrIf ¯2.3=nc ⍝ APL post-v3.39
          version←target.Causeway.SharpPlot.Version
      :ElseIf ¯3.1=⎕NC⊂'ns.Causeway.SharpPlot.GetVersion' ⍝ APL pre-v3.39
          version←target.Causeway.SharpPlot.GetVersion
      :Else  ⍝ failed to load sharpplot !
          version←''
      :EndIf
      r←target.Causeway.SharpPlot
    ∇

    ∇ yes←HasDotNet;⎕USING;System
      ⎕USING←,','     ⍝ Ensure that System is present if at all possible
      :Trap 0 ⋄ yes←~0∊⍴⍕System.Environment.Version
      :Else ⋄ yes←0 ⋄ :EndTrap
    ∇

    ∇ ns←GetAplCauseway   ⍝ do the ⎕CT only once, if needed
      :If CAUSEWAY≡⎕NULL
          CAUSEWAY←#.(⎕NS'') ⍝ unnamed namespace in #
          CAUSEWAY.⎕CY findws'sharpplot'
      :EndIf
      ns←CAUSEWAY
    ∇

    :EndSection SharpPlot

:EndNamespace
