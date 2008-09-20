//
//  NgImageTextCell.m
//  Nagui
//
//  Created by Appledelhi on 08. 09. 18.
//  Copyright 2008 Appledelhi. All rights reserved.
//

#import "NgImageTextCell.h"

@implementation NgImageTextCell

- init
{
  if (self = [super init]) {
    [self setLineBreakMode:NSLineBreakByTruncatingTail];
    [self setSelectable:YES];
  }
  return self;
}

- copyWithZone:(NSZone *)zone
{
  return NSCopyObject(self, 0, zone);
}

- (void)setImage:(NSImage *)newImage
{
  image = newImage;
}

- (NSRect)imageRectForBounds:(NSRect)cellFrame
{
  NSRect result;
//  NSImage *image = [[self objectValue] icon];
  if (image) {
    result.size = [image size];
    result.origin = cellFrame.origin;
    result.origin.x += 3;
    result.origin.y += ceil((cellFrame.size.height - result.size.height) / 2);
  } else {
    result = NSZeroRect;
  }
  return result;
}

- (NSRect)titleRectForBounds:(NSRect)cellFrame
{
  NSRect result;
//  NSImage *image = [[self objectValue] icon];
  if (image) {
    CGFloat imageWidth = [image size].width;
    result = cellFrame;
    result.origin.x += (3 + imageWidth);
    result.size.width -= (3 + imageWidth);
  } else {
    result = NSZeroRect;
  }
  return result;
}


- (void)editWithFrame:(NSRect)aRect inView:(NSView *)controlView editor:(NSText *)textObj
             delegate:(id)anObject event:(NSEvent *)theEvent
{
//  id original = [self objectValue];
//  NSImage *image = [original icon];
  NSRect textFrame, imageFrame;
  NSDivideRect (aRect, &imageFrame, &textFrame, 3 + [image size].width, NSMinXEdge);
//  [self setObjectValue:[original name]];
  [super editWithFrame:textFrame inView:controlView editor:textObj delegate:anObject event:theEvent];
//  [self setObjectValue:original];
}

- (void)selectWithFrame:(NSRect)aRect inView:(NSView *)controlView editor:(NSText *)textObj
               delegate:(id)anObject start:(NSInteger)selStart length:(NSInteger)selLength
{
//  id original = [self objectValue];
//  NSImage *image = [original icon];
  NSRect textFrame, imageFrame;
  NSDivideRect (aRect, &imageFrame, &textFrame, 3 + [image size].width, NSMinXEdge);
//  [self setObjectValue:[original name]];
  [super selectWithFrame:textFrame inView:controlView editor:textObj delegate:anObject start:selStart length:selLength];
//  [self setObjectValue:original];
}

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
//  id original = [self objectValue];
//  NSImage *image = [original icon];
  if (image) {
    NSRect imageFrame;
    NSSize imageSize = [image size];
    NSDivideRect(cellFrame, &imageFrame, &cellFrame, 3 + imageSize.width, NSMinXEdge);
    if ([self drawsBackground]) {
      [[self backgroundColor] set];
      NSRectFill(imageFrame);
    }
    imageFrame.origin.x += 3;
    imageFrame.size = imageSize;
    
    if ([controlView isFlipped])
      imageFrame.origin.y += ceil((cellFrame.size.height + imageFrame.size.height) / 2);
    else
      imageFrame.origin.y += ceil((cellFrame.size.height - imageFrame.size.height) / 2);
    
    [image compositeToPoint:imageFrame.origin operation:NSCompositeSourceOver];
  }
//  [self setObjectValue:[original name]];
  [super drawWithFrame:cellFrame inView:controlView];
//  [self setObjectValue:original];
}

- (NSSize)cellSize
{
  NSSize cellSize = [super cellSize];
//  NSImage *image = [[self objectValue] icon];
  cellSize.width += (image ? [image size].width : 0) + 3;
  return cellSize;
}

- (NSUInteger)hitTestForEvent:(NSEvent *)event inRect:(NSRect)cellFrame ofView:(NSView *)controlView
{
  NSPoint point = [controlView convertPoint:[event locationInWindow] fromView:nil];
//  id original = [self objectValue];
//  NSImage *image = [original icon];
  // If we have an image, we need to see if the user clicked on the image portion.
  if (image) {
    // This code closely mimics drawWithFrame:inView:
    NSSize imageSize = [image size];
    NSRect imageFrame;
    NSDivideRect(cellFrame, &imageFrame, &cellFrame, 3 + imageSize.width, NSMinXEdge);
    
    imageFrame.origin.x += 3;
    imageFrame.size = imageSize;
    // If the point is in the image rect, then it is a content hit
    if (NSMouseInRect(point, imageFrame, [controlView isFlipped])) {
      // We consider this just a content area. It is not trackable, nor it it editable text. If it was, we would or in the additional items.
      // By returning the correct parts, we allow NSTableView to correctly begin an edit when the text portion is clicked on.
      return NSCellHitContentArea;
    }        
  }
//  [self setObjectValue:[original name]];
  // At this point, the cellFrame has been modified to exclude the portion for the image. Let the superclass handle the hit testing at this point.
  NSUInteger r = [super hitTestForEvent:event inRect:cellFrame ofView:controlView];
//  [self setObjectValue:original];
  return r;
}

@end
