//
//  FFError.m
//  FFEngine
//
//  Created by Todd Ditchendorf on 1/17/09.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import "FFError.h"

@interface FFError ()
@property (nonatomic, readwrite) NSInteger responseStatusCode;
@property (nonatomic, readwrite) FFErrorCode errorCode;
@property (nonatomic, retain) NSString *errorDescription;
@end

@implementation FFError

+ (id)errorWithResponseStatusCode:(NSInteger)rsc errorCodeString:(NSString *)s {
	return [[[[self class] alloc] initWithResponseStatusCode:rsc errorCodeString:s] autorelease];
}


- (id)initWithResponseStatusCode:(NSInteger)rsc errorCodeString:(NSString *)ecs {
	self = [super init];
	if (self) {
		self.responseStatusCode = rsc;
		FFErrorCode ec = FFErrorCodeUnspecifiedError;
		NSString *s = nil;
		if ([ecs isEqualToString:@"bad-id-format"]) {
			ec = FFErrorCodeBadIDFormat;
			s = @"Bad ID Format";
		} else if ([ecs isEqualToString:@"bad-url-format"]) {
			ec = FFErrorCodeBadURLFormat;
			s = @"Bad URL Format";
		} else if ([ecs isEqualToString:@"entry-not-found"]) {
			ec = FFErrorCodeEntryNotFound;
			s = @"Entry Not Found";
		} else if ([ecs isEqualToString:@"entry-required"]) {
			ec = FFErrorCodeEntryRequired;
			s = @"Entry Required";
		} else if ([ecs isEqualToString:@"forbidden"]) {
			ec = FFErrorCodeForbidden;
			s = @"Forbidden";
		} else if ([ecs isEqualToString:@"image-format-not-supported"]) {
			ec = FFErrorCodeImageFormatNotSupported;
			s = @"Image Format Not Supported";
		} else if ([ecs isEqualToString:@"internal-server-error"]) {
			ec = FFErrorCodeInternalServerError;
			s = @"Internal Server Error";
		} else if ([ecs isEqualToString:@"limit-exceeded"]) {
			ec = FFErrorCodeLimitExceeded;
			s = @"Limit Exceeded";
		} else if ([ecs isEqualToString:@"room-not-found"]) {
			ec = FFErrorCodeRoomNotFound;
			s = @"Room Not Found";
		} else if ([ecs isEqualToString:@"room-required"]) {
			ec = FFErrorCodeRoomRequired;
			s = @"Room Required";
		} else if ([ecs isEqualToString:@"title-required"]) {
			ec = FFErrorCodeTitleRequired;
			s = @"Title Required";
		} else if ([ecs isEqualToString:@"unauthorized"]) {
			ec = FFErrorCodeUnauthorized;
			s = @"Unauthorized";
		} else if ([ecs isEqualToString:@"user-not-found"]) {
			ec = FFErrorCodeUserNotFound;
			s = @"User Not Found";
		} else if ([ecs isEqualToString:@"not-found"]) {
			ec = FFErrorCodeNotFound;
			s = @"Not Found";
		} else if ([ecs isEqualToString:@"user-required"]) {
			ec = FFErrorCodeUserRequired;
			s = @"User Required";
		} else {
			ec = FFErrorCodeUnspecifiedError;
			s = @"Unspecified Error";
		}
		self.errorCode = ec;
		self.errorDescription = s;
	}
	return self;
}


- (void)dealloc {
	self.errorDescription = nil;
	[super dealloc];
}


- (NSString *)description {
	return errorDescription;
}

@synthesize responseStatusCode;
@synthesize errorCode;
@synthesize errorDescription;
@end
