//
//  NgFileInfo.m
//  Nagui
//
//  Created by Appledelhi on 08. 08. 28.
//  Copyright 2008 Appledelhi. All rights reserved.
//

#import "NgFileInfo.h"
#import "Nagui.h"

@implementation NgFileInfo

@synthesize fileId;
@synthesize fileNames;
@synthesize fileName;
@synthesize md4;
@synthesize fileSize;
@synthesize downloadedSize;
@synthesize downloadSpeed;
@synthesize chunks;
@synthesize availability;

- (BOOL)isEqual:other
{
  if ([other respondsToSelector:@selector(fileId)]) {
    return fileId == [other fileId];
  }
  return NO;
}

- (float)percent
{
  return (float)downloadedSize / fileSize;
}

float sat[] = { 1.00, 0.45, 0.39, 0.43, 0.46, 0.74, 0.67, 0.61, 0.56, 0.50, 0.46, 0.50, 0.00 };
float bri[] = { 0.70, 0.85, 0.90, 0.90, 0.90, 0.88, 0.92, 0.98, 1.00, 1.00, 1.00, 1.00, 0.36 };
float edgeSat = 0.86;
float edgeBri = 0.63;

void drawEdge(float x, float hue)
{
  [[NSColor colorWithDeviceHue:hue saturation:edgeSat brightness:edgeBri alpha:1.0] set];
  [NSBezierPath fillRect:NSMakeRect(x, 2, 1, 13)];
}

void drawChunk(float x, float hue)
{
  float y = 14.0;
  for (int i = 0; i < 13; i++) {
    float h = i == 0 ? 212.0/360.0 : hue;
    [[NSColor colorWithDeviceHue:h saturation:sat[i] brightness:bri[i] alpha:1.0] set];
    [NSBezierPath fillRect:NSMakeRect(x, y, 1, 1)];
    y -= 1.0;
  }
}

- (NSImage *)progress
{
  float width = [nagui.downloadProgress width];
  if (width != oldWidth || ![chunks isEqualToData:oldChunks] || ![availability isEqualToData:oldAvail]) {
    image = [[NSImage alloc] initWithSize:NSMakeSize(width, 17)];
    [image lockFocus];
    int chunksLen = [chunks length];
    int len = [availability length];
    if (chunksLen != len) {
      NSLog(@"chunksLen = %d len = %d", chunksLen, len);
    }
    const UInt8 *chunk = [chunks bytes];
    const UInt8 *avail = [availability bytes];
    drawEdge(0, 0.66666);

    float x = 0;
    float inWidth = width - 2;
    while (x < inWidth) {
      float hue = 212.0/360.0;
      if (fileSize != downloadedSize) {
        int i = x * len / inWidth;
        int endI = (x + 1) * len / inWidth;
        do {
          float h;
          if (chunk && (chunk[i] == '0' || chunk[i] == '1')) {
            float a = avail[i] > 10 ? 10 : avail[i];
            if (a == 0) {
              h = 0;
            } else {
              h = a / 10.0 * (60.0 / 360.0) + (60.0 / 360.0);
            }
          } else {
            h = 212.0/360.0;
          }
          if (h < hue) {
            hue = h;
          }
          i++;
        } while (i < endI);
      }
      drawChunk(x + 1, hue);
      x += 1;
    }
    drawEdge(width - 1, 0.666666);
    [image unlockFocus];
    oldWidth = width;
    oldChunks = chunks;
    oldAvail = availability;
  }
  return image;
}

- (float)eta
{
  if (downloadedSize == fileSize) {
    return 0;
  }
  if (downloadSpeed == 0) {
    return FLT_MAX;
  }
  return (fileSize - downloadedSize) / downloadSpeed;
}

@end
