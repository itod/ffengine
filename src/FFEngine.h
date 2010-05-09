//
//  FFEngine.h
//  FFEngine
//
//  Created by Todd Ditchendorf on 1/17/09.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FFTypes.h"
#import "FFEngineDelegate.h"
#import "FFEngineFactory.h"
#import "FFError.h"
#import "FFXmlDocPtrWrapper.h"

@protocol FFEngineDelegate;

/*!
	@protocol	FFEngine
	@brief		the primary interface to the FriendFeed API
	@details	create a concrete instance using FFEngineFactory
*/
@protocol FFEngine <NSObject>

/*!
	@property   delegate
	@brief      object which will receive callbacks when FriendFeed API calls succeed or fail
*/
@property (nonatomic, assign, readonly) id <FFEngineDelegate> delegate;

/*!
	@property   feedDataType
	@brief      the format of feeds returned from FriendFeed
	@details	JSON, XML, Atom or RSS. Note this only applied to 'feed' or 'read' methods of FFEngine. Result data from 'write' methods is always JSON
*/
@property (nonatomic, readonly) FFDataType feedDataType;

/*!
	@property   feedReturnType
	@brief      the Objective-C type of which feed objects should be returned
	@details	<tt>NSString</tt>, <tt>JSONValue</tt> (<tt>NSDictionary</tt> or <tt>NSArray</tt>), <tt>NSXMLDocument</tt>, <tt>PSFeed</tt>, <tt>FFXmlDocPtrWrapper</tt> (a thin ObjC wrapper for libxml2 <tt>xmlDocPtr</tt> objects)
*/
@property (nonatomic, readonly) FFReturnType feedReturnType;

/*!
	@brief		the FriendFeed user credentials to use for API requests which require HTTP Basic Authentication 
	@details	the remoteKeyPassword is your FriendFeed API Remote Key, not your normal FriendFeed password. It is available to all FriendFeed users here: https://friendfeed.com/account/api
	@param		username of FriendFeed account with wich to authenticate api calls
	@param		remoteKeyPassword provided by FriendFeed (not your password)
*/
- (void)setUsername:(NSString *)username remoteKeyPassword:(NSString *)remoteKeyPassword;

#pragma mark READ

/*!
	@brief		fetches feed of the most recent public entries on FriendFeed
	@details	<tt>/api/feed/public</tt>
	@param		service on which to filter (e.g. <tt>twitter</tt>). send <tt>nil</tt> to include all services
	@param		start index of the first entry to be returned
	@param		num of entries to be returned
	@returns	request identifier which will also be passed to the delegate callback
	@see		FFEngineDelegate#service:didFetchPublicEntries:
*/
- (NSString *)fetchPublicEntriesForService:(NSString *)service start:(NSUInteger)start num:(NSUInteger)num;

/*!
	@brief		fetches feed of the most recent entries from the user with the given username
	@details	<tt>/api/feed/user/NICKNAME</tt>
	@param		username from which to fetch entries
	@param		service on which to filter (e.g. <tt>twitter</tt>). send <tt>nil</tt> to include all services
	@param		start index of the first entry to be returned
	@param		num of entries to be returned
	@returns	request identifier which will also be passed to the delegate callback
	@see		FFEngineDelegate#service:didFetchEntries:forUser:
*/
- (NSString *)fetchEntriesForUser:(NSString *)username service:(NSString *)service start:(NSUInteger)start num:(NSUInteger)num;

/*!
	@brief		fetches feed of the most recent entries from the users with the given usernames
	@details	<tt>/api/feed/user?nickname=bret,paul,jim</tt>
	@param		usernames from which to fetch entries
	@param		service on which to filter (e.g. <tt>twitter</tt>). send <tt>nil</tt> to include all services
	@param		start index of the first entry to be returned
	@param		num of entries to be returned
	@returns	request identifier which will also be passed to the delegate callback
	@see		FFEngineDelegate#service:didFetchEntries:forUsers:
*/
- (NSString *)fetchEntriesForUsers:(NSArray *)usernames service:(NSString *)service start:(NSUInteger)start num:(NSUInteger)num;

