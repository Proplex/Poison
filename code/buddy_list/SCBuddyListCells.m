#include "Copyright.h"

#import "SCBuddyListCells.h"
#import "ObjectiveTox.h"
#import "SCBuddyListShared.h"
#import "SCBuddyListController.h"

@class SCGroupMarker;
@implementation SCGroupRowView {
    NSGradient *_grad;
}

- (id)initWithFrame:(NSRect)frameRect {
    self = [super initWithFrame:frameRect];
    if (self) {
        _grad = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:0.2 alpha:1.0]
                                              endingColor:[NSColor colorWithCalibratedWhite:0.2 alpha:0.5]];
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    [_grad drawInRect:(CGRect){{dirtyRect.origin.x, 0}, {dirtyRect.size.width, self.frame.size.height}} angle:90.0];
}

@end

@implementation SCFriendRowView {
    NSGradient *_shadow;
}

- (void)drawRect:(NSRect)dirtyRect {
//    if (self.isSelected) {
//        [[NSColor colorWithCalibratedWhite:0.04 alpha:1.0] set];
//        [[NSBezierPath bezierPathWithRect:NSMakeRect(-2, 0, self.bounds.size.width + 2, self.bounds.size.height)] stroke];
//        [[NSColor colorWithCalibratedWhite:1.0 alpha:0.35] set];
//        [[NSBezierPath bezierPathWithRect:NSMakeRect(0, 1, self.bounds.size.width, 1)] fill];
//        [[NSColor colorWithCalibratedWhite:1.0 alpha:0.20] set];
//        [[NSBezierPath bezierPathWithRect:NSMakeRect(0, self.bounds.size.height - 2, self.bounds.size.width, 1)] fill];
//        NSGradient *bodyGrad = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:1.0 alpha:0.10] endingColor:[NSColor colorWithCalibratedWhite:1.0 alpha:0.20]];
//        [bodyGrad drawInBezierPath:[NSBezierPath bezierPathWithRect:NSMakeRect(-2, 2, self.bounds.size.width + 2, self.bounds.size.height - 4)] angle:-90.0];
//    }
    if (self.isSelected) {
        if (!_shadow)
            _shadow = [[NSGradient alloc] initWithStartingColor:[NSColor clearColor] endingColor:[NSColor colorWithCalibratedWhite:0.071 alpha:0.3]];
        [[NSColor colorWithCalibratedWhite:0.118 alpha:1.0] set];
        NSRectFill(dirtyRect);
        [_shadow drawInBezierPath:[NSBezierPath bezierPathWithOvalInRect:NSMakeRect(0, -4, self.bounds.size.width, 8)] angle:-90.0];
        [_shadow drawInBezierPath:[NSBezierPath bezierPathWithOvalInRect:NSMakeRect(0, self.bounds.size.height - 4, self.bounds.size.width, 8)] angle:90.0];
    }
}

@end

@implementation SCGroupCellView

- (void)setObjectValue:(SCGroupMarker *)objectValue {
    self.textField.stringValue = [objectValue.name uppercaseString] ?: @"";
    self.auxLabel.stringValue = [objectValue.other uppercaseString] ?: @"";
}

@end

@implementation SCFriendCellView {
    DESConversation *_watchingFriend;
}

- (void)removeKVOHandlers {
    [_watchingFriend removeObserver:self forKeyPath:@"presentableTitle"];
    [_watchingFriend removeObserver:self forKeyPath:@"presentableSubtitle"];
    if ([_watchingFriend conformsToProtocol:@protocol(DESFriend)])
        [_watchingFriend removeObserver:self forKeyPath:@"status"];
}

- (void)attachKVOHandlers {
    [_watchingFriend addObserver:self forKeyPath:@"presentableTitle" options:NSKeyValueObservingOptionNew context:NULL];
    [_watchingFriend addObserver:self forKeyPath:@"presentableSubtitle" options:NSKeyValueObservingOptionNew context:NULL];
    if ([_watchingFriend conformsToProtocol:@protocol(DESFriend)])
        [_watchingFriend addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:NULL];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    dispatch_async(dispatch_get_main_queue(), ^{
        id<DESConversation> obj = object;
        if ([keyPath isEqualToString:@"presentableTitle"]) {
            [self displayStringForName:obj.presentableTitle];
        } else if ([keyPath isEqualToString:@"presentableSubtitle"]) {
            [self displayStringForStatusMessage:obj.presentableSubtitle];
        } else if ([keyPath isEqualToString:@"status"]) {
            [self updateTooltipAgainstFriend:((DESFriend *)object)];
            self.light.image = SCImageForFriendStatus(((DESFriend *)object).status);
        }
    });
}

