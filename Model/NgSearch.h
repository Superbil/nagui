//
//  NgSearch.h
//  Nagui
//
//  Created by Appledelhi on 08. 08. 24.
//  Copyright 2008 Appledelhi. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NgSearch : NSObject {
  int searchId;
  NSString *keyword;
  NSMutableArray *results;
  NSTimer *timer;
}

@property int searchId;
@property(assign) NSString *keyword;
@property(readonly) NSArray *results;

+ searchWithId:(int)i keyword:keyword;

- (void)addResult:result;

@end
