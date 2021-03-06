//
//  GrowlVersionDetective.m
//  Growl Version Detective
//
//  Created by Peter Hosey on 2008-05-26.
//  Copyright 2008 the Growl Project. All rights reserved.
//

#import "GrowlVersionDetective.h"

#import "GVDFoundApp.h"
#import "GVDFileFinder.h"

#import "GrowlFrameworkFinder.h"
#import "GrowlPrefPaneFinder.h"

#import "GrowlPathUtilities.h"

@implementation GrowlVersionDetective

- init {
	if((self = [super init])) {
		fileFinders = [[NSMutableArray alloc] init];
	}
	return self;
}
- (void) dealloc {
	[fileFinders release];
	[super dealloc];
}

- (void) awakeFromNib {
	static BOOL nibIsLoaded = NO;
	if (!nibIsLoaded) {
		nibIsLoaded = YES;
		[NSBundle loadNibNamed:@"GrowlVersionDetective" owner:self];
	} else {
		[self addFileFinder:[[[GrowlPrefPaneFinder alloc] init] autorelease]];
		[self addFileFinder:[[[GrowlFrameworkFinder alloc] init] autorelease]];

		//Force-load the first view.
		//[[tabView tabViewItemAtIndex:0U] setView:[[fileFinders objectAtIndex:0U] view]];
      [tabView selectTabViewItemAtIndex:0];
	}
}

- (void) addFileFinder:(GVDFileFinder *)finder {
	if ([finder localizedTabTitle]) {
		NSUInteger idx = [fileFinders indexOfObjectIdenticalTo:finder];
		if (idx == NSNotFound) {
			[fileFinders addObject:finder];

			NSTabViewItem *item = [[[NSTabViewItem alloc] initWithIdentifier:[finder description]] autorelease];
			[item setLabel:[finder localizedTabTitle]];
			[tabView addTabViewItem:item];
		}
	}
}
- (void) removeFileFinder:(GVDFileFinder *)finder {
	unsigned idx = [fileFinders indexOfObjectIdenticalTo:finder];
	if (idx != NSNotFound) {
		[fileFinders removeObjectAtIndex:idx];

		[tabView removeTabViewItem:[tabView tabViewItemAtIndex:idx]];
	}
}

#pragma mark NSApplication delegate conformance

- (BOOL) applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)app {
	return YES;
}
- (void) applicationWillTerminate:(NSNotification *)notification {
	//Loop through views, unloading them all
	unsigned i = [tabView numberOfTabViewItems] - 1U;
	NSEnumerator *fileFindersEnum = [fileFinders reverseObjectEnumerator];
	GVDFileFinder *finder;
	while ((finder = [fileFindersEnum nextObject])) {
		NSTabViewItem *item = [tabView tabViewItemAtIndex:i--];
		[finder viewWillUnload];
		[tabView removeTabViewItem:item];
		[finder viewDidUnload];
	}

	[mainWindow close];
	[mainWindow release];
	mainWindow = nil;
}

#pragma mark NSApplication delegate conformance

- (void)tabView:(NSTabView *)thisTabView willSelectTabViewItem:(NSTabViewItem *)tabViewItem {
	GVDFileFinder *finder = [fileFinders objectAtIndex:[tabView indexOfTabViewItem:tabViewItem]];

	//NSTabViewItem will make up an NSView for us, so we can't test whether the tab view item's view is nil.
	//Therefore, we just blindly set the view every time. Since GVDFileFinder keeps the view in an ivar, this should not be noticeably inefficient.
	[tabViewItem setView:[finder view]];
}

@end
