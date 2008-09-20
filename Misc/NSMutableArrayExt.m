//
//  NSMutableArrayExt.m
//  Nagui
//
//  Created by Jake Song on 08. 09. 20.
//  Copyright 2008 XL Games. All rights reserved.
//

#import "NSMutableArrayExt.h"


@implementation NSMutableArray(Nagui)

- (void)addRemove:(NSArray *)array
{
  for (id obj in self) {
    BOOL found = NO;
    for (id other in array) {
      if ([obj isEqual:other]) {
        found = YES;
      }
    }
    if (!found) {
      ;
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
