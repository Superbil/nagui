//
//  NGQuery.m
//  Nagui
//
//  Created by Appledelhi on 08. 08. 24.
//  Copyright 2008 Appledelhi. All rights reserved.
//

#import "NgQuery.h"
#import "NgWriteBuffer.h"

@implementation NgQuery

+ (NgQuery *)queryWithKeyword: (NSString *)keyword
{
  return [[NgQuery alloc] initType:NgKeyword arg1:@"keyword" arg2:keyword];
}

+ (NgQuery *)queryWithKeywords: (NSArray *)keywords
{
  if ([keywords count] < 2) {
    return [NgQuery queryWithKeyword:[keywords objectAtIndex:0]];
  }
  NgQuery *mother = [[NgQuery alloc] initType:NgAnd];
  for (NSString *keyword in keywords) {
    NgQuery *query = [NgQuery queryWithKeyword:keyword];
    [mother append:query];
  }
  return mother;
}

+ (NgQuery *)queryWithKeyword: (NSString *)keyword minSize:(NSString *)minSize
{
  NgQuery *keywordQuery = [NgQuery queryWithKeyword:keyword];
  NgQuery *minSizeQuery = [[NgQuery alloc] initType:NgMinSize arg1:@"minsize" arg2:minSize];
  return [[NgQuery alloc] initType:NgAnd arg1:keywordQuery arg2:minSizeQuery];
}

+ (NgQuery *)queryWithKeywords: (NSArray *)keywords minSize:(NSString *)minSize
{
  NgQuery *keywordQuery = [NgQuery queryWithKeywords:keywords];
  NgQuery *minSizeQuery = [[NgQuery alloc] initType:NgMinSize arg1:@"minsize" arg2:minSize];
  return [[NgQuery alloc] initType:NgAnd arg1:keywordQuery arg2:minSizeQuery];
}

- initType:(int)t
{
  type = t;
  args = [NSMutableArray arrayWithCapacity:2];
  return self;
}

- initType:(int)t arg1:arg1 arg2:arg2
{
  type = t;
  args = [NSArray arrayWithObjects:arg1, arg2, nil];
  return self;
}

- (void)append:arg
{
  [args addObject:arg];
}

- description
{
  switch (type) {
    case 0:
      return [args componentsJoinedByString:@" AND "];
    case 1:
      return [args componentsJoinedByString:@" OR "];
    case 2:
      return [args componentsJoinedByString:@" AND NOT "];
    case 3:
      return [NSString stringWithFormat:@"Module(%@, %@)", [args objectAtIndex:0], [args objectAtIndex:1]];
    case 4:
      return [NSString stringWithFormat:@"Keyword(%@, %@)", [args objectAtIndex:0], [args objectAtIndex:1]];
    case 5:
      return [NSString stringWithFormat:@"Minsize(%@, %@)", [args objectAtIndex:0], [args objectAtIndex:1]];
    case 6:
      return [NSString stringWithFormat:@"Maxsize(%@, %@)", [args objectAtIndex:0], [args objectAtIndex:1]];
    case 7:
      return [NSString stringWithFormat:@"Format(%@, %@)", [args objectAtIndex:0], [args objectAtIndex:1]];
    case 8:
      return [NSString stringWithFormat:@"Media(%@, %@)", [args objectAtIndex:0], [args objectAtIndex:1]];
    case 9:
      return [NSString stringWithFormat:@"MP3 Artist(%@, %@)", [args objectAtIndex:0], [args objectAtIndex:1]];
    case 10:
      return [NSString stringWithFormat:@"MP3 Title(%@, %@)", [args objectAtIndex:0], [args objectAtIndex:1]];
    case 11:
      return [NSString stringWithFormat:@"MP3 Album(%@, %@)", [args objectAtIndex:0], [args objectAtIndex:1]];
    case 12:
      return [NSString stringWithFormat:@"MP3 Bitrate(%@, %@)", [args objectAtIndex:0], [args objectAtIndex:1]];
    case 13:
      return [NSString stringWithFormat:@"Hidden(%@)", [args componentsJoinedByString:@","]];
    default:
      return @"unknown type query";
  }
}

- (void)writeTo:(NgWriteBuffer *)buf
{
  [buf putInt8:type];
  switch (type) {
    case 0:
    case 1:
    case 13:
      [buf putInt16:[args count]];
      for (NgQuery *q in args) {
        [q writeTo:buf];
      }
      break;
    case 2:
      [[args objectAtIndex:0] writeTo: buf];
      [[args objectAtIndex:1] writeTo: buf];
      break;
    case 3:
      [buf putString:[args objectAtIndex:0]];
      [[args objectAtIndex:1] writeTo: buf];
      break;
    case 4:
    case 5:
    case 6:
    case 7:
    case 8:
    case 9:
    case 10:
    case 11:
    case 12:
      [buf putString:[args objectAtIndex:0]];
      [buf putString:[args objectAtIndex:1]];
      break;
    default:
      break;
  }
}

@end
