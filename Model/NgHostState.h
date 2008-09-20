//
//  NgHostState.h
//  Nagui
//
//  Created by Appledelhi on 08. 08. 31.
//  Copyright 2008 Appledelhi. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NgHostState : NSObject {
  int8_t state;
  int rank;
}

@property int8_t state;
@property int rank;

@end
