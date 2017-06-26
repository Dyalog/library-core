# Tool

This will contain the documentation for the Tool loading utility.

Example of use:

         ]load tool
    #.Tool
         iR←Tool.New 'RConnect' ⍝ A new instance of RConnect
         1⍕iR.x'rnorm(10,100,1)'
    99.6 99.5 101.7 98.7 101.1 100.2 100.1 101.2 99.9 100.8
