//
//  NgFileGroup.m
//  Nagui
//
//  Created by Appledelhi on 08. 09. 13.
//  Copyright 2008 Appledelhi. All rights reserved.
//

#import "NgFileGroup.h"
#import "NgSharedFolder.h"
#import "Util.h"
#import "Nagui.h"
#include <sys/xattr.h>
#include "NSStringExt.h"
#include "NgFile.h"
#import "NgShareManager.h"
#import "NSObjectControllerExt.h"

@implementation NgFileGroup

@synthesize path;
@synthesize type;

- initPath:(NSString *)p type:(NgGroupType)t
{
  path = p;
  type = t;
//  name = [[NSFileManager defaultManager] displayNameAtPath:path];
//  [self setIcon];
  return self;
}

- (BOOL)isEqual:other
{
  if ([other respondsToSelector:@selector(path)]) {
    return [path isEqualToString:[other path]];
  }
  return NO;
}

- (NSURL *)url
{
  return [[NSURL alloc] initWithScheme:@"file" host:@"localhost" path:path];
}

//- (NSAttributedString *)attributedName
//{
//  NSImage *icon;
//  if (type == NgIncomingFiles) {
//    icon = nagui.downloadImage;
//  } else if (type == NgIncomingDirectories) {
//    icon = nagui.incomingDirImage;
//  } else {
//    icon = [[NSWorkspace sharedWorkspace] iconForFile:path];
//    [icon setSize:NSMakeSize(16, 16)];
//  }
//  NSFileManager *fileMan = [NSFileManager defaultManager];
//  return attributedStringFrom(icon, @" ", [fileMan displayNameAtPath:path], nil);
//}

- (NSString *)name
{
  if (!name) {
    name = [[NSFileManager defaultManager] displayNameAtPath:path];
  }
  return name;
}

- (void)setName:newName
{
  NSFileManager *fileMan = [NSFileManager defaultManager];
  NSString *displayName = [fileMan displayNameAtPath:path];
  if (![newName isEqualToString:displayName]) {
    NSString *newPath = [[path stringByDeletingLastPathComponent] stringByAppendingPathComponent:newName];
    NSError *error = nil;
    [fileMan moveItemAtPath:path toPath:newPath error:&error];
    if (error) {
      [nagui alert:[NSString stringWithFormat:@"Can't rename '%@' to '%@'", displayName, newName]
       informative:@"(Same name exists?)"];
    } else {
      [self willChangeValueForKey:@"url"];
      path = newPath;
      [self didChangeValueForKey:@"url"];
      name = [[NSFileManager defaultManager] displayNameAtPath:path];
    }
  }
}

- (NSImage *)icon
{
  if (!icon) {
    [self setIcon];
  }
  return icon;
}

- (void)setIcon
{
  if (type == NgIncomingFiles) {
    icon = nagui.downloadImage;
  } else if (type == NgIncomingDirectories) {
    icon = nagui.incomingDirImage;
  } else {
    icon = [[NSWorkspace sharedWorkspace] iconForFile:path];
    [icon setSize:NSMakeSize(16, 16)];
  }
}

- (void)createFolder
{
  NSFileManager *fileMan = [NSFileManager defaultManager];
  NSString *newPath = path;
  int i = 2;
  while (![fileMan createDirectoryAtPath:newPath attributes:nil]) {
    newPath = [path stringByAppendingFormat:@" %d", i++];
  }
  path = newPath;
  name = [[NSFileManager defaultManager] displayNameAtPath:path];
  [self setIcon];
}

- (BOOL)selected
{
  return [[nagui.shareManager.shareController selectedObject] isEqual:self];
}

- (void)reload
{
  if ([self selected] || !contents) {
    NSFileManager *fileMan = [NSFileManager defaultManager];
    NSArray *newContents = [fileMan directoryContentsAtPath:path];
    if (![contents isEqualToArray:newContents]) {
      // NSLog(@"%@ loaded", path);
      contents = newContents;
      NSMutableArray *newFolders = [NSMutableArray arrayWithCapacity:[contents count]];
      NSMutableArray *newFiles = [NSMutableArray arrayWithCapacity:[contents count]];
      NSWorkspace *workspace = [NSWorkspace sharedWorkspace];
      for (NSString *f in contents) {
        BOOL isDir = NO;
        NSString *newPath = [path stringByAppendingPathComponent:f];
        if ([newPath isInvisible]) {
          continue;
        }
        if ([fileMan fileExistsAtPath:newPath isDirectory:&isDir]) {
          if (isDir && ![workspace isFilePackageAtPath:newPath]) {
            [newFolders addObject:[[NgFileGroup alloc] initPath:newPath type:NgAllFiles]];
          } else {
            [newFiles addObject:[[NgFile alloc] initPath:newPath]];
          }
        }
      }
      if (![folders isEqualToArray:newFolders]) {
        self.folders = newFolders;
      }
      if (![files isEqualToArray:newFiles]) {
        self.files = newFiles;
      }
    } else {
      // NSLog(@"%@ not loaded", path);
    }
  }
}

- (NSArray *)folders
{
  if (!folders) {
    [self reload];
  }
  return folders;
}

- (NSArray *)files
{
  if (!files) {
    [self reload];
  }
  return files;
}

- (int)addGroup:(NSString *)folderName type:(NgGroupType)t
{
  NSString *newPath = [path stringByAppendingPathComponent:folderName];
  NgFileGroup *newFolder = [[NgFileGroup alloc] initPath:newPath type:NgAllFiles];
  [newFolder createFolder];
  [self willChangeValueForKey:@"folders"];
  [folders addObject:newFolder];
  [folders sortUsingSelector:@selector(compare:)];
  [self didChangeValueForKey:@"folders"];
  return [folders indexOfObject:newFolder];
}

- (BOOL)removeFolder
{
  NSFileManager *fileMan = [NSFileManager defaultManager];
  NSError *error = nil;
  if ([files count] > 0 || [folders count] > 0) {
    [nagui alert:@"Folder is not empty" informative:@"(empty folder first)"];
    return NO;
  } else {
    [fileMan removeItemAtPath:path error:&error];
    if (error) {
      [nagui alert:[error localizedDescription] informative:@""];
      return NO;
    }
  }
  return YES;
}

@end