/*!
	@brief		fetches feed of the most recent entries the user has commented on, ordered by the date of that user's comments
	@details	<tt>/api/feed/user/NICKNAME/comments</tt>
	@param		username from which to fetch comments
	@param		service on which to filter (e.g. <tt>twitter</tt>). send <tt>nil</tt> to include all services
	@param		start index of the first entry to be returned
	@param		num of comments to be returned
	@returns	request identifier which will also be passed to the delegate callback
	@see		FFEngineDelegate#service:didFetchComments:forUser:
*/
- (NSString *)fetchCommentsForUser:(NSString *)username service:(NSString *)service start:(NSUInteger)start num:(NSUInteger)num;

/*!
	@brief		fetches feed of the most recent entries the user has "liked," ordered by the date of that user's "likes"
	@details	<tt>/api/feed/user/NICKNAME/likes</tt>
	@param		username from which to fetch likes
	@param		service on which to filter (e.g. <tt>twitter</tt>). send <tt>nil</tt> to include all services
	@param		start index of the first like to be returned
	@param		num of likes to be returned
	@returns	request identifier which will also be passed to the delegate callback
	@see		FFEngineDelegate#service:didFetchLikes:forUser:
*/
- (NSString *)fetchLikesForUser:(NSString *)username service:(NSString *)service start:(NSUInteger)start num:(NSUInteger)num;

/*!
	@brief		fetches feed of the most recent entries the user has commented on or "liked"
	@details	<tt>/api/feed/user/NICKNAME/discussion</tt>
	@param		username from which to fetch entries
	@param		service on which to filter (e.g. <tt>twitter</tt>). send <tt>nil</tt> to include all services
	@param		start index of the first like to be returned
	@param		num of entries to be returned
	@returns	request identifier which will also be passed to the delegate callback
	@see		FFEngineDelegate#service:didFetchDiscussion:forUser:
*/
- (NSString *)fetchDiscussionForUser:(NSString *)username service:(NSString *)service start:(NSUInteger)start num:(NSUInteger)num;

/*!
	@brief		fetches feed of entries from a user's friends
	@details	<tt>/api/feed/user/NICKNAME/friends</tt>
	@param		username from which to fetch friend entries
	@param		service on which to filter (e.g. <tt>twitter</tt>). send <tt>nil</tt> to include all services
	@param		start index of the first like to be returned
	@param		num of entries to be returned
	@returns	request identifier which will also be passed to the delegate callback
	@see		FFEngineDelegate#service:didFetchFriendEntries:forUser:
*/
- (NSString *)fetchFriendEntriesForUser:(NSString *)username service:(NSString *)service start:(NSUInteger)start num:(NSUInteger)num;

/*!
	@brief		fetches feed of the most recent entries in the room with the given roomname
	@details	<tt>/api/feed/room/NICKNAME</tt>
	@param		roomname from which to fetch entries
	@param		service on which to filter (e.g. <tt>twitter</tt>). send <tt>nil</tt> to include all services
	@param		start index of the first like to be returned
	@param		num of likes to be returned
	@returns	request identifier which will also be passed to the delegate callback
	@see		FFEngineDelegate#service:didFetchEntries:forRoom:
*/
- (NSString *)fetchEntriesForRoom:(NSString *)roomname service:(NSString *)service start:(NSUInteger)start num:(NSUInteger)num;

/*!
	@brief		fetches the entry with the given id
	@details	<tt>/api/feed/entry/ENTRYID</tt>
	@param		entryID to fetch
	@see		FFEngineDelegate#service:didFetchEntry:forID:
*/
- (NSString *)fetchEntry:(NSString *)entryID;

