//
//  NGQuery.h
//  Nagui
//
//  Created by Appledelhi on 08. 08. 24.
//  Copyright 2008 Appledelhi. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class NgWriteBuffer;

enum {
  NgAnd = 0,
  NgOr = 1,
  NgAndNot = 2,
  NgModule = 3,
  NgKeyword = 4,
  NgMinSize = 5,
  NgBitRate = 12,
  NgHidden = 13,
};

@interface NgQuery : NSObject {
  int type;
  NSMutableArray *args;
}

+ (NgQuery *)queryWithKeyword:(NSString *)keyword;
+ (NgQuery *)queryWithKeyword:(NSString *)keyword minSize:(NSString *)size;
+ (NgQuery *)queryWithKeywords:(NSArray *)keywords minSize:(NSString *)size;
+ (NgQuery *)queryWithString:(NSString *)string minSize:(NSString *)size;

- initType:(int)type;
- initType:(int)type arg1:arg1 arg2:arg2;
- (void)append:arg;
- (void)writeTo:(NgWriteBuffer *)buffer;
- (NSString *)keyword;

@end
