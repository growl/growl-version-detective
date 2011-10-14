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
	[arrayController setFilterPredicate:[NSPredicate predicateWithFormat:@"activeFrameworkVersion != nil"]];

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

#pragma mark NSTableView delegate methods

-(void) tableViewSelectionDidChange:(NSNotification *)notification {
   if([[arrayController selectedObjects] count] > 0){
      if([[[arrayController selectedObjects] objectAtIndex:0] isFrameworkPathUpgrade:nil])
         [upgradeButton setEnabled:YES];
      else
         [upgradeButton setEnabled:NO];
   }else{
      [upgradeButton setEnabled:YES];
   }
}

#pragma mark NSMetadataQuery delegate conformance

-(id) metadataQuery:(NSMetadataQuery *)aQueary replacementObjectForResultObject:(NSMetadataItem *)result {
   return [[[GVDFoundApp alloc] initWithItem:result] autorelease];
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

- (IBAction)upgradeApps:(id)sender{
   NSArray *arrayToUpgrade = nil;
   if([[arrayController selectedObjects] count] > 0)
      arrayToUpgrade = [arrayController selectedObjects];
   else
      arrayToUpgrade = [arrayController arrangedObjects];
   
   [arrayToUpgrade enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
      if([obj isKindOfClass:[GVDFoundApp class]]){
         [obj upgradeAppWithFramework:nil];
      }
   }];
}

- (IBAction)downgradeApp:(id)sender {
   if([[arrayController selectedObjects] count] > 0 && [[[arrayController selectedObjects] objectAtIndex:0] backupFramework] != nil)
      [[[arrayController selectedObjects] objectAtIndex:0] downgradeApp];
}

@end
