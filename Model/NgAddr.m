//
//  NgAddr.m
//  Nagui
//
//  Created by Appledelhi on 08. 09. 01.
//  Copyright 2008 Appledelhi. All rights reserved.
//

#import "NgAddr.h"


@implementation NgAddr

@synthesize type;
@synthesize ip;
@synthesize geoIp;
@synthesize name;
@synthesize blocked;
@synthesize inetPort;

- (NSString *)description
{
  if (type == 0) {
    return [NSString stringWithFormat:@"%d.%d.%d.%d:%d",
            ip & 0xff, ip >> 8 & 0xff, ip >> 16 & 0xff, ip >> 24 & 0xff, inetPort];
  } else {
    return name;
  }
}

- (BOOL)isEqual:other
{
  if ([other isKindOfClass:[NgAddr class]]) {
    return ip == [other ip] && inetPort == [other inetPort];
  }
  return NO;
}

@end
