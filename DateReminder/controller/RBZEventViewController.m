//
//  RBZAddEventViewController.m
//  Date Reminder
//
//  Created by robin on 13-12-9.
//  Copyright (c) 2013年 Robin Zhang. All rights reserved.
//

#import "UIViewController+MMDrawerController.h"
#import "RBZEventViewController.h"
#import "RBZTimeViewController.h"
#import "RBZTypeViewController.h"
#import "RBZReminderViewController.h"
#import "RBZDateViewController.h"
#import "RBZDateValueViewController.h"
#import "RBZDateReminder.h"
#import "RBZUtils.h"
#import "GoogleAnalyticsHelper.h"

@interface RBZEventViewController ()

@property NSNumber *picked_hour;
@property NSNumber *picked_minute;

@property NSNumber *picked_type;
@property NSNumber *picked_day;
@property NSNumber *picked_month;
@property NSNumber *picked_weekday;
@property NSNumber *picked_year;

@property NSNumber *picked_hasReminder;
@property NSNumber *picked_minutesBefore;

@property UIColor *textColor;
@property UIColor *hintColor;
@property UIColor *highlightColor;
@property UIImage *highlightImage;
@property UIColor *backgroundColor;
@property UIColor *invalidColor;

@property NSTimer *refreshTimer;

@end

static NSString *const GA_VC_EVENT_VIEW = @"Event View";

@implementation RBZEventViewController

static NSString *eventTextHint = @"<Event Notes>";
static NSString *timeLabelHint = @"<Set Time>";
static NSString *typeLabelHint = @"<Set Date>";
static NSString *reminderLabelHint = @"<Set Reminder>";

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    self.textColor = [UIColor blackColor];
    self.hintColor = [UIColor colorWithRed:178.0/255.0 green:178.0/255.0 blue:178.0/255.0 alpha:1.0];
    self.highlightColor = [UIColor colorWithRed:1.0 green:153.0/255.0 blue:0.0 alpha:0.2];
    self.backgroundColor = [UIColor colorWithRed:1.0 green:153.0/255.0 blue:0.0 alpha:0.0];
    self.invalidColor = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.3];
    
    self.eventText.backgroundColor = self.backgroundColor;
    self.nextCell.backgroundColor = self.backgroundColor;
    
    self.highlightImage = [RBZUtils imageWithColor:self.highlightColor];
    
    UIColor *highlightColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.2];
    UIImage *highlightImage = [RBZUtils imageWithColor:highlightColor];
    [self.createButton setBackgroundImage:highlightImage forState:UIControlStateHighlighted];
    self.createButton.layer.cornerRadius = 2.0;
    
    [self.timeCell setBackgroundImage:self.highlightImage forState:UIControlStateHighlighted];
    [self.timeCell addTarget:self action:@selector(onTapTime:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.typeCell setBackgroundImage:self.highlightImage forState:UIControlStateHighlighted];
    [self.typeCell addTarget:self action:@selector(onTapType:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.reminderCell setBackgroundImage:self.highlightImage forState:UIControlStateHighlighted];
    [self.reminderCell addTarget:self action:@selector(onTapReminder:) forControlEvents:UIControlEventTouchUpInside];
    
    UITapGestureRecognizer *tapScrollView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapOutsideEventText:)];
    [self.scrollView addGestureRecognizer:tapScrollView];
    
    UITapGestureRecognizer *tapNextCell = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapNextCell:)];
    [self.nextCell addGestureRecognizer:tapNextCell];
    
    self.eventText.delegate = self;
    
    if (self.event) {
        [self.createButton setHidden:YES];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(onDeleteEvent:)];
        self.eventText.text = self.event.title;
    } else {
        [self.createButton setHidden:NO];
        [self.createButton addTarget:self action:@selector(onDoneCreate:) forControlEvents:UIControlEventTouchUpInside];
        self.eventText.text = eventTextHint;
        self.eventText.textColor = self.hintColor;
    }
    [self updateTimeLabel];
    [self updateDateLabel];
    [self updateReminderLabel];
    [self updateNextLabel];
    //NSLog(@"viewDidLoad:event");
}

