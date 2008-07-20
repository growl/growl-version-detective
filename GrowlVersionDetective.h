//
//  GrowlVersionDetective.h
//  Growl Version Detective
//
//  Created by Peter Hosey on 2008-05-26.
//  Copyright 2008 the Growl Project. All rights reserved.
//

@class GVDFileFinder;

@interface GrowlVersionDetective : NSObject {
	IBOutlet NSWindow *mainWindow;
	IBOutlet NSTabView *tabView;
	NSMutableArray *fileFinders;
}

- (void) addFileFinder:(GVDFileFinder *)finder;
- (void) removeFileFinder:(GVDFileFinder *)finder;

@end
