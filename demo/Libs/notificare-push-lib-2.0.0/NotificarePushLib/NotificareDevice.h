//
//  NotificareDevice.h
//  NotificarePushLib
//
//  Created by Joel Oliveira on 28/01/15.
//  Copyright (c) 2015 Notificare. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NotificareDevice : NSObject

@property (strong, nonatomic, nonnull) NSData * deviceTokenData;
@property (strong, nonatomic, nonnull) NSString * deviceID;
@property (strong, nonatomic, nullable) NSString * userID;
@property (strong, nonatomic, nullable) NSString * userName;
@property (strong, nonatomic, nonnull) NSNumber * timezone;
@property (strong, nonatomic, nonnull) NSString * osVersion;
@property (strong, nonatomic, nonnull) NSString * sdkVersion;
@property (strong, nonatomic, nonnull) NSString * appVersion;
@property (strong, nonatomic, nonnull) NSString * deviceModel;
@property (strong, nonatomic, nullable) NSString * country;
@property (strong, nonatomic, nonnull) NSString * language;
@property (strong, nonatomic, nullable) NSDictionary * dnd;
@property (strong, nonatomic, nullable) NSDictionary * userData;
@property (strong, nonatomic, nullable) NSNumber * latitude;
@property (strong, nonatomic, nullable) NSNumber * longitude;
@property (strong, nonatomic, nullable) NSNumber * floor;
@property (strong, nonatomic, nonnull) NSDate * lastRegistered;
@property (assign, nonatomic) BOOL registeredForNotifications;
@property (assign, nonatomic) BOOL allowedLocationServices;
@property (assign, nonatomic) BOOL allowedUI;



@end
