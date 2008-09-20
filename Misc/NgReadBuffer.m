//
//  NGReadBuffer.m
//  Nagui
//
//  Created by Appledelhi on 08. 08. 21.
//  Copyright 2008 Appledelhi. All rights reserved.
//

#import "NgReadBuffer.h"
#import "Util.h"
#import "Nagui.h"
#import "NgQuery.h"
#import "NgTag.h"
#import "NgAvailability.h"
#import "NgFileFormat.h"
#import "NgOggStream.h"
#import "NgOggStreamTag.h"
#import "NgSubfile.h"
#import "NgComment.h"
#import "NgFileInfo.h"
#import "NgClientKind.h"
#import "NgHostState.h"
#import "NgAddr.h"

@implementation NgReadBuffer

- initStream:inputStream
{
  stream = inputStream;
  buf = [NSMutableData dataWithCapacity:1024];
  [self reset];
  return self;
}

- (void)reset
{
  state = RS_LENGTH;
  toRead = 4;
  [buf setLength:4];
  head = [buf mutableBytes];
  tail = head;
}

- (uint8_t)getInt8
{
  if (head < tail) {
    return *head++;
  } else {
    return 0;
  }
}

- (int16_t)getInt16
{
  if (head + 2 <= tail) {
    int16_t v = OSReadLittleInt16(head, 0);
    head += 2;
    return v;
  } else {
    return 0;
  }
}

- (int)getInt
{
  if (head + 4 <= tail) {
    int v = OSReadLittleInt32(head, 0);
    head += 4;
    return v;
  } else {
    return 0;
  }
}

- (int64_t)getInt64
{
  if (head + 8 <= tail) {
    int64_t v = OSReadLittleInt64(head, 0);
    head += 8;
    return v;
  } else {
    return 0;
  }
}

- (NSString *)getString
{
  int len = [self getInt16];
  if (len > 0 && head + len <= tail) {
    NSString *str = [[NSString alloc] initWithBytes:head length:len encoding:NSUTF8StringEncoding];
    if (str == nil) {
      str = [[NSString alloc] initWithBytes:head length:len encoding:NSISOLatin1StringEncoding];
      if (str == nil) {
        str = @"unknown encoding";
        NSLog(@"nil string");
      }
    }
    head += len;
    return str;
  } else {
    return @"";
  }
}

- (NgQuery *)getQuery
{
  int type = [self getInt8];
  NgQuery *query = [[NgQuery alloc] initType:type];
  if (type == NgAnd || type == NgOr || type == NgHidden) { // AND, OR, Hidden
    int count = [self getInt16];
    while (count-- > 0) {
      [query append: [self getQuery]];
    }
  } else if (type == NgAndNot) { // ANDNOT
    [query append: [self getQuery]];
    [query append: [self getQuery]];
  } else if (type == NgModule) { // Module
    [query append: [self getString]];
    [query append: [self getQuery]];
  } else if (type >= NgKeyword && type <= NgBitRate) {
    [query append: [self getString]];
    [query append: [self getString]];
  }
  return query;
}

- (NSArray *)getStringList
{
  int count = [self getInt16];
  NSMutableArray *array = [NSMutableArray arrayWithCapacity:count];
  while (count-- > 0) {
    [array addObject:[self getString]];
  }
  return array;
}

- getTag
{
  NSString *name = [self getString];
  int intValue = 0;
  int intValue2 = 0;
  NSString *strValue = nil;
  int type = [self getInt8];
  switch (type) {
    case 0:
    case 1:
    case 3:
      intValue = [self getInt];
      break;
    case 2:
      strValue = [self getString];
      break;
    case 4:
      intValue = [self getInt16];
      break;
    case 5:
      intValue = [self getInt8];
      break;
    case 6:
      intValue = [self getInt];
      intValue2 = [self getInt];
      break;
    default:
      break;
  }
  return [NgTag tagWith:name type:type intValue:intValue intValue2:intValue2 strValue:strValue];
}

- (NSArray *)getTagList
{
  int count = [self getInt16];
  NSMutableArray *array = [NSMutableArray arrayWithCapacity:count];
  while (count-- > 0) {
    [array addObject:[self getTag]];
  }
  return array;
}

- (NSData *)getMd4
{
  if (head + 16 <= tail) {
    NSData *md4 = [NSData dataWithBytes:head length:16];
    head += 16;
    return md4;
  } else {
    return nil;
  }
}

- (int)getFileState
{
  int fileState = [self getInt8];
  if (fileState == 6) {
    [self getString]; // reason for abortion
  }
  return fileState;
}

