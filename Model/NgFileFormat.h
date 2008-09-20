//
//  NgFileFormat.h
//  Nagui
//
//  Created by Appledelhi on 08. 08. 28.
//  Copyright 2008 Appledelhi. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NgFileFormat : NSObject {
  int format;
  NSString *ext;
  NSString *kind;
  NSString *codec;
  int width;
  int height;
  int fps;
  int rate;
  NSString *title;
  NSString *artist;
  NSString *album;
  NSString *year;
  NSString *comment;
  int track;
  int genre;
  NSMutableArray *oggList;
}

@property int format;
@property(assign) NSString *ext;
@property(assign) NSString *kind;
@property(assign) NSString *codec;
@property int width;
@property int height;
@property int fps;
@property int rate;
@property(assign) NSString *title;
@property(assign) NSString *artist;
@property(assign) NSString *album;
@property(assign) NSString *year;
@property(assign) NSString *comment;
@property int track;
@property int genre;
@property(assign) NSMutableArray *oggList;

@end
