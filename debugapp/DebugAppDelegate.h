//
//  DebugAppDelegate.h
//  FFEngine
//
//  Created by Todd Ditchendorf on 1/17/09.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <FFEngine/FFEngine.h>

@class WebView;

@interface DebugAppDelegate : NSObject <FFEngineDelegate> {
	IBOutlet NSTextView *textView;
	IBOutlet WebView *webView;
	NSAttributedString *displayString;
	BOOL busy;
}
- (IBAction)run:(id)sender;

- (void)renderHTMLFor:(NSXMLDocument *)doc;

@property (nonatomic, retain) NSAttributedString *displayString;
@property (nonatomic) BOOL busy;
@end
