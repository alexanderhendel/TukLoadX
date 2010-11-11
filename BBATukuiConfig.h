//
//  Unit:	BBATukuiConfig.m
//  App:	TukLoadX
//
//  Created by Alex aka Finroth
//  Copyright 2010 BBA - Blue Box Apps. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface BBATukuiConfig : NSObject {

	NSString* installedVersion;
	NSString* filename;
}

- (NSString*) formatGitVersionString:(NSString*)inputstring;

@property (nonatomic, retain) NSString* installedVersion;
@property (nonatomic, retain) NSString* filename;


@end
