//
//  GrowlVersionDetective.m
//  Growl Version Detective
//
//  Created by Peter Hosey on 2008-05-26.
//  Copyright 2008 Peter Hosey. All rights reserved.
//

#import "GrowlVersionDetective.h"

#import "GVDFoundApp.h"

@implementation GrowlVersionDetective

- (void) awakeFromNib {
	static BOOL nibIsLoaded = NO;
	if (!nibIsLoaded) {
		nibIsLoaded = YES;
		[NSBundle loadNibNamed:@"GrowlVersionDetective" owner:self];
	} else {
	}
}

#pragma mark NSApplication delegate conformance

- (void) applicationDidFinishLaunching:(NSNotification *)notification {
	[self willChangeValueForKey:@"query"];
	query = [[NSMetadataQuery alloc] init];
	NSLog(@"Setting predicate");
	[query setPredicate:[NSPredicate predicateWithFormat:@"(kMDItemContentType = 'com.apple.application-bundle')"]];
	[query setDelegate:self];
	[self  didChangeValueForKey:@"query"];

	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(gatheringResults:)
												 name:NSMetadataQueryGatheringProgressNotification
											   object:query];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(liveUpdate:)
												 name:NSMetadataQueryDidUpdateNotification
											   object:query];
	[query startQuery];
	NSLog(@"query is gathering: %@", [query isGathering] ? @"YES" : @"NO");
}
- (BOOL) applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)app {
	return YES;
}
- (void) applicationWillTerminate:(NSNotification *)notification {
	[query stopQuery];
	[mainWindow close];
	[mainWindow release];
	mainWindow = nil;

	[query release];
	query = nil;
}

- (void) gatheringResults:(NSNotification *)notification {
	NSLog(@"query results: %@", [query results]);
}
- (void) liveUpdate:(NSNotification *)notification {
//	NSLog(@"query results: %@", [query results]);
}

#pragma mark NSMetadataQuery delegate conformance

- metadataQuery:(NSMetadataQuery *)query replacementObjectForResultObject:(NSMetadataItem *)result {
	return [[[GVDFoundApp alloc] initWithPath:[result valueForAttribute:(NSString *)kMDItemPath]] autorelease];
}

#pragma mark Accessors

- (NSMetadataQuery *) query {
	return query;
}

#pragma mark Actions

- (IBAction) revealSelectionInWorkspace:sender {
	NSWorkspace *wksp = [NSWorkspace sharedWorkspace];

	NSEnumerator *pathsEnum = [[[arrayController selection] valueForKey:@"path"] objectEnumerator];
	NSString *path;
	while ((path = [pathsEnum nextObject])) {
		[wksp selectFile:path inFileViewerRootedAtPath:@""];
	}
}

@end
