#import "SCFriendListItemCell.h"
#import "SCAppDelegate.h"
#import "SCSafeUnicode.h"
#import <DeepEnd/DeepEnd.h>

@implementation SCFriendListItemCell {
    DESFriend *referencedFriend;
    CGFloat originalOriginX;
}

- (void)awakeFromNib {
    self.userImage.layer.cornerRadius = 2.0;
    self.userImage.layer.masksToBounds = YES;
    originalOriginX = self.userStatus.frame.origin.x;
    if ([NSColor currentControlTint] == NSBlueControlTint)
        self.unreadIndicator.image = [NSImage imageNamed:@"unread-blue"];
    else
        self.unreadIndicator.image = [NSImage imageNamed:@"unread-grey"];
}

- (NSString *)defaultStringForStatusType:(DESStatusType)kind {
    switch (kind) {
        case DESStatusTypeOnline: return NSLocalizedString(@"Online", @"");
        case DESStatusTypeAway: return NSLocalizedString(@"Away", @"");
        case DESStatusTypeBusy: return NSLocalizedString(@"Busy", @"");
        default: return NSLocalizedString(@"Invalid", @"");
    }
}

- (void)changeDisplayName:(NSString *)aName {
    if ([aName isEqualToString:@""]) {
        self.displayName.stringValue = referencedFriend ? referencedFriend.publicKey : @"";
        self.displayName.textColor = [NSColor colorWithCalibratedWhite:0.8 alpha:1.0];
    } else {
        self.displayName.stringValue = SC_SANITIZED_STRING(aName);
        self.displayName.textColor = [NSColor whiteColor];
    }
    self.displayName.toolTip = self.displayName.stringValue;
}

- (void)changeUserStatus:(NSString *)aStatus {
    if ([aStatus isEqualToString:@""]) {
        self.userStatus.stringValue = referencedFriend ? [self defaultStringForStatusType:referencedFriend.statusType] : @"";
    } else {
        self.userStatus.stringValue = SC_SANITIZED_STRING(aStatus);
    }
    self.userStatus.toolTip = aStatus;
}

- (void)changeUnreadIndicatorState:(BOOL)hidden {
    if (hidden) {
        self.unreadIndicator.hidden = YES;
    } else {
        self.unreadIndicator.hidden = NO;
    }
    [self.displayName setFrameSize:(NSSize){self.frame.size.width - self.statusLight.frame.origin.x - 8 - (self.unreadIndicator.isHidden ? 0 : 16), self.displayName.frame.size.height}];
    if (referencedFriend.status != DESFriendStatusOnline) {
        [self.userStatus setFrame:(NSRect){{self.statusLight.frame.origin.x, self.userStatus.frame.origin.y}, {self.frame.size.width - self.statusLight.frame.origin.x - 8 - (self.unreadIndicator.isHidden ? 0 : 16), self.userStatus.frame.size.height}}];
    } else {
        [self.userStatus setFrame:(NSRect){{originalOriginX, self.userStatus.frame.origin.y}, {self.frame.size.width - originalOriginX - 8 - (self.unreadIndicator.isHidden ? 0 : 16), self.userStatus.frame.size.height}}];
    }
}

- (void)bindToFriend:(DESFriend *)aFriend {
    referencedFriend = aFriend;
    [aFriend addObserver:self forKeyPath:@"userStatus" options:NSKeyValueObservingOptionNew context:NULL];
    [aFriend addObserver:self forKeyPath:@"displayName" options:NSKeyValueObservingOptionNew context:NULL];
    [aFriend addObserver:self forKeyPath:@"statusType" options:NSKeyValueObservingOptionNew context:NULL];
    [aFriend addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:NULL];
    [self changeDisplayName:aFriend.displayName];
    switch (referencedFriend.statusType) {
        case DESStatusTypeAway:
            self.statusLight.image = [NSImage imageNamed:@"status-light-away"];
            break;
        case DESStatusTypeBusy:
            self.statusLight.image = [NSImage imageNamed:@"status-light-offline"];
            break;
        default:
            self.statusLight.image = [NSImage imageNamed:@"status-light-online"];
            break;
    }
    if (referencedFriend.status != DESFriendStatusOnline) {
        self.statusLight.hidden = YES;
        [self.userStatus setFrameOrigin:(NSPoint){self.statusLight.frame.origin.x, self.userStatus.frame.origin.y}];
        switch (referencedFriend.status) {
            case DESFriendStatusConfirmed: self.userStatus.stringValue = NSLocalizedString(@"Offline", @"");
            case DESFriendStatusRequestSent: self.userStatus.stringValue = NSLocalizedString(@"Request sent...", @"");
            case DESFriendStatusOffline: self.userStatus.stringValue = NSLocalizedString(@"Offline", @"");
            default: self.userStatus.stringValue = NSLocalizedString(@"Offline", @"");
        }
    } else {
        self.statusLight.hidden = NO;
        [self.userStatus setFrameOrigin:(NSPoint){originalOriginX, self.userStatus.frame.origin.y}];
        [self changeUserStatus:aFriend.userStatus];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object == referencedFriend) {
        if ([keyPath isEqualToString:@"userStatus"]) {
            [self changeUserStatus:change[NSKeyValueChangeNewKey]];
        } else if ([keyPath isEqualToString:@"displayName"]) {
            [self changeDisplayName:change[NSKeyValueChangeNewKey]];
        } else if ([keyPath isEqualToString:@"statusType"] || [keyPath isEqualToString:@"status"]) {
            switch (referencedFriend.statusType) {
                case DESStatusTypeAway:
                    self.statusLight.image = [NSImage imageNamed:@"status-light-away"];
                    break;
                case DESStatusTypeBusy:
                    self.statusLight.image = [NSImage imageNamed:@"status-light-offline"];
                    break;
                default:
                    self.statusLight.image = [NSImage imageNamed:@"status-light-online"];
                    break;
            }
            if (referencedFriend.status != DESFriendStatusOnline) {
                self.statusLight.hidden = YES;
                [self.userStatus setFrame:(NSRect){{self.statusLight.frame.origin.x, self.userStatus.frame.origin.y}, {self.frame.size.width - self.statusLight.frame.origin.x - 8 - (self.unreadIndicator.isHidden ? 0 : 16), self.userStatus.frame.size.height}}];
                switch (referencedFriend.status) {
                    case DESFriendStatusConfirmed: self.userStatus.stringValue = NSLocalizedString(@"Offline", @"");
                    case DESFriendStatusRequestSent: self.userStatus.stringValue = NSLocalizedString(@"Request sent...", @"");
                    case DESFriendStatusOffline: self.userStatus.stringValue = NSLocalizedString(@"Offline", @"");
                    default: self.userStatus.stringValue = NSLocalizedString(@"Offline", @"");
                }
            } else {
                self.statusLight.hidden = NO;
                [self.userStatus setFrame:(NSRect){{originalOriginX, self.userStatus.frame.origin.y}, {self.frame.size.width - originalOriginX - 8 - (self.unreadIndicator.isHidden ? 0 : 16), self.userStatus.frame.size.height}}];
                [self changeUserStatus:referencedFriend.userStatus];
            }
        }
    }
}

