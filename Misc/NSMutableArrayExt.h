//
//  NSMutableArrayExt.h
//  Nagui
//
//  Created by Appledelhi on 08. 09. 20.
//  Copyright 2008 Appledelhi. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSMutableArray(Nagui)

- (void)addAndRemove:(NSArray *)array;
- (void)addObjectsFromArrayUnique:(NSArray *)array;

@end
