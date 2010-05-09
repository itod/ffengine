//
//  FFEngineTest.m
//  FFEngine
//
//  Created by Todd Ditchendorf on 1/17/09.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import "FriendFeedTest.h"

@implementation FriendFeedTest

- (void)setUp {
	mock = [OCMockObject mockForProtocol:@protocol(FFEngineDelegate)];
	factory = [FFEngineFactory factory];
	service = [factory defaultServiceWithDelegate:mock feedDataType:FFDataTypeXML feedReturnType:FFReturnTypeNSXMLDocument];

}


- (void)tearDown {
	
}


- (void)testPublicFeedForNilService {
    [[mock expect] request:OCMOCK_ANY didFetchPublicEntries:OCMOCK_ANY];
	[service fetchPublicEntriesForService:nil start:0 num:20];
//	[mock verify];
}

@end
