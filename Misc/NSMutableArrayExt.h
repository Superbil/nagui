//
//  NSMutableArrayExt.h
//  Nagui
//
//  Created by Jake Song on 08. 09. 20.
//  Copyright 2008 XL Games. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSMutableArray(Nagui)

- (void)addRemove:(NSArray *)array;
- (void)addObjectsFromArrayUnique:(NSArray *)array;

@end
