//
//  NgServerManager.m
//  Nagui
//
//  Created by Appledelhi on 08. 09. 01.
//  Copyright 2008 Appledelhi. All rights reserved.
//

#import "NgServerManager.h"
#import "NgServerInfo.h"

@implementation NgServerManager

@synthesize servers;

-  (void)awakeFromNib
{
  servers = [NSMutableArray arrayWithCapacity:100];
}

- (void)add:(NgServerInfo *)serverInfo
{
  NSUInteger index = [servers indexOfObject:serverInfo];

  [self willChangeValueForKey:@"servers"];
  if (index == NSNotFound) {
    [servers addObject:serverInfo];
  } else {
    [servers replaceObjectAtIndex:index withObject:serverInfo];
  }

  [self didChangeValueForKey:@"servers"];
}

@end
