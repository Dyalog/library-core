# APLProcess

This will contain the documentation for the APLProcess tool.

Example of use:

          ]load APLProcess
	#.APLProcess
	      proc←⎕NEW APLProcess ('dfns.dws' 'MAXWS=200M' 0)
          proc.HasExited
    0