- (void)timerFired:(NSTimer *)timer
{
    [self updateNextLabel];
}

- (void)viewWillAppear:(BOOL)animated
{
    if (self.mm_drawerController) {
        [self.mm_drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeNone];
        [self.mm_drawerController setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeNone];
    }
    [self registerForKeyboardNotifications];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self unregisterForKeyboardNotifications];
    [super viewWillDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [GoogleAnalyticsHelper trackScreen:GA_VC_EVENT_VIEW];
    NSString *str = [self.eventText.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([str length] == 0 || [str isEqualToString:eventTextHint]) {
        if (!self.event
            && !self.picked_minute && !self.picked_hour
            && !self.picked_type
            && !self.picked_hasReminder) {
            [self.eventText becomeFirstResponder];
        }
    }
    self.refreshTimer = [NSTimer scheduledTimerWithTimeInterval:1
                                                         target:self
                                                       selector:@selector(timerFired:)
                                                       userInfo:nil
                                                        repeats:YES];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self updateNextLabel];
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    //NSLog(@"viewDidDisappear:event");
    if (self.refreshTimer)
        [self.refreshTimer invalidate];
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)validateNewEventValue
{
    BOOL invalidEventText = NO;
    NSString *str = [self.eventText.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([str length] == 0 || [str isEqualToString:eventTextHint]) {
        invalidEventText = YES;
    }
    if (!self.picked_hasReminder) {
        self.picked_hasReminder = [NSNumber numberWithBool:NO];
        [self updateReminderLabel];
    }
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"backgroundColor"];
    animation.autoreverses = YES;
    animation.repeatCount = 2;
    animation.toValue = (id)self.invalidColor.CGColor;
    animation.duration = 0.2;
    if (invalidEventText) {
        [self.eventText.layer addAnimation:animation forKey:@"backgroundColor"];
        [self.nextCell.layer addAnimation:animation forKey:@"backgroundColor"];
    }
    if (!self.picked_hour || !self.picked_minute)
        [self.timeCell.layer addAnimation:animation forKey:@"backgroundColor"];
    if (!self.picked_type)
        [self.typeCell.layer addAnimation:animation forKey:@"backgroundColor"];

    return !invalidEventText && (self.picked_hour != nil) && (self.picked_minute != nil) && (self.picked_type != nil);
}

