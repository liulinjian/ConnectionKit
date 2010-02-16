//
//  SVParagraph.h
//  Sandvox
//
//  Created by Mike on 18/11/2009.
//  Copyright 2009 Karelia Software. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "SVBodyElement.h"

@class SVPlugInPagelet;

@interface SVBodyParagraph :  SVBodyElement  

#pragma mark HTML

- (void)writeHTML;
- (void)writeInnerHTML;

- (NSString *)styleAttribute;


#pragma mark Raw Properties
// External code should rarely need to modify these
@property(nonatomic, copy) NSString *archiveString;

@property(nonatomic, copy) NSString *customTextAlign;


#pragma mark Attributes
@property(nonatomic, copy) NSSet *attributes;
- (NSArray *)orderedAttributes;


@end