- (void)updateTooltipAgainstFriend:(DESFriend *)f {
    if (f.status != DESFriendStatusOffline) {
        NSString *address = f.address;
        uint16_t port = f.port;
        self.toolTip = [NSString stringWithFormat:
                        NSLocalizedString(@"Public Key: %@\n"
                                          "Address: %@:%hu", nil),
                        f.publicKey, address, port];
    } else {
        self.toolTip = [NSString stringWithFormat:
                        NSLocalizedString(@"Public Key: %@\n"
                                          "IP Address: None (friend is offline)", nil),
                        f.publicKey];
    }
}

- (void)displayStringForName:(NSString *)def {
    if (![_watchingFriend conformsToProtocol:@protocol(DESFriend)]) {
        self.mainLabel.stringValue = def;
        return;
    }

    NSString *custom = [self.manager lookupCustomNameForID:_watchingFriend.publicKey];
    NSCharacterSet *cs = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    def = [def stringByTrimmingCharactersInSet:cs];
    if (custom && ![custom isEqualToString:def]) {
        NSMutableAttributedString *names = [[NSMutableAttributedString alloc] initWithString:custom
                                            attributes:@{NSForegroundColorAttributeName: [NSColor whiteColor]}];
        if (![def isEqualToString:@""])
            [names appendAttributedString:[[NSAttributedString alloc]
                                           initWithString:[NSString stringWithFormat:@" (%@)", def]
                                           attributes:@{NSForegroundColorAttributeName: [NSColor disabledControlTextColor]}]];
        self.mainLabel.attributedStringValue = names;
    } else {
        if ([def isEqualToString:@""]) {
            NSMutableAttributedString *names = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"Unknown", nil)
                                                attributes:@{NSForegroundColorAttributeName: [NSColor whiteColor]}];
            [names appendAttributedString:[[NSAttributedString alloc]
                                           initWithString:[NSString stringWithFormat:@" (%@)",
                                                           [_watchingFriend.publicKey substringToIndex:8]]
                                           attributes:@{NSForegroundColorAttributeName: [NSColor disabledControlTextColor]}]];
            self.mainLabel.attributedStringValue = names;
        } else {
            self.mainLabel.stringValue = def;
        }
    }
}

- (void)displayStringForStatusMessage:(NSString *)def {
    if (![_watchingFriend conformsToProtocol:@protocol(DESFriend)]) {
        self.auxLabel.stringValue = def;
        return;
    }

    /* convert it for type-checking purposes */
    DESFriend *wf = (DESFriend *)_watchingFriend;
    if (wf.status == DESFriendStatusOffline) {
        self.auxLabel.stringValue = [self.manager formatDate:wf.lastSeen];
    } else {
        NSCharacterSet *cs = [NSCharacterSet whitespaceAndNewlineCharacterSet];
        if ([[def stringByTrimmingCharactersInSet:cs] isEqualToString:@""]) {
            self.auxLabel.stringValue = SCStringForFriendStatus(wf.status);
        } else {
            self.auxLabel.stringValue = def;
        }
    }
}

- (void)applyMaskIfRequired {
    if (self.avatarView.wantsLayer)
        return;
    self.avatarView.wantsLayer = YES;
    NSImage *mask = [NSImage imageNamed:@"avatar_mask"];
    CALayer *maskLayer = [CALayer layer];
    maskLayer.frame = (CGRect){CGPointZero, self.avatarView.frame.size};
    maskLayer.contents = (id)mask;
    self.avatarView.layer.mask = maskLayer;
}

- (void)setObjectValue:(id)objectValue {
    [self removeKVOHandlers];
    _watchingFriend = objectValue;
    if (_watchingFriend) {
        [self displayStringForName:_watchingFriend.presentableTitle];
        [self displayStringForStatusMessage:_watchingFriend.presentableSubtitle];
        if ([_watchingFriend conformsToProtocol:@protocol(DESFriend)]) {
            DESFriend *f = (DESFriend *)_watchingFriend;
            self.light.hidden = NO;
            self.light.image = SCImageForFriendStatus(f.status);
            [self updateTooltipAgainstFriend:f];
        } else {
            self.light.hidden = YES;
            self.toolTip = nil;
        }
        [self attachKVOHandlers];
    }
}

@end