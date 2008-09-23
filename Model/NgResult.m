//
//  NgResult.m
//  Nagui
//
//  Created by Appledelhi on 08. 08. 24.
//  Copyright 2008 Appledelhi. All rights reserved.
//

#import "NgResult.h"
#import "NgTag.h"
#import "Nagui.h"
#import "NgTransferManager.h"
#import "NgSearchManager.h"

@implementation NgResult

@synthesize resultId;
@synthesize networkId;
@synthesize fileNames;
@synthesize fileIds;
@synthesize fileSize;
@synthesize format;
@synthesize type;
@synthesize tags;
@synthesize comment;
@synthesize time;
@synthesize downloaded;

- (BOOL)isEqual:other
{
  if ([other respondsToSelector:@selector(resultId)]) {
    return resultId == [other resultId];
  }
  return NO;
}

- (NSString *)fileName
{
  if ([fileNames count] > 0) {
    return [fileNames objectAtIndex:0];
  }
  return @"";
}

- (int)available
{
  if (available) {
    return available.intValue;
  }
  for (NgTag *tag in tags) {
    if ([tag.name isEqualToString:@"availability"]) {
      available = tag;
      return tag.intValue;
    }
  }
  return 0;
}

- (int)complete
{
  if (complete) {
    return complete.intValue;
  }
  for (NgTag *tag in tags) {
    if ([tag.name isEqualToString:@"completesources"]) {
      complete = tag;
      return tag.intValue;
    }
  }
  return 0;
}

- (int)bitRate
{
  if (bitRate) {
    return bitRate.intValue;
  }
  for (NgTag *tag in tags) {
    if ([tag.name isEqualToString:@"bitrate"]) {
      bitRate = tag;
      return tag.intValue;
    }
  }
  return 0;
}

- (NSColor *)color
{
  float bri = [self available] / 20.0;
  if (bri > 1.0) {
    bri = 1.0;
  }
  if (downloaded || [self isDownloading]) {
    return [NSColor colorWithDeviceHue:120.0/360 saturation:0.9 brightness:0.5 alpha:1.0];
  }
  if ([self complete] == 0) {
    return [NSColor colorWithDeviceHue:47.0/360.0 saturation:0.97 brightness:0.66 alpha:1.0];
  }
  return [NSColor colorWithDeviceHue:0.666 saturation:1.0 brightness:bri alpha:1.0];
}
// 
// - (BOOL)bold
// {
//   if (!isDownloadingInited) {
//     isDownloading = [nagui.transferManager isDownloading:fileIds];
//     isDownloadingInited = YES;
//   }
//   return downloaded || isDownloading;
// }

- (NSImage *)status
{
  if (downloaded) {
    return nagui.downloadImage;
  } else if ([self isDownloading]) {
    return nagui.downloadingImage;
  } else if ([self complete] == 0) {
    return nagui.alertImage;
  } else {
    return nil;
  }
}

- (BOOL)isDownloading
{
  return [nagui.transferManager isDownloading:fileIds];
}

// - (void)setIsDownloading:(BOOL)i
// {
//   isDownloading = i;
// }

@end
