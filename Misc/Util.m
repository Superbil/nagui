/*
 *  Util.c
 *  Nagui
 *
 *  Created by Appledelhi on 08. 08. 21.
 *  Copyright 2008 Appledelhi. All rights reserved.
 *
 */

#include "Util.h"

NSAttributedString *attributedStringFromImage(NSImage *image)
{
  NSTextAttachment *attach = [[NSTextAttachment alloc] init];
  NSTextAttachmentCell *cell = [[NSTextAttachmentCell alloc] init];
  [cell setImage:image];
  [attach setAttachmentCell:cell];
  return [NSAttributedString attributedStringWithAttachment:attach];
}

NSAttributedString *attributedStringFrom(id obj, ...)
{
  va_list args;
  va_start(args, obj);
  NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] init];
  id arg = obj;
  while (arg) {
    NSAttributedString *str = nil;
    if ([arg isKindOfClass:[NSImage class]]) {
      str = attributedStringFromImage(arg);
    } else if ([arg isKindOfClass:[NSString class]]) {
      str = [[NSAttributedString alloc] initWithString:arg
                                            attributes:[NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:3.0]
                                                                                   forKey:NSBaselineOffsetAttributeName]];
    } else if ([arg isKindOfClass:[NSAttributedString class]]) {
      str = [[NSAttributedString alloc] initWithAttributedString:arg];
    } else {
      break;
    }
    [attrStr appendAttributedString:str];
    arg = va_arg(args, id);
  }
  va_end(args);
  return attrStr;
}

int asciiToHex(int a)
{
  if (a >= '0' && a <= '9') {
    return a - '0';
  } else if (a >= 'A' && a <= 'F') {
    return a - 'A' + 10;
  }
  return 0;
}

int ascii2ToHex(const char *str)
{
  return (asciiToHex(str[0]) << 4) + asciiToHex(str[1]);
}

NSArray *md4sFromStrings(NSArray *array)
{
  NSMutableArray *md4s = [NSMutableArray arrayWithCapacity:[array count]];
  for (NSString *str in array) {
    if ([str hasPrefix:@"urn:ed2k:"]) {
      const char *utf = [[str substringFromIndex:9] UTF8String];
      char buf[16];
      for (int i = 0; i < 16; i++) {
        buf[i] = ascii2ToHex(utf + i * 2);
      }
      NSData *data = [NSData dataWithBytes:buf length:16];
      [md4s addObject:data];
      // NSLog(@"%@", str);
      // NSLog(@"%@", data);
    }
  }
  return md4s;
}

NSString *fromHuman(NSString *str)
{
  if (!str) {
    return @"0";
  }
  NSString *trim = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
  unichar c = [trim characterAtIndex:[trim length] - 1];
  NSString *replace = nil;
  if (c == 'k' || c == 'K') {
    replace = @"000";
  } else if (c == 'm' || c == 'M') {
    replace = @"000000";
  } else if (c == 'g' || c == 'G') {
    replace = @"000000000";
  }
  if (replace) {
    return [[trim substringToIndex:[trim length] - 1] stringByAppendingString:replace];
  } else {
    return trim;
  }
}

NSTask *launch(NSFileHandle **output, NSFileHandle **err, NSString *path, ...)
{
  NSTask *task = [[NSTask alloc] init];
  [task setLaunchPath:path];
  
  NSMutableArray *array = [NSMutableArray arrayWithCapacity:5];
  va_list args;
  va_start(args, path);
  id arg;
  while (arg = va_arg(args, id)) {
    [array addObject:arg];
  }
  va_end(args);

  [task setArguments:array];

  if (output) {
    NSPipe *pipe = [NSPipe pipe];
    [task setStandardOutput:pipe];
    *output = [pipe fileHandleForReading];
  }
  if (err) {
    NSPipe *pipe = [NSPipe pipe];
    [task setStandardError:pipe];
    *err = [pipe fileHandleForReading];
  }
  [task launch];
  return task;
}

NSTask *launchNoOutput(NSString *path, ...)
{
  NSTask *task = [[NSTask alloc] init];
  [task setLaunchPath:path];

  NSMutableArray *array = [NSMutableArray arrayWithCapacity:5];
  va_list args;
  va_start(args, path);
  id arg;
  while (arg = va_arg(args, id)) {
    [array addObject:arg];
  }
  va_end(args);
  
  [task setArguments:array];
  [task launch];
  return task;
}
