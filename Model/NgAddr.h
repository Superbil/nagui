//
//  NgAddr.h
//  Nagui
//
//  Created by Appledelhi on 08. 09. 01.
//  Copyright 2008 Appledelhi. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NgAddr : NSObject {
  uint8_t type;
  int ip;
  uint8_t geoIp;
  NSString *name;
  uint8_t blocked;
  
  uint16_t inetPort;
}

@property uint8_t type;
@property int ip;
@property uint8_t geoIp;
@property(assign) NSString *name;
@property uint8_t blocked;
@property uint16_t inetPort;

@end
