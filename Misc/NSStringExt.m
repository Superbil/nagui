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

@end
