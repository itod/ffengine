//
//  FFEngineBaseImpl+BasicAuth.m
//  FFEngine
//
//  Created by Todd Ditchendorf on 1/19/09.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import "FFEngineBaseImpl+BasicAuth.h"

@implementation FFEngineBaseImpl (BasicAuth)

- (BOOL)getUsername:(NSString **)uname password:(NSString **)passwd forAuthScheme:(NSString *)scheme URL:(NSURL *)URL realm:(NSString *)realm domain:(NSURL *)domain forProxy:(BOOL)forProxy isRetry:(BOOL)isRetry {
    if (uname) {
        *uname = @"itod";
    }
    if (passwd) {
        *passwd = @"ham64hew";
    }
    return NO;
//    BOOL cancelled = NO;
//    self.authPassword = nil;
//    
//    // check keychain for auth creds first. use those if they exist
//    NSString *passwordString = nil;
//    SecKeychainItemRef keychainItem = [self keychainItemForURL:URL getPasswordString:&passwordString forProxy:forProxy];
//	
//    if (keychainItem && !isRetry) {
//        NSString *accountString = [self accountNameFromKeychainItem:keychainItem];
//        //NSLog(@"found username and password in keychain!!!! %@, %@", accountString, passwordString);
//        self.authUsername = accountString;
//        self.authPassword = passwordString;
//    } else {
//		cancelled = YES;
//		// NO auth credentials found, present UI
//    }
//    
//    if (keychainItem) {
//        CFRelease(keychainItem);
//    }
//    
//    // finally, return username and password
//	if (uname) {
//		(*uname)  = (authUsername) ? [[authUsername copy] autorelease] : @"";
//	}
//	if (passwd) {
//		(*passwd) = (authPassword) ? [[authPassword copy] autorelease] : @"";
//	}
//    
//    return cancelled;
}


