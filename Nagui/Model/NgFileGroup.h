//
//  NgFileGroup.h
//  Nagui
//
//  Created by Appledelhi on 08. 09. 13.
//  Copyright 2008 Appledelhi. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "NgGroup.h"

@interface NgFileGroup : NgGroup {
  NSString *path;
  NSArray *contents;
}

@property(assign) NSString *path;

- initPath:(NSString *)path type:(NgGroupType)type;
- (void)setIcon;
- (BOOL)removeFolder;

@end
