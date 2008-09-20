//
//  NgTransferManager.m
//  Nagui
//
//  Created by Appledelhi on 08. 08. 28.
//  Copyright 2008 Appledelhi. All rights reserved.
//

#import "NgTransferManager.h"
#import "NgFileInfo.h"
#import "Nagui.h"
#import "NgProtocolHandler.h"
#import "NgSharedFile.h"
#import "NgClientInfo.h"
#import "NgHostState.h"
#import "NgSearchManager.h"
#import "NgOption.h"
#import "NSObjectControllerExt.h"

@implementation NgTransferManager

@synthesize downloads;
@synthesize uploads;
//@synthesize sharedFiles;
//@synthesize shares;
//@synthesize downloadRate;
@synthesize downloadCritical;
@synthesize downloadWarning;
//@synthesize uploadRate;
@synthesize uploadCritical;
@synthesize uploadWarning;

- (void)awakeFromNib
{
  downloads = [NSMutableArray arrayWithCapacity:20];
  uploads = [NSMutableArray arrayWithCapacity:20];
  fileInfos = [NSMutableDictionary dictionaryWithCapacity:40];
  fileMd4s = [NSMutableDictionary dictionaryWithCapacity:40];
//  sharedFiles = [NSMutableArray arrayWithCapacity:1000];
  shares = [NSMutableArray arrayWithCapacity:1000];
  clients = [NSMutableDictionary dictionaryWithCapacity:100];
//  downloadMax = 100000;
//  uploadMin = 0;
//  uploadMax = 50000;
//  uploadCritical = uploadMax * 9/10;
//  uploadWarning = uploadMax * 7/10;
}

- (void)addFileInfo:(NgFileInfo *)fileInfo
{
  [fileInfos setObject:fileInfo forKey:[NSNumber numberWithInt:fileInfo.fileId]];
  [fileMd4s setObject:fileInfo forKey:fileInfo.md4];
}

- (void)updateDownload:(int)fileId downloaded:(int64_t)downloaded speed:(float)speed
{
  NgFileInfo *fileInfo = [fileInfos objectForKey:[NSNumber numberWithInt:fileId]];
  if (fileInfo) {
    fileInfo.downloadedSize = downloaded;
    fileInfo.downloadSpeed = speed;
    [self addDownload: fileInfo];
  }
}

- (void)addDownload:(NgFileInfo *)fileInfo
{
  NSUInteger index = [downloads indexOfObject:fileInfo];
  [fileMd4s setObject:fileInfo forKey:fileInfo.md4];
  [self willChangeValueForKey:@"downloads"];
  if (index == NSNotFound) {
    [downloads addObject:fileInfo];
    [nagui.searchManager refresh];
  } else {
    [downloads replaceObjectAtIndex:index withObject:fileInfo];
  }
  // NSLog(@"downloads %@", fileInfo.md4);
  [self didChangeValueForKey:@"downloads"];
}

- (void)addPending:(int)fileId
{
  [self addDownload: [fileInfos objectForKey:[NSNumber numberWithInt:fileId]]];
}

- (BOOL)isDownloading:(NSArray *)md4s
{
  for (NSData *md4 in md4s) {
    for (NgFileInfo *fi in downloads) {
      if ([md4 isEqualToData:fi.md4]) {
        return YES;
      }
    }
  }
  return NO;
}

- (BOOL)isDownloaded:(NSArray *)md4s
{
  for (NSData *md4 in md4s) {
    if ([fileMd4s objectForKey:md4]) {
      return YES;
    }
  }
  return NO;
}

- (IBAction)cancelDownload:sender
{
  NgFileInfo *f = [downloadController selectedObject];
  if (f) {
    [nagui.protocolHandler sendRemoveDownload:f.fileId];
    [downloadController removeObject:f];
    [fileInfos removeObjectForKey:[NSNumber numberWithInt:f.fileId]];
    [fileMd4s removeObjectForKey:f.md4];
  }
}

