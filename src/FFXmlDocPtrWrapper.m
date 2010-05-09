//
//  FFXmlDocPtrWrapper.m
//  FFEngine
//
//  Created by Todd Ditchendorf on 1/19/09.
//  Copyright 2009 Todd Ditchendorf. All rights reserved.
//

#import "FFXmlDocPtrWrapper.h"
#import <libxml/xmlmemory.h>
#import <libxslt/xslt.h>
#import <libxslt/xsltinternals.h>
#import <libxslt/transform.h>
#import <libxslt/xsltutils.h>
#import <libxslt/xsltinternals.h>
#import <libxslt/extensions.h>
#import <libxml/xpath.h>
#import <libxml/xpathInternals.h>
#import <libexslt/exslt.h>
#import <ParseKit/ParseKit.h>

void myGenericErrorFunc(id self, const char *msg, ...) {
    va_list vargs;
    va_start(vargs, msg);
    
    NSString *format = [NSString stringWithUTF8String:msg];
    NSMutableString *str = [[[NSMutableString alloc] initWithFormat:format arguments:vargs] autorelease];
    
    NSLog(@"%@", str);
    
    va_end(vargs);
}


NSString *markedUpHashtag(PKTokenizer *t, PKToken *inTok, PKToken *poundTok) {
    PKToken *eof = [PKToken EOFToken];
    NSMutableString *ms = [NSMutableString stringWithString:[inTok stringValue]];
    
    PKToken *tok = nil;
    while (tok = [t nextToken]) {
        NSString *s = [tok stringValue];
        
        if (eof == tok) {
            break;
        } else if ([poundTok isEqual:tok]) {
            [ms appendString:s];
            continue;
        } else if (tok.isWord) {
            [ms setString:@""];
            [ms appendFormat:@"<a href='ffrolic:http://twitter.com/search?q=%%23%@'>#%@</a>", s, s];
            break;
        } else {
            [ms appendString:s];
            break;
        }
    }
    return ms;
}


NSString *markedUpUsername(PKTokenizer *t, PKToken *inTok, PKToken *atTok) {
    PKToken *eof = [PKToken EOFToken];
    NSMutableString *ms = [NSMutableString stringWithString:[inTok stringValue]];
    
    PKToken *tok = nil;
    while (tok = [t nextToken]) {
        NSString *s = [tok stringValue];
        
        if (eof == tok) {
            break;
        } else if ([atTok isEqual:tok]) {
            [ms appendString:s];
            continue;
        } else if (tok.isWord) {
            [ms setString:@""];
            [ms appendFormat:@"<a href='ffrolic:http://twitter.com/%@'>@%@</a>", s, s];
            break;
        } else {
            [ms appendString:s];
            break;
        }
    }
    return ms;
}


NSString *markedUpURL(PKTokenizer *t, PKToken *inTok, PKToken *colonSlashSlashTok) {
    PKToken *tok = [t nextToken];
    if (![colonSlashSlashTok isEqual:tok]) {
        return [NSString stringWithFormat:@"%@%@", [inTok stringValue], [tok stringValue]];
    }
    
    PKToken *eof = [PKToken EOFToken];
    NSMutableString *ms = [NSMutableString string];
    
    NSString *s = nil;
    while (tok = [t nextToken]) {
        s = [tok stringValue];
        
        if (eof == tok || tok.isWhitespace) {
            break;
        } else {
            [ms appendFormat:s];
        }
    }

    NSString *display = [[ms copy] autorelease];
    NSInteger maxLen = 32;
    if ([display length] > maxLen) {
        display = [NSString stringWithFormat:@"%@%C", [display substringToIndex:maxLen], 0x2026];
    }
    
    if ([display hasSuffix:@"/"]) {
        display = [display substringToIndex:[display length] - 1];
    }
    
    ms = [NSMutableString stringWithFormat:@"<a href='ffrolic:http://%@'>%@</a>", ms, display];
    if (s) [ms appendString:s];
    return ms;
}


