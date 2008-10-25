//
//  NgShareManager.m
//  Nagui
//
//  Created by Appledelhi on 08. 09. 13.
//  Copyright 2008 Appledelhi. All rights reserved.
//

#import "NgShareManager.h"
#import "NgSharedFolder.h"
#import "NgFileGroup.h"
#import "Util.h"
#import "Nagui.h"
#import "NgProtocolHandler.h"
#import "NSArrayExt.h"
#import "NgMovingTask.h"
#import "NgTaskManager.h"
#import "NgSmartGroup.h"
#import "NSStringExt.h"
#import "NgFile.h"
#import "NSObjectControllerExt.h"
#import "NSMutableArrayExt.h"

@implementation NgShareManager

@synthesize shareController;
@synthesize root;
@synthesize loading;

- (void)awakeFromNib
{
  root = [[NgGroup alloc] initName:@"" type:NgNone];
  [shareController bind:@"contentArray" toObject:root withKeyPath:@"folders" options:nil];

  [filesTable setTarget:self];
  [filesTable setDoubleAction:@selector(openFile:)];
  [filesTable registerForDraggedTypes:[NSArray arrayWithObject:NSFilenamesPboardType]];
  [sharesOutline registerForDraggedTypes:[NSArray arrayWithObject:NSFilenamesPboardType]];

  NSSortDescriptor *sd1 = [[NSSortDescriptor alloc] initWithKey:@"type" ascending:YES];
  NSSortDescriptor *sd2 = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES selector:@selector(caseInsensitiveCompare:)];
  [shareController setSortDescriptors:[NSArray arrayWithObjects:sd1, sd2, nil]];
}

- (void)unsharePath:(NSString *)path
{
  [nagui.protocolHandler sendCommand:[NSString stringWithFormat:@"unshare \"%@\"", path]];
}

- (void)unshare:sender
{
  NgGroup *group = [shareController selectedObject];
  if (group) {
    NSString *path = [group origPath];
    if (path) {
      [self unsharePath:path];
      [nagui.protocolHandler sendCommand:@"shares"];
    }
  }
}

- (void)reloadSmartGroups
{
  for (NgGroup *g in [root folders]) {
    if ([g type] == NgSmartAllFiles) {
      [g reload];
    }
  }
}

- (void)event:(FSEventStreamEventFlags)event path:(NSString *)path
{
  int last = [path length] - 1;
  if ([path characterAtIndex:last] == '/') {
    path = [path substringToIndex:last];
  }
  // NSLog(@"event %x in %@", event, path);
  if ([NgFileGroup reload:path]) {
    // NSLog(@"reloaded %@", path);
    [self reloadSmartGroups];
  }
}

static void feCallback(ConstFSEventStreamRef streamRef, void *info, size_t numEvents, void *eventPaths,
                       const FSEventStreamEventFlags eventFlags[], const FSEventStreamEventId eventIds[])
{
  char **paths = eventPaths;
  for (int i = 0; i < numEvents; i++) {
    [nagui.shareManager event:eventFlags[i] path:[NSString stringWithUTF8String:paths[i]]];
  }
}

