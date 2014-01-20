//
//  RBZEventListViewController.m
//  Date Reminder
//
//  Created by robin on 13-12-12.
//  Copyright (c) 2013年 Robin Zhang. All rights reserved.
//

#import "UIViewController+MMDrawerController.h"
#import "RBZEventListViewController.h"
#import "RBZEventViewController.h"
#import "RBZAllEventViewController.h"
#import "RBZEventListCell.h"
#import "RBZEventListHeader.h"
#import "RBZDateReminder.h"
#import "RBZUtils.h"
#import "GoogleAnalyticsHelper.h"

@interface RBZEventListViewController ()

@property (nonatomic, strong) NSMutableArray *todayEvents;
@property (nonatomic, strong) NSMutableArray *tomorrowEvents;
@property (nonatomic, strong) NSMutableArray *pendingRemoveEvent;
@property (nonatomic, strong) NSMutableArray *pendingAddEvent;
@property (nonatomic, strong) NSMutableSet *pendingUpdateEvent;

@property (nonatomic, strong) NSString *todayDateString;
@property (nonatomic, strong) NSString *tomorrowDateString;

@property UIColor *mainColor;
@property UIColor *cellBgOdd;
@property UIColor *cellBgEven;

@property RBZEventListHeader *todayHeader;
@property RBZEventListHeader *tomorrowHeader;

@property NSDate *displayDate;
@property NSTimer *refreshTimer;

@end

static NSString *const GA_VC_EVENT_LIST = @"Event List View";

static NSString *const DEFAULTS_MENU_BUTTON_HINT = @"dr_menuButtonHint";
static NSString *EventCellIdentifier = @"cell_event";
static NSString *NoEventCellIdentifier = @"cell_noEvent";
static NSString *HeaderIdentifier = @"header_event";
static float coverViewHeight = 20.0;
static float sectionHeaderHeight = 44.0;

@implementation RBZEventListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self commonSetup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonSetup];
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    
    [self.view.layer setCornerRadius:2.0];
    self.view.layer.masksToBounds = YES;
    
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [[UIView alloc] init];
    [self.tableView registerNib:[UINib nibWithNibName:@"EventListHeader" bundle:nil] forHeaderFooterViewReuseIdentifier:HeaderIdentifier];
    //[self.tableView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:NULL];
    
    
}

- (void)commonSetup
{
    self.mainColor = [UIColor colorWithRed:1.0 green:153.0/255.0 blue:0.0 alpha:1.0];
    self.cellBgOdd = [UIColor colorWithRed:249.0/255.0 green:249.0/255.0 blue:249.0/255.0 alpha:1.0];
    self.cellBgEven = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.menuButton addTarget:self action:@selector(onMenuTapped:) forControlEvents:UIControlEventTouchUpInside];
    self.toastLabel.layer.cornerRadius = 4.0;
    self.toastLabel.alpha = 0.0;
    
    [self loadData];
    [self loadQuote];
    //NSLog(@"viewDidLoad:eventList");
}

- (void)timerFired:(NSTimer *)timer
{
    [self loadData];
    [self loadQuote];
}

- (void)didBecomeActive:(NSNotification *)notification
{
    NSDate *now = [NSDate date];
    if (![RBZUtils onSameDay:now anotherDate:self.displayDate]) {
        [self loadData];
        [self loadQuote];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                              selector:@selector(didBecomeActive:)
                                                  name:UIApplicationDidBecomeActiveNotification
                                                object:nil];
    if (self.mm_drawerController) {
        [self.mm_drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeAll];
        [self.mm_drawerController setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeAll];
    }
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super viewWillDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [GoogleAnalyticsHelper trackScreen:GA_VC_EVENT_LIST];
    NSDate *now = [NSDate date];
    if (![RBZUtils onSameDay:now anotherDate:self.displayDate]) {
        [self loadData];
        [self loadQuote];
    }
    NSDate *date = [RBZUtils beginningOfTomorrow];
    self.refreshTimer = [[NSTimer alloc] initWithFireDate:date
                                              interval:86400
                                                target:self
                                              selector:@selector(timerFired:)
                                              userInfo:nil
                                               repeats:YES];
    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    [runLoop addTimer:self.refreshTimer forMode:NSDefaultRunLoopMode];
    
    [self handlePendingUpdateEvents];
    [self handlePendingRemoveEvents];
    [self handlePendingAddEvents];
    [super viewDidAppear:YES];
}

