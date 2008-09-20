//
//  NgFolderManager.h
//  Nagui
//
//  Created by Appledelhi on 08. 09. 06.
//  Copyright 2008 Appledelhi. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class NgFolder;

@interface NgFolderManager : NSObject {
  IBOutlet id folderController;
  IBOutlet id folderColumn;
  IBOutlet id folderTable;
  
  NgFolder *root;
  
  NSMutableArray *sharedFolders;
  NSString *incomingFiles;
  NSString *incomingDirectories;
  NgFolder *incomingFilesFolder;
  NgFolder *incomingDirectoriesFolder;
  
  NSImage *incomingFilesImage;
  NSImage *incomingDirectoriesImage;
}

@property(assign) NgFolder *root;

- (IBAction)expandFolder:sender;
- (IBAction)shareFiles:sender;
- (IBAction)shareFilesAndFolders:sender;
- (IBAction)shareAsIncomingFiles:sender;
- (IBAction)shareAsIncomingDirectories:sender;
- (IBAction)unshareFolder:sender;

- (void)parseSharedFolders:(NSString *)msg;
- (int)shareStateForPath:(NSString *)path;

@end
