//
//  RBZIAPHelper.m
//  Date Reminder
//
//  Created by robin on 14-1-4.
//  Copyright (c) 2014年 Robin Zhang. All rights reserved.
//

#import "RBZIAPHelper.h"

@implementation RBZIAPHelper

+ (RBZIAPHelper *)sharedInstance {
    static dispatch_once_t once;
    static RBZIAPHelper * sharedInstance;
    dispatch_once(&once, ^{
        NSSet * productIdentifiers = [NSSet setWithObjects:
                                      RBZIAP_buyCoffee,
                                      nil];
        sharedInstance = [[self alloc] initWithProductIdentifiers:productIdentifiers];
    });
    return sharedInstance;
}

@end
