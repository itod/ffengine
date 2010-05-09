//
//  FFEngineBaseImpl.m
//  FFEngine
//
//  Created by Todd Ditchendorf on 1/17/09.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import "FFEngineBaseImpl.h"
#import "FFEngineBaseImpl+BasicAuth.h"
#import "FFEngineDelegate.h"
#import "FFError.h"
#import "FFEngineFactory.h"
#import "FFXmlDocPtrWrapper.h"
#import "NSString+SBJSON.h"
#import <libxml/parser.h>
#import <libxml/tree.h>

static NSString * const kFFEngineFeedPrefix		= @"http://friendfeed.com/api/feed/";
static NSString * const kFFEnginePostPrefix		= @"http://friendfeed.com/api/";

static NSString * const FFURLStringKey				= @"FFURLString";
static NSString * const FFNicknameKey				= @"FFNickname";
static NSString * const FFEntryIDKey				= @"FFEntryID";
static NSString * const FFEntryIDsKey				= @"FFEntryIDs";
static NSString * const FFSubscribedOnlyKey			= @"FFSubscribedOnly";
static NSString * const FFInexactMatchKey			= @"FFInexactMatch";
static NSString * const FFQueryKey					= @"FFQuery";
static NSString * const FFDomainsKey				= @"FFDomains";
static NSString * const FFReturnValueKey			= @"FFReturnValue";
static NSString * const FFIdentifierKey				= @"FFIdentifier";
static NSString * const FFCommentIDKey				= @"FFCommentID";

NSString * const HTTPRequestMethodKey				= @"HTTPRequestMethod";
NSString * const HTTPRequestURLStringKey			= @"HTTPRequestURLString";
NSString * const HTTPRequestBodyStringKey			= @"HTTPRequestBodyString";
NSString * const HTTPRequestHeadersKey				= @"HTTPRequestHeaders";
NSString * const HTTPResponseStatusCodeKey			= @"HTTPResponseStatusCode";
NSString * const HTTPResponseURLStringKey			= @"HTTPResponseURLString";
NSString * const HTTPResponseBodyDataKey			= @"HTTPResponseBodyData";
NSString * const HTTPResponseBodyStringEncodingKey	= @"HTTPResponseBodyStringEncoding";
NSString * const HTTPErrorStringKey					= @"HTTPErrorString";


static void myGenericErrorFunc(void *ctx, const char *str, ...) {
    va_list vargs;
    va_start(vargs, str);
    
    NSString *format = [NSString stringWithUTF8String:str];
    NSString *msg = [[[NSString alloc] initWithFormat:format arguments:vargs] autorelease];
    
    NSLog(@"%@", msg);
    
    va_end(vargs);
}
    

static xmlDocPtr FFXmlDocPtrFromString(NSString *XMLString, NSString *baseURLString) {
	if (!XMLString.length) return NULL;
	
    xmlSetGenericErrorFunc(NULL, myGenericErrorFunc);
    
	xmlDocPtr docPtr = NULL;
///#ifdef FFDEBUG
	int opts = XML_PARSE_NONET|XML_PARSE_NOXINCNODE|XML_PARSE_RECOVER;
//#else
//	int opts = XML_PARSE_NONET|XML_PARSE_NOXINCNODE|XML_PARSE_RECOVER|XML_PARSE_NOERROR|XML_PARSE_NOWARNING;
//#endif
	
	const char *baseURL = NULL;
	if (baseURLString.length) {
		baseURL = [baseURLString UTF8String];
	}
	
	docPtr = xmlReadMemory([XMLString UTF8String], 
						   [XMLString length], 
						   baseURL,
						   "utf-8", 
						   opts);
	return docPtr;
}

@interface FFEngineBaseImpl ()
// helper methods
- (NSString *)stringForFeedDataType;
- (NSString *)makeUniqueIdentifier;
- (NSString *)feedURLStringForPath:(NSString *)path service:(NSString *)service start:(NSUInteger)start num:(NSUInteger)num;
- (NSString *)postURLStringForPath:(NSString *)path;

- (NSString *)fetchFeedFor:(NSMutableDictionary *)cmd callback:(SEL)sel;
- (NSString *)postDataFor:(NSMutableDictionary *)cmd callback:(SEL)sel;
- (NSString *)sendRequestFor:(NSMutableDictionary *)cmd callback:(SEL)sel;
	
// success helpers
- (id)convertedFeedReturnValueFor:(NSMutableDictionary *)cmd;
- (id)convertedFeedReturnValueForJSON:(NSMutableDictionary *)cmd;
- (id)convertedFeedReturnValueForXML:(NSMutableDictionary *)cmd;
- (id)convertedFeedReturnValueForRSSOrAtom:(NSMutableDictionary *)cmd;
- (id)JSONObjectFor:(NSMutableDictionary *)cmd;
- (FFXmlDocPtrWrapper *)FFXmlDocPtrWrapperFor:(NSMutableDictionary *)cmd;
#if FF_DTOP_ENV
- (NSXMLDocument *)NSXMLDocumentFor:(NSMutableDictionary *)cmd;
- (PSFeed *)PSFeedFor:(NSMutableDictionary *)cmd;
#endif
- (NSString *)responseBodyStringFor:(NSMutableDictionary *)cmd;

// error helpers
- (NSString *)errorCodeStringFromFeedResponseBodyString:(NSString *)responseBodyString;
- (NSString *)errorCodeStringFromXMLString:(NSString *)inString;
- (NSString *)errorCodeStringFromJSONString:(NSString *)inString;
	
// Delegate callbacks
- (void)didFetchPublicEntries:(NSMutableDictionary *)cmd;
- (void)didFetchEntriesForUser:(NSMutableDictionary *)cmd;
- (void)didFetchEntriesForUsers:(NSMutableDictionary *)cmd;
- (void)didFetchCommentsForUser:(NSMutableDictionary *)cmd;
- (void)didFetchLikesForUser:(NSMutableDictionary *)cmd;
- (void)didFetchDiscussionForUser:(NSMutableDictionary *)cmd;
- (void)didFetchFriendEntriesForUser:(NSMutableDictionary *)cmd;
- (void)didFetchEntriesForRoom:(NSMutableDictionary *)cmd;
- (void)didFetchEntry:(NSMutableDictionary *)cmd;
- (void)didFetchEntries:(NSMutableDictionary *)cmd;
- (void)didFetchHomeEntries:(NSMutableDictionary *)cmd;
- (void)didFetchRoomEntries:(NSMutableDictionary *)cmd;
- (void)didFetchEntriesForQuery:(NSMutableDictionary *)cmd;
- (void)didFetchEntriesForList:(NSMutableDictionary *)cmd;
- (void)didFetchEntriesAboutURLFromSubscribedOnly:(NSMutableDictionary *)cmd;
- (void)didFetchEntriesAboutURLFromNicknames:(NSMutableDictionary *)cmd;
- (void)didFetchEntriesForDomainsFromSubscribedOnly:(NSMutableDictionary *)cmd;
- (void)didFetchEntriesForDomainsFromNicknames:(NSMutableDictionary *)cmd;

