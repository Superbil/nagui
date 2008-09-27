//
//  NgSharedFile.h
//  Nagui
//
//  Created by Appledelhi on 08. 08. 31.
//  Copyright 2008 Appledelhi. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NgSharedFile : NSObject {
  NSNumber *fileId;
  NSString *fileName;
  int64_t fileSize;
}

@property(assign) NSNumber *fileId;
@property(assign) NSString *fileName;
@property int64_t fileSize;

@end