- (void)viewDidDisappear:(BOOL)animated
{
    //NSLog(@"viewDidDisappear:eventList");
    if (self.refreshTimer)
        [self.refreshTimer invalidate];
    [super viewDidDisappear:animated];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self adjustCoverViewPosition];
    [self adjustMenuButtonPosition];
    [self adjustTodaySectionHeader];
    [self adjustTomorrowSectionHeader];
}

- (void)adjustCoverViewPosition
{
    CGRect frame = self.coverView.frame;
    CGPoint offset = self.tableView.contentOffset;
    if (offset.y < 0) {
        frame.origin.y = -offset.y;
    } else {
        frame.origin.y = 0;
    }
    CGSize size = self.tableView.contentSize;
    if (offset.y > size.height) {
        frame.origin.y = size.height - offset.y;
    }
    self.coverView.frame = frame;
}

- (void)adjustMenuButtonPosition
{
    CGRect frame = self.menuButton.frame;
    CGPoint offset = self.tableView.contentOffset;
    if (offset.y < 0) {
        frame.origin.y = -offset.y + coverViewHeight;
    } else {
        frame.origin.y = coverViewHeight;
    }
    CGSize size = self.tableView.contentSize;
    if (offset.y + frame.size.height > size.height) {
        frame.origin.y = coverViewHeight - (offset.y + frame.size.height - size.height);
    }
    self.menuButton.frame = frame;
}

- (void)adjustTodaySectionHeader
{
    CGRect frame = self.todayHeader.frame;
    CGPoint offset = self.tableView.contentOffset;
    CGFloat alpha = self.todayHeader.contentView.alpha;
    CGFloat distance = frame.origin.y - offset.y;
    if (distance <= -coverViewHeight) {
        if (self.tomorrowHeader && frame.origin.y + sectionHeaderHeight >= self.tomorrowHeader.frame.origin.y) {
            alpha = 0.0;
        }
    } else if (distance < -5.0) {
        if (self.tomorrowHeader && frame.origin.y + sectionHeaderHeight >= self.tomorrowHeader.frame.origin.y) {
            alpha = (distance + coverViewHeight) / (coverViewHeight - 5.0);
        }
    } else {
        alpha = 1.0;
    }
    self.todayHeader.contentView.alpha = alpha;
}

- (void)adjustTomorrowSectionHeader
{
    CGRect frame = self.tomorrowHeader.frame;
    CGPoint offset = self.tableView.contentOffset;
    CGFloat alpha = self.tomorrowHeader.contentView.alpha;
    CGFloat distance = frame.origin.y - offset.y;
    CGSize size = self.tableView.contentSize;
    if (distance <= -coverViewHeight) {
        if (frame.origin.y + sectionHeaderHeight >= size.height) {
            alpha = 0.0;
        }
    } else if (distance < -5.0) {
        if (frame.origin.y + sectionHeaderHeight >= size.height) {
            alpha = (distance + coverViewHeight) / (coverViewHeight - 5.0);
        }
    } else {
        alpha = 1.0;
    }
    self.tomorrowHeader.contentView.alpha = alpha;
}

- (void)showToast
{
    self.toastLabel.alpha = 0.9;
    [UIView animateWithDuration:0.8
                     animations:^{
                         self.toastLabel.alpha = 1.0;
                     }
                     completion:^(BOOL finished) {
                         [UIView animateWithDuration:1.5
                                          animations:^{
                                              self.toastLabel.alpha = 0.0;
                                          }
                                          completion:^(BOOL finished) {
                                              
                                          }];
                     }];
    
}

- (IBAction)onMenuTapped:(id)sender
{
    [self.mm_drawerController openDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"segue_detailedEvent"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        Event *ev = [self getEventAtIndexPath:indexPath];
        RBZEventViewController *dest = [segue destinationViewController];
        dest.delegate = self;
        dest.event = ev;
    } else if ([segue.identifier isEqualToString:@"segue_addEvent"]) {
        RBZEventViewController *dest = [segue destinationViewController];
        dest.delegate = self;
    }
}

