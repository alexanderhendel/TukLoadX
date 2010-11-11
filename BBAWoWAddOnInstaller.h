//
//  Unit:	BBAWoWAddOnInstaller.h
//  App:	TukLoadX
//
//  Created by Alex aka Finroth
//  Copyright 2010 BBA - Blue Box Apps. All rights reserved.
//


#import <Cocoa/Cocoa.h>

@interface BBAWoWAddOnInstaller : NSObject {

	NSString *wowinstallpath;
}

- (id) initWithWoWBaseDir:(NSString*)wowpath;
- (BOOL) installAddOnFromZipFile:(NSString*)zipfilepath
								:(NSString*)addonname;
- (BOOL) installAddOnFromZipFile:(NSString*)zipfilepath
								:(NSString*)addonname
								:(NSString*)xcludefile;
- (BOOL) backupAddOn:(NSString*)addonname;
- (BOOL) backupInterface;
- (NSString*) getTimeString;
- (void) cleanAddon:(NSString*)addonname;

@property (nonatomic, retain) NSString* wowinstallpath;

@end
