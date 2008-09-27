//
//  NgSearchController.h
//  Nagui
//
//  Created by Appledelhi on 08. 08. 24.
//  Copyright 2008 Appledelhi. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class NgResult;

@interface NgSearchManager : NSObject {
  IBOutlet NSArrayController *searchController;
  IBOutlet NSArrayController *resultController;
  IBOutlet NSTableView *resultTable;
  int globalSearchId;
  NSMutableArray *searches;
  NSMutableDictionary *results;
  NSString *minSize;
  NSString *keyword;
  NSString *searchFieldTooltip;
//  NSMutableDictionary *indiRows;
}

@property(readonly) NSMutableArray *searches;

- (IBAction)search:sender;
- (IBAction)deleteSearch:sender;
- (IBAction)moreResults:sender;
- (IBAction)download:sender;

- (void)addResult:result;
- (void)associateResult:(NSNumber *)resultId toSearch:(int)searchId;
//- (void)resetIndicators;
- (void)refresh;

@end
