#import <Cocoa/Cocoa.h>

@interface SCTextField : NSTextField

- (void)updateShadowLayerWithRect:(NSRect)rect;
- (void)clearSelection;
- (void)saveSelection;
- (void)restoreSelection;

@end
