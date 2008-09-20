//
//  NgTaskManager.m
//  Nagui
//
//  Created by Appledelhi on 08. 09. 15.
//  Copyright 2008 Appledelhi. All rights reserved.
//

#import "NgTaskManager.h"
#import "NgMovingTask.h"

@implementation NgTaskManager

- (void)awakeFromNib
{
  tasks = [NSMutableArray arrayWithCapacity:5];
}

- (void)addTask:(NgMovingTask *)task
{
  [statusWindow orderFront:self];
  [task start];
  [self willChangeValueForKey:@"tasks"];
  [tasks addObject:task];
  [self didChangeValueForKey:@"tasks"];
}

- (void)removeTask:(NgMovingTask *)task
{
  [self willChangeValueForKey:@"tasks"];
  [tasks removeObject:task];
  [self didChangeValueForKey:@"tasks"];
  [[NSSound soundNamed:@"Glass"] play];
  if ([tasks count] == 0) {
    [statusWindow orderOut:self];
  }
}

- (void)tableView:(NSTableView *)view willDisplayCell:cell forTableColumn:(NSTableColumn *)column row:(NSInteger)row
{
  NgMovingTask *task = [tasks objectAtIndex:row];
  NSRect rect = [view rectOfRow:row];
  rect.origin.x += 16;
  rect.origin.y += 25;
  rect.size.width -= 32;
  rect.size.height = 16;
  if (!task.indicator) {
    [task makeIndicator:rect view:view];
  } else {
    [task.indicator setFrame:rect];
  }
}

@end
