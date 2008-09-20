//
//  NgAvailability.h
//  Nagui
//
//  Created by Appledelhi on 08. 08. 28.
//  Copyright 2008 Appledelhi. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NgAvailability : NSObject {
  int networkId;
  NSData *chunks;
}

@property int networkId;
@property(assign) NSData *chunks;

@end
