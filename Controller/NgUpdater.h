//
//  NgUpdater.h
//  Nagui
//
//  Created by Jake Song on 08. 09. 25.
//  Copyright 2008 XL Games. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NgUpdater : NSObject {
  NSMutableData *received;
//  NSURLConnection *connection;
  int version;
}

- (void)checkUpdate;

@end
