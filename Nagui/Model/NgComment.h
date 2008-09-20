//
//  NgComment.h
//  Nagui
//
//  Created by Appledelhi on 08. 08. 28.
//  Copyright 2008 Appledelhi. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NgComment : NSObject {
  int ip;
  int geoIp;
  NSString *name;
  int rating;
  NSString *comment;  
}

@property int ip;
@property int geoIp;
@property(assign) NSString *name;
@property int rating;
@property(assign) NSString *comment;

@end
