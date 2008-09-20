//
//  NgSharedFolder.m
//  Nagui
//
//  Created by Appledelhi on 08. 09. 07.
//  Copyright 2008 Appledelhi. All rights reserved.
//

#import "NgSharedFolder.h"


@implementation NgSharedFolder

@synthesize path;
@synthesize type;

- initPath:(NSString *)p type:(NgGroupType)t
{
  path = p;
  type = t;
  return self;
}

@end
