//
//  NSObjectControllerExt.m
//  Nagui
//
//  Created by Appledelhi on 08. 09. 20.
//  Copyright 2008 Appledelhi. All rights reserved.
//

#import "NSObjectControllerExt.h"


@implementation NSObjectController(Nagui)

- selectedObject
{
  NSArray *array = [self selectedObjects];
  if ([array count] > 0) {
    return [array objectAtIndex:0];
  }
  return nil;
}

@end
