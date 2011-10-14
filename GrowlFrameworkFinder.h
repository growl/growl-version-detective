//
//  GrowlFrameworkFinder.h
//  Growl Version Detective
//
//  Created by Peter Hosey on 2008-07-19.
//  Copyright 2008 Peter Hosey. All rights reserved.
//

#import "GVDFileFinder.h"

@interface GrowlFrameworkFinder : GVDFileFinder {
	IBOutlet NSArrayController *arrayController;
   IBOutlet NSButton *upgradeButton;

	NSMetadataQuery *query;
}

- (NSString *) growlVersion;
- (NSMetadataQuery *) query;

- (IBAction) revealGrowlPrefPaneInWorkspace:sender;
- (IBAction) revealSelectionInWorkspace:sender;

@end
