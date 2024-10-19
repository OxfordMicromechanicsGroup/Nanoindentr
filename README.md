# Nanoindentr
Written and developed by Robin J Scales.

## Step 1 Nanoindentr.m
- 1: Convert *.xls files to *.xlsx as this works much better with MATLAB importing.
- 2: Nanoindentr.m takes in the *.xlsx files and bins them with the x-variable (e.g. depth) to get a statistical average and uncertainty as a function of depth.
- 3: It takes in multiple sheets and files and analyses it all, then saves it as one file and exports it as a *.mat file.
- 4: **CalculateStressStrain** should be _true_ if using spherical tips and _false_ if not. This uses spherical nanoindentation data and converts the data into stress and strain.
- 5: **GUI_on_off** should be _true_ if you want to select the files to process using the file dialogue OR _false_ if you want to paste the full paths into _filepaths_.
- 6: The code is not annotated fully, but I aim to do so further. The key parts are, though.

## Step 2 Nanoindentr_Plotting.m
- 1: The *.mat files produced by **Nanoindentr.m** can be loaded into this, labels & colours specified, and then nice aesthetic plots of the data can be made.
- 2: Each file is essentially 1 sample and/or condition. Hence, they can be compared nicely.

If you have any other questions, feel free to contact me on GitHub, ResearchGate, or LinkedIn.
Robin Scales (C)
