//
//  NotificationService.m
//  notification
//
//  Created by Joel Oliveira on 30/01/2017.
//  Copyright © 2017 Notificare. All rights reserved.
//

#import "NotificationService.h"
#import "NotificarePushLib.h"

@interface NotificationService ()

@property (nonatomic, strong) void (^contentHandler)(UNNotificationContent *contentToDeliver);
@property (nonatomic, strong) UNMutableNotificationContent *bestAttemptContent;

@end

@implementation NotificationService

- (void)didReceiveNotificationRequest:(UNNotificationRequest *)request withContentHandler:(void (^)(UNNotificationContent * _Nonnull))contentHandler {
    self.contentHandler = contentHandler;
    self.bestAttemptContent = [request.content mutableCopy];
    
    [[NotificarePushLib shared] handleNotificationRequest:request.content.userInfo forContent:self.bestAttemptContent completionHandler:^(id  _Nullable response, NSError * _Nullable error) {
        if (!error) {
            self.contentHandler(response);
        } else {
            self.contentHandler(self.bestAttemptContent);
        }
    }];
    
}

- (void)serviceExtensionTimeWillExpire {
    // Called just before the extension will be terminated by the system.
    // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
    self.contentHandler(self.bestAttemptContent);
}

@end
