//
//  AppDelegate.m
//  demo
//
//  Created by Joel Oliveira on 18/12/2016.
//  Copyright © 2016 Notificare. All rights reserved.
//

#import "AppDelegate.h"
#import "NotificareAsset.h"
#import "GravatarHelper.h"
#import "ResetPasswordViewController.h"
#import "NSData+Hex.h"


@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(nullable NSDictionary *)launchOptions{
    
    [[UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[UINavigationBar class]]] setTintColor:MAIN_COLOR];
    //[[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil] setTintColor:MAIN_COLOR];
    [[UIProgressView appearance] setTrackTintColor:WILD_SAND_COLOR];
    [[UIProgressView appearance] setProgressTintColor:MAIN_COLOR];
    
    return YES;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [[NotificarePushLib shared] initializeWithKey:nil andSecret:nil];
    [[NotificarePushLib shared] launch];
    [[NotificarePushLib shared] setDelegate:self];
    
    if (@available(iOS 12.0, *)) {
        [[NotificarePushLib shared] setAuthorizationOptions:UNAuthorizationOptionAlert + UNAuthorizationOptionBadge + UNAuthorizationOptionSound + UNAuthorizationOptionProvidesAppNotificationSettings];
    }
    
    if (@available(iOS 10.0, *)) {
        [[NotificarePushLib shared] setPresentationOptions:UNNotificationPresentationOptionAlert];
        [[NotificarePushLib shared] setCategoryOptions:UNNotificationCategoryOptionCustomDismissAction];
    }
    
    if (@available(iOS 11.0, *)) {
        [[NotificarePushLib shared] setCategoryOptions:UNNotificationCategoryOptionCustomDismissAction + UNNotificationCategoryOptionHiddenPreviewsShowTitle];
    }


    [self setHostReachability:[NotificareNetworkReachability reachabilityWithHostname:@"https://google.com"]];
    [[self hostReachability] startNotifier];
    [self updateInterfaceWithReachability:[self hostReachability]];
    
    [self setInternetReachability:[NotificareNetworkReachability reachabilityForInternetConnection]];
    [[self internetReachability] startNotifier];
    [self updateInterfaceWithReachability:[self internetReachability]];
    
    [self setWifiReachability:[NotificareNetworkReachability reachabilityForLocalWiFi]];
    [[self wifiReachability] startNotifier];
    [self updateInterfaceWithReachability:[self wifiReachability]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged:)
                                                 name:kNotificareReachabilityChangedNotification
                                               object:nil];
    
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