/*!
	@brief		fetches the entries with the given ids
	@details	<tt>/api/feed/entry?entry_id=7ad57cd3-30e6-253a-c745-6345b1bd0e78,6f6a36d2-a6c6-fbe7-6bb2-f328c8794eea</tt>
	@param		entryIDs to fetch
	@returns	request identifier which will also be passed to the delegate callback
	@see		FFEngineDelegate#service:didFetchEntries:forIDs:
*/
- (NSString *)fetchEntries:(NSArray *)entryIDs;

/*!
	@brief		fetches feed of the entries the authenticated user would see on their FriendFeed homepage - all of their subscriptions and friend-of-a-friend entries
	@details	<tt>/api/feed/home</tt>
	@param		service on which to filter (e.g. <tt>twitter</tt>). send <tt>nil</tt> to include all services
	@param		start index of the first entry to be returned
	@param		num of entries to be returned
	@returns	request identifier which will also be passed to the delegate callback
	@see		FFEngineDelegate#service:didFetchHomeEntries:
*/
- (NSString *)fetchHomeEntriesForService:(NSString *)service start:(NSUInteger)start num:(NSUInteger)num;

/*!
	@brief		fetches feed of the entries the authenticated user would see on their Rooms page - entries from all of the rooms they are members of
	@details	<tt>/api/feed/rooms</tt>
	@param		service on which to filter (e.g. <tt>twitter</tt>). send <tt>nil</tt> to include all services
	@param		start index of the first entry to be returned
	@param		num of entries to be returned
	@returns	request identifier which will also be passed to the delegate callback
	@see		FFEngineDelegate#service:didFetchRoomEntries:
*/
- (NSString *)fetchRoomsEntriesForService:(NSString *)service start:(NSUInteger)start num:(NSUInteger)num;

/*!
	@brief		fetches feed of a search over the entries in FriendFeed. If the request is authenticated, the default scope is over all of the entries in the authenticated user's Friends Feed. If the request is not authenticated, the default scope is over all public entries.
	@details	<tt>/api/feed/search?q=fluid</tt>
	@param		query search query string which can include special FriendFeed qualifiers like <tt>who:</tt>
	@param		start index of the first entry to be returned
	@param		num of entries to be returned
	@returns	request identifier which will also be passed to the delegate callback
	@see		FFEngineDelegate#service:didFetchEntries:forQuery:
*/
- (NSString *)fetchEntriesForQuery:(NSString *)query start:(NSUInteger)start num:(NSUInteger)num;

/*!
	@brief		fetches feed of entries from the authenticated user's list with the given listname
	@details	<tt>/api/feed/list/NICKNAME</tt>
	@param		listname of the list from which to fetch entries
	@param		service on which to filter (e.g. <tt>twitter</tt>). send <tt>nil</tt> to include all services
	@param		start index of the first entry to be returned
	@param		num of entries to be returned
	@returns	request identifier which will also be passed to the delegate callback
	@see		FFEngineDelegate#service:didFetchEntries:forList:
*/
- (NSString *)fetchEntriesForList:(NSString *)listname service:(NSString *)service start:(NSUInteger)start num:(NSUInteger)num;

/*!
	@brief		fetches feed of the most recent entries linking to a given URL
	@details	<tt>/api/feed/url?url=http://fluidapp.com&subscribed=1</tt>. <tt>service</tt> filter not currently supported on this method
	@param		URLString about which to fetch entries
	@param		fromSubscribedOnly if <tt>YES</tt>, fetch only entries from authenticated user's subscriptions
	@param		start index of the first entry to be returned
	@param		num of entries to be returned
	@returns	request identifier which will also be passed to the delegate callback
	@see		FFEngineDelegate#service:didFetchEntries:aboutURL:fromSubscribedOnly:
*/
- (NSString *)fetchEntriesAboutURL:(NSString *)URLString fromSubscribedOnly:(BOOL)subscribedOnly start:(NSUInteger)start num:(NSUInteger)num;

