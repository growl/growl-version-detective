//
//  GVDFoundApp.m
//  Growl Version Detective
//
//  Created by Peter Hosey on 2008-05-26.
//  Copyright 2008 the Growl Project. All rights reserved.
//

#import "GVDFoundApp.h"

@implementation GVDFoundApp

- initWithPath:(NSString *)newPath {
	if ((self = [super init])) {
		path = [newPath copy];
	}
	return self;
}
- (void) dealloc {
	[path release];
	[super dealloc];
}

- (NSString *) description {
	return [NSString stringWithFormat:@"<%@ %p: %@>", [self class], self, path];
}

#pragma mark Accessors

- (NSImage  *) applicationIcon {
	return [[NSWorkspace sharedWorkspace] iconForFile:path];
}
- (NSString *) localizedApplicationName {
	return [[NSFileManager defaultManager] displayNameAtPath:path];
}
- (NSString *) applicationVersion {
	NSBundle *bundle = [NSBundle bundleWithPath:path];
	NSString *version = [bundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
	if (!version)
		version = [bundle objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];
	return version;
}
- (NSString *) growlFrameworkVersion {
	return [[NSBundle bundleWithPath:[[[path stringByAppendingPathComponent:@"Contents"] stringByAppendingPathComponent:@"Frameworks"] stringByAppendingPathComponent:@"Growl.framework"]] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
}
- (NSString *) path {
	return path;
}

@end
