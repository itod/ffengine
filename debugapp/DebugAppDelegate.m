//
//  DebugAppDelegate.m
//  FFEngine
//
//  Created by Todd Ditchendorf on 1/17/09.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import "DebugAppDelegate.h"
#import <WebKit/WebKit.h>

@implementation DebugAppDelegate

- (id)init {
	self = [super init];
	if (self) {
		
	}
	return self;
}


- (void)dealloc {
	self.displayString = nil;
	[super dealloc];
}


- (IBAction)run:(id)sender {
	self.busy = YES;
	FFEngineFactory *factory = [FFEngineFactory factory];
	
//	id <FFEngine>service = [factory defaultServiceWithDelegate:self feedDataType:FFDataTypeJSON feedReturnType:FFReturnTypeNSString];
//	id <FFEngine>service = [factory defaultServiceWithDelegate:self feedDataType:FFDataTypeJSON feedReturnType:FFReturnTypeJSONValue];

//	id <FFEngine>service = [factory defaultServiceWithDelegate:self feedDataType:FFDataTypeXML feedReturnType:FFReturnTypeNSString];
	id <FFEngine>service = [factory defaultServiceWithDelegate:self feedDataType:FFDataTypeXML feedReturnType:FFReturnTypeNSXMLDocument];
//	id <FFEngine>service = [factory defaultServiceWithDelegate:self feedDataType:FFDataTypeXML feedReturnType:FFReturnTypeFFXmlDocPtrWrapper];

//	id <FFEngine>service = [factory defaultServiceWithDelegate:self feedDataType:FFDataTypeRSS feedReturnType:FFReturnTypeNSString];
//	id <FFEngine>service = [factory defaultServiceWithDelegate:self feedDataType:FFDataTypeRSS feedReturnType:FFReturnTypeNSXMLDocument];
//	id <FFEngine>service = [factory defaultServiceWithDelegate:self feedDataType:FFDataTypeRSS feedReturnType:FFReturnTypeFFXmlDocPtrWrapper];
//	id <FFEngine>service = [factory defaultServiceWithDelegate:self feedDataType:FFDataTypeRSS feedReturnType:FFReturnTypePSFeed];

//	id <FFEngine>service = [factory defaultServiceWithDelegate:self feedDataType:FFDataTypeAtom feedReturnType:FFReturnTypeNSString];
//	id <FFEngine>service = [factory defaultServiceWithDelegate:self feedDataType:FFDataTypeAtom feedReturnType:FFReturnTypeNSXMLDocument];
//	id <FFEngine>service = [factory defaultServiceWithDelegate:self feedDataType:FFDataTypeAtom feedReturnType:FFReturnTypeFFXmlDocPtrWrapper];
//	id <FFEngine>service = [factory defaultServiceWithDelegate:self feedDataType:FFDataTypeAtom feedReturnType:FFReturnTypePSFeed];
	
	
//	[service fetchPublicEntriesForService:nil start:0 num:10];
	[service fetchEntriesForUser:@"itod" service:nil start:0 num:10];


	//http://friendfeed.com/api/comment/delete?entry=ad54fe4e-30b2-4659-8503-791370ae7106&comment=6f2b16e8-cf71-449d-ae36-6dcfbaf4dea4&format=json&undelete=1
}


- (void)request:(NSString *)identifier didFetchPublicEntries:(id)data {
	self.displayString = [[[NSAttributedString alloc] initWithString:[data description]] autorelease];
	[self renderHTMLFor:data];
	self.busy = NO;
}


- (void)request:(NSString *)identifier didFetchEntries:(id)data forUser:(NSString *)username {
	self.displayString = [[[NSAttributedString alloc] initWithString:[data description]] autorelease];
	[self renderHTMLFor:data];
	self.busy = NO;
}


- (void)request:(NSString *)identifier didPostComment:(id)data onEntry:(NSString *)entryID {
	self.displayString = [[[NSAttributedString alloc] initWithString:[data description]] autorelease];
	self.busy = NO;
}


- (void)request:(NSString *)identifier didDeleteComment:(id)data onEntry:(NSString *)entryID {
	self.displayString = [[[NSAttributedString alloc] initWithString:[data description]] autorelease];
	self.busy = NO;
}


- (void)request:(NSString *)identifier didUndeleteComment:(id)data onEntry:(NSString *)entryID {
	self.displayString = [[[NSAttributedString alloc] initWithString:[data description]] autorelease];
	self.busy = NO;
}


- (void)request:(NSString *)identifier didDeleteEntry:(id)data forID:(NSString *)entryID {
	self.displayString = [[[NSAttributedString alloc] initWithString:[data description]] autorelease];
	self.busy = NO;
}


- (void)request:(NSString *)identifier didUndeleteEntry:(id)data forID:(NSString *)entryID {
	self.displayString = [[[NSAttributedString alloc] initWithString:[data description]] autorelease];
	self.busy = NO;
}


- (void)request:(NSString *)identifier didHideEntry:(id)data forID:(NSString *)entryID {
	self.displayString = [[[NSAttributedString alloc] initWithString:[data description]] autorelease];
	self.busy = NO;
}


- (void)request:(NSString *)identifier didUnhideEntry:(id)data forID:(NSString *)entryID {
	self.displayString = [[[NSAttributedString alloc] initWithString:[data description]] autorelease];
	self.busy = NO;
}



- (void)request:(NSString *)identifier didFailWithError:(FFError *)error {
	self.displayString = [[[NSAttributedString alloc] initWithString:[error description]] autorelease];
	self.busy = NO;
}


- (void)renderHTMLFor:(NSXMLDocument *)doc {
	NSString *path = [[NSBundle mainBundle] pathForResource:@"xml2html" ofType:@"xsl"];
	NSString *XSLTString = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
	
	NSError *err = nil;
	NSXMLDocument *res = [doc objectByApplyingXSLTString:XSLTString arguments:nil error:&err];
	if (err) {
		NSLog(@"%@", err);
	}
	
	NSString *HTMLString = [res XMLString];
	[[webView mainFrame] loadHTMLString:HTMLString baseURL:nil];
}

@synthesize displayString;
@synthesize busy;
@end
