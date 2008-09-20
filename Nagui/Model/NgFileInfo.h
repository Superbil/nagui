//
//  NgFileInfo.h
//  Nagui
//
//  Created by Appledelhi on 08. 08. 28.
//  Copyright 2008 Appledelhi. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NgFileInfo : NSObject {
  int fileId;
  NSArray *fileNames;
  NSString *fileName;
  NSData *md4;
  int64_t fileSize;
  int64_t downloadedSize;
  float downloadSpeed;
  NSData *chunks;
  NSData *availability;

  // image cache
  float oldWidth;
  NSData *oldChunks;
  NSData *oldAvail;
  NSImage *image;
}

@property int fileId;
@property(assign) NSArray *fileNames;
@property(assign) NSString *fileName;
@property(assign) NSData *md4;
@property int64_t fileSize;
@property int64_t downloadedSize;
@property float downloadSpeed;
@property(assign) NSData *chunks;
@property(assign) NSData *availability;

@end