/*!
	@brief		fetches feed of the most recent entries linking to a given URL 
	@details	<tt>/api/feed/url?url=http://fluidapp.com&nickname=bret,itod,friendfeed-news</tt>. <tt>service</tt> filter not currently supported on this method
	@param		URLString about which to fetch entries
	@param		usernamesAndRoomnames limit to a given set of users and/or rooms. pass <tt>nil</tt> for no limiting by nickname
	@param		start index of the first entry to be returned
	@param		num of entries to be returned
	@returns	request identifier which will also be passed to the delegate callback
	@see		FFEngineDelegate#service:didFetchEntries:aboutURL:fromNicknames:
*/
- (NSString *)fetchEntriesAboutURL:(NSString *)URLString fromNicknames:(NSArray *)usernamesAndRoomnames start:(NSUInteger)start num:(NSUInteger)num;

/*!
	@brief		fetches feed of the most recent entries linking to URLs in the given domain(s)
	@details	By default, sub-domains will not be matched (i.e. friendfeed.com will not include blog.friendfeed.com entries). 
				Subdomain matches may be requested by passing inexact=1 (the results of inexact queries will be unsorted for performance reasons). 
				If authentication is used, private entries may be returned, otherwise only public entries will be.
				When authenticated, the results may be limited to only entries from the user's friends and subscribed rooms by passing subscribedOnly=<tt>YES</tt>.
				<tt>/api/feed/domain?domain=blog.friendfeed.com,fluidapp.com</tt>. <tt>service</tt> filter not currently supported on this method
	@param		domains about which to fetch entries
	@param		inexactMatch if <tt>YES</tt>, match subdomains
	@param		fromSubscribedOnly if <tt>YES</tt>, fetch only entries from authenticated user's subscriptions
	@param		start index of the first entry to be returned
	@param		num of entries to be returned
	@returns	request identifier which will also be passed to the delegate callback
	@see		FFEngineDelegate#service:didFetchEntriesForDomains:inexactMatch:fromSubscribedOnly:
*/
- (NSString *)fetchEntriesForDomains:(NSArray *)domains inexactMatch:(BOOL)inexactMatch fromSubscribedOnly:(BOOL)subscribedOnly start:(NSUInteger)start num:(NSUInteger)num;

/*!
	@brief		fetches feed of the most recent entries linking to URLs in the given domain(s)
	@details	By default, sub-domains will not be matched (i.e. friendfeed.com will not include blog.friendfeed.com entries). 
				Subdomain matches may be requested by passing inexact=1 (the results of inexact queries will be unsorted for performance reasons). 
				If authentication is used, private entries may be returned, otherwise only public entries will be.
				When authenticated, the results may be limited to only entries from the user's friends and subscribed rooms by passing subscribedOnly=<tt>YES</tt>.
				<tt>/api/feed/domain?domain=blog.friendfeed.com,fluidapp.com&nickname=bret,friendfeed-news</tt>. <tt>service</tt> filter not currently supported on this method
	@param		domains about which to fetch entries
	@param		inexactMatch if <tt>YES</tt>, match subdomains
	@param		usernamesAndRoomnames limit to a given set of users and/or rooms. pass <tt>nil</tt> for no limiting by nickname
	@param		start index of the first entry to be returned
	@param		num of entries to be returned
	@returns	request identifier which will also be passed to the delegate callback
	@see		FFEngineDelegate#service:didFetchEntriesForDomains:inexactMatch:fromNicknames:
*/
- (NSString *)fetchEntriesForDomains:(NSArray *)domains inexactMatch:(BOOL)inexactMatch fromNicknames:(NSArray *)usernamesAndRoomnames start:(NSUInteger)start num:(NSUInteger)num;

#pragma mark WRITE

/*!
	@brief		add a comment on the given entry
	@details	<tt>/api/comment</tt>
	@param		entryID the FriendFeed UUID of the entry to which this comment is attached
	@param		body the textual body of the comment
	@returns	request identifier which will also be passed to the delegate callback
	@see		FFEngineDelegate#service:didPostComment:onEntry:
*/
- (NSString *)postCommentOnEntry:(NSString *)entryID withBody:(NSString *)body;