- (Event *)createNewEvent
{
    NSManagedObjectContext *localContext = [NSManagedObjectContext MR_defaultContext];
    Event *event = [Event MR_createInContext:localContext];
    event.title = [self.eventText.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    EventTime *time = [EventTime MR_createInContext:localContext];
    time.hour = self.picked_hour;
    time.minute = self.picked_minute;
    
    EventDate *date = [EventDate MR_createInContext:localContext];
    date.type = self.picked_type;
    switch ([date.type integerValue]) {
        case RBZEventOnce:
            date.day = self.picked_day;
            date.month = self.picked_month;
            date.year = self.picked_year;
            break;
        case RBZEventDaily:
            break;
        case RBZEventWeekly:
            date.weekday = self.picked_weekday;
            break;
        case RBZEventMonthly:
            date.day = self.picked_day;
            break;
        case RBZEventYearly:
            date.day = self.picked_day;
            date.month = self.picked_month;
            break;
    }
    
    EventReminder *reminder = [EventReminder MR_createInContext:localContext];
    reminder.hasReminder = self.picked_hasReminder;
    reminder.minutesBefore = self.picked_minutesBefore;
    
    event.date = date;
    event.time = time;
    event.reminder = reminder;
    [localContext MR_saveToPersistentStoreAndWait];
    //NSLog(@"%@", [[[event objectID] URIRepresentation] absoluteString]);
    //NSLog(@"%@", [[[event.date objectID] URIRepresentation] absoluteString]);
    //NSLog(@"%@", [[[event.time objectID] URIRepresentation] absoluteString]);
    //NSLog(@"%@", [[[event.reminder objectID] URIRepresentation] absoluteString]);
    
    NSString *typeStr = [EventDate typeString:[event.date.type integerValue]];
    [GoogleAnalyticsHelper trackEventWithCategory:GA_CATEGORY_USER
                                           action:GA_ACTION_CREATE_EVENT
                                            label:typeStr
                                            value:[event.reminder.hasReminder boolValue] ? event.reminder.minutesBefore : event.reminder.hasReminder];
    return event;
}

- (IBAction)onDoneCreate:(id)sender
{
    if ([self validateNewEventValue]) {
        Event *event = [self createNewEvent];
        [[RBZDateReminder instance] addEvent:event];
        [self.delegate eventCreated:event];
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [GoogleAnalyticsHelper trackEventWithCategory:GA_CATEGORY_USER
                                               action:GA_ACTION_CREATE_INVALIDATE
                                                label:nil
                                                value:nil];
    }
}

- (IBAction)onDeleteEvent:(id)sender
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Delete this event?"
                                                    message:nil
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Delete", nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        NSString *typeStr = [EventDate typeString:[self.event.date.type integerValue]];
        [GoogleAnalyticsHelper trackEventWithCategory:GA_CATEGORY_USER
                                               action:GA_ACTION_DELETE_EVENT
                                                label:typeStr
                                                value:[self.event.reminder.hasReminder boolValue] ? self.event.reminder.minutesBefore : self.event.reminder.hasReminder];
        NSManagedObjectContext *localContext = [NSManagedObjectContext MR_defaultContext];
        [self.event MR_deleteInContext:localContext];
        [localContext MR_saveToPersistentStoreAndWait];
        [[RBZDateReminder instance] removeEvent:self.event];
        [self.delegate eventDeleted:self.event];
        self.event = nil;
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (IBAction)onTapNextCell:(id)sender
{
    if ([self.eventText isFirstResponder])
        [self.eventText resignFirstResponder];
    else
        [self.eventText becomeFirstResponder];
}

- (IBAction)onTapTime:(id)sender
{
    [self exitEventTextEditing];
    RBZTimeViewController *vc = (RBZTimeViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"vc_timeView"];
    if (self.event) {
        vc.hour = self.event.time.hour;
        vc.minute = self.event.time.minute;
    } else {
        vc.hour = self.picked_hour;
        vc.minute = self.picked_minute;
    }
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)onTapType:(id)sender
{
    [self exitEventTextEditing];
    RBZTypeViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"vc_typeView"];
    if (self.event) {
        vc.type = self.event.date.type;
        vc.day = self.event.date.day;
        vc.weekday = self.event.date.weekday;
        vc.month = self.event.date.month;
        vc.year = self.event.date.year;
    } else {
        vc.type = self.picked_type;
        vc.day = self.picked_day;
        vc.weekday = self.picked_weekday;
        vc.month = self.picked_month;
        vc.year = self.picked_year;
    }
    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)onTapReminder:(id)sender
{
    [self exitEventTextEditing];
    RBZReminderViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"vc_reminderView"];
    if (self.event) {
        vc.hasReminder = self.event.reminder.hasReminder;
        vc.minutesBefore = self.event.reminder.minutesBefore;
    } else {
        vc.hasReminder = self.picked_hasReminder;
        vc.minutesBefore = self.picked_minutesBefore;
    }
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)onTapOutsideEventText:(id)sender
{
    [self exitEventTextEditing];
}

- (void)updateTimeLabel
{
    if (self.event) {
        self.timeLabel.text = [self.event.time getTimeString];
        self.timeLabel.textColor = [UIColor blackColor];
    } else if (self.picked_hour && self.picked_minute) {
        self.timeLabel.text = [EventTime getTimeString:self.picked_minute hour:self.picked_hour];
        self.timeLabel.textColor = [UIColor blackColor];
    } else {
        self.timeLabel.text = timeLabelHint;
        self.timeLabel.textColor = self.hintColor;
    }
}

