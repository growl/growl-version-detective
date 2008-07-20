//
//  GrowlPrefPaneFinder.h
//  Growl Version Detective
//
//  Created by Peter Hosey on 2008-07-07.
//  Copyright 2008 Peter Hosey. All rights reserved.
//

#import "GVDFileFinder.h"

@interface GrowlPrefPaneFinder : GVDFileFinder {
	NSString *pathToHomeGrowl, *pathToLocalGrowl, *pathToNetworkGrowl;
	NSString *versionNumberOfHomeGrowl, *versionNumberOfLocalGrowl, *versionNumberOfNetworkGrowl;
}

- (NSString *) versionNumberOfHomeGrowl;
- (NSString *) versionNumberOfLocalGrowl;
- (NSString *) versionNumberOfNetworkGrowl;

- (IBAction) moveHomeGrowlToTrash:sender;
- (IBAction) moveLocalGrowlToTrash:sender;
- (IBAction) moveNetworkGrowlToTrash:sender;

@end