- (void)didPostComment:(NSMutableDictionary *)cmd;
- (void)didEditComment:(NSMutableDictionary *)cmd;
- (void)didDeleteComment:(NSMutableDictionary *)cmd;
- (void)didUndeleteComment:(NSMutableDictionary *)cmd;
- (void)didPostLike:(NSMutableDictionary *)cmd;
- (void)didDeleteLike:(NSMutableDictionary *)cmd;
- (void)didDeleteEntry:(NSMutableDictionary *)cmd;
- (void)didUndeleteEntry:(NSMutableDictionary *)cmd;
- (void)didHideEntry:(NSMutableDictionary *)cmd;
- (void)didUnhideEntry:(NSMutableDictionary *)cmd;

@property (nonatomic, readwrite) FFDataType feedDataType;
@property (nonatomic, readwrite) FFReturnType feedReturnType;

@property (nonatomic, assign, readwrite) id <FFEngineDelegate>delegate;
@property (nonatomic, retain) NSMutableDictionary *callbackTable;
@end

@implementation FFEngineBaseImpl

- (id)initWithDelegate:(id <FFEngineDelegate>)d feedDataType:(FFDataType)dt feedReturnType:(FFReturnType)rt {
	self = [super init];
	if (self) {
		self.delegate = d;
		self.feedDataType = dt;
		self.feedReturnType = rt;
		self.callbackTable = [NSMutableDictionary dictionary];
	}
	return self;
}


- (void)dealloc {
	delegate = nil;
	self.callbackTable = nil;
    self.authUsername = nil;
    self.authPassword = nil;
	[super dealloc];
}


#pragma mark -
#pragma mark Abstract Methods

- (void)sendHTTPRequest:(NSMutableDictionary *)cmd {
	NSAssert1(0, @"-[FFEngineBaseImpl %s] is Abstract and must be overriden", _cmd);
}


#pragma mark -
#pragma mark Helper Methods

- (NSString *)stringForFeedDataType {
	switch (feedDataType) {
		case FFDataTypeXML:
			return @"xml";
		case FFDataTypeRSS:
			return @"rss";
		case FFDataTypeAtom:
			return @"atom";
		case FFDataTypeJSON:
		default:
			return @"json";
	}
}


- (NSString *)makeUniqueIdentifier {
	CFUUIDRef uuid = CFUUIDCreate(NULL);
	NSString *identifier = (id)CFUUIDCreateString(NULL, uuid);
	CFRelease(uuid);
	return [identifier autorelease];
}


- (NSString *)feedURLStringForPath:(NSString *)path service:(NSString *)service start:(NSUInteger)start num:(NSUInteger)num {
	NSString *URLString = [NSString stringWithFormat:@"%@%@?format=%@", kFFEngineFeedPrefix, path, [self stringForFeedDataType]];
	
	if (NSUIntegerMax != start) {
		URLString = [NSString stringWithFormat:@"%@&start=%d&num=%d", URLString, start, num];
	}
	
	if (service) {
		URLString = [NSString stringWithFormat:@"%@&service=%@", URLString, service];
	}
	
	return URLString;
}


- (NSString *)postURLStringForPath:(NSString *)path {
	NSString *URLString = [NSString stringWithFormat:@"%@%@?format=json&", kFFEnginePostPrefix, path];
	return URLString;
}


- (NSString *)fetchFeedFor:(NSMutableDictionary *)cmd callback:(SEL)sel {
	[cmd setObject:@"GET" forKey:HTTPRequestMethodKey];
	return [self sendRequestFor:cmd callback:sel];
}


- (NSString *)postDataFor:(NSMutableDictionary *)cmd callback:(SEL)sel {
	[cmd setObject:@"POST" forKey:HTTPRequestMethodKey];
	return [self sendRequestFor:cmd callback:sel];
}


- (NSString *)sendRequestFor:(NSMutableDictionary *)cmd callback:(SEL)sel {
	NSString *identifier = [self makeUniqueIdentifier];
	[cmd setObject:identifier forKey:FFIdentifierKey];
	
	[self sendHTTPRequest:cmd];
	
	[callbackTable setObject:NSStringFromSelector(sel) forKey:identifier];
	return identifier;
}


- (id)convertedFeedReturnValueFor:(NSMutableDictionary *)cmd {
	switch (feedDataType) {
		case FFDataTypeXML:
			return [self convertedFeedReturnValueForXML:cmd];
		case FFDataTypeRSS:
		case FFDataTypeAtom:
			return [self convertedFeedReturnValueForRSSOrAtom:cmd];
		case FFDataTypeJSON:
		default:
			return [self convertedFeedReturnValueForJSON:cmd];
	}
}


- (id)convertedFeedReturnValueForJSON:(NSMutableDictionary *)cmd {
	switch (feedReturnType) {
		case FFReturnTypeJSONValue:
			return [self JSONObjectFor:cmd];
		case FFReturnTypeNSString:
		case FFReturnTypePSFeed:
		case FFReturnTypeNSXMLDocument:
		default:
			return [self responseBodyStringFor:cmd];
	}
}


- (id)convertedFeedReturnValueForXML:(NSMutableDictionary *)cmd {
	switch (feedReturnType) {
		case FFReturnTypeFFXmlDocPtrWrapper:
			return [self FFXmlDocPtrWrapperFor:cmd];
#if FF_DTOP_ENV
		case FFReturnTypeNSXMLDocument:
			return [self NSXMLDocumentFor:cmd];
#endif
		case FFReturnTypeNSString:
		case FFReturnTypeJSONValue:
		case FFReturnTypePSFeed:
		default:
			return [self responseBodyStringFor:cmd];
	}
}


