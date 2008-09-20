//
//  NSArrayExt.m
//  Nagui
//
//  Created by Appledelhi on 08. 09. 14.
//  Copyright 2008 Appledelhi. All rights reserved.
//

#import "NSArrayExt.h"


@implementation NSArray(Nagui)

- (NSArray *)arrayByPerform:(SEL)sel
{
  NSMutableArray *array = [NSMutableArray arrayWithCapacity:[self count]];
  for (id obj in self) {
    id performed = [obj performSelector:sel];
    if (performed) {
      [array addObject:performed];
    }
  }
  return array;
}

@end
