//
//  Unit:	BBATukui.h
//  App:	TukLoadX
//
//  Created by Alex aka Finroth
//  Copyright 2010 BBA - Blue Box Apps. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#define TUKUI_TOC_FILE @"/Interface/AddOns/Tukui/Tukui.toc"

@interface BBATukui : NSObject {

	NSString* installedVersion;
	NSString* filename;
	NSFileManager* defaultManager;
}

- (NSString*) getVersionFromTocFile:(NSString*)wowinstallpath;
- (NSString*) formatGitVersionString:(NSString*)inputstring;

@property (nonatomic, retain) NSString* installedVersion;
@property (nonatomic, retain) NSString* filename;

@end