- (IBAction)unwindFromAll:(UIStoryboardSegue *)segue
{
    RBZAllEventViewController *vc = (RBZAllEventViewController *)[segue sourceViewController];
    if (vc.changed) {
        [self loadData];
        RBZSettingsViewController *settingsVc = (RBZSettingsViewController *)self.mm_drawerController.leftDrawerViewController;
        [settingsVc updateAllEventsLabel];
    }
}

- (void)navigateToAllEvent
{
    RBZAllEventViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"nav_allEvent"];
    vc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self.navigationController presentViewController:vc animated:YES completion:^{}];
}

- (void)loadQuote
{
}

- (void)loadData
{
    RBZDateReminder *dr = [RBZDateReminder instance];
    self.todayEvents = [dr getTodayEvents];
    self.tomorrowEvents = [dr getTomorrowEvents];
    self.pendingRemoveEvent = [[NSMutableArray alloc] init];
    self.pendingAddEvent = [[NSMutableArray alloc] init];
    self.pendingUpdateEvent = [[NSMutableSet alloc] init];
    
    NSTimeInterval secondsPerDay = 24 * 60 * 60;
    self.displayDate = [[NSDate alloc] init];
    NSDate *tomorrow = [[NSDate alloc] initWithTimeInterval:secondsPerDay sinceDate:self.displayDate];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMM dd"];
    self.todayDateString = [formatter stringFromDate:self.displayDate];
    self.tomorrowDateString = [formatter stringFromDate:tomorrow];
    [formatter setDateFormat:@"EE"];
    self.todayDateString = [NSString stringWithFormat:@"%@, %@", [formatter stringFromDate:self.displayDate], self.todayDateString];
    self.tomorrowDateString = [NSString stringWithFormat:@"%@, %@", [formatter stringFromDate:tomorrow], self.tomorrowDateString];
    
    [self.tableView reloadData];
}

- (Event *)getNextEvent
{
    NSDate *now = [NSDate date];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *comps = [gregorian components:NSHourCalendarUnit|NSMinuteCalendarUnit fromDate:now];
    
    for (Event *event in self.todayEvents) {
        if (![event.time isTimePassed:comps.minute hour:comps.hour]) {
            return event;
        }
    }
    return nil;
}

- (void)eventDeleted:(Event *)ev
{
    [self.pendingRemoveEvent addObject:ev];
    RBZSettingsViewController *settingsVc = (RBZSettingsViewController *)self.mm_drawerController.leftDrawerViewController;
    [settingsVc updateAllEventsLabel];
}

- (void)handlePendingRemoveEvents
{
    for (Event *ev in self.pendingRemoveEvent) {
        [self removeEventRow:ev];
    }
    [self.pendingRemoveEvent removeAllObjects];
}

- (void)eventCreated:(Event *)ev
{
    [self.pendingAddEvent addObject:ev];
    RBZSettingsViewController *settingsVc = (RBZSettingsViewController *)self.mm_drawerController.leftDrawerViewController;
    [settingsVc updateAllEventsLabel];
}

- (void)handlePendingAddEvents
{
    for (Event *ev in self.pendingAddEvent) {
        [self insertEventRow:ev];
    }

    [self.pendingAddEvent removeAllObjects];
}

- (void)eventUpdated:(Event *)ev
{
    [self.pendingUpdateEvent addObject:ev];
}

- (void)handlePendingUpdateEvents
{
    for (Event *ev in self.pendingUpdateEvent) {
        [self.pendingRemoveEvent addObject:ev];
        [self.pendingAddEvent addObject:ev];
    }
    [self.pendingUpdateEvent removeAllObjects];
}

- (void)removeEventRow:(Event *)ev
{
    [self.tableView beginUpdates];
    [self removeEventRow:ev inSection:SECTION_TODAY];
    [self removeEventRow:ev inSection:SECTION_TOMORROW];
    [self.tableView endUpdates];
}

