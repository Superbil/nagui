//
//  Nagui.m
//  Nagui
//
//  Created by Appledelhi on 08. 08. 17.
//  Copyright 2008 Appledelhi. All rights reserved.
//

#import "Nagui.h"
#import "NgProtocolHandler.h"
#import "NgSearchManager.h"
#import "NgFileSizeTrans.h"
#import "NgTimeTrans.h"
#import "NgStateTrans.h"
#import "NgProgressCell.h"
#import "NgFolderManager.h"
#import "NgMlnetManager.h"
#import "NgUpdater.h"

Nagui *nagui;

@implementation Nagui

@synthesize searchManager;
@synthesize transferManager;
@synthesize serverManager;
@synthesize optionManager;
@synthesize shareManager;
@synthesize taskManager;
@synthesize protocolHandler;
@synthesize downloadProgress;
@synthesize shareMenu;
@synthesize currentManager;
@synthesize downArrowImage;
@synthesize downloadImage;
@synthesize downloadingImage;
@synthesize folderImage;
@synthesize incomingDirImage;
@synthesize xInCircleImage;
@synthesize alertImage;
@synthesize smartFolderImage;

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication
{
  return YES;
}

- (void)createDownloadsIni
{
  NSFileManager *fileMan = [NSFileManager defaultManager];
  NSString *mldonkey = [NSString stringWithFormat:@"%@/.mldonkey", NSHomeDirectory()];
  NSString *downloadsIni = [mldonkey stringByAppendingPathComponent:@"downloads.ini"];
  BOOL isDir;
  if (![fileMan fileExistsAtPath:mldonkey isDirectory:&isDir]) {
    [fileMan createDirectoryAtPath:mldonkey attributes:nil];
  } else if (!isDir) {
    [fileMan removeFileAtPath:mldonkey handler:nil];
    [fileMan createDirectoryAtPath:mldonkey attributes:nil];
  }
  if (![fileMan fileExistsAtPath:downloadsIni]) {
    NSString *str = [NSString stringWithFormat:@" allowed_ips = [\
         \"127.0.0.1\";]\
      shared_directories = [\
      {     dirname = \"%@/Downloads\"\
         strategy = incoming_files\
         priority = 0\
      };\
      {     dirname = \"%@/Downloads\"\
         strategy = incoming_directories\
         priority = 0\
      };]", NSHomeDirectory(), NSHomeDirectory()];
    NSData *data = [NSData dataWithBytes:[str UTF8String] length:[str length]];
    [fileMan createFileAtPath:downloadsIni contents:data attributes:nil];
  }
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
  [self createDownloadsIni];
  updater = [[NgUpdater alloc] init];
  [updater checkUpdate];
  [mlnetManager autoStart];
}

- (void)applicationWillTerminate:(NSNotification *)notification
{
  [searchManager forgetSearches];
  [mlnetManager autoQuit];
}

- (void)showView:(NSView *)view
{
  if (currentView) {
    [contentView replaceSubview:currentView with:view];
  } else {
    [contentView addSubview:view];
  }
  [view setFrame:[contentView bounds]];
  currentView = view;
}

- (void)awakeFromNib
{
  nagui = self;
  [self showView:consoleView];
  
  // set up textview to display text of any width
  id textView = [consoleView documentView];
  [[textView textContainer] setWidthTracksTextView:NO];
  
  NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
  [formatter setFormat:@"#,##0"];
  [[usersColumn dataCell] setFormatter:formatter];
  [[filesColumn dataCell] setFormatter:formatter];
  
  protocolHandler = [[NgProtocolHandler alloc] init];
  [NSTimer scheduledTimerWithTimeInterval:1.0 target:protocolHandler selector:@selector(timer:)
                                 userInfo:nil repeats:YES];

  NgFileSizeTrans *fileSizeTrans = [[NgFileSizeTrans alloc] init];
  [NSValueTransformer setValueTransformer:fileSizeTrans forName:@"NgFileSizeTrans"];
  NgTimeTrans *timeTrans = [[NgTimeTrans alloc] init];
  [NSValueTransformer setValueTransformer:timeTrans forName:@"NgTimeTrans"];
  NgStateTrans *stateTrans = [[NgStateTrans alloc] init];
  [NSValueTransformer setValueTransformer:stateTrans forName:@"NgStateTrans"];
  
  downArrowImage = [NSImage imageNamed:@"agt_update_misc"];
  downloadImage = [NSImage imageNamed:@"download16"];
  downloadingImage = [NSImage imageNamed:@"Sync"];
  folderImage = [NSImage imageNamed:@"folder_open"];
  incomingDirImage = [NSImage imageNamed:@"incomingDir"];
  
  xInCircleImage = [[NSImage alloc] initWithSize:NSMakeSize(14, 15)];
  [xInCircleImage lockFocus];
  NSImage *image = [NSImage imageNamed:NSImageNameStopProgressFreestandingTemplate];
  [image setSize:NSMakeSize(14, 14)];
  [image drawAtPoint:NSMakePoint(0, 1) fromRect:NSMakeRect(0, 0, 14, 14) operation:NSCompositeSourceOver fraction:1.0];
  [xInCircleImage unlockFocus];
  
  alertImage = [NSImage imageNamed:@"AlertCautionIcon"];
  smartFolderImage = [NSImage imageNamed:@"SmartFolderIcon"];
  [smartFolderImage setSize:NSMakeSize(16, 16)];
  
  // NSOpenPanel *openPanel = [NSOpenPanel openPanel];
  // [openPanel setCanChooseFiles:YES];
  // [openPanel setCanChooseDirectories:YES];
  // [openPanel setAllowsMultipleSelection:YES];
  // shareView = [openPanel contentView];
}

