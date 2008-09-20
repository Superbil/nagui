//
//  NgGroup.m
//  Nagui
//
//  Created by Appledelhi on 08. 09. 16.
//  Copyright 2008 Appledelhi. All rights reserved.
//

#import "NgGroup.h"
#import "NgSmartGroup.h"
#import "NgFileGroup.h"
#import "Nagui.h"
#import "NgShareManager.h"
#import "NSMutableArrayExt.h"

@implementation NgGroup

@synthesize type;
@synthesize icon;
@synthesize name;
@synthesize files;
@synthesize folders;

- initName:(NSString *)n type:(NgGroupType)t
{
  name = n;
  type = t;
//  folders = [NSMutableArray arrayWithCapacity:5];
  return self;
}

- copyWithZone:(NSZone *)zone
{
  NgGroup *copy = NSCopyObject(self, 0, zone);
  return copy;
}

- (BOOL)isEqual:other
{
  if ([other respondsToSelector:@selector(name)]) {
    return [name isEqualToString:[other name]];
  }
  return NO;
}

- (NSComparisonResult)compare:other
{
  if ([other respondsToSelector:@selector(name)]) {
    return [name caseInsensitiveCompare:[other name]];
  }
  return NSOrderedSame;
}

//- (NSMutableArray *)folders
//{
//  if (!folders) {
//    folders = [NSMutableArray arrayWithCapacity:5];
//  }
//  return folders;
//}
//
//- (void)setFolders:(NSMutableArray *)f
//{
//  folders = f;
//}

//- (unsigned)countOfFolders
//{
//  return [folders count];
//}
//
//- objectInFoldersAtIndex:(unsigned)index
//{
//  return [folders objectAtIndex:index];
//}
//
//- (void)insertObject:folder inFoldersAtIndex:(unsigned)index
//{
//  [folders insertObject:folder atIndex:index];
//}
//
//- (void)removeObjectFromFoldersAtIndex:(unsigned)index
//{
//  [folders removeObjectAtIndex:index];
//}

- (NSString *)path
{
  return nil;
}

- (NSString *)url
{
  return @"";
}

- (int)addGroup:(NSString *)str type:(NgGroupType)t
{
  if (!folders) {
    folders = [NSMutableArray arrayWithCapacity:5];
  }
  NgGroup *group;
  if (t == NgSmartAllFiles) {
    group = [[NgSmartGroup alloc] initName:str type:t];
  } else {
    group = [[NgFileGroup alloc] initPath:str type:t];
  }
  int index = [folders indexOfObject:group];
  if (index == NSNotFound) {
    [self willChangeValueForKey:@"folders"];
    [folders addObject:group];
    [folders sortUsingSelector:@selector(compare:)];
    [self didChangeValueForKey:@"folders"];
    return [folders indexOfObject:group];
  }
  return index;
}

- (void)reloadDir:(NSString *)dir
{
  NSString *p = [self path];
  if (!p || [p isEqualToString:dir]) {
    [self reload];
  }
  if (!p || [p length] < [dir length]) {
    for (NgGroup *g in folders) {
      [g reloadDir:dir];
    }
  }
}

- (void)reload
{
}

- (BOOL)removeFolder
{
  return YES;
}

- (NSMutableArray *)allFiles
{
  NSMutableArray *array = [NSMutableArray arrayWithCapacity:10];
  [array addObjectsFromArrayUnique:[self files]];
  for (NgGroup *g in [self folders]) {
    if ([g type] != NgSmartAllFiles) {
      [array addObjectsFromArrayUnique:[g allFiles]];
    }
  }
  return array;
}

@end
