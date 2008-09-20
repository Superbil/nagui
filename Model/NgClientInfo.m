//
//  NgClientInfo.m
//  Nagui
//
//  Created by Appledelhi on 08. 08. 31.
//  Copyright 2008 Appledelhi. All rights reserved.
//

#import "NgClientInfo.h"


@implementation NgClientInfo

@synthesize clientId;
@synthesize name;
@synthesize fileName;
@synthesize state;
@synthesize downloaded;
@synthesize uploaded;
@synthesize color;

- (BOOL)isEqual:other
{
  if ([other respondsToSelector:@selector(clientId)]) {
    return clientId == [other clientId];
  }
  return NO;
}

@end