- (id)convertedFeedReturnValueForRSSOrAtom:(NSMutableDictionary *)cmd {
	switch (feedReturnType) {
		case FFReturnTypeFFXmlDocPtrWrapper:
			return [self FFXmlDocPtrWrapperFor:cmd];
#if FF_DTOP_ENV			
		case FFReturnTypeNSXMLDocument:
			return [self NSXMLDocumentFor:cmd];
		case FFReturnTypePSFeed:
			return [self PSFeedFor:cmd];
#endif
		case FFReturnTypeNSString:
		case FFReturnTypeJSONValue:
		default:
			return [self responseBodyStringFor:cmd];
	}
}


- (id)JSONObjectFor:(NSMutableDictionary *)cmd {
	NSString *responseBody = [self responseBodyStringFor:cmd];
	return [responseBody JSONValue];
}


- (FFXmlDocPtrWrapper *)FFXmlDocPtrWrapperFor:(NSMutableDictionary *)cmd {
	NSString *XMLString = [self responseBodyStringFor:cmd];
	NSString *baseURLString = [cmd objectForKey:HTTPResponseURLStringKey];
	xmlDocPtr xmlDoc = FFXmlDocPtrFromString(XMLString, baseURLString);
	return [FFXmlDocPtrWrapper wrapperWithXmlDoc:xmlDoc];
}


#if FF_DTOP_ENV
- (NSXMLDocument *)NSXMLDocumentFor:(NSMutableDictionary *)cmd {
	NSData *responseBodyData = [cmd objectForKey:HTTPResponseBodyDataKey];
	NSError *err = nil;
	NSXMLDocument *doc = [[[NSXMLDocument alloc] initWithData:responseBodyData options:NSXMLNodeOptionsNone error:&err] autorelease];
	return doc;
}


- (PSFeed *)PSFeedFor:(NSMutableDictionary *)cmd {
	NSData *responseBodyData = [cmd objectForKey:HTTPResponseBodyDataKey];
	NSString *finalURLString = [cmd objectForKey:HTTPResponseURLStringKey];
	PSFeed *feed = [[[PSFeed alloc] initWithData:responseBodyData URL:[NSURL URLWithString:finalURLString]] autorelease];
	return feed;
}
#endif

	
- (NSString *)responseBodyStringFor:(NSMutableDictionary *)cmd {
    NSStringEncoding encoding = [[cmd objectForKey:HTTPResponseBodyStringEncodingKey] unsignedIntegerValue];
    NSData *data = [cmd objectForKey:HTTPResponseBodyDataKey];
    NSString *result = [[[NSString alloc] initWithData:data encoding:encoding] autorelease];
    
    // if the result is nil, give it one last try with utf8 or preferrably latin1. 
    // ive seen this work for servers that lie (sideways glance at reddit.com)
    if (!result) {
        if (NSISOLatin1StringEncoding == encoding) {
            encoding = NSUTF8StringEncoding;
        } else {
            encoding = NSISOLatin1StringEncoding;
        }
        result = [[[NSString alloc] initWithData:data encoding:encoding] autorelease];
    }

    return result;
}


- (NSString *)errorCodeStringFromFeedResponseBodyString:(NSString *)responseBodyString {
	switch (feedDataType) {
		case FFDataTypeJSON:
			return [self errorCodeStringFromJSONString:responseBodyString];
		case FFDataTypeXML:
		case FFDataTypeRSS:
		case FFDataTypeAtom:
			return [self errorCodeStringFromXMLString:responseBodyString];
		default:
			return responseBodyString;
	}
}


- (NSString *)errorCodeStringFromXMLString:(NSString *)inString {
	xmlDocPtr doc = FFXmlDocPtrFromString(inString, nil);
	xmlNodePtr rootEl = xmlDocGetRootElement(doc);
	xmlNodePtr errorCodeEl = xmlGetLastChild(rootEl);
	const xmlChar *errCodeStr = xmlNodeGetContent(errorCodeEl);
	if (errCodeStr) {
		NSString *result = [NSString stringWithUTF8String:(const char *)errCodeStr];
		xmlFree((void *)errCodeStr);
		errCodeStr = NULL;
		return result;
	} else {
		return inString;
	}
}


- (NSString *)errorCodeStringFromJSONString:(NSString *)inString {
	NSDictionary *JSONValue = [inString JSONValue];
	if (!JSONValue) return inString;
	
	NSString *result = [JSONValue objectForKey:@"errorCode"];
	if (result.length) {
		return result;
	} else {
		return inString;
	}
}


#pragma mark -
#pragma mark FFEngine

- (void)setUsername:(NSString *)u remoteKeyPassword:(NSString *)p {
	NSParameterAssert(u);
	NSParameterAssert(p);
	self.authUsername = u;
	self.authPassword = p;
	
//	NSURL *URL = [NSURL URLWithString:@"http://friendfeed.com"];
//	SecKeychainItemRef item = [self keychainItemForURL:URL getPasswordString:nil forProxy:NO];
//	[self addAuthToKeychainItem:item forURL:URL realm:@"friendfeed.com" forProxy:NO];
}

// /api/feed/public
- (NSString *)fetchPublicEntriesForService:(NSString *)service start:(NSUInteger)start num:(NSUInteger)num {
	NSString *URLString = [self feedURLStringForPath:@"public" service:service start:start num:num];
	NSMutableDictionary *cmd = [NSMutableDictionary dictionaryWithObjectsAndKeys:
								URLString, HTTPRequestURLStringKey,
								nil];
	return [self fetchFeedFor:cmd callback:@selector(didFetchPublicEntries:)];
}

// /api/feed/user/NICKNAME
- (NSString *)fetchEntriesForUser:(NSString *)username service:(NSString *)service start:(NSUInteger)start num:(NSUInteger)num {
	NSParameterAssert(username);
	NSString *path = [NSString stringWithFormat:@"user/%@", username];
	NSString *URLString = [self feedURLStringForPath:path service:service start:start num:num];
	NSMutableDictionary *cmd = [NSMutableDictionary dictionaryWithObjectsAndKeys:
								URLString, HTTPRequestURLStringKey,
								username, FFNicknameKey,
								nil];	
	return [self fetchFeedFor:cmd callback:@selector(didFetchEntriesForUser:)];
}

// /api/feed/user?nickname=bret,paul,jim
- (NSString *)fetchEntriesForUsers:(NSArray *)usernames service:(NSString *)service start:(NSUInteger)start num:(NSUInteger)num {
	NSParameterAssert(usernames.count);
	NSString *URLString = [self feedURLStringForPath:@"user" service:service start:start num:num];
	URLString = [NSString stringWithFormat:@"%@&nickname=%@", URLString, [usernames componentsJoinedByString:@","]];
	NSMutableDictionary *cmd = [NSMutableDictionary dictionaryWithObjectsAndKeys:
								URLString, HTTPRequestURLStringKey,
								usernames, FFNicknameKey,
								nil];	
	return [self fetchFeedFor:cmd callback:@selector(didFetchEntriesForUsers:)];
}

