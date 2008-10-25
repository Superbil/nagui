//
//  NgMovingTask.m
//  Nagui
//
//  Created by Appledelhi on 08. 09. 15.
//  Copyright 2008 Appledelhi. All rights reserved.
//

#import "NgMovingTask.h"
#import "NSStringExt.h"
#import "Nagui.h"
#import "NgTaskManager.h"
#import "NgShareManager.h"

@implementation NgMovingTask

@synthesize indicator;

- initSource:(NSString *)s dest:(NSString *)d
{
  source = s;
  dest = d;
  return self;
}

- copyWithZone:(NSZone *)zone
{
  return NSCopyObject(self, 0, zone);;
}

- (BOOL)isEqual:other
{
  return self == other;
}

- (void)updateStatus:(NSDictionary *)status stage:(FSFileOperationStage)stage error:(OSStatus)error
{
  if (error) {
    [nagui error:error];
  } else {
    NSNumber *bytes = [status objectForKey:(NSString *)kFSOperationBytesCompleteKey];
    int64_t bytesCopied = [bytes longLongValue];
    [indicator setDoubleValue:bytesCopied];
//    NSLog(@"%lld %lld", bytesCopied, size);
  }
  if (stage == kFSOperationStageComplete) {
    if (!error) {
      NSError *err = nil;
      [[NSFileManager defaultManager] removeItemAtPath:source error:&err];
      
//      if (err) {
//        [nagui alert:[NSString stringWithFormat:@"Can't remove '%@'", [source lastPathComponent]]
//         informative:@""];
//      }
    }
    [indicator removeFromSuperview];
    [nagui.taskManager removeTask:self];
  }
}

static void statusCallback(FSFileOperationRef fileOp, const char *currentItem, FSFileOperationStage stage,
                           OSStatus error, CFDictionaryRef statusDictionary, void *info)
{
  NgMovingTask *task = info;
  [task updateStatus:(NSDictionary *)statusDictionary stage:stage error:error];
}

- (void)thread:arg
{
  if ([source isSameDir:dest]) {
    return;
  }
  NSDictionary *attrs = [[NSFileManager defaultManager] fileAttributesAtPath:source traverseLink:YES];
  size = [[attrs objectForKey:NSFileSize] longLongValue];

  FSFileOperationRef fileOp = FSFileOperationCreate(kCFAllocatorDefault);
  OSStatus status = FSFileOperationScheduleWithRunLoop(fileOp, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);

  FSFileOperationClientContext context;
  context.version = 0;
  context.info = self;
  context.retain = nil;
  context.release = nil;
  context.copyDescription = nil;
  
  status = FSPathMoveObjectAsync(fileOp, [source fileSystemRepresentation], [dest fileSystemRepresentation], NULL,
                                 kFSFileOperationDefaultOptions, statusCallback, 0.5, &context);
  if (status) {
    NSLog(@"error %d", status);
  }
  CFRelease(fileOp);
}

- (void)start
{
  [self thread:nil];
//  [NSThread detachNewThreadSelector:@selector(thread:) toTarget:self
//                         withObject:self];
}

- (NSString *)description
{
  NSString *sourceName = [source lastPathComponent];
  NSString *destName = [dest lastPathComponent];
  return [NSString stringWithFormat:@"Moving '%@' to '%@'", sourceName, destName];
}

- (void)makeIndicator:(NSRect)rect view:(NSView *)view
{
  indicator = [[NSProgressIndicator alloc] initWithFrame:rect];
  [indicator setIndeterminate:NO];
  [indicator setMaxValue:size];
  [indicator startAnimation:self];
  [view addSubview:indicator];
}

@end
