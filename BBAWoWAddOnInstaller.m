//
//  Unit:	BBAWoWAddOnInstaller.m
//  App:	TukLoadX
//
//  Created by Alex aka Finroth
//  Copyright 2010 BBA - Blue Box Apps. All rights reserved.
//

#import "BBAWoWAddOnInstaller.h"


@interface BBAWoWAddOnInstaller()

// private methods
- (BOOL) zipFolder:(NSString*)pathtofolder;

@end

@implementation BBAWoWAddOnInstaller

@synthesize wowinstallpath;

- (id)init
{
	if ([super init])
	{
		wowinstallpath = @"";
	}
	
	return self;
}

- (id)initWithWoWBaseDir:(NSString *)wowpath
{
	if ([super init])
	{
		wowinstallpath = wowpath;
	}
	
	return self;
}

- (void)dealloc
{
	//dealloc retained objects
	[wowinstallpath dealloc];
	
	[super	dealloc];
}

- (BOOL) installAddOnFromZipFile:(NSString*)zipfilepath
								:(NSString*)addonname
{
	BOOL done = NO;
	
	//implementation
	NSString *targetPath = [wowinstallpath stringByAppendingString:@"/Interface/AddOns"];
	
	NSLog(@"BBAWoWAddOnInstaller.m: Will try to extract: %@",zipfilepath);
	NSLog(@"BBAWoWAddOnInstaller.m: Target Folder is: %@",targetPath);
	
	NSTask * task = [[NSTask alloc] init];
	
	[task setLaunchPath:@"/usr/bin/unzip"];
	[task setArguments: [NSArray arrayWithObjects:@"-o",zipfilepath,@"-d",targetPath,nil]];
	[task launch];
	[task waitUntilExit];
	
	NSLog(@"NSTask unzip terminationStatus: %d", [task terminationStatus]);
	
	if ([task terminationStatus] == 0) {
		done = YES;
	}
	
	return done;
}

- (BOOL) installAddOnFromZipFile:(NSString*)zipfilepath
								:(NSString*)addonname
								:(NSString*)xcludefile
{
	BOOL done = NO;
	
	//implementation
	NSString *targetPath = [wowinstallpath stringByAppendingString:@"/Interface/AddOns"];
	
	NSLog(@"BBAWoWAddOnInstaller.m: Will try to extract: %@",zipfilepath);
	NSLog(@"BBAWoWAddOnInstaller.m: Target Folder is: %@",targetPath);
	
	NSTask * task = [[NSTask alloc] init];
	
	[task setLaunchPath:@"/usr/bin/unzip"];
	[task setArguments: [NSArray arrayWithObjects:@"-o",zipfilepath,@"-d",targetPath,@"-x",[@"*" stringByAppendingString:xcludefile],nil]];
	[task launch];
	[task waitUntilExit];
	
	NSLog(@"NSTask unzip terminationStatus: %d", [task terminationStatus]);
	
	if ([task terminationStatus] == 0) {
		done = YES;
	}
	
	return done;
}


- (BOOL) backupAddOn:(NSString*)addonname
{
	BOOL done = NO;
	
	//implementation
	NSString* sourcePath = [[self.wowinstallpath stringByAppendingString:@"/Interface/AddOns/"] stringByAppendingString:addonname];
	NSString* destPath = [[[self.wowinstallpath stringByAppendingString:@"/Backup_"] stringByAppendingString:addonname]stringByAppendingString:[self getTimeString]];
	
	NSFileManager* fm = [NSFileManager defaultManager];
	NSError* err = nil;
	
	if ([fm copyItemAtPath:sourcePath toPath:destPath error:&err] == YES) {
		NSLog(@"Interface backup done");
		done = YES;
	} else {
		NSLog(@"Interface backup failed for reason: %@", err);
		[[NSAlert alertWithError:err] runModal];
	}
	
	return done;
}

- (BOOL) backupInterface
{
	BOOL done = NO;
	
	//implementation
	NSString* sourcePath = [self.wowinstallpath stringByAppendingString:@"/Interface"];
	NSString* destPath = [[self.wowinstallpath stringByAppendingString:@"/Backup_Interface"] stringByAppendingString:[self getTimeString]];
	
	NSFileManager* fm = [NSFileManager defaultManager];
	NSError* err = nil;
	
	if ([fm copyItemAtPath:sourcePath toPath:destPath error:&err] == YES) {
		NSLog(@"BBAWoWAddOnInstaller.m: Interface backup done");
		done = YES;
	} else {
		NSLog(@"BBAWoWAddOnInstaller.m: Interface backup failed for reason: %@", err);
		[[NSAlert alertWithError:err] runModal];
	}
	
	NSLog(@"BBAWoWAddOnInstaller.m: Bundle Backup of Interface.");
	if ([self zipFolder:destPath] == NO)
	{
		done = NO;
	} else {
		//remove backup folder as we have a compressed backup
		if ([fm removeItemAtPath:destPath error:&err] == YES)
		{
			NSLog(@"BBAWoWAddOnInstaller.m: Interface backup folder removed as zip is available.");
			done = YES;
		} else {
			NSLog(@"BBAWoWAddOnInstaller.m: Interface backup folder NOT removed for reason: %@", err);
			[[NSAlert alertWithError:err] runModal];
		}
	}

	return done;
}

- (NSString*) getTimeString
{
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	NSDateComponents *dateComponents = [gregorian components:(NSHourCalendarUnit  | NSMinuteCalendarUnit | NSSecondCalendarUnit | NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit) fromDate:[NSDate date]];
	
	NSInteger hour = [dateComponents hour];
	NSInteger minute = [dateComponents minute];
	NSInteger second = [dateComponents second];
	
	NSInteger day = [dateComponents day];
	NSInteger month = [dateComponents month];
	NSInteger year = [dateComponents year];
	
	[gregorian release];
	
	return [NSString stringWithFormat:@"_%d.%d.%d-%d%d%d",day,month,year,hour,minute,second];
}

- (BOOL) zipFolder:(NSString*)pathtofolder
{
	BOOL done = NO;
	
	//implementation
	NSLog(@"BBAWoWAddOnInstaller.m: Target Folder for Zipping is: %@",pathtofolder);
	
	NSTask * task = [[NSTask alloc] init];
	
	[task setLaunchPath:@"/usr/bin/zip"];
	[task setArguments: [NSArray arrayWithObjects:@"-r",[pathtofolder stringByAppendingString:@".zip"],pathtofolder,nil]];
	[task launch];
	[task waitUntilExit];
	
	NSLog(@"NSTask unzip terminationStatus: %d", [task terminationStatus]);
	
	if ([task terminationStatus] == 0) {
		done = YES;
	}
	
	return done;	
}

- (void) cleanAddon:(NSString*)addonname
{
	//implementation
	NSString* sourcePath = [[self.wowinstallpath stringByAppendingString:@"/Interface/AddOns/"] stringByAppendingString:addonname];
	
	NSLog(@"BBAWoWAddOnInstaller.m: AddOn Cleaning working path: %@", sourcePath);
	
	NSFileManager* fm = [NSFileManager defaultManager];
	NSError* err = nil;
	
	if ([fm removeItemAtPath:sourcePath error:&err] == YES) {
		NSLog(@"BBAWoWAddOnInstaller.m: Removed AddOn: %@", addonname);
	} else {
		NSLog(@"BBAWoWAddOnInstaller.m: Remove AddOn failed for reason: %@", err);
		//[[NSAlert alertWithError:err] runModal];
	}
}

@end
