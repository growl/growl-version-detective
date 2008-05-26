//
//  GrowlPathUtilities.h
//  Growl
//
//  Created by Ingmar Stein on 17.04.05.
//  Copyright 2005-2006 The Growl Project. All rights reserved.
//
// This file is under the BSD License, refer to License.txt for details

@interface GrowlPathUtilities : NSObject {

}

#pragma mark Bundles

/*!	@method	growlPrefPaneBundle
 *	@abstract	Returns the Growl preference pane bundle.
 *	@discussion	First, attempts to retrieve the bundle for a running
 *	 GrowlHelperApp process using <code>runningHelperAppBundle</code>, and if
 *	 that was successful, returns the .prefpane bundle that contains it (if any).
 *	Then, if that failed, searches all installed preference panes for the Growl
 *	 preference pane.
 *	@result	The <code>NSBundle</code> for the Growl preference pane if it is
 *	 installed; <code>nil</code> otherwise.
 */
+ (NSBundle *) growlPrefPaneBundle;
/*!	@method	helperAppBundle
 *	@abstract	Returns the GrowlHelperApp bundle.
 *	@discussion	First, attempts to retrieve the bundle for a running
 *	 GrowlHelperApp process using <code>runningHelperAppBundle</code>, and
 *	 returns that if it was successful.
 *	Then, if it wasn't, searches for a Growl preference pane, and, if one is
 *	 installed, returns the GrowlHelperApp bundle inside it.
 *	@result	The <code>NSBundle</code> for GrowlHelperApp if it is present;
 *	 <code>nil</code> otherwise.
 */
+ (NSBundle *) helperAppBundle;

/*!	@method	runningHelperAppBundle
 *	@abstract	Returns the bundle for the running GrowlHelperApp process.
 *	@discussion	If GrowlHelperApp is running, returns an NSBundle for the .app 
 *	 bundle it was loaded from.
 *	If GrowlHelperApp is not running, returns <code>nil</code>.
 *	@result	The <code>NSBundle</code> for GrowlHelperApp if it is running;
 *	 <code>nil</code> otherwise.
 */
+ (NSBundle *) runningHelperAppBundle;

//Modified by PRH: Deleted a bunch of methods that I don't need in this app and that would have required a bunch more of the Growl source code to compile.

@end
