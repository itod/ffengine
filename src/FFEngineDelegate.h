//
//  FFEngineDelegate.h
//  FFEngine
//
//  Created by Todd Ditchendorf on 1/24/09.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FFError;
@protocol FFEngine;

/*!
	@protocol	FFEngineDelegate
	@brief		implement this protocol in your application to receive notifications when FFEngine requests succeed or fail and receive information from FriendFeed
*/
@protocol FFEngineDelegate <NSObject>

/*!
	@brief		called when any FFEngine method results in an error of any kind
	@details	this is the only method you are required to implement in the FFEngineDelegate protocol. errors from all FFEngine methods are routed to this delegate callback and are matched by the identifier argument
	@param		identifier UUID string matching the string return value of the engine request that produced this error
	@param		error info on what ocurred
	@see		FFEngineDelegate#request:didFailWithError:
*/
- (void)request:(NSString *)identifier didFailWithError:(FFError *)error;

#pragma mark READ

@optional
/*!
	@brief		optional callback after fetching feed of the most recent public entries on FriendFeed
	@details	<tt>/api/feed/public</tt>
	@param		identifier UUID string matching the string return value of the engine request that produced this callback
	@param		data returned feed entries. the type of this ObjC object will match the feedReturnType of service
	@see		FFEngineDelegate#request:didFetchPublicEntries:
*/
- (void)request:(NSString *)identifier didFetchPublicEntries:(id)data;

/*!
	@brief		optional callback after fetching feed of the most recent entries posted to FriendFeed by a given user
	@details	<tt>/api/feed/user/NICKNAME</tt>
	@param		identifier UUID string matching the string return value of the engine request that produced this callback
	@param		data returned from the user feed entries. the type of this ObjC object will match the feedReturnType of service
	@param		username from which entries were fetched
	@see		FFEngineDelegate#fetchPublicEntriesForService:start:num:
*/
- (void)request:(NSString *)identifier didFetchEntries:(id)data forUser:(NSString *)username;

/*!
	@brief		optional callback after fetching feed of the most recent entries posted to FriendFeed by the given users
	@details	<tt>/api/feed/users/NICKNAME</tt>
	@param		identifier UUID string matching the string return value of the engine request that produced this callback
	@param		data returned from the users feed entries. the type of this ObjC object will match the feedReturnType of service
	@param		usernames from which entries were fetched
	@see		FFEngineDelegate#fetchEntriesForUsers:service:start:num:
*/
- (void)request:(NSString *)identifier didFetchEntries:(id)data forUsers:(NSArray *)usernames;

/*!
	@brief		optional callback after fetching feed of the most recent entries the user has commented on, ordered by the date of that user's comments
	@details	<tt>/api/feed/user/NICKNAME/comments</tt>
	@param		identifier UUID string matching the string return value of the engine request that produced this callback
	@param		data entries commented on by user with username. the type of this ObjC object will match the feedReturnType of service
	@param		username from which entries were fetched
	@see		FFEngineDelegate#fetchCommentsForUser:service:start:num:
*/
- (void)request:(NSString *)identifier didFetchComments:(id)data forUser:(NSString *)username;

/*!
	@brief		optional callback after fetching feed of the most recent entries posted to FriendFeed by the given users
	@details	<tt>/api/feed/user/NICKNAME/likes</tt>
	@param		identifier UUID string matching the string return value of the engine request that produced this callback
	@param		data entries liked by user with username. the type of this ObjC object will match the feedReturnType of service
	@param		username from which entries were fetched
	@see		FFEngineDelegate#fetchLikesForUser:service:start:num:
*/
- (void)request:(NSString *)identifier didFetchLikes:(id)data forUser:(NSString *)username;

/*!
	@brief		optional callback after fetching feed of the most recent entries the user has commented on or "liked"
	@details	<tt>/api/feed/user/NICKNAME/discussion</tt>
	@param		identifier UUID string matching the string return value of the engine request that produced this callback
	@param		data entries discussed by user with username. the type of this ObjC object will match the feedReturnType of service
	@param		username from which entries were fetched
	@see		FFEngineDelegate#fetchDiscussionForUser:service:start:num:
*/
- (void)request:(NSString *)identifier didFetchDiscussion:(id)data forUser:(NSString *)username;

/*!
	@brief		optional callback after fetching feed of entries from a user's friends
	@details	<tt>/api/feed/user/NICKNAME/friends</tt>
	@param		identifier UUID string matching the string return value of the engine request that produced this callback
	@param		data friend entries for user with username. the type of this ObjC object will match the feedReturnType of service
	@param		username from which friend entries were fetched
	@see		FFEngineDelegate#fetchFriendEntriesForUser:service:start:num:
*/
- (void)request:(NSString *)identifier didFetchFriendEntries:(id)data forUser:(NSString *)username;

