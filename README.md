arXiver
=======

arXiver is an AppleScript that automatically renames and archives PDFs downloaded from arxiv.org. 

Normally, PDFs downloaded from arXiv.org have a non-descript name that corresponds to their arXiv identifier,
for example `1206.7095.pdf`. These files names are not particular well suited for searching them with Spotlight,
unless you know the identifier by heart.
arXiver renames the PDFs to `"identifier" "list of authors" - "title".pdf`, such that you can easily search
for an author or paper title with Spotlight. It also moves the renamed PDFs to a custom directory, 
displays a Growl notification doing so.


How to install
--------------

1. Download the [arXiver applescript file](https://raw.github.com/teake/arXiver/master/arXiver.applescript), 
   and open it with the AppleScript Editor. 
2. Adjust the `destination` variable to where you want to the PDFs after hey have been removed.
3. Save the script as a compiled script (the `Script` file format) in `~/Library/Scripts/Folder Action Scripts`. 
   If this directory doesn't exist, create it.
4. (Optional) Run the script once from the Applescript Editor in order to register the Growl notifications. 
5. Enable Folder Actions by right-clicking your download directory and selecting `Services -> Folder Action Setup`.` 
   Select the previously saved arXiver script and enable it.
6. Lastly, download and install the [XML Tools](http://www.latenightsw.com/freeware/xml-tools/) for AppleScript.


Limitations
-----------

arXiver determines whether a file has been downloaded from arxiv.org via its metadata. 
Because Firefox doesn't store this metadata, arXiver only works with PDFs downloaded in Safari or Chrome.
