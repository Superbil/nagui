//
//  NgFile.m
//  Nagui
//
//  Created by Appledelhi on 08. 09. 08.
//  Copyright 2008 Appledelhi. All rights reserved.
//

#import "NgFile.h"
#include <sys/xattr.h>
#import "Nagui.h"
#import "NSStringExt.h"

@implementation NgFile

@synthesize path;

- initPath:(NSString *)p
{
  path = p;
  return self;
}

- (BOOL)isEqual:other
{
  if ([other isKindOfClass:[NgFile class]]) {
    NgFile *file = other;
    return [path isEqualToString:[file path]];
  }
  return NO;
}

- (NSURL *)url
{
  return [[NSURL alloc] initWithScheme:@"file" host:@"localhost" path:path];
}

- (NSString *)name
{
  if (!name) {
    name = [[NSFileManager defaultManager] displayNameAtPath:path];
  }
  return name;
}

- (void)setName:(NSString *)n
{
  NSString *newPath = [[path stringByDeletingLastPathComponent] stringByAppendingPathComponent:n];
  NSError *error = nil;
  NSFileManager *fileMan = [NSFileManager defaultManager];
  [fileMan moveItemAtPath:path toPath:newPath error:&error];
  if (error) {
    [nagui alert:@"Can't rename" informative:@"(same name exist?)"];
  } else {
    name = n;
    path = newPath;
  }
}

- (NSImage *)icon
{
  if (!icon) {
    icon = [[NSWorkspace sharedWorkspace] iconForFile:path];
  }
  return icon;
}

- (NSNumber *)size
{
  if (!size) {
    NSDictionary *attrs = [[NSFileManager defaultManager] fileAttributesAtPath:path traverseLink:YES];
    size = [attrs objectForKey:NSFileSize];
  }
  return size;
}

- (NSNumber *)rating
{
  if (!rating) {
    uint8_t r = 0;
    getxattr([path fileSystemRepresentation], "rating", &r, 1, 0, 0);
    rating = [NSNumber numberWithInt:r];
  }
  return rating;
}

- (void)setRating:(NSNumber *)newRating
{
  uint8_t r = [newRating intValue];
  setxattr([path fileSystemRepresentation], "rating", &r, 1, 0, 0);
  rating = newRating;
}

- (NSString *)tags
{
  if (!tags) {
    int len;
    const char *pathStr = [path fileSystemRepresentation];
    if (getxattr(pathStr, "tagsLen", &len, 4, 0, 0) == 4) {
      NSMutableData *data = [NSMutableData dataWithLength:len];
      if (getxattr(pathStr, "tags", [data mutableBytes], len, 0, 0) == len) {
        tags = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
      } else {
        tags = @"";
      }
    } else {
      tags = @"";
    }
  }
  return tags;
}

- (void)setTags:(NSString *)str
{
  const char *pathStr = [path fileSystemRepresentation];
  tags = str;
  if ([str length] > 0) {
    const char *bytes = [tags UTF8String];
    int len = strlen(bytes);
    setxattr(pathStr, "tagsLen", &len, 4, 0, 0);
    setxattr(pathStr, "tags", bytes, strlen(bytes), 0, 0);
  } else {
    removexattr(pathStr, "tagsLen", 0);
    removexattr(pathStr, "tags", 0);
  }
}

- (BOOL)match:(NSString *)str
{
  if ([name contains:str] || [tags contains:str]) {
    return YES;
  }
  return NO;
}

@end