-(BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options{
    [[NotificarePushLib shared]  handleOpenURL:url withOptions:options];
    [self handleDeepLinks:url];
    
    return YES;
}


#pragma Deep Links
-(void)handleDeepLinks:(NSURL *)url{
    
    UINavigationController *navController = (UINavigationController *)self.window.rootViewController;
    UIStoryboard *storyboard = self.window.rootViewController.storyboard;

    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    
    if ([[url path] isEqualToString:@"/inbox"]) {

        [navController pushViewController:[storyboard instantiateViewControllerWithIdentifier:[url path]] animated:YES];
        
    } else if ([[url path] isEqualToString:@"/settings"]) {
        
       [navController pushViewController:[storyboard instantiateViewControllerWithIdentifier:[url path]] animated:YES];
        
    } else if ([[url path] isEqualToString:@"/regions"]) {
        
        [navController pushViewController:[storyboard instantiateViewControllerWithIdentifier:[url path]] animated:YES];
        
    } else if ([[url path] isEqualToString:@"/profile"]) {
        
        if([[[NotificarePushLib shared] authManager] isLoggedIn]){
            
            [navController pushViewController:[storyboard instantiateViewControllerWithIdentifier:[url path]] animated:YES];
            
        } else {
            
            [navController pushViewController:[storyboard instantiateViewControllerWithIdentifier:@"/signin"] animated:YES];
        }
        
    } else if ([[url path] isEqualToString:@"/membercard"]) {
        
        if([settings objectForKey:@"memberCardSerial"]){
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"openMemberCard" object:nil];
            
        } else {
            
            [navController pushViewController:[storyboard instantiateViewControllerWithIdentifier:@"/signin"] animated:YES];
        }
        
        
    } else if ([[url path] isEqualToString:@"/signin"]) {
        
        [navController pushViewController:[storyboard instantiateViewControllerWithIdentifier:[url path]] animated:YES];
        
    } else if ([[url path] isEqualToString:@"/signup"]) {
        
        [navController pushViewController:[storyboard instantiateViewControllerWithIdentifier:[url path]] animated:YES];
        
    } else if ([[url path] isEqualToString:@"/analytics"]) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"openCustomEvents" object:nil];
        
    } else if ([[url path] isEqualToString:@"/storage"]) {
        
        [navController pushViewController:[storyboard instantiateViewControllerWithIdentifier:[url path]] animated:YES];
        
    } else if ([[url path] isEqualToString:@"/beacons"]) {

        [navController pushViewController:[storyboard instantiateViewControllerWithIdentifier:[url path]] animated:YES];
        
    } else if ([[url path] isEqualToString:@"/scan"]) {
        
        [self startScannableSession];
        
    } else if ([[url path] isEqualToString:@"/qrcode"]) {

        [[NotificarePushLib shared] fetchScannable:[url absoluteString]];
        
    } else {
    
        
        if ([[[Configuration shared] getProperty:@"urlScheme"] isEqualToString:[url scheme]]) {
            NSURL * mainURL = [NSURL URLWithString:[[Configuration shared] getProperty:@"url"]];
            url  = [NSURL URLWithString:[NSString stringWithFormat:@"%@://%@%@?%@", [mainURL scheme],  [[Configuration shared] getProperty:@"host"], [url path], [url query]]];
            NSLog(@"Openning URL: %@", [url absoluteString]);
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadURL" object:self userInfo:@{@"url":url}];
        
    }
    
}


- (void)notificarePushLib:(NotificarePushLib *)library onReady:(nonnull NotificareApplication *)application {
    
    [self initalConfig];
    
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    
    if([settings boolForKey:@"OnBoardingFinished"]){
        
        [[NotificarePushLib shared] registerForNotifications];
        
    }
    
}

- (void)notificarePushLib:(NotificarePushLib *)library shouldOpenSettings:(NotificareNotification * _Nullable)notification{
    
    UINavigationController *navController = (UINavigationController *)self.window.rootViewController;
    UIStoryboard *storyboard = self.window.rootViewController.storyboard;
    [navController pushViewController:[storyboard instantiateViewControllerWithIdentifier:@"/settings"] animated:YES];
    
}


-(void)notificarePushLib:(NotificarePushLib *)library didRegisterDevice:(NotificareDevice *)device {
    
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    
    if([settings boolForKey:@"OnBoardingFinished"]){
        
        if ([[NotificarePushLib shared] locationServicesEnabled]) {
            [[NotificarePushLib shared] startLocationUpdates];
        }
    }
    
}

-(void)notificarePushLib:(NotificarePushLib *)library didFailToRegisterForNotificationsWithError:(nonnull NSError *)error{
    
}

-(void)notificarePushLib:(NotificarePushLib *)library didChangeNotificationSettings:(BOOL)granted{
    if (granted) {
        NSLog(@"didChangeNotificationSettings GRANTED");
    } else {
        NSLog(@"didChangeNotificationSettings NOT GRANTED");
    }
}

-(void)notificarePushLib:(NotificarePushLib *)library didReceiveRemoteNotificationInForeground:(nonnull NotificareNotification *)notification withController:(id _Nullable)controller {
    
        [[NSNotificationCenter defaultCenter] postNotificationName:@"newNotification" object:nil];
}


-(void)notificarePushLib:(NotificarePushLib *)library didReceiveRemoteNotificationInBackground:(nonnull NotificareNotification *)notification withController:(id _Nullable)controller{
    NSLog(@"didReceiveRemoteNotificationInBackground %@", [notification notificationMessage]);
    
    UINavigationController *navController = (UINavigationController *)self.window.rootViewController;
    
    if ([controller isKindOfClass:[UIViewController class]]) {
        UIBarButtonItem * leftButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action:@selector(back)];
        [leftButton setTintColor:MAIN_COLOR];
        [[controller navigationItem] setLeftBarButtonItem:leftButton];
    }
    
    if (controller != nil && ![controller isKindOfClass:[UIAlertController class]]) {
        [navController setNavigationBarHidden:NO];
    }
    
    [[NotificarePushLib shared] presentNotification:notification inNavigationController:navController withController:controller];
    
}

