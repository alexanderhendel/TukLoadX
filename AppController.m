//
//  AppController.m
//  TukLoadX
//
//  Created by Finroth on 01.10.10.
//  Copyright 2010 BlueBox Apps. All rights reserved.
//

#import "AppController.h"

@implementation AppController

@synthesize installer;
@synthesize gitUtils;
@synthesize gitRepoTukui;
@synthesize gitRepoTukuiConfig;
@synthesize gitRepoTukuiClassTimer;
@synthesize tukui;
@synthesize tukuiConfig;

-(id)init
{
	if ([super init])
	{
		//NSLog to file for debugging
		[self redirectNSLog];
		
		// user prefs
		preferences = [[NSUserDefaults standardUserDefaults] retain];
		NSString *file = [[NSBundle mainBundle] pathForResource:@"Defaults" ofType:@"plist"];
		NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:file];
		[preferences registerDefaults:dict];
		
		// addon installer
		installer = [[BBAWoWAddOnInstaller alloc] initWithWoWBaseDir:[preferences objectForKey:@"WoWBasePath"]];
		
		// git helper and repos
		gitUtils = [[BBAGitUtils alloc] init];
		
		gitRepoTukui = [[BBAGitRepository alloc] initWithRepository:GIT_REPO_TUKUI :GIT_USER_TUKUI];
		gitRepoTukuiConfig = [[BBAGitRepository alloc] initWithRepository:GIT_REPO_CONFI :GIT_USER_CONFI];
		gitRepoTukuiClassTimer = [[BBAGitRepository alloc] initWithRepository:GIT_REPO_TIMER :GIT_USER_TIMER];
		
		tukui = [[BBATukui alloc] init];
		tukuiConfig = [[BBATukuiConfig alloc] init];
		
		// register for notifications
		NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
		[nc addObserver:self 
			   selector:@selector(handleDownloadFinished:) 
				   name:@"BBADownloadDidFinishNotification" 
				 object:nil];
		
		[nc addObserver:self
			   selector:@selector(handleRemoteVersionChecked:)
				   name:@"BBARemotVersionCheckedNotification" 
				 object:nil];
		
		[nc addObserver:self
			   selector:@selector(handleDownloadAdvanced:)
				   name:@"BBADownloadDidAdvanceNotification" 
				 object:nil];
		
		NSLog(@"Register for Notification: BBADownloadDidFinishNotification");
		NSLog(@"Register for Notification: BBARemotVersionCheckedNotification");
		NSLog(@"Register for Notification: BBADownloadDidAdvanceNotification");
	}
	
	NSLog(@"Initialise Application TukLoadX");
	
	return self;
}

-(void)dealloc
{
	// dealloc retained objects
	[preferences dealloc];
	[installer dealloc];
	[gitUtils dealloc];
	[gitRepoTukui dealloc];
	[gitRepoTukuiConfig dealloc];
	[gitRepoTukuiClassTimer dealloc];
	[tukui dealloc];
	[tukuiConfig dealloc];
	
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc removeObserver:self];
	
	[super dealloc];
}

-(IBAction) openPreferenceSheet:(id)sender
{
	[NSApp beginSheet:preferencesWindow 
	   modalForWindow:mainWindow 
		modalDelegate:nil
	   didEndSelector:nil
		  contextInfo:nil];
	
    [NSApp runModalForWindow:preferencesWindow];
	
    [NSApp endSheet:preferencesWindow];
    [preferencesWindow orderOut:self];
}

- (IBAction) closePreferencesSheet:(id)sender
{
    [NSApp stopModal];			// end modal loop for prefs sheet
}

- (IBAction) setWowPathFromChooseDialog:(id)sender
{
	int result;
	NSArray *fileTypes = [NSArray arrayWithObjects:@"app", nil];
	NSOpenPanel *oPanel = [[NSOpenPanel openPanel] retain];
		
	NSLog(@"Throw Sheet for Dir Selection");
	
	[oPanel setAllowsMultipleSelection:NO];
	[oPanel setTitle:@"Choose App Location"];
	[oPanel setMessage:@"Choose World of Warcraft App Location."];
	[oPanel setDelegate:preferencesWindow];
	[oPanel setCanChooseDirectories:NO];
	result = [oPanel runModalForDirectory:NSHomeDirectory() 
									 file:nil 
									types:fileTypes];
	
	//set path
	if (result == NSOKButton) {
		NSString *wowAppPath = [[oPanel filenames] objectAtIndex:0];
	
		// sort out file name if appended
		if ([[wowAppPath lastPathComponent] isEqual:WOW_APP_NAME])
		{
			wowAppPath = [wowAppPath stringByDeletingLastPathComponent];
		}
		
		NSLog(@"WoW Path From Panel is: %@", wowAppPath);

		[preferences setObject:wowAppPath forKey:@"WoWBasePath"];
		[preferences synchronize];
		[installer setWowinstallpath:[preferences objectForKey:@"WoWBasePath"]];
	}
}


