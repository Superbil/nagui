//
//  NgServerInfo.h
//  Nagui
//
//  Created by Appledelhi on 08. 09. 01.
//  Copyright 2008 Appledelhi. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class NgHostState;
@class NgAddr;

@interface NgServerInfo : NSObject {
  int serverId;
  NSString *name;
  NSString *description;
  NgHostState *state;
  int64_t users;
  int64_t files;
  int ping;
  NgAddr *addr;
}

@property int serverId;
@property(assign) NSString *name;
@property(assign) NSString *description;
@property(assign) NgHostState *state;
@property int64_t users;
@property int64_t files;
@property int ping;
@property(assign) NgAddr *addr;

@end
