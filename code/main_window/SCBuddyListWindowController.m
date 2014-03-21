//
//  SCBuddyListWindowController.m
//  Poison
//
//  Created by stal on 2/3/2014.
//  Copyright (c) 2014 Project Tox. All rights reserved.
//

#import "SCBuddyListWindowController.h"
#import "SCBuddyListController.h"
#import "DESToxConnection.h"
#import "CGGeometryExtreme.h"

#define SCBuddyListDefaultWindowFrame ((CGRect){{0, 0}, {290, 400}})
#define SCBuddyListMinimumSize ((CGSize){290, 142})

@interface SCBuddyListWindowController ()
@property (strong) SCBuddyListController *friendsListCont;
@property (weak) DESToxConnection *tox;
@end

@implementation SCBuddyListWindowController
@synthesize qrPanel;

- (instancetype)initWithDESConnection:(DESToxConnection *)tox {
    self = [self init];
    if (self) {
        NSWindow *window = [[NSWindow alloc] initWithContentRect:CGRectCentreInRect(SCBuddyListDefaultWindowFrame, [NSScreen mainScreen].visibleFrame) styleMask:NSTitledWindowMask | NSClosableWindowMask | NSMiniaturizableWindowMask | NSResizableWindowMask backing:NSBackingStoreBuffered defer:YES];
        window.restorable = NO;
        window.minSize = SCBuddyListMinimumSize;
        [window setFrameUsingName:@"MainWindow"];
        window.frameAutosaveName = @"MainWindow";
        window.title = [NSString stringWithFormat:NSLocalizedString(@"%@ \u2014 Friends", @"friends list window title"), SCApplicationInfoDictKey(@"CFBundleName")];
        self.window = window;
        self.tox = tox;
        self.friendsListCont = [[SCBuddyListController alloc] initWithNibName:@"FriendsPanel" bundle:[NSBundle mainBundle]];
        [self.friendsListCont loadView];
        self.friendsListCont.view.frame = ((NSView*)window.contentView).frame;
        self.window.contentView = self.friendsListCont.view;
    }
    return self;
}

#pragma mark - sheets and stuff

- (void)displayQRCode {
    if (!self.qrPanel)
        self.qrPanel = [[SCQRCodeSheetController alloc] initWithWindowNibName:@"QRSheet"];
    self.qrPanel.friendAddress = self.tox.friendAddress;
    self.qrPanel.name = self.tox.name;
    [NSApp beginSheet:self.qrPanel.window modalForWindow:self.window modalDelegate:self didEndSelector:@selector(didEndSheet:returnCode:contextInfo:) contextInfo:NULL];
}

- (void)didEndSheet:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo {
    [sheet orderOut:self];
}

- (void)displayAddFriend {
    return;
}

- (void)displayAddFriendWithToxSchemeURL:(NSURL *)url {
    return;
}

@end
