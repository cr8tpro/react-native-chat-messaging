/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "AppDelegate.h"

#import <React/RCTBundleURLProvider.h>
#import <React/RCTRootView.h>
#import <Applozic/Applozic.h>

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  NSURL *jsCodeLocation;

  jsCodeLocation = [[RCTBundleURLProvider sharedSettings] jsBundleURLForBundleRoot:@"index" fallbackResource:nil];

  RCTRootView *rootView = [[RCTRootView alloc] initWithBundleURL:jsCodeLocation
                                                      moduleName:@"ApplozicSample"
                                               initialProperties:nil
                                                   launchOptions:launchOptions];
  rootView.backgroundColor = [[UIColor alloc] initWithRed:1.0f green:1.0f blue:1.0f alpha:1];

  self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
  UIViewController *rootViewController = [UIViewController new];
  rootViewController.view = rootView;
  self.window.rootViewController = rootViewController;
  [self.window makeKeyAndVisible];
  //========================= Applozic code ===============================
  
  return YES;
}


- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)
deviceToken {
  
  const unsigned *tokenBytes = [deviceToken bytes];
  NSString *hexToken = [NSString stringWithFormat:@"%08x%08x%08x%08x%08x%08x%08x%08x",
                        ntohl(tokenBytes[0]), ntohl(tokenBytes[1]), ntohl(tokenBytes[2]),
                        ntohl(tokenBytes[3]), ntohl(tokenBytes[4]), ntohl(tokenBytes[5]),
                        ntohl(tokenBytes[6]), ntohl(tokenBytes[7])];
  
  NSString *apnDeviceToken = hexToken;
  NSLog(@"apnDeviceToken: %@", hexToken);
  
  if (![[ALUserDefaultsHandler getApnDeviceToken] isEqualToString:apnDeviceToken]) {
    ALRegisterUserClientService *registerUserClientService = [[ALRegisterUserClientService alloc] init];
    [registerUserClientService updateApnDeviceTokenWithCompletion
     :apnDeviceToken withCompletion:^(ALRegistrationResponse
                                      *rResponse, NSError *error) {
       
       if (error) {
         NSLog(@"%@",error);
         return;
       }
       NSLog(@"Registration response%@", rResponse);
     }];
  }
}


- (void)application:(UIApplication*)application didReceiveRemoteNotification:(NSDictionary*)dictionary {
  
  NSLog(@"Received notification WithoutCompletion: %@", dictionary);
  ALPushNotificationService *pushNotificationService = [[ALPushNotificationService alloc] init];
  [pushNotificationService notificationArrivedToApplication:application withDictionary:dictionary];
}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(nonnull void (^)(UIBackgroundFetchResult))completionHandler {
  
  NSLog(@"Received notification Completion: %@", userInfo);
  ALPushNotificationService *pushNotificationService = [[ALPushNotificationService alloc] init];
  [pushNotificationService notificationArrivedToApplication:application withDictionary:userInfo];
  completionHandler(UIBackgroundFetchResultNewData);
  
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
  
  ALRegisterUserClientService *registerUserClientService = [[ALRegisterUserClientService alloc] init];
  [registerUserClientService disconnect];
  [[NSNotificationCenter defaultCenter] postNotificationName:@"APP_ENTER_IN_BACKGROUND" object:nil];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
  
  ALRegisterUserClientService *registerUserClientService = [[ALRegisterUserClientService alloc] init];
  [registerUserClientService connect];
  [ALPushNotificationService applicationEntersForeground];
  [[NSNotificationCenter defaultCenter] postNotificationName:@"APP_ENTER_IN_FOREGROUND" object:nil];
}

- (void)applicationWillTerminate:(UIApplication *)application {
  [[ALDBHandler sharedInstance] saveContext];
}

@end