// /api/feed/user/NICKNAME/comments
- (NSString *)fetchCommentsForUser:(NSString *)username service:(NSString *)service start:(NSUInteger)start num:(NSUInteger)num {
	NSParameterAssert(username);
	NSString *path = [NSString stringWithFormat:@"user/%@/comments", username];
	NSString *URLString = [self feedURLStringForPath:path service:service start:start num:num];
	NSMutableDictionary *cmd = [NSMutableDictionary dictionaryWithObjectsAndKeys:
								URLString, HTTPRequestURLStringKey,
								nil];	
	return [self fetchFeedFor:cmd callback:@selector(didFetchCommentsForUser:)];
}

// /api/feed/user/NICKNAME/likes
- (NSString *)fetchLikesForUser:(NSString *)username service:(NSString *)service start:(NSUInteger)start num:(NSUInteger)num {
	NSParameterAssert(username);
	NSString *path = [NSString stringWithFormat:@"user/%@/likes", username];
	NSString *URLString = [self feedURLStringForPath:path service:service start:start num:num];
	NSMutableDictionary *cmd = [NSMutableDictionary dictionaryWithObjectsAndKeys:
								URLString, HTTPRequestURLStringKey,
								nil];	
	return [self fetchFeedFor:cmd callback:@selector(didFetchLikesForUser:)];
}

// /api/feed/user/NICKNAME/discussion
- (NSString *)fetchDiscussionForUser:(NSString *)username service:(NSString *)service start:(NSUInteger)start num:(NSUInteger)num {
	NSParameterAssert(username);
	NSString *path = [NSString stringWithFormat:@"user/%@/discussion", username];
	NSString *URLString = [self feedURLStringForPath:path service:service start:start num:num];
	NSMutableDictionary *cmd = [NSMutableDictionary dictionaryWithObjectsAndKeys:
								URLString, HTTPRequestURLStringKey,
								username, FFNicknameKey,
								nil];	
	return [self fetchFeedFor:cmd callback:@selector(didFetchDiscussionForUser:)];
}

// /api/feed/user/NICKNAME/friends
- (NSString *)fetchFriendEntriesForUser:(NSString *)username service:(NSString *)service start:(NSUInteger)start num:(NSUInteger)num {
	NSParameterAssert(username);
	NSString *path = [NSString stringWithFormat:@"user/%@/friends", username];
	NSString *URLString = [self feedURLStringForPath:path service:service start:start num:num];
	NSMutableDictionary *cmd = [NSMutableDictionary dictionaryWithObjectsAndKeys:
								URLString, HTTPRequestURLStringKey,
								username, FFNicknameKey,
								nil];	
	return [self fetchFeedFor:cmd callback:@selector(didFetchFriendEntriesForUser:)];
}

// /api/feed/room/NICKNAME - Fetch Entries from a Room
- (NSString *)fetchEntriesForRoom:(NSString *)roomname service:(NSString *)service start:(NSUInteger)start num:(NSUInteger)num {
	NSParameterAssert(roomname);
	NSString *path = [NSString stringWithFormat:@"room/%@", roomname];
	NSString *URLString = [self feedURLStringForPath:path service:service start:start num:num];
	NSMutableDictionary *cmd = [NSMutableDictionary dictionaryWithObjectsAndKeys:
								URLString, HTTPRequestURLStringKey,
								roomname, FFNicknameKey,
								nil];	
	return [self fetchFeedFor:cmd callback:@selector(didFetchEntriesForRoom:)];
}

// /api/feed/entry/ENTRYID - Fetch Entry by id
- (NSString *)fetchEntry:(NSString *)entryID {
	NSParameterAssert(entryID);
	NSString *path = [NSString stringWithFormat:@"entry/%@", entryID];
	NSString *URLString = [self feedURLStringForPath:path service:nil start:NSUIntegerMax num:NSUIntegerMax];
	NSMutableDictionary *cmd = [NSMutableDictionary dictionaryWithObjectsAndKeys:
								URLString, HTTPRequestURLStringKey,
								entryID, FFEntryIDKey,
								nil];	
	return [self fetchFeedFor:cmd callback:@selector(didFetchEntry:)];
}

// /api/feed/entry?entry_id=7ad57cd3-30e6-253a-c745-6345b1bd0e78,6f6a36d2-a6c6-fbe7-6bb2-f328c8794eea
- (NSString *)fetchEntries:(NSArray *)entryIDs {
	NSParameterAssert(entryIDs.count);
	NSString *URLString = [self feedURLStringForPath:@"entry" service:nil start:NSUIntegerMax num:NSUIntegerMax];
	URLString = [NSString stringWithFormat:@"%@&entry_id=%@", URLString, [entryIDs componentsJoinedByString:@","]];
	NSMutableDictionary *cmd = [NSMutableDictionary dictionaryWithObjectsAndKeys:
								URLString, HTTPRequestURLStringKey,
								entryIDs, FFEntryIDsKey,
								nil];	
	return [self fetchFeedFor:cmd callback:@selector(didFetchEntries:)];
}

// api/feed/home
- (NSString *)fetchHomeEntriesForService:(NSString *)service start:(NSUInteger)start num:(NSUInteger)num {
	NSString *URLString = [self feedURLStringForPath:@"home" service:service start:start num:num];
	NSMutableDictionary *cmd = [NSMutableDictionary dictionaryWithObjectsAndKeys:
								URLString, HTTPRequestURLStringKey,
								nil];	
	return [self fetchFeedFor:cmd callback:@selector(didFetchHomeEntries:)];
}

// /api/feed/rooms
- (NSString *)fetchRoomsEntriesForService:(NSString *)service start:(NSUInteger)start num:(NSUInteger)num {
	NSString *URLString = [self feedURLStringForPath:@"rooms" service:service start:start num:num];
	NSMutableDictionary *cmd = [NSMutableDictionary dictionaryWithObjectsAndKeys:
								URLString, HTTPRequestURLStringKey,
								nil];	
	return [self fetchFeedFor:cmd callback:@selector(didFetchRoomEntries:)];
}