static void ffModuleFunctionFormatDate(xmlXPathParserContextPtr ctxt, int nargs) {
	const xmlChar *str = xmlXPathPopString(ctxt);
    NSString *inStr = [NSString stringWithUTF8String:(const char *)str];
    free((void *)str);

    NSDateFormatter *fmt = [[[NSDateFormatter alloc] init] autorelease];
    [fmt setDateFormat:@"yyyy-MM-dd'T'HH:mm:SS'Z'"]; // 2009-07-08T:02:08:14Z
    NSDate *date = [fmt dateFromString:inStr];

    // add the value of the timezone offset to get true local time of post
    NSTimeInterval secs = [[NSTimeZone systemTimeZone] secondsFromGMTForDate:date];
    date = [date addTimeInterval:secs];

    secs = abs([date timeIntervalSinceNow]);
    
    NSString *s = nil;
    if (secs < 120) {
        s = NSLocalizedString(@"1 minute ago", @"");
    } else if (secs < 60 * 60) {
        s = [NSString stringWithFormat:NSLocalizedString(@"%1.0f minutes ago", @""), (float)round((float)secs/(float)60.0)];
    } else if (secs < 60 * 60 * 24) {
        s = [NSString stringWithFormat:NSLocalizedString(@"%1.0f hours ago", @""), (float)round((float)secs /(float)(60. * 60.))];
    } else {
        [fmt setDateFormat:@"HH:mm 'on' EEEE MMMM d"]; // 2009-07-08T:02:08:14Z
        s = [fmt stringFromDate:date];
    }
    
	xmlXPathObjectPtr value = xmlXPathNewString((xmlChar *)[s UTF8String]);
	valuePush(ctxt, value);
}


static void ffModuleFunctionMarkupTitle(xmlXPathParserContextPtr ctxt, int nargs) {
	const xmlChar *str = xmlXPathPopString(ctxt);
    NSString *inStr = [NSString stringWithUTF8String:(const char *)str];
    free((void *)str);
    
    NSMutableString *ms = [NSMutableString stringWithCapacity:[inStr length]];

    PKTokenizer *t = [PKTokenizer tokenizerWithString:inStr];
    t.whitespaceState.reportsWhitespaceTokens = YES;
    
    PKToken *atTok = [PKToken tokenWithTokenType:PKTokenTypeSymbol stringValue:@"@" floatValue:0];
    PKToken *poundTok = [PKToken tokenWithTokenType:PKTokenTypeSymbol stringValue:@"#" floatValue:0];
    PKToken *httpTok = [PKToken tokenWithTokenType:PKTokenTypeWord stringValue:@"http" floatValue:0];
    PKToken *colonSlashSlashTok = [PKToken tokenWithTokenType:PKTokenTypeSymbol stringValue:@"://" floatValue:0];
    //PKToken *wwwTok = [PKToken tokenWithTokenType:PKTokenTypeSymbol stringValue:@"www." floatValue:0];
    
    [t.symbolState add:[colonSlashSlashTok stringValue]];
    //[t.symbolState add:[wwwTok stringValue]];

    PKToken *eof = [PKToken EOFToken];
    PKToken *tok = nil;
    NSString *s = nil;
    
    while ((tok = [t nextToken]) != eof) {
        if ([atTok isEqual:tok]) {
            s = markedUpUsername(t, tok, atTok);
        } else if ([poundTok isEqual:tok]) {
            s = markedUpHashtag(t, tok, poundTok);
        } else if ([httpTok isEqual:tok]) {
            s = markedUpURL(t, tok, colonSlashSlashTok);
        } else {
            s = [tok stringValue];
        }
        
        [ms appendString:s];
    }
	
	xmlXPathObjectPtr value = xmlXPathNewString((xmlChar *)[ms UTF8String]);
	valuePush(ctxt, value);
}


static void *ffModuleInit(xsltTransformContextPtr ctxt, const xmlChar *URI) {	
	xsltRegisterExtFunction(ctxt, (const xmlChar *)"markupTitle", URI,
							(xmlXPathFunction)ffModuleFunctionMarkupTitle);
	xsltRegisterExtFunction(ctxt, (const xmlChar *)"formatDate", URI,
							(xmlXPathFunction)ffModuleFunctionFormatDate);
	return NULL;
}


static void *ffModuleShutdown(xsltTransformContextPtr ctxt, const xmlChar *URI, void *data) {
	return NULL;
}


