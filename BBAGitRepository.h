//
//  Unit:	BBAGitRepository.h
//  App:	TukLoadX
//
//  Created by Alex aka Finroth
//  Copyright 2010 BBA - Blue Box Apps. All rights reserved.
//


#import <Cocoa/Cocoa.h>

extern NSString* const BBARemotVersionCheckedNotification;

@interface BBAGitRepository : NSObject {

	NSString* repository;
	NSString* repositoryowner;
	NSString* repositoryversion;
	
	// URL Data
	NSURL* gitBaseURL;
	NSMutableData* gitResponseData;
	NSMutableArray* gitDownloadItems;
}

- (id)initWithRepository:(NSString*)reponame :(NSString*)repoowner;
- (void) getLatestVersionOfRepository;
- (void) getLatestVersionOfRepositoryFromHostedFile:(NSString *)fileURL;
- (NSString*) getDownloadPageForRepository;
- (NSString*) getDownloadPageForRepositoryFile;
- (NSString*) downloadLinkForLatestVersion;
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response;
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data;
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error;
- (void)connectionDidFinishLoading:(NSURLConnection *)connection;

@property (nonatomic, retain) NSString* repository;
@property (nonatomic, retain) NSString* repositoryowner;
@property (nonatomic, retain) NSString* repositoryversion;

@end
