//
//  NgFolderManager.m
//  Nagui
//
//  Created by Appledelhi on 08. 09. 06.
//  Copyright 2008 Appledelhi. All rights reserved.
//

#import "NgFolderManager.h"
#import "NgFolder.h"
#import "NgSharedFolder.h"
#import "Nagui.h"
#import "NgProtocolHandler.h"
#import "NgFolderCell.h"
#import "Util.h"
#import "NSObjectControllerExt.h"

@implementation NgFolderManager

@synthesize root;

- (void)awakeFromNib
{
  sharedFolders = [NSMutableArray arrayWithCapacity:10];
  NSButtonCell *cell = [[NSButtonCell alloc] initTextCell:@""];
  [cell setButtonType:NSSwitchButton];
  [cell setAllowsMixedState:YES];
  [folderColumn setDataCell:cell];
  [folderTable setTarget:self];
  [folderTable setDoubleAction:@selector(expandFolder:)];
  
  incomingFilesImage = nagui.downArrowImage;
  incomingDirectoriesImage = [[NSImage alloc] initWithSize:NSMakeSize(24, 16)];
  [incomingDirectoriesImage lockFocus];
  NSImage *image = nagui.folderImage;
  [image drawAtPoint:NSMakePoint(0, 0) fromRect:NSMakeRect(0, 0, 16, 16) operation:NSCompositeSourceOver fraction:1.0];
  [incomingFilesImage drawAtPoint:NSMakePoint(8, 0) fromRect:NSMakeRect(0, 0, 16, 16) operation:NSCompositeSourceOver
                         fraction:1.0];
  [incomingDirectoriesImage unlockFocus];
}

// NSAttributedString *appendImage(NSAttributedString *str, NSImage *image)
// {
//   NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithAttributedString:str];
//   [attrStr appendAttributedString:[[NSAttributedString alloc] initWithString:@" "]];
//   [attrStr appendAttributedString:attributedStringFromImage(image)];
//   [attrStr setAttributes:[NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:3.0] forKey:NSBaselineOffsetAttributeName]
//     range:NSMakeRange(1, [attrStr length] - 2)];
//   return attrStr;
// }

// NSMutableAttributedString *stringWithImage(NSString *str, NSImage *image)
// {
//   NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:str];
//   appendImage(attrStr, image);
//   return attrStr;
// }

- (void)outlineView:(NSOutlineView *)view willDisplayCell:cell forTableColumn:(NSTableColumn *)column item:item
{
  if ([[column identifier] isEqualToString:@"sharedFolder"]) {
    NgFolder *folder = [item representedObject];
    NSAttributedString *title = folder.name;
    if ([folder.path isEqualToString:incomingFiles]) {
      title = attributedStringFrom(folder.name, @" ", incomingFilesImage, nil);
      incomingFilesFolder = folder;
    } else if ([folder.path isEqualToString:incomingDirectories]) {
      title = attributedStringFrom(folder.name, @" ", incomingDirectoriesImage, nil);
      incomingDirectoriesFolder = folder;
    }
    [cell setAttributedTitle:title];
  }
}

//- (BOOL)outlineView:(NSOutlineView *)outlineView shouldEditTableColumn:(NSTableColumn *)column item:(id)item
//{
//  return NO;
//}
//
//- (BOOL)tableView:(NSTableView *)view shouldEditTableColumn:(NSTableColumn *)column row:(NSInteger)row
//{
//  return NO;
//}
//
//- (BOOL)tableView:(NSTableView *)view shouldTrackCell:(NSCell *)cell
//   forTableColumn:(NSTableColumn *)column row:(NSInteger)row
//{
//  return NO;
//}

- (void)unshare:(NSString *)path
{
  NSString *command = [NSString stringWithFormat:@"unshare \"%@\"", path];
  [nagui.protocolHandler sendCommand:command];
}

- (void)share:(NSString *)path strategy:(NSString *)strategy
{
  NSString *command = [NSString stringWithFormat:@"share 0 \"%@\" %@", path, strategy];
  [nagui.protocolHandler sendCommand:command];

  // unshare old incoming_files
  int stra = 0;
  if ([strategy isEqualToString:@"incoming_files"]) {
    stra = NgIncomingFiles;
    if (incomingFilesFolder) {
      incomingFilesFolder.shared = incomingFilesFolder.shared;
    }
    incomingFiles = path;
    incomingFilesFolder = nil;
  } else if ([strategy isEqualToString:@"incoming_directories"]) {
    stra = NgIncomingDirectories;
    if (incomingDirectoriesFolder) {
      incomingDirectoriesFolder.shared = incomingDirectoriesFolder.shared;
    }
    incomingDirectories = path;
    incomingDirectoriesFolder = nil;
  }
  if (stra) {
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:[sharedFolders count]];
    for (NgSharedFolder *sf in sharedFolders) {
      if (sf.type == stra) {
        [self unshare:sf.path];
      } else {
        [array addObject:sf];
      }
    }
    [array addObject:[[NgSharedFolder alloc] initPath:path type:stra]];
    sharedFolders = array;
  }
}