@implementation FFXmlDocPtrWrapper

+ (void)initialize {
    if (self == [FFXmlDocPtrWrapper class]) {
        xmlInitParser();
        
        xsltRegisterExtModule((const xmlChar *)"http://ditchnet.org/ff",
                              (xsltExtInitFunction)ffModuleInit,
                              (xsltExtShutdownFunction)ffModuleShutdown);

        xmlSubstituteEntitiesDefaultValue = 0;
        xmlLoadExtDtdDefaultValue = 0;
        exsltRegisterAll();
    }
}


+ (id)wrapperWithXmlDoc:(xmlDocPtr)d {
    return [[[self alloc] initWithXmlDoc:d] autorelease];
}


- (id)initWithXmlDoc:(xmlDocPtr)d {
    self = [super init];
    if (self) {
        _xmlDoc = d;
    }
    return self;
}


- (void)dealloc {
    if (_xmlDoc) {
        xmlFreeDoc(_xmlDoc);
        _xmlDoc = NULL;
    }
    [super dealloc];
}


- (xmlDocPtr)xmlDoc {
    return _xmlDoc;
}


- (NSString *)description {
    return [NSString stringWithFormat:@"<FFXmlDocPtrWrapper %p", self];
    //return [self XMLString];
}


- (NSString *)XMLString {
    if (!_xmlDoc) return @"";
    
    xmlChar *mem = NULL;
    int len = 0;
    xmlDocDumpMemoryEnc(_xmlDoc, &mem, &len, "utf-8");
    
    //  this doesnt work
    //    NSString *XMLString = [[[NSString alloc] initWithBytesNoCopy:mem
    //                                                          length:len
    //                                                        encoding:NSUTF8StringEncoding
    //                                                    freeWhenDone:NO] autorelease];
    
    NSString *XMLString = [NSString stringWithUTF8String:(const char *)mem];
    xmlFree((void *)mem);
    return XMLString;
}


- (FFXmlDocPtrWrapper *)wrapperByTransformingWithStylesheetAtPath:(NSString *)path params:(NSDictionary *)params {
    FFXmlDocPtrWrapper *newWrapper = nil;

    xmlSetGenericErrorFunc((void *)self, (xmlGenericErrorFunc)myGenericErrorFunc);
    xsltSetGenericErrorFunc((void *)self, (xmlGenericErrorFunc)myGenericErrorFunc);
    
    xmlDocPtr srcDoc = [self xmlDoc];
    xsltStylesheetPtr stylesheet = NULL;
    xsltTransformContextPtr xformCtxt = NULL;
    xmlDocPtr resDoc = NULL;
    
    stylesheet = xsltParseStylesheetFile((const xmlChar*)[path UTF8String]);
    
    if (stylesheet) {
        xformCtxt = xsltNewTransformContext(stylesheet, srcDoc);
        xsltSetTransformErrorFunc(xformCtxt, (void *)self, (xmlGenericErrorFunc)myGenericErrorFunc);
        
        const int count = [params count]*2 +1;
        const char *xsltParams[count];
        
        if ([params count] == 0) {
            *xsltParams = NULL;
        } else {
            NSInteger i = -1;
            for (id key in params) {
                id val = [params objectForKey:key];
                xsltParams[++i] = [key UTF8String];
                xsltParams[++i] = [val UTF8String];
            }
            xsltParams[++i] = NULL;
        }
        
        resDoc = xsltApplyStylesheet(stylesheet, srcDoc, xsltParams);
        
        if (resDoc) {
            newWrapper = [[[FFXmlDocPtrWrapper alloc] initWithXmlDoc:resDoc] autorelease];
        } else {
            NSLog(@"error: error during transformation");
            goto leave;
        }    
    } else {
        NSLog(@"error: error loading stylehseet");
        goto leave;
    }
    
    
leave:
    if (stylesheet) {
        xsltFreeStylesheet(stylesheet);
        stylesheet = NULL;
    }
    if (xformCtxt) {
        xsltFreeTransformContext(xformCtxt);
        xformCtxt = NULL;
    }
    
    xmlCleanupParser();
    
    return newWrapper;
}

@synthesize xmlDoc;
@end
