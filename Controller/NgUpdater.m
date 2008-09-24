//
//  NgUpdater.m
//  Nagui
//
//  Created by Jake Song on 08. 09. 25.
//  Copyright 2008 XL Games. All rights reserved.
//

#import "NgUpdater.h"


@implementation NgUpdater

- (void)checkUpdate
{
  [NSThread detachNewThreadSelector:@selector(checkUpdateThread) toTarget:self withObject:nil];
}

- (void)checkUpdateThread
{
  NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://code.google.com/p/nagui-cocoa/downloads/list"]
                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                       timeoutInterval:60.0];
  NSURLResponse *response;
  NSError *error;
  NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
  NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
  NSScanner *scanner = [NSScanner scannerWithString:str];
  [scanner scanUpToString:@"Nagui.r" intoString:nil];
  [scanner scanString:@"Nagui.r" intoString:nil];
  [scanner scanInteger:&version];
  [self performSelectorOnMainThread:@selector(gotVersion) withObject:nil waitUntilDone:NO];
//  connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
//  if (connection) {
//    //[connection start];
//    //[connection scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
//  } else {
//    NSLog(@"error");
//  }
}

- (void)gotVersion
{
  NSBundle *bundle = [NSBundle mainBundle];
  NSString *verStr = [[bundle infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey];
  int currentVer = [[verStr substringFromIndex:1] intValue];
  if (version > currentVer) {
    NSAlert *alert = [NSAlert alertWithMessageText:@"New version available." 
                                     defaultButton:@"Go to web site"
                                   alternateButton:@"Cancel"
                                       otherButton:nil
                         informativeTextWithFormat:@""];
    int result = [alert runModal];
    if (result == NSAlertDefaultReturn) {
      [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://code.google.com/p/nagui-cocoa/"]];
    }
  }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
  NSLog(@"response %@", response);
  [received setLength:0];
}

- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request
            redirectResponse:(NSURLResponse *)redirectResponse
{
  NSLog(@"redirect request %@ response %@", request, redirectResponse);
  return request;
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
  NSLog(@"auth");
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
  NSLog(@"data");
  [received appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
  NSLog(@"Error %@", [error localizedDescription]);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
  NSLog(@"received %@", received);
}

@end
