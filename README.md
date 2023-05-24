# image-scripts


## svg-recolor.sh
###Usage: 
```
$ svg-recolor.sh -input=<file> [-fromColor=<color>] -toColor=<color> [-skipMissing:false] [-recursive:false] [-replace:false]
```

Changes or adds colors to SVG file(s)

### Arguments:

* *-input=* File or folder you would like to process (Required)
* *-fromColor=* Color code you would like to change in file (Optional)
* *-toColor=* Color code you would like to change or add with (Required)
* *-skipMissing* If the fill pattern is not found than it skips it, assumes the next option is d
* *-recursive* Crawls the entire folder, creating the same structure in the output folder of the root provided
* *-replace* Replaces file if it exists, otherwise it skips the file (Optional)