- (IBAction)copyPublicKey:(id)sender {
    [[NSPasteboard generalPasteboard] clearContents];
    [[NSPasteboard generalPasteboard] writeObjects:@[referencedFriend.publicKey]];
}

- (IBAction)forkNewWindow:(id)sender {
    [(SCAppDelegate*)[NSApp delegate] newWindowWithDESContext:[[DESToxNetworkConnection sharedConnection].friendManager chatContextForFriend:referencedFriend]];
}

- (IBAction)deleteFriend:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"deleteFriend" object:nil userInfo:@{@"friend": referencedFriend}];
}

- (void)prepareForReuse {
    [referencedFriend removeObserver:self forKeyPath:@"userStatus"];
    [referencedFriend removeObserver:self forKeyPath:@"displayName"];
    [referencedFriend removeObserver:self forKeyPath:@"statusType"];
    [referencedFriend removeObserver:self forKeyPath:@"status"];
    referencedFriend = nil;
}

- (void)dealloc {
    [self prepareForReuse];
}

#ifndef POISON_USES_ALTERNATE_FRIENDCELL_DRAW_STYLE

- (void)drawRect:(NSRect)dirtyRect {
    if (self.isSelected) {
        NSGradient *shadowGrad = [[NSGradient alloc] initWithStartingColor:[NSColor clearColor] endingColor:[NSColor colorWithCalibratedWhite:0.071 alpha:0.3]];
        [[NSColor colorWithCalibratedWhite:0.118 alpha:1.0] set];
        [[NSBezierPath bezierPathWithRect:self.bounds] fill];
        [shadowGrad drawInBezierPath:[NSBezierPath bezierPathWithOvalInRect:NSMakeRect(0, -4, self.bounds.size.width, 8)] angle:-90.0];
        [shadowGrad drawInBezierPath:[NSBezierPath bezierPathWithOvalInRect:NSMakeRect(0, self.bounds.size.height - 4, self.bounds.size.width, 8)] angle:90.0];
    }
}

#else

/* Based on a mockup posted on /g/. Define the macro 
 * POISON_USES_ALTERNATE_FRIENDCELL_DRAW_STYLE to use it. */

- (void)drawRect:(NSRect)dirtyRect {
    if (self.isSelected) {
        [[NSColor colorWithCalibratedWhite:0.04 alpha:1.0] set];
        [[NSBezierPath bezierPathWithRect:NSMakeRect(-2, 0, self.bounds.size.width + 2, self.bounds.size.height)] stroke];
        [[NSColor colorWithCalibratedWhite:1.0 alpha:0.35] set];
        [[NSBezierPath bezierPathWithRect:NSMakeRect(0, self.bounds.size.height - 2, self.bounds.size.width, 1)] fill];
        [[NSColor colorWithCalibratedWhite:1.0 alpha:0.20] set];
        [[NSBezierPath bezierPathWithRect:NSMakeRect(0, 1, self.bounds.size.width, 1)] fill];
        NSGradient *bodyGrad = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:1.0 alpha:0.10] endingColor:[NSColor colorWithCalibratedWhite:1.0 alpha:0.20]];
        [bodyGrad drawInBezierPath:[NSBezierPath bezierPathWithRect:NSMakeRect(-2, 2, self.bounds.size.width + 2, self.bounds.size.height - 4)] angle:90.0];
    }
}

#endif

@end
