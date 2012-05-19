//
//  AppDelegate.m
//  ClipboardPlain
//
//  Created by davide ficano on 15/05/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"

#define gUserDefaults [NSUserDefaults standardUserDefaults]

NSString* const CPPrefAutomatic = @"emautomaticRemoveFormatpty";
NSString* const CPPrefTransformation = @"trasformation";

enum {
    CPLaunchMenuTag = 1000
};

@interface AppDelegate()

@property (retain) NSArray* supportedTypes;
- (void)startTimer;
- (void)pollPasteboard:(NSTimer *)timer;
- (void)cleanContent;
@end

@implementation AppDelegate

@synthesize supportedTypes = _supportedTypes;
@synthesize window = _window;
@synthesize statusItem = _statusItem;
@synthesize pasteboard = _pasteboard;
@synthesize timer = _timer;

- (void)awakeFromNib {
    self.supportedTypes = [NSArray arrayWithObject: NSStringPboardType];

    NSBundle *bundle = [NSBundle mainBundle];
    
    statusImage = [[NSImage alloc] initWithContentsOfFile:[bundle pathForResource:@"statusBarIcon" ofType:@"png"]];

    NSStatusBar* bar = [NSStatusBar systemStatusBar];
    
    self.statusItem = [bar statusItemWithLength:NSVariableStatusItemLength];
    self.statusItem.menu = theMenu;
    self.statusItem.image = statusImage;
}

- (void)dealloc {
    [statusImage release];
    [super dealloc];
}
	
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    self.pasteboard = [NSPasteboard generalPasteboard];
    isAutomatic = YES;
    trasformation = CPTransformationNone;
    NSNumber* num = [gUserDefaults objectForKey:CPPrefAutomatic];
    
    if (num) {
        isAutomatic = [num boolValue];
    }
    num = [gUserDefaults objectForKey:CPPrefTransformation];
    if (num) {
        trasformation = [num intValue];
    }
    isLaunchAtStartup = NO;

    [[theMenu itemWithTag:CPLaunchMenuTag] setState:isLaunchAtStartup ? NSOnState : NSOffState];
    [[theMenu itemWithTag:trasformation] setState:NSOnState];
    if (isAutomatic) {
        [self startTimer];
    }
}

#pragma mark -
#pragma mark Menu messages

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem {
    SEL action = [menuItem action];

    if (action == @selector(removeFormatNow:)) {
        return !isAutomatic;
    }
    return YES;
}

- (IBAction)toggleAutomaticFormat:(id)sender {
    isAutomatic = !isAutomatic;
    [sender setState:isAutomatic ? NSOnState : NSOffState];

    if (isAutomatic) {
        [self startTimer];
    } else {
        [self.timer invalidate];
    }
    [gUserDefaults setBool:isAutomatic forKey:CPPrefAutomatic];
}

- (IBAction)removeFormatNow:(id)sender {
    [self cleanContent];
}

- (IBAction)trasformation:(id)sender {
    NSInteger newValue = [sender tag];
    
    if (trasformation != newValue) {
        [[theMenu itemWithTag:trasformation] setState:NSOffState];
        [sender setState:NSOnState];
        trasformation = newValue;
        
        [gUserDefaults setInteger:trasformation forKey:CPPrefTransformation];
    }
}

- (IBAction)toggleLaunchAtStartup:(id)sender {
    isLaunchAtStartup = !isLaunchAtStartup;
    [sender setState:isLaunchAtStartup ? NSOnState : NSOffState];
}

#pragma mark -
#pragma mark Private messages

- (void)startTimer {
    previousChangeCount = self.pasteboard.changeCount;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.75
                                                  target:self
                                                selector:@selector(pollPasteboard:)
                                                userInfo:nil
                                                 repeats:YES];
}

- (void)pollPasteboard:(NSTimer *)timer {
    NSInteger currentChangeCount = self.pasteboard.changeCount;
    if (currentChangeCount == previousChangeCount || changingPasteboard) {
        return;
    }
    [self cleanContent];
}

- (void)cleanContent {
    NSString* bestType = [self.pasteboard availableTypeFromArray:self.supportedTypes];
    NSString* text = [self.pasteboard stringForType:bestType];
    
    if (text) {
        changingPasteboard = YES;
        switch (trasformation) {
            case CPTransformationAllLowercase:
                text = [text lowercaseString];
                break;
            case CPTransformationAllUppercase:
                text = [text uppercaseString];
                break;
            case CPTransformationCapitalized:
                text = [text capitalizedString];
                break;
        }
        [self.pasteboard clearContents];
        [self.pasteboard writeObjects:[NSArray arrayWithObject:text]];
        changingPasteboard = NO;
    }
    previousChangeCount = self.pasteboard.changeCount;
}
@end