-(void)back{
    UINavigationController *navController = (UINavigationController *)self.window.rootViewController;
    [navController popViewControllerAnimated:YES];
}

-(void)notificarePushLib:(NotificarePushLib *)library didLoadInbox:(nonnull NSArray<NotificareDeviceInbox *> *)items{
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"newNotification" object:nil];
    
}


-(void)notificarePushLib:(NotificarePushLib *)library didReceiveSystemPushInForeground:(nonnull NotificareSystemNotification *)notification{
    NSLog(@"%@", notification);
}

-(void)notificarePushLib:(NotificarePushLib *)library didReceiveSystemPushInBackground:(nonnull NotificareSystemNotification *)notification{
    NSLog(@"%@", notification);
}

-(void)notificarePushLib:(NotificarePushLib *)library didReceivePass:(nonnull NSURL *)pass inNotification:(nonnull NotificareNotification *)notification{
    
    NSData *data = [[NSData alloc] initWithContentsOfURL:pass];
    NSError *error;
    
    //init a pass object with the data
    PKPass * pkPass = [[PKPass alloc] initWithData:data error:&error];
    
    if(!error){
        //present view controller to add the pass to the library
        PKAddPassesViewController * vc = [[PKAddPassesViewController alloc] initWithPass:pkPass];
        [vc setDelegate:self];
        
        UINavigationController *navController = (UINavigationController *)self.window.rootViewController;
        
        [[NotificarePushLib shared] presentWalletPass:notification inNavigationController:navController withController:vc];
        
    }
}



- (void)notificarePushLib:(NotificarePushLib *)library didFailToStartLocationServiceWithError:(NSError *)error {
    NSLog(@"didFailToStartLocationServiceWithError: %@", error);
}

- (void)notificarePushLib:(NotificarePushLib *)library didReceiveLocationServiceAuthorizationStatus:(NotificareGeoAuthorizationStatus)status {
    
    switch (status) {
        case NotificareGeoAuthorizationStatusAuthorizedWhenInUse:
            
            NSLog(@"didReceiveLocationServiceAuthorizationStatus: NotificareGeoAuthorizationStatusAuthorizedWhenInUse");
            break;
        case NotificareGeoAuthorizationStatusAuthorizedAlways:
            
            NSLog(@"didReceiveLocationServiceAuthorizationStatus: NotificareGeoAuthorizationStatusAuthorizedAlways");
            break;
        default:
            break;
    }
}

- (void)notificarePushLib:(NotificarePushLib *)library didUpdateLocations:(NSArray<NotificareLocation*> *)locations {
    NSLog(@"didUpdateLocations: %@", locations);
    
    /*
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    UNMutableNotificationContent *content = [UNMutableNotificationContent new];
    content.title = @"TEST";
    content.body = [NSString stringWithFormat:@"Did update with %lu locations", [locations count]];
    content.sound = [UNNotificationSound defaultSound];
    NSString *identifier = [NSString stringWithFormat:@"%@", [NSDate new]];
    UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:3 repeats:NO];
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:identifier content:content trigger:trigger];
    
    [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
        
    }];
     */
    
}
- (void)notificarePushLib:(NotificarePushLib *)library monitoringDidFailForRegion:(id)region withError:(NSError *)error {
    NSLog(@"monitoringDidFailForRegion: %@ - %@", region, error);
}

- (void)notificarePushLib:(NotificarePushLib *)library didStartMonitoringForRegion:(id)region {
    NSLog(@"didStartMonitoringForRegion: %@", region);
}

