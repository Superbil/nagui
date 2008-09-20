//
//  NgMovingTask.h
//  Nagui
//
//  Created by Appledelhi on 08. 09. 15.
//  Copyright 2008 Appledelhi. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NgMovingTask : NSObject {
  NSString *source;
  NSString *dest;
  uint64_t size;
  NSProgressIndicator *indicator;
}

@property(assign) NSProgressIndicator *indicator;

- initSource:(NSString *)sourcePath dest:(NSString *)destPath;
- (void)start;
- (void)makeIndicator:(NSRect)rect view:(NSView *)view;

@end
