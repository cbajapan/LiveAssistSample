#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@import AssistSDK;

@interface TabViewController : UITabBarController<AssistSDKDocumentDelegate,ASDKScreenShareRequestedDelegate, UrlOpenDelegate,AssistSDKDelegate>
@end
