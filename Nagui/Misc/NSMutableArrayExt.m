//
//  NSMutableArrayExt.m
//  Nagui
//
//  Created by Jake Song on 08. 09. 20.
//  Copyright 2008 XL Games. All rights reserved.
//

#import "NSMutableArrayExt.h"


@implementation NSMutableArrayExt

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

@end
