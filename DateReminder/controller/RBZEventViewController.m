//
//  RBZEventViewController.m
//  DateReminder
//
//  Created by robin on 2/14/14.
//  Copyright (c) 2014 Robin Zhang. All rights reserved.
//

#import "RBZEventViewController.h"
#import "RBZTimePickerViewController.h"
#import "RBZDatePickerViewController.h"
#import "RBZEventBadgeCell.h"
#import "RBZEventBadgeFlowLayout.h"
#import "RBZEventTimeHintView.h"
#import "RBZEventDateHintView.h"
#import "RBZEventReminderHintView.h"
#import "RBZUtils.h"
#import "RZSquaresLoading.h"
#import "GoogleAnalyticsHelper.h"

@interface RBZEventViewController () <UIViewControllerTransitioningDelegate>

@end

@implementation RBZEventViewController {
    UIColor *_mainColor;
    UIColor *_highlightColor;
    UIColor *_invalidateColor;
    UIColor *_buttonInvalidateColor;
    UIColor *_titleTextColor;
    UIColor *_titleHintColor;
    UIColor *_titleBackgroundColor;
    
    NSNumber *_pickedHour;
    NSNumber *_pickedMinute;
    NSNumber *_pickedType;
    NSNumber *_pickedDay;
    NSNumber *_pickedMonth;
    NSNumber *_pickedWeekday;
    NSNumber *_pickedYear;
    NSNumber *_pickedHasReminder;
    NSNumber *_pickedMinutesBefore;
    
    BOOL _quickControlAnimating;
    BOOL _calendarPickerShown;
    BOOL _reminderPickerShown;
    
    BOOL _titleInputPrompt;
    BOOL _needUpdateTimeBadge;
    BOOL _needUpdateDateBadge;
    UILabel *_dummyBadgeLabel;
    NSMutableArray *_badges;
    BOOL _timeBadge;
    BOOL _dateBadge;
    BOOL _reminderBadge;
    
    NSTimer *_refreshTimer;
    
    UIView *_eventTimeHintView;
    BOOL _needShowDateHint;
    UIView *_eventDateHintView;
    BOOL _needShowReminderHint;
    UIView *_eventReminderHintView;
}

static NSString *const GA_VC_EVENT_VIEW = @"Event View";
static NSString *_titleHint = @"Notes...";

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self commonSetup];
    
    if (self.event) {
        self.createButton.hidden = YES;
        self.discardButton.hidden = YES;
        self.controlViewBottonSpace.constant = 0.0;
        self.textView.text = self.event.title;
    } else {
        self.backButton.hidden = YES;
        self.deleteButton.hidden = YES;
        self.eventContainerTopConstraint.constant = 4.0;
        self.textView.textColor = _titleHintColor;
        self.textView.text = _titleHint;
    }
    
    UITapGestureRecognizer *tapOutside = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onOutsideTapped:)];
    tapOutside.delegate = self;
    [self.view addGestureRecognizer:tapOutside];
    
    self.textView.delegate = self;
    [self setupButtons];
    [self setupBadges];
    [self setupCountdown];
    [self updateRepeatIndicator];
    
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [RBZUtils dropShadow:self.backButton];
    [RBZUtils dropShadow:self.deleteButton];
    [RBZUtils dropShadow:self.createButton];
    [RBZUtils dropShadow:self.discardButton];
    [RBZUtils dropShadow:self.textViewContainer];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    //[self registerForKeyboardNotifications];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    //[self unregisterForKeyboardNotifications];
    [super viewWillDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [GoogleAnalyticsHelper trackScreen:GA_VC_EVENT_VIEW];
    
    _refreshTimer = [NSTimer scheduledTimerWithTimeInterval:1
                                                     target:self
                                                   selector:@selector(onRefreshTimerFired:)
                                                   userInfo:nil
                                                    repeats:YES];
    if (!_titleInputPrompt && !self.event) {
        _titleInputPrompt = YES;
        [self.textView becomeFirstResponder];
    }
    if (_needUpdateTimeBadge)
        [self updateTimeBadge];
    if (_needUpdateDateBadge)
        [self updateDateBadge];
    if (_needShowDateHint)
        [self displayEventDateHint];
    if (_needShowReminderHint)
        [self displayEventReminderHint];
}

