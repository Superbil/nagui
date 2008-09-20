//
//  NgOptionManager.m
//  Nagui
//
//  Created by Appledelhi on 08. 09. 05.
//  Copyright 2008 Appledelhi. All rights reserved.
//

#import "NgOptionManager.h"
#import "NgOption.h"
#import "Nagui.h"
#import "NgProtocolHandler.h"
#import "NgTransferManager.h"

@implementation NgOptionManager

- (void)awakeFromNib
{
  sections = [NSMutableArray arrayWithCapacity:20];
}

- (void)addOption:(NgOption *)option
{
  NgOption *section = nil;
  for (NgOption *op in sections) {
    if ([op.name isEqualToString:option.section]) {
      section = op;
      break;
    }
  }

  [self willChangeValueForKey:@"sections"];
  if (!section) {
    section = [[NgOption alloc] init];
    section.name = option.section;
    section.options = [NSMutableArray arrayWithCapacity:10];
    [sections addObject:section];
  }
  [section.options addObject:option];
  [self didChangeValueForKey:@"sections"];
  [option addObserver:self forKeyPath:@"value" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)addOption:(NSString *)optionName value:(NSString *)value
{
  NgOption *option = [[NgOption alloc] init];
  option.section = @"Main";
  option.name = optionName;
  option.value = value;
  [self addOption:option];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:object change:(NSDictionary *)change
                       context:(void *)context
{
  if ([object isMemberOfClass:[NgOption class]]) {
    NgOption *option = object;
    NSString *newValue = [change objectForKey:NSKeyValueChangeNewKey];
    [nagui.protocolHandler sendSetOption:option.name value:newValue];
    [nagui.transferManager setLimits:option];
  }
}

@end
