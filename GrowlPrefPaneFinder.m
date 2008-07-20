//
//  GrowlPrefPaneFinder.m
//  Growl Version Detective
//
//  Created by Peter Hosey on 2008-07-07.
//  Copyright 2008 Peter Hosey. All rights reserved.
//

#import "GrowlPrefPaneFinder.h"

#import <OSAKit/OSAKit.h>

@implementation GrowlPrefPaneFinder

+ (void) initialize {
	if (self == [GrowlPrefPaneFinder class]) {
		[self setKeys:[NSArray arrayWithObject:@"pathToHomeGrowl"] triggerChangeNotificationsForDependentKey:@"versionNumberOfHomeGrowl"];
		[self setKeys:[NSArray arrayWithObject:@"pathToLocalGrowl"] triggerChangeNotificationsForDependentKey:@"versionNumberOfLocalGrowl"];
		[self setKeys:[NSArray arrayWithObject:@"pathToNetworkGrowl"] triggerChangeNotificationsForDependentKey:@"versionNumberOfNetworkGrowl"];
	}
}

- (NSString *) localizedTabTitle {
	return NSLocalizedString(@"Growl", /*comment*/ @"Tab title");
}
- (NSString *) viewNibName {
	return @"GrowlPrefPaneFinder";
}

- (void) dealloc {
	[pathToHomeGrowl release];
	[pathToLocalGrowl release];
	[pathToNetworkGrowl release];
	[super dealloc];
}

- (BOOL) isOnLeopardOrGreater {
	SInt32 majorVersion = 0, minorVersion = 0;
	Gestalt(gestaltSystemVersionMajor, &majorVersion);
	Gestalt(gestaltSystemVersionMinor, &minorVersion);
	return (majorVersion > 10) || (minorVersion >= 5);
}

- (void) viewWillLoad {
	NSWorkspace *wksp = [NSWorkspace sharedWorkspace];
	[[wksp iconForFile:NSHomeDirectory()] setName:@"Home"];
	[[wksp iconForFileType:NSFileTypeForHFSTypeCode(kTrashIcon)] setName:@"Trash"];
	if (![self isOnLeopardOrGreater]) {
		//Define image names that otherwise only exist on Leopard and later.
		[[wksp iconForFileType:NSFileTypeForHFSTypeCode(kComputerIcon)] setName:@"NSComputer"];
		[[wksp iconForFileType:NSFileTypeForHFSTypeCode(kGenericNetworkIcon)] setName:@"NSNetwork"];
	}
}

#pragma mark -

- (NSString *) pathToGrowlInDomain:(NSSearchPathDomainMask) domainMask {
	NSString *growlPath = nil;

	NSArray *libraries = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, domainMask, YES);
	if ([libraries count]) {
		NSFileManager *mgr = [NSFileManager defaultManager];
		BOOL isDir = NO;

		NSString *libraryPath = [libraries objectAtIndex:0U];
		NSLog(@"Library: %@", libraryPath);
		NSString *preferencePanesPath = [libraryPath stringByAppendingPathComponent:@"PreferencePanes"];
		NSLog(@"PreferencePanes: %@", preferencePanesPath);

		if ([mgr fileExistsAtPath:preferencePanesPath isDirectory:&isDir] && isDir) {
			growlPath = [preferencePanesPath stringByAppendingPathComponent:@"Growl.prefPane"];
			NSLog(@"Growl.prefPane: %@", growlPath);
			if (![mgr fileExistsAtPath:growlPath])
				growlPath = nil;
			NSLog(@"Growl.prefPane exists: %@", growlPath ? @"YES" : @"NO");
		}
	}

	return growlPath;
}

- (NSString *) pathToHomeGrowl {
	if (!pathToHomeGrowl)
		pathToHomeGrowl = [[self pathToGrowlInDomain:NSUserDomainMask] retain];
	return pathToHomeGrowl;
}
- (void) setPathToHomeGrowl:(NSString *)newPath {
	if (pathToHomeGrowl != newPath) {
		[pathToHomeGrowl release];
		pathToHomeGrowl = [newPath copy];
	}
}
- (NSString *) pathToLocalGrowl {
	if (!pathToLocalGrowl)
		pathToLocalGrowl = [[self pathToGrowlInDomain:NSLocalDomainMask] retain];
	return pathToLocalGrowl;
}
- (void) setPathToLocalGrowl:(NSString *)newPath {
	if (pathToLocalGrowl != newPath) {
		[pathToLocalGrowl release];
		pathToLocalGrowl = [newPath copy];
	}
}
- (NSString *) pathToNetworkGrowl {
	if (!pathToNetworkGrowl)
		pathToNetworkGrowl = [[self pathToGrowlInDomain:NSNetworkDomainMask] retain];
	return pathToNetworkGrowl;
}
- (void) setPathToNetworkGrowl:(NSString *)newPath {
	if (pathToNetworkGrowl != newPath) {
		[pathToNetworkGrowl release];
		pathToNetworkGrowl = [newPath copy];
	}
}

#pragma mark -

- (NSString *) versionNumberOfHomeGrowl {
	return [[NSBundle bundleWithPath:[self pathToHomeGrowl]] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
}
- (NSString *) versionNumberOfLocalGrowl {
	return [[NSBundle bundleWithPath:[self pathToLocalGrowl]] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
}
- (NSString *) versionNumberOfNetworkGrowl {
	return [[NSBundle bundleWithPath:[self pathToNetworkGrowl]] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
}

#pragma mark -

- (IBAction) moveHomeGrowlToTrash:sender {
	NSString *path = [self pathToHomeGrowl];

	int tag = 0;
	[[NSWorkspace sharedWorkspace] performFileOperation:NSWorkspaceRecycleOperation
												 source:[path stringByDeletingLastPathComponent]
											destination:@""
												  files:[NSArray arrayWithObject:[path lastPathComponent]]
													tag:&tag];

	[self setPathToHomeGrowl:[self pathToGrowlInDomain:NSUserDomainMask]];
}
- (IBAction) moveLocalGrowlToTrash:sender {
	NSString *scriptPath = [[NSBundle mainBundle] pathForResource:@"TrashLocalGrowlPrefPane" ofType:@"applescript"];

	NSDictionary *errorDict = nil;
	OSAScript *script = [[[OSAScript alloc] initWithContentsOfURL:[NSURL fileURLWithPath:scriptPath] error:&errorDict] autorelease];
	[script executeAndReturnError:&errorDict];

	[self setPathToLocalGrowl:[self pathToGrowlInDomain:NSLocalDomainMask]];
}
- (IBAction) moveNetworkGrowlToTrash:sender {
	NSString *path = [self pathToNetworkGrowl];

	int tag = 0;
	[[NSWorkspace sharedWorkspace] performFileOperation:NSWorkspaceRecycleOperation
												 source:[path stringByDeletingLastPathComponent]
											destination:@""
												  files:[NSArray arrayWithObject:path]
													tag:&tag];

	[self setPathToNetworkGrowl:[self pathToGrowlInDomain:NSNetworkDomainMask]];
}

@end