- (void)viewDidDisappear:(BOOL)animated
{
    if (_refreshTimer)
        [_refreshTimer invalidate];
    _refreshTimer = nil;
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)commonSetup
{
    _mainColor = [UIColor colorWithRed:251.0/255.0 green:119.0/255.0 blue:52.0/255.0 alpha:1.0];
    _highlightColor = [UIColor colorWithRed:251.0/255.0 green:119.0/255.0 blue:52.0/255.0 alpha:.1];
    _invalidateColor = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:.3];
    _buttonInvalidateColor = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:1.0];
    _titleTextColor = [UIColor blackColor];
    _titleHintColor = [UIColor lightGrayColor];
    _titleBackgroundColor = [UIColor clearColor];
    
    float cornerRadius = 3.0;
    self.backButton.layer.cornerRadius = cornerRadius;
    self.deleteButton.layer.cornerRadius = cornerRadius;
    self.createButton.layer.cornerRadius = cornerRadius;
    self.discardButton.layer.cornerRadius = cornerRadius;
    self.textViewContainer.layer.cornerRadius = cornerRadius;
    //[RBZUtils roundedCornerMask:self.textViewContainer corners:UIRectCornerTopLeft|UIRectCornerTopRight radius:cornerRadius];
    self.controlContainer.clipsToBounds = YES;
}

