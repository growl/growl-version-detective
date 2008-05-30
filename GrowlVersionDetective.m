//
//  GrowlVersionDetective.m
//  Growl Version Detective
//
//  Created by Peter Hosey on 2008-05-26.
//  Copyright 2008 the Growl Project. All rights reserved.
//

#import "GrowlVersionDetective.h"

#import "GVDFoundApp.h"

#import "GrowlPathUtilities.h"

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
	[query setPredicate:[NSPredicate predicateWithFormat:@"(kMDItemContentType = 'com.apple.application-bundle')"]];
	[query setSortDescriptors:[NSArray arrayWithObject:[[[NSSortDescriptor alloc] initWithKey:(NSString *)kMDItemDisplayName ascending:YES selector:@selector(localizedCompare:)] autorelease]]];
	[query setDelegate:self];
	[self  didChangeValueForKey:@"query"];

	[query startQuery];

	[arrayController setFilterPredicate:[NSPredicate predicateWithFormat:@"growlFrameworkVersion != nil"]];
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

#pragma mark NSMetadataQuery delegate conformance

- metadataQuery:(NSMetadataQuery *)query replacementObjectForResultObject:(NSMetadataItem *)result {
	return [[[GVDFoundApp alloc] initWithPath:[result valueForAttribute:(NSString *)kMDItemPath]] autorelease];
}

#pragma mark Accessors

- (NSString *) growlVersion {
	NSBundle *bundle = [GrowlPathUtilities growlPrefPaneBundle];
	return [bundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
}
- (NSMetadataQuery *) query {
	return query;
}

#pragma mark Actions

- (IBAction) revealGrowlPrefPaneInWorkspace:sender {
	[[NSWorkspace sharedWorkspace] selectFile:[[GrowlPathUtilities growlPrefPaneBundle] bundlePath] inFileViewerRootedAtPath:@""];
}
- (IBAction) revealSelectionInWorkspace:sender {
	[[NSWorkspace sharedWorkspace] selectFile:[arrayController selection] inFileViewerRootedAtPath:@""];
}

@end
