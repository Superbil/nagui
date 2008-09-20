//
//  NgOption.h
//  Nagui
//
//  Created by Appledelhi on 08. 09. 05.
//  Copyright 2008 Appledelhi. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NgOption : NSObject {
  NSString *section;
  NSString *description;
  NSString *name;
  NSString *type;
  NSString *help;
  NSString *value;
  NSString *defaultValue;
  BOOL advanced;
  
  NSMutableArray *options;
}

@property(assign) NSString *section;
@property(assign) NSString *description;
@property(assign) NSString *name;
@property(assign) NSString *type;
@property(assign) NSString *help;
@property(assign) NSString *value;
@property(assign) NSString *defaultValue;
@property BOOL advanced;
@property(assign) NSMutableArray *options;

@end