- (IBAction)clicked:sender
{
  NSLog(@"clicked");
//  NSInteger row = [sender clickedRow];
//  id item = [sender itemAtRow:row];
//  NgFolder *folder = [item representedObject];
//  if (folder.shared == NSOffState) {
//    [folder shareRecursive:NSOffState];
//    [self unshare:folder.path];
//  } else {
//    if (folder.shared == NSMixedState) {
//      folder.shared = NSOnState;
//    }
//    [folder shareRecursive:NSOnState];
//    [self share:folder.path];
//  }
}

- (void)removeRedundancy
{
  NSMutableArray *newShared = [NSMutableArray arrayWithCapacity:[sharedFolders count]];
  for (NgSharedFolder *longF in sharedFolders) {
    BOOL found = NO;
    for (NgSharedFolder *shortF in sharedFolders) {
      if (longF != shortF) {
        NSRange r = [longF.path rangeOfString:shortF.path];
        if (r.location == 0 && shortF.type == NgAllFiles
            && longF.type != NgIncomingFiles && longF.type != NgIncomingDirectories) {
          found = YES;
          break;
        }
      }
    }
    if (found) {
      [self unshare:longF.path];
    } else {
      [newShared addObject:longF];
    }
  }
  sharedFolders = newShared;
}

- (void)resetFolders:(int)count
{
  sharedFolders = [NSMutableArray arrayWithCapacity:count];
  incomingFiles = nil;
  incomingFilesFolder = nil;
  incomingDirectories = nil;
  incomingDirectoriesFolder = nil;
}

- (void)parseSharedFolders:(NSString *)msg
{
  NSArray *lines = [msg componentsSeparatedByString:@"Shared directories:\n"];
  if ([lines count] == 2) {
    lines = [[lines objectAtIndex:1] componentsSeparatedByString:@"\n"];
    [self resetFolders:[lines count]];
    for (NSString *line in lines) {
      NSString *trimmed = [line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
      NSArray *words = [trimmed componentsSeparatedByString:@" "];
      if ([words count] == 3) {
        NSString *path = [words objectAtIndex:1];
        NSString *strategy = [words objectAtIndex:2];
        int stra = 0;
        if ([strategy isEqualToString:@"all_files"]) {
          stra = NgAllFiles;
        } else if ([strategy isEqualToString:@"only_directory"]) {
          stra = NgOnlyDirectory;
        } else if ([strategy isEqualToString:@"incoming_files"]) {
          incomingFiles = path;
          stra = NgIncomingFiles;
        } else if ([strategy isEqualToString:@"incoming_directories"]) {
          incomingDirectories = path;
          stra = NgIncomingDirectories;
        }
        if (stra) {
          [sharedFolders addObject:[[NgSharedFolder alloc] initPath:path type:stra]];
        }
      }
    }
    [self removeRedundancy];
  }
  if (!root) {
    NgFolder *folder = [[NgFolder alloc] initParent: nil path:@"/" name:@"" shared:NSOffState icon:nil];
    self.root = folder;
  }
}

NSInteger shortestFirst(id a, id b, void *context)
{
  int aLen = [[a path] length];
  int bLen = [[b path] length];
  if (aLen < bLen) {
    return NSOrderedAscending;
  } else if (aLen > bLen) {
    return NSOrderedDescending;
  } else {
    return NSOrderedSame;
  }
}

- (int)shareStateForPath:(NSString *)path
{
  NSArray *sorted = [sharedFolders sortedArrayUsingFunction:shortestFirst context:nil];
  for (NgSharedFolder *sf in sorted) {
    BOOL pathIsParent = [sf.path hasPrefix:path];
    BOOL pathIsSub = [path hasPrefix:sf.path];
    if (pathIsParent && pathIsSub) {
      // exact match
      return NSOnState;
    }
    if (pathIsSub && sf.type != NgOnlyDirectory) {
      return NSOnState;
    }
    if (pathIsParent) {
      return NSMixedState;
    }
  }
  return NSOffState;
}

- (IBAction)shareFiles:sender
{
  NgFolder *folder = [folderController selectedObject];
  if (folder) {
    [self share:folder.path strategy:@"only_directory"];
    folder.shared = NSOnState;
  }
}

- (IBAction)shareFilesAndFolders:sender
{
  NgFolder *folder = [folderController selectedObject];
  if (folder) {
    [self share:folder.path strategy:@"all_files"];
    [folder shareRecursive:NSOnState];
  }
}

- (IBAction)shareAsIncomingFiles:sender
{
  NgFolder *folder = [folderController selectedObject];
  if (folder) {
    [self share:folder.path strategy:@"incoming_files"];
    [folder shareRecursive:NSOnState];
  }
}

- (IBAction)shareAsIncomingDirectories:sender
{
  NgFolder *folder = [folderController selectedObject];
  if (folder) {
    [self share:folder.path strategy:@"incoming_directories"];
    [folder shareRecursive:NSOnState];
  }
}

- (IBAction)unshareFolder:sender
{
  NgFolder *folder = [folderController selectedObject];
  if (folder) {
    [self unshare:folder.path];
    [folder shareRecursive:NSOffState];
  }
}

- (IBAction)expandFolder:sender
{
  NSInteger row = [sender clickedRow];
  id item = [sender itemAtRow:row];
  if ([folderTable isItemExpanded:item]) {
    [folderTable collapseItem:item];
  } else {
    [folderTable expandItem:item];
  }
}

- (BOOL)validateUserInterfaceItem:item
{
  if (nagui.currentManager == self) {
    return YES;
  }
  return NO;
}

@end
