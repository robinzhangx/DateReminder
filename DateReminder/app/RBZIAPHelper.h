//
//  RBZIAPHelper.h
//  Date Reminder
//
//  Created by robin on 14-1-4.
//  Copyright (c) 2014年 Robin Zhang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IAPHelper.h"

static NSString *const RBZIAP_buyCoffee = @"com.robiz.datereminder.baac";

@interface RBZIAPHelper : IAPHelper

+ (RBZIAPHelper *)sharedInstance;

@end
