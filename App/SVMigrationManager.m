//
//  SVMigrationManager.m
//  Sandvox
//
//  Created by Mike on 14/02/2011.
//  Copyright 2011 Karelia Software. All rights reserved.
//

#import "SVMigrationManager.h"

#import "KTDocument.h"
#import "KT.h"

#import "KSExtensibleManagedObject.h"
#import "KSURLUtilities.h"


@implementation SVMigrationManager

- (id)initWithSourceModel:(NSManagedObjectModel *)sourceModel
               mediaModel:(NSManagedObjectModel *)mediaModel
         destinationModel:(NSManagedObjectModel *)destinationModel;
{
    OBPRECONDITION(mediaModel);
    
    if (self = [super initWithSourceModel:sourceModel destinationModel:destinationModel])
    {
        _mediaModel = [mediaModel retain];
    }
    
    return self;
}

- (id)initWithSourceModel:(NSManagedObjectModel *)sourceModel destinationModel:(NSManagedObjectModel *)destinationModel;
{
    return [self initWithSourceModel:sourceModel mediaModel:nil destinationModel:destinationModel];
}

- (BOOL)migrateDocumentFromURL:(NSURL *)sourceDocURL
              toDestinationURL:(NSURL *)dURL
                         error:(NSError **)error;
{
    // Create context for accessing media during migration
    NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc]
                                                 initWithManagedObjectModel:[self sourceMediaModel]];
    
    NSURL *sMediaStoreURL = [sourceDocURL ks_URLByAppendingPathComponent:@"media.xml" isDirectory:NO];
    
    if (![coordinator addPersistentStoreWithType:NSXMLStoreType
                                   configuration:nil
                                             URL:sMediaStoreURL
                                         options:nil
                                           error:error])
    {
        [coordinator release];
        return NO;
    }
    
    _mediaContext = [[NSManagedObjectContext alloc] init];
    [_mediaContext setPersistentStoreCoordinator:coordinator];
    [coordinator release];
    
    
    // Do the migration
    NSURL *modelURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Sandvox" ofType:@"cdm"]];
    NSMappingModel *mappingModel = [[NSMappingModel alloc] initWithContentsOfURL:modelURL];
    
    _docURL = dURL;
    NSURL *sStoreURL = [KTDocument datastoreURLForDocumentURL:sourceDocURL type:kKTDocumentUTI_1_5];
    NSURL *dStoreURL = [KTDocument datastoreURLForDocumentURL:sourceDocURL type:nil];
    
    BOOL result = [self migrateStoreFromURL:sStoreURL
                                       type:NSSQLiteStoreType
                                    options:nil
                           withMappingModel:mappingModel
                           toDestinationURL:dStoreURL
                            destinationType:NSBinaryStoreType
                         destinationOptions:nil
                                      error:error];
    
    _docURL = nil;
    [mappingModel release];
    [_mediaContext release];
    
    return result;
}

- (NSManagedObjectModel *)sourceMediaModel; { return _mediaModel; }

- (NSManagedObjectContext *)sourceMediaContext; { return _mediaContext; }

- (NSURL *)sourceURLOfMediaWithFilename:(NSString *)filename;
{
    NSURL *result = [[[_docURL ks_URLByAppendingPathComponent:@"Site" isDirectory:YES]
                      ks_URLByAppendingPathComponent:@"_Media" isDirectory:YES]
                     ks_URLByAppendingPathComponent:filename isDirectory:NO];
    return result;
}

- (NSFetchRequest *)pagesFetchRequest;
{
    // The default request generated by Core Data ignores sub-entites, meaning the home page doesn't get migrated. So, I wrote this custom method that builds a less picky predicate.
    
    NSFetchRequest *result = [[[NSFetchRequest alloc] init] autorelease];
    [result setEntity:[self sourceEntityForEntityMapping:[self currentEntityMapping]]];
    
    [result setPredicate:[NSPredicate predicateWithFormat:
                          @"pluginIdentifier != 'sandvox.DownloadElement' && pluginIdentifier != 'sandvox.LinkElement'"]];
    
    return result;
}

- (NSDictionary *)extensiblePropertiesFromData:(NSData *)data;
{
    NSDictionary *result = [KSExtensibleManagedObject unarchiveExtensibleProperties:data];
    return result;
}

@end
