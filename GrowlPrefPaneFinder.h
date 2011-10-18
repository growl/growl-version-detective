//
//  GrowlPrefPaneFinder.h
//  Growl Version Detective
//
//  Created by Peter Hosey on 2008-07-07.
//  Copyright 2008 Peter Hosey. All rights reserved.
//

#import "GVDFileFinder.h"

@interface GrowlPrefPaneFinder : GVDFileFinder <NSMetadataQueryDelegate> {
	NSString *pathToHomeGrowl, *pathToLocalGrowl, *pathToNetworkGrowl;
	NSString *versionNumberOfHomeGrowl, *versionNumberOfLocalGrowl, *versionNumberOfNetworkGrowl;
      
   NSMetadataQuery *query;
   NSArrayController *arrayController;
   NSMutableArray *results;
}
@property (nonatomic, retain) NSMutableArray *results;
@property (nonatomic, retain) IBOutlet NSArrayController *arrayController;

- (NSString *) versionNumberOfHomeGrowl;
- (NSString *) versionNumberOfLocalGrowl;
- (NSString *) versionNumberOfNetworkGrowl;

- (IBAction) moveHomeGrowlToTrash:sender;
- (IBAction) moveLocalGrowlToTrash:sender;
- (IBAction) moveNetworkGrowlToTrash:sender;

@end
