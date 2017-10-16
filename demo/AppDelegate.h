//
//  AppDelegate.h
//  demo
//
//  Created by Joel Oliveira on 18/12/2016.
//  Copyright © 2016 Notificare. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NotificarePushLib.h"
#import "Configuration.h"
#import "NotificareNetworkReachability.h"
#import "NoInternetViewController.h"
#import "Definitions.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, NotificarePushLibDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (assign, nonatomic) BOOL hasInternet;
@property (assign, nonatomic) BOOL NoInternetViewIsOpen;
@property (strong, nonatomic) NotificareNetworkReachability *hostReachability;
@property (strong, nonatomic) NotificareNetworkReachability *internetReachability;
@property (strong, nonatomic) NotificareNetworkReachability *wifiReachability;
@property (assign, nonatomic) BOOL isInitialLoadingDone;
@property (strong, nonatomic) NSDictionary *passTemplate;
@property (strong, nonatomic) NSArray *beacons;

typedef void (^PassSuccess)(NSDictionary * info);
typedef void (^PassError)(NSError * error);

-(void)handleDeepLinks:(NSURL *)url;
-(void)createMemberCard:(NSString*)name andEmail:(NSString*)email completionHandler:(PassSuccess)completionBlock errorHandler:(PassError)errorBlock;

@end