// /api/feed/search?q=friendfeed
- (NSString *)fetchEntriesForQuery:(NSString *)query start:(NSUInteger)start num:(NSUInteger)num; {
	NSParameterAssert(query);
	NSString *URLString = [self feedURLStringForPath:@"search" service:nil start:start num:num];
	URLString = [NSString stringWithFormat:@"%@&q=%@", URLString, query];
	NSMutableDictionary *cmd = [NSMutableDictionary dictionaryWithObjectsAndKeys:
								URLString, HTTPRequestURLStringKey,
								query, FFQueryKey,
								nil];	
	return [self fetchFeedFor:cmd callback:@selector(didFetchEntriesForQuery:)];
}

// /api/feed/list/NICKNAME
- (NSString *)fetchEntriesForList:(NSString *)listname service:(NSString *)service start:(NSUInteger)start num:(NSUInteger)num {
	NSParameterAssert(listname);
	NSString *path = [NSString stringWithFormat:@"list/%@", listname];
	NSString *URLString = [self feedURLStringForPath:path service:service start:start num:num];
	NSMutableDictionary *cmd = [NSMutableDictionary dictionaryWithObjectsAndKeys:
								URLString, HTTPRequestURLStringKey,
								listname, FFNicknameKey,
								nil];	
	return [self fetchFeedFor:cmd callback:@selector(didFetchEntriesForList:)];
}

// service not currently supported
// /api/feed/url?url=http://blog.friendfeed.com/2008/08/simple-update-protocol-fetch-updates.html&subscribed=1
- (NSString *)fetchEntriesAboutURL:(NSString *)inURLString fromSubscribedOnly:(BOOL)subscribedOnly start:(NSUInteger)start num:(NSUInteger)num {
	NSParameterAssert(inURLString);
	NSString *URLString = [self feedURLStringForPath:@"url" service:nil start:start num:num];
	URLString = [NSString stringWithFormat:@"%@&url=%@&subscribed=%d", URLString, inURLString, subscribedOnly];
	NSMutableDictionary *cmd = [NSMutableDictionary dictionaryWithObjectsAndKeys:
								URLString, HTTPRequestURLStringKey,
								inURLString, FFURLStringKey,
								[NSNumber numberWithBool:subscribedOnly], FFSubscribedOnlyKey,
								nil];	
	return [self fetchFeedFor:cmd callback:@selector(didFetchEntriesAboutURLFromSubscribedOnly:)];
}

// service not currently supported
// /api/feed/url?url=http://blog.friendfeed.com/2008/08/simple-update-protocol-fetch-updates.html&nickname=bret,friendfeed-news
- (NSString *)fetchEntriesAboutURL:(NSString *)inURLString fromNicknames:(NSArray *)usernamesAndRoomnames start:(NSUInteger)start num:(NSUInteger)num {
	NSParameterAssert(inURLString);
	NSString *URLString = [self feedURLStringForPath:@"url" service:nil start:start num:num];
	URLString = [NSString stringWithFormat:@"%@&url=%@&nicknames=%@", URLString, inURLString, [usernamesAndRoomnames componentsJoinedByString:@","]];
	NSMutableDictionary *cmd = [NSMutableDictionary dictionaryWithObjectsAndKeys:
								URLString, HTTPRequestURLStringKey,
								inURLString, FFURLStringKey,
								usernamesAndRoomnames, FFNicknameKey,
								nil];	
	return [self fetchFeedFor:cmd callback:@selector(didFetchEntriesAboutURLFromNicknames:)];
}

// service not currently supported
// /api/feed/domain?domain=blog.friendfeed.com,code.google.com
- (NSString *)fetchEntriesForDomains:(NSArray *)domains inexactMatch:(BOOL)inexactMatch fromSubscribedOnly:(BOOL)subscribedOnly start:(NSUInteger)start num:(NSUInteger)num {
	NSParameterAssert(domains.count);
	NSString *URLString = [self feedURLStringForPath:@"domain" service:nil start:start num:num];
	URLString = [NSString stringWithFormat:@"%@&domain=%@&subscribed=%d", URLString, [domains componentsJoinedByString:@","], subscribedOnly];
	NSMutableDictionary *cmd = [NSMutableDictionary dictionaryWithObjectsAndKeys:
								URLString, HTTPRequestURLStringKey,
								domains, FFDomainsKey,
								[NSNumber numberWithBool:inexactMatch], FFInexactMatchKey,
								[NSNumber numberWithBool:subscribedOnly], FFSubscribedOnlyKey,
								nil];	
	return [self fetchFeedFor:cmd callback:@selector(didFetchEntriesForDomainsFromSubscribedOnly:)];
}

// service not currently supported
// /api/feed/domain?domain=blog.friendfeed.com,code.google.com&nickname=bret,friendfeed-news
- (NSString *)fetchEntriesForDomains:(NSArray *)domains inexactMatch:(BOOL)inexactMatch fromNicknames:(NSArray *)usernamesAndRoomnames start:(NSUInteger)start num:(NSUInteger)num {
	NSParameterAssert(domains.count);
	NSString *URLString = [self feedURLStringForPath:@"domain" service:nil start:start num:num];
	URLString = [NSString stringWithFormat:@"%@&domain=%@&nicknames=%@", URLString, [domains componentsJoinedByString:@","], [usernamesAndRoomnames componentsJoinedByString:@","]];
	NSMutableDictionary *cmd = [NSMutableDictionary dictionaryWithObjectsAndKeys:
								URLString, HTTPRequestURLStringKey,
								domains, FFDomainsKey,
								[NSNumber numberWithBool:inexactMatch], FFInexactMatchKey,
								usernamesAndRoomnames, FFNicknameKey,
								nil];	
	return [self fetchFeedFor:cmd callback:@selector(didFetchEntriesForDomainsFromNicknames:)];
}


#pragma mark -
#pragma mark Write

