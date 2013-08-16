-- Running this script once will register a Growl notification.

-- check if Growl is running
tell application "System Events"
	set growlIsRunning to (count of (every process whose bundle identifier is "com.Growl.GrowlHelperApp")) > 0
end tell
-- register a Growl notification
if growlIsRunning then
	tell application id "com.Growl.GrowlHelperApp"
		register as application "arXiver script" all notifications {"archived"} default notifications {"archived"} icon of application "Preview"
	end tell
end if

-- This is called when items are added to the watched folder.
on adding folder items to this_folder after receiving added_items
	
	-- change 'destination' to where you want to move the rename pdf
	set destination to "Root:Users:Teake:Dropbox:Papers:"
	
	-- don't change this
	set arxivURLprefix to "http://arxiv.org/pdf/"
	set tid to AppleScript's text item delimiters
	
	try
		-- loop over the added items
		repeat with currentFile in added_items
			
			-- fake repeat so we can simulate a continue' with 'exit repeat'
			repeat 1 times
				
				tell application "Finder"
					set fullName to (the name of currentFile)
					set fileExtension to (the name extension of currentFile)
				end tell
				
				-- if it's not a pdf then continue with the next item in the repeat
				if (fileExtension is not "pdf") then
					exit repeat
				end if
				
				tell application "Preview"
					activate
					open currentFile
				end tell
				
				-- get the whereFroms metadata with mdls
				set whereFroms to do shell script "mdls -name kMDItemWhereFroms " & (quoted form of POSIX path of currentFile)
				if (whereFroms is "kMDItemWhereFroms = (null)") then
					exit repeat
				end if
				-- strip the "kMDItemWhereFroms = (" and ")"
				set whereFroms to text 27 thru -2 of whereFroms
				-- read off the first item of the whereFroms list
				set AppleScript's text item delimiters to ","
				set whereFrom to text 2 thru -2 of text item 1 of whereFroms
				set AppleScript's text item delimiters to tid
				
				-- return if the file is not downloaded from arXiv
				if (length of whereFrom is less than length of arxivURLprefix) then
					exit repeat
				end if
				if (text 1 thru (length of arxivURLprefix) of whereFrom is not arxivURLprefix) then
					exit repeat
				end if
				
				-- strip the arxiv prefix url and the .pdf
				set fileName to text ((length of arxivURLprefix) + 1) thru -5 of whereFrom
				
				-- get info from arXiv API
				set arXivUrl to "http://export.arxiv.org/api/query?id_list=" & fileName & "&start=0&max_results=1"
				set arxivData to do shell script "curl " & arXivUrl
				
				-- parse XML
				set theXML to parse XML arxivData
				if getElementValue(getAnElement(theXML, "totalResults")) is not "1" then
					exit repeat
				end if
				
				set paperXML to getAnElement(theXML, "entry")
				set paperTitle to getElementValue(getAnElement(paperXML, "title"))
				set paperDate to text 1 thru 4 of getElementValue(getAnElement(paperXML, "published"))
				set paperAuthorsXML to getElements(paperXML, "author")
				set paperAuthors to {}
				set AppleScript's text item delimiters to " "
				repeat with authorXML in paperAuthorsXML
					set authorFull to getElementValue(getAnElement(authorXML, "name"))
					set authorLast to last item of text items of authorFull
					copy authorLast to end of paperAuthors
				end repeat
				set AppleScript's text item delimiters to ", "
				set paperAuthors to (paperAuthors as text)
				set AppleScript's text item delimiters to ""
				
				-- create filename
				set newName to fileName & " " & paperAuthors & " - " & paperTitle & ".pdf"
				--check for illegal characters (":" and "/")
				set AppleScript's text item delimiters to ":"
				set nameList to text items of newName
				set AppleScript's text item delimiters to "_"
				set newName to (nameList as text)
				set AppleScript's text item delimiters to "/"
				set nameList to text items of newName
				set AppleScript's text item delimiters to "_"
				set newName to (nameList as text)
				set AppleScript's text item delimiters to ""
				
				-- move the file
				tell application "Finder"
					if (exists file (destination & newName)) then
						move currentFile to trash
					else
						move currentFile to destination
						set movedFile to alias (destination & fullName)
						set name of movedFile to newName
						
						--display a growl notification
						tell application "System Events"
							set growlIsRunning to Â
								(count of (every process whose bundle identifier is "com.Growl.GrowlHelperApp")) > 0
						end tell
						if growlIsRunning then
							tell application id "com.Growl.GrowlHelperApp"
								notify with name 	"archived" title "PDF archived" description (fileName & " has been archived as \"" & paperAuthors & " - " & paperTitle & "\"") application name "arXiver script" icon of application "Preview"
							end tell
						end if
						
					end if
				end tell
				
			end repeat -- fake repeat
		end repeat -- added items repeat
		
	end try
end adding folder items to


--XML helper functions below

on getElements(theXML, theElementName)
	-- find and return all instatnces of a particular element
	
	local theResult
	
	set theResult to {}
	repeat with anElement in XML contents of theXML
		if class of anElement is XML element and Â
			XML tag of anElement is theElementName then
			set end of theResult to contents of anElement
		end if
	end repeat
	
	return theResult as list
end getElements

on getElementValue(theXML)
	if theXML is missing value or theXML is {} then
		return ""
	else if class of theXML is string then
		return theXML
	else
		try
			return item 1 of XML contents of theXML
		on error number -1728
			return ""
		end try
	end if
end getElementValue

on getAnElement(theXML, theElementName)
	-- find and return a particular element (this presumes there is only one instance of the element)
	
	repeat with anElement in XML contents of theXML
		if class of anElement is XML element and Â
			XML tag of anElement is theElementName then
			return contents of anElement
		end if
	end repeat
	
	return missing value
end getAnElement