- (void)notificarePushLib:(NotificarePushLib *)library didDetermineState:(NotificareRegionState)state forRegion:(id)region {
    //NSLog(@"didDetermineState: %@ - %lii", region,(long) (long)state);
    
    /*
    if ([region isKindOfClass:[NotificareRegion class]]) {
        
        if (state == NotificareRegionStateInside) {
            UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
            UNMutableNotificationContent *content = [UNMutableNotificationContent new];
            content.title = @"TEST";
            content.body = [NSString stringWithFormat:@"Is Inside %@", [region regionName]];
            content.sound = [UNNotificationSound defaultSound];
            NSString *identifier = [NSString stringWithFormat:@"%@", [region regionId]];
            UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:3 repeats:NO];
            UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:identifier content:content trigger:trigger];
            
            [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
                
            }];
        }
        
        if (state == NotificareRegionStateOutside) {
            UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
            UNMutableNotificationContent *content = [UNMutableNotificationContent new];
            content.title = @"TEST";
            content.body = [NSString stringWithFormat:@"Is Outside %@", [region regionName]];
            content.sound = [UNNotificationSound defaultSound];
            NSString *identifier = [NSString stringWithFormat:@"%@", [region regionId]];
            UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:3 repeats:NO];
            UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:identifier content:content trigger:trigger];
            
            [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
                
            }];
        }
    }
    */
    
}
- (void)notificarePushLib:(NotificarePushLib *)library didEnterRegion:(id)region {
    NSLog(@"didEnterRegion: %@", region);
}
- (void)notificarePushLib:(NotificarePushLib *)library didExitRegion:(id)region {
    NSLog(@"didExitRegion: %@", region);
}

- (void)notificarePushLib:(NotificarePushLib *)library rangingBeaconsDidFailForRegion:(NotificareBeacon *)region withError:(NSError *)error {
    NSLog(@"rangingBeaconsDidFailForRegion: %@ - %@", region, error);
}

- (void)notificarePushLib:(NotificarePushLib *)library didRangeBeacons:(NSArray<NotificareBeacon *> *)beacons inRegion:(NotificareBeacon *)region {
    [self setBeacons:beacons];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"beaconsReload" object:nil];
    
}

- (void)notificarePushLib:(NotificarePushLib *)library didUpdateHeading:(nonnull NotificareHeading *)heading {
    NSLog(@"didUpdateHeading: %@", heading);
}

- (void)notificarePushLib:(NotificarePushLib *)library didVisit:(nonnull NotificareVisit *)visit {
    NSLog(@"didVisit: %@", visit);
}

- (void)notificarePushLib:(NotificarePushLib *)library didUpdateBadge:(int)badge{

    [[NSNotificationCenter defaultCenter] postNotificationName:@"badgeUpdate" object:nil];
    
}


-(void)notificarePushLib:(NotificarePushLib *)library didClickURL:(nonnull NSURL *)url inNotification:(nonnull NotificareNotification *)notification{

    [self handleDeepLinks:url];
    //[self performSelector:@selector(handleDeepLinks:) withObject:url afterDelay:1.0];
    
}

/*!
 * Called by Reachability whenever status changes.
 */
- (void) reachabilityChanged:(NSNotification *)note
{
    if([[note object] isKindOfClass:[NotificareNetworkReachability class]]){
        NotificareNetworkReachability* curReach = [note object];
        [self updateInterfaceWithReachability:curReach];
    }
    
}

- (void)updateInterfaceWithReachability:(NotificareNetworkReachability *)reachability
{
    
    if (reachability == [self internetReachability]){
        [self checkReachability:reachability];
    }
    
    if (reachability == [self wifiReachability]){
        [self checkReachability:reachability];
    }
    
}

-(void)checkReachability:(NotificareNetworkReachability *)reachability{
    
    NotificareNetworkStatus netStatus = [reachability currentReachabilityStatus];
    
    switch (netStatus)
    {
        case NotificareNotReachable:        {
            [self setHasInternet:NO];
            [self performSelector:@selector(showNoInternetView) withObject:nil afterDelay:.5];
            break;
        }
            
        case NotificareReachableViaWWAN:        {
            [self setHasInternet:YES];
            [self performSelector:@selector(hideNoInternetView) withObject:nil afterDelay:1.0];
            break;
        }
        case NotificareReachableViaWiFi:        {
            [self setHasInternet:YES];
            [self performSelector:@selector(hideNoInternetView) withObject:nil afterDelay:1.0];
            break;
        }
    }
    
}

