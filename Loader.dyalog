:Namespace Loader

    lc←0∘(819⌶) ⍝ lowercase

    ∇ r←Init args;module;rarg;larg;minver;target
     ⍝ Initialise a Core Dyalog Application Component
     ⍝ args[1] - or simple argument: Conga|SQAPL|SharpPlot (more to come)
     ⍝ The rest are optional
     ⍝ args[2] - right argument to Init function of the component (default = '')
     ⍝     [3] - left argument to Init function (missing or '' = monadic call)
     ⍝     [4] - Minimum version required in the form (major minor svnrev)
     ⍝     [5] - Terget namespace to materialise namespaces or classes in (default = #)
     
      (module rarg larg minver target)←{⍵,(≢⍵)'' '' ''(0 0 0)#}↓,⊆args
     
      :Trap 999
          r←Load args[1 4 5]
      :Else
          (⊃⎕DMX.DM)⎕SIGNAL ⎕DMX.EN
      :EndTrap
    ∇

    ∇ r←Load args;module;minver;target
     ⍝ Load, but do not initialise a Core Dyalog Application Component
     ⍝ args[1] - or simple argument: Conga|SQAPL|SharpPlot (more to come)
     ⍝ The rest are optional
     ⍝     [2] - Minimum version required in the form (major minor svnrev)
     ⍝     [3] - Terget namespace to materialise namespaces or classes in (default = #)
      (module minver target)←{⍵,(≢⍵)↓''(0 0 0)#}←,⊆args
      DYALOG←{⍵,'/'↓⍨'/\'∊⍨¯1↑⍵}2 ⎕NQ'.' 'GetEnvironment' 'DYALOG'
     
      :Select lc module
      :Case 'conga'
          r←LoadConga minver target
      :Case 'sqapl'
          ∘∘∘
      :Case 'sharpplot'
          ∘∘∘
      :Case 'rconnect'
          ∘∘∘
      :Else
          ('Unknown module: ',module)⎕SIGNAL 6
      :EndSelect
    ∇

    :Section Conga

    ∇ r←LoadConga(minver target);ns;m;nss;copied
      
      r←copied←''
      
      :If ∨/m←0≠target.⎕NC nss←'Conga' 'DRC'
          r←target⍎ns←(m⍳1)⊃nss
      :Else
          :For ns :In nss
              :Trap 0
                  ns target.⎕CY'ws/conga.dws'
                  copied←'copied from ws/conga.dws'
                  r←target⍎ns ⋄ :Leave
              :EndTrap
          :EndFor
      :EndIf                          
      :If r≢''
          ('LoadConga: unable to copy ',ns) ⎕SIGNAL 11
      :EndIf           
      :If ~r.Version ge minver
          ('LoadConga: ',ns,copied,' has version ',⍕minver) ⎕SIGNAL 11
      :EndIf
     
     
      :If ''≡{6::⍵ ⋄ LDRC}'' ⍝ if LDRC exists, we assume Conga has been initialized and just carry on
          :If ~0∊⍴CongaRef  ⍝ did the user supply a reference to Conga?
              →0⍴⍨''≡LDRC←ResolveCongaRef CongaRef
          :Else
              ref nc←{1↑¨⍵{(×⍵)∘/¨⍺ ⍵}#.⎕NC ⍵}ns←'Conga' 'DRC'
              :Select ⊃⌊nc
              :Case 9
                  →0⍴⍨''≡LDRC←ResolveCongaRef'#.',∊ref
              :Case 0
                  class←⊃⊃⎕CLASS ⎕THIS
                  congaCopied←0
                  :For n :In ns
                      :Trap 0
                          n class.⎕CY dyalog,'ws/conga'
                          →0⍴⍨''≡LDRC←ResolveCongaRef class⍎n
                          congaCopied←1
                          :Leave
                      :EndTrap
                  :EndFor
                  :If ~congaCopied
                      ⎕←'*** Neither Conga nor DRC was found'
                      →0
                  :EndIf
              :Else
                  ⎕←'*** Neither Conga nor DRC was found'
                  →0
              :EndSelect
          :EndIf
      :EndIf
    ∇

    ∇ LDRC←ResolveCongaRef CongaRef;z
    ⍝ CongaRef could be a charvec, reference to the Conga or DRC namespaces, or reference to an iConga instance
      :Access public shared  ⍝!!! testing only  - remove :Access after testing
      LDRC←''
      :Select ⎕NC⊂'CongaRef' ⍝ what is it?
      :Case 9.1 ⍝ namespace?  e.g. CongaRef←DRC or Conga
          :If 0≡⊃z←CongaRef.Init'' ⍝ DRC?
              LDRC←CongaRef
              {}LDRC.Init''
          :ElseIf 9.2=⎕NC⊂,'z'    ⍝ Conga?
              LDRC←z
          :EndIf
      :Case 9.2 ⍝ instance?  e.g. CongaRef←Conga.Init ''
          LDRC←CongaRef ⍝ an instance is already initialized
      :Case 2.1 ⍝ variable?  e.g. CongaRef←'#.Conga'
          :Trap 0
              LDRC←ResolveCongaRef(⍎∊⍕CongaRef)
          :EndTrap
      :EndSelect
      :If ''≡LDRC
          ⎕←'*** CongaRef "',(∊⍕CongaRef),'" does not refer to a valid object.'
      :EndIf
    ∇


    :EndSection Conga

    :Section SharpPlot

    ∇ yes←HasDotNet;⎕USING;System
      ⎕USING←,','     ⍝ Ensure that System is present if at all possible
      :Trap 0 ⋄ yes←~0∊⍴⍕System.Environment.Version
      :Else ⋄ yes←0 ⋄ :EndTrap
    ∇

    ∇ ns←GetAplCauseway   ⍝ do the ⎕CT only once, if needed
      :If CAUSEWAY≡⎕NULL
          CAUSEWAY←#.(⎕NS'') ⍝ unnamed namespace in #
          CAUSEWAY.⎕CY'sharpplot.dws'
      :EndIf
      ns←CAUSEWAY
    ∇


    ∇ {version}←{apl}InitSharpPlot ns;nc
    ⍝ note that ns may be an array of references
     
      HASDOTNET←HasDotNet  ⍝ cached at fix time
      CAUSEWAY←⎕NULL  ⍝ reference to APL ⎕CY of sharpplot
     
      :If 0=⎕NC'apl' ⋄ apl←0 ⋄ :EndIf  ⍝ do not force APL unless told to
      :If HASDOTNET∧(~apl)
          ns.⎕USING,←',system.drawing.dll' ',sharpplot.dll'
      :Else
          ns.System.Drawing←ns.System←ns.Causeway←GetAplCauseway
      :EndIf
      nc←⎕NC⊂'ns.Causeway.SharpPlot.Version'
      :If ¯2.6=nc  ⍝ .Net
      :OrIf ¯2.3=nc ⍝ APL post-v3.39
          version←ns.Causeway.SharpPlot.Version
      :ElseIf ¯3.1=⎕NC⊂'ns.Causeway.SharpPlot.GetVersion' ⍝ APL pre-v3.39
          version←ns.Causeway.SharpPlot.GetVersion
      :Else  ⍝ failed to load sharpplot !
          version←''
      :EndIf
    ∇


    :EndSection SharpPlot

:EndNamespace
