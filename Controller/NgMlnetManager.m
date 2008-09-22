//
//  NgMlnetManager.m
//  Nagui
//
//  Created by Appledelhi on 08. 09. 10.
//  Copyright 2008 Appledelhi. All rights reserved.
//

#import "NgMlnetManager.h"
#import "Nagui.h"
#import "NgProtocolHandler.h"
#import "Util.h"

@implementation NgMlnetManager

+ (void)initialize
{
  NSDictionary *defaults = [NSDictionary dictionaryWithObjectsAndKeys:
                            [NSNumber numberWithBool:YES], @"mlnetAutoStart",
                            [NSNumber numberWithBool:YES], @"mlnetAutoConnect",
                            @"localhost", @"mlnetHost",
                            @"4001", @"mlnetPort",
                            nil];
  [[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
}

- (int)mlnetPid
{
  NSFileHandle *outputPipe;
  launch(&outputPipe, nil, @"/bin/ps", @"-axc", nil);
  NSData *outputData = [outputPipe readDataToEndOfFile];
  NSString *output = [[NSString alloc] initWithData:outputData encoding:NSUTF8StringEncoding];
  NSArray *lines = [output componentsSeparatedByString:@"\n"];
  for (NSString *line in lines) {
    if (contains(line, @"mlnet")) {
      return [line intValue];
    }
  }
  return 0;
}

- (void)autoStart
{
  if ([self mlnetPid] == 0) {
    if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"mlnetAutoStart"] boolValue]) {
      [self startMlnet:self];
    }
  } else {
    if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"mlnetAutoConnect"] boolValue]) {
      [self connectMlnet:self];
    }
  }
}

- (void)autoQuit
{
  if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"mlnetAutoQuit"] boolValue]) {
    [self stopMlnet:self];
  }
}
- (IBAction)chooseMlnetPath:sender
{
  NSOpenPanel *panel = [NSOpenPanel openPanel];
  NSArray *types = [NSArray arrayWithObject:@""];
  NSString *homeFolder = [@"~" stringByExpandingTildeInPath];
  [panel beginSheetForDirectory:homeFolder file:@"mlnet" types:types modalForWindow:[nagui window] modalDelegate:self
                 didEndSelector:@selector(choosePanelDidEnd:returnCode:contextInfo:) contextInfo:nil];
}

- (void)choosePanelDidEnd:(NSOpenPanel *)panel returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
  if (returnCode == NSOKButton) {
    [[NSUserDefaults standardUserDefaults] setValue:[panel filename] forKey:@"mlnetPath"];
  }
}

- (void)mlnetOutput:(NSNotification *)notification
{
  NSData *data = [[notification userInfo] valueForKey:NSFileHandleNotificationDataItem];
  NSString *msg = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
  [nagui log:@"%@", msg];
  [mlnetOutput readInBackgroundAndNotify];
  
  if (contains(msg, @"Core started")) {
    if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"mlnetAutoConnect"] boolValue]) {
      [self connectMlnet:self];
    } 
  }
}

- (IBAction)startMlnet:sender
{
  NSString *mlnetPath;
  if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"mlnetExternal"] boolValue]) {
    mlnetPath = [[NSUserDefaults standardUserDefaults] valueForKey:@"mlnetPath"];
  } else {
    mlnetPath = [[NSBundle mainBundle] pathForResource:@"mlnet" ofType:@""];
  }
  [nagui log:@"Starting mlnet (%@)...\n", mlnetPath];
  mlnet = launch(nil, &mlnetOutput, mlnetPath, nil);
  [mlnetOutput readInBackgroundAndNotify];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mlnetOutput:)
                                               name:NSFileHandleReadCompletionNotification object:mlnetOutput];
}

- (IBAction)stopMlnet:sender
{
//  if (mlnet) {
//    [mlnet terminate];
//    [mlnet waitUntilExit];
//    mlnet = nil;
//  } else {
    int pid = [self mlnetPid];
    if (pid) {
      kill(pid, 15);
    }
//  }
}

- (IBAction)connectMlnet:sender
{
  if ([nagui.protocolHandler status] == NgDisconnected) {
    NSString *hostStr = [[NSUserDefaults standardUserDefaults] valueForKey:@"mlnetHost"];
    NSHost *host = [NSHost hostWithName:hostStr];
    NSArray *addresses = [host addresses];
    if (addresses.count > 1) {
      // choose ipv4
      for (NSString *address in addresses) {
        if (!contains(address, @"::")) {
          host = [NSHost hostWithAddress:address];
        }
      }
    }
    int port = [[[NSUserDefaults standardUserDefaults] valueForKey:@"mlnetPort"] intValue];
    [nagui log:@"Connecting mlnet at %@(%@:%d)\n", hostStr, host.address, port];
    [nagui.protocolHandler connectHost:host port:port];
  }
}

- (BOOL)validateUserInterfaceItem:item
{
  int tag = [item tag];
  if (tag == 0 && [self mlnetPid]) {
    return NO;
  }
  if (tag == 1 && [self mlnetPid] == 0) {
    return NO;
  }
  if (tag == 2 && nagui.protocolHandler.status != NgDisconnected) {
    return NO;
  }
  return YES;
}

@end
