//
//  GVDFoundApp.h
//  Growl Version Detective
//
//  Created by Peter Hosey on 2008-05-26.
//  Copyright 2011 the Growl Project. All rights reserved.
//

@interface GVDFoundApp : NSObject {
   NSString *appBundleID;
   NSString *appVersion;
   NSString *appName;
   NSImage  *appIcon;
   NSString *path;
   
   NSString *displayVersion;
   
   NSBundle *activeFramework;
   NSString *activeFrameworkVersion;
   NSBundle *backupFramework;
   NSString *backupFrameworkVersion;
	NSString *frameworksDir;
   
   NSString *upgradeString;
      
   BOOL withInstaller;
   BOOL backupWithInstaller;
   BOOL relaunchAfterUpgrade;
}
@property (nonatomic, retain) NSString *appBundleID;
@property (nonatomic, retain) NSString *appVersion;
@property (nonatomic, retain) NSString *appName;
@property (nonatomic, retain) NSImage  *appIcon;
@property (nonatomic, retain) NSString *path;

@property (nonatomic, retain) NSString *displayVersion;

@property (nonatomic, retain) NSBundle *activeFramework;
@property (nonatomic, retain) NSString *activeFrameworkVersion;
@property (nonatomic, retain) NSBundle *backupFramework;
@property (nonatomic, retain) NSString *backupFrameworkVersion;
@property (nonatomic, retain) NSString *frameworksDir;

@property (nonatomic, retain) NSString *upgradeString;

@property (nonatomic) BOOL withInstaller;
@property (nonatomic) BOOL backupWithInstaller;
@property (nonatomic) BOOL relaunchAfterUpgrade;

+ (NSString*)defaultFrameworkPath;

- (id) initWithPath:(NSString*)newPath
           bundleID:(NSString*)bundleID
            appName:(NSString*)name;
- (id) initWithItem:(NSMetadataItem*)item;

- (void) updateDisplayVersion;
- (BOOL) isAppRunning;
- (BOOL) canUpgrade;
- (BOOL) isFrameworkPathUpgrade:(NSString*)newPath;
- (BOOL) preReplacement;
- (void) postReplacement;

- (void) upgradeAppWithFramework:(NSString*)path;
- (void) downgradeApp;

@end
