//
//  AppDelegate.h
//  LiveAssistDemo
//
//  Created by Cole M on 11/13/23.
//

#import <UIKit/UIKit.h>

@protocol UrlOpenDelegate
-(void) openWithUrl : (NSURL *) url;
@end

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property id<UrlOpenDelegate> openUrlDelegate;

@end

