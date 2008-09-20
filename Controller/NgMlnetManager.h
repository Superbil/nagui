//
//  NgMlnetManager.h
//  Nagui
//
//  Created by Appledelhi on 08. 09. 10.
//  Copyright 2008 Appledelhi. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NgMlnetManager : NSObject {
  NSTask *mlnet;
  NSFileHandle *mlnetOutput;
}

- (IBAction)chooseMlnetPath:sender;
- (IBAction)startMlnet:sender;
- (IBAction)stopMlnet:sender;
- (IBAction)connectMlnet:sender;

- (void)autoStart;
- (void)autoQuit;

@end
