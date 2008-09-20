/*
 *  Util.h
 *  Nagui
 *
 *  Created by Appledelhi on 08. 08. 21.
 *  Copyright 2008 Appledelhi. All rights reserved.
 *
 */

static inline int intFrom(uint8_t *buf)
{
  return buf[0] | buf[1] << 8 | buf[2] << 16 | buf[3] << 24;
}

static inline short shortFrom(uint8_t *buf)
{
  return buf[0] | buf[1] << 8;
}

static inline BOOL contains(NSString *str, NSString *sub)
{
  return [str rangeOfString:sub].location != NSNotFound;
}

NSAttributedString *attributedStringFromImage(NSImage *image);
NSAttributedString *attributedStringFrom(id obj, ...);
NSArray *md4sFromStrings(NSArray *array);
NSString *fromHuman(NSString *str);
NSTask *launch(NSFileHandle **output, NSFileHandle **err, NSString *path, ...);
