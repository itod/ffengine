//
//  FFEngineFactory.m
//  FFEngine
//
//  Created by Todd Ditchendorf on 1/17/09.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import "FFEngineFactory.h"
#import "FFEngine.h"
#import "FFEngineBaseImpl.h"
#import "FFEngineCFNetworkImpl.h"

@implementation FFEngineFactory

+ (id)factory {
	return [[[[self class] alloc] init] autorelease];
}


- (id <FFEngine>)defaultEngineWithDelegate:(id <FFEngineDelegate>)d feedDataType:(FFDataType)dt feedReturnType:(FFReturnType)rt {
#if !FF_DTOP_ENV
	if (FFReturnTypeNSXMLDocument == rt) {
		[NSException raise:@"FFUnsupportedPlatform" format:@"An FFEngine may not created with a FFReturnType of NSXMLDocument on mobile platforms, as NSXML is unavailable."];
	}
#endif
	return [[[FFEngineCFNetworkImpl alloc] initWithDelegate:d feedDataType:dt feedReturnType:rt] autorelease];
}

@end
