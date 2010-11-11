//
//  Unit:	BBAGitUtils.m
//  App:	TukLoadX
//
//  Created by Alex aka Finroth
//  Copyright 2010 BBA - Blue Box Apps. All rights reserved.
//

#import "BBAGitUtils.h"

NSString* const BBADownloadDidFinishNotification = @"BBADownloadDidFinish";
NSString* const BBADownloadDidAdvanceNotification = @"BBADownloadDidAdvance";

@interface BBAGitUtils()

// private methods

@end


@implementation BBAGitUtils

@synthesize defaultTargetDir;
@synthesize downloadBytesReceived;
@synthesize downloadPercentComplete;

- (id)init
{
	if ([super init])
	{
		defaultTargetDir = [[NSString alloc] initWithString:NSHomeDirectory()];
		downloadResponse = [[NSURLResponse alloc] init];
		downloadPercentComplete = 0;
		downloadBytesReceived = 0;
	}
	
	return self;
}

- (void)dealloc
{
	//dealloc retained objects
	[defaultTargetDir dealloc];
	[downloadResponse dealloc];
	
	[super	dealloc];
}

- (NSString*) downloadLatestVersionOfRepository:(BBAGitRepository*)repo
{
	NSString* destination = [[NSString alloc] init];

	// download file
	destination = [[[self defaultTargetDir] stringByAppendingString:@"/Downloads/"] stringByAppendingString:[repo repositoryversion]];
	
	NSLog(@"BBAGitUtils.m: Destination File Name Set: %@", destination);
	NSLog(@"BBAGitUtils.m: Requesting file from URL: %@", [repo downloadLinkForLatestVersion]);

	// create the request
	NSURLRequest *theRequest=[NSURLRequest requestWithURL:[NSURL URLWithString:[repo downloadLinkForLatestVersion]]
											   cachePolicy:NSURLRequestUseProtocolCachePolicy
										   timeoutInterval:60.0];
	 
	// create the connection with the request and start loading the data
	 theDownload=[[NSURLDownload alloc] initWithRequest:theRequest
											   delegate:self];
	
	if (theDownload) 
	{
		// set the destination file now
		[theDownload setDestination:destination allowOverwrite:YES];
	} else {
		// inform the user that the download could not be made
		NSLog(@"BBAGitUtils.m: Download of File FAILED.");
	}
	
	return destination;
}

- (void)download:(NSURLDownload *)download didFailWithError:(NSError *)error
{
    // release the connection
    [download release];
    // inform the user
    NSLog(@"BBAGitUtils.m: Download failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSErrorFailingURLStringKey]);
}
- (void)downloadDidFinish:(NSURLDownload *)download
{	
    [download release];					// release the connection
	
	// post notification if download is done
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc postNotificationName:@"BBADownloadDidFinishNotification" object:self];
	
	NSLog(@"Notify: BBADownloadDidFinishNotification");
	
    NSLog(@"BBAGitUtils.m: Download of File finished.");
}

-(void)download:(NSURLDownload *)download didCreateDestination:(NSString *)path
{
    // path now contains the destination path
    // of the download, taking into account any
    // unique naming caused by -setDestination:allowOverwrite:
    NSLog(@"BBAGitUtils.m: Final file destination: %@",path);
}

- (void)setDownloadResponse:(NSURLResponse *)aDownloadResponse
{
    [aDownloadResponse retain];
	
    // downloadResponse is an instance variable defined elsewhere.
    [downloadResponse release];
    downloadResponse = aDownloadResponse;
}

- (void)download:(NSURLDownload *)download didReceiveResponse:(NSURLResponse *)response
{
    // Reset the progress, this might be called multiple times.
    // bytesReceived is an instance variable defined elsewhere.
    downloadBytesReceived = 0;
	
    // Retain the response to use later.
    [self setDownloadResponse:response];
}

- (void)download:(NSURLDownload *)download didReceiveDataOfLength:(unsigned)length
{
    long long expectedLength = [downloadResponse expectedContentLength];
	
    downloadBytesReceived = downloadBytesReceived + length;
	
    if (expectedLength != NSURLResponseUnknownLength) {
        // If the expected content length is
        // available, display percent complete.
		self.downloadPercentComplete = (downloadBytesReceived/(float)expectedLength)*100.0;
        NSLog(@"BBAGitUtils.m: Percent complete - %f",self.downloadPercentComplete);
		
		// post notification on download progress
		NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
		[nc postNotificationName:@"BBADownloadDidAdvanceNotification" object:self];
		
		NSLog(@"Notify: BBADownloadDidAdvanceNotification");
    } else {
        // If the expected content length is
        // unknown, just log the progress.
        NSLog(@"BBAGitUtils.m: Bytes received - %d",self.downloadBytesReceived);
    }
}

- (BOOL)download:(NSURLDownload *)download shouldDecodeSourceDataOfMIMEType:(NSString *)encodingType
{
    BOOL shouldDecode = NO;
	
    if ([encodingType isEqual:@"application/macbinary"]) {
        shouldDecode = YES;
    } else if ([encodingType isEqual:@"application/binhex"]) {
        shouldDecode = YES;
    } else if ([encodingType isEqual:@"application/zip"]) {
        shouldDecode = YES;
    }
    return shouldDecode;
}

@end
