//
//  NgSharedFolder.h
//  Nagui
//
//  Created by Appledelhi on 08. 09. 07.
//  Copyright 2008 Appledelhi. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "NgGroup.h"

@interface NgSharedFolder : NSObject {
  NSString *path;
  NgGroupType type;
}

@property(assign) NSString *path;
@property NgGroupType type;

- initPath:(NSString *)path type:(NgGroupType)type;

@end
