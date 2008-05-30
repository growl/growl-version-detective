//
//  GVDFoundApp.h
//  Growl Version Detective
//
//  Created by Peter Hosey on 2008-05-26.
//  Copyright 2008 the Growl Project. All rights reserved.
//

@interface GVDFoundApp : NSObject {
	NSString *path;
}

- initWithPath:(NSString *)path;

#pragma mark Accessors

- (NSImage  *) applicationIcon;
- (NSString *) localizedApplicationName;
- (NSString *) applicationVersion;
- (NSString *) growlFrameworkVersion;
- (NSString *) path;

@end
