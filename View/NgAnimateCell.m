//
//  NgAnimateCell.m
//  Nagui
//
//  Created by Appledelhi on 08. 09. 10.
//  Copyright 2008 Appledelhi. All rights reserved.
//

#import "NgAnimateCell.h"
#import "Nagui.h"

@implementation NgAnimateCell

- (void)drawWithFrame:(NSRect)frame inView:(NSView *)view
{
  if ([self objectValue] == nagui.downloadingImage) {
    // if (!timer) {
    //   timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timer:)
    //                                  userInfo:nil repeats:YES];
    // }
    NSLog(@"Yes");
  }
  [super drawWithFrame:frame inView:view];
}

@end