- (void)appendString: (NSString *)str
{
  id textView = [consoleView documentView];
  id storage = [textView textStorage];
  [storage appendAttributedString: [[NSAttributedString alloc] initWithString: str]];
  [textView scrollRangeToVisible:NSMakeRange([storage length], 0)];
}

- (void)log: (NSString *)format, ...
{
  va_list args;
  va_start(args, format);
  [self appendString:[[NSString alloc] initWithFormat:format arguments:args]];
  va_end(args);
}

- (IBAction)showConsole: sender
{
  [self showView:consoleView];
  currentManager = nil;
}

- (IBAction)showSearch: sender
{
  [self showView:searchView];
  currentManager = searchManager;
  [[self window] makeFirstResponder:searchField];
//  [searchManager resetIndicators];
}

- (IBAction)showTransfer:sender
{
  [self showView:transferView];
  currentManager = transferManager;
  [protocolHandler sendGetDownloadingFiles];
  [protocolHandler sendGetUploaders];
}

- (IBAction)showServer:sender
{
  [self showView:serverView];
  currentManager = serverManager;
}

- (IBAction)showShare:sender
{
  [self showView:shareView];
  currentManager = shareManager;
}

- (IBAction)showOption:sender
{
  [self showView:optionView];
  currentManager = optionManager;
}

- (IBAction)showMlnet:sender
{
  [self showView:mlnetView];
  currentManager = mlnetManager;
}

- (BOOL)showingShare
{
  return currentManager == shareManager;
}

- (BOOL)validateUserInterfaceItem:item
{
  SEL action = [item action];
  if ([currentManager respondsToSelector:action]) {
    return [currentManager validateUserInterfaceItem:item];
  }

  int state = NSOffState;
  if (action == @selector(showConsole:) && currentView == consoleView) {
    state = NSOnState;
  } else if (action == @selector(showSearch:) && (currentView == searchView || protocolHandler.status != NgConnected)) {
    state = NSOnState;
  } else if (action == @selector(showTransfer:) && (currentView == transferView || protocolHandler.status != NgConnected)) {
    state = NSOnState;
  } else if (action == @selector(showServer:) && (currentView == serverView || protocolHandler.status != NgConnected)) {
    state = NSOnState;
  } else if (action == @selector(showShare:) && (currentView == shareView || protocolHandler.status != NgConnected)) {
    state = NSOnState;
  } else if (action == @selector(showOption:) && (currentView == optionView || protocolHandler.status != NgConnected)) {
    state = NSOnState;
  } else if (action == @selector(showMlnet:) && currentView == mlnetView) {
    state = NSOnState;
  }
  if ([item respondsToSelector:@selector(setState:)]) {
    [item setState:state];
  }
  return YES;
}

- (NSArray *)toolbarSelectableItemIdentifiers:(NSToolbar *)toolbar
{
  return [NSArray arrayWithObjects:@"A731DC45-824F-4044-A010-627662453FE0",
                                   @"896DEB5E-0124-4836-A168-D5575E55C72C",
                                   @"DD77F32C-DC3F-4299-BEB9-8601669CC629",
                                   @"89177CF5-EF5B-4187-B9E0-C662D8843888",
                                   @"7E2B68D8-67D0-460B-843A-ABE767FE33A0",
                                   @"35598249-6DD6-4F6D-B94E-B9376C25E6CD",
                                   @"A0CC9CDC-E16B-4F60-BAC9-433B5FAC44D5", nil];
}

- (void)alert:(NSString *)msg informative:(NSString *)informative
{
  if (!alert) {
    alert = [[NSAlert alloc] init];
  }
  [alert setMessageText:msg];
  [alert setInformativeText:informative];
  [alert beginSheetModalForWindow:[self window] modalDelegate:nil didEndSelector:nil contextInfo:nil];
}

- (void)error:(OSStatus)error
{
  switch (error) {
    case dupFNErr:
      [self alert:@"Same file exists" informative:@""];
      break;
    case paramErr:
      [self alert:@"Can't copy file" informative:@"(file name is too long?)"];
      break;
    default:
      [self alert:[NSString stringWithFormat:@"Error %d", error] informative:@""];
      break;
  }
}

- (BOOL)askDelete:(NSString *)fileName
{
  if (!askDelete) {
    askDelete = [[NSAlert alloc] init];
    [askDelete setAlertStyle:NSCriticalAlertStyle];
    [askDelete addButtonWithTitle:@"Delete"];
    [askDelete addButtonWithTitle:@"Cancel"];
    [[[askDelete buttons] objectAtIndex:0] setKeyEquivalent:@""];
    [[[askDelete buttons] objectAtIndex:1] setKeyEquivalent:@"\r"];
  }
  [askDelete setMessageText:[NSString stringWithFormat:@"Can't recycle '%@'. Permanently delete it?", fileName]];
  int r = [askDelete runModal];
//  [askDelete beginSheetModalForWindow:[self window] modalDelegate:self
//                       didEndSelector:@selector(askDeleteDidEnd:returnCode:contextInfo:) contextInfo:nil];

  return r == NSAlertFirstButtonReturn;
}

//- (void)askDeleteDidEnd:(NSAlert *)askDelete returnCode:(int)returnCode contextInfo:(void *)contextInfo
//{
//  NSLog(@"return %d", returnCode);
//}

- (void)copy:sender
{
  [currentManager copy:sender];
}

- (void)paste:sender
{
  [currentManager paste:sender];
}

@end
