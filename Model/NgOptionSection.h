//
//  NgOptionSection.h
//  Nagui
//
//  Created by Appledelhi on 08. 09. 06.
//  Copyright 2008 Appledelhi. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NgOptionSection : NSObject {
  NSString *name;
  NSMutableArray *options;
}

@property(assign) NSString *name;
@property(assign) NSMutableArray *options;

@end
