//
//  NgTimeTrans.m
//  Nagui
//
//  Created by Appledelhi on 08. 08. 30.
//  Copyright 2008 Appledelhi. All rights reserved.
//

#import "NgTimeTrans.h"


@implementation NgTimeTrans

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
  float time = [value floatValue];
  if (time == FLT_MAX) {
    return @"∞";
  } else if (time == 0.0) {
    return @"";
  } else {
    int64_t t = time;
    if (t > 24 * 60 * 60) {
      return [NSString stringWithFormat:@"%lldd %2lldh", t / 24 / 60 / 60, t / 60 / 60 % 24];
    } else {
      return [NSString stringWithFormat:@"%2lld:%02lld:%02lld", t / 60 / 60, t / 60 % 60, t % 60];
    }
  }
}

@end