- (void)removeEventRow:(Event *)ev inSection:(NSInteger)section
{
    NSMutableArray *data;
    if (section == SECTION_TODAY)
        data = self.todayEvents;
    else if (section == SECTION_TOMORROW)
        data = self.tomorrowEvents;
    else
        return;
    NSInteger idx = [data indexOfObject:ev];
    if (idx != NSNotFound) {
        [data removeObjectAtIndex:idx];
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:idx inSection:section];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:YES];
        if ([data count] == 0) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:section];
            [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:YES];
        }
    }
}

- (void)insertEventRow:(Event *)ev
{
    [self.tableView beginUpdates];
    BOOL insertedToday = [self insertEventRow:ev inSection:SECTION_TODAY];
    BOOL insertedTomorrow = [self insertEventRow:ev inSection:SECTION_TOMORROW];
    [self.tableView endUpdates];
    if (!insertedToday && !insertedTomorrow)
        [self showToast];
}

- (BOOL)insertEventRow:(Event *)ev inSection:(NSInteger)section
{
    NSDate *date;
    NSMutableArray *data;
    if (section == SECTION_TODAY) {
        data = self.todayEvents;
        date = [NSDate date];
    } else if (section == SECTION_TOMORROW) {
        data = self.tomorrowEvents;
        NSTimeInterval secondsPerDay = 24 * 60 * 60;
        date = [NSDate dateWithTimeIntervalSinceNow:secondsPerDay];
    } else {
        return NO;
    }
    
    if ([ev isOnDate:date]) {
        if ([data count] == 0) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:section];
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:YES];
        }
        int idx = 0;
        for ( ; idx < [data count]; idx++) {
            Event *curr = data[idx];
            if ([curr.time.hour integerValue] > [ev.time.hour integerValue])
                break;
            else if ([curr.time.hour integerValue] == [ev.time.hour integerValue])
                if ([curr.time.minute integerValue] > [ev.time.minute integerValue])
                    break;
        }
        [data insertObject:ev atIndex:idx];
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:idx inSection:section];
        [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:YES];
        return YES;
    } else {
        return NO;
    }
}

#pragma mark - Table view data source

static const NSInteger SECTION_TODAY = 0;
static const NSInteger SECTION_TOMORROW = 1;
static const NSInteger SECTION_COUNT = 2;

- (Event *)getEventAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *events;
    if (indexPath.section == SECTION_TODAY) {
        events = self.todayEvents;
    } else if (indexPath.section == SECTION_TOMORROW) {
        events = self.tomorrowEvents;
    }
    Event *ev = [events objectAtIndex:indexPath.row];
    return ev;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return sectionHeaderHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    RBZEventListHeader *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:HeaderIdentifier];
    if (section == SECTION_TODAY) {
        headerView.titleLabel.text = @"TODAY";
        headerView.dateLabel.text = self.todayDateString;
        self.todayHeader = headerView;
    } else if (section == SECTION_TOMORROW) {
        headerView.titleLabel.text = @"TOMORROW";
        headerView.dateLabel.text = self.tomorrowDateString;
        self.tomorrowHeader = headerView;
    }
    return headerView;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return SECTION_COUNT;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == SECTION_TODAY) {
        NSInteger count = [self.todayEvents count];
        return count > 0 ? count : 1;
    } else if (section == SECTION_TOMORROW) {
        NSInteger count = [self.tomorrowEvents count];
        return count > 0 ? count : 1;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ((indexPath.section == SECTION_TODAY && [self.todayEvents count] == 0)
        || (indexPath.section == SECTION_TOMORROW && [self.tomorrowEvents count] == 0)) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NoEventCellIdentifier forIndexPath:indexPath];
        return cell;
    }
    
    
    RBZEventListCell *cell = [tableView dequeueReusableCellWithIdentifier:EventCellIdentifier forIndexPath:indexPath];
    Event *ev = [self getEventAtIndexPath:indexPath];
    cell.titleLabel.text = ev.title;
    cell.timeLabel.text = ev.time.getTimeString;
    if ([ev.reminder.hasReminder boolValue]) {
        [cell.reminderImage setHidden:NO];
    } else {
        [cell.reminderImage setHidden:YES];
    }
    if (indexPath.row % 2 == 1)
        cell.contentView.backgroundColor = self.cellBgOdd;
    else
        cell.contentView.backgroundColor = self.cellBgEven;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self adjustCoverViewPosition];
    [self adjustMenuButtonPosition];
}

@end
