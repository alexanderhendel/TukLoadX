//
//  Unit:	BBAGitRepository.h
//  App:	TukLoadX
//
//  Created by Alex aka Finroth
//  Copyright 2010 BBA - Blue Box Apps. All rights reserved.
//

#import "BBAGitRepository.h"

NSString* const BBARemotVersionCheckedNotification = @"BBARemotVersionChecked";

@interface BBAGitRepository()

// private methods
- (void) readGitHtmlResponse;

@end


@implementation BBAGitRepository

@synthesize repository;
@synthesize repositoryowner;
@synthesize repositoryversion;

- (id)init
{
	if ([super init])
	{
		repository = @"";
		repositoryowner = @"";
		repositoryversion = nil;
		
		gitDownloadItems = [[NSMutableArray alloc] init];
	}
	
	return self;
}

- (id)initWithRepository:(NSString*)reponame
						:(NSString*)repoowner
{
	if ([super init])
	{
		[self setRepository:reponame];
		[self setRepositoryowner:repoowner];
		[self setRepositoryversion:nil];
		
		gitDownloadItems = [[NSMutableArray alloc] init];
	}
	
	return self;
}

- (void)dealloc
{
	//dealloc retained objects
	[repository dealloc];
	[repositoryowner dealloc];
	[repositoryversion dealloc];
	[gitResponseData dealloc];
	[gitDownloadItems dealloc];
	
	[super	dealloc];
}

- (NSString*) getDownloadPageForRepository
{
	NSString* downloadPage;
	
	downloadPage = [[[[@"http://github.com/" stringByAppendingString:[self repositoryowner]] 
											 stringByAppendingString:@"/"]  
											 stringByAppendingString:[self repository]] 
											 stringByAppendingString:@"/downloads"];
	
	return downloadPage;
}

- (NSString*) getDownloadPageForRepositoryFile
{
	NSString* downloadPage;
	
	downloadPage = [[[[@"http://github.com/" stringByAppendingString:[self repositoryowner]] 
											 stringByAppendingString:@"/"]  
											 stringByAppendingString:[self repository]] 
											 stringByAppendingString:@"/blob/master"];
	
	return downloadPage;
}

//get latest version from github download page
- (void) getLatestVersionOfRepository
{	
	gitResponseData = [[NSMutableData data] retain];
    gitBaseURL = [[NSURL URLWithString:[self getDownloadPageForRepository]] retain];
	
	NSLog(@"BBAGitRepository.m: Connection attempt to: @%", [self getDownloadPageForRepository]);
	
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[self getDownloadPageForRepository]]];
    [[[NSURLConnection alloc] initWithRequest:request delegate:self] autorelease];
}

// get latest version of repo based on filecontent
- (void) getLatestVersionOfRepositoryFromHostedFile:(NSString *)fileURL
{
	gitResponseData = [[NSMutableData data] retain];
    gitBaseURL = [[NSURL URLWithString:[[self getDownloadPageForRepositoryFile] stringByAppendingString:fileURL]] retain];
	
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[[self getDownloadPageForRepositoryFile] stringByAppendingString:fileURL]]];
    [[[NSURLConnection alloc] initWithRequest:request delegate:self] autorelease];
}

- (NSString*) downloadLinkForLatestVersion
{
	NSString *link = [[NSString alloc] init];
	
	link = [[[[[@"http://github.com/downloads/" 
						stringByAppendingString:repositoryowner] 
						stringByAppendingString:@"/"] 
						stringByAppendingString:repository] 
						stringByAppendingString:@"/"] 
						stringByAppendingString:repositoryversion];
	
	return link;
}			   

- (void)readGitHtmlResponse
{
	// Once this method is invoked, "responseData" contains the complete result
	NSError *error;
    NSXMLDocument *document = [[NSXMLDocument alloc] initWithData:gitResponseData options:NSXMLDocumentTidyHTML error:&error];
    
    // Deliberately ignore the error: with most HTML it will be filled with
    // numerous "tidy" warnings.
    
    NSXMLElement *rootNode = [document rootElement];
    
    NSString *xpathQueryString = @"//div[@id='uploaded_downloads']/ol/li/h4/a";
    
	NSArray *newItemsNodes = [rootNode nodesForXPath:xpathQueryString error:&error];
    if (error)
    {
        [[NSAlert alertWithError:error] runModal];
        return;
    }
	
	//format fetched data
	[self willChangeValueForKey:@"newItems"];
    [gitDownloadItems release];
    gitDownloadItems = [[NSMutableArray array] retain];
    for (NSXMLElement *node in newItemsNodes)
    {
        NSString *relativeString = [[node attributeForName:@"href"] stringValue];
        NSURL *url = [NSURL URLWithString:relativeString relativeToURL:gitBaseURL];
        
        NSString *linkText = [[node childAtIndex:0] stringValue];
        
        [gitDownloadItems addObject:[NSDictionary dictionaryWithObjectsAndKeys:[url absoluteString], @"linkURL", linkText, @"linkText", nil]];
    }
}
			   
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [gitResponseData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [gitResponseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [[NSAlert alertWithError:error] runModal];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	NSLog(@"BBAGitRepository.m: Connection loaded.. reading response.");
	
	[self readGitHtmlResponse];
	
	repositoryversion = [[gitDownloadItems objectAtIndex:0] objectForKey:@"linkText"];
	
	// post notification if download is done
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc postNotificationName:@"BBARemotVersionCheckedNotification" object:self];
	
	NSLog(@"Notify: BBARemotVersionCheckedNotification");
	
	NSLog(@"BBAGitRepository.m: Latest Repo Version is: %@", repositoryversion);
}

- (NSURLRequest *)connection:(NSURLConnection *)connection
			 willSendRequest:(NSURLRequest *)request
			redirectResponse:(NSURLResponse *)redirectResponse
{
    [gitBaseURL autorelease];
    gitBaseURL = [[request URL] retain];
    return request;
}

@end
