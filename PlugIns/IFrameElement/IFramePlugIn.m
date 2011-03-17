//
//  IFramePlugIn.m
//  IFrameElement
//
//  Copyright 2004-2011 Karelia Software. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//
//  *  Redistribution of source code must retain the above copyright notice,
//     this list of conditions and the follow disclaimer.
//
//  *  Redistributions in binary form must reproduce the above copyright notice,
//     this list of conditions and the following disclaimer in the documentation
//     and/or other material provided with the distribution.
//
//  *  Neither the name of Karelia Software nor the names of its contributors
//     may be used to endorse or promote products derived from this software
//     without specific prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS-IS"
//  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
//  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
//  ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
//  LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
//  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
//  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
//  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
//  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
//  ARISING IN ANY WAY OUR OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
//  POSSIBILITY OF SUCH DAMAGE.
//
//  Community Note: This code is distrubuted under a modified BSD License.
//  We encourage you to share your Sandvox Plugins similarly.
//

#import "IFramePlugIn.h"


@implementation IFramePlugIn


#pragma mark SVPlugIn

+ (NSArray *)plugInKeys
{ 
    return [NSArray arrayWithObjects:
            @"iFrameIsBordered",
            @"linkURL",
            nil];
}


- (void)dealloc
{
    self.linkURL = nil;
	[super dealloc]; 
}

- (void)awakeFromNew;
{
    [super awakeFromNew];
    
    // Attempt to automatically grab the URL from the user's browser
    id<SVWebLocation> location = [[NSWorkspace sharedWorkspace] fetchBrowserWebLocation];
    if ( location )
    {
        if ( [location URL] ) self.linkURL = [location URL];
        if ( [location title] ) [self setTitle:[location title]];
    }
    
    // Set our "show border" checkbox from the defaults
    self.iFrameIsBordered = [[NSUserDefaults standardUserDefaults] boolForKey:@"iFramePageletIsBordered"];
}

- (void)awakeFromSourceProperties:(NSDictionary *)properties
{
    [super awakeFromSourceProperties:properties];
    
    if ( [properties objectForKey:@"linkURL"] )
    {
        self.linkURL = [NSURL URLWithString:[properties objectForKey:@"linkURL"]];
    }
    if ( [properties objectForKey:@"titleHTML"] )
    {
        self.title = [properties objectForKey:@"titleHTML"]; //FIXME: we need a plug-in accessible version of stringByConvertingHTMLToPlainText
    }
}

// possible Sandvox 1 properties
//iFrameHeight = 200;
//iFrameIsBordered = 0;
//iFrameWidth = 0;
//introductionHTML = <null>;
//linkURL = "http://www.apple.com/";
//location = 1;
//ordering = 0;
//plugin = <null>;
//pluginIdentifier = "sandvox.IFrameElement";
//pluginVersion = "1.6.8";
//prefersBottom = 0;
//shouldPropagate = 1;
//showBorder = 0;
//titleHTML = Apple;
//titleLinkURLPath = <null>;
//uniqueID = 44E953B5D6D94A06B3C1;



#pragma mark HTML Generation

- (void)writeHTML:(id <SVPlugInContext>)context
{
    // add dependencies for any ivars not references in html template
    [context addDependencyForKeyPath:@"linkURL" ofObject:self];
    [context addDependencyForKeyPath:@"iFrameIsBordered" ofObject:self];
    
    if ( self.linkURL )
    {
        if ( [context liveDataFeeds] )
        {
            NSString *src = (self.linkURL) ? [self.linkURL absoluteString] : @"";
            NSString *class = (self.iFrameIsBordered) ? @"iframe-border" : @"iframe-no-border";
            NSString *frameBorder = (self.iFrameIsBordered) ? @"1" : @"0";
            NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                        class, @"class",
                                        src, @"src",
                                        @"test iframe", @"title",
                                        frameBorder, @"frameBorder",
                                        nil];
            // write iframe
            // width and height attrs are included by writer
            [context startElement:@"iframe"
                 bindSizeToPlugIn:self
                  preferredIdName:@"iframe"
                       attributes:attributes];
            
            // write fallback link in case iframe isn't supported -- it's supported in HTML5, still needed?
            // I think this has nothing to do with the spec, but instead, older browsers - Mike
            [context startAnchorElementWithHref:[self.linkURL absoluteString]
                                          title:self.title
                                         target:nil 
                                            rel:nil];
            [context writeCharacters:self.title];
            [context endElement]; // </a>
            
            [context endElement]; // </div>
        }
        else
        {
            [context startElement:@"div" bindSizeToPlugIn:self preferredIdName:nil attributes:nil];
            
            NSString *placeholder = SVLocalizedString(@"Placeholder for:", "String - followed by a URL");
            NSString *text = [NSString stringWithFormat:@"%@ %@", placeholder, self.linkURL];
            [context writePlaceholderWithText:text options:0];
            
            [context endElement];
        }
    }
    else
    {
        [context startElement:@"div" bindSizeToPlugIn:self preferredIdName:nil attributes:nil];
        
        NSString *text = SVLocalizedString(@"Please enter a URL in the Inspector.","");
        [context writePlaceholderWithText:text options:0];
        
        [context endElement];
    }
}
                                     

#pragma mark Metrics

- (NSNumber *)minWidth { return [NSNumber numberWithInt:100]; }
- (NSNumber *)minHeight { return [NSNumber numberWithInt:100]; }

- (void)makeOriginalSize;
{
    // pick an artibrary, yet visible, size to start with
    [self setWidth:[NSNumber numberWithInt:320] height:[NSNumber numberWithInt:640]];
}


#pragma mark Drag and Drop

+ (NSArray *)readableTypesForPasteboard:(NSPasteboard *)pasteboard;
{
    return SVWebLocationGetReadablePasteboardTypes(pasteboard);
}

+ (SVPasteboardPriority)priorityForPasteboardItem:(id <SVPasteboardItem>)item;
{
    NSURL *URL = [item URL];
    if ( URL )
    {
        if ( [URL isFileURL ] )
        {
            return SVPasteboardPriorityNone;
        }
        else
        {
            return SVPasteboardPriorityReasonable;
        }
        
    }
    return [super priorityForPasteboardItem:item];
}

- (BOOL)awakeFromPasteboardItems:(NSArray *)items;
{
    BOOL didAwakeAnItem = NO;
    
    if ( items && [items count] )
    {      
        id<SVPasteboardItem, SVWebLocation> item = [items objectAtIndex:0];
        
        if ( [item conformsToProtocol:@protocol(SVWebLocation)] )
        {
            if ( [item  URL] ) self.linkURL = [item URL];
            if ( [item title] ) [self setTitle:[item title]];
            didAwakeAnItem = YES;
        }
    }
    
    return didAwakeAnItem;    
}

+ (BOOL)supportsMultiplePasteboardItems; { return NO; }


#pragma mark Properties

@synthesize linkURL = _linkURL;

@synthesize iFrameIsBordered = _iFrameIsBordered;
- (void)setIFrameIsBordered:(BOOL)yn
{
    [self willChangeValueForKey:@"iFrameIsBordered"];
    _iFrameIsBordered = yn;
    [[NSUserDefaults standardUserDefaults] setBool:yn forKey:@"iFramePageletIsBordered"];
    [self didChangeValueForKey:@"iFrameIsBordered"];
}

@end
