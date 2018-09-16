//
//  Configuration.m
//  CrossingBorder
//
//  Created by Joel Oliveira on 26/02/14.
//  Copyright (c) 2014 CrossingBorder. All rights reserved.
//


#import "Configuration.h"

@implementation Configuration


// Get the shared instance and create it if necessary.
+(Configuration*)shared {
    
    static Configuration *shared = nil;
    
    if (shared == nil) {
        static dispatch_once_t oncePredicate;
        dispatch_once(&oncePredicate, ^{
            shared = [[Configuration alloc] init];
            
        });
    }
    return shared;
}


-(NSString*)getProperty:(NSString *)key{
    
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    NSDictionary * configFile = [settings objectForKey:@"configFile"];

    return [configFile objectForKey:key];
}

-(NSArray*)getArray:(NSString *)key{
    
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    NSDictionary * configFile = [settings objectForKey:@"configFile"];
    
    return [configFile objectForKey:key];
}

-(NSDictionary*)getDictionary:(NSString *)key{
    
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    NSDictionary * configFile = [settings objectForKey:@"configFile"];
    
    return [configFile objectForKey:key];
}

@end
