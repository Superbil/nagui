//
//  NgSmartGroup.h
//  Nagui
//
//  Created by Appledelhi on 08. 09. 16.
//  Copyright 2008 Appledelhi. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "NgGroup.h"

@interface NgSmartGroup : NgGroup {
  // NSMetadataQuery *query;
  NSLock *lock;
  BOOL scanning;
}

@end