/*!
	@brief		edit a comment on the given entry
	@details	<tt>/api/comment</tt>
	@param		commentID the FriendFeed UUID of the comment to edit
	@param		entryID the FriendFeed UUID of the entry to which this comment is attached
	@param		body the textual body of the comment
	@returns	request identifier which will also be passed to the delegate callback
	@see		FFEngineDelegate#service:didEditComment:onEntry:
*/
- (NSString *)editComment:(NSString *)commentID onEntry:(NSString *)entryID withBody:(NSString *)body;

/*!
	@brief		delete a comment on the given entry
	@details	<tt>/api/comment/delete</tt>
	@param		commentID the FriendFeed UUID of the comment to delete
	@param		entryID the FriendFeed UUID of the entry to which this comment is attached
	@returns	request identifier which will also be passed to the delegate callback
	@see		FFEngineDelegate#service:didDeleteComment:onEntry:
*/
- (NSString *)deleteComment:(NSString *)commentID onEntry:(NSString *)entryID;

/*!
	@brief		undelete a previously deleted comment on the given entry
	@details	<tt>/api/comment/delete?undelete=1</tt>
	@param		commentID the FriendFeed UUID of the comment to undelete
	@param		entryID the FriendFeed UUID of the entry to which this comment is attached
	@returns	request identifier which will also be passed to the delegate callback
	@see		FFEngineDelegate#service:didUndeleteComment:onEntry:
*/
- (NSString *)undeleteComment:(NSString *)commentID onEntry:(NSString *)entryID;

/*!
	@brief		add a "Like" to a given FriendFeed entry for the authenticated user
	@details	<tt>/api/like</tt>
	@param		entryID the FriendFeed UUID of the entry to which this like is attached
	@returns	request identifier which will also be passed to the delegate callback
	@see		FFEngineDelegate#service:didPostLikeOnEntry:
*/
- (NSString *)postLikeOnEntry:(NSString *)entryID;

/*!
	@brief		delete a "Like" to a given FriendFeed entry for the authenticated user
	@details	<tt>/api/like/delete</tt>
	@param		entryID the FriendFeed UUID of the entry to which this like is attached
	@returns	request identifier which will also be passed to the delegate callback
	@see		FFEngineDelegate#service:didDeleteLike:onEntry:
*/
- (NSString *)deleteLikeOnEntry:(NSString *)entryID;

/*!
	@brief		delete an existing entry
	@details	<tt>/api/entry/delete</tt>
	@param		entryID the FriendFeed UUID of the entry to delete
	@returns	request identifier which will also be passed to the delegate callback
	@see		FFEngineDelegate#service:didDeleteEntry:
*/
- (NSString *)deleteEntry:(NSString *)entryID;

/*!
	@brief		undelete a previously deleted entry
	@details	<tt>/api/entry/delete?undelete=1</tt>
	@param		entryID the FriendFeed UUID of the entry to undelete
	@returns	request identifier which will also be passed to the delegate callback
	@see		FFEngineDelegate#service:didUndeleteEntry:
*/
- (NSString *)undeleteEntry:(NSString *)entryID;

/*!
	@brief		hide an existing entry
	@details	<tt>/api/entry/hide</tt>
	@param		entryID the FriendFeed UUID of the entry to hide
	@returns	request identifier which will also be passed to the delegate callback
	@see		FFEngineDelegate#service:didHideEntry:
*/
- (NSString *)hideEntry:(NSString *)entryID;

/*!
	@brief		unhide a previously hidden entry
	@details	<tt>/api/entry/hide?unhide=1</tt>
	@param		entryID the FriendFeed UUID of the entry to unhide
	@returns	request identifier which will also be passed to the delegate callback
	@see		FFEngineDelegate#service:didUnhideEntry:
 */
- (NSString *)unhideEntry:(NSString *)entryID;
@end
