//
//  NgSmartGroup.m
//  Nagui
//
//  Created by Appledelhi on 08. 09. 16.
//  Copyright 2008 Appledelhi. All rights reserved.
//

#import "NgSmartGroup.h"
#import "Nagui.h"
#import "Util.h"

@implementation NgSmartGroup

@synthesize name;

- initName:(NSString *)n type:(NgGroupType)t
{
  self = [super initName:n type:t];
//  icon = nagui.smartFolderImage;
  return self;
}

- (NSImage *)icon
{
  return nagui.smartFolderImage;
}

@end
