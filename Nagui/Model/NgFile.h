//
//  NgFile.h
//  Nagui
//
//  Created by Appledelhi on 08. 09. 08.
//  Copyright 2008 Appledelhi. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NgFile : NSObject {
  NSString *path;
  NSImage *icon;
  NSString *name;
  NSNumber *size;
  NSNumber *rating;
  NSString *tags;
}

@property(assign) NSString *path;
@property(readonly) NSImage *icon;
@property(assign) NSString *name;
@property(readonly) NSNumber *size;
@property(assign) NSNumber *rating;
@property(assign) NSString *tags;

- initPath:(NSString *)path;

@end
