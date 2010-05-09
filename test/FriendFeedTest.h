//
//  FFEngineTest.h
//  FFEngine
//
//  Created by Todd Ditchendorf on 1/17/09.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import <OCMock/OCMock.h>
#import <FFEngine/FFEngine.h>

@interface FriendFeedTest : SenTestCase {
	FFEngineFactory *factory;
	id <FFEngine>service;
	id mock;
}

@end
