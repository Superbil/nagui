//
//  NgFolderCell.m
//  Nagui
//
//  Created by Appledelhi on 08. 09. 06.
//  Copyright 2008 Appledelhi. All rights reserved.
//

#import "NgFolderCell.h"
#import "NgFolder.h"
#import "Nagui.h"

@implementation NgFolderCell

- initTextCell:(NSString *)text
{
  buttonCell = [[NSButtonCell alloc] initTextCell:@""];
  [buttonCell setButtonType:NSSwitchButton];
  [buttonCell setAllowsMixedState:YES];
  popupCell = [[NSPopUpButtonCell alloc] initTextCell:@"" pullsDown:NO];
  [popupCell setBezelStyle:NSRegularSquareBezelStyle];
  [popupCell setBordered:NO];
  [popupCell setArrowPosition:NSPopUpArrowAtBottom];
  [popupCell setPreferredEdge:NSMinXEdge];
//  [popupCell addItemsWithTitles:[NSArray arrayWithObjects:
//                                 @"", @"Share", @"Share recursively",
//                                 @"As incoming files", @"As incoming directories", nil]];
//  [[popupCell menu] addItem:[NSMenuItem separatorItem]];
//  [popupCell addItemWithTitle:@"Unshare"];
  [popupCell setMenu:nagui.shareMenu];
  return [super initTextCell:@""];
}

- copyWithZone:(NSZone *)zone
{
  return NSCopyObject(self, 0, zone);;
}

- (void)setTitle:(NSString *)title
{
  [buttonCell setTitle:title];
}

- (void)setState:(int)value
{
  NSLog(@"setState %d", value);
  [popupCell setState:value];
  [buttonCell setState:value];
}

- (void)drawWithFrame:(NSRect)frame inView:(NSView *)view
{
  [buttonCell drawWithFrame:frame inView:view];
  NSSize size = [buttonCell cellSize];
  frame.origin.x += size.width;
  frame.size.width = [popupCell cellSize].width;
  [popupCell drawWithFrame:frame inView:view];
}

- (void)selectWithFrame:(NSRect)frame inView:(NSView *)view  
                 editor:(NSText *)textObj delegate:object start:(int)start length:(int)length
{
  NSSize size = [buttonCell cellSize];
  frame.origin.x += size.width;
  frame.size.width = [popupCell cellSize].width;
  [popupCell selectWithFrame:frame inView:view editor:textObj delegate:object start:start length:length];
}

- (void)editWithFrame:(NSRect)frame inView:(NSView *)view  
               editor:(NSText *)textObj delegate:object event:(NSEvent *)event
{
  NSSize size = [buttonCell cellSize];
  frame.origin.x += size.width;
  frame.size.width = [popupCell cellSize].width;
  [popupCell editWithFrame:frame inView:view editor:textObj delegate:object event:event];
}

- (BOOL)trackMouse:(NSEvent *)event inRect:(NSRect)frame  
            ofView:(NSView *)view untilMouseUp:(BOOL)until
{
  NSPoint point = [view convertPoint:[event locationInWindow] fromView:nil];
  NSSize size = [buttonCell cellSize];
  frame.origin.x += size.width;
  frame.size.width = [popupCell cellSize].width;
  if (NSPointInRect(point, frame)) {
    return [popupCell trackMouse:event inRect:frame ofView:view untilMouseUp:until];
  }
  return NO;
}
//- copyWithZone:(NSZone *)zone
//{
//  NgFolderCell *copy = [super copyWithZone:zone];
//  copy->buttonCell = buttonCell;
//  return copy;
//}
//- (NSString *)title
//{
//  
//}
//- objectValue
//{
////  NgFolder *f = [super objectValue];
//  return [NSNumber numberWithInt:1];
//}

//- (void)setObjectValue:object
//{
//  [super setObjectValue:object];
//  [buttonCell setState:[object shared]];
//}
//static NSButtonCell *buttonCell;
//
//
//- (BOOL)startTrackingAt:(NSPoint)startPoint inView:view
//{
//  NSLog(@"start");
//  return [buttonCell startTrackingAt:startPoint inView:view];
//}
//
//- (BOOL)continueTracking:(NSPoint)lastPoint at:(NSPoint)currentPoint inView:(NSView *)view
//{
//  NSLog(@"continue");
//  return [buttonCell continueTracking:lastPoint at:currentPoint inView:view];
//}
//
//- (void)stopTracking:(NSPoint)lastPoint at:(NSPoint)stopPoint inView:(NSView *)view mouseIsUp:(BOOL)flag
//{
//  NSLog(@"stop");
//  [super stopTracking:lastPoint at:stopPoint inView:view mouseIsUp:flag];
//}
//
//- (void)performClick:sender
//{
//  NSLog(@"click");
//  [super performClick:sender];
//}
//
//-  (BOOL)isEnabled
//{
//  return YES;
//}
//
//- (NSUInteger)hitTestForEvent:(NSEvent *)event inRect:(NSRect)frame ofView:(NSView *)view
//{
//  NSLog(@"hit");
//  return [buttonCell hitTestForEvent:event inRect:frame ofView:view];
//}

@end
