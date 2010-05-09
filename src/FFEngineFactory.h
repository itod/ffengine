//
//  FFEngineFactory.h
//  FFEngine
//
//  Created by Todd Ditchendorf on 1/17/09.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FFEngine.h"

@interface FFEngineFactory : NSObject {

}
+ (id)factory;

- (id <FFEngine>)defaultEngineWithDelegate:(id <FFEngineDelegate>)d feedDataType:(FFDataType)dt feedReturnType:(FFReturnType)rt;
@end
