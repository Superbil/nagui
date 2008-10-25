//
//  NgShareManager.h
//  Nagui
//
//  Created by Appledelhi on 08. 09. 13.
//  Copyright 2008 Appledelhi. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class NgGroup;

@interface NgShareManager : NSObject {
  IBOutlet NSTreeController *shareController;
  IBOutlet NSArrayController *sharedFileController;
  IBOutlet id sharesOutline;
  IBOutlet id filesTable;
  IBOutlet NSProgressIndicator *loading;
  
  NgGroup *root;
  FSEventStreamRef stream;
  BOOL edit;
  NSOpenPanel *choosePanel;
  NSMutableDictionary *shareType;
}

@property(readonly) NSTreeController *shareController;
@property(readonly) NgGroup *root;
@property(readonly) NSProgressIndicator *loading;

- (IBAction)addFolder:sender;
- (IBAction)removeFolder:sender;
- (IBAction)moveToTrash:sender;
- (IBAction)unshare:sender;
- (IBAction)setAsIncomingFiles:sender;
- (IBAction)setAsIncomingDirectories:sender;

- (NSArray *)uniqueFolders;
- (int)shareType:(NSString *)path;

@end
