//
//  GVDFileFinder.m
//  Growl Version Detective
//
//  Created by Peter Hosey on 2008-07-19.
//  Copyright 2008 Peter Hosey. All rights reserved.
//

#import "GVDFileFinder.h"

@implementation GVDFileFinder

- (NSView *) view {
	if (!view) {
		NSString *viewNibName = [self viewNibName];
		if (!viewNibName) {
			NSLog(@"-[%@ viewNibName] returned nil—you must subclass %@ and implement this method to return a string", [self class], [GVDFileFinder class]);
		} else {
			[self viewWillLoad];
			[NSBundle loadNibNamed:viewNibName owner:self];
			[self viewDidLoad];

			if (!view)
				NSLog(@"WARNING: Loaded view nib named %@, but view is still nil!", viewNibName);
		}
	}

	return view;
}

- (NSString *) localizedTabTitle {
	NSLog(@"WARNING: Abstract method %s called!", __PRETTY_FUNCTION__);
	return nil;
}
- (NSString *) viewNibName {
	NSLog(@"WARNING: Abstract method %s called!", __PRETTY_FUNCTION__);
	return nil;
}

- (void) viewWillLoad {
}
- (void) viewDidLoad {
}
- (void) viewWillUnload {
}
- (void) viewDidUnload {
}

@end
