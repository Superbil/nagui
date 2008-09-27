//
//  NgResult.h
//  Nagui
//
//  Created by Appledelhi on 08. 08. 24.
//  Copyright 2008 Appledelhi. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class NgTag;

@interface NgResult : NSObject {
  NSNumber *resultId;
  int networkId;
  NSArray *fileNames;
  NSArray *fileIds;
  int64_t fileSize;
  NSString *format;
  NSString *type;
  NSArray *tags;
  NSString *comment;
  BOOL downloaded;
  // BOOL isDownloading;
  int time;
  // cache
  NgTag *available;
  NgTag *complete;
  NgTag *bitRate;
  // BOOL isDownloadingInited;
  // BOOL isDownloading;
}

@property(assign) NSNumber *resultId;
@property int networkId;
@property(assign) NSArray *fileNames;
@property(assign) NSArray *fileIds;
@property int64_t fileSize;
@property(assign) NSString *format;
@property(assign) NSString *type;
@property(assign) NSArray *tags;
@property(assign) NSString *comment;
@property BOOL downloaded;
@property(readonly) BOOL isDownloading;
@property int time;
@property(readonly) NSString *fileName;

- (NSColor *)color;

@end