- (void)monitor
{
  if (!stream) {
    NSArray *pathsToWatch = [[root folders] arrayByPerform:@selector(path)];
    stream = FSEventStreamCreate(NULL, feCallback, NULL, (CFArrayRef)pathsToWatch, kFSEventStreamEventIdSinceNow, 2.0,
                                 kFSEventStreamCreateFlagNone);
    FSEventStreamScheduleWithRunLoop(stream, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
    FSEventStreamStart(stream);
  }
}

- (void)parseSharedFolders:(NSString *)msg
{
  NSArray *lines = [msg componentsSeparatedByString:@"Shared directories:\n"];
  if ([lines count] == 2) {
    lines = [[lines objectAtIndex:1] componentsSeparatedByString:@"\n"];

    NSMutableArray *array = [NSMutableArray arrayWithCapacity:[lines count]];
    shareType = [NSMutableDictionary dictionaryWithCapacity:[lines count]];
    
    for (NSString *line in lines) {
      NSString *trimmed = [line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
      NSArray *words = [trimmed componentsSeparatedByString:@" "];
      if ([words count] >= 3) {
        NSArray *middle = [words subarrayWithRange:NSMakeRange(1, [words count] - 2)]; 
        NSString *path = [middle componentsJoinedByString:@" "];
        NSString *strategy = [words lastObject];
        int type = 0;
        if ([strategy isEqualToString:@"all_files"]) {
          type = NgAllFiles;
        } else if ([strategy isEqualToString:@"only_directory"]) {
          type = NgOnlyDirectory;
        } else if ([strategy isEqualToString:@"incoming_files"]) {
          type = NgIncomingFiles;
        } else if ([strategy isEqualToString:@"incoming_directories"]) {
          type = NgIncomingDirectories;
        }
        if (type) {
          [shareType setObject:[NSNumber numberWithInt:type] forKey:path];
          
          NgFileGroup *g = [NgFileGroup groupWithPath:path type:type]; 
          BOOL sub = NO;

          for (int i = 0; i < [array count];) {
            NSString *aPath = [[array objectAtIndex:i] path];
            if ([path hasPrefix:aPath]) {
              sub = YES;
            }
            if ([aPath hasPrefix:path]) {
              [array removeObjectAtIndex:i];
            } else {
              i++;
            }
          }
          if (!sub) {
            [array addObject:g];
          }
        }
      }
    }
    [array addObject:[[NgSmartGroup alloc] initName:@"All Files" type:NgSmartAllFiles]];

    [root willChangeValueForKey:@"folders"];
    [[root folders] addAndRemove:array];
    [root didChangeValueForKey:@"folders"];
    
    [self monitor];
  }
}

- (IBAction)openFile:sender
{
  NgFile *file = [sharedFileController selectedObject];
  if (file) {
    [[NSWorkspace sharedWorkspace] openFile:[file path]];
  }
}

- (BOOL)tableView:(NSTableView *)view writeRowsWithIndexes:(NSIndexSet *)rows toPasteboard:(NSPasteboard*)pboard
{
  NSArray *array = [[sharedFileController arrangedObjects] objectsAtIndexes:rows];
  NSMutableArray *fileNames = [NSMutableArray arrayWithCapacity:[array count]];
  for (NgFileGroup *g in array) {
    [fileNames addObject:[g path]];
  }
  [pboard declareTypes:[NSArray arrayWithObject:NSFilenamesPboardType] owner:nil];
  [pboard setPropertyList:fileNames forType:NSFilenamesPboardType];
  return YES;
}

- (NSDragOperation)tableView:(NSTableView*)view validateDrop:(id <NSDraggingInfo>)info proposedRow:(int)row
       proposedDropOperation:(NSTableViewDropOperation)op
{
  return NSDragOperationNone;
}

- (BOOL)tableView:(NSTableView *)view acceptDrop:(id <NSDraggingInfo>)info
              row:(int)row dropOperation:(NSTableViewDropOperation)operation
{
//  NSPasteboard* pboard = [info draggingPasteboard];
//  NSArray *array = [pboard propertyListForType:NSFilenamesPboardType];

//  NSLog(@"drop %@", array);
  return YES;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView writeItems:(NSArray *)items toPasteboard:(NSPasteboard *)pboard
{
  NSMutableArray *fileNames = [NSMutableArray arrayWithCapacity:[items count]];
  for (id i in items) {
    [fileNames addObject:[[i representedObject] path]];
  }
  [pboard declareTypes:[NSArray arrayWithObject:NSFilenamesPboardType] owner:nil];
  [pboard setPropertyList:fileNames forType:NSFilenamesPboardType];
  return YES;
}

- (NSDragOperation)outlineView:(NSOutlineView *)view validateDrop:(id <NSDraggingInfo>)info
                  proposedItem:(id)item proposedChildIndex:(NSInteger)childIndex
{
  if (childIndex >= 0) {
    return NSDragOperationNone;
//    NSArray *children = [item childNodes];
//    if ([children count] > childIndex) {
//      [view setDropItem:[children objectAtIndex:childIndex] dropChildIndex:-1];
//    }
  }
  return NSDragOperationEvery;
}

- (BOOL)outlineView:(NSOutlineView *)view acceptDrop:(id <NSDraggingInfo>)info item:(id)item
         childIndex:(NSInteger)childIndex
{
  NSPasteboard* pboard = [info draggingPasteboard];
  NSArray *array = [pboard propertyListForType:NSFilenamesPboardType];
  for (NSString *sourcePath in array) {
    NSString *destDir = [[item representedObject] path];
    [nagui.taskManager addTask:[[NgMovingTask alloc] initSource:sourcePath dest:destDir]];
//    NSLog(@"move %@ to %@ error %@", sourcePath, destPath, error);
  }
  return YES;
}

- (void)outlineViewSelectionDidChange:(NSNotification *)notification
{
  if (edit) {
    int row = [sharesOutline selectedRow];
    [sharesOutline editColumn:0 row:row withEvent:nil select:YES];
    edit = NO;
  }
  // [[shareController selectedObject] reload];
}

- (void)outlineView:(NSOutlineView *)view willDisplayCell:(NSCell *)cell forTableColumn:(NSTableColumn *)column item:(id)item
{
  [cell setImage:[[item representedObject] icon]];
}

- (void)controlTextDidEndEditing:(NSNotification *)notification
{
  if ([notification object] == sharesOutline) {
    NSArray *array = [shareController selectedNodes];
    NSTreeNode *selected = [array objectAtIndex:0];
    NSTreeNode *parent = [selected parentNode];
    NSArray *sorts = [NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES
                                                                           selector:@selector(caseInsensitiveCompare:)]];
    [parent sortWithSortDescriptors:sorts recursively:NO];
    [shareController setSelectionIndexPath:[selected indexPath]];
  }
}

- (IBAction)addFolder:sender
{
  NgGroup *group = [shareController selectedObject];
  if (group) {
    int index = [group addGroup:@"untitled folder" type:NgAllFiles];
    NSIndexPath *indexPath = [shareController selectionIndexPath];
    edit = YES;
    [shareController setSelectionIndexPath:[indexPath indexPathByAddingIndex:index]];
  } else {
    if (!choosePanel) {
      choosePanel = [NSOpenPanel openPanel];
      [choosePanel setCanChooseFiles:NO];
      [choosePanel setCanChooseDirectories:YES];
      [choosePanel setAllowsMultipleSelection:NO];
      [choosePanel setCanCreateDirectories:YES];
      [choosePanel setMessage:@"Choose folder to share."];
      [choosePanel setPrompt:@"Share"];
    }
    [choosePanel beginSheetForDirectory:nil file:nil modalForWindow:[nagui window] modalDelegate:self
                       didEndSelector:@selector(openPanelDidEnd:returnCode:contextInfo:) contextInfo:nil];
  }
}

- (void)sharePath:(NSString *)path strategy:(NSString *)strategy
{
  [nagui.protocolHandler sendCommand:[NSString stringWithFormat:@"share 0 \"%@\" %@", path, strategy]];
}

- (void)openPanelDidEnd:(NSOpenPanel *)panel returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
  if (returnCode == NSOKButton) {
    NSArray *array = [panel filenames];
    for (NSString *path in array) {
      [self sharePath:path strategy:@"all_files"];
    }
    [nagui.protocolHandler sendCommand:@"shares"];
  }
}

- (IBAction)removeFolder:sender
{
  NgGroup *group = [shareController selectedObject];
  if (group) {
    if ([group removeFolder]) {
      [shareController remove:self];
    }
  }
}

- (IBAction)moveToTrash:sender
{
  NgGroup *group = [shareController selectedObject];
  if (group) {
    NSArray *array = [sharedFileController selectedObjects];
    if ([array count] > 0) {
      NSArray *files = [array arrayByPerform:@selector(path)];
      for (NSString *path in files) {
        NSString *dir = [path stringByDeletingLastPathComponent];
        NSArray *fileArray = [NSArray arrayWithObject:[path lastPathComponent]];
        int tag = 0;
        [[NSWorkspace sharedWorkspace] performFileOperation:NSWorkspaceRecycleOperation
                                                     source:dir destination:@"" files:fileArray tag:&tag];
        if (tag < 0) {
          if ([nagui askDelete:[fileArray objectAtIndex:0]]) {
            [[NSWorkspace sharedWorkspace] performFileOperation:NSWorkspaceDestroyOperation
                                                         source:dir destination:@"" files:fileArray tag:&tag];
            if (tag < 0) {
              [nagui alert:[NSString stringWithFormat:@"Can't delete:'%@'", [fileArray objectAtIndex:0]]
               informative:@""];
            }
          }
        }
      }
    }
  }
}

- (BOOL)pastePossible
{
  NSPasteboard *pb = [NSPasteboard generalPasteboard];
  NSArray *pasteTypes = [NSArray arrayWithObject:NSStringPboardType];
  NSString *bestType = [pb availableTypeFromArray:pasteTypes];
  NgFile *file = [sharedFileController selectedObject];
  return bestType && file;
}

- (BOOL)copyPossible
{
  NSResponder *firstResponder = [[nagui window] firstResponder];
  id obj = nil;
  if (firstResponder == sharesOutline) {
    obj = [shareController selectedObject];
  } else if (firstResponder == filesTable) {
    obj = [sharedFileController selectedObject];
  }
  return obj != nil;
}

- (BOOL)validateUserInterfaceItem:item
{
  SEL action = [item action];
  if (action == @selector(copy:)) {
    return [self copyPossible];
  } else if ([item action] == @selector(paste:)) {
    return [self pastePossible];
  }
//  int tag = [item tag];
//  if (tag == 1 && ![sharedFileController selectedObject]) {
//    return NO;
//  }
  return YES;
}

- (IBAction)copy:sender
{
  NSResponder *firstResponder = [[nagui window] firstResponder];
  id obj = nil;
  if (firstResponder == sharesOutline) {
    obj = [shareController selectedObject];
  } else if (firstResponder == filesTable) {
    obj = [sharedFileController selectedObject];
  }
  if (obj) {
    NSString *name = [obj name];
    NSPasteboard *pb = [NSPasteboard generalPasteboard];
    NSArray *types = [NSArray arrayWithObject:NSStringPboardType];
    [pb declareTypes:types owner:self];
    [pb setString:[name stringByDeletingPathExtension] forType:NSStringPboardType];
  }
}

- (IBAction)paste:sender
{
  NSPasteboard *pb = [NSPasteboard generalPasteboard];
  NSArray *pasteTypes = [NSArray arrayWithObject:NSStringPboardType];
  NSString *bestType = [pb availableTypeFromArray:pasteTypes];
  if (bestType) {
    NSString *pasteName = [pb stringForType:bestType];
    NgFile *file = [sharedFileController selectedObject];
    if (file) {
      NSString *name = [file name];
      NSString *ext = [name pathExtension];
      [file setName:[pasteName stringByAppendingPathExtension:ext]];
    }
  }
}

- (NSArray *)uniqueFolders
{
  NSArray *groups = [root folders];
  NSMutableArray *uniqueFolders = [NSMutableArray arrayWithCapacity:[groups count]];
  for (NgGroup *group in groups) {
    if ([group path]) {
      [uniqueFolders addObject:[group path]];
//      BOOL sub = NO;
//      for (NgGroup *g in groups) {
//        if ([group isSubgroupOf:g]) {
//          sub = YES;
//        }
//      }
//      if (!sub) {
//        [uniqueFolders addObject:[group path]];
//      }
    }
  }
  // NSLog(@"%@", uniqueFolders);
  return uniqueFolders;
}

- (void)setAs:(NSString *)type
{
  NgGroup *group = [shareController selectedObject];
  if (group) {
    NSString *path = [group path];
    if (path) {
      [self unsharePath:path];
      [self sharePath:path strategy:type];
      for (NgGroup *g in [root folders]) {
        if ([g type] == NgIncomingFiles && [type isEqualToString:@"incoming_files"]) {
          [self unsharePath:[g path]];
          [self sharePath:[g path] strategy:@"all_files"];
        } else if ([g type] == NgIncomingDirectories && [type isEqualToString:@"incoming_directories"]) {
          [self unsharePath:[g path]];
          [self sharePath:[g path] strategy:@"all_files"];
        }
      }
      [nagui.protocolHandler sendCommand:@"shares"];
    }
  }
}

- (IBAction)setAsIncomingFiles:sender
{
  [self setAs:@"incoming_files"];
}

- (IBAction)setAsIncomingDirectories:sender
{
  [self setAs:@"incoming_directories"];
}

- (int)shareType:(NSString *)path
{
  NSNumber *num = [shareType objectForKey:path];
  if (num) {
    return [num intValue];
  }
  return NgNone;
}

- (void)adjustSync:sender
{
  NgFile *file = [sharedFileController selectedObject];
  NSString *path = [file path];
  if ([[path pathExtension] isEqualToString:@"smi"]) {
    [[NSApplication sharedApplication] beginSheet:timeShiftPanel modalForWindow:[nagui window]
                                    modalDelegate:self
                                   didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:)
                                      contextInfo:nil];
  }
}

- (void)sheetDidEnd:(NSWindow *)sheet returnCode:(int)code contextInfo:(void *)context
{
  if (code != 1) {
    return;
  }
  NgFile *file = [sharedFileController selectedObject];
  NSString *path = [file path];
  NSError *err = nil;
  NSString *content = [NSString stringWithContentsOfFile:path encoding:NSISOLatin1StringEncoding error:&err];
  if (err) {
    [nagui alert:[err localizedDescription] informative:@"can't read file"];
    return;
  }
  NSArray *lines = [content componentsSeparatedByString:@"\n"];
  NSMutableArray *output = [NSMutableArray arrayWithCapacity:[lines count]];
  int t = [shiftAmount floatValue] * 1000;
  for (NSString *line in lines) {
    [output addObject:[line shiftTime:t]];
  }
  content = [output componentsJoinedByString:@"\n"];
  [content writeToFile:path atomically:YES encoding:NSISOLatin1StringEncoding error:&err];
  if (err) {
    [nagui alert:[err localizedDescription] informative:@"can't write file"];
  }
}

- (IBAction)closePanel:sender
{
  [[NSApplication sharedApplication] endSheet:timeShiftPanel returnCode:[sender tag]];
  [timeShiftPanel orderOut:sender];
}

@end
