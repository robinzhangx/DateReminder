//
//  RBZDateReminderApp.m
//  Date Reminder
//
//  Created by robin on 13-12-4.
//  Copyright (c) 2013年 Robin Zhang. All rights reserved.
//

#import "RBZDateReminder.h"

@implementation RBZDateReminder

static RBZDateReminder *instance;

static NSString *const DateReminder_defaultEventsKey = @"dr_defaultEvents";
static NSString *const DateReminder_localNotificationCleared = @"dr_localNotificationCleared";

+ (RBZDateReminder *)instance
{
    @synchronized (self) {
        if (!instance) {
            instance = [[RBZDateReminder alloc] init];
        }
        return instance;
    }
}

- (id)init
{
    self = [super init];
    
    if (self) {
        NSLog(@"Event:%d, Date:%d, Time:%d, Reminder:%d", [Event MR_countOfEntities], [EventDate MR_countOfEntities], [EventTime MR_countOfEntities], [EventReminder MR_countOfEntities]);
        NSLog(@"Local Notifications:%d", [[[UIApplication sharedApplication] scheduledLocalNotifications] count]);
        
        self.datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0.0, 0.0, 290.0, 162.0)];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        if (![defaults boolForKey:DateReminder_localNotificationCleared]) {
            [[UIApplication sharedApplication] cancelAllLocalNotifications];
            [defaults setBool:YES forKey:DateReminder_localNotificationCleared];
            [defaults synchronize];
        }
        
        if (![defaults boolForKey:DateReminder_defaultEventsKey]) {
            [self setupDefaultEvents];
        }
        
        //[[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
        //[[UIApplication sharedApplication] cancelAllLocalNotifications];
        //[Event MR_truncateAll];
        //[EventDate MR_truncateAll];
        //[EventTime MR_truncateAll];
        //[EventReminder MR_truncateAll];
        //[[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
        
    }
    return self;
}

- (void)addEvent:(Event *)ev
{
    [self scheduleLocalNotificationForEvent:ev];
}

- (void)removeEvent:(Event *)ev
{
    [self cancelLocalNotificationForEvent:ev];
}

- (void)updateEvent:(Event *)ev
{
    [self updateLocalNotificationForEvent:ev];
}

- (NSArray *)getTodayEvents
{
    NSMutableArray *ret = [NSMutableArray array];
    NSDate *today = [[NSDate alloc] init];
    
    for (Event *ev in [Event MR_findAll]) {
        if ([ev isOnDate:today]) {
            [ret addObject:ev];
        }
    }
    
    NSSortDescriptor *hourSort = [[NSSortDescriptor alloc] initWithKey:@"time.hour" ascending:YES];
    NSSortDescriptor *minuteSort = [[NSSortDescriptor alloc] initWithKey:@"time.minute" ascending:YES];
    NSArray *sortDescriptors = @[hourSort, minuteSort];
    [ret sortUsingDescriptors:sortDescriptors];
    return ret;
}

- (NSArray *)getTomorrowEvents
{
    NSMutableArray *ret = [NSMutableArray array];
    NSTimeInterval secondsPerDay = 24 * 60 * 60;
    NSDate *tomorrow = [[NSDate alloc] initWithTimeIntervalSinceNow:secondsPerDay];
    
    for (Event *ev in [Event MR_findAll]) {
        if ([ev isOnDate:tomorrow]) {
            [ret addObject:ev];
        }
    }
    
    NSSortDescriptor *hourSort = [[NSSortDescriptor alloc] initWithKey:@"time.hour" ascending:YES];
    NSSortDescriptor *minuteSort = [[NSSortDescriptor alloc] initWithKey:@"time.minute" ascending:YES];
    NSArray *sortDescriptors = @[hourSort, minuteSort];
    [ret sortUsingDescriptors:sortDescriptors];
    
    return ret;
}

- (NSMutableArray *)getActiveEvents
{
    NSDate *now = [[NSDate alloc] init];
    NSMutableArray *ret = [NSMutableArray array];
    
    for (Event *ev in [Event MR_findAll]) {
        if (![ev isExpired:now])
            [ret addObject:ev];
    }
    return ret;
}

- (NSMutableArray *)getExpiredEvents
{
    NSDate *now = [[NSDate alloc] init];
    NSMutableArray *ret = [NSMutableArray array];
    
    for (Event *ev in [Event MR_findAll]) {
        if ([ev isExpired:now])
            [ret addObject:ev];
    }
    return ret;
}

static NSString *LOCAL_NOTIFICATION_KEY = @"event_id";

