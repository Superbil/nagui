//
//  NgStateTrans.m
//  Nagui
//
//  Created by Appledelhi on 08. 08. 31.
//  Copyright 2008 Appledelhi. All rights reserved.
//

#import "NgStateTrans.h"
#import "NgHostState.h"

@implementation NgStateTrans

+ (Class)transformedValueClass
{
  return [NSString class];
}

+ (BOOL)allowsReverseTransformation
{
  return NO;
}

- transformedValue:value
{
  NgHostState *hs = value;
  switch (hs.state) {
    case 0:
      return @"Disconnected";
    case 1:
      return @"Connecting";
    case 2:
      return @"Initiating";
    case 3:
      return [NSString stringWithFormat:@"Downloading %d", hs.rank];
    case 4:
      return @"Connected -1";
    case 5:
      return [NSString stringWithFormat:@"Connected %d", hs.rank];
    case 6:
      return @"New host";
    case 7:
      return @"Remove host";
    case 8:
      return @"Blacklisted";
    case 9:
      return [NSString stringWithFormat:@"Not connected %d", hs.rank];
    case 10:
      return @"Connected";
    default:
      return @"Unknown";
  }
}

@end
