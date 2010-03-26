//
//  SVGraphic.h
//  Sandvox
//
//  Created by Mike on 11/10/2009.
//  Copyright 2009 Karelia Software. All rights reserved.
//

#import "SVContentObject.h"
#import <iMedia/IMBImageItem.h>


typedef enum {
    SVGraphicPlacementInline,
    SVGraphicPlacementBlock,
} SVGraphicPlacement;

typedef enum {  // Note that "left" or "right" refers to the side of the graphic *text* will be placed
    SVGraphicWrapNone,
    SVGraphicWrapLeftSplit,
    SVGraphicWrapCenterSplit,
    SVGraphicWrapRightSplit,
    SVGraphicWrapLeft,
    SVGraphicWrapCenter,
    SVGraphicWrapRight,
} SVGraphicWrap;


#define SVContentObjectWrapNone [NSNumber numberWithInteger:SVGraphicWrapNone]
#define SVContentObjectWrapFloatLeft [NSNumber numberWithInteger:SVGraphicWrapLeft]
#define SVContentObjectWrapFloatRight [NSNumber numberWithInteger:SVGraphicWrapRight]
#define SVContentObjectWrapBlockLeft [NSNumber numberWithInteger:SVGraphicWrapLeftSplit]
#define SVContentObjectWrapBlockCenter [NSNumber numberWithInteger:SVGraphicWrapCenterSplit]
#define SVContentObjectWrapBlockRight [NSNumber numberWithInteger:SVGraphicWrapRightSplit]
//typedef NSNumber SVContentObjectWrap;
#define SVContentObjectWrap NSNumber


#pragma mark -


//  Have decided to use the term "graphic" in the same way that Pages does through its scripting API (and probably in its class hierarchy). That is, a graphic is anything on the page that can be selected and isn't text. e.g. pagelets, images, plug-ins.

//  I'm declaring a protocol for graphics first to keep things nice and pure. (Also, it means I can make some things @optional so that Core Data will still generate accessors when the superclass chooses not to implement the method)

@protocol SVGraphic
- (NSString *)elementID;
@optional
@end


#pragma mark -


@class SVTitleBox;
@class SVTextAttachment, SVTemplate;


@interface SVGraphic : SVContentObject <SVGraphic>

#pragma mark Pagelet
- (BOOL)isPagelet;  // whether to generate <div class="pagelet"> etc. HTML
- (BOOL)isCallout;  // whether to generate enclosing <div class="callout"> etc.
- (NSString *)calloutWrapClassName; // nil if not a callout


#pragma mark Title
@property(nonatomic, retain) SVTitleBox *titleBox;
- (void)setTitle:(NSString *)title;   // creates Title object if needed
+ (NSString *)placeholderTitleText;


#pragma mark Layout/Styling
@property(nonatomic, copy) NSNumber *showBackground;
@property(nonatomic, copy) NSNumber *showBorder;


#pragma mark Placement

/*  There is generally no need to directly adjust a graphic's wrap setting. In particular, one hazard is that you could cause a block-level object appear inline. i.e. invalid HTML. Instead, use the higher-level DOM Controller API to modify wrap/placement of the selection.
 */

@property(nonatomic, retain) SVTextAttachment *textAttachment;
- (BOOL)canBePlacedInline;  // default is NO. Subclasses can override
- (void)didPlaceInline:(BOOL)isInline; // turns off title, etc.

- (void)detachFromBodyText; // deletes the corresponding text attachment and string if there is one.


#pragma mark Sidebar

+ (NSArray *)sortedPageletsInManagedObjectContext:(NSManagedObjectContext *)context;
+ (NSArray *)arrayBySortingPagelets:(NSSet *)pagelets;
+ (NSArray *)pageletSortDescriptors;

// Checks that a given set of pagelets have unique sort keys
+ (BOOL)validatePagelets:(NSSet **)pagelets error:(NSError **)error;

// Shouldn't really have any need to set this yourself. Use a proper array controller instead please.
@property(nonatomic, copy) NSNumber *sortKey;

@property(nonatomic, readonly) NSSet *sidebars;

- (void)moveBeforeSidebarPagelet:(SVGraphic *)pagelet;
- (void)moveAfterSidebarPagelet:(SVGraphic *)pagelet;


#pragma mark HTML

- (void)writeBody;  // Subclasses MUST override

@property(nonatomic, retain, readonly) NSString *elementID;
- (NSString *)className;

+ (SVTemplate *)template;
   

#pragma mark Thumbnail
@property(nonatomic, readonly) id <IMBImageItem> thumbnail; // MUST be KVO-compliant


#pragma mark Serialization
+ (id)graphicWithSerializedProperties:(id)properties
       insertIntoManagedObjectContext:(NSManagedObjectContext *)context;


@end