//- (SecKeychainItemRef)keychainItemForURL:(NSURL *)URL getPasswordString:(NSString **)passwordString forProxy:(BOOL)forProxy {
//    SecKeychainItemRef result = NULL;
//    
//    NSString *host = URL.host;
//    UInt16 port = URL.port.integerValue;
//    OSType protocol = [self protocolForURL:URL isProxy:forProxy];
//    void *passwordData;
//    UInt32 len;
//    OSStatus status = SecKeychainFindInternetPassword(NULL,
//                                                      host.length,
//                                                      host.UTF8String,
//                                                      0, //realm.length,
//                                                      NULL, //realm.UTF8String,
//                                                      0, //acctName.length,
//                                                      NULL, //acctName.UTF8String,
//                                                      0, //path.length,
//                                                      NULL, //path.UTF8String,
//                                                      port,
//                                                      protocol,
//                                                      kSecAuthenticationTypeDefault,
//                                                      &len,
//                                                      &passwordData,
//                                                      &result);
//    
//    if (errSecItemNotFound == status) {
//        //NSLog(@"could not find in keychain");
//    } else if (status) {
//        //NSLog(@"error while trying to find in keychain");
//    } else {
//		if (passwordData) {
//			NSData *data = [NSData dataWithBytes:passwordData length:len];
//			if (passwordString) {
//				(*passwordString) = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
//			}
//			SecKeychainItemFreeContent(NULL, passwordData);
//		}
//    }
//    
//    return result;
//}
//
//
//- (NSString *)accountNameFromKeychainItem:(SecKeychainItemRef)item {
//    NSString *result = nil;
//    OSStatus err = 0;
//    UInt32 infoTag = kSecAccountItemAttr;
//    UInt32 infoFmt = 0; // string
//    SecKeychainAttributeInfo info;
//    SecKeychainAttributeList *authAttrList = NULL;
//    void *data = NULL;
//    UInt32 dataLen = 0;
//    
//    info.count = 1;
//    info.tag = &infoTag;
//    info.format = &infoFmt;
//    
//    err = SecKeychainItemCopyAttributesAndData(item, &info, NULL, &authAttrList, &dataLen, &data);
//    if (err) {
//        goto leave; 
//    }
//    if (!authAttrList->count || authAttrList->attr->tag != kSecAccountItemAttr) { 
//        goto leave; 
//    }
//    if (authAttrList->attr->length > 1024) { 
//        goto leave; 
//    }
//    
//    result = [[[NSString alloc] initWithBytes:authAttrList->attr->data length:authAttrList->attr->length encoding:NSUTF8StringEncoding] autorelease];
//	
//leave:
//    if (authAttrList) {
//        SecKeychainItemFreeAttributesAndData(authAttrList, data);
//		//        SecKeychainItemFreeContent(authAttrList, data);
//    }
//    
//    return result;
//}
//
//
//- (void)addAuthToKeychainItem:(SecKeychainItemRef)keychainItemRef forURL:(NSURL *)URL realm:(NSString *)realm forProxy:(BOOL)forProxy {
//    OSStatus status = 0;
//    NSString *host = URL.host;
//    NSInteger port = URL.port.integerValue;
//    //NSString *path = URL.path;
//    NSString *label = [NSString stringWithFormat:@"%@ (%@)", host, authUsername];
//    //NSString *URLString = URL.absoluteString;
//    NSString *comment = @"created by ObjC FriendFeed Framework";
//    
//    NSData *passwordData = [authPassword dataUsingEncoding:NSUTF8StringEncoding];
//    
//    if (!keychainItemRef) {                
//        OSType protocol = [self protocolForURL:URL isProxy:forProxy];
//        OSType authType = kSecAuthenticationTypeDefault;
//        
//        // set up attribute vector (each attribute consists of {tag, length, pointer})
//        SecKeychainAttribute attrs[] = {
//            { kSecLabelItemAttr, label.length, (char *)label.UTF8String },
//            { kSecProtocolItemAttr, 4, &protocol },
//            { kSecServerItemAttr, host.length, (char *)host.UTF8String },
//            { kSecAccountItemAttr, authUsername.length, (char *)authUsername.UTF8String },
//            { kSecPortItemAttr, sizeof(SInt16), &port },
//            { kSecPathItemAttr, 0, "" },
//            { kSecCommentItemAttr, comment.length, (char *)comment.UTF8String },
//            { kSecAuthenticationTypeItemAttr, 4, &authType },
//            { kSecSecurityDomainItemAttr, realm.length, (char *)realm.UTF8String },
//        };
//        SecKeychainAttributeList attributes = { sizeof(attrs)/sizeof(attrs[0]), attrs };
//        
//        status = SecKeychainItemCreateFromContent(kSecInternetPasswordItemClass,
//                                                  &attributes,
//                                                  passwordData.length,
//                                                  (void *)passwordData.bytes,
//                                                  NULL,
//                                                  (SecAccessRef)NULL, //access,
//                                                  &keychainItemRef);
//        if (!status) {
//            NSLog(@"keychain item creation failed");
//        }
//    } else {
//        SecKeychainAttribute attrs[] = {
//            { kSecAccountItemAttr, authUsername.length, (char *)authUsername.UTF8String }
//        };
//        const SecKeychainAttributeList attributes = { sizeof(attrs) / sizeof(attrs[0]), attrs };
//        
//        status = SecKeychainItemModifyAttributesAndData(keychainItemRef, &attributes, passwordData.length, (void *)passwordData.bytes);
//        if (status) {
//            NSLog(@"Failed to change password in keychain.");
//        }        
//    }
//}
//
//
//- (OSType)protocolForURL:(NSURL *)URL isProxy:(BOOL)isProxy {
//    OSType protocol;
//	
//    BOOL isHTTPS = [[URL scheme] hasPrefix:@"https://"];
//    
//    if (isProxy) {
//        protocol = (isHTTPS) ? kSecProtocolTypeHTTPSProxy : kSecProtocolTypeHTTPProxy;
//    } else {
//        protocol = (isHTTPS) ? kSecProtocolTypeHTTPS : kSecProtocolTypeHTTP;
//    }
//	
//    return protocol;
//}

@end