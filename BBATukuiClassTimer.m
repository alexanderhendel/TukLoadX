//
//  Unit:	BBATukuiClassTimer.m
//  App:	TukLoadX
//
//  Created by Alex aka Finroth
//  Copyright 2010 BBA - Blue Box Apps. All rights reserved.
//

#import "BBATukuiClassTimer.h"


@implementation BBATukuiClassTimer

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
	NSRange rangev = [inputstring rangeOfString:@"_v"];
	version = [[inputstring substringToIndex:range.location] substringFromIndex:range.location - rangev.location];
	
	NSLog(@"BBATukuiClassTimer.m: Version String Formatted to: %@", version);
	
	return version;
}

@end
