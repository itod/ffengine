//
//  FFError.h
//  FFEngine
//
//  Created by Todd Ditchendorf on 1/17/09.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import <Foundation/Foundation.h>

//	bad-id-format - Bad format for UUID argument.
//	bad-url-format - Bad format for URL argument.
//	entry-not-found - Entry with the specified UUID was not found.
//	entry-required - Entry UUID argument is required.
//	forbidden - User does not have access to entry, room or other entity specified in the request.
//	image-format-not-supported - Unsupported image format.
//	internal-server-error - Internal error on FriendFeed server.
//	limit-exceeded - Request limit exceeded.
//	room-not-found - Room with specified name not found.
//	room-required - Room name argument is required.
//	title-required - Entry title argument is required.
//	unauthorized - The request requires authentication.
//	user-not-found - User with specified nickname not found.
//	user-required - User nickname argument is required.
//	error - Other unspecified error.

typedef enum {
	FFErrorCodeUnspecifiedError = 0,
	FFErrorCodeBadIDFormat,
	FFErrorCodeBadURLFormat,
	FFErrorCodeEntryNotFound,
	FFErrorCodeEntryRequired,
	FFErrorCodeForbidden,
	FFErrorCodeImageFormatNotSupported,
	FFErrorCodeInternalServerError,
	FFErrorCodeLimitExceeded,
	FFErrorCodeRoomNotFound,
	FFErrorCodeRoomRequired,
	FFErrorCodeTitleRequired,
	FFErrorCodeUnauthorized,
	FFErrorCodeUserNotFound,
	FFErrorCodeNotFound,
	FFErrorCodeUserRequired,
} FFErrorCode;

@interface FFError : NSObject {
	NSInteger responseStatusCode;
	FFErrorCode errorCode;
	NSString *errorDescription;
}
+ (id)errorWithResponseStatusCode:(NSInteger)rsc errorCodeString:(NSString *)s;
- (id)initWithResponseStatusCode:(NSInteger)rsc errorCodeString:(NSString *)s;

@property (nonatomic, readonly) NSInteger responseStatusCode;
@property (nonatomic, readonly) FFErrorCode errorCode;
@end
