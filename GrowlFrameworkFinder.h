//
//  GrowlFrameworkFinder.h
//  Growl Version Detective
//
//  Created by Peter Hosey on 2008-07-19.
//  Copyright 2008 Peter Hosey. All rights reserved.
//

#import "GVDFileFinder.h"

@interface GrowlFrameworkFinder : GVDFileFinder <NSMetadataQueryDelegate> {
	IBOutlet NSArrayController *arrayController;
   IBOutlet NSButton *upgradeButton;
   
   NSMutableArray *results;

	NSMetadataQuery *query;
}

@property (nonatomic, retain) NSMutableArray *results;

- (NSString *) growlVersion;
- (NSMetadataQuery *) query;

- (IBAction) revealGrowlPrefPaneInWorkspace:sender;
- (IBAction) revealSelectionInWorkspace:sender;

@end