- (void)updateDateLabel
{
    if (self.event) {
        self.typeLabel.text = [self.event.date getTypeString];
        self.typeLabel.textColor = [UIColor blackColor];
    } else if (self.picked_type) {
        NSString *str;
        switch ([self.picked_type integerValue]) {
            case RBZEventOnce:
                str = [EventDate getOnceString:self.picked_day month:self.picked_month year:self.picked_year];
                break;
            case RBZEventDaily:
                str = [EventDate getDailyString];
                break;
            case RBZEventWeekly:
                str = [EventDate getWeeklyString:self.picked_weekday];
                break;
            case RBZEventMonthly:
                str = [EventDate getMonthlyString:self.picked_day];
                break;
            case RBZEventYearly:
                str = [EventDate getYearlyString:self.picked_day month:self.picked_month];
                break;
        }
        self.typeLabel.text = str;
        self.typeLabel.textColor = [UIColor blackColor];
    } else {
        self.typeLabel.text = typeLabelHint;
        self.typeLabel.textColor = self.hintColor;
    }
}

- (void)updateReminderLabel
{
    if (self.event) {
        self.reminderLabel.text = [self.event.reminder getReminderString];
        self.reminderLabel.textColor = [UIColor blackColor];
    } else if (self.picked_hasReminder) {
        self.reminderLabel.text = [EventReminder getReminderString:self.picked_hasReminder minutes:self.picked_minutesBefore];
        self.reminderLabel.textColor = [UIColor blackColor];
    } else {
        self.reminderLabel.text = reminderLabelHint;
        self.reminderLabel.textColor = self.hintColor;
    }
}

- (void)updateNextLabel
{
    NSDate *next;
    BOOL expired;
    if (self.picked_minute && self.picked_hour && self.picked_type) {
        next = [Event getNextDate:self.picked_type
                           minute:self.picked_minute
                             hour:self.picked_hour
                              day:self.picked_day
                          weekday:self.picked_weekday
                            month:self.picked_month
                             year:self.picked_year];
        expired = [Event isExpired:[[NSDate alloc] init]
                              type:self.picked_type
                            minute:self.picked_minute
                              hour:self.picked_hour
                               day:self.picked_day
                           weekday:self.picked_weekday
                             month:self.picked_month
                              year:self.picked_year];
    } else if (self.event) {
        next = [self.event getNextDate];
        expired = [self.event isExpired:[[NSDate alloc] init]];
    }
    
    if (next) {
        if (expired) {
            self.nextLabel.text = @"Expired";
        } else {
            NSTimeInterval interval = [next timeIntervalSinceNow];
            self.nextLabel.text = [NSString stringWithFormat:@"%@ %@", @"Will happen in", [RBZUtils getReadableTimeInterval:interval]];
        }
    } else {
        self.nextLabel.text = @"";
    }
}

- (IBAction)timePicked:(UIStoryboardSegue *)segue
{
    RBZTimeViewController *src = (RBZTimeViewController *)segue.sourceViewController;
    if (self.event) {
        self.event.time.hour = src.hour;
        self.event.time.minute = src.minute;
        NSManagedObjectContext *localContext = [NSManagedObjectContext MR_defaultContext];
        [localContext MR_saveToPersistentStoreAndWait];
        [[RBZDateReminder instance] updateEvent:self.event];
        [self.delegate eventUpdated:self.event];
    } else {
        self.picked_hour = src.hour;
        self.picked_minute = src.minute;
    }
    [self updateTimeLabel];
    [self updateNextLabel];
}

