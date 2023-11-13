//
//  AppDelegate.m
//  LiveAssistDemo
//
//  Created by Cole M on 11/13/23.
//

#import "AppDelegate.h"
#import "NSUserDefaults+BundleSettings.h"
#import "SupportParameters.h"

@import AssistSDK;

#define URL_PREFIX @"la"
#define URLS_PREFIX @"las"
#define HTTP_PORT 8080
#define HTTPS_PORT 8443
#define DEFAULT_AGENT @"agent1"

@interface AppDelegate () {
  BOOL loadURLRequested;
  NSString *serverUrl;
  NSMutableDictionary *supportParameters;
}
@end

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [NSUserDefaults registerDefaultsFromSettingsBundle];
     loadURLRequested = NO;
    return YES;
}


#pragma mark - UISceneSession lifecycle


- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}


- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
  loadURLRequested = FALSE;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    
    if ([self shouldStartStartSupportCall]) {
      if (!loadURLRequested) {
          [self initialiseSupportParametersForAutoStart];
      }
        
      NSLog(@"Support Parameters %@ :", supportParameters);
      [AssistSDK startSupport:serverUrl supportParameters:supportParameters];
  }
}

-(void) initialiseSupportParametersForAutoStart {
    serverUrl = [SupportParameters serverHost];
    supportParameters = [[NSMutableDictionary alloc] initWithDictionary:[SupportParameters userDefaults]];
}


- (BOOL)shouldStartStartSupportCall {
  return loadURLRequested || [SupportParameters isAutoStartSession];
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
  loadURLRequested = NO;
    
  if (url != nil) {
    if ([self generateCredientialsFromApplicationUrl:url] == NO) {
      [self callOpenUrlDelegateWithUrl:url];
    } else {
      loadURLRequested = YES;
    }
  }

  return YES;
}

- (BOOL)isApplicationUrl:(NSURL *)url {
  return (([[url scheme] caseInsensitiveCompare:URL_PREFIX] == NSOrderedSame) ||
          ([[url scheme] caseInsensitiveCompare:URLS_PREFIX] == NSOrderedSame));
}

- (BOOL)isApplicationUrlHttpRequest:(NSURL *)url {
  return ([[url scheme] caseInsensitiveCompare:URL_PREFIX] == NSOrderedSame);
}

- (BOOL)generateCredientialsFromApplicationUrl:(NSURL *)url {
  if ([self isApplicationUrl:url]) {
    serverUrl = [self getServerUrlFromApplicationUrl:url];
      supportParameters = [[NSMutableDictionary alloc] init];
      supportParameters[@"acceptSelfSignedCerts"] = @YES;

    NSString *query = [url query];

    if ([query hasPrefix:@"agent="]) {
      supportParameters[@"destination"] = [query substringFromIndex:6];
    } else if ([query hasPrefix:@"correlationId="]) {
      supportParameters[@"correlationId"] = [query substringFromIndex:14];
        [supportParameters removeObjectForKey:@"destination"];
    }

    if ([supportParameters[@"destination"] length] == 0 &&
        supportParameters[@"correlationId"] == nil) {
      supportParameters[@"destination"] = DEFAULT_AGENT;
    }
    return YES;
  }
  return NO;
}

- (NSString *)getServerUrlFromApplicationUrl:(NSURL *)url {
  NSString *protocol =
      [self isApplicationUrlHttpRequest:url] ? @"http" : @"https";
  long port = [[url port] integerValue];

  if (!port) {
    port = [self isApplicationUrlHttpRequest:url] ? HTTP_PORT : HTTPS_PORT;
  }

  return [[NSString alloc]
      initWithFormat:@"%@://%@:%ld/", protocol, [url host], port];
}

- (void)callOpenUrlDelegateWithUrl:(NSURL *)url {
  if (_openUrlDelegate) {
    [_openUrlDelegate openWithUrl:url];
  }
}


@end
