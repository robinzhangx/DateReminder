//
//  RBZDateReminderTest.m
//  DateReminder
//
//  Created by robin on 14-1-6.
//  Copyright (c) 2014年 Robin Zhang. All rights reserved.
//

#import "RBZDateReminderTest.h"
#import "RBZDateReminder.h"

@implementation RBZDateReminderTest

+ (void)injectTestEvents:(NSInteger)count reminder:(BOOL)hasReminder
{
    NSTimeInterval secondsPerDay = 24 * 60 * 60;
    NSDate *tomorrow = [[NSDate alloc] initWithTimeIntervalSinceNow:secondsPerDay];
    NSCalendar *calendar = [[RBZDateReminder instance] defaultCalendar];
    NSDateComponents *comps = [calendar components:NSMinuteCalendarUnit|NSHourCalendarUnit|NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit
                                          fromDate:tomorrow];
    
    NSManagedObjectContext *localContext = [NSManagedObjectContext MR_defaultContext];
    for (int i = 0; i < count; i++) {
        Event *event = [Event MR_createInContext:localContext];
        event.title = [NSString stringWithFormat:@"Test event #%d", i];
        EventTime *time = [EventTime MR_createInContext:localContext];
        time.hour = [NSNumber numberWithInteger:comps.hour];
        time.minute = [NSNumber numberWithInteger:(comps.minute + i) % 60];
        EventDate *date = [EventDate MR_createInContext:localContext];
        date.type = [NSNumber numberWithInteger:RBZEventOnce];
        date.day = [NSNumber numberWithInteger:comps.day];
        date.month = [NSNumber numberWithInteger:comps.month];
        date.year = [NSNumber numberWithInteger:comps.year];
        EventReminder *reminder = [EventReminder MR_createInContext:localContext];
        reminder.hasReminder = [NSNumber numberWithBool:hasReminder];
        event.date = date;
        event.time = time;
        event.reminder = reminder;
        [localContext MR_saveToPersistentStoreAndWait];
        [[RBZDateReminder instance] addEvent:event];
    }
}

@end
