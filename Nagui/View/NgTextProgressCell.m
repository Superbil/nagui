//
//  NgTextProgressCell.m
//  Nagui
//
//  Created by Appledelhi on 08. 09. 19.
//  Copyright 2008 Appledelhi. All rights reserved.
//

#import "NgTextProgressCell.h"


@implementation NgTextProgressCell

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
  cellFrame.size.height -= 16;
  [super drawWithFrame:cellFrame inView:controlView];
}

@end