- (IBAction) forceGetVersion:(id)sender
{
	[self checkVersions];
}

- (void) checkVersions
{
	// Get Installed Version of Tukui
	[tukui getVersionFromTocFile:[installer wowinstallpath]];
	
	NSLog(@"AppController.m: TukUI Version Installed: %@",[tukui installedVersion]);
	
	if ([tukui installedVersion] != nil) {
		[installedVersionTextField setStringValue:[tukui installedVersion]];
	}
	
	// Get Repository Version of Tukui
	[gitRepoTukui getLatestVersionOfRepository];
	
	NSLog(@"AppController.m: TukUI Version Available: %@",[gitRepoTukui repositoryversion]);
	
	if ([gitRepoTukui repositoryversion] != nil) {
		[latestVersionTextField setStringValue:[tukui formatGitVersionString:[gitRepoTukui repositoryversion]]];
	}
	
	// Get Repository Version of Tukui Config
	if ([preferences boolForKey:@"InstallIngameConfig"] == YES)
	{
		[gitRepoTukuiConfig getLatestVersionOfRepository];
		NSLog(@"AppController.m: TukUI Config Version Available: %@",[gitRepoTukuiConfig repositoryversion]);
	}
}

- (void) awakeFromNib 
{	
	[self checkVersions];
}

- (IBAction) backupInterface:(id)sender
{	
	[progressBar setDoubleValue:0.0];
	[progressBar setIndeterminate:YES];
	[progressBar startAnimation:nil];
	
	[progressBarTextField setStringValue:@"Backup WoW Interface..."];
	
	if ([installer backupInterface] == YES)
	{
		NSBeginInformationalAlertSheet(@"Information",
									   @"Ok", 
									   nil, 
									   nil, 
									   mainWindow, 
									   self, 
									   @selector(sheetDidEnd:returnCode:contextInfo:), 
									   nil, 
									   nil,
									   @"Interface Backup Done.");
	}
	
	[progressBarTextField setStringValue:@"Progress:"];
	
	[progressBar stopAnimation:nil];
	[progressBar setIndeterminate:NO];
}

- (IBAction) backupTukUI:(id)sender
{
	if (([installer backupAddOn:@"Tukui"] == YES) && 
		([installer backupAddOn:@"Tukui_Dps_Layout"] == YES) && 
		([installer backupAddOn:@"Tukui_Heal_Layout"] == YES)
		)
	{
		NSBeginInformationalAlertSheet(@"Information",
									   @"Ok", 
									   nil, 
									   nil, 
									   mainWindow, 
									   self, 
									   @selector(sheetDidEnd:returnCode:contextInfo:), 
									   nil, 
									   nil,
									   @"TukUI Backup Done.");
	}
}

- (IBAction) installTukUI:(id)sender
{	
	// TukUI installation
	[progressBarTextField setStringValue:@"Downloading TukUI..."];
	
	if (([tukui installedVersion]) && ([gitRepoTukui repositoryversion]))
	{
		// versions checked so go ahead for download
		[tukui setFilename:[gitUtils downloadLatestVersionOfRepository:gitRepoTukui]];
		
		// if requested also process ingame config
		if ([preferences boolForKey:@"InstallIngameConfig"] == YES)
		{
			[tukuiConfig setFilename:[gitUtils downloadLatestVersionOfRepository:gitRepoTukuiConfig]];
		}
	} else {
		// versions not checked do it first
		[self checkVersions];
	 
		//finally download
		[tukui setFilename:[gitUtils downloadLatestVersionOfRepository:gitRepoTukui]];
		
		// if requested also process ingame config
		if ([preferences boolForKey:@"InstallIngameConfig"] == YES)
		{
			[tukuiConfig setFilename:[gitUtils downloadLatestVersionOfRepository:gitRepoTukuiConfig]];
		}
	}
	
	NSLog(@"AppController.m: Local Filename of Tukui download is %@", [tukui filename]);
	
	// wait for download finished notification
}