- (void)cancelLocalNotificationForEvent:(Event *)event
{
    NSString *eid = [[[event objectID] URIRepresentation] absoluteString];
    NSLog(@"cancelLocalNotificationForEvent: %@", eid);
    NSArray *notifs = [[UIApplication sharedApplication] scheduledLocalNotifications];
    for (UILocalNotification *notif in notifs) {
        NSString *nid = [notif.userInfo objectForKey:LOCAL_NOTIFICATION_KEY];
        if ([eid isEqualToString:nid]) {
            NSLog(@"found local notification");
            [[UIApplication sharedApplication] cancelLocalNotification:notif];
        }
    }
}

- (void)scheduleLocalNotificationForEvent:(Event *)event
{
    if (![event.reminder.hasReminder boolValue])
        return;
    NSArray *notifs = [[UIApplication sharedApplication] scheduledLocalNotifications];
    if ([notifs count] >= 64) {
        NSLog(@"Local notification exceeded maximum");
        [Flurry logEvent:FLURRY_LOCAL_NOTIFICATION_MAXIMUM_REACHED];
    }
    UILocalNotification *localNotif = [[UILocalNotification alloc] init];
    if (localNotif == nil)
        return;
    NSDate *date = [event getNextDate];
    date = [date dateByAddingTimeInterval:-60.0 * [event.reminder.minutesBefore integerValue]];
    localNotif.fireDate = date;
    switch ([event.date.type integerValue]) {
        case RBZEventDaily: localNotif.repeatInterval = NSDayCalendarUnit; break;
        case RBZEventWeekly: localNotif.repeatInterval = NSWeekCalendarUnit; break;
        case RBZEventMonthly: localNotif.repeatInterval = NSMonthCalendarUnit; break;
        case RBZEventYearly: localNotif.repeatInterval = NSYearCalendarUnit; break;
        case RBZEventOnce: {
            NSDate *now = [[NSDate alloc] init];
            if ([date timeIntervalSinceDate:now] < 0) {
                return;
            }
        }
    }
    localNotif.timeZone = [NSTimeZone defaultTimeZone];
    localNotif.alertBody = event.title;
    localNotif.soundName = UILocalNotificationDefaultSoundName;
    NSString *eid = [[[event objectID] URIRepresentation] absoluteString];
    NSLog(@"scheduleLocalNotificationForEvent: %@", eid);
    NSDictionary *info = [NSDictionary dictionaryWithObject:eid forKey:LOCAL_NOTIFICATION_KEY];
    localNotif.userInfo = info;
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
}

- (void)updateLocalNotificationForEvent:(Event *)event
{
    [self cancelLocalNotificationForEvent:event];
    [self scheduleLocalNotificationForEvent:event];
}

/*
- (void)removeDangingLocalNotifications
{
    NSManagedObjectContext *localContext = [NSManagedObjectContext MR_defaultContext];
    NSArray *notifs = [[UIApplication sharedApplication] scheduledLocalNotifications];
    for (UILocalNotification *notif in notifs) {
        NSString *nid = [notif.userInfo objectForKey:LOCAL_NOTIFICATION_KEY];
        NSLog(@"%@", nid);
        NSURL *url = [[NSURL alloc] initWithString:nid];
        NSManagedObjectID *objectId = [[localContext persistentStoreCoordinator] managedObjectIDForURIRepresentation:url];
        NSError *error;
        NSManagedObject *object = [localContext existingObjectWithID:objectId error:&error];
        if (!object) {
            NSLog(@"dangling local notification found");
        }
    }
}
*/

- (void)setupDefaultEvents
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDate *now = [NSDate date];
    NSDateComponents *add = [[NSDateComponents alloc] init];
    add.day = 14;
    NSDate *d = [calendar dateByAddingComponents:add toDate:now options:0];
    NSDateComponents *comps = [calendar components:NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit
                                          fromDate:d];
    
    NSManagedObjectContext *localContext = [NSManagedObjectContext MR_defaultContext];
    Event *event = [Event MR_createInContext:localContext];
    event.title = @"What do you think of Date Reminder?\nYou can help to make it better! Send feedbacks/suggestions to author in menu.";
    EventTime *time = [EventTime MR_createInContext:localContext];
    time.hour = [NSNumber numberWithInteger:15];
    time.minute = [NSNumber numberWithInteger:0];
    EventDate *date = [EventDate MR_createInContext:localContext];
    date.type = [NSNumber numberWithInteger:RBZEventOnce];
    date.day = [NSNumber numberWithInteger:comps.day];
    date.month = [NSNumber numberWithInteger:comps.month];
    date.year = [NSNumber numberWithInteger:comps.year];
    EventReminder *reminder = [EventReminder MR_createInContext:localContext];
    reminder.hasReminder = [NSNumber numberWithBool:NO];
    event.date = date;
    event.time = time;
    event.reminder = reminder;
    [localContext MR_saveToPersistentStoreAndWait];
    // this event has no reminder, no need to call AddEvent:
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:YES forKey:DateReminder_defaultEventsKey];
    [defaults synchronize];
}

@end
