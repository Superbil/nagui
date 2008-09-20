//
//  NgClientKind.h
//  Nagui
//
//  Created by Appledelhi on 08. 08. 31.
//  Copyright 2008 Appledelhi. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NgClientKind : NSObject {
  int8_t type;
  NSString *name;
  NSData *hash;   // 16 bytes
  int ip;
  int8_t geoIp;
  int16_t port;
}

@property int8_t type;
@property(assign) NSString *name;
@property(assign) NSData *hash;
@property int ip;
@property int8_t geoIp;
@property int16_t port;

@end
