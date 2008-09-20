//
//  NGWriteBuffer.h
//  Nagui
//
//  Created by Appledelhi on 08. 08. 23.
//  Copyright 2008 Appledelhi. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class NgQuery;

@interface NgWriteBuffer : NSObject {
  NSOutputStream *stream;
  NSMutableData *buf;
}

- initStream:stream;

- (void)putInt8:(int8_t)x;
- (void)putInt16:(int16_t)x;
- (void)putInt:(int)x;
- (void)putString:(NSString *)x;
- (void)putStringList:(NSArray *)x;
- (void)send;

@end
