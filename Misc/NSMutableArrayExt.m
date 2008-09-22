//
//  NSMutableArrayExt.m
//  Nagui
//
//  Created by Jake Song on 08. 09. 20.
//  Copyright 2008 XL Games. All rights reserved.
//

#import "NSMutableArrayExt.h"


@implementation NSMutableArray(Nagui)

- (void)addAndRemove:(NSArray *)array
{
  NSMutableIndexSet *removeSet = [NSMutableIndexSet indexSet];
  int index = 0;
  for (id obj in self) {
    if (![array containsObject:obj]) {
      [removeSet addIndex:index];
    }
    index++;
  }
  [self removeObjectsAtIndexes:removeSet];
  for (id obj in array) {
    if (![self containsObject:obj]) {
      [self addObject:obj];
    }
  }
}

- (void)addObjectsFromArrayUnique:(NSArray *)array
{
  if (array) {
    for (id obj in array) {
      if (![self containsObject:obj]) {
        [self addObject:obj];
      }
    }
  }
}

@end
