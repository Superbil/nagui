//
//  NgFileController.m
//  Nagui
//
//  Created by Jake Song on 08. 09. 20.
//  Copyright 2008 XL Games. All rights reserved.
//

#import "NgFileController.h"
#import "NgFile.h"

@implementation NgFileController

- (NSArray *)arrangeObjects:(NSArray *)objects
{
  if (!filterStr || [filterStr length] == 0) {
    return [super arrangeObjects:objects];
  }
  NSMutableArray *filtered = [NSMutableArray arrayWithCapacity:[objects count]];
  for (id obj in objects) {
    if ([obj match:filterStr]) {
      [filtered addObject:obj];
    }
  }
  return [super arrangeObjects:filtered];
}

- (IBAction)setFilter:sender
{
  filterStr = [sender stringValue];
  [self rearrangeObjects];
}

@end