/*!
	@brief		optional callback after fetching feed of the most recent entries in the room with the given roomname
	@details	<tt>/api/feed/room/NICKNAME</tt>
	@param		identifier UUID string matching the string return value of the engine request that produced this callback
	@param		data entries discussed by user with username. the type of this ObjC object will match the feedReturnType of service
	@param		roomname from which entries were fetched
	@see		FFEngineDelegate#fetchEntriesForRoom:service:start:num:
*/
- (void)request:(NSString *)identifier didFetchEntries:(id)data forRoom:(NSString *)roomname;

/*!
	@brief		optional callback after fetching the entry with the given id
	@details	<tt>/api/feed/entry/ENTRYID</tt>
	@param		identifier UUID string matching the string return value of the engine request that produced this callback
	@param		data the entry. the type of this ObjC object will match the feedReturnType of service
	@param		entryID FriendFeed id of the entry fetched
	@see		FFEngineDelegate#fetchEntry:
*/
- (void)request:(NSString *)identifier didFetchEntry:(id)data forID:(NSString *)entryID;

/*!
	@brief		optional callback after fetching the entries with the given ids
	@details	<tt>/api/feed/entry?entry_id=7ad57cd3-30e6-253a-c745-6345b1bd0e78,6f6a36d2-a6c6-fbe7-6bb2-f328c8794eea</tt>
	@param		identifier UUID string matching the string return value of the engine request that produced this callback
	@param		data the entries. the type of this ObjC object will match the feedReturnType of service
	@param		entryIDs FriendFeed ids of the entries fetched
	@see		FFEngineDelegate#fetchEntries:
*/
- (void)request:(NSString *)identifier didFetchEntries:(id)data forIDs:(NSArray *)entryIDs;

/*!
	@brief		optional callback after fetching feed of the entries the authenticated user would see on their FriendFeed homepage - all of their subscriptions and friend-of-a-friend entries
	@details	<tt>/api/feed/entry?entry_id=7ad57cd3-30e6-253a-c745-6345b1bd0e78,6f6a36d2-a6c6-fbe7-6bb2-f328c8794eea</tt>
	@param		identifier UUID string matching the string return value of the engine request that produced this callback
	@param		data the home entries. the type of this ObjC object will match the feedReturnType of service
	@see		FFEngineDelegate#fetchHomeEntriesForService:start:num:
*/
- (void)request:(NSString *)identifier didFetchHomeEntries:(id)data;

/*!
	@brief		optional callback after fetching feed of the entries the authenticated user would see on their Rooms page - entries from all of the rooms they are members of
	@details	<tt>/api/feed/rooms</tt>
	@param		identifier UUID string matching the string return value of the engine request that produced this callback
	@param		data the room entries. the type of this ObjC object will match the feedReturnType of service
	@see		FFEngineDelegate#fetchRoomEntriesForService:start:num:
*/
- (void)request:(NSString *)identifier didFetchRoomEntries:(id)data;

/*!
	@brief		optional callback after fetching the entries for a search over the entries in FriendFeed. If the request was authenticated, the default scope is over all of the entries in the authenticated user's Friends Feed. If the request was not authenticated, the default scope is over all public entries.
	@details	<tt>/api/feed/search?q=fluid</tt>
	@param		identifier UUID string matching the string return value of the engine request that produced this callback
	@param		data the entries for the query. the type of this ObjC object will match the feedReturnType of service
	@param		query search query string which was executed
	@see		FFEngineDelegate#fetchEntriesForQuery:start:num:
*/
- (void)request:(NSString *)identifier didFetchEntries:(id)data forQuery:(NSString *)query;

/*!
	@brief		optional callback after fetching the entries for a search over the entries in FriendFeed. If the request was authenticated, the default scope is over all of the entries in the authenticated user's Friends Feed. If the request was not authenticated, the default scope is over all public entries.
	@details	<tt>/api/feed/search?q=fluid</tt>
	@param		identifier UUID string matching the string return value of the engine request that produced this callback
	@param		data the entries for the query. the type of this ObjC object will match the feedReturnType of service
	@param		query search query string which was executed
	@see		FFEngineDelegate#fetchEntriesForQuery:start:num:
*/
- (void)request:(NSString *)identifier didFetchEntries:(id)data forList:(NSString *)listname;

