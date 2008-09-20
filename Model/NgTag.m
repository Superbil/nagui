//
//  NgTag.m
//  Nagui
//
//  Created by Appledelhi on 08. 08. 24.
//  Copyright 2008 Appledelhi. All rights reserved.
//

#import "NgTag.h"


@implementation NgTag

@synthesize name;
@synthesize type;
@synthesize intValue;
@synthesize intValue2;
@synthesize strValue;

+ tagWith:name type:(int)type intValue:(int)i intValue2:(int)i2 strValue:str
{
  NgTag *tag = [[NgTag alloc] init];
  tag.name = name;
  tag.type = type;
  tag.intValue = i;
  tag.intValue2 = i2;
  tag.strValue = str;
  return tag;
}

@end
