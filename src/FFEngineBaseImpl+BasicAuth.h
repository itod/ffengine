//
//  FFEngineBaseImpl+BasicAuth.h
//  FFEngine
//
//  Created by Todd Ditchendorf on 1/19/09.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import "FFEngineBaseImpl.h"
#import <Security/SecBase.h>

@interface FFEngineBaseImpl (BasicAuth)
//- (SecKeychainItemRef)keychainItemForURL:(NSURL *)URL getPasswordString:(NSString **)passwordString forProxy:(BOOL)forProxy;
//- (void)addAuthToKeychainItem:(SecKeychainItemRef)keychainItem forURL:(NSURL *)URL realm:(NSString *)realm forProxy:(BOOL)forProxy;
//- (NSString *)accountNameFromKeychainItem:(SecKeychainItemRef)item;
//- (OSType)protocolForURL:(NSURL *)URL isProxy:(BOOL)isProxy;

- (BOOL)getUsername:(NSString **)uname 
		   password:(NSString **)passwd 
	  forAuthScheme:(NSString *)scheme 
				URL:(NSURL *)URL 
			  realm:(NSString *)realm 
			 domain:(NSURL *)domain 
		   forProxy:(BOOL)forProxy 
			isRetry:(BOOL)isRetry;
@end