- (IBAction)clear:sender
{
  NSMutableArray *new = [NSMutableArray arrayWithCapacity:[downloads count]];
  for (NgFileInfo *fi in downloads) {
    if (fi.downloadedSize < fi.fileSize) {
      [new addObject:fi];
    }
  }
  self.downloads = new;
}

//- (void)addSharedFile:(NgSharedFile *)sharedFile
//{
//  [self willChangeValueForKey:@"sharedFiles"];
//  [sharedFiles addObject:sharedFile];
//  [self didChangeValueForKey:@"sharedFiles"];
//}

- (void)updateClient:(NgClientInfo *)clientInfo
{
  int s = clientInfo.state.state;
  // 0:not connected, 1:connecting, 6:new host, 7:remove host, 8:black listed, 9:not connected
  BOOL remove = (s == 0 || s == 7 || s == 8 || s == 9);
  if (remove) {
    [clients removeObjectForKey:[NSNumber numberWithInt:clientInfo.clientId]];
  } else {
    [clients setObject:clientInfo forKey:[NSNumber numberWithInt:clientInfo.clientId]];
  }
//  NSLog(@"clients = %d", [clients count]);
}

- (NSArray *)clientsOf:(NSArray *)clientIds color:(NSColor *)color
{
  NSMutableArray *array = [NSMutableArray arrayWithCapacity:20];
  for (NSNumber *cid in clientIds) {
    NgClientInfo *client = [clients objectForKey:cid];
    if (client) {
      client.color = color;
      [array addObject:client];
    } else {
//      NSLog(@"didn't find client %@", cid);
    }
  }
  return array;
}

- (void)setUploaders:(NSArray *)clientIds
{
  uploading = [self clientsOf:clientIds color:[NSColor blackColor]];
}

- (void)setPending:(NSArray *)clientIds
{
  NSArray *pending = [self clientsOf:clientIds color:[NSColor grayColor]];
  self.uploads = [uploading arrayByAddingObjectsFromArray:pending];
}

- (void)client:(int)clientId message:(NSString *)msg
{
  NgClientInfo *client = [clients objectForKey:[NSNumber numberWithInt:clientId]];
  [nagui log:@"%@:%@", client.name, msg];
}

- (BOOL)validateUserInterfaceItem:(id <NSValidatedUserInterfaceItem>)item
{
  if (nagui.currentManager == self) {
    return YES;
  }
  return NO;
}

- (int)uploadRate
{
  return uploadRate;
}

- (void)setUploadRate:(int)rate
{
  uploadRate = rate;
  if (rate < uploadMax * 1/3) {
    self.uploadCritical = 2;
    self.uploadWarning = 1;
  } else if (rate < uploadMax * 2/3) {
    self.uploadCritical = INT_MAX;
    self.uploadWarning = 1;
  } else {
    self.uploadCritical = INT_MAX;
    self.uploadWarning = INT_MAX;
  }
}

- (int)downloadRate
{
  return downloadRate;
}

- (void)setDownloadRate:(int)rate
{
  downloadRate = rate;
  if (rate < downloadMax * 1/3) {
    self.downloadCritical = 2;
    self.downloadWarning = 1;
  } else if (rate < downloadMax * 2/3) {
    self.downloadCritical = INT_MAX;
    self.downloadWarning = 1;
  } else {
    self.downloadCritical = INT_MAX;
    self.downloadWarning = INT_MAX;
  }
}

- (void)setLimits:(NgOption *)option
{
  if ([option.name isEqualToString:@"max_hard_upload_rate"]) {
    uploadMax = [option.value intValue] * 1000;
//    self.uploadCritical = uploadMax * 9/10;
//    uploadWarning = uploadMax * 7/10;
  } else if ([option.name isEqualToString:@"max_hard_download_rate"]) {
    downloadMax = [option.value intValue] * 1000;
//    self.downloadCritical = downloadMax * 9/10;
//    downloadWarning = downloadMax * 7/10;
  }
}

@end