- (void)setupButtons
{
    [self.backButton addTarget:self action:@selector(onBackTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.deleteButton addTarget:self action:@selector(onDeleteTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.discardButton addTarget:self action:@selector(onDiscardTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.createButton addTarget:self action:@selector(onCreateTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.timeButton addTarget:self action:@selector(onTimeButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.dateButton addTarget:self action:@selector(onDateButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.reminderButton addTarget:self action:@selector(onReminderButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)setupBadges
{
    _dummyBadgeLabel = [[UILabel alloc] init];
    _dummyBadgeLabel.font = [UIFont fontWithName:@"AvenirNextCondensed-Regular" size:20.0];
    _badges = [[NSMutableArray alloc] init];
    if (self.event) {
        _timeBadge = _dateBadge = _reminderBadge = YES;
        [_badges addObject:[self.event.time getTimeString]];
        [_badges addObject:[self.event.date getTypeString]];
        [_badges addObject:[self.event.reminder getReminderString]];
    }
    self.badgeCollectionView.dataSource = self;
    self.badgeCollectionView.delegate = self;
    self.badgeCollectionView.collectionViewLayout = [[RBZEventBadgeFlowLayout alloc] init];
    [self.badgeCollectionView reloadData];
}

- (void)setupCountdown
{
    RZSquaresLoading *sl = [[RZSquaresLoading alloc] initWithFrame:CGRectMake(0, 0, 12, 12)];
    sl.color = _mainColor;
    [self.loadingView addSubview:sl];
    self.countdownLabel.alpha = 0.0;
    self.loadingView.alpha = 0.0;
    [self updateCountdownLabel];
}

- (BOOL)validateNewEventValue
{
    BOOL hasTitle, hasTime, hasDate;
    hasTitle = hasTime = hasDate = NO;
    
    NSString *str = [self.textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([str length] != 0 && ![str isEqualToString:_titleHint])
        hasTitle = YES;
    if (_pickedHour && _pickedMinute)
        hasTime = YES;
    if (_pickedType)
        hasDate = YES;
    if (!_pickedHasReminder) {
        _pickedHasReminder = [NSNumber numberWithBool:NO];
        [self updateReminderBadge];
    }
    
    if (!hasTitle) {
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"backgroundColor"];
        animation.autoreverses = YES;
        animation.repeatCount = 2;
        animation.toValue = (id)_invalidateColor.CGColor;
        animation.duration = 0.2;
        [self.textView.layer addAnimation:animation forKey:@"backgroundColor"];
    }
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"backgroundColor"];
    animation.autoreverses = YES;
    animation.repeatCount = 2;
    animation.toValue = (id)_buttonInvalidateColor.CGColor;
    animation.duration = 0.2;
    if (!hasTime)
        [self.timeButton.layer addAnimation:animation forKey:@"backgroundColor"];
    if (!hasDate)
        [self.dateButton.layer addAnimation:animation forKey:@"backgroundColor"];
    
    return hasTitle && hasTime && hasDate;
}

- (Event *)createNewEvent
{
    NSManagedObjectContext *localContext = [NSManagedObjectContext MR_defaultContext];
    Event *event = [Event MR_createInContext:localContext];
    event.title = [self.textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    EventTime *time = [EventTime MR_createInContext:localContext];
    time.hour = _pickedHour;
    time.minute = _pickedMinute;
    
    EventDate *date = [EventDate MR_createInContext:localContext];
    date.type = _pickedType;
    switch ([date.type integerValue]) {
        case RBZEventOnce:
            date.day = _pickedDay;
            date.month = _pickedMonth;
            date.year = _pickedYear;
            break;
        case RBZEventDaily:
            break;
        case RBZEventWeekly:
            date.weekday = _pickedWeekday;
            break;
        case RBZEventMonthly:
            date.day = _pickedDay;
            break;
        case RBZEventYearly:
            date.day = _pickedDay;
            date.month = _pickedMonth;
            break;
    }
    
    EventReminder *reminder = [EventReminder MR_createInContext:localContext];
    reminder.hasReminder = _pickedHasReminder;
    reminder.minutesBefore = _pickedMinutesBefore;
    
    event.date = date;
    event.time = time;
    event.reminder = reminder;
    [localContext MR_saveToPersistentStoreAndWait];
    
    [GoogleAnalyticsHelper trackCreateEvent:event];
    return event;
}

#pragma mark - Event Badges

- (void)updateTimeBadge
{
    _needUpdateTimeBadge = NO;
    NSString *str;
    if (self.event)
        str = [self.event.time getTimeString];
    else if (_pickedMinute && _pickedHour)
        str = [EventTime getTimeString:_pickedMinute hour:_pickedHour];
    
    if (str) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
        if (_timeBadge) {
            _badges[0] = str;
            [self.badgeCollectionView reloadItemsAtIndexPaths:@[indexPath]];
        } else {
            _timeBadge = YES;
            [_badges insertObject:str atIndex:0];
            [self.badgeCollectionView insertItemsAtIndexPaths:@[indexPath]];
        }
    }
}

- (void)updateDateBadge
{
    _needUpdateDateBadge = NO;
    NSString *str;
    if (self.event) {
        str = [self.event.date getTypeString];
    } else if (_pickedType) {
        switch ([_pickedType integerValue]) {
            case RBZEventOnce:
                str = [EventDate getOnceString:_pickedDay month:_pickedMonth year:_pickedYear];
                break;
            case RBZEventDaily:
                str = [EventDate getDailyString];
                break;
            case RBZEventWeekly:
                str = [EventDate getWeeklyString:_pickedWeekday];
                break;
            case RBZEventMonthly:
                str = [EventDate getMonthlyString:_pickedDay];
                break;
            case RBZEventYearly:
                str = [EventDate getYearlyString:_pickedDay month:_pickedMonth];
                break;
        }
    }
    
    if (str) {
        int index = 0;
        if (_timeBadge)
            index++;
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
        if (_dateBadge) {
            _badges[index] = str;
            [self.badgeCollectionView reloadItemsAtIndexPaths:@[indexPath]];
        } else {
            _dateBadge = YES;
            [_badges insertObject:str atIndex:index];
            [self.badgeCollectionView insertItemsAtIndexPaths:@[indexPath]];
        }
    }
    [self updateRepeatIndicator];
}

- (void)updateReminderBadge
{
    NSString *str;
    if (self.event)
        str = [self.event.reminder getReminderString];
    else if (_pickedHasReminder)
        str = [EventReminder getReminderString:_pickedHasReminder minutes:_pickedMinutesBefore];
    
    if (str) {
        int index = 0;
        if (_timeBadge)
            index++;
        if (_dateBadge)
            index++;
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
        if (_reminderBadge) {
            _badges[index] = str;
            [self.badgeCollectionView reloadItemsAtIndexPaths:@[indexPath]];
        } else {
            _reminderBadge = YES;
            [_badges insertObject:str atIndex:index];
            [self.badgeCollectionView insertItemsAtIndexPaths:@[indexPath]];
        }
    }
}

- (void)updateCountdownLabel
{
    NSDate *next;
    BOOL expired = NO;
    if (_pickedMinute && _pickedHour && _pickedType) {
        next = [Event getNextDate:_pickedType
                           minute:_pickedMinute
                             hour:_pickedHour
                              day:_pickedDay
                          weekday:_pickedWeekday
                            month:_pickedMonth
                             year:_pickedYear];
        expired = [Event isExpired:[[NSDate alloc] init]
                              type:_pickedType
                            minute:_pickedMinute
                              hour:_pickedHour
                               day:_pickedDay
                           weekday:_pickedWeekday
                             month:_pickedMonth
                              year:_pickedYear];
    } else if (self.event) {
        next = [self.event getNextDate];
        expired = [self.event isExpired:[[NSDate alloc] init]];
    }
    
    [UIView animateWithDuration:.1
                     animations:^{
                         if (next) {
                             if (expired) {
                                 self.countdownLabel.text = @"Expired";
                                 self.countdownLabel.alpha = 1.0;
                                 self.loadingView.alpha = 0.0;
                                 self.countdownLabelTrailingSpace.constant = 12.0;
                                 [self.countdownLabel layoutIfNeeded];
                             } else {
                                 NSTimeInterval interval = [next timeIntervalSinceNow];
                                 self.countdownLabel.text = [NSString stringWithFormat:@"%@ %@", @"Coming in",
                                                            [RBZUtils getReadableTimeInterval:interval]];
                                 self.countdownLabel.alpha = 1.0;
                                 self.loadingView.alpha = 1.0;
                                 self.countdownLabelTrailingSpace.constant = 36.0;
                                 [self.countdownLabel layoutIfNeeded];
                             }
                         } else {
                             self.countdownLabel.text = @"";
                             self.countdownLabel.alpha = 0.0;
                             self.loadingView.alpha = 0.0;
                             self.countdownLabelTrailingSpace.constant = 12.0;
                             [self.countdownLabel layoutIfNeeded];
                         }
                     }];
}

- (void)updateRepeatIndicator
{
    BOOL isRepeat = NO;
    if (self.event)
        isRepeat = ([self.event.date.type integerValue] != RBZEventOnce);
    else if (_pickedType)
        isRepeat = ([_pickedType integerValue] != RBZEventOnce);
    self.repeatImageView.hidden = !isRepeat;
}

#pragma mark - Event Handling

- (void)onRefreshTimerFired:(NSTimer *)timer
{
    [self updateCountdownLabel];
}

- (IBAction)onOutsideTapped:(id)sender
{
    [self exitEventTextEditing];
}

- (IBAction)onCreateTapped:(id)sender
{
    [self hideControlContainer];
    if ([self validateNewEventValue]) {
        Event *event = [self createNewEvent];
        [[RBZDateReminder instance] addEvent:event];
        [self.delegate eventCreated:event];
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [GoogleAnalyticsHelper trackEventWithCategory:GA_CATEGORY_UI
                                               action:GA_ACTION_CREATE_INVALIDATE
                                                label:nil
                                                value:nil];
    }
}

- (IBAction)onDiscardTapped:(id)sender
{
    [GoogleAnalyticsHelper trackEventWithCategory:GA_CATEGORY_UI
                                           action:GA_ACTION_DISCARD_CREATE
                                            label:nil
                                            value:nil];
    [self hideControlContainer];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onBackTapped:(id)sender
{
    [self hideControlContainer];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onDeleteTapped:(id)sender
{
    [GoogleAnalyticsHelper trackEventWithCategory:GA_CATEGORY_UI
                                           action:GA_ACTION_DELETE_BUTTON
                                            label:nil
                                            value:nil];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Delete this event?"
                                                    message:nil
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Delete", nil];
    [alert show];
}

- (IBAction)onTimeButtonTapped:(id)sender
{
    [GoogleAnalyticsHelper trackEventWithCategory:GA_CATEGORY_UI
                                           action:GA_ACTION_TIME_BUTTON
                                            label:nil
                                            value:nil];
    if (_eventTimeHintView) {
        [_eventTimeHintView removeFromSuperview];
        _eventTimeHintView = nil;
    }
    [self hideControlContainer];
    RBZTimePickerViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"vc_timePicker"];
    if (self.event) {
        vc.hour = self.event.time.hour;
        vc.minute = self.event.time.minute;
    } else {
        vc.hour = _pickedHour;
        vc.minute = _pickedMinute;
    }
    [self presentViewController:vc animated:YES completion:nil];
}

- (IBAction)onDateButtonTapped:(id)sender
{
    [GoogleAnalyticsHelper trackEventWithCategory:GA_CATEGORY_UI
                                           action:GA_ACTION_DATE_BUTTON
                                            label:nil
                                            value:nil];
    if (_eventDateHintView) {
        [_eventDateHintView removeFromSuperview];
        _eventDateHintView = nil;
    }
    if (_quickControlAnimating)
        return;
    if (!_calendarPickerShown)
        [self showQuickCalendarPicker];
    else
        [self hideControlContainer];
}

- (IBAction)onReminderButtonTapped:(id)sender
{
    [GoogleAnalyticsHelper trackEventWithCategory:GA_CATEGORY_UI
                                           action:GA_ACTION_REMINDER_BUTTON
                                            label:nil
                                            value:nil];
    if (_eventReminderHintView) {
        [_eventReminderHintView removeFromSuperview];
        _eventReminderHintView = nil;
    }
    if (_quickControlAnimating)
        return;
    if (!_reminderPickerShown)
        [self showQuickReminderPicker];
    else
        [self hideControlContainer];
}

#pragma mark - Segues

- (IBAction)onTimePicked:(UIStoryboardSegue *)segue
{
    RBZTimePickerViewController *src = (RBZTimePickerViewController *)segue.sourceViewController;
    if (self.event) {
        self.event.time.hour = src.hour;
        self.event.time.minute = src.minute;
        NSManagedObjectContext *localContext = [NSManagedObjectContext MR_defaultContext];
        [localContext MR_saveToPersistentStoreAndWait];
        [[RBZDateReminder instance] updateEvent:self.event];
        [self.delegate eventUpdated:self.event];
    } else {
        _pickedHour = src.hour;
        _pickedMinute = src.minute;
    }
    _needUpdateTimeBadge = YES;
    _needShowDateHint = YES;
}

- (IBAction)onDatePicked:(UIStoryboardSegue *)segue
{
    [GoogleAnalyticsHelper trackEventWithCategory:GA_CATEGORY_UI
                                           action:GA_ACTION_DATE_FROM_PICKER_VIEW
                                            label:nil
                                            value:nil];
    RBZDatePickerViewController *src = (RBZDatePickerViewController *)segue.sourceViewController;
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
        _pickedType = src.type;
        _pickedDay = src.day;
        _pickedWeekday = src.weekday;
        _pickedMonth = src.month;
        _pickedYear = src.year;
    }
    _needUpdateDateBadge = YES;
    _needShowReminderHint = YES;
}

#pragma mark - Gesture Recognizer Delegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([self.textView isFirstResponder])
        return YES;
    return NO;
}

#pragma mark - TextView and Keyboard

- (void)exitEventTextEditing
{
    [self.textView resignFirstResponder];
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
}

- (void)keyboardWillBeHidden:(NSNotification *)notification
{
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    [self hideControlContainer];
    if ([textView.text isEqualToString:_titleHint]) {
        textView.text = nil;
        textView.textColor = _titleTextColor;
    }
    [UIView animateWithDuration:0.2
                     animations:^{
                         textView.backgroundColor = _highlightColor;
                     }];
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    NSString *str = [textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([str length] != 0 && ![str isEqualToString:_titleHint]) {
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
                         textView.backgroundColor = _titleBackgroundColor;
                     }
                     completion:^(BOOL finished) {
                         if ([str length] == 0 || [str isEqualToString:_titleHint]) {
                             textView.text = _titleHint;
                             textView.textColor = _titleHintColor;
                         }
                         [self displayEventTimeHint];
                     }];
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
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

#pragma mark - Badge Collection View Datasource & Delegate

static const float _badgeTitleInsets = 6.0;
static const float _badgeHeight = 36.0;

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [_badges count];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *str = _badges[indexPath.item];
    _dummyBadgeLabel.text = str;
    [_dummyBadgeLabel sizeToFit];
    CGSize size = CGSizeMake(_dummyBadgeLabel.frame.size.width + 2 * _badgeTitleInsets, _badgeHeight);
    return size;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"badge";
    RBZEventBadgeCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    NSString *str = _badges[indexPath.item];
    cell.titleLabel.text = str;
    [cell.titleLabel sizeToFit];
    [RBZUtils dropShadow:cell];
    cell.clipsToBounds = NO;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    int timeBadgeIndex, dateBadgeIndex, reminderBadgeIndex;
    timeBadgeIndex = dateBadgeIndex = reminderBadgeIndex = 0;
    if (_timeBadge) {
        dateBadgeIndex++;
        reminderBadgeIndex++;
    } else {
        timeBadgeIndex = -1;
    }
    if (_dateBadge) {
        reminderBadgeIndex++;
    } else {
        dateBadgeIndex = -1;
    }
    if (_reminderBadge) {
        
    } else {
        reminderBadgeIndex = -1;
    }
    
    if (indexPath.item == timeBadgeIndex) {
        [GoogleAnalyticsHelper trackEventWithCategory:GA_CATEGORY_UI
                                               action:GA_ACTION_TIME_BADGE
                                                label:nil
                                                value:nil];
        [self hideControlContainer];
        RBZTimePickerViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"vc_timePicker"];
        if (self.event) {
            vc.hour = self.event.time.hour;
            vc.minute = self.event.time.minute;
        } else {
            vc.hour = _pickedHour;
            vc.minute = _pickedMinute;
        }
        [self presentViewController:vc animated:YES completion:nil];
    }
    else if (indexPath.item == dateBadgeIndex) {
        [GoogleAnalyticsHelper trackEventWithCategory:GA_CATEGORY_UI
                                               action:GA_ACTION_DATE_BADGE
                                                label:nil
                                                value:nil];
        [self showQuickCalendarPicker];
    }
    else if (indexPath.item == reminderBadgeIndex) {
        [GoogleAnalyticsHelper trackEventWithCategory:GA_CATEGORY_UI
                                               action:GA_ACTION_REMINDER_BADGE
                                                label:nil
                                                value:nil];
        [self showQuickReminderPicker];
    }
}

#pragma mark - Controls

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [GoogleAnalyticsHelper trackDeleteEvent:self.event];
        NSManagedObjectContext *localContext = [NSManagedObjectContext MR_defaultContext];
        [self.event MR_deleteInContext:localContext];
        [localContext MR_saveToPersistentStoreAndWait];
        [[RBZDateReminder instance] removeEvent:self.event];
        [self.delegate eventDeleted:self.event];
        self.event = nil;
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)showQuickCalendarPicker
{
    _quickControlAnimating = YES;
    _calendarPickerShown = YES;
    
    UIView *view = [self loadQuickCalendarPickerView];
    self.quickControlViewHeightConstraint.constant = view.frame.size.height;
    [UIView animateWithDuration:.1
                     animations:^{
                         self.quickControlView.alpha = 1.0;
                         [self.controlContainer layoutIfNeeded];
                     }
                     completion:^(BOOL finished) {
                         if (_reminderPickerShown) {
                             [UIView transitionFromView:self.quickControlView.subviews[0]
                                                 toView:view
                                               duration:.2
                                                options:UIViewAnimationOptionTransitionFlipFromBottom
                                             completion:^(BOOL finished) {
                                                 _reminderPickerShown = NO;
                                                 _quickControlAnimating = NO;
                                             }];
                         } else {
                             [self.quickControlView addSubview:view];
                             _quickControlAnimating = NO;
                         }
                     }];
}

- (void)showQuickReminderPicker
{
    _quickControlAnimating = YES;
    _reminderPickerShown = YES;
    
    UIView *view = [self loadQuickReminderPickerView];
    if (_calendarPickerShown) {
        [UIView transitionFromView:self.quickControlView.subviews[0]
                            toView:view
                          duration:.2
                           options:UIViewAnimationOptionTransitionFlipFromBottom
                        completion:^(BOOL finished) {
                            self.quickControlViewHeightConstraint.constant = view.frame.size.height;
                            [UIView animateWithDuration:.1
                                             animations:^{
                                                 [self.controlContainer layoutIfNeeded];
                                             }
                                             completion:^(BOOL finished) {
                                                 _calendarPickerShown = NO;
                                                 _quickControlAnimating = NO;
                                             }];
                        }];
    } else {
        self.quickControlViewHeightConstraint.constant = view.frame.size.height;
        [UIView animateWithDuration:.1
                         animations:^{
                             self.quickControlView.alpha = 1.0;
                             [self.controlContainer layoutIfNeeded];
                         }
                         completion:^(BOOL finished) {
                             [self.quickControlView addSubview:view];
                             _quickControlAnimating = NO;
                         }];
    }
}

- (void)hideControlContainer
{
    _quickControlAnimating = YES;
    _calendarPickerShown = NO;
    _reminderPickerShown = NO;
    self.quickControlViewHeightConstraint.constant = 0.0;
    [UIView animateWithDuration:0.1
                     animations:^{
                         self.quickControlView.alpha = 0.0;
                         [self.view layoutIfNeeded];
                     }
                     completion:^(BOOL finished) {
                         for (UIView *view in self.quickControlView.subviews)
                             [view removeFromSuperview];
                         _quickControlAnimating = NO;
                     }];
}

- (RBZQuickCalendarPickerView *)loadQuickCalendarPickerView
{
    NSArray *quickControls = [[NSBundle mainBundle] loadNibNamed:@"QuickCalendarPickerView" owner:self options:nil];
    RBZQuickCalendarPickerView *calendarPicker = (RBZQuickCalendarPickerView *)quickControls[0];
    calendarPicker.delegate = self;
    return calendarPicker;
}

- (UIView *)loadQuickReminderPickerView
{
    NSArray *quickControls = [[NSBundle mainBundle] loadNibNamed:@"QuickReminderPickerView" owner:self options:nil];
    RBZQuickReminderPickerView *reminderPicker = (RBZQuickReminderPickerView *)quickControls[0];
    reminderPicker.delegate = self;
    return reminderPicker;
}

- (void)quickCalendarPickerView:(RBZQuickCalendarPickerView *)view didSelectDate:(NSDate *)date
{
    [GoogleAnalyticsHelper trackEventWithCategory:GA_CATEGORY_UI
                                           action:GA_ACTION_DATE_FROM_QUICK_PICKER
                                            label:nil
                                            value:nil];
    NSCalendar *calendar = [[RBZDateReminder instance] defaultCalendar];
    NSDateComponents *comps = [calendar components:NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit fromDate:date];
    if (self.event) {
        self.event.date.type = [NSNumber numberWithInteger:RBZEventOnce];
        self.event.date.day = [NSNumber numberWithInteger:comps.day];
        self.event.date.month = [NSNumber numberWithInteger:comps.month];
        self.event.date.year = [NSNumber numberWithInteger:comps.year];
        NSManagedObjectContext *localContext = [NSManagedObjectContext MR_defaultContext];
        [localContext MR_saveToPersistentStoreAndWait];
        [[RBZDateReminder instance] updateEvent:self.event];
        [self.delegate eventUpdated:self.event];
    } else {
        _pickedType = [NSNumber numberWithInteger:RBZEventOnce];
        _pickedDay = [NSNumber numberWithInteger:comps.day];
        _pickedWeekday = [NSNumber numberWithInteger:comps.month];
        _pickedMonth = [NSNumber numberWithInteger:comps.month];
        _pickedYear = [NSNumber numberWithInteger:comps.year];
    }
    [self updateDateBadge];
    [self hideControlContainer];
    [self displayEventReminderHint];
}

- (void)quickCalendarPickerViewDidSelectDaily:(RBZQuickCalendarPickerView *)view
{
    [GoogleAnalyticsHelper trackEventWithCategory:GA_CATEGORY_UI
                                           action:GA_ACTION_DATE_FROM_QUICK_PICKER
                                            label:nil
                                            value:nil];
    if (self.event) {
        self.event.date.type = [NSNumber numberWithInteger:RBZEventDaily];
        NSManagedObjectContext *localContext = [NSManagedObjectContext MR_defaultContext];
        [localContext MR_saveToPersistentStoreAndWait];
        [[RBZDateReminder instance] updateEvent:self.event];
        [self.delegate eventUpdated:self.event];
    } else {
        _pickedType = [NSNumber numberWithInteger:RBZEventDaily];
    }
    [self updateDateBadge];
    [self hideControlContainer];
    [self displayEventReminderHint];
}

- (void)quickCalendarPickerViewDidSelectPickOther:(RBZQuickCalendarPickerView *)view
{
    [self hideControlContainer];
    RBZDatePickerViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"vc_datePicker"];
    if (self.event) {
        vc.type = self.event.date.type;
        vc.day = self.event.date.day;
        vc.weekday = self.event.date.weekday;
        vc.month = self.event.date.month;
        vc.year = self.event.date.year;
    } else {
        vc.type = _pickedType;
        vc.day = _pickedDay;
        vc.weekday = _pickedWeekday;
        vc.month = _pickedMonth;
        vc.year = _pickedYear;
    }
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)quickReminderPickerView:(RBZQuickReminderPickerView *)view didSelectReminder:(NSInteger)minutes
{
    if (self.event) {
        self.event.reminder.hasReminder = [NSNumber numberWithBool:YES];
        self.event.reminder.minutesBefore = [NSNumber numberWithInteger:minutes];
        NSManagedObjectContext *localContext = [NSManagedObjectContext MR_defaultContext];
        [localContext MR_saveToPersistentStoreAndWait];
        [[RBZDateReminder instance] updateEvent:self.event];
        [self.delegate eventUpdated:self.event];
    } else {
        _pickedHasReminder = [NSNumber numberWithBool:YES];
        _pickedMinutesBefore = [NSNumber numberWithInteger:minutes];
    }
    [self updateReminderBadge];
    [self hideControlContainer];
}

- (void)quickReminderPickerViewDidSelectNoReminder:(RBZQuickReminderPickerView *)view
{
    if (self.event) {
        self.event.reminder.hasReminder = [NSNumber numberWithBool:NO];
        NSManagedObjectContext *localContext = [NSManagedObjectContext MR_defaultContext];
        [localContext MR_saveToPersistentStoreAndWait];
        [[RBZDateReminder instance] updateEvent:self.event];
        [self.delegate eventUpdated:self.event];
    } else {
        _pickedHasReminder = [NSNumber numberWithBool:NO];
    }
    [self updateReminderBadge];
    [self hideControlContainer];
}

#pragma mark - Hint Message

static NSString *const DEFAULTS_TIME_HINT_SHOWN = @"dr_eventTimeHintShown";
static NSString *const DEFAULTS_DATE_HINT_SHOWN = @"dr_eventDateHintShown";
static NSString *const DEFAULTS_REMINDER_HINT_SHOWN = @"dr_eventReminderHintShown";

- (void)displayEventTimeHint
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (![defaults boolForKey:DEFAULTS_TIME_HINT_SHOWN]) {
        [defaults setBool:YES forKey:DEFAULTS_TIME_HINT_SHOWN];
        [defaults synchronize];
        
        RBZEventTimeHintView *hintView = [self loadEventTimeHintView];
        CGRect frame = CGRectMake(self.timeButton.center.x - 32.0,
                                  self.timeButton.frame.origin.y - hintView.frame.size.height - 7.0,
                                  hintView.frame.size.width,
                                  hintView.frame.size.height);
        hintView.frame = frame;
        _eventTimeHintView = hintView;
        [self.controlsView addSubview:hintView];
        CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"position"];
        anim.beginTime = 0.5 + CACurrentMediaTime();
        anim.autoreverses = YES;
        anim.repeatCount = HUGE_VAL;
        anim.byValue = [NSValue valueWithCGPoint:CGPointMake(0.0, 6.0)];
        anim.duration = 1.0;
        anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        [hintView.layer addAnimation:anim forKey:@"eventTimeHint"];
    }
}

- (void)displayEventDateHint
{
    _needShowDateHint = NO;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (![defaults boolForKey:DEFAULTS_DATE_HINT_SHOWN]) {
        [defaults setBool:YES forKey:DEFAULTS_DATE_HINT_SHOWN];
        [defaults synchronize];
        
        RBZEventDateHintView *hintView = [self loadEventDateHintView];
        CGRect frame = CGRectMake(self.dateButton.center.x - 54.0,
                                  self.dateButton.frame.origin.y - hintView.frame.size.height - 7.0,
                                  hintView.frame.size.width,
                                  hintView.frame.size.height);
        hintView.frame = frame;
        _eventDateHintView = hintView;
        [self.controlsView addSubview:hintView];
        CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"position"];
        anim.beginTime = 0.5 + CACurrentMediaTime();
        anim.autoreverses = YES;
        anim.repeatCount = HUGE_VAL;
        anim.byValue = [NSValue valueWithCGPoint:CGPointMake(0.0, 6.0)];
        anim.duration = 1.0;
        anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        [hintView.layer addAnimation:anim forKey:@"eventDateHint"];
    }
}

