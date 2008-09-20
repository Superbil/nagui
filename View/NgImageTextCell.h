//
//  NgImageTextCell.h
//  Nagui
//
//  Created by Appledelhi on 08. 09. 18.
//  Copyright 2008 Appledelhi. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NgImageTextCell : NSTextFieldCell {
  NSImage *image;
}

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView;
- (NSSize)cellSize;

@end
