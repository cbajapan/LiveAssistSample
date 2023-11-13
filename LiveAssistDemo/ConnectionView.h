#import <UIKit/UIKit.h>

@import AssistSDK;

@interface ConnectionView : UIView<ASDKConnectionStatusDelegate>

- (void) reset;
@end
