//
//  NgHostState.m
//  Nagui
//
//  Created by Appledelhi on 08. 08. 31.
//  Copyright 2008 Appledelhi. All rights reserved.
//

#import "NgHostState.h"


@implementation NgHostState

@synthesize state;
@synthesize rank;

- (NSComparisonResult)compare:other
{
  if ([other isMemberOfClass:[NgHostState class]]) {
    NgHostState *o = other;
    return state - o.state;
  }
  return NSOrderedSame;
}

@end
