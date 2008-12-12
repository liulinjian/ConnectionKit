//
//  KTPublishingWindowController.h
//  Marvel
//
//  Created by Mike on 08/12/2008.
//  Copyright 2008 Karelia Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "KTPublishingEngine.h"


@class KTExportEngine, CKTransferRecord;


@interface KTPublishingWindowController : NSWindowController <KTPublishingEngineDelegate>
{
    IBOutlet NSTextField            *oMessageLabel;
    IBOutlet NSTextField            *oInformativeTextLabel;
    IBOutlet NSProgressIndicator    *oProgressIndicator;
    IBOutlet NSButton               *oFirstButton;
    IBOutlet NSTableColumn          *oTransferDetailsTableColumn;
    
    
    @private
    KTExportEngine      *_publishingEngine;
    CKTransferRecord    *_currentTransfer;
    BOOL                _didFail;
}

- (IBAction)firstButtonAction:(NSButton *)sender;

- (id)initWithPublishingEngine:(KTExportEngine *)engine;
- (KTExportEngine *)publishingEngine;
- (BOOL)isExporting;

- (CKTransferRecord *)currentTransfer;

// Presentation
- (void)beginSheetModalForWindow:(NSWindow *)window;
- (void)endSheet;

@end