- (NSData *)getChunks
{
  int len = [self getInt16];
  if (head + len <= tail) {
    NSData *chunks = [NSData dataWithBytes:head length:len];
    head += len;
    return chunks;
  } else {
    return nil;
  }
}

- (NSArray *)getAvailabilityList
{
  NSMutableArray *array = [NSMutableArray arrayWithCapacity:10];
  int count = [self getInt16];
  while (count-- > 0) {
    NgAvailability *avail = [[NgAvailability alloc] init];
    avail.networkId = [self getInt];
    avail.chunks = [self getChunks];
    [array addObject:avail];
  }
  return array;
}

- (float)getFloat
{
  NSString *s = [self getString];
  NSArray *compo = [s componentsSeparatedByString:@"."];
  int i = [[compo objectAtIndex:0] intValue];
  int f = 0;
  if ([compo count] > 1) {
    f = [[compo objectAtIndex:1] intValue];
  }
  return i + f / 100.0;
}

- (NSArray *)getIntList
{
  int count = [self getInt16];
  NSMutableArray *array = [NSMutableArray arrayWithCapacity:count];
  while (count-- > 0) {
    [array addObject:[NSNumber numberWithInt:[self getInt]]];
  }
  return array;
}

- (NgOggStreamTag *)getOggStreamTag
{
  NgOggStreamTag *tag = [[NgOggStreamTag alloc] init];
  tag.type = [self getInt8]; // tag type
  switch (tag.type) {
  case 0:
    [self getString]; // codec
    break;
  case 1:
    [self getInt];  // bits per sample
    break;
  case 2:
    [self getInt];  // duration
    break;
  case 3:         // has subtitle
    break;
  case 4:         // has index
    break;
  case 5:         // audio channels
    [self getInt];
  case 6:         // audio sample rate
    [self getFloat];
    break;
  case 7:         // audio block align
    [self getInt];
    break;
  case 8:         // audio avg bytes per sec
    [self getFloat];
    break;
  case 9:         // vorbis version
    [self getFloat];
    break;
  case 10:        // vorbis sample rate
    [self getFloat];
    break;
  case 11:        // vorbis bit rates
    {
      int count = [self getInt16];
      while (count-- > 0) {
        [self getInt8];     // 0: maximum, 1: norminal, 2: minimum
        [self getFloat];
      }
      break;
    }
  case 12:        // vorbis block size 0
    [self getInt];
    break;
  case 13:        // vorbis block size 1
    [self getInt];
    break;
  case 14:        // video width
    [self getFloat];
    break;
  case 15:        // video height
    [self getFloat];
    break;
  case 16:        // video sample rate
    [self getFloat];
    break;
  case 17:        // aspect ratio
    [self getFloat];
    break;
  case 18:        // theora cs
    [self getInt8];   // 0: undefined, 1: rec470m, 2: rec470bg
    break;
  case 19:        // theora quality
    [self getInt];
    break;
  case 20:        // theora avg bytes per sec
    [self getInt];
    break;
  }
  return tag;
}

- (NgFileFormat *)getFileFormat
{
  NgFileFormat *fileFormat = [[NgFileFormat alloc] init];
  fileFormat.format = [self getInt8];
  switch (fileFormat.format) {
    case 0: // unknown format
      break;
    case 1: // generic format
      fileFormat.ext = [self getString];
      fileFormat.kind = [self getString];
      break;
    case 2: // avi file
      fileFormat.codec = [self getString];
      fileFormat.width = [self getInt];
      fileFormat.height = [self getInt];
      fileFormat.fps = [self getInt];
      fileFormat.rate = [self getInt];
      break;
    case 3: // mp3 file
      fileFormat.title = [self getString];
      fileFormat.artist = [self getString];
      fileFormat.album = [self getString];
      fileFormat.year = [self getString];
      fileFormat.comment = [self getString];
      fileFormat.track = [self getInt];
      fileFormat.genre = [self getInt];
      break;
    case 4: // ogg file
    {
      int count = [self getInt16];
      fileFormat.oggList = [NSMutableArray arrayWithCapacity:count];
      while (count-- > 0) {
        NgOggStream *ogg = [[NgOggStream alloc] init];
        ogg.streamNum = [self getInt];
        ogg.streamType = [self getInt8];
        int tagCount = [self getInt16];
        ogg.streamTags = [NSMutableArray arrayWithCapacity:tagCount];
        while (tagCount-- > 0) {
          [ogg.streamTags addObject:[self getOggStreamTag]];
        }
        [fileFormat.oggList addObject:ogg];
      }
      break;
    }
    default:
      break;
  }
  return fileFormat;
}

