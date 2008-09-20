//
//  NgServerInfo.m
//  Nagui
//
//  Created by Appledelhi on 08. 09. 01.
//  Copyright 2008 Appledelhi. All rights reserved.
//

#import "NgServerInfo.h"
#import "NgHostState.h"

@implementation NgServerInfo

@synthesize serverId;
@synthesize name;
@synthesize description;
@synthesize state;
@synthesize users;
@synthesize files;
@synthesize ping;
@synthesize addr;

- (BOOL)isEqual:other
{
  if ([other respondsToSelector:@selector(serverId)]) {
    if (serverId == [other serverId]) {
      return YES;
    }
  }
  if ([other respondsToSelector:@selector(addr)]) {
    return [addr isEqual:[other addr]];
  }
  return NO;
}

- (NSColor *)color
{
  if (state.state == 10) {
    return [NSColor colorWithDeviceHue:240.0/360.0 saturation:0.9 brightness:0.9 alpha:1.0];
  }
  return [NSColor blackColor];
}
@end