// /api/comment - Add or Edit Comments
//	entry - required - The FriendFeed UUID of the entry to which this comment is attached.
//	body - required - The textual body of the comment.
//	comment - If given, the FriendFeed UUID of the comment to edit. If not given, the request will create a new comment.
- (NSString *)postCommentOnEntry:(NSString *)entryID withBody:(NSString *)body {
	NSParameterAssert(entryID);
	NSParameterAssert(body);
	NSString *URLString = [self postURLStringForPath:@"comment"];
	URLString = [NSString stringWithFormat:@"%@entry=%@&body=%@", URLString, entryID, [body stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
	NSMutableDictionary *cmd = [NSMutableDictionary dictionaryWithObjectsAndKeys:
								URLString, HTTPRequestURLStringKey,
								entryID, FFEntryIDKey,
								nil];	
	return [self postDataFor:cmd callback:@selector(didPostComment:)];
}


- (NSString *)editComment:(NSString *)commentID onEntry:(NSString *)entryID withBody:(NSString *)body {
	NSParameterAssert(commentID);
	NSParameterAssert(entryID);
	NSParameterAssert(body);
	NSString *URLString = [self postURLStringForPath:@"comment"];
	URLString = [NSString stringWithFormat:@"%@entry=%@&comment=%@&body=%@", URLString, entryID, commentID, [body stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
	NSMutableDictionary *cmd = [NSMutableDictionary dictionaryWithObjectsAndKeys:
								URLString, HTTPRequestURLStringKey,
								entryID, FFEntryIDKey,
								commentID, FFCommentIDKey,
								nil];	
	return [self postDataFor:cmd callback:@selector(didEditComment:)];
}

// /api/comment/delete - Delete a Comment
//	entry - required - The FriendFeed UUID of the entry to which this comment is attached.
//	comment - required - The FriendFeed UUID of the comment to delete.
- (NSString *)deleteComment:(NSString *)commentID onEntry:(NSString *)entryID {
	NSParameterAssert(commentID);
	NSParameterAssert(entryID);
	NSString *URLString = [self postURLStringForPath:@"comment/delete"];
	URLString = [NSString stringWithFormat:@"%@entry=%@&comment=%@", URLString, entryID, commentID];
	NSMutableDictionary *cmd = [NSMutableDictionary dictionaryWithObjectsAndKeys:
								URLString, HTTPRequestURLStringKey,
								entryID, FFEntryIDKey,
								commentID, FFCommentIDKey,
								nil];	
	return [self postDataFor:cmd callback:@selector(didDeleteComment:)];
}


- (NSString *)undeleteComment:(NSString *)commentID onEntry:(NSString *)entryID {
	NSParameterAssert(commentID);
	NSParameterAssert(entryID);
	NSString *URLString = [self postURLStringForPath:@"comment/delete"];
	URLString = [NSString stringWithFormat:@"%@entry=%@&comment=%@&undelete=1", URLString, entryID, commentID];
	NSMutableDictionary *cmd = [NSMutableDictionary dictionaryWithObjectsAndKeys:
								URLString, HTTPRequestURLStringKey,
								entryID, FFEntryIDKey,
								commentID, FFCommentIDKey,
								nil];	
	return [self postDataFor:cmd callback:@selector(didUndeleteComment:)];
}

// /api/like - "Like" an Entry
//	entry - required - The FriendFeed UUID of the entry to which this comment is attached
- (NSString *)postLikeOnEntry:(NSString *)entryID {
	NSParameterAssert(entryID);
	NSString *URLString = [self postURLStringForPath:@"like"];
	URLString = [NSString stringWithFormat:@"%@entry=%@", URLString, entryID];
	NSMutableDictionary *cmd = [NSMutableDictionary dictionaryWithObjectsAndKeys:
								URLString, HTTPRequestURLStringKey,
								entryID, FFEntryIDKey,
								nil];	
	return [self postDataFor:cmd callback:@selector(didPostLike:)];
}

// /api/like/delete - Delete a "Like"
- (NSString *)deleteLikeOnEntry:(NSString *)entryID {
	NSParameterAssert(entryID);
	NSString *URLString = [self postURLStringForPath:@"like/delete"];
	URLString = [NSString stringWithFormat:@"%@entry=%@", URLString, entryID];
	NSMutableDictionary *cmd = [NSMutableDictionary dictionaryWithObjectsAndKeys:
								URLString, HTTPRequestURLStringKey,
								entryID, FFEntryIDKey,
								nil];	
	return [self postDataFor:cmd callback:@selector(didDeleteLike:)];
}

// /api/entry/delete - Delete an Entry
// entry - required - The FriendFeed UUID of the entry to delete
// undelete - optional - if given, un-delete the given entry if it is already deleted
- (NSString *)deleteEntry:(NSString *)entryID {
	NSParameterAssert(entryID);
	NSString *URLString = [self postURLStringForPath:@"entry/delete"];
	URLString = [NSString stringWithFormat:@"%@entry=%@", URLString, entryID];
	NSMutableDictionary *cmd = [NSMutableDictionary dictionaryWithObjectsAndKeys:
								URLString, HTTPRequestURLStringKey,
								entryID, FFEntryIDKey,
								nil];	
	return [self postDataFor:cmd callback:@selector(didDeleteEntry:)];
}


- (NSString *)undeleteEntry:(NSString *)entryID {
	NSParameterAssert(entryID);
	NSString *URLString = [self postURLStringForPath:@"entry/delete"];
	URLString = [NSString stringWithFormat:@"%@entry=%@&undelete=1", URLString, entryID];
	NSMutableDictionary *cmd = [NSMutableDictionary dictionaryWithObjectsAndKeys:
								URLString, HTTPRequestURLStringKey,
								entryID, FFEntryIDKey,
								nil];	
	return [self postDataFor:cmd callback:@selector(didUndeleteEntry:)];
}

// /api/entry/hide - Hide an Entry
// entry - required - The FriendFeed UUID of the entry to delete
// unhide - optional - if given, un-hide the given entry if it is already hidden
- (NSString *)hideEntry:(NSString *)entryID {
	NSParameterAssert(entryID);
	NSString *URLString = [self postURLStringForPath:@"entry/hide"];
	URLString = [NSString stringWithFormat:@"%@entry=%@", URLString, entryID];
	NSMutableDictionary *cmd = [NSMutableDictionary dictionaryWithObjectsAndKeys:
								URLString, HTTPRequestURLStringKey,
								entryID, FFEntryIDKey,
								nil];	
	return [self postDataFor:cmd callback:@selector(didHideEntry:)];
}


- (NSString *)unhideEntry:(NSString *)entryID {
	NSParameterAssert(entryID);
	NSString *URLString = [self postURLStringForPath:@"entry/hide"];
	URLString = [NSString stringWithFormat:@"%@entry=%@&unhide=1", URLString, entryID];
	NSMutableDictionary *cmd = [NSMutableDictionary dictionaryWithObjectsAndKeys:
								URLString, HTTPRequestURLStringKey,
								entryID, FFEntryIDKey,
								nil];	
	return [self postDataFor:cmd callback:@selector(didUnhideEntry:)];
}


#pragma mark -
#pragma mark HTTP Callbacks

- (void)success:(NSMutableDictionary *)cmd {
	NSString *identifier = [cmd objectForKey:FFIdentifierKey];
	SEL callback = NSSelectorFromString([callbackTable objectForKey:identifier]);

	id returnValue = nil;
	NSString *method = [cmd objectForKey:HTTPRequestMethodKey];
	if ([@"POST" isEqualToString:method]) {
		returnValue = [self JSONObjectFor:cmd];
	} else {
		returnValue = [self convertedFeedReturnValueFor:cmd];
	}
		
	[cmd setObject:returnValue forKey:FFReturnValueKey];

	[self performSelector:callback withObject:cmd];
}


- (void)failure:(NSMutableDictionary *)cmd {
	NSString *responseBodyString = [self responseBodyStringFor:cmd];
	NSString *errorCodeString = nil;
	NSString *method = [cmd objectForKey:HTTPRequestMethodKey];
	if ([@"POST" isEqualToString:method]) {
		errorCodeString = [self errorCodeStringFromJSONString:responseBodyString];
	} else {
		errorCodeString = [self errorCodeStringFromFeedResponseBodyString:responseBodyString];
	}
	NSInteger statusCode = [[cmd objectForKey:HTTPResponseStatusCodeKey] integerValue];
	FFError *error = [FFError errorWithResponseStatusCode:statusCode errorCodeString:errorCodeString];
	NSString *identifier = [cmd objectForKey:FFIdentifierKey];
	[delegate request:identifier didFailWithError:error];
}


#pragma mark -
#pragma mark Read Callbacks

- (void)didFetchPublicEntries:(NSMutableDictionary *)cmd {
	NSString *identifier = [cmd objectForKey:FFIdentifierKey];
	id returnValue = [cmd objectForKey:FFReturnValueKey];
	[delegate request:identifier didFetchPublicEntries:returnValue];
}


- (void)didFetchEntriesForUser:(NSMutableDictionary *)cmd {
	NSString *identifier = [cmd objectForKey:FFIdentifierKey];
	id returnValue = [cmd objectForKey:FFReturnValueKey];
	NSString *username = [cmd objectForKey:FFNicknameKey];
	[delegate request:identifier didFetchEntries:returnValue forUser:username];
}


- (void)didFetchEntriesForUsers:(NSMutableDictionary *)cmd {
	NSString *identifier = [cmd objectForKey:FFIdentifierKey];
	id returnValue = [cmd objectForKey:FFReturnValueKey];
	NSArray *usernames = [cmd objectForKey:FFNicknameKey];
	[delegate request:identifier didFetchEntries:returnValue forUsers:usernames];
}


- (void)didFetchCommentsForUser:(NSMutableDictionary *)cmd {
	NSString *identifier = [cmd objectForKey:FFIdentifierKey];
	id returnValue = [cmd objectForKey:FFReturnValueKey];
	NSString *username = [cmd objectForKey:FFNicknameKey];
	[delegate request:identifier didFetchComments:returnValue forUser:username];
}


- (void)didFetchLikesForUser:(NSMutableDictionary *)cmd {
	NSString *identifier = [cmd objectForKey:FFIdentifierKey];
	id returnValue = [cmd objectForKey:FFReturnValueKey];
	NSString *username = [cmd objectForKey:FFNicknameKey];
	[delegate request:identifier didFetchLikes:returnValue forUser:username];
}


- (void)didFetchDiscussionForUser:(NSMutableDictionary *)cmd {
	NSString *identifier = [cmd objectForKey:FFIdentifierKey];
	id returnValue = [cmd objectForKey:FFReturnValueKey];
	NSString *username = [cmd objectForKey:FFNicknameKey];
	[delegate request:identifier didFetchDiscussion:returnValue forUser:username];
}


- (void)didFetchFriendEntriesForUser:(NSMutableDictionary *)cmd {
	NSString *identifier = [cmd objectForKey:FFIdentifierKey];
	id returnValue = [cmd objectForKey:FFReturnValueKey];
	NSString *username = [cmd objectForKey:FFNicknameKey];
	[delegate request:identifier didFetchFriendEntries:returnValue forUser:username];
}


- (void)didFetchEntriesForRoom:(NSMutableDictionary *)cmd {
	NSString *identifier = [cmd objectForKey:FFIdentifierKey];
	id returnValue = [cmd objectForKey:FFReturnValueKey];
	NSString *roomname = [cmd objectForKey:FFNicknameKey];
	[delegate request:identifier didFetchEntries:returnValue forRoom:roomname];
}


- (void)didFetchEntry:(NSMutableDictionary *)cmd {
	NSString *identifier = [cmd objectForKey:FFIdentifierKey];
	id returnValue = [cmd objectForKey:FFReturnValueKey];
	NSString *entryID = [cmd objectForKey:FFEntryIDKey];
	[delegate request:identifier didFetchEntry:returnValue forID:entryID];
}


- (void)didFetchEntries:(NSMutableDictionary *)cmd {
	NSString *identifier = [cmd objectForKey:FFIdentifierKey];
	id returnValue = [cmd objectForKey:FFReturnValueKey];
	NSArray *entryIDs = [cmd objectForKey:FFEntryIDsKey];
	[delegate request:identifier didFetchEntries:returnValue forIDs:entryIDs];
}


- (void)didFetchHomeEntries:(NSMutableDictionary *)cmd {
	NSString *identifier = [cmd objectForKey:FFIdentifierKey];
	id returnValue = [cmd objectForKey:FFReturnValueKey];
	[delegate request:identifier didFetchHomeEntries:returnValue];
}


- (void)didFetchRoomEntries:(NSMutableDictionary *)cmd {
	NSString *identifier = [cmd objectForKey:FFIdentifierKey];
	id returnValue = [cmd objectForKey:FFReturnValueKey];
	NSString *roomname = [cmd objectForKey:FFNicknameKey];
	[delegate request:identifier didFetchEntries:returnValue forRoom:roomname];
}


- (void)didFetchEntriesForQuery:(NSMutableDictionary *)cmd {
	NSString *identifier = [cmd objectForKey:FFIdentifierKey];
	id returnValue = [cmd objectForKey:FFReturnValueKey];
	NSString *query = [cmd objectForKey:FFQueryKey];
	[delegate request:identifier didFetchEntries:returnValue forQuery:query];
}


- (void)didFetchEntriesForList:(NSMutableDictionary *)cmd {
	NSString *identifier = [cmd objectForKey:FFIdentifierKey];
	id returnValue = [cmd objectForKey:FFReturnValueKey];
	NSString *listname = [cmd objectForKey:FFNicknameKey];
	[delegate request:identifier didFetchEntries:returnValue forList:listname];
}


- (void)didFetchEntriesAboutURLFromSubscribedOnly:(NSMutableDictionary *)cmd {
	NSString *identifier = [cmd objectForKey:FFIdentifierKey];
	id returnValue = [cmd objectForKey:FFReturnValueKey];
	NSString *URLString = [cmd objectForKey:FFURLStringKey];
	BOOL subscribedOnly = [[cmd objectForKey:FFSubscribedOnlyKey] boolValue];
	[delegate request:identifier didFetchEntries:returnValue aboutURL:URLString fromSubscribedOnly:subscribedOnly];
}


- (void)didFetchEntriesAboutURLFromNicknames:(NSMutableDictionary *)cmd {
	NSString *identifier = [cmd objectForKey:FFIdentifierKey];
	id returnValue = [cmd objectForKey:FFReturnValueKey];
	NSString *URLString = [cmd objectForKey:FFURLStringKey];
	NSArray *nicknames = [cmd objectForKey:FFNicknameKey];
	[delegate request:identifier didFetchEntries:returnValue aboutURL:URLString fromNicknames:nicknames];
}


- (void)didFetchEntriesForDomainsFromSubscribedOnly:(NSMutableDictionary *)cmd {
	NSString *identifier = [cmd objectForKey:FFIdentifierKey];
	id returnValue = [cmd objectForKey:FFReturnValueKey];
	NSArray *domains = [cmd objectForKey:FFDomainsKey];
	BOOL inexactMatch = [[cmd objectForKey:FFInexactMatchKey] boolValue];
	BOOL subscribedOnly = [[cmd objectForKey:FFSubscribedOnlyKey] boolValue];
	[delegate request:identifier didFetchEntries:returnValue forDomains:domains inexactMatch:inexactMatch fromSubscribedOnly:subscribedOnly];
}


- (void)didFetchEntriesForDomainsFromNicknames:(NSMutableDictionary *)cmd {
	NSString *identifier = [cmd objectForKey:FFIdentifierKey];
	id returnValue = [cmd objectForKey:FFReturnValueKey];
	NSArray *domains = [cmd objectForKey:FFDomainsKey];
	BOOL inexactMatch = [[cmd objectForKey:FFInexactMatchKey] boolValue];
	NSArray *nicknames = [cmd objectForKey:FFNicknameKey];
	[delegate request:identifier didFetchEntries:returnValue forDomains:domains inexactMatch:inexactMatch fromNicknames:nicknames];
}


#pragma mark -
#pragma mark Write Callbacks

- (void)didPostComment:(NSMutableDictionary *)cmd {
	NSString *identifier = [cmd objectForKey:FFIdentifierKey];
	id returnValue = [cmd objectForKey:FFReturnValueKey];
	NSString *entryID = [cmd objectForKey:FFEntryIDKey];
	[delegate request:identifier didPostComment:returnValue onEntry:entryID];
}


- (void)didEditComment:(NSMutableDictionary *)cmd {
	NSString *identifier = [cmd objectForKey:FFIdentifierKey];
	id returnValue = [cmd objectForKey:FFReturnValueKey];
	NSString *entryID = [cmd objectForKey:FFEntryIDKey];
	[delegate request:identifier didEditComment:returnValue onEntry:entryID];
}


- (void)didDeleteComment:(NSMutableDictionary *)cmd {
	NSString *identifier = [cmd objectForKey:FFIdentifierKey];
	id returnValue = [cmd objectForKey:FFReturnValueKey];
	NSString *entryID = [cmd objectForKey:FFEntryIDKey];
	[delegate request:identifier didDeleteComment:returnValue onEntry:entryID];
}


- (void)didUndeleteComment:(NSMutableDictionary *)cmd {
	NSString *identifier = [cmd objectForKey:FFIdentifierKey];
	id returnValue = [cmd objectForKey:FFReturnValueKey];
	NSString *entryID = [cmd objectForKey:FFEntryIDKey];
	[delegate request:identifier didUndeleteComment:returnValue onEntry:entryID];
}


- (void)didPostLike:(NSMutableDictionary *)cmd {
	NSString *identifier = [cmd objectForKey:FFIdentifierKey];
	NSString *entryID = [cmd objectForKey:FFEntryIDKey];
	[delegate request:identifier didPostLikeOnEntry:entryID];
}


- (void)didDeleteLike:(NSMutableDictionary *)cmd {
	NSString *identifier = [cmd objectForKey:FFIdentifierKey];
	NSString *entryID = [cmd objectForKey:FFEntryIDKey];
	[delegate request:identifier didDeleteLikeOnEntry:entryID];
}


- (void)didDeleteEntry:(NSMutableDictionary *)cmd {
	NSString *identifier = [cmd objectForKey:FFIdentifierKey];
	id returnValue = [cmd objectForKey:FFReturnValueKey];
	NSString *entryID = [cmd objectForKey:FFEntryIDKey];
	[delegate request:identifier didDeleteEntry:returnValue forID:entryID];
}


- (void)didUndeleteEntry:(NSMutableDictionary *)cmd {
	NSString *identifier = [cmd objectForKey:FFIdentifierKey];
	id returnValue = [cmd objectForKey:FFReturnValueKey];
	NSString *entryID = [cmd objectForKey:FFEntryIDKey];
	[delegate request:identifier didUndeleteEntry:returnValue forID:entryID];
}


- (void)didHideEntry:(NSMutableDictionary *)cmd {
	NSString *identifier = [cmd objectForKey:FFIdentifierKey];
	id returnValue = [cmd objectForKey:FFReturnValueKey];
	NSString *entryID = [cmd objectForKey:FFEntryIDKey];
	[delegate request:identifier didHideEntry:returnValue forID:entryID];
}


- (void)didUnhideEntry:(NSMutableDictionary *)cmd {
	NSString *identifier = [cmd objectForKey:FFIdentifierKey];
	id returnValue = [cmd objectForKey:FFReturnValueKey];
	NSString *entryID = [cmd objectForKey:FFEntryIDKey];
	[delegate request:identifier didUnhideEntry:returnValue forID:entryID];
}

@synthesize delegate;
@synthesize feedDataType;
@synthesize feedReturnType;
@synthesize callbackTable;
@synthesize authUsername;
@synthesize authPassword;
@end
