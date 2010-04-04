//
//  SVPageletManager.m
//  Sandvox
//
//  Created by Mike on 04/04/2010.
//  Copyright 2010 Karelia Software. All rights reserved.
//

#import "SVPageletManager.h"

#import "KTElementPlugInWrapper.h"
#import "SVGraphicRegistrationInfo.h"

#import "NSSet+Karelia.h"

#import "Registration.h"


@implementation SVPageletManager

static SVPageletManager *sSharedPageletManager;

+ (void)initialize
{
    if (!sSharedPageletManager)
    {
        // Order plug-ins first by priority, then by name
        NSSet *plugins = [KTElementPlugInWrapper pageletPlugins];
        
        NSSortDescriptor *prioritySort = [[NSSortDescriptor alloc] initWithKey:@"priority"
                                                                     ascending:YES];
        NSSortDescriptor *nameSort = [[NSSortDescriptor alloc]
                                      initWithKey:@"name"
                                      ascending:YES
                                      selector:@selector(caseInsensitiveCompare:)];
        
        NSArray *sortDescriptors = [NSArray arrayWithObjects:prioritySort, nameSort, nil];
        [prioritySort release];
        [nameSort release];
        
        NSArray *sortedPlugins = [plugins KS_sortedArrayUsingDescriptors:sortDescriptors];
        
        sSharedPageletManager = [[SVPageletManager alloc] initWithGraphicFactories:sortedPlugins];
    }
}

+ (SVPageletManager *)sharedPageletManager; { return sSharedPageletManager; }

- (id)initWithGraphicFactories:(NSArray *)graphicFactories;
{
    [self init];
    
    _graphicFactories = [graphicFactories copy];
    
    return self;
}

@synthesize graphicFactories = _graphicFactories;

#pragma mark Menu

// nil targeted actions will be sent to firstResponder (the active document)
// representedObject is the bundle of the plugin
- (void)populateMenu:(NSMenu *)menu atIndex:(NSUInteger)index;
{	
    for (id <SVGraphicFactory> factory in [self graphicFactories])
	{
		NSMenuItem *menuItem = [[[NSMenuItem alloc] init] autorelease];
		
        
        // Name
		NSString *pluginName = [factory name];
		if (![pluginName length])
		{
			NSLog(@"empty plugin name for %@", factory);
			pluginName = @"";
		}
		[menuItem setTitle:pluginName];
        
        
		// Icon
        NSImage *image = [[factory pluginIcon] copy];
#ifdef DEBUG
        if (!image) NSLog(@"nil pluginIcon for %@", pluginName);
#endif
        
        [image setSize:NSMakeSize(32.0f, 32.0f)];
        [menuItem setImage:image];
        [image release];
        
        
        // Pro status
        if (9 == [factory priority] && nil == gRegistrationString)
        {
            [[NSApp delegate] setMenuItemPro:menuItem];
        }
		
        
		
		[menuItem setRepresentedObject:factory];
        
		
		// set target/action
		[menuItem setAction:@selector(insertPagelet:)];
		
		[menu insertItem:menuItem atIndex:index];   index++;
	}
}

@end
