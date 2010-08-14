//
//  SVImageDOMController.m
//  Sandvox
//
//  Created by Mike on 27/01/2010.
//  Copyright 2010 Karelia Software. All rights reserved.
//

#import "SVImageDOMController.h"

#import "WebEditingKit.h"
#import "SVWebEditorHTMLContext.h"

#import "DOMNode+Karelia.h"

#import <QuartzCore/QuartzCore.h>


@implementation SVImageDOMController

#pragma mark Element

- (NSString *)elementIdName;
{
    NSString *idName = [[self representedObject] elementIdName];
    NSString *result = (idName ? [@"image-" stringByAppendingString:idName] : nil);
    return result;
}

#pragma mark Selection

- (void)updateToReflectSelection;
{
    // Do nothing!!
}

- (BOOL)allowsDirectAccessToWebViewWhenSelected; { return YES; }

#pragma mark Resizing

- (void)resizeToSize:(NSSize)size byMovingHandle:(SVGraphicHandle)handle;
{
    // Size calculated – now what to store?
    BOOL resizingWidth = (handle == kSVGraphicUpperLeftHandle ||
                          handle == kSVGraphicMiddleLeftHandle ||
                          handle == kSVGraphicLowerLeftHandle ||
                          handle == kSVGraphicUpperRightHandle ||
                          handle == kSVGraphicMiddleRightHandle ||
                          handle == kSVGraphicLowerRightHandle);
    
    BOOL resizingHeight = (handle == kSVGraphicUpperLeftHandle ||
                           handle == kSVGraphicUpperMiddleHandle ||
                           handle == kSVGraphicUpperRightHandle ||
                           handle == kSVGraphicLowerLeftHandle ||
                           handle == kSVGraphicLowerMiddleHandle ||
                           handle == kSVGraphicLowerRightHandle);
    
    
    // Snap to original size if you are very close to it
	SVImage *image = [self representedObject];
	CGSize originalSize = [image originalSize];
	
#define SNAP 4
	if (resizingWidth && ( abs(size.width - originalSize.width) < SNAP) )
	{
		size.width = originalSize.width;
	}
	if (resizingHeight && ( abs(size.height - originalSize.height) < SNAP) )
	{
		size.height = originalSize.height;
	}
    
    
    // Apply the change
    if (resizingWidth)
    {
        if (resizingHeight)
        {
            [image setSize:size];
        }
        else
        {
            [image setWidth:[NSNumber numberWithFloat:size.width]];
        }
    }
    else if (resizingHeight)
    {
        [image setHeight:[NSNumber numberWithFloat:size.height]];
    }
}

- (NSSize)minSize;
{
    // Remove the 200px width restriction
    NSSize result = [super minSize];
    result.width = result.height;
    return result;
}

- (NSPoint)locationOfHandle:(SVGraphicHandle)handle;
{
    SVSelectionBorder *border = [self newSelectionBorder];
    
    NSPoint result = [border locationOfHandle:handle
                                    frameRect:[border frameRectForGraphicBounds:
                                               [[self HTMLElement] boundingBox]]];
    
    [border release];
    return result;
}

- (DOMElement *)selectableDOMElement; { return [self HTMLElement]; }

- (unsigned int)resizingMask
{
    // Super's behaviour is enough to handle width, but we want height to be adjustable too.
    unsigned int result = (kCALayerBottomEdge | [super resizingMask]);
    return result;
}

#define MINDIMENSION 16.0

#pragma mark Drawing

- (SVSelectionBorder *)newSelectionBorder;
{
    SVSelectionBorder *result = [super newSelectionBorder];
    [result setBorderColor:nil];
    return result;
}

@end


#pragma mark -


@implementation SVImagePageletDOMController

- (void)awakeFromHTMLContext:(SVWebEditorHTMLContext *)context;
{
    [super awakeFromHTMLContext:context];
    return;
    
    // Add separate DOM controller for the image itself
    [_imageDOMController release]; _imageDOMController = [[SVImageDOMController alloc] init];
    [_imageDOMController setRepresentedObject:[self representedObject]];
    
    [self addChildWebEditorItem:_imageDOMController];
}

- (SVSizeBindingDOMController *)newSizeBindingControllerWithRepresentedObject:(id)object;
{
    return [[SVImageDOMController alloc] initWithRepresentedObject:object];
}

- (void)dealloc
{
    [_imageDOMController release];
    [super dealloc];
}

#pragma mark Controller

@synthesize imageDOMController = _imageDOMController;

- (DOMElement *)selectableDOMElement;
{
    // Normally we are, but not for chrome-less images
    DOMElement *imageElement = [[self imageDOMController] HTMLElement];
    DOMElement *result = [super selectableDOMElement];
    
    if (result == imageElement) result = nil;
    return result;
}

#pragma mark DOM

- (void)setHTMLElement:(DOMHTMLElement *)element;
{
    // Is this a change due to being orphaned while editing? If so, pass down to image controller too. #83312
    if ([self HTMLElement] == [[self imageDOMController] HTMLElement])
    {
        [[self imageDOMController] setHTMLElement:element];
    }
    
    [super setHTMLElement:element];
}

- (void)loadHTMLElementFromDocument:(DOMDocument *)document;
{
    // Hook up image controller first
    SVImageDOMController *imageController = [self imageDOMController];
    if (![imageController isHTMLElementCreated])
    {
        [imageController loadHTMLElementFromDocument:document];
    }
    
    [super loadHTMLElementFromDocument:document];
    
    // If it failed that's because the image is chromeless, so adopt its element
    if (![self isHTMLElementCreated])
    {
        [self setHTMLElement:[imageController HTMLElement]];
    }
}

@end


#pragma mark -


@implementation SVImage (SVDOMController)

- (SVDOMController *)newDOMController;
{
    //Class class = ([self isPagelet] ? [SVImagePageletDOMController class] : [SVImageDOMController class]);
    return [[SVImagePageletDOMController alloc] initWithRepresentedObject:self];
}

@end