- (IBAction)reminderPicked:(UIStoryboardSegue *)segue
{
    RBZReminderViewController *src = (RBZReminderViewController *)segue.sourceViewController;
    if (self.event) {
        self.event.reminder.hasReminder = src.hasReminder;
        self.event.reminder.minutesBefore = src.minutesBefore;
        NSManagedObjectContext *localContext = [NSManagedObjectContext MR_defaultContext];
        [localContext MR_saveToPersistentStoreAndWait];
        [[RBZDateReminder instance] updateEvent:self.event];
        [self.delegate eventUpdated:self.event];
    } else {
        self.picked_hasReminder = src.hasReminder;
        self.picked_minutesBefore = src.minutesBefore;
    }
    [self updateReminderLabel];
}

- (IBAction)datePicked:(UIStoryboardSegue *)segue
{
    RBZDateViewController *src = (RBZDateViewController *)segue.sourceViewController;
    if (self.event) {
        self.event.date.type = [NSNumber numberWithInteger:RBZEventOnce];
        self.event.date.day = src.day;
        self.event.date.month = src.month;
        self.event.date.year = src.year;
        NSManagedObjectContext *localContext = [NSManagedObjectContext MR_defaultContext];
        [localContext MR_saveToPersistentStoreAndWait];
        [[RBZDateReminder instance] updateEvent:self.event];
        [self.delegate eventUpdated:self.event];
    } else {
        self.picked_type = [NSNumber numberWithInteger:RBZEventOnce];
        self.picked_day = src.day;
        self.picked_month = src.month;
        self.picked_year = src.year;
    }
    [self updateDateLabel];
    [self updateNextLabel];
}

- (IBAction)dateValuePicked:(UIStoryboardSegue *)segue
{
    RBZDateValueViewController *src = (RBZDateValueViewController *)segue.sourceViewController;
    if (self.event) {
        self.event.date.type = src.type;
        self.event.date.day = src.day;
        self.event.date.weekday = src.weekday;
        self.event.date.month = src.month;
        self.event.date.year = src.year;
        NSManagedObjectContext *localContext = [NSManagedObjectContext MR_defaultContext];
        [localContext MR_saveToPersistentStoreAndWait];
        [[RBZDateReminder instance] updateEvent:self.event];
        [self.delegate eventUpdated:self.event];
    } else {
        self.picked_type = src.type;
        self.picked_day = src.day;
        self.picked_weekday = src.weekday;
        self.picked_month = src.month;
        self.picked_year = src.year;
    }
    [self updateDateLabel];
    [self updateNextLabel];
}

- (void)eventDateDailyPicked
{
    if (self.event) {
        self.event.date.type = [NSNumber numberWithInteger:RBZEventDaily];
        NSManagedObjectContext *localContext = [NSManagedObjectContext MR_defaultContext];
        [localContext MR_saveToPersistentStoreAndWait];
        [[RBZDateReminder instance] updateEvent:self.event];
        [self.delegate eventUpdated:self.event];
    } else {
        self.picked_type = [NSNumber numberWithInteger:RBZEventDaily];
    }
    [self updateDateLabel];
    [self updateNextLabel];
}

- (void)eventDateWeeklyPicked:(NSNumber *)weekday
{
    if (self.event) {
        self.event.date.type = [NSNumber numberWithInteger:RBZEventWeekly];
        self.event.date.weekday = weekday;
        NSManagedObjectContext *localContext = [NSManagedObjectContext MR_defaultContext];
        [localContext MR_saveToPersistentStoreAndWait];
        [[RBZDateReminder instance] updateEvent:self.event];
        [self.delegate eventUpdated:self.event];
    } else {
        self.picked_type = [NSNumber numberWithInteger:RBZEventWeekly];
        self.picked_weekday = weekday;
    }
    [self updateDateLabel];
    [self updateNextLabel];
}

- (void)eventDateMonthlyPicked:(NSNumber *)day
{
    if (self.event) {
        self.event.date.type = [NSNumber numberWithInteger:RBZEventMonthly];
        self.event.date.day = day;
        NSManagedObjectContext *localContext = [NSManagedObjectContext MR_defaultContext];
        [localContext MR_saveToPersistentStoreAndWait];
        [[RBZDateReminder instance] updateEvent:self.event];
        [self.delegate eventUpdated:self.event];
    } else {
        self.picked_type = [NSNumber numberWithInteger:RBZEventMonthly];
        self.picked_day = day;
    }
    [self updateDateLabel];
    [self updateNextLabel];
}

