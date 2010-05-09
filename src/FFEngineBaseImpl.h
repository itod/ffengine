//
//  FFEngineBaseImpl.h
//  FFEngine
//
//  Created by Todd Ditchendorf on 1/17/09.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FFEngine.h"

extern NSString * const HTTPRequestMethodKey;
extern NSString * const HTTPRequestURLStringKey;
extern NSString * const HTTPRequestBodyStringKey;
extern NSString * const HTTPRequestHeadersKey;
extern NSString * const HTTPResponseStatusCodeKey;
extern NSString * const HTTPResponseURLStringKey;
extern NSString * const HTTPResponseBodyDataKey;
extern NSString * const HTTPResponseBodyStringEncodingKey;
extern NSString * const HTTPErrorStringKey;

@interface FFEngineBaseImpl : NSObject <FFEngine> {
	id <FFEngineDelegate> delegate;
	FFDataType feedDataType;
	FFReturnType feedReturnType;
	NSMutableDictionary *callbackTable;
	
	// auth
	NSString *authUsername;
    NSString *authPassword;
}
- (id)initWithDelegate:(id <FFEngineDelegate>)d feedDataType:(FFDataType)dt feedReturnType:(FFReturnType)rt;

- (void)sendHTTPRequest:(NSMutableDictionary *)cmd;
- (void)success:(NSMutableDictionary *)cmd;
- (void)failure:(NSMutableDictionary *)cmd;

@property (nonatomic, copy) NSString *authUsername;
@property (nonatomic, copy) NSString *authPassword;
@end
