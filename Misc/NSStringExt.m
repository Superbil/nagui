//
//  NSStringExt.m
//  Nagui
//
//  Created by Appledelhi on 08. 09. 15.
//  Copyright 2008 Appledelhi. All rights reserved.
//

#import "NSStringExt.h"


@implementation NSString(Nagui)

- (NSString *)beforeLastPathComponent
{
  NSArray *array = [self pathComponents];
  if ([array count] > 1) {
    return [array objectAtIndex:[array count] - 2];
  }
  if ([array count] > 0) {
    return [array objectAtIndex:0];
  }
  return @"";
}

- (BOOL)isSameDir:(NSString *)dir
{
  return [[self stringByDeletingLastPathComponent] isEqualToString:dir];
}

- (BOOL)contains:(NSString *)str
{
  if (str) {
    NSRange r = [self rangeOfString:str];
    return r.location != NSNotFound;
  }
  return NO;
}

- (BOOL)containsCaseInsensitive:(NSString *)str
{
  if (str) {
    NSRange r = [self rangeOfString:str options:NSCaseInsensitiveSearch];
    return r.location != NSNotFound;
  }
  return NO;
}

- (BOOL)isInvisible
{
  BOOL isInvisible = NO;
  FSRef ref;
  if (CFURLGetFSRef((CFURLRef)[NSURL fileURLWithPath:self], &ref)) {
    CFTypeRef isInvisibleRef;
    if (LSCopyItemAttribute(&ref, kLSRolesAll, kLSItemIsInvisible, &isInvisibleRef) == noErr) {
      if (isInvisibleRef == kCFBooleanTrue) {
        isInvisible = YES;
      }
      CFRelease(isInvisibleRef);
    }
  }
  return isInvisible;
}

- (BOOL)isSameString:(NSString *)other
{
  const char *str = [self UTF8String];
  const char *otherStr = [other UTF8String];
  return strcmp(str, otherStr) == 0;
}

- (NSString *)mldonkeyFullPath
{
  if ([self characterAtIndex:0] != '/') {
    return [NSString stringWithFormat:@"%@/.mldonkey/%@", NSHomeDirectory(), self];
  }
  return self;
}

- (NSString *)separate:(NSString *)str prefix:(NSString *)prefix
{
  NSArray *array = [self componentsSeparatedByString:str];
  NSMutableArray *modified = [NSMutableArray arrayWithCapacity:[array count]];
  for (NSString *word in array) {
    [modified addObject:[NSString stringWithFormat:@"%@%@", prefix, word]];
  }
  return [modified componentsJoinedByString:str];
}

- (NSString *)shiftTime:(int)t
{
  NSRange r = [self rangeOfString:@"<sync start=" options:NSCaseInsensitiveSearch];
  if (r.location == NSNotFound) {
    return self;
  } else {
    int start = r.location + r.length;
    int i = start;
    for (; i < [self length]; i++) {
      unichar c = [self characterAtIndex:i];
      if (c < '0' || c > '9') {
        break;
      }
    }
    NSString *before = [self substringToIndex:start];
    NSString *number = [self substringWithRange:NSMakeRange(start, i - start)];
    NSString *after = [self substringFromIndex:i];
    number = [NSString stringWithFormat:@"%d", [number intValue] + t];
    return [NSString stringWithFormat:@"%@%@%@", before, number, after];
  }
}

@end