- (NgSubfile *)getSubfile
{
  NgSubfile *subfile = [[NgSubfile alloc] init];
  subfile.name = [self getString];
  subfile.size = [self getInt64];
  subfile.format = [self getString];
  return subfile;
}

- (NSArray *)getSubfileList
{
  int count = [self getInt16];
  NSMutableArray *array = [NSMutableArray arrayWithCapacity:count];
  while (count-- > 0) {
    [array addObject:[self getSubfile]];
  }
  return array;
}

- (NgComment *)getComment
{
  NgComment *comment = [[NgComment alloc] init];
  comment.ip = [self getInt];
  comment.geoIp = [self getInt8];
  comment.name = [self getString];
  comment.rating = [self getInt8];
  comment.comment = [self getString];
  return comment;
}

- (NSArray *)getCommentList
{
  int count = [self getInt16];
  NSMutableArray *array = [NSMutableArray arrayWithCapacity:count];
  while (count-- > 0) {
    [array addObject:[self getComment]];
  }
  return array;
}

- (NgFileInfo *)getFileInfo
{
  NgFileInfo *fileInfo = [[NgFileInfo alloc] init];
  fileInfo.fileId = [self getInt];
  // NSLog(@"%d", fileInfo.fileId);
  int networkId = [self getInt];
  fileInfo.fileNames = [self getStringList];
  fileInfo.md4 = [self getMd4];
  fileInfo.fileSize = [self getInt64];
  fileInfo.downloadedSize = [self getInt64];
  int numSources = [self getInt];
  int numClients = [self getInt];
  int fileState = [self getFileState];
  fileInfo.chunks = [self getChunks];
  NSArray *availList = [self getAvailabilityList];
  NgAvailability *avail = [availList objectAtIndex:0];
  fileInfo.availability = avail.chunks;
  fileInfo.downloadSpeed = [self getFloat];
  NSArray *ages = [self getIntList];
  int age = [self getInt];
  // NSLog(@"age = %d", age);
  NgFileFormat *format = [self getFileFormat];
  // NSLog(@"format");
  fileInfo.fileName = [self getString];
  int lastSeen = [self getInt];
  int priority = [self getInt];
  NSString *comment = [self getString];
  NSArray *links = [self getStringList];
  NSArray *subFiles = [self getSubfileList];
  NSString *fileFormat = [self getString];
  NSArray *comments = [self getCommentList];
  NSString *user = [self getString];
  [self getString];     // group
  // NSLog(@"group = %@", group);
  networkId, 
  numSources, numClients, fileState,
  ages, age, format, lastSeen, priority, comment, links, subFiles, fileFormat, comments, user;

  return fileInfo;
}

- (NgClientKind *)getClientKind
{
  NgClientKind *clientKind = [[NgClientKind alloc] init];
  clientKind.type = [self getInt8];
  if (clientKind.type == 1) {
    clientKind.name = [self getString];
    [self getInt8];                     // country code
    clientKind.hash = [self getMd4];
  }
  clientKind.ip = [self getInt];
  clientKind.geoIp = [self getInt8];
  clientKind.port = [self getInt16];
  return clientKind;
}

- (NgHostState *)getState
{
  NgHostState *hostState = [[NgHostState alloc] init];
  hostState.state = [self getInt8];
  if (hostState.state == 3 || hostState.state == 5 || hostState.state == 9) { // 3: downloading, 5: connected, 9: not connected
    hostState.rank = [self getInt];
  }
  return hostState;
}

- (NgAddr *)getAddr
{
  NgAddr *addr = [[NgAddr alloc] init];
  addr.type = [self getInt8];
  if (addr.type == 0) { // ip
    addr.ip = [self getInt];
    addr.geoIp = [self getInt8];
  } else {
    addr.geoIp = [self getInt8];
    addr.name = [self getString];
  }
  addr.blocked = [self getInt8];
  return addr;
}

- (BOOL)read
{
  int len = [stream read:tail maxLength:toRead];
  NSAssert(len >= 0, @"read: returned negative");
  toRead -= len;
  tail += len;

  if (toRead == 0) {
    if (state == RS_LENGTH) {
      state = RS_BODY;
      toRead = [self getInt];
      [buf setLength:toRead];
      head = [buf mutableBytes];
      tail = head;
    } else {
      return YES;
    }
  }
  return NO;
}

@end