- (void)eventDateYearlyPicked:(NSNumber *)day month:(NSNumber *)month
{
    if (self.event) {
        self.event.date.type = [NSNumber numberWithInteger:RBZEventYearly];
        self.event.date.day = day;
        self.event.date.month = month;
        NSManagedObjectContext *localContext = [NSManagedObjectContext MR_defaultContext];
        [localContext MR_saveToPersistentStoreAndWait];
        [[RBZDateReminder instance] updateEvent:self.event];
        [self.delegate eventUpdated:self.event];
    } else {
        self.picked_type = [NSNumber numberWithInteger:RBZEventYearly];
        self.picked_day = day;
        self.picked_month = month;
    }
    [self updateDateLabel];
    [self updateNextLabel];
}

- (void)eventDateOncePicked:(NSNumber *)day month:(NSNumber *)month year:(NSNumber *)year
{
    if (self.event) {
        self.event.date.type = [NSNumber numberWithInteger:RBZEventOnce];
        self.event.date.day = day;
        self.event.date.month = month;
        self.event.date.year = year;
        NSManagedObjectContext *localContext = [NSManagedObjectContext MR_defaultContext];
        [localContext MR_saveToPersistentStoreAndWait];
        [[RBZDateReminder instance] updateEvent:self.event];
        [self.delegate eventUpdated:self.event];
    } else {
        self.picked_type = [NSNumber numberWithInteger:RBZEventOnce];
        self.picked_day = day;
        self.picked_month = month;
        self.picked_year = year;
    }
    [self updateDateLabel];
    [self updateNextLabel];
}

- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)unregisterForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardDidShowNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}

- (void)keyboardWasShown:(NSNotification *)notification
{
    NSDictionary *info = [notification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(self.scrollView.contentInset.top, 0.0, kbSize.height, 0.0);
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
}

- (void)keyboardWillBeHidden:(NSNotification *)notification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(self.scrollView.contentInset.top, 0.0, 0.0, 0.0);
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
}

- (void)exitEventTextEditing
{
    [self.eventText resignFirstResponder];
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:eventTextHint]) {
        textView.text = nil;
        textView.textColor = self.textColor;
    }
    [UIView animateWithDuration:0.2
                     animations:^{
                         textView.backgroundColor = self.highlightColor;
                         self.nextCell.backgroundColor = self.highlightColor;
                     }];
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    NSString *str = [textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([str length] != 0 && ![str isEqualToString:eventTextHint]) {
        if (self.event && ![self.event.title isEqualToString:str]) {
            self.event.title = str;
            NSManagedObjectContext *localContext = [NSManagedObjectContext MR_defaultContext];
            [localContext MR_saveToPersistentStoreAndWait];
            [[RBZDateReminder instance] updateEvent:self.event];
            [self.delegate eventUpdated:self.event];
        }
    }
    [UIView animateWithDuration:0.2
                     animations:^{
                         textView.backgroundColor = self.backgroundColor;
                         self.nextCell.backgroundColor = self.backgroundColor;
                     }
                     completion:^(BOOL finished) {
                         if ([str length] == 0 || [str isEqualToString:eventTextHint]) {
                             textView.text = eventTextHint;
                             textView.textColor = self.hintColor;
                         }
                     }];
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
    CGRect line = [textView caretRectForPosition:textView.selectedTextRange.start];
    CGFloat overflow = line.origin.y + line.size.height - (textView.contentOffset.y + textView.bounds.size.height - textView.contentInset.bottom - textView.contentInset.top);
    if (overflow > 0) {
        CGPoint offset = textView.contentOffset;
        offset.y += overflow + 7;
        // Cannot animate with setContentOffset:animated: or caret will not appear
        [UIView animateWithDuration:.2 animations:^{
            [textView setContentOffset:offset];
        }];
    }
}

@end
