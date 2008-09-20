//
//  NgClientInfo.h
//  Nagui
//
//  Created by Appledelhi on 08. 08. 31.
//  Copyright 2008 Appledelhi. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class NgHostState;

@interface NgClientInfo : NSObject {
  int clientId;
  NSString *name;
  NSString *fileName;
  NgHostState *state;
  int64_t downloaded;
  int64_t uploaded;
  NSColor *color;
}

@property int clientId;
@property(assign) NSString *name;
@property(assign) NSString *fileName;
@property(assign) NgHostState *state;
@property int64_t downloaded;
@property int64_t uploaded;
@property(assign) NSColor *color;

@end
