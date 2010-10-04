//
//  SVIndexPlugIn.m
//  Sandvox
//
//  Created by Mike on 10/08/2010.
//  Copyright 2010 Karelia Software. All rights reserved.
//

#import "SVIndexPlugIn.h"

#import "SVPageProtocol.h"


@implementation SVIndexPlugIn

- (void)awakeFromNew
{
    [super awakeFromNew];
    self.enableMaxItems = YES;
    self.maxItems = 10;
}

- (void)didAddToPage:(id <SVPage>)page;
{
    if (![self indexedCollection])
    {
        if ([page isCollection]) [self setIndexedCollection:page];
    }
}


#pragma mark Metrics

- (void)makeOriginalSize;
{
    [self setWidth:0];
    [self setHeight:0];
}


#pragma mark Child Pages

- (NSArray *)iteratablePagesOfCollection
{
    NSArray *result = nil;
    if ( self.enableMaxItems && self.maxItems > 0 )
    {
        NSMutableArray *array = [NSMutableArray arrayWithCapacity:self.maxItems];
        NSUInteger numberOfChildPages = [[self.indexedCollection childPages] count];
        NSUInteger arrayMax = (numberOfChildPages < self.maxItems) ? numberOfChildPages : self.maxItems;
        for ( NSUInteger i=0; i<arrayMax; i++ )
        {
            id<SVPage> childPage = [[self.indexedCollection childPages] objectAtIndex:i];
            [array addObject:childPage];
        }
        result = [NSArray arrayWithArray:array];
    }
    else
    {
        result = self.indexedCollection.childPages;
    }
    return result;
}


#pragma mark Serialization

+ (NSArray *)plugInKeys;
{
    NSArray *plugInKeys = [NSArray arrayWithObjects:
                           @"indexedCollection", 
                           @"maxItems", 
                           @"enableMaxItems", 
                           nil];
    NSArray *result = [[super plugInKeys] arrayByAddingObjectsFromArray:plugInKeys];
    OBPOSTCONDITION(result);
    return result;
}

- (id)serializedValueForKey:(NSString *)key;
{
    if ([key isEqualToString:@"indexedCollection"])
    {
        return [[self indexedCollection] identifier];
    }
    else
    {
        return [super serializedValueForKey:key];
    }
}

- (void)setSerializedValue:(id)serializedValue forKey:(NSString *)key;
{
    if ([key isEqualToString:@"indexedCollection"])
    {
        [self setIndexedCollection:(serializedValue ?
                                    [self pageWithIdentifier:serializedValue] :
                                    nil)];
    }
    else
    {
        [super setSerializedValue:serializedValue forKey:key];
    }
}


#pragma mark HTML Generation

- (void)writeHTML:(id <SVPlugInContext>)context
{
    // add dependencies
    [context addDependencyForKeyPath:@"maxItems" ofObject:self];
    [context addDependencyForKeyPath:@"enableMaxItems" ofObject:self];
    [context addDependencyForKeyPath:@"indexedCollection" ofObject:self];
    [context addDependencyForKeyPath:@"indexedCollection.childPages" ofObject:self];
    
    if ( self.indexedCollection )
    {
        if ( [[self iteratablePagesOfCollection] count] )
        {
            [super writeHTML:context];
        }
        else if ( [context isForEditing] )
        {
            [[context HTMLWriter] startElement:@"p"];
            [[context HTMLWriter] writeText:NSLocalizedString(@"To see the Index, please add indexable pages to the collection.","add pages to collection")];
            [[context HTMLWriter] endElement];
        }
    }
    else if ( [context isForEditing] )
    {
        [[context HTMLWriter] startElement:@"p"];
        [[context HTMLWriter] writeText:NSLocalizedString(@"Please specify the collection to index using the PlugIn Inspector.","set index collectionb")];
        [[context HTMLWriter] endElement];
    }
}


#pragma mark Properties

@synthesize indexedCollection = _collection;
- (void)setIndexedCollection:(id <SVPage>)collection
{
    // when we change indexedCollection, set the containers title to the title of the collection, or to
    // KTPluginUntitledName if collection is nil
    [collection retain];
    [_collection release]; _collection = collection;
    
    if ( collection )
    {
        [self setTitle:[collection title]];
    }
    else
    {
        NSString *defaultTitle = [[self bundle] objectForInfoDictionaryKey:@"KTPluginUntitledName"];
        [self setTitle:defaultTitle];
    }
}


@synthesize enableMaxItems = _enableMaxItems;

@synthesize maxItems = _maxItems;
- (NSUInteger)maxItems
{
    // return 0 if user has disabled maximum
    return (self.enableMaxItems) ? _maxItems : 0;
}

@end
