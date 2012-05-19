//
//  AppDelegate.h
//  ClipboardPlain
//
//  Created by davide ficano on 15/05/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

enum CP_TRANSFORMATION {
    CPTransformationNone,
    CPTransformationAllUppercase,
    CPTransformationAllLowercase,
    CPTransformationCapitalized
};

@interface AppDelegate : NSObject <NSApplicationDelegate> {
    NSInteger previousChangeCount;
    NSImage* statusImage;
    BOOL changingPasteboard;

    BOOL isAutomatic;
    NSInteger trasformation;
    BOOL isLaunchAtStartup;
    
    IBOutlet NSMenu* theMenu;
}

@property (assign) IBOutlet NSWindow *window;
@property (retain) NSStatusItem *statusItem;
@property (retain) NSTimer * timer;
@property (retain) NSPasteboard* pasteboard;

@end
