//
//  NgSmartGroup.m
//  Nagui
//
//  Created by Appledelhi on 08. 09. 16.
//  Copyright 2008 Appledelhi. All rights reserved.
//

#import "NgSmartGroup.h"
#import "Nagui.h"
#import "Util.h"
#import "NgShareManager.h"
#import "NgFile.h"
#import "NSStringExt.h"

enum {
  NoScanning,
  Scanning
};

@implementation NgSmartGroup

@synthesize name;

- initName:(NSString *)n type:(NgGroupType)t
{
  self = [super initName:n type:t];
//  icon = nagui.smartFolderImage;
  lock = [[NSLock alloc] init];
  return self;
}

- (NSImage *)icon
{
  return nagui.smartFolderImage;
}

// - (void)queryFinished
// {
//   NSArray *results = [query results];
//   NSMutableArray *array = [NSMutableArray arrayWithCapacity:[results count]];
//   for (NSMetadataItem *item in results) {
//     NSString *storePath = [item valueForAttribute:(NSString *)kMDItemPath];
//     if (storePath && [storePath length] > 0) {
//       [array addObject:[[NgFile alloc] initPath:storePath]];
//     }
//   }
//   NSLog(@"conversion finished");
//   self.files = array;
// }
// 
// - (void)queryNotification:(NSNotification *)note
// {
//   if ([[note name] isEqualToString:NSMetadataQueryDidFinishGatheringNotification]) {
//     NSLog(@"query finished");
//     [self queryFinished];
//   }
// }

- (void)scan
{
  [lock lock];
  [nagui.shareManager.loading performSelectorOnMainThread:@selector(startAnimation:) withObject:self waitUntilDone:NO];
  NSMutableArray *newFiles = [NSMutableArray arrayWithCapacity:1000];
  NSArray *sharedFolders = [nagui.shareManager uniqueFolders];
  for (NSString *startPath in sharedFolders) {
    NSDirectoryEnumerator *e = [[NSFileManager defaultManager] enumeratorAtPath:startPath];
    NSString *p;
    while (p = [e nextObject]) {
      NSString *newPath = [startPath stringByAppendingPathComponent:p];
      if (![newPath isInvisible]) {
        [newFiles addObject:[[NgFile alloc] initPath:newPath]];
      }
    }
  }
  self.files = newFiles;
  scanning = NO;
  [nagui.shareManager.loading performSelectorOnMainThread:@selector(stopAnimation:) withObject:self waitUntilDone:NO];
  [lock unlock];
}

- (NSMutableArray *)files
{
  // if (!files) {
  //   files = [nagui.shareManager.root allFiles];
  // }
  // return files;
  // if (!query) {
  //   query = [[NSMetadataQuery alloc] init];
  //   NSNotificationCenter *nf = [NSNotificationCenter defaultCenter];
  //   [nf addObserver:self selector:@selector(queryNotification:) name:nil object:query];
  //   // [query setDelegate:self];
  //   [query setSearchScopes:[NSArray arrayWithObjects:@"/Volumes/capsule/Share", nil]];
  //   [query setPredicate:[NSPredicate predicateWithFormat:@"(kMDItemFSSize >= 0)"]];
  //   NSLog(@"start query");
  //   [query startQuery];
  //   return nil;
  // }
  if (!files) {
    if ([lock tryLock]) {
      if (!scanning) {
        scanning = YES;
        [NSThread detachNewThreadSelector:@selector(scan) toTarget:self withObject:nil];
      }
      [lock unlock];
    }
  }
  return files;
}

- (NSMutableArray *)allFiles
{
  // NSMetadataQuery *query = [[NSMetadataQuery alloc] init];
  // [query setSearchScopes:[NSArray arrayWithObjects:@"/Volumes/capsule/Share", nil]];
  // [query startQuery];
  // NSArray *results = [query results];
  // NSLog(@"%@", results);
  // return results;
  return nil;
}

- (BOOL)reload
{
  NSLog(@"reloading smart group");
  self.files = nil;
  return YES;
  // if ([nagui showingShare]) {
  //   NSLog(@"reloading all files");
  //   self.files = [nagui.shareManager.root allFiles];
  //   // NSLog(@"%d", [files count]);
  // }
}

@end
