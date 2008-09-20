//
//  NgOptionManager.h
//  Nagui
//
//  Created by Appledelhi on 08. 09. 05.
//  Copyright 2008 Appledelhi. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class NgOption;

@interface NgOptionManager : NSObject {
  NSMutableArray *sections;
}

- (void)addOption:(NgOption *)option;
- (void)addOption:(NSString *)option value:(NSString *)value;

@end