- (void)sheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
	//end sheets
}

- (void)handleDownloadFinished:(NSNotification*)note
{
	NSLog(@"Handle Notification: BBADownloadDidFinishNotification");
	
	// when download finished do installation
	
	[progressBar setDoubleValue:0.0];
	[progressBar setIndeterminate:YES];
	[progressBar startAnimation:nil];
	
	[progressBarTextField setStringValue:@"Installing TukUI..."];
	
	//if backup is required do one
	if ([preferences boolForKey:@"BackupPrevious"] == YES)
	{
		[installer backupInterface];		// uhh that was easy, man did I write good helper classes
	}
	
	// if clean install remove old version first
	if ([preferences boolForKey:@"CleanInstall"] == YES)
	{
		[installer cleanAddon:@"Tukui"];
		[installer cleanAddon:@"Tukui_Dps_Layout"];
		[installer cleanAddon:@"Tukui_Heal_Layout"];
		
		//now install
		[installer installAddOnFromZipFile:[tukui filename] :@"Tukui"];
		
		// if requested also process ingame config
		if ([preferences boolForKey:@"InstallIngameConfig"] == YES)
		{
			[installer cleanAddon:@"Tukui_ConfigUI"];
			[installer installAddOnFromZipFile:[tukuiConfig filename] :@"Tukui_ConfigUI"];
		}
	} else {
		//if not a clean install
		if ([preferences boolForKey:@"OverrideConfig"] == YES) {
			// config can be wiped
			[installer installAddOnFromZipFile:[tukui filename] :@"Tukui"];
		} else {
			// config must be kept
			[installer installAddOnFromZipFile:[tukui filename] :@"Tukui" :@"config.lua"];
		}
		
		// if requested also process ingame config - no need to take care of the config.lua
		if ([preferences boolForKey:@"InstallIngameConfig"] == YES)
		{
			[installer installAddOnFromZipFile:[tukuiConfig filename] :@"Tukui_ConfigUI"];
		}
	}
	
	[progressBarTextField setStringValue:@"Progress:"];
	
	[progressBar stopAnimation:nil];
	[progressBar setIndeterminate:NO];
}

- (void)handleRemoteVersionChecked:(NSNotification*)note
{
	NSLog(@"Handle Notification: BBARemotVersionCheckedNotification");
	
	// when remote version checked update GUI
	if ([gitRepoTukui repositoryversion] != nil) {
		[latestVersionTextField setStringValue:[tukui formatGitVersionString:[gitRepoTukui repositoryversion]]];

		NSBeginInformationalAlertSheet(@"Information",
									   @"Ok", 
									   nil, 
									   nil, 
									   mainWindow, 
									   self, 
									   @selector(sheetDidEnd:returnCode:contextInfo:), 
									   nil, 
									   nil,
									   @"Version Checked.");
	}
}

- (void)handleDownloadAdvanced:(NSNotification*)note
{
	NSLog(@"Handle Notification: BBADownloadDidAdvanceNotification");
	
	[progressBar setDoubleValue:[gitUtils downloadPercentComplete]];
}

- (BOOL)redirectNSLog
{
	// Create log file
	NSString *logDir = NSHomeDirectory();
	NSString *logFile = [logDir stringByAppendingString:@"/tukloadx.log"];
	
	[@"" writeToFile:logFile atomically:YES encoding:NSUTF8StringEncoding error:nil];
	
	id fileHandle = [NSFileHandle fileHandleForWritingAtPath:logFile];

	if (!fileHandle) {
		return NSLog(@"Opening log failed"), NO;
	}
	[fileHandle retain];
	
	// Redirect stderr
	int err = dup2([fileHandle fileDescriptor], STDERR_FILENO);
	if (!err) {
		return	NSLog(@"Couldn't redirect stderr"), NO;
	}
	
	// Redirect stdout
	int sout = dup2([fileHandle fileDescriptor], STDOUT_FILENO);
	if (!sout) {
		return	NSLog(@"Couldn't redirect stdout"), NO;
	}
	
	return YES;
}

@end
