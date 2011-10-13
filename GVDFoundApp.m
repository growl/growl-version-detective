//
//  GVDFoundApp.m
//  Growl Version Detective
//
//  Created by Peter Hosey on 2008-05-26.
//  Copyright 2008 the Growl Project. All rights reserved.
//

#import "GVDFoundApp.h"
#import "GrowlVersionUtilities.h"

@implementation GVDFoundApp

@synthesize appBundleID;
@synthesize appVersion;
@synthesize appName;
@synthesize appIcon;
@synthesize path;

@synthesize activeFramework;
@synthesize activeFrameworkVersion;
@synthesize backupFramework;
@synthesize backupFrameworkVersion;
@synthesize frameworksDir;

@synthesize withInstaller;
@synthesize relaunchAfterUpgrade;

+ (NSString*) defaultFrameworkPath{
   static NSString *defaultPath = nil;
   if(!defaultPath){
      defaultPath = [[[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"Contents"] stringByAppendingPathComponent:@"Frameworks"];
      defaultPath = [[defaultPath stringByAppendingPathComponent:@"Growl.framework"] retain];
   }
   return defaultPath;
}

- (id) initWithItem:(NSMetadataItem*)item {
   if((self = [super init])) {
      self.path = [item valueForAttribute:(NSString*)kMDItemPath];
      self.appBundleID = [item valueForAttribute:(NSString*)kMDItemCFBundleIdentifier];
      self.appName = [item valueForAttribute:(NSString *)kMDItemDisplayName];
      self.appIcon = [[NSWorkspace sharedWorkspace] iconForFile:path];

      NSBundle *bundle = [NSBundle bundleWithPath:path];
      self.appVersion = [bundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
      if (!appVersion)
         self.appVersion = [bundle objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];;
      
      self.frameworksDir = [[path stringByAppendingPathComponent:@"Contents"] stringByAppendingPathComponent:@"Frameworks"];
      
      relaunchAfterUpgrade = NO;
      
      withInstaller = NO;
      
      /* Active framework */
      self.activeFramework = [NSBundle bundleWithPath:[frameworksDir stringByAppendingPathComponent:@"Growl.framework"]];
      if (!activeFramework) {
         self.activeFramework = [NSBundle bundleWithPath:[frameworksDir stringByAppendingPathComponent:@"Growl-WithInstaller.framework"]];
         withInstaller = YES;
      }
      if(activeFramework){
         NSString *activeVersion = [activeFramework objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
         self.activeFrameworkVersion = activeVersion;
      }else
         self.activeFrameworkVersion = nil;
      
      /* Backup framework */
      self.backupFramework = [NSBundle bundleWithPath:[frameworksDir stringByAppendingPathComponent:@"Growl.framework.bak"]];
      if (!backupFramework) {
         self.backupFramework = [NSBundle bundleWithPath:[frameworksDir stringByAppendingPathComponent:@"Growl-WithInstaller.framework.bak"]];
      }
      
      if(backupFramework){
         NSString *backupVersion = [backupFramework objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
         self.backupFrameworkVersion = backupVersion;
      }else 
         self.backupFrameworkVersion = nil;
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


- (BOOL) isAppRunning {
   return ([[NSRunningApplication runningApplicationsWithBundleIdentifier:appBundleID] count] > 0);
}

- (BOOL) isFrameworkPathUpgrade:(NSString*)newPath {
   if(!newPath)
      newPath = [GVDFoundApp defaultFrameworkPath];
   
   NSBundle *newFramework = [NSBundle bundleWithPath:newPath];
   NSString *newVersion = [newFramework objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
   if (compareVersionStrings(activeFrameworkVersion, newVersion) != NSOrderedAscending) {
      return NO;
   }
   return YES;
}

- (BOOL) preReplacement
{
   relaunchAfterUpgrade = [self isAppRunning];

   __block BOOL success = YES;
   if(relaunchAfterUpgrade){
      NSLog(@"Terminating instances of %@", appName);
      [[NSRunningApplication runningApplicationsWithBundleIdentifier:appBundleID] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
         if([obj isKindOfClass:[NSRunningApplication class]]){
            NSRunningApplication *app = (NSRunningApplication*)obj;
            if(![app terminate])
               success = NO;
         }
      }];
   }
   return success;
}

- (void) postReplacement
{
   if(relaunchAfterUpgrade){
      NSError *launchError = nil;
      [[NSWorkspace sharedWorkspace] launchApplicationAtURL:[NSURL URLWithString:path]
                                                    options:NSWorkspaceLaunchDefault
                                              configuration:nil
                                                      error:&launchError];
      if(launchError)
         NSLog(@"There was an error relaunching %@ at %@: %@", appName, path, launchError);
   }
}

- (void) upgradeAppWithFramework:(NSString *)newFWPath
{
   if(!newFWPath)
      newFWPath = [GVDFoundApp defaultFrameworkPath];
   
   if(![self isFrameworkPathUpgrade:newFWPath]){
      NSLog(@"Not replacing FW because it is not newer than");
      return;
   }
   
   NSString *frameworkPath = [activeFramework bundlePath];
   
   if(![self preReplacement]){
      NSLog(@"There was a problem quitting the application, not upgrading the FW");
      return;
   }

   //Should we move the existing aside?
   //If a backup already exists, thats the original framework, we dont want to replace it
   NSString *backupPath = [backupFramework bundlePath];
   if(backupPath != nil){
      NSError *error = nil;
      [[NSFileManager defaultManager] moveItemAtPath:frameworkPath
                                              toPath:[frameworkPath stringByAppendingString:@".bak"]
                                               error:&error];
      if(error){
         NSLog(@"Error backing up framework! %@", error);
         return;
      }
   }else{
      NSLog(@"Backup of original already found, upgrading current active framework in place");
      NSError *removeError = nil;
      [[NSFileManager defaultManager] removeItemAtPath:frameworkPath
                                                 error:&removeError];
      if(removeError){
         NSLog(@"Error removing the upgraded FW! %@", removeError);
         return;
      }
   }

   //Move the new framework into place
   NSError *error = nil;
   [[NSFileManager defaultManager] moveItemAtPath:newFWPath
                                           toPath:[frameworksDir stringByAppendingPathComponent:@"Growl.framework"] 
                                            error:&error];
   if(error){
      NSLog(@"Error moving new framework into place %@", error);
   }
   [self postReplacement];
}

- (void) downgradeApp
{
   NSString *backupPath = [backupFramework bundlePath];
   if(backupPath){
      [self preReplacement];
      
      //We will only let upgrade to Growl.framework
      NSString *upgradedFW = [frameworksDir stringByAppendingPathComponent:@"Growl.framework"];
      NSError *removeError = nil;
      [[NSFileManager defaultManager] removeItemAtPath:upgradedFW
                                                 error:&removeError];
      if(removeError){
         NSLog(@"Error removing the upgraded FW! %@", removeError);
         return;
      }
      
      NSString *newPath = [backupPath stringByDeletingPathExtension];
      NSError *moveError = nil;
      [[NSFileManager defaultManager] moveItemAtPath:backupPath
                                              toPath:newPath
                                               error:&moveError];
      if(moveError){
         NSLog(@"Error moving old framework back into place %@", moveError);
      }
      
      [self postReplacement];
   }else{
      NSLog(@"No backup framework found");
   }
}

@end
