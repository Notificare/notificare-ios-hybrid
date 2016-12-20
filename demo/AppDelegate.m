//
//  AppDelegate.m
//  demo
//
//  Created by Joel Oliveira on 18/12/2016.
//  Copyright © 2016 Notificare. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [[NotificarePushLib shared] launch];
    [[NotificarePushLib shared] setDelegate:self];
    [[NotificarePushLib shared] handleOptions:launchOptions];
    
    if ([UIApplicationShortcutItem class]){
        UIApplicationShortcutItem *shortcutItem = [launchOptions objectForKey:UIApplicationLaunchOptionsShortcutItemKey];
        return ![self handleShortCutItem:shortcutItem];
    }
    
    return YES;
}


- (void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void (^)(BOOL))completionHandler{
    [self handleShortCutItem:shortcutItem];
}

- (BOOL)handleShortCutItem:(UIApplicationShortcutItem *)shortcutItem {
    BOOL handled = NO;
    
    if (shortcutItem == nil) {
        return handled;
    } else {
        
        NSURL * url = [NSURL URLWithString:[shortcutItem type]];
        
        [self handleDeepLinks:url];
        
        return YES;
        
    }

}


- (BOOL)application:(UIApplication *)application openURL:(nonnull NSURL *)url sourceApplication:(nullable NSString *)sourceApplication annotation:(nonnull id)annotation{
    [[NotificarePushLib shared]  handleOpenURL:url];
    [self handleDeepLinks:url];
    
    return YES;
}

#pragma Deep Links
-(void)handleDeepLinks:(NSURL *)url{
    
    NSLog(@"%@", [url path] );
    if ([[url path] isEqualToString:@"/inbox"]) {

       [[NSNotificationCenter defaultCenter] postNotificationName:@"openInbox" object:nil];
    } else if ([[url path] isEqualToString:@"/settings"]) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"openSettings" object:nil];
    } else {
    
        
        if ([[[Configuration shared] getProperty:@"urlScheme"] isEqualToString:[url scheme]]) {
            url  = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", [[Configuration shared] getProperty:@"url"], [url path]]];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadURL" object:self userInfo:@{@"url":url}];
        
    }
    
}


- (void)notificarePushLib:(NotificarePushLib *)library onReady:(NSDictionary *)info{
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"onReady" object:nil];
    
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    
    if([settings boolForKey:@"OnBoardingFinished"]){
        
        [[NotificarePushLib shared] registerForNotifications];
    }
    
}


#pragma APNS Delegates
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    [[NotificarePushLib shared] registerDevice:deviceToken completionHandler:^(NSDictionary *info) {

        if([[NotificarePushLib shared] checkLocationUpdates]){
            [[NotificarePushLib shared] startLocationUpdates];
        }

    } errorHandler:^(NSError *error) {
        //

    }];

}


- (void)application:(UIApplication *)application handleActionWithIdentifier:(nullable NSString *)identifier forRemoteNotification:(nonnull NSDictionary *)userInfo withResponseInfo:(nonnull NSDictionary *)responseInfo completionHandler:(nonnull void (^)())completionHandler{
    
    
    [[NotificarePushLib shared] handleAction:identifier forNotification:userInfo withData:responseInfo completionHandler:^(NSDictionary *info) {
        completionHandler();
    } errorHandler:^(NSError *error) {
        completionHandler();
    }];
    
    
}



- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error{
    
    NSLog(@"%@", error);

}




- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler{
    
    [[NotificarePushLib shared] handleNotification:userInfo forApplication:application completionHandler:^(NSDictionary *info) {
        
        completionHandler(UIBackgroundFetchResultNewData);
    } errorHandler:^(NSError *error) {
        
        completionHandler(UIBackgroundFetchResultNoData);
    }];

}


-(void)notificarePushLib:(NotificarePushLib *)library willHandleNotification:(nonnull UNNotification *)notification{
    
    [[NotificarePushLib shared] handleNotification:notification completionHandler:^(NSDictionary * _Nonnull info) {
        //
    } errorHandler:^(NSError * _Nonnull error) {
        //
    }];
}

- (void)notificarePushLib:(NotificarePushLib *)library didUpdateBadge:(int)badge{

    NSLog(@"didUpdateBadge: %i", badge);
    [[NSNotificationCenter defaultCenter] postNotificationName:@"newNotification" object:nil];
    
}



- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
