//
//  Unit:	BBAGitUtils.h
//  App:	TukLoadX
//
//  Created by Alex aka Finroth
//  Copyright 2010 BBA - Blue Box Apps. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BBAGitRepository.h"

extern NSString* const BBADownloadDidFinishNotification;
extern NSString* const BBADownloadDidAdvanceNotification;

@interface BBAGitUtils : NSObject {

	NSString* defaultTargetDir;
	NSURLDownload* theDownload;
	NSURLResponse* downloadResponse;
	int downloadBytesReceived;
	float downloadPercentComplete;
}

- (NSString*) downloadLatestVersionOfRepository:(BBAGitRepository*)repo;

- (void)download:(NSURLDownload *)download didFailWithError:(NSError *)error;
- (void)downloadDidFinish:(NSURLDownload *)download;
- (void)download:(NSURLDownload *)download didReceiveDataOfLength:(unsigned)length;
- (void)download:(NSURLDownload *)download didReceiveResponse:(NSURLResponse *)response;
- (void)download:(NSURLDownload *)download didCreateDestination:(NSString *)path;
- (BOOL)download:(NSURLDownload *)download shouldDecodeSourceDataOfMIMEType:(NSString *)encodingType;

@property (nonatomic, retain) NSString* defaultTargetDir;
@property (readwrite) float downloadPercentComplete;
@property (readwrite) int downloadBytesReceived;

@end
