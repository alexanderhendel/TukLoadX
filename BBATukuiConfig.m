//
//  Unit:	BBATukuiConfig.m
//  App:	TukLoadX
//
//  Created by Alex aka Finroth
//  Copyright 2010 BBA - Blue Box Apps. All rights reserved.
//

#import "BBATukuiConfig.h"


@implementation BBATukuiConfig

@synthesize installedVersion;
@synthesize filename;

- (id)init
{
	if ([super init])
	{
		//allocate class objects
		installedVersion = nil;
		filename = nil;
	}
	
	return self;
}

- (void)dealloc
{
	//dealloc retained objects
	[installedVersion dealloc];
	[filename dealloc];
	
	[super	dealloc];
}

- (NSString*) formatGitVersionString:(NSString*)inputstring
{
	NSString* version;
	
	NSRange range = [inputstring rangeOfString:@".zip"];
	version = [[inputstring substringToIndex:range.location] substringFromIndex:range.location - 4];
	
	NSLog(@"BBATukui.m: Version String Formatted to: %@", version);
	
	return version;
}

@end
