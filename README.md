# dual-camera-focus
For the Cosa lab. Takes a 2 channel image and describes how a 2-colour TIRF cameras' focus can be better aligned in 3 dimensions.

Organization of Code:

Open Focus.m. This will also open an instance of MicroManager automatically, utilizing MMsetup_javaclasspath.m
Once the MicroManager properties and GUI settings have been set, select “Run” on the GUI:

Now, Focus.m will call on evaluateFocusScript.m. This script calls on all the functions for every run. 
It will first call on splitImage.m. Once split.m is complete, it returns to evaluateFocusScript.m again.
Next, evaluateFocusScript.m will call restoreRed.m. Once restoreRed.m is complete, it returns to evaluateFocusScript.m again.
Next, evaluateFocusScript.m will call findROI for the green image. Once findROI is complete, it returns to evaluateFocusScript.m again.
Then, evaluateFocusScript.m will call findROI for the red image. Once it is complete, it return to evaluateFocusScript.m.
Next, evaluateFocusScript.m will call evaluateFocus.m. Once evaluateFocus.m is complete, the script is done running. If “Run” is selected on the GUI again, it will once again start evaluateFocusScript.m.



Focus.m/Focus.fig		    :	The GUI
MMsetup_javaclasspath.m	:	Places the MicroManager scripts in the Matlab Java Class Path so that Matlab can find it
evaluateFocusScript.m	  :	The central code of each run. Calls on all the smaller functions.
splitImage.m				    :	Takes the microscope picture and splits it into the two channels and saves them as the greed and red picture.
restoreRed.m			      :	Computes the geometric transform of the red image in order to match it to the green image. Displays the transform and the 2D offset of the red picture. Saves the new, transformed red image.
findROI.m			          :	Uses the Find Spots algorithm to detect beads in an image. To do this, it first calls generateCircles.m, intensitytrace.m, and gtr_rafa.m.
evaluateFocus.m		      :	Computes the ratio of green to red intensity. Plots the ratio over the area of the image including linear fits of the ratio over space relative to the mean ratio. Also plots the location of the Find Spots spots over the green image. 
