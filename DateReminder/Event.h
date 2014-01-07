//
//  Event.h
//  DateReminder
//
//  Created by robin on 14-1-4.
//  Copyright (c) 2014年 Robin Zhang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class EventDate, EventReminder, EventTime;

@interface Event : NSManagedObject

@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) EventDate *date;
@property (nonatomic, retain) EventReminder *reminder;
@property (nonatomic, retain) EventTime *time;

@end
