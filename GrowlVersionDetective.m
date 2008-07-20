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
		id foo = [[[GrowlFrameworkFinder alloc] init] autorelease];
		NSLog(@"Adding file-finder: %@", foo);
		[self addFileFinder:foo];

//		[self addFileFinder:[[[GrowlFrameworkFinder alloc] init] autorelease]];

		//Force-load the first view.
		[[tabView tabViewItemAtIndex:0U] setView:[[fileFinders objectAtIndex:0U] view]];
	}
}

- (void) addFileFinder:(GVDFileFinder *)finder {
	NSLog(@"Tab title: %@", [finder localizedTabTitle]);
	if ([finder localizedTabTitle]) {
		unsigned idx = [fileFinders indexOfObjectIdenticalTo:finder];
		NSLog(@"Index of file-finder in array %p of them: %u (NSNotFound = %u)", fileFinders, idx, NSNotFound);
		if (idx == NSNotFound) {
			[fileFinders addObject:finder];

			NSTabViewItem *item = [[[NSTabViewItem alloc] initWithIdentifier:[finder description]] autorelease];
			[item setLabel:[finder localizedTabTitle]];
			NSLog(@"Adding tab view item: %@ to tab view: %@", item, tabView);
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
		NSTabViewItem *item = [tabView tabViewItemAtIndex:i];
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

	if (![tabViewItem view])
		[tabViewItem setView:[finder view]];
}

@end
