//
//  NGBuffer.h
//  Nagui
//
//  Created by Appledelhi on 08. 08. 21.
//  Copyright 2008 Appledelhi. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class NgQuery;
@class NgFileFormat;
@class NgFileInfo;
@class NgClientKind;
@class NgHostState;
@class NgAddr;

enum ReadState {
  RS_LENGTH,
  RS_BODY
};

@interface NgReadBuffer : NSObject {
  NSInputStream *stream;
  enum ReadState state;
  int toRead;
  uint8_t *head;
  uint8_t *tail;
  NSMutableData *buf;
}

- initStream:stream;

- (BOOL)read;
- (void)reset;

- (uint8_t)getInt8;
- (int16_t)getInt16;
- (int)getInt;
- (int64_t)getInt64;
- (NSString *)getString;
- (NSData *)getMd4;
- (int)getFileState;
- (NSData *)getChunks;
- (float)getFloat;
- (NSNumber *)getIntNumber;

- (NgHostState *)getState;
- (NgQuery *)getQuery;
- (NgFileFormat *)getFileFormat;
- (NgFileInfo *)getFileInfo;
- (NgClientKind *)getClientKind;
- (NgAddr *)getAddr;

- (NSArray *)getIntList;
- (NSArray *)getStringList;
- (NSArray *)getTagList;
- (NSArray *)getAvailabilityList;
- (NSArray *)getSubfileList;
- (NSArray *)getCommentList;

@end
