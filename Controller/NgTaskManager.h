//
//  NgTaskManager.h
//  Nagui
//
//  Created by Appledelhi on 08. 09. 15.
//  Copyright 2008 Appledelhi. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class NgMovingTask;

@interface NgTaskManager : NSObject {
  IBOutlet NSWindow *statusWindow;

  NSMutableArray *tasks;
}

- (void)addTask:(NgMovingTask *)task;
- (void)removeTask:(NgMovingTask *)task;

@end
