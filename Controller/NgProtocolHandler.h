//
//  NGProtocolHandler.h
//  Nagui
//
//  Created by Appledelhi on 08. 08. 24.
//  Copyright 2008 Appledelhi. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class NgReadBuffer;
@class NgWriteBuffer;
@class NgSearch;
@class NgQuery;

enum {
  NgDisconnected = 0,
  NgConnecting = 1,
  NgConnected = 2
};
  
@interface NgProtocolHandler : NSObject {
  NgReadBuffer *readBuffer;
  NgWriteBuffer *writeBuffer;
  BOOL writable;
  int status;
}

@property(readonly) NgWriteBuffer *writeBuffer;
@property(readonly) int status;

- (void)connectHost:(NSHost *)host port:(int)port;

- (void)sendProtocolVersion:(int)ver;
- (void)sendPassword:(NSString *)password login:(NSString *)login;
- (void)sendSearch:(int)searchId query:(NgQuery *)keyword;
- (void)sendCloseSearch:(int)searchId;
- (void)sendExtendSearch;
- (void)sendDownload:(NSArray*)fileNames resultId:(NSNumber *)resultId;
- (void)sendGetDownloadingFiles;
- (void)sendGetDownloadedFiles;
- (void)sendRemoveDownload:(NSNumber *)fileId;
- (void)sendGetUploaders;
- (void)sendSetOption:(NSString *)option value:(NSString *)value;
- (void)sendCommand:(NSString *)command;
- (void)sendGetSearches;

@end
