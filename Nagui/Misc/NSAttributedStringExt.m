//
//  NSAttributedString.m
//  Nagui
//
//  Created by Appledelhi on 08. 09. 14.
//  Copyright 2008 Appledelhi. All rights reserved.
//

#import "NSAttributedStringExt.h"


@implementation NSAttributedString(Nagui)

- (NSComparisonResult)compare:other
{
  if (self == nil && other == nil) {
    return NSOrderedSame;
  } else if (self == nil) {
    return NSOrderedAscending;
  } else if (other == nil) {
    return NSOrderedDescending;
  }
  return [[self string] compare:[other string]];
}

@end
