//
//  Nagui.h
//  Nagui
//
//  Created by Appledelhi on 08. 08. 17.
//  Copyright 2008 Appledelhi. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class NgProtocolHandler;
@class NgSearchManager;
@class NgTransferManager;
@class NgServerManager;
@class NgOptionManager;
@class NgFolderManager;
@class NgMlnetManager;
@class NgShareManager;
@class NgTaskManager;

@interface Nagui : NSWindowController {
  IBOutlet id contentView;
  IBOutlet id consoleView;
  IBOutlet id searchView;
  IBOutlet id transferView;
  IBOutlet id serverView;
  IBOutlet id shareView;
  IBOutlet id optionView;
  IBOutlet id mlnetView;
  
  IBOutlet id searchField;
  IBOutlet id downloadProgress;
  IBOutlet id usersColumn;
  IBOutlet id filesColumn;
  IBOutlet id folderColumn;
  IBOutlet id shareMenu;
  
  IBOutlet NgSearchManager *searchManager;
  IBOutlet NgTransferManager *transferManager;
  IBOutlet NgServerManager *serverManager;
  IBOutlet NgOptionManager *optionManager;
  IBOutlet NgShareManager *shareManager;
  IBOutlet NgTaskManager *taskManager;
  IBOutlet NgMlnetManager *mlnetManager;
  
  NgProtocolHandler *protocolHandler;
  NSView *currentView;
  id currentManager;
  NSAlert *alert;
  NSAlert *askDelete;
  
  NSImage *downArrowImage;
  NSImage *downloadImage;
  NSImage *downloadingImage;
  NSImage *folderImage;
  NSImage *incomingDirImage;
  NSImage *xInCircleImage;
  NSImage *alertImage;
  NSImage *smartFolderImage;
}

@property(readonly) NgSearchManager *searchManager;
@property(readonly) NgTransferManager *transferManager;
@property(readonly) NgServerManager *serverManager;
@property(readonly) NgOptionManager *optionManager;
@property(readonly) NgShareManager *shareManager;
@property(readonly) NgTaskManager *taskManager;
@property(readonly) NgProtocolHandler *protocolHandler;
@property(readonly) id downloadProgress;
@property(readonly) id shareMenu;
@property(readonly) id currentManager;
@property(readonly) NSImage *downArrowImage;
@property(readonly) NSImage *downloadImage;
@property(readonly) NSImage *downloadingImage;
@property(readonly) NSImage *folderImage;
@property(readonly) NSImage *incomingDirImage;
@property(readonly) NSImage *xInCircleImage;
@property(readonly) NSImage *alertImage;
@property(readonly) NSImage *smartFolderImage;

- (void)log:(NSString *)format, ...;
- (void)alert:(NSString *)msg informative:(NSString *)informative;
- (void)error:(OSStatus)error;
- (BOOL)askDelete:(NSString *)fileName;
- (BOOL)showingShare;

- (IBAction)showConsole:sender;
- (IBAction)showSearch:sender;
- (IBAction)showTransfer:sender;
- (IBAction)showServer:sender;
- (IBAction)showShare:sender;
- (IBAction)showOption:sender;
- (IBAction)showMlnet:sender;

@end

extern Nagui *nagui;
