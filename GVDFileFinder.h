//
//  GVDFileFinder.h
//  Growl Version Detective
//
//  Created by Peter Hosey on 2008-07-19.
//  Copyright 2008 Peter Hosey. All rights reserved.
//

/*A file finder is a module that goes into the Growl Version Detective's tab view.
 *Each file finder has a view and a title, which the GVD attaches to the tab view item.
 */

@interface GVDFileFinder : NSObject {
	IBOutlet NSView *view;
}

- (NSView *) view;

//Abstract—must be overridden by subclasses.
- (NSString *) localizedTabTitle;
//You can skip overriding -viewNibName only if you override -view instead.
- (NSString *) viewNibName;

//Abstract—can be overridden by subclasses.
- (void) viewWillLoad;
- (void) viewDidLoad;
- (void) viewWillUnload;
- (void) viewDidUnload;

@end
