#import <Foundation/Foundation.h>

@interface DynamicMasker : NSObject

+ (instancetype) createWithHiddenTags:(NSSet *)hiddenTags maskedTags:(NSSet *)maskedTags;
+ (instancetype)sharedInstance;
- (void) storeHiddenOrMaskedViews:(NSArray *)views;
- (void) setHidingAndMasking:(bool) hidingAndMasking;

- (NSSet *) maskedTags;
@end
