//
//  NgProgressCell.m
//  Nagui
//
//  Created by Appledelhi on 08. 09. 03.
//  Copyright 2008 Appledelhi. All rights reserved.
//

#import "NgProgressCell.h"
#import "NgFileInfo.h"

@implementation NgProgressCell

static void draw(float hue, float x, float y, float width, float height, BOOL edge)
{
  static NSMutableDictionary *gradients;
  static NSGradient *edgeGradient;
  
  if (gradients == nil) {
    gradients = [NSMutableDictionary dictionaryWithCapacity:20];
    edgeGradient = [[NSGradient alloc] initWithColorsAndLocations:
                    [NSColor colorWithDeviceHue:212.0/360.0 saturation:1.00 brightness:0.70 alpha:1.0], 0.0,
                    [NSColor colorWithDeviceHue:212.0/360.0 saturation:0.00 brightness:0.36 alpha:1.0], 1.0,
                    nil];
  }
  NSGradient *gradient;
  if (edge) {
    gradient = edgeGradient;
  } else {
    gradient = [gradients objectForKey:[NSNumber numberWithFloat:hue]];
    if (gradient == nil) {
      gradient = [[NSGradient alloc] initWithColors:
                  [NSArray arrayWithObjects:
                   [NSColor colorWithDeviceHue:hue saturation:1.00 brightness:0.70 alpha:1.0],
                   [NSColor colorWithDeviceHue:hue saturation:0.46 brightness:0.88 alpha:1.0],
                   [NSColor colorWithDeviceHue:hue saturation:0.36 brightness:0.91 alpha:1.0],
                   [NSColor colorWithDeviceHue:hue saturation:0.36 brightness:0.91 alpha:1.0],
                   [NSColor colorWithDeviceHue:hue saturation:0.41 brightness:0.91 alpha:1.0],
                   [NSColor colorWithDeviceHue:hue saturation:0.64 brightness:0.90 alpha:1.0],
                   [NSColor colorWithDeviceHue:hue saturation:0.57 brightness:0.95 alpha:1.0],
                   [NSColor colorWithDeviceHue:hue saturation:0.52 brightness:1.00 alpha:1.0],
                   [NSColor colorWithDeviceHue:hue saturation:0.45 brightness:1.00 alpha:1.0],
                   [NSColor colorWithDeviceHue:hue saturation:0.40 brightness:1.00 alpha:1.0],
                   [NSColor colorWithDeviceHue:hue saturation:0.36 brightness:1.00 alpha:1.0],
                   [NSColor colorWithDeviceHue:hue saturation:0.40 brightness:1.00 alpha:1.0],
                   [NSColor colorWithDeviceHue:hue saturation:0.00 brightness:0.36 alpha:1.0],
                   nil]];
      [gradients setObject:gradient forKey:[NSNumber numberWithFloat:hue]];
    }
  }
  [gradient drawInRect:NSMakeRect(x, y, width, height) angle:90.0];
}

- (void)drawWithFrame:(NSRect)frame inView:(NSView *)view
{
  if (!levelCell) {
    levelCell = [[NSLevelIndicatorCell alloc] initWithLevelIndicatorStyle:NSContinuousCapacityLevelIndicatorStyle];
    [levelCell setMaxValue:1];
    [levelCell setObjectValue:[NSNumber numberWithInt:1]];
  }
  NgFileInfo *fi = [self objectValue];
  if (!fi.indicator) {
    NSProgressIndicator *indi = [[NSProgressIndicator alloc] initWithFrame:frame];
    fi.indicator = indi;
    [indi setIndeterminate:NO];
    [view addSubview:indi];
  }
  int len = [fi.chunks length];
  const uint8_t *chunk = [fi.chunks bytes];
  float endX = frame.origin.x + frame.size.width;
  NSRect r = frame;
  r.size.width = 1;
  r.size.height -= 1;
  while (r.origin.x < endX) {
    if (*chunk == '3') {
      [levelCell setWarningValue:1.5];
      [levelCell setCriticalValue:1.5];
    } else if (*chunk == '0') {
      [levelCell setWarningValue:0];
      [levelCell setCriticalValue:0.5];
    } else {
      [levelCell setWarningValue:0];
      [levelCell setCriticalValue:1.5];
    }
    [levelCell drawWithFrame:r inView:view];
    r.origin.x += 1;
    chunk++;
  }
}

- (void)olddrawWithFrame:(NSRect)frame inView:(NSView *)view
{
//  NSButtonCell *buttonCell = [[NSButtonCell alloc] init];
//  [buttonCell setTitle:@""];
//  [buttonCell setKeyEquivalent:@"\r"];
//  [buttonCell setGradientType:NSGradientConvexStrong];
//  [buttonCell setControlSize:NSMiniControlSize];
//  [buttonCell setBezelStyle:NSRoundedBezelStyle];
//  frame.origin.y += 1;
//  [buttonCell drawBezelWithFrame:frame inView:view];
  NgFileInfo *fi = [self objectValue];
  int len = [fi.availability length];
  const uint8_t *chunk = [fi.chunks bytes];
  const uint8_t *avail = [fi.availability bytes];
  float x = frame.origin.x;
  float y = frame.origin.y;
  float width = (frame.size.width - 2.0) / len;
  float height = frame.size.height - 3;
  float hue;
  [view lockFocus];
  draw(212.0/360.0, x, y, 1.0, height, YES);
  x += 1.0;
  while (len-- > 0) {
    if (fi.fileSize == fi.downloadedSize || *chunk == '3') {
      hue = 212.0/360.0;
    } else if (*chunk == '0' || *avail == 0) {
      hue = 0.0;
    } else {
      float a = *avail > 10 ? 10 : *avail;
      hue = a / 10.0 * (60.0 / 360.0) + (60.0 / 360.0);
    }
    draw(hue, x, y, width, height, NO);
    x += width;
    avail++;
    chunk++;
  }
  draw(212.0/360.0, x, y, 1.0, height, YES);
  [view unlockFocus];
}

@end
