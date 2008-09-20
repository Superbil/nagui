//
//  NgOption.m
//  Nagui
//
//  Created by Appledelhi on 08. 09. 05.
//  Copyright 2008 Appledelhi. All rights reserved.
//

#import "NgOption.h"


@implementation NgOption

@synthesize section;
@synthesize description;
@synthesize name;
@synthesize type;
@synthesize help;
@synthesize value;
@synthesize defaultValue;
@synthesize advanced;
@synthesize options;

- (NSColor *)color
{
  if ([value isEqualToString:defaultValue]) {
    return [NSColor blackColor];
  }
  return [NSColor blueColor];
}

@end