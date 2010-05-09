//
//  FFXmlDocPtrWrapper.h
//  FFEngine
//
//  Created by Todd Ditchendorf on 1/19/09.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <libxml/tree.h>

@interface FFXmlDocPtrWrapper : NSObject {
	xmlDocPtr _xmlDoc;
}
+ (id)wrapperWithXmlDoc:(xmlDocPtr)d;
- (id)initWithXmlDoc:(xmlDocPtr)d;

- (NSString *)XMLString;
- (FFXmlDocPtrWrapper *)wrapperByTransformingWithStylesheetAtPath:(NSString *)path params:(NSDictionary *)params;

@property (nonatomic, readonly) xmlDocPtr xmlDoc;
@end