-(void)showNoInternetView{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(showNoInternetView) object:nil];
    
    if(![self NoInternetViewIsOpen]){
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        NoInternetViewController *lvc = [storyboard instantiateViewControllerWithIdentifier:@"NoInternet"];
        
        [self.window.rootViewController presentViewController:lvc animated:YES completion:^{
            //
            [self setNoInternetViewIsOpen:YES];
        }];
    }
    
    
}

-(void)hideNoInternetView{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideNoInternetView) object:nil];
    
    if([self NoInternetViewIsOpen]){
        [self.window.rootViewController dismissViewControllerAnimated:YES completion:^{
            //
        }];
    }
    
}



-(void)initalConfig{

    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    
    [[NotificarePushLib shared] fetchAssets:@"CONFIG" completionHandler:^(id  _Nullable response, NSError * _Nullable error) {
        
        if (!error) {
            
            if (response && [response count] > 0 && [response firstObject]) {
                
                NotificareAsset * configAsset = (NotificareAsset*)[response firstObject];
                
                NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?x=%@", [configAsset assetUrl],  [NSString stringWithFormat:@"%.0f", [[NSDate new] timeIntervalSince1970]]]];
                
                NSURLSession *session = [NSURLSession sharedSession];
                
                [[session dataTaskWithURL:url
                        completionHandler:^(NSData *data,
                                            NSURLResponse *response,
                                            NSError *fileError) {
                            
                            if (!fileError) {
                                
                                NSError *errorJson=nil;
                                NSDictionary* responseDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&errorJson];

                                [settings setObject:responseDict forKey:@"configFile"];
                                [settings synchronize];
                                
                                [[NotificarePushLib shared] fetchAssets:@"CUSTOMJS" completionHandler:^(id  _Nullable response, NSError * _Nullable error) {
                                    if (!error) {
                                        
                                        if (response && [response count] > 0 && [response firstObject]) {
                                            
                                            NotificareAsset * customJSAsset = (NotificareAsset*)[response firstObject];
                                            
                                            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?x=%@", [customJSAsset assetUrl],  [NSString stringWithFormat:@"%.0f", [[NSDate new] timeIntervalSince1970]]]];
                                            
                                            NSURLSession *session = [NSURLSession sharedSession];
                                            
                                            [[session dataTaskWithURL:url
                                                    completionHandler:^(NSData *jsData,
                                                                        NSURLResponse *response,
                                                                        NSError *fileError) {
                                                        
                                                        if (!fileError) {
                                                            
                                                            NSString* jsString = [[NSString alloc] initWithData:jsData encoding:NSUTF8StringEncoding];
                                                            
                                                            [settings setObject:jsString forKey:@"customJSFile"];
                                                            
                                                            if ( [settings synchronize] ){
                                                                
                                                                // Fetch Main Template
                                                                [self fetchTemplate];
                                                                
                                                                [[NSNotificationCenter defaultCenter] postNotificationName:@"initialConfig" object:nil];
                                                            }
                                                            
                                                        } else {
                                                            
                                                            [self initalConfig];
                                                            
                                                        }
                                                        
                                                    }] resume];
                                            
                                            
                                        } else {
                                            
                                            // Fetch Main Template
                                            [self fetchTemplate];
                                            
                                            [[NSNotificationCenter defaultCenter] postNotificationName:@"initialConfig" object:nil];
                                        }
                                        
                                    } else {
                                        [self initalConfig];
                                    }
                                }];
                            
                                
                            } else {
                                
                                [self initalConfig];
                                
                            }
                            
                            
                        }] resume];
                
            }
            
        } else {
            [self initalConfig];
        }
    }];

}