/*!
	@brief		optional callback after fetching the most recent entries linking to a given URL
	@details	<tt>/api/feed/url?url=http://fluidapp.com&subscribed=1</tt>
	@param		identifier UUID string matching the string return value of the engine request that produced this callback
	@param		data the entries about URLString. the type of this ObjC object will match the feedReturnType of service
	@param		URLString about which entries were fetched
	@param		fromSubscribedOnly if <tt>YES</tt>, fetched only entries from authenticated user's subscriptions
	@see		FFEngineDelegate#fetchEntriesAboutURL:fromSubscribedOnly:start:num:
*/
- (void)request:(NSString *)identifier didFetchEntries:(id)data aboutURL:(NSString *)URLString fromSubscribedOnly:(BOOL)subscribedOnly;

/*!
	@brief		optional callback after fetching the most recent entries linking to a given URL
	@details	<tt>/api/feed/url?url=http://fluidapp.com&nickname=bret,itod,friendfeed-news</tt>
	@param		identifier UUID string matching the string return value of the engine request that produced this callback
	@param		data the entries about URLString. the type of this ObjC object will match the feedReturnType of service
	@param		URLString about which entries were fetched
	@param		usernamesAndRoomnames if the request was limited to a given set of users and/or rooms, this will be contain them. otherwise it will be <tt>nil</tt>.
	@see		FFEngineDelegate#fetchEntriesAboutURL:fromNicknames:start:num:
*/
- (void)request:(NSString *)identifier didFetchEntries:(id)data aboutURL:(NSString *)URLString fromNicknames:(NSArray *)usernamesAndRoomnames;

/*!
	@brief		optional callback after fetching the most recent entries linking to URLs in the given domain(s)
	@details	<tt>/api/feed/domain?domain=blog.friendfeed.com,fluidapp.com</tt>
	@param		identifier UUID string matching the string return value of the engine request that produced this callback
	@param		data the entries about URLString. the type of this ObjC object will match the feedReturnType of service
	@param		domains about which entries were fetched
	@param		inexactMatch if <tt>YES</tt>, the request matched subdomains
	@param		fromSubscribedOnly if <tt>YES</tt>, fetched only entries from authenticated user's subscriptions
	@see		FFEngineDelegate#fetchEntriesForDomains:inexactMatch:fromSubscribedOnly:start:num:
*/
- (void)request:(NSString *)identifier didFetchEntries:(id)data forDomains:(NSArray *)domains inexactMatch:(BOOL)inexactMatch fromSubscribedOnly:(BOOL)subscribedOnly;

/*!
	@brief		optional callback after fetching the most recent entries linking to URLs in the given domain(s)
	@details	<tt>/api/feed/domain?domain=blog.friendfeed.com,fluidapp.com&nickname=bret,friendfeed-news</tt>
	@param		identifier UUID string matching the string return value of the engine request that produced this callback
	@param		data the entries about URLString. the type of this ObjC object will match the feedReturnType of service
	@param		domains about which entries were fetched
	@param		inexactMatch if <tt>YES</tt>, the request matched subdomains
	@param		fromSubscribedOnly if <tt>YES</tt>, fetched only entries from authenticated user's subscriptions
	@see		FFEngineDelegate#fetchEntriesForDomains:inexactMatch:fromNicknames:start:num:
*/
- (void)request:(NSString *)identifier didFetchEntries:(id)data forDomains:(NSArray *)domains inexactMatch:(BOOL)inexactMatch fromNicknames:(NSArray *)nicknames;

#pragma mark WRITE

- (void)request:(NSString *)identifier didPostComment:(id)data onEntry:(NSString *)entryID;
- (void)request:(NSString *)identifier didEditComment:(id)data onEntry:(NSString *)entryID;
- (void)request:(NSString *)identifier didDeleteComment:(id)data onEntry:(NSString *)entryID;
- (void)request:(NSString *)identifier didUndeleteComment:(id)data onEntry:(NSString *)entryID;
- (void)request:(NSString *)identifier didPostLikeOnEntry:(NSString *)entryID;
- (void)request:(NSString *)identifier didDeleteLikeOnEntry:(NSString *)entryID;
- (void)request:(NSString *)identifier didDeleteEntry:(id)data forID:(NSString *)entryID;
- (void)request:(NSString *)identifier didUndeleteEntry:(id)data forID:(NSString *)entryID;
- (void)request:(NSString *)identifier didHideEntry:(id)data forID:(NSString *)entryID;
- (void)request:(NSString *)identifier didUnhideEntry:(id)data forID:(NSString *)entryID;
@end

