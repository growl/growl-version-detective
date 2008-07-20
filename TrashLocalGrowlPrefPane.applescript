-- TrashLocalGrowlPrefPane.applescript
-- Growl Version Detector

--  Created by Peter Hosey on 2008-07-08.
--  Copyright 2008 Peter Hosey. All rights reserved.
tell application "Finder"
	activate
	move file "Growl.prefPane" in folder "PreferencePanes" in folder "Library" in startup disk to trash
end tell
