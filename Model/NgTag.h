//
//  NgTag.h
//  Nagui
//
//  Created by Appledelhi on 08. 08. 24.
//  Copyright 2008 Appledelhi. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NgTag : NSObject {
  NSString *name;
  int type;
  int intValue;
  int intValue2;
  NSString *strValue;
}

@property(assign) NSString *name;
@property int type;
@property int intValue;
@property int intValue2;
@property(assign) NSString *strValue;

+ tagWith:name type:(int)type intValue:(int)i intValue2:(int)i2 strValue:str;

@end
