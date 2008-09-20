//
//  NgFolder.h
//  Nagui
//
//  Created by Appledelhi on 08. 09. 06.
//  Copyright 2008 Appledelhi. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NgFolder : NSObject {
  NSString *path;
  NSAttributedString *name;
  NgFolder *parent;
  int shared;
  NSMutableArray *folders;
  NSMutableArray *files;
}

@property(assign) NSString *path;
@property(assign) NSAttributedString *name;
@property(assign) NgFolder *parent;
@property int shared;
@property(assign) NSMutableArray *folders;
@property(assign) NSMutableArray *files;

- initParent:(NgFolder *)parent path:(NSString *)path name:(NSString *)name shared:(int)shared icon:(NSImage *)icon;
- (void)shareRecursive:(int)state;

@end