-(void)createMemberCard:(NSString*)name andEmail:(NSString*)email completionHandler:(PassSuccess)completionBlock errorHandler:(PassError)errorBlock{
    
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    
    if (![[[self passTemplate] class] isKindOfClass:[NSNull class]]) {
        
        NSMutableDictionary * payload = [NSMutableDictionary dictionaryWithDictionary:[self passTemplate]];
        NSMutableDictionary * dataPayload = [NSMutableDictionary dictionaryWithDictionary:[[self passTemplate] objectForKey:@"data"]];
        
        NSMutableArray * tempPrimaryFields = [NSMutableArray arrayWithArray:[dataPayload objectForKey:@"primaryFields"]];
        for (NSDictionary * primaryField in [dataPayload objectForKey:@"primaryFields"]) {
            if ([[primaryField objectForKey:@"key"] isEqualToString:@"name"]) {
                
                NSMutableDictionary * field = [NSMutableDictionary dictionaryWithDictionary:primaryField];
                
                [tempPrimaryFields removeObject:primaryField];
                
                [field setObject:name forKey:@"value"];
                [tempPrimaryFields addObject:field];
            }
        }
        
        [dataPayload setObject:tempPrimaryFields forKey:@"primaryFields"];
        
        NSMutableArray * tempSecondaryFields = [NSMutableArray arrayWithArray:[dataPayload objectForKey:@"secondaryFields"]];
        
        for (NSDictionary * secondaryField in [dataPayload objectForKey:@"secondaryFields"]) {
            if ([[secondaryField objectForKey:@"key"] isEqualToString:@"email"]) {
                
                NSMutableDictionary * field = [NSMutableDictionary dictionaryWithDictionary:secondaryField];
                
                [tempSecondaryFields removeObject:secondaryField];
                
                [field setObject:email forKey:@"value"];
                [tempSecondaryFields addObject:field];
            }
        }
        
        [dataPayload setObject:tempSecondaryFields forKey:@"secondaryFields"];
        [dataPayload setObject:[[GravatarHelper getGravatarURL:email] absoluteString] forKey:@"thumbnail"];
        
        [payload setObject:[[self passTemplate] objectForKey:@"_id"] forKey:@"passbook"];
        [payload setObject:dataPayload forKey:@"data"];
        
        [[NotificarePushLib shared] doCloudHostOperation:@"POST" path:@"/pass" URLParams:nil customHeaders:nil bodyJSON:payload completionHandler:^(id  _Nullable response, NSError * _Nullable error) {
            if (!error) {
                if (response && [response objectForKey:@"pass"] && [[response objectForKey:@"pass"] objectForKey:@"serial"] ) {
                    
                    [settings setObject:[[response objectForKey:@"pass"] objectForKey:@"serial"] forKey:@"memberCardSerial"];
                    
                    if ([settings synchronize]) {
                        
                        completionBlock(@{@"serial" : [settings objectForKey:@"memberCardSerial"]});
                    }
                    
                }
                
            } else {
                errorBlock(error);
            }
        }];

    } else {
        NSMutableDictionary * userInfo = [NSMutableDictionary dictionary];
        [userInfo setObject:LS(@"error_no_pass_template_selected") forKey:@"response"];
        NSError * e = [NSError errorWithDomain:@"re.notifica.push" code:400 userInfo:userInfo];
        errorBlock(e);
    }
}


-(void)fetchTemplate{
    
    NSDictionary * memberCardConfig = [[Configuration shared] getDictionary:@"memberCard"];
    
    [[NotificarePushLib shared] doCloudHostOperation:@"GET" path:@"/passbook" URLParams:nil customHeaders:nil bodyJSON:nil completionHandler:^(id  _Nullable response, NSError * _Nullable error) {
        if (!error) {
            if (response && [response objectForKey:@"passbooks"]) {
                
                for (NSDictionary * template in [response objectForKey:@"passbooks"]) {
                    if ([[memberCardConfig objectForKey:@"templateId"] isEqualToString:[template objectForKey:@"_id"]]) {
                        
                        [self setPassTemplate:[NSDictionary dictionaryWithDictionary:template]];
                        
                    }
                }
            } else {
                NSLog(@"%@", response);
            }
        } else {
            NSLog(@"%@", error);
        }
    }];
}


#pragma Notificare OAuth2 delegates

