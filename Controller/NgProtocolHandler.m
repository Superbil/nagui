//
//  NGProtocolHandler.m
//  Nagui
//
//  Created by Appledelhi on 08. 08. 24.
//  Copyright 2008 Appledelhi. All rights reserved.
//

#import "NgProtocolHandler.h"
#import "NgReadBuffer.h"
#import "NgWriteBuffer.h"
#import "Nagui.h"
#import "NgQuery.h"
#import "NgResult.h"
#import "NgSearchManager.h"
#import "NgFileInfo.h"
#import "NgTransferManager.h"
#import "NgSharedFile.h"
#import "NgClientInfo.h"
#import "NgServerInfo.h"
#import "NgAddr.h"
#import "NgOption.h"
#import "NgOptionManager.h"
#import "NgFolderManager.h"
#import "Util.h"

@implementation NgProtocolHandler

@synthesize writeBuffer;
@synthesize status;

- (void)connectHost:(NSHost *)host port:(int)port
{
  NSInputStream *inputStream = nil;
  NSOutputStream *outputStream = nil;
  [NSStream getStreamsToHost:host port:port inputStream:&inputStream outputStream:&outputStream];
  [inputStream setDelegate:self];
  [outputStream setDelegate:self];
  [inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
  [outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
  [inputStream open];
  [outputStream open];
  readBuffer = [[NgReadBuffer alloc] initStream:inputStream];
  writeBuffer = [[NgWriteBuffer alloc] initStream:outputStream];
  status = NgConnecting;
}

- (void)coreProtocol
{
  status = NgConnected;
  [readBuffer getInt];  // max protocol
  [readBuffer getInt];  // max op code
  [readBuffer getInt];  // max op code accepted
//  [nagui log:@"protocol = %d opcode = %d accepted = %d\n", maxProtocol, maxOpcode, maxOpcodeAccepted];
  [self sendProtocolVersion: 41];
  [self sendPassword: @"" login: @"admin"];
  [self sendGetDownloadingFiles];
  [self sendGetDownloadedFiles];
  [self sendCommand:@"shares"];
}

- (void)networkInfoProtocol
{
  //  int networkId = [readBuffer getInt];
  //  NSString *networkName = [readBuffer getString];
  //  BOOL enabled = [readBuffer getInt8];
  //  NSString *configFile = [readBuffer getString];
  //[self log:@"network id = %d name = %@ enabled = %d config = %@\n", networkId, networkName, enabled, configFile];
}

- (void)sharedFileInfoProtocol
{
  // NgSharedFile *sharedFile = [[NgSharedFile alloc] init];
  // sharedFile.fileId = [readBuffer getInt];  // shared file id
  // [readBuffer getInt];  // network id
  // sharedFile.fileName = [readBuffer getString];   // file name
  // sharedFile.fileSize = [readBuffer getInt64];    // file size
  // [readBuffer getInt64];    // bytes uploaded
  // [readBuffer getInt];      // requests
  // [nagui.transferManager addSharedFile:sharedFile];
}

- (void)removeFileSourceProtocol
{
}

- (void)addSectionOptionProtocol
{
  NgOption *option = [[NgOption alloc] init];
  option.section = [readBuffer getString];
  option.description = [readBuffer getString];
  option.name = [readBuffer getString];
  option.type = [readBuffer getString];
  option.help = [readBuffer getString];
  option.value = [readBuffer getString];
  option.defaultValue = [readBuffer getString];
  option.advanced = [readBuffer getInt8];
  [nagui.optionManager addOption:option];
  [nagui.transferManager setLimits:option];
}

- (void)addPluginOptionProtocol
{
  NgOption *option = [[NgOption alloc] init];
  option.section = [readBuffer getString];
  option.description = [readBuffer getString];
  option.name = [readBuffer getString];
  option.type = [readBuffer getString];
  option.help = [readBuffer getString];
  option.value = [readBuffer getString];
  option.defaultValue = [readBuffer getString];
  option.advanced = [readBuffer getInt8];
  [nagui.optionManager addOption:option];
}

- (void)consoleMessageProtocol
{
  NSString *msg = [readBuffer getString];
  if (contains(msg, @"Eval command: shares")) {
    [nagui.shareManager parseSharedFolders:msg];
  }
  [nagui log:@"%@", msg];
}

- (void)clientInfoProtocol
{
  NgClientInfo *clientInfo = [[NgClientInfo alloc] init];
  clientInfo.clientId = [readBuffer getIntNumber];  // client id
  [readBuffer getInt];  // network id
  [readBuffer getClientKind];
  clientInfo.state = [readBuffer getState];  // connection state
  [readBuffer getInt8];   // client type
  [readBuffer getTagList];  // metadata
  clientInfo.name = [readBuffer getString];   // name
  [readBuffer getInt];      // rating
  [readBuffer getString];   // software
  clientInfo.downloaded = [readBuffer getInt64];    // downloaded
  clientInfo.uploaded = [readBuffer getInt64];    // uploaded
  clientInfo.fileName = [readBuffer getString];   // upload filename
  [readBuffer getInt];      // connect time
  [readBuffer getString];   // emule mod
  [readBuffer getString];   // release version
  [readBuffer getInt8];     // sui verified
  [nagui.transferManager updateClient:clientInfo];
}

- (void)clientStatsProtocol
{
  [readBuffer getInt64];  // total uploaded
  [readBuffer getInt64];  // total downloaded
  [readBuffer getInt64];  // total shared
  [readBuffer getInt];    // number of shared files
  int tcpUp = [readBuffer getInt];    // tcp upload rate
  int tcpDown = [readBuffer getInt];    // tcp download rate
  int udpUp = [readBuffer getInt];    // udp upload rate
  int udpDown = [readBuffer getInt];    // udp download rate
  [readBuffer getInt];    // number of current downloads
  [readBuffer getInt];    // number of downloads finished
  int count = [readBuffer getInt16];
  while (count-- > 0) {
    [readBuffer getInt];  // network id
    [readBuffer getInt];  // number of connected servers
  }
//  [nagui setValue:[NSString stringWithFormat:@"Download: %d", tcpDown + udpDown] forKey:@"downloadRate"];
  nagui.transferManager.downloadRate = tcpDown + udpDown;
  nagui.transferManager.uploadRate = tcpUp + udpUp;
}

- (void)fileInfoProtocol
{
  NgFileInfo *fileInfo = [readBuffer getFileInfo];
  // NSLog(@"%@",fileInfo.fileName);
  [nagui.transferManager addFileInfo:fileInfo];
}

- (void)serverInfoProtocol
{
  NgServerInfo *serverInfo = [[NgServerInfo alloc] init];
  serverInfo.serverId = [readBuffer getInt];  // server id
  [readBuffer getInt];  // network id
  serverInfo.addr = [readBuffer getAddr]; // internet addr
  serverInfo.addr.inetPort = [readBuffer getInt16];  // server port
  [readBuffer getInt];    // server score
  [readBuffer getTagList];  // meta data
  serverInfo.users = [readBuffer getInt64];    // number of user
  serverInfo.files = [readBuffer getInt64];    // number of files
  serverInfo.state = [readBuffer getState];  // connection state
  serverInfo.name = [readBuffer getString];     // server name
  serverInfo.description = [readBuffer getString];     // server description
  [readBuffer getInt8];       // preferred
  [readBuffer getString];     // server version
  [readBuffer getInt64];      // max users
  [readBuffer getInt64];      // low id users
  [readBuffer getInt64];      // soft limit
  [readBuffer getInt64];      // hard limit
  serverInfo.ping = [readBuffer getInt];        // ping
  [nagui.serverManager add:serverInfo];
}

- (void)optionsInfoProtocol
{
//  int count = [readBuffer getInt16];
//  while (count-- > 0) {
//    NSString *option = [readBuffer getString];
//    NSString *value = [readBuffer getString];
//    [nagui.optionManager addOption:option value:value];
//  }
}

- (void)defineSearchesProtocol
{
  int count = [readBuffer getInt16];
  while (count-- > 0) {
    [readBuffer getString];   // search name
    [readBuffer getQuery];    // query
    // [nagui log:@"define search = %@ query = %@\n", str, [query description]];
  }
}

- (void)roomInfoProtocol
{
}

- (void)fileAddSourceProtocol
{
}

- (void)cleanTablesProtocol
{
}

- (void)searchResultProtocol
{
  int searchId = [readBuffer getInt];
  NSNumber *resultId = [readBuffer getIntNumber];
  [nagui.searchManager associateResult:resultId toSearch:searchId];
}

- (void)searchWaitingProtocol
{
  [readBuffer getInt];  // search number?
  [readBuffer getInt];  // number of waiting?
}

- (void)resultInfoProtocol
{
  NgResult *result = [[NgResult alloc] init];
  result.resultId = [readBuffer getIntNumber];
  result.networkId = [readBuffer getInt];
  result.fileNames = [readBuffer getStringList];
  result.fileIds = md4sFromStrings([readBuffer getStringList]);
  result.fileSize = [readBuffer getInt64];
  result.format = [readBuffer getString];
  result.type = [readBuffer getString];
  result.tags = [readBuffer getTagList];
  result.comment = [readBuffer getString];
  result.downloaded = [readBuffer getInt8];
  result.time = [readBuffer getInt];
  [nagui.searchManager addResult:result];
}

- (void)clientStateProtocol
{
}

- (void)fileUpdateAvailabilityProtocol
{
  
}

- (void)fileDownloadUpdateProtocol
{
  NSNumber *fileId = [readBuffer getIntNumber];
  int64_t downloaded = [readBuffer getInt64];
  float speed = [readBuffer getFloat];
  [readBuffer getInt];
  [nagui.transferManager updateDownload:fileId downloaded:downloaded speed:speed];
}

- (void)downloadingFilesProtocol
{
  int count = [readBuffer getInt16];
  while (count-- > 0) {
    NgFileInfo *fileInfo = [readBuffer getFileInfo];
    [nagui.transferManager addDownload:fileInfo];
  }
}

- (void)downloadedFilesProtocol
{
  int count = [readBuffer getInt16];
  while (count-- > 0) {
    NgFileInfo *fileInfo = [readBuffer getFileInfo];
    [nagui.transferManager addDownload:fileInfo];
  }
}

- (void)pendingProtocol
{
  int count = [readBuffer getInt16];
  NSMutableArray *array = [NSMutableArray arrayWithCapacity:count];
  while (count-- > 0) {
    [array addObject:[readBuffer getIntNumber]];  // client id
  }
  [nagui.transferManager setPending:array];
}

- (void)statsProtocol
{
}

- (void)uploadersProtocol
{
  int count = [readBuffer getInt16];
  NSMutableArray *array = [NSMutableArray arrayWithCapacity:count];
  while (count-- > 0) {
    [array addObject:[readBuffer getIntNumber]];
  }
  [nagui.transferManager setUploaders:array];
}

- (void)messageFromClientProtocol
{
  int clientId = [readBuffer getInt];  // client id
  NSString *msg = [readBuffer getString];
  [nagui.transferManager client:clientId message:msg];
}

- (void)processPacket
{
  int op = [readBuffer getInt16];
  // NSLog(@"op = %d", op);
  switch (op) {
    case 0:
      [self coreProtocol];
      break;
    case 1:
      [self optionsInfoProtocol];
      break;
    case 3:
      [self defineSearchesProtocol];
      break;
    case 4:
      [self resultInfoProtocol];
      break;
    case 5:
      [self searchResultProtocol];
      break;
    case 6:
      [self searchWaitingProtocol];
      break;
    case 9:
      [self fileUpdateAvailabilityProtocol];
      break;
    case 10:
      [self fileAddSourceProtocol];
      break;
    case 15:
      [self clientInfoProtocol];
      break;
    case 16:
      [self clientStateProtocol];
      break;
    case 19:
      [self consoleMessageProtocol];
      break;
    case 20:
      [self networkInfoProtocol];
      break;
    case 26:
      [self serverInfoProtocol];
      break;
    case 27:
      [self messageFromClientProtocol];
      break;
    case 31:
      [self roomInfoProtocol];
      break;
    case 36:
      [self addSectionOptionProtocol];
      break;
    case 38:
      [self addPluginOptionProtocol];
      break;
    case 46:
      [self fileDownloadUpdateProtocol];
      break;
    case 48:
      [self sharedFileInfoProtocol];
      break;
    case 49:
      [self clientStatsProtocol];
      break;
    case 50:
      [self removeFileSourceProtocol];
      break;
    case 51:
      [self cleanTablesProtocol];
      break;
    case 52:
      [self fileInfoProtocol];
      break;
    case 53:
      [self downloadingFilesProtocol];
      break;
    case 54:
      [self downloadedFilesProtocol];
      break;
    case 55:
      [self uploadersProtocol];
      break;
    case 56:
      [self pendingProtocol];
      break;
    case 59:
      [self statsProtocol];
      break;
    default:
      [nagui log:@"unknown op = %d\n", op];
      break;
  }
}

- (void)readStream:(NSInputStream *)stream
{
  if ([readBuffer read]) {
    [self processPacket];
    [readBuffer reset];
  }
}

- (void)errorStream:(NSStream *)stream
{
  [nagui log:@"%@\n", [[stream streamError] localizedDescription]];
  status = NgDisconnected;
}

- (void)stream:(NSStream *)stream handleEvent:(NSStreamEvent)streamEvent
{
  switch (streamEvent) {
    case NSStreamEventOpenCompleted:
      // [nagui log:@"Open\n"];
      break;
    case NSStreamEventHasBytesAvailable:
      [self readStream:(NSInputStream *)stream];
      break;
    case NSStreamEventHasSpaceAvailable:
      writable = YES;
      break;
    case NSStreamEventErrorOccurred:
      [self errorStream:stream];
      break;
    default:
      [nagui log:@"Unknown Event\n"];
      break;
  }
}

- (void)sendProtocolVersion: (int)ver
{
  [writeBuffer putInt16: 0];
  [writeBuffer putInt: ver];
  [writeBuffer send];
}

- (void)sendPassword: (NSString *)password login: (NSString *)login
{
  [writeBuffer putInt16: 52];
  [writeBuffer putString: password];
  [writeBuffer putString: login];
  [writeBuffer send];
}

- (void)sendSearch: (int)searchId query: (NgQuery *)query
{
  [writeBuffer putInt16: 42];
  [writeBuffer putInt: searchId];
  [query writeTo: writeBuffer];
  [writeBuffer putInt: 1000];  // maximal number of results
  [writeBuffer putInt8: 1];    // search type = remote
  [writeBuffer putInt: 0];     // network = all
  [writeBuffer send];
}

- (void)sendCloseSearch:(int)searchId
{
  [writeBuffer putInt16:53];
  [writeBuffer putInt:searchId];
  [writeBuffer putInt8:1];  // forget search
  [writeBuffer send];
}

- (void)sendExtendSearch
{
  [writeBuffer putInt16:4];
  [writeBuffer send];
}

- (void)sendDownload:(NSArray *)fileNames resultId:(NSNumber *)resultId
{
  [writeBuffer putInt16:50];
  [writeBuffer putStringList:fileNames];
  [writeBuffer putInt:[resultId intValue]];
  [writeBuffer putInt8:0];
  [writeBuffer send];
}

- (void)sendGetDownloadingFiles
{
  [writeBuffer putInt16:45];
  [writeBuffer send];
}

- (void)sendGetDownloadedFiles
{
  [writeBuffer putInt16:46];
  [writeBuffer send];
}

- (void)sendRemoveDownload:(NSNumber *)fileId
{
  [writeBuffer putInt16:11];
  [writeBuffer putInt:[fileId intValue]];
}

- (void)sendGetUploaders
{
  [writeBuffer putInt16:57];
  [writeBuffer send];
  [writeBuffer putInt16:58];
  [writeBuffer send];
}

- (void)sendSetOption:(NSString *)option value:(NSString *)value
{
  [writeBuffer putInt16:28];
  [writeBuffer putString:option];
  [writeBuffer putString:value];
  [writeBuffer send];
}

- (void)sendCommand:(NSString *)command
{
  [writeBuffer putInt16:29];
  [writeBuffer putString:command];
  [writeBuffer send];
}

- (void)timer:timer
{
  if (writable) {
    [self sendGetUploaders];
  }
}

@end
