//
//  NgSubfile.h
//  Nagui
//
//  Created by Appledelhi on 08. 08. 28.
//  Copyright 2008 Appledelhi. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NgSubfile : NSObject {
  NSString *name;
  int64_t size;
  NSString *format;
}

@property(assign) NSString *name;
@property int64_t size;
@property(assign) NSString *format;

@end