- (void)notificarePushLib:(NotificarePushLib *)library didChangeAccountState:(NSDictionary *)info{

    [[NSNotificationCenter defaultCenter] postNotificationName:@"didChangeAccountNotification" object:nil];

}

- (void)notificarePushLib:(NotificarePushLib *)library didFailToRenewAccountSessionWithError:(NSError * _Nullable)error {

    [[NSNotificationCenter defaultCenter] postNotificationName:@"didFailToRequestAccessNotification" object:nil];
    
}


- (void)notificarePushLib:(NotificarePushLib *)library didReceiveActivationToken:(NSString *)token{
    
    [[[NotificarePushLib shared] authManager] validateAccount:token completionHandler:^(id  _Nullable response, NSError * _Nullable error) {
        if (!error) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"showAlertWithMessage" object:nil userInfo:@{@"message": LS(@"success_validate")}];
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"showAlertWithMessage" object:nil userInfo:@{@"message": LS(@"error_validate")}];
        }
    }];
    
}

- (void)notificarePushLib:(NotificarePushLib *)library didReceiveResetPasswordToken:(NSString *)token{
    
    
    UINavigationController *navController = (UINavigationController *)self.window.rootViewController;
    UIStoryboard *storyboard = self.window.rootViewController.storyboard;
    
    ResetPasswordViewController *viewController = (ResetPasswordViewController *)[storyboard instantiateViewControllerWithIdentifier:@"/resetpass"];
    
    [viewController setToken:token];
    [navController pushViewController:viewController animated:YES];
    
}


-(void)notificarePushLib:(NotificarePushLib *)library didDetectScannable:(nonnull NotificareScannable *)scannable{
    
    [[NotificarePushLib shared] openScannable:scannable completionHandler:^(id  _Nullable response, NSError * _Nullable error) {
        if (!error) {
            
            UINavigationController *navController = (UINavigationController *)self.window.rootViewController;
            
            if (response != nil && ![response isKindOfClass:[UIAlertController class]]) {
                [navController setNavigationBarHidden:NO];
            }

            [[NotificarePushLib shared] presentScannable:scannable inNavigationController:navController withController:response];
            
        }
    }];
}

-(void)notificarePushLib:(NotificarePushLib *)library didInvalidateScannableSessionWithError:(nonnull NSError *)error{
    
    
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:APP_NAME
                                 message:error.localizedDescription
                                 preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* cancel = [UIAlertAction
                             actionWithTitle:LS(@"ok")
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action){
                                 
                             }];
    [alert addAction:cancel];
    
    UINavigationController *navController = (UINavigationController *)self.window.rootViewController;
    
    [navController presentViewController:alert animated:YES completion:^{
        
    }];
    
}


-(void)startScannableSession{
    
    if (@available(iOS 11.0, *)) {
        if ([NFCNDEFReaderSession readingAvailable]) {
            NFCNDEFReaderSession * session = [[NFCNDEFReaderSession alloc] initWithDelegate:self queue:nil invalidateAfterFirstRead:YES];
            [session beginSession];
        } else {
            // Fallback for devices with no hardware support with QRCode
            UINavigationController *navController = (UINavigationController *)self.window.rootViewController;
            [navController setNavigationBarHidden:NO];
            [[NotificarePushLib shared] startScannableSessionWithQRCode:navController asModal:NO];
        }
    } else {
        // Fallback on earlier versions with QRCode
        UINavigationController *navController = (UINavigationController *)self.window.rootViewController;
        [navController setNavigationBarHidden:NO];
        [[NotificarePushLib shared] startScannableSessionWithQRCode:navController asModal:NO];
    }
}

