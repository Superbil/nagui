//
//  NGWriteBuffer.m
//  Nagui
//
//  Created by Appledelhi on 08. 08. 23.
//  Copyright 2008 Appledelhi. All rights reserved.
//

#import "NgWriteBuffer.h"
#import "NgQuery.h"

@implementation NgWriteBuffer

- initStream:outputStream
{
  stream = outputStream;
  buf = [NSMutableData dataWithCapacity:1024];
  [buf setLength:4];
  return self;
}

- (void)putInt8:(int8_t)x
{
  [buf appendBytes:&x length:1];
}

- (void)putInt16:(int16_t)x
{
  char tmp[2];
  OSWriteLittleInt16(tmp, 0, x);
  [buf appendBytes:tmp length:2];
}

- (void)putInt:(int)x
{
  char tmp[4];
  OSWriteLittleInt32(tmp, 0, x);
  [buf appendBytes:tmp length:4];
}

- (void)putString:(NSString *)string
{
  const char *str = [string UTF8String];
  int len = strlen(str);
  [self putInt16: len];
  [buf appendBytes:str length:len];
}

- (void)putStringList:(NSArray *)array
{
  [self putInt16:[array count]];
  for (NSString *str in array) {
    [self putString:str];
  }
}

- (void)send
{
  int len = [buf length] - 4;
  char tmp[4];
  OSWriteLittleInt32(tmp, 0, len);
  [buf replaceBytesInRange:NSMakeRange(0, 4) withBytes:tmp];
  len = [stream write:[buf bytes] maxLength: [buf length]];
  NSAssert(len == [buf length], @"sent length short");
  [buf setLength:4];
}

@end
