//
//  NgSearchController.m
//  Nagui
//
//  Created by Appledelhi on 08. 08. 24.
//  Copyright 2008 Appledelhi. All rights reserved.
//

#import "NgSearchManager.h"
#import "NgQuery.h"
#import "Nagui.h"
#import "NgProtocolHandler.h"
#import "NgWriteBuffer.h"
#import "NgSearch.h"
#import "NgResult.h"
#import "Util.h"
#import "NSObjectControllerExt.h"

@implementation NgSearchManager

@synthesize searches;

- (void)awakeFromNib
{
  globalSearchId = 0;
  searches = [NSMutableArray arrayWithCapacity:10];
  results = [NSMutableDictionary dictionaryWithCapacity:1000];
//  indiRows = [NSMutableDictionary dictionaryWithCapacity:10];

  [resultTable setTarget:self];
  [resultTable setDoubleAction:@selector(download:)];
}

- (void)search:sender
{
  if ([keyword length] > 0) {
    NgQuery *query = [NgQuery queryWithString:keyword minSize:fromHuman(minSize)];
    NgSearch *search = [NgSearch searchWithId:globalSearchId++ keyword:keyword];
    [nagui.protocolHandler sendSearch:search.searchId query:query];

    [self willChangeValueForKey:@"searches"];
    [searches addObject:search];
    [self didChangeValueForKey:@"searches"];
    
    [searchController setSelectionIndex:[searches count] - 1];
  }
}

- (void)addResult:(NgResult *)result
{
  [results setObject:result forKey:[NSNumber numberWithInt:result.resultId]];
}

- (void)associateResult:(int)resultId toSearch:(int)searchId
{
  NgResult *result = [results objectForKey:[NSNumber numberWithInt:resultId]];
  if (result) {
    for (NgSearch *search in searches) {
      if (search.searchId == searchId) {
        [search addResult:result];
        break;
      }
    }
  }
}

- deleteButton
{
  return nagui.xInCircleImage;
}

- (IBAction)deleteSearch:sender
{
  NSInteger col = [sender clickedColumn];
  NSInteger row = [sender clickedRow];
  if (col == 2) {
    if (row >= 0 && row < [searches count]) {
      NgSearch *search = [searches objectAtIndex:row];
      [nagui.protocolHandler sendCloseSearch: search.searchId];
      [self willChangeValueForKey:@"searches"];
      [searches removeObjectAtIndex:row];
      [self didChangeValueForKey:@"searches"];
      
    }
  }
}

- (IBAction)moreResults:sender
{
  [nagui.protocolHandler sendExtendSearch];
}

- (IBAction)download:sender
{
  NgResult *result = [resultController selectedObject];
  if (result) {
    // [result willChangeValueForKey:@"color"];
    // [result willChangeValueForKey:@"status"];
    // result.isDownloading = YES;
    // [result didChangeValueForKey:@"status"];
    // [result didChangeValueForKey:@"bold"];
    [nagui.protocolHandler sendDownload:result.fileNames resultId:result.resultId];
    [nagui.protocolHandler sendGetDownloadingFiles];
  }
}

// - (BOOL)isSelected:(NgResult *)result
// {
//   NSArray *array = [resultController selectedObjects];
//   if ([array count] > 0) {
//     return result == [array objectAtIndex:0];
//   }
//   return NO;
// }

- (void)tableView:(NSTableView *)view willDisplayCell:cell forTableColumn:(NSTableColumn *)column row:(NSInteger)row
{
  if (view == resultTable) {
    NgResult *result = [[resultController arrangedObjects] objectAtIndex:row];
    if ([[column identifier] isEqualToString:@"status"]) {
//      NSNumber *rowNum = [NSNumber numberWithInt:row];
//      if (result.isDownloading && ![indiRows objectForKey:rowNum]) {
//        NSRect rect = [view rectOfRow:row];
//        rect.size.width = 17;
//        rect.size.height -= 2;
//        NSProgressIndicator *indi = [[NSProgressIndicator alloc] initWithFrame:rect];
//        [indiRows setObject:indi forKey:rowNum];
//        [indi setStyle:NSProgressIndicatorSpinningStyle];
//        [view addSubview:indi];
//        [indi startAnimation:self];
//      }
    } else {
      if ([view selectedRow] == row) {
        [cell setTextColor:[NSColor whiteColor]];
      } else {
        [cell setTextColor:[result color]];
      }
    }
  }
}

//- (void)tableViewSelectionDidChange:(NSNotification *)notification
//{
//  if ([notification object] != resultTable) {
//    [self resetIndicators];
//  }
//}

//- (void)tableView:(NSTableView *)view didClickTableColumn:(NSTableColumn *)column
//{
//  if (view == resultTable) {
//    [self resetIndicators];
//  }
//}

//- (void)resetIndicators
//{
//  for (NSNumber *key in indiRows) {
//    NSProgressIndicator *indi = [indiRows objectForKey:key];
//    [indi removeFromSuperview];
//  }
//  indiRows = [NSMutableDictionary dictionaryWithCapacity:10];
//}

- (void)refresh
{
  [resultTable setNeedsDisplay];
}

@end
