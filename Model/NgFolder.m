//
//  NgFolder.m
//  Nagui
//
//  Created by Appledelhi on 08. 09. 06.
//  Copyright 2008 Appledelhi. All rights reserved.
//

#import "NgFolder.h"
#import "Nagui.h"
#import "NgFolderManager.h"
#import "NgFile.h"
#import "Util.h"

@implementation NgFolder

@synthesize path;
@synthesize name;
@synthesize shared;
@synthesize parent;
@synthesize files;

- initParent:(NgFolder *)pa path:(NSString *)p name:(NSString *)n shared:(int)s icon:(NSImage *)icon
{
  parent = pa;
  path = p;
  shared = s;

  [icon setSize:NSMakeSize(16, 16)];
  // NSMutableAttributedString *temp = [[NSMutableAttributedString alloc] init];
  // [temp appendAttributedString:attributedStringFromImage(icon)];
  // [temp appendAttributedString:[[NSAttributedString alloc] initWithString:@" "]];
  // [temp appendAttributedString:[[NSAttributedString alloc] initWithString:n]];
  // [temp setAttributes:[NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:3.0] forKey:NSBaselineOffsetAttributeName]
  //               range:NSMakeRange(1, [temp length] - 1)];
  name = attributedStringFrom(icon, @" ", n, nil);
  return self;
}

- copyWithZone:(NSZone *)zone
{
  return NSCopyObject(self, 0, zone);;
}

static NSArray *hidden;

// - (NSArray *)subfolders
// {
//   if (!hidden) {
//     hidden = [NSArray arrayWithObjects:@"/Desktop DB", @"/Desktop DF", @"/bin", @"/cores", @"/dev", @"/etc", @"/home",
//      @"/mach_kernel", @"/mach_kernel.ctfsys", @"/net", @"/opt", @"/private", @"/sbin", @"/tmp", @"/usr", @"/var", nil];
//   }
//   NSFileManager *fileMan = [NSFileManager defaultManager];
//   NSArray *files = [fileMan directoryContentsAtPath:path];
//   NSMutableArray *subfolders = [NSMutableArray arrayWithCapacity:[files count]];
// 
//   for (NSString *f in files) {
//     if ([f characterAtIndex:0] == '.') {
//       continue;
//     }
//     BOOL isDir = NO;
//     NSString *newPath = [NSString pathWithComponents:[NSArray arrayWithObjects:path, f, nil]];
//     if ([hidden containsObject:newPath]) {
//       continue;
//     }
//     if ([fileMan fileExistsAtPath:newPath isDirectory:&isDir] && isDir)  {
//       if (![[newPath pathExtension] isEqualToString:@"app"]) {
//         int s = [nagui.folderManager shareStateForPath:newPath];
//         NgFolder *folder = [[NgFolder alloc] initParent:self path:newPath name:f shared:s];
//         [subfolders addObject:folder];
//         [folder addObserver:folder forKeyPath:@"shared" options:NSKeyValueObservingOptionNew context:nil];
//       }
//     }
//   }
// 
//   return subfolders;
// }

- (NSArray *)folders
{
  if (!folders) {
    if (!hidden) {
      hidden = [NSArray arrayWithObjects:@"Desktop DB", @"Desktop DF", @"/bin", @"/cores", @"/dev", @"/etc", @"/home",
       @"/mach_kernel", @"/mach_kernel.ctfsys", @"/net", @"/opt", @"/private", @"/sbin", @"/tmp", @"/usr", @"/var",
       @"Thumbs.db", nil];
    }
    NSFileManager *fileMan = [NSFileManager defaultManager];
    NSWorkspace *workspace = [NSWorkspace sharedWorkspace];
    NSArray *contents = [fileMan directoryContentsAtPath:path];
    folders = [NSMutableArray arrayWithCapacity:[contents count]];
    NSMutableArray *fileArray = [NSMutableArray arrayWithCapacity:[contents count]];

    for (NSString *f in contents) {
      if ([f characterAtIndex:0] == '.') {
        continue;
      }
      BOOL isDir = NO;
      NSString *newPath = [NSString pathWithComponents:[NSArray arrayWithObjects:path, f, nil]];
      NSString *displayName = [fileMan displayNameAtPath:newPath];
      if ([hidden containsObject:newPath] || [hidden containsObject:displayName]) {
        continue;
      }
      if ([fileMan fileExistsAtPath:newPath isDirectory:&isDir]) {
        NSImage *newIcon = [workspace iconForFile:newPath];
        if (isDir && ![workspace isFilePackageAtPath:newPath]) {
          int s = [nagui.folderManager shareStateForPath:newPath];
          NgFolder *folder = [[NgFolder alloc] initParent:self path:newPath name:displayName shared:s icon:newIcon];
          [folders addObject:folder];
          [folder addObserver:folder forKeyPath:@"shared" options:NSKeyValueObservingOptionNew context:nil];
        } else {
          NgFile *file = [[NgFile alloc] initPath:newPath];
          [fileArray addObject:file];
        }
      }
    }
    self.files = fileArray;
  }
  return folders;
}

- (void)setFolders:(NSMutableArray *)f
{
  folders = f;
}

- (void)setSharedRecursive:(int)v
{
  shared = v;
  for (NgFolder *f in folders) {
    [f setSharedRecursive:v];
  }
}

- (void)rescan
{
  int onCount = 0;
  int offCount = 0;
  for (NgFolder *f in folders) {
    if (f.shared == NSOnState) {
      onCount++;
    } else if (f.shared == NSOffState) {
      offCount++;
    }
  }
  if (onCount == [folders count]) {
    self.shared = NSOnState;
  } else if (offCount == [folders count]) {
    self.shared = NSOffState;
  } else {
    self.shared = NSMixedState;
  }
//  [parent rescan];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:object change:(NSDictionary *)change
                       context:(void *)context
{
  NgFolder *folder = object;
  [folder.parent rescan];
}

- (void)shareRecursive:(int)state
{
  // causes parents to update
  self.shared = state;
  for (NgFolder *f in folders) {
    [f removeObserver:f forKeyPath:@"shared"];
    [f shareRecursive:state];
    [f addObserver:f forKeyPath:@"shared" options:NSKeyValueObservingOptionNew context:nil];
  }
}

@end
