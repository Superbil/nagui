//
//  NgOptionSection.m
//  Nagui
//
//  Created by Appledelhi on 08. 09. 06.
//  Copyright 2008 Appledelhi. All rights reserved.
//

#import "NgOptionSection.h"


@implementation NgOptionSection

@synthesize name;
@synthesize options;

- (BOOL)isEqual:other
{
  if ([other respondsToSelector:@selector(name)]) {
    return [name isEqualToString:[other name]];
  }
  return NO;
}

- (NSString *)value
{
  return @"";
}

@end
