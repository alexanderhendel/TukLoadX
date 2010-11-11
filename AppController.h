//
//  AppController.h
//  TukLoadX
//
//  Created by Finroth on 01.10.10.
//  Copyright 2010 BlueBox Apps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BBAWoWAddOnInstaller.h"
#import	"BBAGitUtils.h"
#import "BBAGitRepository.h"
#import "BBATukui.h"
#import "BBATukuiConfig.h"

#define GIT_REPO_TUKUI @"Tukui"
#define GIT_USER_TUKUI @"tukz"
#define GIT_REPO_TIMER @"Tukui_ClassTimer"
#define GIT_USER_TIMER @"shadowphoenix"
#define GIT_REPO_CONFI @"Tukui_ConfigUI"
#define GIT_USER_CONFI @"tukz"

#define CONFIG_PATH_TUKUI @"/Downloads/tukui_dl.zip"
#define CONFIG_PATH_TIMER @"/Downloads/tukui_classtiemer_dl.zip"
#define CONFIG_PATH_CONFI @"/Downloads/tukui_ingamecfg_dl.zip"

#define WOW_APP_NAME @"World of Warcraft.app"

@interface AppController : NSObject {

	// default user settings
	NSUserDefaults* preferences;
	
	// utils
	BBAWoWAddOnInstaller* installer;
	BBAGitUtils* gitUtils;
	
	BBAGitRepository* gitRepoTukui;
	BBAGitRepository* gitRepoTukuiConfig;
	BBAGitRepository* gitRepoTukuiClassTimer;
	
	// addons
	BBATukui* tukui;
	BBATukuiConfig* tukuiConfig;

	// Outlets
	IBOutlet id mainWindow;
	IBOutlet id preferencesWindow;
	IBOutlet NSProgressIndicator* progressBar;
	IBOutlet NSTextField* installedVersionTextField;
	IBOutlet NSTextField* latestVersionTextField;
	IBOutlet NSTextField* progressBarTextField;
}
- (IBAction)openPreferenceSheet:(id)sender;
- (IBAction)closePreferencesSheet:(id)sender;
- (IBAction)setWowPathFromChooseDialog:(id)sender;
- (IBAction)forceGetVersion:(id)sender;
- (IBAction)backupInterface:(id)sender;
- (IBAction)backupTukUI:(id)sender;
- (IBAction)installTukUI:(id)sender;

- (void)checkVersions;

// property list
@property (nonatomic, retain) BBAWoWAddOnInstaller *installer;
@property (nonatomic, retain) BBAGitUtils* gitUtils;
@property (nonatomic, retain) BBAGitRepository* gitRepoTukui;
@property (nonatomic, retain) BBAGitRepository* gitRepoTukuiConfig;
@property (nonatomic, retain) BBAGitRepository* gitRepoTukuiClassTimer;
@property (nonatomic, retain) BBATukui* tukui;
@property (nonatomic, retain) BBATukuiConfig* tukuiConfig;


@end