- (void)displayEventReminderHint
{
    _needShowReminderHint = NO;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (![defaults boolForKey:DEFAULTS_REMINDER_HINT_SHOWN]) {
        [defaults setBool:YES forKey:DEFAULTS_REMINDER_HINT_SHOWN];
        [defaults synchronize];
        
        RBZEventReminderHintView *hintView = [self loadEventReminderHintView];
        CGRect frame = CGRectMake(self.reminderButton.center.x - 54.0,
                                  self.reminderButton.frame.origin.y - hintView.frame.size.height - 7.0,
                                  hintView.frame.size.width,
                                  hintView.frame.size.height);
        hintView.frame = frame;
        _eventReminderHintView = hintView;
        [self.controlsView addSubview:hintView];
        CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"position"];
        anim.beginTime = 0.5 + CACurrentMediaTime();
        anim.autoreverses = YES;
        anim.repeatCount = HUGE_VAL;
        anim.byValue = [NSValue valueWithCGPoint:CGPointMake(0.0, 6.0)];
        anim.duration = 1.0;
        anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        [hintView.layer addAnimation:anim forKey:@"eventReminderHint"];
    }
}

- (RBZEventTimeHintView *)loadEventTimeHintView
{
    NSArray *views = [[NSBundle mainBundle] loadNibNamed:@"EventTimeHintView" owner:self options:nil];
    RBZEventTimeHintView *hintView = (RBZEventTimeHintView *)views[0];
    return hintView;
}

- (RBZEventDateHintView *)loadEventDateHintView
{
    NSArray *views = [[NSBundle mainBundle] loadNibNamed:@"EventDateHintView" owner:self options:nil];
    RBZEventDateHintView *hintView = (RBZEventDateHintView *)views[0];
    return hintView;
}

- (RBZEventReminderHintView *)loadEventReminderHintView
{
    NSArray *views = [[NSBundle mainBundle] loadNibNamed:@"EventReminderHintView" owner:self options:nil];
    RBZEventReminderHintView *hintView = (RBZEventReminderHintView *)views[0];
    return hintView;
}

@end
