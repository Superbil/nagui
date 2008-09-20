//
//  NgSearch.m
//  Nagui
//
//  Created by Appledelhi on 08. 08. 24.
//  Copyright 2008 Appledelhi. All rights reserved.
//

#import "NgSearch.h"


@implementation NgSearch

@synthesize searchId;
@synthesize keyword;
@synthesize results;

+ searchWithId:(int)i keyword:keyword
{
  NgSearch *search = [[NgSearch alloc] init];
  search.searchId = i;
  search.keyword = keyword;
  return search;
}

- init
{
  results = [NSMutableArray arrayWithCapacity:100];
  timer = nil;
  return self;
}

- (void)updateResults:t
{
  [self willChangeValueForKey:@"count"];
  [self didChangeValueForKey:@"count"];
  [self willChangeValueForKey:@"results"];
  [self didChangeValueForKey:@"results"];
  timer = nil;
}

- (void)addResult:result
{
  if (![results containsObject:result]) {
    [results addObject:result];
    if (timer == nil) {
      timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateResults:) userInfo:nil repeats:NO];
    }
  }
}

- (int)count
{
  return [results count];
}

@end
