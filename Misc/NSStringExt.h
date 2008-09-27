//
//  NSStringExt.h
//  Nagui
//
//  Created by Appledelhi on 08. 09. 15.
//  Copyright 2008 Appledelhi. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSString(Nagui)

- (NSString *)beforeLastPathComponent;
- (BOOL)isSameDir:(NSString *)dir;
- (BOOL)contains:(NSString *)str;
- (BOOL)containsCaseInsensitive:(NSString *)str;
- (BOOL)isInvisible;
- (BOOL)isSameString:(NSString *)str;
- (NSString *)mldonkeyFullPath;

@end