-(void)readerSession:(NFCNDEFReaderSession *)session didDetectNDEFs:(NSArray<NFCNDEFMessage *> *)messages NS_AVAILABLE_IOS(11.0){
    
    if (@available(iOS 11.0, *)) {
        NSString * scannable = @"";
        for (NFCNDEFMessage *tagMessage in messages) {
            for (NFCNDEFPayload *tagPayload in [tagMessage records]) {
                
                NSString * typeString = [[NSString alloc] initWithData:tagPayload.type encoding:NSUTF8StringEncoding];

                if (tagPayload.typeNameFormat == NFCTypeNameFormatNFCWellKnown) {
                    if ([typeString isEqualToString:@"U"]) {
                        scannable = [[NotificarePushLib shared] parseURIPayload:tagPayload.payload];
                        
                        if (scannable && scannable.length > 0) {
                            [[NotificarePushLib shared] fetchScannable:scannable];
                        } else {
                            
                            NSMutableDictionary * userInfo = [NSMutableDictionary dictionary];
                            [userInfo setObject:@"Notificare: This is not a supportable scannable" forKey:@"response"];
                            NSError * e = [NSError errorWithDomain:@"re.notifica.push" code:404 userInfo:userInfo];
                            
                            [self notificarePushLib:[NotificarePushLib shared] didInvalidateScannableSessionWithError:e];
                            
                        }
                        
                        
                    } else {
                        
                        NSMutableDictionary * userInfo = [NSMutableDictionary dictionary];
                        [userInfo setObject:@"Notificare: This is not a supportable scannable" forKey:@"response"];
                        NSError * e = [NSError errorWithDomain:@"re.notifica.push" code:404 userInfo:userInfo];
                        
                        [self notificarePushLib:[NotificarePushLib shared] didInvalidateScannableSessionWithError:e];
                    }
                } else {
                    
                    NSMutableDictionary * userInfo = [NSMutableDictionary dictionary];
                    [userInfo setObject:@"Notificare: This is not a supportable scannable" forKey:@"response"];
                    NSError * e = [NSError errorWithDomain:@"re.notifica.push" code:404 userInfo:userInfo];
                    
                    [self notificarePushLib:[NotificarePushLib shared] didInvalidateScannableSessionWithError:e];
                    
                }
                
            }
        }
        
    }
    
}

-(void)readerSession:(NFCNDEFReaderSession *)session didInvalidateWithError:(nonnull NSError *)error NS_AVAILABLE_IOS(11.0) {
    
    UINavigationController *navController = (UINavigationController *)self.window.rootViewController;
    
    switch ([error code]) {
        case NFCReaderSessionInvalidationErrorFirstNDEFTagRead:
            ///Session is close after first read don't trigger the delegate
            break;
        case NFCReaderErrorUnsupportedFeature:
            // Fallback for devices with no hardware support with QRCode
            [[NotificarePushLib shared] startScannableSessionWithQRCode:navController asModal:YES];
            break;
        default:
            
            [self notificarePushLib:[NotificarePushLib shared] didInvalidateScannableSessionWithError:error];
            
            break;
    }
    
    
    
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

//Non-Manage Implementation
/*
-(void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(nonnull NSData *)deviceToken {
    [[NotificarePushLib shared] didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(nonnull NSDictionary *)userInfo fetchCompletionHandler:(nonnull void (^)(UIBackgroundFetchResult))completionHandler {
    [[NotificarePushLib shared] didReceiveRemoteNotification:userInfo completionHandler:^(id  _Nullable response, NSError * _Nullable error) {
        if (!error) {
            completionHandler(UIBackgroundFetchResultNewData);
        } else {
            completionHandler(UIBackgroundFetchResultNoData);
        }
    }];
}

-(void)application:(UIApplication *)application handleActionWithIdentifier:(nullable NSString *)identifier forRemoteNotification:(nonnull NSDictionary *)userInfo withResponseInfo:(nonnull NSDictionary *)responseInfo completionHandler:(nonnull void (^)())completionHandler{
    [[NotificarePushLib shared] handleActionWithIdentifier:identifier forRemoteNotification:userInfo withResponseInfo:responseInfo completionHandler:^(id  _Nullable response, NSError * _Nullable error) {
        completionHandler();
    }];
}

-(void)application:(UIApplication *)application handleActionWithIdentifier:(nullable NSString *)identifier forRemoteNotification:(nonnull NSDictionary *)userInfo completionHandler:(nonnull void (^)())completionHandler{
    [[NotificarePushLib shared] handleActionWithIdentifier:identifier forRemoteNotification:userInfo withResponseInfo:nil completionHandler:^(id  _Nullable response, NSError * _Nullable error) {
        completionHandler();
    }];
}
*/

@end
