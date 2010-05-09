//
//  FFEngineCFNetworkImpl.m
//  FFEngine
//
//  Created by Todd Ditchendorf on 1/17/09.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import "FFEngineCFNetworkImpl.h"
#import "FFEngineBaseImpl+BasicAuth.h"
#import <CFNetwork/CFNetwork.h>

#define BUFSIZE 1024

@interface FFEngineCFNetworkImpl ()
- (void)doSendHTTPRequest:(NSMutableDictionary *)cmd;
- (NSMutableDictionary *)makeHTTPRequestWith:(NSMutableDictionary *)cmd;

- (CFHTTPMessageRef)newHTTPRequestWithURL:(NSURL *)URL method:(NSString *)method body:(NSString *)body headers:(NSArray *)headers;
- (CFHTTPMessageRef)newResponseBySendingHTTPRequest:(CFHTTPMessageRef)req from:(NSMutableDictionary *)cmd;
- (NSData *)bodyDataForHTTPMessage:(CFHTTPMessageRef)message;
- (NSStringEncoding)stringEncodingForBodyOfHTTPMessage:(CFHTTPMessageRef)message;
@end

static BOOL isAuthChallengeForProxyStatusCode(NSInteger statusCode) {
    return (407 == statusCode);
}


static BOOL isAuthChallengeStatusCode(NSInteger statusCode) {
    return (401 == statusCode || isAuthChallengeForProxyStatusCode(statusCode));
}


static BOOL isErrorStatusCode(NSInteger statusCode) {
    return (statusCode >= 400 && statusCode < 600);
}

@implementation FFEngineCFNetworkImpl

#pragma mark -
#pragma mark HTTPClientHTTPService

- (void)dealloc; {
    [super dealloc];
}


- (void)sendHTTPRequest:(NSMutableDictionary *)cmd {
    [NSThread detachNewThreadSelector:@selector(doSendHTTPRequest:) toTarget:self withObject:cmd];
}


#pragma mark -
#pragma mark Private

- (void)doSendHTTPRequest:(NSMutableDictionary *)cmd {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		
	cmd = [self makeHTTPRequestWith:cmd];
    NSInteger statusCode = [[cmd objectForKey:HTTPResponseStatusCodeKey] integerValue];

	BOOL failed = isErrorStatusCode(statusCode);
    if (failed) {
		[self performSelectorOnMainThread:@selector(failure:) withObject:cmd waitUntilDone:NO];
    } else {
        [self performSelectorOnMainThread:@selector(success:) withObject:cmd waitUntilDone:NO];
    }
    
    [pool release];
}


- (NSMutableDictionary *)makeHTTPRequestWith:(NSMutableDictionary *)cmd {

    NSString *URLString = [[cmd objectForKey:HTTPRequestURLStringKey] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *URL = [NSURL URLWithString:URLString];
    NSString *method = [cmd objectForKey:HTTPRequestMethodKey];
    NSString *body = [cmd objectForKey:HTTPRequestBodyStringKey];
    NSArray *headers = [cmd objectForKey:HTTPRequestHeadersKey];
    	
    NSData *result = nil;
    CFHTTPMessageRef request = [self newHTTPRequestWithURL:URL method:method body:body headers:headers];
    CFHTTPMessageRef response = NULL;
    CFHTTPAuthenticationRef auth = NULL;
    NSInteger count = 0;
    
    while (1) {
        //    send request
        response = [self newResponseBySendingHTTPRequest:request from:cmd];
        
        if (!response) {
            result = nil;
            break;
        }
        
        NSURL *finalURL = (NSURL *)CFHTTPMessageCopyRequestURL(response);
        [cmd setObject:[finalURL absoluteString] forKey:HTTPResponseURLStringKey];
        [finalURL release];
        NSInteger responseStatusCode = CFHTTPMessageGetResponseStatusCode(response);
		[cmd setObject:[NSNumber numberWithInteger:responseStatusCode] forKey:HTTPResponseStatusCodeKey];
        
        if (!isAuthChallengeStatusCode(responseStatusCode)) {
			NSStringEncoding enc = [self stringEncodingForBodyOfHTTPMessage:response];
			[cmd setObject:[NSNumber numberWithUnsignedInteger:enc] forKey:HTTPResponseBodyStringEncodingKey];
            result = [self bodyDataForHTTPMessage:response];
            break;
        }
        
        if (count) {
            self.authUsername = nil;
            self.authPassword = nil;
        }
        
        BOOL forProxy = isAuthChallengeForProxyStatusCode(responseStatusCode);
        auth = CFHTTPAuthenticationCreateFromResponse(kCFAllocatorDefault, response);
        
        NSString *scheme = [(id)CFHTTPAuthenticationCopyMethod(auth) autorelease];
        NSString *realm  = [(id)CFHTTPAuthenticationCopyRealm(auth) autorelease];
        NSArray *domains = [(id)CFHTTPAuthenticationCopyDomains(auth) autorelease];
        NSURL *domain = domains.count ? [domains objectAtIndex:0] : nil;
        
        BOOL cancelled = NO;
        NSString *username = nil;
        NSString *password = nil;
        
        // try the previous username/password first? do we really wanna do that?
        if (0 == count && self.authUsername.length && self.authPassword.length) {
            username = self.authUsername;
            password = self.authPassword;
        } 
        cancelled = [self getUsername:&username password:&password forAuthScheme:scheme URL:URL realm:realm domain:domain forProxy:forProxy isRetry:count];
        count++;
        
        self.authUsername = username;
        self.authPassword = password;
        
        if (cancelled) {
            result = nil;
            break;
        }        
        
        if (request) {
            CFRelease(request);
            request = NULL;
        }
        if (response) {
            CFRelease(response);
            response = NULL;
        }
        
        request = [self newHTTPRequestWithURL:URL method:method body:body headers:headers];
        
        NSMutableDictionary *creds = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                      username, kCFHTTPAuthenticationUsername,
                                      password, kCFHTTPAuthenticationPassword,
                                      nil];
        
        if (domain && CFHTTPAuthenticationRequiresAccountDomain(auth)) {
            [creds setObject:[domain absoluteString] forKey:(id)kCFHTTPAuthenticationAccountDomain];
        }
        
        Boolean credentialsApplied = CFHTTPMessageApplyCredentialDictionary(request, auth, (CFDictionaryRef)creds, NULL);
        
        if (auth) {
            CFRelease(auth);
            auth = NULL;
        }
        
        if (!credentialsApplied) {
            NSLog(@"OH BOTHER. Can't add add auth credentials to request. dunno why. FAIL.");
            result = nil;
            break;
        }
    }
    
    if (request) {
        CFRelease(request);
        request = NULL;
    }
    if (response) {
        CFRelease(response);
        response = NULL;
    }
    if (auth) {
        CFRelease(auth);
        auth = NULL;
    }
    
	if (result) {
		[cmd setObject:result forKey:HTTPResponseBodyDataKey];
	}
	
    return cmd;
}


