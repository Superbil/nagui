//
//  NgOggStream.h
//  Nagui
//
//  Created by Appledelhi on 08. 08. 28.
//  Copyright 2008 Appledelhi. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NgOggStream : NSObject {
  int streamNum;
  int streamType;
  NSMutableArray *streamTags;
}

@property int streamNum;
@property int streamType;
@property(assign) NSMutableArray *streamTags;

@end
