//
//  NgTransferManager.h
//  Nagui
//
//  Created by Appledelhi on 08. 08. 28.
//  Copyright 2008 Appledelhi. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class NgFileInfo;
@class NgSharedFile;
@class NgClientInfo;
@class NgOption;

@interface NgTransferManager : NSObject {
  IBOutlet id downloadController;
  NSMutableArray *downloads;
  NSArray *uploads;
  NSArray *uploading;
  NSMutableDictionary *fileInfos;   // key = fileId
//  NSMutableArray *sharedFiles;
//  NSMutableArray *shares;
  NSMutableDictionary *clients;
  int downloadRate;
  int uploadRate;
  int downloadMax;
  int downloadMin;
  int downloadCritical;
  int downloadWarning;
  int uploadMax;
  int uploadMin;
  int uploadCritical;
  int uploadWarning;
}

@property(assign) NSMutableArray *downloads;
@property(assign) NSArray *uploads;
//@property(assign) NSMutableArray *sharedFiles;
@property int downloadRate;
@property int downloadCritical;
@property int downloadWarning;
@property int uploadRate;
@property int uploadCritical;
@property int uploadWarning;

- (IBAction)cancelDownload:sender;
- (IBAction)clear:sender;

- (void)addFileInfo:(NgFileInfo *)fileInfo;
- (void)updateDownload:(NSNumber *)fileId downloaded:(int64_t)downloaded speed:(float)speed;
- (void)addDownload:(NgFileInfo *)fileInfo;
//- (void)addPending:(int)fileId;
- (BOOL)isDownloading:(NSArray *)fileIds;
//- (void)addSharedFile:(NgSharedFile *)sharedFile;

- (void)updateClient:(NgClientInfo *)clientInfo;
- (void)client:(int)clientId  message:(NSString *)msg;
- (void)setUploaders:(NSArray *)clientIds;
- (void)setPending:(NSArray *)clientIds;

- (void)setLimits:(NgOption *)option;

@end