- (CFHTTPMessageRef)newHTTPRequestWithURL:(NSURL *)URL method:(NSString *)method body:(NSString *)body headers:(NSArray *)headers {
    
    CFHTTPMessageRef message = CFHTTPMessageCreateRequest(kCFAllocatorDefault, (CFStringRef)method, (CFURLRef)URL, kCFHTTPVersion1_1);
    
    if ([body length]) {
        CFHTTPMessageSetBody(message, (CFDataRef)[body dataUsingEncoding:NSUTF8StringEncoding]);
    }
    
    for (NSDictionary *header in headers) {
        NSString *name = [header objectForKey:@"name"];
        NSString *value = [header objectForKey:@"value"];
        if ([name length] && [value length]) {
            CFHTTPMessageSetHeaderFieldValue(message, (CFStringRef)name, (CFStringRef)value);
        }
    }
    
    return message;
}


- (CFHTTPMessageRef)newResponseBySendingHTTPRequest:(CFHTTPMessageRef)req from:(NSMutableDictionary *)cmd {
    CFHTTPMessageRef response = NULL;
    NSMutableData *responseBodyData = [NSMutableData data];
    
    CFReadStreamRef stream = CFReadStreamCreateForHTTPRequest(kCFAllocatorDefault, req);
    CFReadStreamSetProperty(stream, kCFStreamPropertyHTTPShouldAutoredirect, kCFBooleanTrue);
    CFReadStreamOpen(stream);    
    
    BOOL done = NO;
    while (!done) {
        UInt8 buf[BUFSIZE];
        CFIndex numBytesRead = CFReadStreamRead(stream, buf, BUFSIZE);
        if (numBytesRead < 0) {
            CFStreamError error = CFReadStreamGetError(stream);
            NSString *msg = [NSString stringWithFormat:@"Network Error. Domain: %d, Code: %d", error.domain, error.error];
            //NSLog(@"%@", msg);
			[cmd setObject:msg forKey:HTTPErrorStringKey];
            [self performSelectorOnMainThread:@selector(failure:) withObject:cmd waitUntilDone:NO];
            responseBodyData = nil;
            done = YES;
        } else if (numBytesRead == 0) {
            done = YES;
        } else {
            [responseBodyData appendBytes:buf length:numBytesRead];
        }
    }
    
    CFReadStreamClose(stream);
    NSInteger streamStatus = CFReadStreamGetStatus(stream);
    
    if (kCFStreamStatusError != streamStatus) {
        response = (CFHTTPMessageRef)CFReadStreamCopyProperty(stream, kCFStreamPropertyHTTPResponseHeader);
        CFHTTPMessageSetBody(response, (CFDataRef)responseBodyData);
    }
    
    if (stream) {
        CFRelease(stream);
        stream = NULL;
    }
    
    return response;
}


- (NSData *)bodyDataForHTTPMessage:(CFHTTPMessageRef)message {
    NSData *data = (NSData *)CFHTTPMessageCopyBody(message);
	return [data autorelease];
}


- (NSStringEncoding)stringEncodingForBodyOfHTTPMessage:(CFHTTPMessageRef)message {
    
    // use latin1 as the default. why not.
    NSStringEncoding encoding = NSISOLatin1StringEncoding;
    
    // get the content-type header field value
    NSString *contentType = [(id)CFHTTPMessageCopyHeaderFieldValue(message, (CFStringRef)@"Content-Type") autorelease];
    if (contentType) {
        
        // "text/html; charset=utf-8" is common, so just get the good stuff
        NSRange r = [contentType rangeOfString:@"charset="];
        if (NSNotFound == r.location) {
            r = [contentType rangeOfString:@"="];
        }
        if (NSNotFound != r.location) {
            contentType = [contentType substringFromIndex:r.location + r.length];
        }
        
        // trim whitespace
        contentType = [contentType stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        
        // convert to an NSStringEncoding
        CFStringEncoding cfStrEnc = CFStringConvertIANACharSetNameToEncoding((CFStringRef)contentType);
        if (kCFStringEncodingInvalidId != cfStrEnc) {
            encoding = CFStringConvertEncodingToNSStringEncoding(cfStrEnc);
        }
    }
    
    return encoding;
}

@end
