//
//  NSManagedObjectContext+KTExtensions.h
//  Sandvox
//
//  Copyright 2005-2009 Karelia Software. All rights reserved.
//
//  THIS SOFTWARE IS PROVIDED BY KARELIA SOFTWARE AND ITS CONTRIBUTORS "AS-IS"
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

#import <Cocoa/Cocoa.h>
#import "NSManagedObjectContext+Karelia.h"


@class KTAbstractElement, KTDocument, KTSite, KTAbstractPage, KTPage;

@interface NSManagedObjectContext (KTExtensions)

#pragma mark General NSManagedObjectContext extensions

/*! returns an autoreleased core data stack with file at aStoreURL */
+ (NSManagedObjectContext *)contextWithStoreType:(NSString *)storeType
                                             URL:(NSURL *)aStoreURL
                                           model:(NSManagedObjectModel *)aModel
                                           error:(NSError **)error;

/*! returns set of all updated, inserted, and deleted objects in context */
- (NSSet *)changedObjects;

- (void)deleteObjectsInCollection:(id)collection;   // e.g. NSArray or NSSet

- (NSArray *)objectsWithFetchRequestTemplateWithName:(NSString *)aTemplateName
							   substitutionVariables:(NSDictionary *)aDictionary
											   error:(NSError **)anError;

// returns object corresponding to NSManagedObjectID's URIRepresentation
- (NSManagedObject *)objectWithURIRepresentation:(NSURL *)aURL;

// returns object corresponding to NSString of NSManagedObjectID's URIRepresentation
- (NSManagedObject *)objectWithURIRepresentationString:(NSString *)aURIRepresentationString;

// returns array of unique values for aColumnName for all instances of anEntityName
- (NSArray *)objectsForColumnName:(NSString *)aColumnName entityName:(NSString *)anEntityName;

#pragma mark methods Sandvox-specific extensions

// return context's Site
- (KTSite *)site;

// returns object in context matching criteria 
- (NSManagedObject *)objectWithUniqueID:(NSString *)aUniqueID entityName:(NSString *)anEntityName;

- (void)deletePage:(KTAbstractPage *)page;  // Please ALWAYS call this for pages as it posts a notification first

@end
