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
  
  NgGroup *root;
  FSEventStreamRef stream;
  BOOL edit;
}

@property(readonly) NSTreeController *shareController;

- (IBAction)addFolder:sender;
- (IBAction)removeFolder:sender;
- (IBAction)moveToTrash:sender;
- (IBAction)unshare:sender;

- (void)reloadSourcePath:(NSString *)source destDir:(NSString *)dest;

@end
