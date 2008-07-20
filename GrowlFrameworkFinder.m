//
//  GrowlFrameworkFinder.m
//  Growl Version Detective
//
//  Created by Peter Hosey on 2008-07-19.
//  Copyright 2008 Peter Hosey. All rights reserved.
//

#import "GrowlFrameworkFinder.h"

#import "GVDFoundApp.h"
#import "GrowlPathUtilities.h"

@implementation GrowlFrameworkFinder

- (NSString *) localizedTabTitle {
	return NSLocalizedString(@"Framework", /*comment*/ @"Tab title");
}
- (NSString *) viewNibName {
	return @"GrowlFrameworkFinder";
}

- (void) viewDidLoad {
	[arrayController setFilterPredicate:[NSPredicate predicateWithFormat:@"growlFrameworkVersion != nil"]];

	[self willChangeValueForKey:@"query"];
	query = [[NSMetadataQuery alloc] init];
	[query setPredicate:[NSPredicate predicateWithFormat:@"(kMDItemContentType = 'com.apple.application-bundle')"]];
	[query setSortDescriptors:[NSArray arrayWithObject:[[[NSSortDescriptor alloc] initWithKey:(NSString *)kMDItemDisplayName ascending:YES selector:@selector(localizedCompare:)] autorelease]]];
	[query setDelegate:self];
	[self  didChangeValueForKey:@"query"];

	[query startQuery];
}
- (void) viewWillUnload {
	[query stopQuery];
	[view release];
	view = nil;

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
	[[NSWorkspace sharedWorkspace] selectFile:[[arrayController selection] valueForKey:@"path"] inFileViewerRootedAtPath:@""];
}

@end
