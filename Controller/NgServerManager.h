//
//  NgServerManager.h
//  Nagui
//
//  Created by Appledelhi on 08. 09. 01.
//  Copyright 2008 Appledelhi. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NgServerManager : NSObject {
  NSMutableArray *servers;
}

@property(assign) NSMutableArray *servers;

@end
