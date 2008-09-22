//
//  NgGroup.h
//  Nagui
//
//  Created by Appledelhi on 08. 09. 16.
//  Copyright 2008 Appledelhi. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef enum {
  NgNone = 0,
  NgIncomingFiles,
  NgIncomingDirectories,
  NgOnlyDirectory,
  NgAllFiles,
  NgSmartAllFiles
} NgGroupType;

@interface NgGroup : NSObject {
  NgGroupType type;
  NSImage *icon;
  NSString *name;
  NSMutableArray *folders;
  NSMutableArray *files;
}

@property NgGroupType type;
@property(assign) NSImage *icon;
@property(assign) NSString *name;
@property(assign) NSMutableArray *folders;
@property(assign) NSMutableArray *files;

- initName:(NSString *)name type:(NgGroupType)type;
- (NSString *)path;
- (BOOL)reload;
// - (void)reloadDir:(NSString *)dir;
- (int)addGroup:(NSString *)name type:(NgGroupType)type;
- (BOOL)removeFolder;
- (NSMutableArray *)allFiles;
- (BOOL)isSubgroupOf:(NgGroup *)group;

@end
