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

@synthesize results;
@synthesize queryIndicator;

- (NSString *) localizedTabTitle {
	return NSLocalizedString(@"Framework", /*comment*/ @"Tab title");
}
- (NSString *) viewNibName {
	return @"GrowlFrameworkFinder";
}

- (void) viewDidLoad {
	//[arrayController setFilterPredicate:[NSPredicate predicateWithFormat:@"activeFrameworkVersion != nil"]];

	[self willChangeValueForKey:@"query"];
	query = [[NSMetadataQuery alloc] init];
	[query setPredicate:[NSPredicate predicateWithFormat:@"(kMDItemContentType = 'com.apple.application-bundle')"]];
	[arrayController setSortDescriptors:[NSArray arrayWithObject:[[[NSSortDescriptor alloc] initWithKey:@"appName" ascending:YES selector:@selector(localizedCompare:)] autorelease]]];
	[query setDelegate:self];
	[self  didChangeValueForKey:@"query"];
   
   results = [[NSMutableArray alloc] init];

   [queryIndicator startAnimation:self];
   __block NSProgressIndicator *indicator = queryIndicator;
   [[NSNotificationCenter defaultCenter] addObserverForName:NSMetadataQueryDidFinishGatheringNotification
                                                     object:query
                                                      queue:[NSOperationQueue mainQueue]
                                                 usingBlock:^(NSNotification *note) {
                                                    [indicator stopAnimation:nil];
                                                 }];
	[query startQuery];
}
- (void) viewWillUnload {
   [[NSNotificationCenter defaultCenter] removeObserver:self
                                                   name:NSMetadataQueryDidFinishGatheringNotification
                                                 object:query];
	[query stopQuery];
	[view release];
	view = nil;

	[query release];
	query = nil;
   
   [results release];
   results = nil;
}

#pragma mark NSTableView delegate methods

-(void) tableViewSelectionDidChange:(NSNotification *)notification {
   if([[arrayController selectedObjects] count] > 0){
      GVDFoundApp *app = [[arrayController selectedObjects] objectAtIndex:0];
      if([app canUpgrade] && [app isFrameworkPathUpgrade:nil])
         [upgradeButton setEnabled:YES];
      else
         [upgradeButton setEnabled:NO];
   }else{
      [upgradeButton setEnabled:NO];
   }
}

#pragma mark NSMetadataQuery delegate conformance

-(id) metadataQuery:(NSMetadataQuery *)aQueary replacementObjectForResultObject:(NSMetadataItem *)result {
   dispatch_async(dispatch_get_main_queue(), ^(void) {
      GVDFoundApp *app = [[GVDFoundApp alloc] initWithItem:result];
      if([app activeFramework] != nil){
         [self willChangeValueForKey:@"results"];
         [results addObject:app];
         [self didChangeValueForKey:@"results"];
      }
      [app release];
   });
   return nil;
}

#pragma mark Accessors

- (NSString *) growlVersion {
	NSBundle *bundle = [GrowlPathUtilities runningHelperAppBundle];
   if(bundle)
      return [bundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
   else
      return @"not running";
}
- (NSMetadataQuery *) query {
	return query;
}

- (void) upgradeSelected
{
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

#pragma mark Actions

- (IBAction) revealGrowlPrefPaneInWorkspace:sender {
	[[NSWorkspace sharedWorkspace] selectFile:[[GrowlPathUtilities runningHelperAppBundle] bundlePath] inFileViewerRootedAtPath:@""];
}
- (IBAction) revealSelectionInWorkspace:sender {
	[[NSWorkspace sharedWorkspace] selectFile:[[arrayController selection] valueForKey:@"path"] inFileViewerRootedAtPath:@""];
}

- (IBAction)upgradeApps:(id)sender {
   NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
   if(![defaults valueForKey:@"UpgradeWarningDisable"] || ![defaults boolForKey:@"UpgradeWarningDisable"]){
      NSAlert *alert = [NSAlert alertWithMessageText:@"Warning!" 
                                       defaultButton:@"Ok" 
                                     alternateButton:@"Cancel" 
                                         otherButton:nil 
                           informativeTextWithFormat:@"Upgrading the framework in an application might make it so that the app can talk more reliably with more modern versions of Growl\nHowever, it might also cause instability in that application.  If you need to revert, the original framework is kept alongside the old one, and we offer a revert function"];
      [alert setShowsSuppressionButton:YES];
      int result = [alert runModal];
      if(result != NSAlertDefaultReturn)
         return;
      
      if([[alert suppressionButton] state] == NSOnState)
         [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"UpgradeWarningDisable"];
   }
   [self upgradeSelected];
}

- (IBAction)downgradeApp:(id)sender {
   if([[arrayController selectedObjects] count] > 0 && [[[arrayController selectedObjects] objectAtIndex:0] backupFramework] != nil)
      [[[arrayController selectedObjects] objectAtIndex:0] downgradeApp];
}

@end
