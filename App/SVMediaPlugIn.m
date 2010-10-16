//
//  SVMediaPlugIn.m
//  Sandvox
//
//  Created by Mike on 24/09/2010.
//  Copyright 2010 Karelia Software. All rights reserved.
//

#import "SVMediaPlugIn.h"

#import "SVMediaRecord.h"

#import "NSString+Karelia.h"
#import "KSURLUtilities.h"
#import "NSError+Karelia.h"


@implementation SVMediaPlugIn

#pragma mark Properties

- (SVMediaRecord *)media; { return [[self container] media]; }
- (SVMediaRecord *)posterFrame; { return [[self container] posterFrame]; }
- (NSURL *)externalSourceURL; { return [[self container] externalSourceURL]; }

- (void)didSetSource;
{
    [[self container] setTypeToPublish:[[self media] typeOfFile]];
}

+ (NSArray *)allowedFileTypes; { return nil; }

- (BOOL)validatePosterFrame:(SVMediaRecord *)posterFrame;
{
    return (posterFrame == nil);
}

#pragma mark Media Conversion

- (BOOL)validateTypeToPublish:(NSString *)type; { return YES; }

#pragma mark Metrics

+ (BOOL)isExplicitlySized; { return YES; }

- (BOOL)validateHeight:(NSNumber **)height error:(NSError **)error;
{
    // SVGraphic.width is optional. For media graphics it becomes compulsary
    BOOL result = (*height != nil);
    if (!result && error)
    {
        *error = [NSError errorWithDomain:NSCocoaErrorDomain
                                     code:NSValidationMissingMandatoryPropertyError
                     localizedDescription:@"height is a mandatory property"];
    }
    
    return result;
}

- (CGSize)originalSize;
{
    CGSize result = CGSizeZero;
    
    SVMediaRecord *media = [self media];
    if (media)
	{
		SVMediaGraphic *container = [self container];
        
        NSNumber *naturalWidth = container.naturalWidth;
		NSNumber *naturalHeight = container.naturalHeight;
		// Try to get cached natural size first
		if (nil != naturalWidth && nil != naturalHeight)
		{
			result = CGSizeMake([naturalWidth floatValue], [naturalHeight floatValue]);
		}
		else	// ask the media for it, and cache it.
		{
			result = [media originalSize];
			container.naturalWidth = [NSNumber numberWithFloat:result.width];
			container.naturalHeight = [NSNumber numberWithFloat:result.height];
		}
	}
	
    
    return result;
}

- (void)makeOriginalSize;
{
    CGSize size = [self originalSize];
    if (!CGSizeEqualToSize(size, CGSizeZero))
    {
        [self setWidth:size.width];
        [self setHeight:size.height];
    }
}

#pragma mark SVEnclosure

- (NSURL *)downloadedURL;   // where it currently resides on disk
{
	NSURL *mediaURL = nil;
	SVMediaRecord *media = [self media];
	
    if (media)
    {
		mediaURL = [media mediaURL];
	}
	else
	{
		mediaURL = [self externalSourceURL];
	}
	return mediaURL;
}

- (long long)length;
{
	long long result = 0;
	SVMediaRecord *media = [self media];
	
    if (media)
    {
		NSData *mediaData = [media mediaData];
		result = [mediaData length];
	}
	return result;
}

- (NSString *)MIMEType;
{
	NSString *type = [[self media] typeOfFile];
    if (!type)
    {
        type = [NSString UTIForFilenameExtension:[[self externalSourceURL] ks_pathExtension]];
    }
    
    NSString *result = (type ? [NSString MIMETypeForUTI:type] : nil);
	return result;
}

- (NSURL *)URL; { return [self externalSourceURL]; }

#pragma mark HTML

- (BOOL)shouldWriteHTMLInline; { return NO; }
- (BOOL)canWriteHTMLInline; { return NO; }
- (id <SVMedia>)thumbnailMedia; { return [self media]; }
- (id)imageRepresentation; { return [[self media] imageRepresentation]; }
- (NSString *)imageRepresentationType; { return [[self media] imageRepresentationType]; }


#pragma mark Inspector

- (id)valueForUndefinedKey:(NSString *)key; { return NSNotApplicableMarker; }

@end
