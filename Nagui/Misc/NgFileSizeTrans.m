//
//  NgFileSizeTrans.m
//  Nagui
//
//  Created by Appledelhi on 08. 08. 25.
//  Copyright 2008 Appledelhi. All rights reserved.
//

#import "NgFileSizeTrans.h"


@implementation NgFileSizeTrans

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
  double size = [value doubleValue];
  const char *unit = " KMGTP";
  if (size == 0.0) {
    return [NSString stringWithFormat:@"0"];
  }
  while (*unit) {
    if (size < 10.0) {
      return [NSString stringWithFormat:@"%.2f%c", size, *unit];
    } else if (size < 100.0) {
      return [NSString stringWithFormat:@"%.1f%c", size, *unit];
    } else if (size < 1000.0) {
      return [NSString stringWithFormat:@"%.0f%c", size, *unit];
    }
    size /= 1024.0; 
    unit++;
  }
  return [NSString stringWithFormat:@"%.2fE", size];
}

@end
