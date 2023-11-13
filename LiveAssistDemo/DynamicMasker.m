#import "DynamicMasker.h"
#import <math.h>
#import <UIKit/UIKit.h>

@implementation DynamicMasker {
    NSSet *hiddenTags;
    NSSet *maskedTags;
    NSMutableSet *hiddenViews;
    NSMutableSet *maskedViews;
    BOOL isMasking;
}

__strong static DynamicMasker *single = nil;

+ (instancetype) createWithHiddenTags:(NSSet *)pHiddenTags maskedTags:(NSSet *)pMaskedTags {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (single == nil) {
            single = [[[self class] alloc] initWithHiddenTags:pHiddenTags maskedTags:pMaskedTags];
            
        }
    });
    
    return single;
}

- (id) initWithHiddenTags:(NSSet *)pHiddenTags maskedTags:(NSSet *)pMaskedTags {
    if (self = [super init]) {
        hiddenTags = pHiddenTags;
        maskedTags = pMaskedTags;
        hiddenViews = [NSMutableSet set];
        maskedViews = [NSMutableSet set];
        isMasking = YES;
    }
    return self;
}

+ (instancetype)sharedInstance;
{
    return single;
}

- (void) storeHiddenOrMaskedViews:(NSArray *)views {
    
    for (UIView *view in views) {
        NSNumber *tag = [NSNumber numberWithLong:[view tag]];
        if ([hiddenTags containsObject:tag]) {
            [hiddenViews addObject:view];
        } else if ([maskedTags containsObject:tag]) {
            [maskedViews addObject:view];
        }
        [self storeHiddenOrMaskedViews:[view subviews]];
    }
}

- (void) setHidingAndMasking:(bool) newHidingAndMasking {
    isMasking = newHidingAndMasking;
    
    // Negate sign of tags... Simplest way of unhiding/re-hiding
    for (UIView *hidden in hiddenViews) {
        if (newHidingAndMasking) {
            hidden.tag = labs(hidden.tag);
        }
        else {
            hidden.tag = -labs(hidden.tag);
        }
    }
    for (UIView *masked in maskedViews) {
        if (newHidingAndMasking) {
            masked.tag = labs(masked.tag);
        }
        else {
            masked.tag = -labs(masked.tag);
        }
    }
}

- (NSSet *) maskedTags {
    return maskedTags;
}
@end
