//
//  KTAbstractPage.h
//  Marvel
//
//  Created by Mike on 28/02/2008.
//  Copyright 2008 Karelia Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "KTAbstractElement.h"

#import "KTWebPathsProtocol.h"
#import "KTWebViewComponentProtocol.h"


typedef enum	//	Defines the 3 ways of linking to a collection:
{
	KTCollectionDirectoryPath,			//		collection
	KTCollectionHTMLDirectoryPath,		//		collection/
	KTCollectionIndexFilePath,			//		collection/index.html
}
KTCollectionPathStyle;


@class KTDocumentInfo, KTMaster;
@class KTHTMLParser;


@interface KTAbstractPage : KTAbstractElement <KTWebViewComponent>
{
}

+ (NSString *)entityName;
+ (NSArray *)allPagesInManagedObjectContext:(NSManagedObjectContext *)MOC;
+ (id)pageWithUniqueID:(NSString *)ID inManagedObjectContext:(NSManagedObjectContext *)MOC;

+ (id)pageWithParent:(KTPage *)aParent entityName:(NSString *)entityName;

#pragma mark Relationships
- (KTPage *)parent;
- (BOOL)isCollection;
- (BOOL)isRoot;

- (KTDocumentInfo *)documentInfo;

- (KTMaster *)master;

#pragma mark Title
- (BOOL)canEditTitle;

- (BOOL)shouldUpdateFileNameWhenTitleChanges;
- (void)setShouldUpdateFileNameWhenTitleChanges:(BOOL)autoUpdate;

#pragma mark Web
- (NSString *)pageMainContentTemplate;	// instance method too for key paths to work in tiger
- (NSString *)contentHTMLWithParserDelegate:(id)delegate isPreview:(BOOL)isPreview;
- (BOOL)isXHTML;

// Staleness
- (BOOL)isStale;
- (void)setIsStale:(BOOL)stale;

- (NSData *)publishedDataDigest;
- (void)setPublishedDataDigest:(NSData *)digest;


// Notifications
- (void)postSiteStructureDidChangeNotification;

@end


@interface KTAbstractPage (Paths) <KTWebPaths>

// File Name
- (NSString *)fileName;
- (void)setFileName:(NSString *)fileName;
- (NSString *)suggestedFileName;


// File Extension
- (NSString *)fileExtension;

- (NSString *)customFileExtension;
- (void)setCustomFileExtension:(NSString *)extension;

- (BOOL)fileExtensionIsEditable;
- (void)setFileExtensionIsEditable:(BOOL)editable;

- (NSString *)defaultFileExtension;
- (NSArray *)availableFileExtensions;


// Summat else
- (NSString *)indexFilename;
- (NSString *)indexFileName;
- (NSString *)archivesFilename;


// Publishing
- (NSURL *)URL;
- (void)recursivelyInvalidateURL:(BOOL)recursive;

- (NSString *)customPathRelativeToSite;
- (void)setCustomPathRelativeToSite:(NSString *)path;

- (NSString *)uploadPath;

- (NSString *)publishedPath;
- (void)setPublishedPath:(NSString *)path;

// Preview
- (NSString *)previewPath;

@end

