//
//  GrowlVersionDetective.h
//  Growl Version Detective
//
//  Created by Peter Hosey on 2008-05-26.
//  Copyright 2008 Peter Hosey. All rights reserved.
//

@interface GrowlVersionDetective : NSObject {
	IBOutlet NSWindow *mainWindow;
	IBOutlet NSArrayController *arrayController;

	NSMetadataQuery *query;
}

- (NSMetadataQuery *) query;

- (IBAction) revealSelectionInWorkspace:sender;

@end
