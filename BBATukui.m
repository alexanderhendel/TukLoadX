//
//  Unit:	BBATukui.m
//  App:	TukLoadX
//
//  Created by Alex aka Finroth
//  Copyright 2010 BBA - Blue Box Apps. All rights reserved.
//

#import "BBATukui.h"


@implementation BBATukui

@synthesize installedVersion;
@synthesize filename;

- (id)init
{
	if ([super init])
	{
		//allocate class objects
		installedVersion = nil;
		filename = nil;
		defaultManager = [[NSFileManager alloc] init];
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

- (NSString*) getVersionFromTocFile:(NSString*)wowinstallpath
{
	NSLog(@"Tukui.m: Looking for .toc file in path: %@", [wowinstallpath stringByAppendingString:TUKUI_TOC_FILE]);
	
	//get version from tukui.toc if file exists
	if ([defaultManager fileExistsAtPath:[wowinstallpath stringByAppendingString:TUKUI_TOC_FILE]]) {
		//read tukui.toc
		NSLog(@"Tukui.m: .toc file used is: %@", [wowinstallpath stringByAppendingString:TUKUI_TOC_FILE]);
		
		NSStringEncoding encoding = NSUTF8StringEncoding;
        NSError *error = nil;
		NSString* tocContent = [NSString stringWithContentsOfFile:[wowinstallpath stringByAppendingString:TUKUI_TOC_FILE]
														 encoding:encoding
															error:&error];
		
		NSLog(@"Tukui.m: .toc File contains:");
		NSLog(@"Tukui.m: %@", tocContent);
		
		// iterate through lines of content
		NSEnumerator * lineEnumerator = [[tocContent componentsSeparatedByString:@"\n"] objectEnumerator];
		NSString *enumeratedLine;
		NSString *version = @"";
		BOOL nextIsVersionNumber = NO;
		
		// Prepare to process each line of numbers 
		NSEnumerator * stringEnumerator; 
		NSString * itemAsString; 
		
		while (enumeratedLine = [lineEnumerator nextObject]) 
		{ 
			stringEnumerator = [[enumeratedLine componentsSeparatedByString:@" "] objectEnumerator]; 
			
			while (itemAsString = [stringEnumerator nextObject]) 
			{
				if (nextIsVersionNumber == YES) {
					version = itemAsString;
					nextIsVersionNumber = NO;
				}
				
				if ([itemAsString isEqual:@"Version:"]) {
					nextIsVersionNumber = YES;
				}
			}
		} 
		
		installedVersion = version;
	} else {
		//path invalid so go to prefs sheet
		NSLog(@"Tukui.m: No .toc file found.");
	}	
	
	NSLog(@"Tukui.m: Installed Version is: %@", installedVersion);
	
	return installedVersion;
}

- (NSString*) formatGitVersionString:(NSString*)inputstring
{
	NSString* version;
	
	NSRange range = [inputstring rangeOfString:@".zip"];
	version = [[inputstring substringToIndex:range.location] substringFromIndex:1];
	
	NSLog(@"BBATukui.m: Version String Formatted to: %@", version);
	
	return version;
}

@end
