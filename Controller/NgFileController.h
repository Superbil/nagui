//
//  NgFileController.h
//  Nagui
//
//  Created by Jake Song on 08. 09. 20.
//  Copyright 2008 XL Games. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NgFileController : NSArrayController {
  NSString *filterStr;
}

- (IBAction)setFilter:sender;

@end
