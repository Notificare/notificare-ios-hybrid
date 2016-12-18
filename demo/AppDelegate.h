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

@interface AppDelegate : UIResponder <UIApplicationDelegate, NotificarePushLibDelegate>

@property (strong, nonatomic) UIWindow *window;


@end

