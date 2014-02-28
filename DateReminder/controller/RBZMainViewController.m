//
//  RBZMainViewController.m
//  DateReminder
//
//  Created by robin on 2/12/14.
//  Copyright (c) 2014 Robin Zhang. All rights reserved.
//

#import "UIViewController+MMDrawerController.h"
#import "RBZMainViewController.h"
#import "RBZEventViewController.h"
#import "RBZArchiveViewController.h"
#import "RBZEventListCell.h"
#import "RZSquaresLoading.h"
#import "RBZDateReminder.h"
#import "RBZUtils.h"
#import "GoogleAnalyticsHelper.h"

@interface RBZMainViewController ()

@end

@implementation RBZMainViewController {
    UIColor *_mainColor;
    UIColor *_highlightColor;
    UIColor *_oddCellColor;
    UIColor *_evenCellColor;
    
    NSDate *_displayDate;
    NSMutableArray *_todayEvents;
    NSMutableArray *_tomorrowEvents;
    NSMutableSet *_pendingAddEvents;
    NSMutableSet *_pendingRemoveEvents;
    NSMutableSet *_pendingUpdateEvents;
    Event *_upcomingEvent;
    BOOL _upcomingEventFromTomorrow;
    
    NSTimer *_refreshTimer;
    
    BOOL _tableAnimating;
    BOOL _todayTableShown;
    BOOL _tomorrowTableShown;
    
    UILabel *_dummyHudTimeLabel;
}

static NSString *const GA_VC_MAIN_VIEW = @"Main View";

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
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    
    [self commonSetup];
    [self setupButtons];
    [self setupTables];
    [self setupHud];
    self.popupView.layer.opacity = 0.0;
    
    [self reloadEventData];
}

- (void)viewDidLayoutSubviews
{
    [RBZUtils dropShadow:self.hudContainerView];
    [RBZUtils dropShadow:self.tableView];
    [RBZUtils dropShadow:self.addButton];
    [RBZUtils dropShadow:self.archiveButton];
    [RBZUtils dropShadow:self.settingsButton];
    [RBZUtils roundedCornerMask:self.todayContainerView corners:UIRectCornerAllCorners radius:3.0];
    [RBZUtils roundedCornerMask:self.tomorrowContainerView corners:UIRectCornerAllCorners radius:3.0];
    [RBZUtils roundedCornerMask:self.hudButton corners:UIRectCornerAllCorners radius:3.0];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didBecomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    if (self.mm_drawerController) {
        [self.mm_drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeNone];
        [self.mm_drawerController setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeAll];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super viewWillDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [GoogleAnalyticsHelper trackScreen:GA_VC_MAIN_VIEW];
    
    NSDate *now = [NSDate date];
    if (![RBZUtils onSameDay:now anotherDate:_displayDate]) {
        [self reloadEventData];
    }
    
    NSCalendar *calendar = [[RBZDateReminder instance] defaultCalendar];
    NSDateComponents *comps = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit
                                          fromDate:now];
    NSDate *fireDate = [calendar dateFromComponents:comps];
    fireDate = [NSDate dateWithTimeInterval:60 sinceDate:fireDate];
    _refreshTimer = [[NSTimer alloc] initWithFireDate:fireDate
                                                 interval:60
                                                   target:self
                                                 selector:@selector(onRefreshTimerFired:)
                                                 userInfo:nil
                                                  repeats:YES];
    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    [runLoop addTimer:_refreshTimer forMode:NSDefaultRunLoopMode];
    
    [self handlePendingUpdateEvents];
    [self handlePendingRemoveEvents];
    [self handlePendingAddEvents];
    [self updateHeadUpDisplay];
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
    _highlightColor = [UIColor colorWithRed:251.0/255.0 green:119.0/255.0 blue:52.0/255.0 alpha:.6];
    _oddCellColor = [UIColor colorWithRed:249.0/255.0 green:249.0/255.0 blue:249.0/255.0 alpha:1.0];
    _evenCellColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
    
    self.hudContainerView.layer.cornerRadius = 3.0;
    self.tableView.layer.cornerRadius = 3.0;
    self.addButton.layer.cornerRadius = 3.0;
    self.archiveButton.layer.cornerRadius = 3.0;
    self.settingsButton.layer.cornerRadius = 3.0;
    self.hudTimeView.layer.cornerRadius = 3.0;
    self.popupView.layer.cornerRadius = 3.0;
}

- (void)setupButtons
{
    [self.settingsButton addTarget:self action:@selector(onSettingsButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)setupTables
{
    UIImage *image = [RBZUtils imageWithColor:[UIColor colorWithRed:85.0/255.0 green:85.0/255.0 blue:85.0/255.0 alpha:0.6]];
    self.todayTableView.dataSource = self;
    self.todayTableView.delegate = self;
    self.todayTableView.tableFooterView = [[UIView alloc] init];
    [self.tomorrowButton setBackgroundImage:image forState:UIControlStateHighlighted];
    
    self.tomorrowTableView.dataSource = self;
    self.tomorrowTableView.delegate = self;
    self.tomorrowTableView.tableFooterView = [[UIView alloc] init];
    [self.todayButton setBackgroundImage:image forState:UIControlStateHighlighted];
}

- (void)setupHud
{
    UIImage *image = [RBZUtils imageWithColor:_highlightColor];
    _dummyHudTimeLabel = [[UILabel alloc] init];
    _dummyHudTimeLabel.font = [UIFont fontWithName:@"AvenirNextCondensed-Regular" size:26.0];
    RZSquaresLoading *sl = [[RZSquaresLoading alloc] initWithFrame:CGRectMake(0, 0, 12, 12)];
    sl.color = _mainColor;
    [self.hudLoadingView addSubview:sl];
    [self.hudButton setBackgroundImage:image forState:UIControlStateHighlighted];
    [self.hudButton addTarget:self action:@selector(onHudTapped:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)reloadEventData
{
    RBZDateReminder *dr = [RBZDateReminder instance];
    _displayDate = [NSDate date];
    _todayEvents = [dr getTodayEvents];
    _tomorrowEvents = [dr getTomorrowEvents];
    _pendingRemoveEvents = [[NSMutableSet alloc] init];
    _pendingAddEvents = [[NSMutableSet alloc] init];
    _pendingUpdateEvents = [[NSMutableSet alloc] init];
    [self.todayTableView reloadData];
    [self.tomorrowTableView reloadData];
    
    [self.todayContainerView bringSubviewToFront:self.todayTableView];
    _todayTableShown = YES;
    
    [self updateHeadUpDisplay];
}

- (BOOL)reloadEventDataIfNeeded
{
    NSDate *now = [NSDate date];
    if (![RBZUtils onSameDay:now anotherDate:_displayDate]) {
        [self reloadEventData];
        return YES;
    }
    return NO;
}

- (void)updateHeadUpDisplay
{
    Event *old = _upcomingEvent;
    BOOL oldFromTomorrow = _upcomingEventFromTomorrow;
    
    _upcomingEvent = [self getNextEvent];
    if (!_upcomingEvent && [_tomorrowEvents count] > 0) {
        _upcomingEventFromTomorrow = YES;
        _upcomingEvent = _tomorrowEvents[0];
    } else {
        _upcomingEventFromTomorrow = NO;
    }
    
    if (_upcomingEvent != old || oldFromTomorrow != _upcomingEventFromTomorrow) {
        for (int i = 0; i < [_todayEvents count]; i++) {
            if (_todayEvents[i] == old || _todayEvents[i] == _upcomingEvent) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
                [self.todayTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            }
        }
        for (int i = 0; i < [_tomorrowEvents count]; i++) {
            if (_tomorrowEvents[i] == old || _tomorrowEvents[i] == _upcomingEvent) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
                [self.tomorrowTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            }
        }
    }
    
    NSString *str;
    if (_upcomingEventFromTomorrow)
        str = [NSString stringWithFormat:@"Tomorrow %@", [_upcomingEvent.time getTimeString]];
    else
        str = [_upcomingEvent.time getTimeString];
    [UIView animateWithDuration:.2
                     animations:^{
                         if (_upcomingEvent) {
                             _dummyHudTimeLabel.text = str;
                             [_dummyHudTimeLabel sizeToFit];
                             CGFloat width = _dummyHudTimeLabel.frame.size.width + 12.0;
                             
                             self.hudTitleLabel.text = [_upcomingEvent title];
                             if (width <= self.hudTimeViewWidthConstraint.constant)
                                 self.hudTimeLabel.text = str;
                             self.hudTimeViewWidthConstraint.constant = _dummyHudTimeLabel.frame.size.width + 12.0;
                             self.hudTitleLabel.alpha = 1.0;
                             self.hudTimeView.alpha = 1.0;
                             self.hudLoadingView.alpha = 1.0;
                             self.hudHintLabel.alpha = 0.0;
                         } else {
                             self.hudTitleLabel.text = @"";
                             self.hudTimeLabel.text = @"";
                             self.hudTimeViewWidthConstraint.constant = 0.0;
                             self.hudTitleLabel.alpha = 0.0;
                             self.hudTimeView.alpha = 0.0;
                             self.hudLoadingView.alpha = 0.0;
                             self.hudHintLabel.alpha = 1.0;
                         }
                         
                     } completion:^(BOOL finished) {
                         self.hudTimeLabel.text = str;
                     }];
}

- (Event *)getNextEvent
{
    NSDate *now = [NSDate date];
    NSCalendar *calendar = [[RBZDateReminder instance] defaultCalendar];
    NSDateComponents *comps = [calendar components:NSHourCalendarUnit|NSMinuteCalendarUnit fromDate:now];
    
    for (Event *event in _todayEvents) {
        if (![event.time isTimePassed:comps.minute hour:comps.hour]) {
            return event;
        }
    }
    return nil;
}

- (void)showEventSavedPopup
{
    [GoogleAnalyticsHelper trackEventWithCategory:GA_CATEGORY_UI
                                           action:GA_ACTION_SHOW_CREATE_POPUP
                                            label:nil
                                            value:nil];

    CGPoint buttonCenter = self.archiveButton.center;
    CGPoint popupCenter = self.popupContainer.center;
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, 45.0, 12.0);
    CGPathAddQuadCurveToPoint(path, NULL,
                              buttonCenter.x - popupCenter.x + 45.0, 12.0,
                              buttonCenter.x - popupCenter.x + 45.0, buttonCenter.y - popupCenter.y + 12.0);
    
    CAKeyframeAnimation *pathAnim = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    pathAnim.path = path;
    pathAnim.beginTime = 1.4;
    pathAnim.duration = 0.2;
    
    CAKeyframeAnimation *scaleAnim = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    scaleAnim.beginTime = 1.4;
    scaleAnim.duration = 0.2;
    scaleAnim.keyTimes = @[@(0.0), @(1.0)];
    scaleAnim.values = @[
                         [NSValue valueWithCATransform3D:CATransform3DIdentity],
                         [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.25, 0.25, 1.0)]];
    
    CAKeyframeAnimation *alphaAnim = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
    alphaAnim.duration = 1.6;
    alphaAnim.values = @[@(0.0), @(1.0), @(1.0), @(0.0)];
    alphaAnim.keyTimes = @[@(0.0), @(0.2 / 1.6), @(1.4 / 1.6), @(1.0)];
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.animations = @[pathAnim, scaleAnim, alphaAnim];
    group.beginTime = CACurrentMediaTime();
    group.duration = 1.6;
    
    [self.popupView.layer addAnimation:group forKey:@"popup"];
}

#pragma mark - Event Handling

- (void)didBecomeActive:(NSNotification *)notification
{
    [self reloadEventDataIfNeeded];
}

- (void)onRefreshTimerFired:(NSTimer *)timer
{
    if (![self reloadEventDataIfNeeded])
        [self updateHeadUpDisplay];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"segue_detailedEvent"]) {
        Event *ev;
        if (_todayTableShown) {
            NSIndexPath *indexPath = [self.todayTableView indexPathForCell:sender];
            ev = _todayEvents[indexPath.row];
        } else {
            NSIndexPath *indexPath = [self.tomorrowTableView indexPathForCell:sender];
            ev = _tomorrowEvents[indexPath.row];
        }
        RBZEventViewController *dest = [segue destinationViewController];
        dest.delegate = self;
        dest.event = ev;
    } else if ([segue.identifier isEqualToString:@"segue_addEvent"]) {
        RBZEventViewController *dest = [segue destinationViewController];
        dest.delegate = self;
    }
}

- (IBAction)todayButtonTapped:(id)sender
{
    [GoogleAnalyticsHelper trackEventWithCategory:GA_CATEGORY_UI
                                           action:GA_ACTION_OPEN_TODAY_PAGE
                                            label:nil
                                            value:nil];
    if (_tableAnimating)
        return;
    _todayTableShown = YES;
    _tomorrowTableShown = NO;
    [self animateFlipTransition:self.tomorrowContainerView toView:self.todayContainerView reverse:YES];
}

- (IBAction)tomorrowButtonTapped:(id)sender
{
    [GoogleAnalyticsHelper trackEventWithCategory:GA_CATEGORY_UI
                                           action:GA_ACTION_OPEN_TOMORROW_PAGE
                                            label:nil
                                            value:nil];
    if (_tableAnimating)
        return;
    _todayTableShown = NO;
    _tomorrowTableShown = YES;
    [self animateFlipTransition:self.todayContainerView toView:self.tomorrowContainerView reverse:NO];
}

- (IBAction)onHudTapped:(id)sender
{
    [GoogleAnalyticsHelper trackEventWithCategory:GA_CATEGORY_UI
                                           action:GA_ACTION_CLICK_HUD
                                            label:nil
                                            value:nil];
    RBZEventViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"vc_eventView"];
    vc.delegate = self;
    vc.event = _upcomingEvent;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)onSettingsButtonTapped:(id)sender
{
    [GoogleAnalyticsHelper trackEventWithCategory:GA_CATEGORY_UI
                                           action:GA_ACTION_OPEN_SETTINGS
                                            label:nil
                                            value:nil];
    [self.mm_drawerController openDrawerSide:MMDrawerSideRight animated:YES completion:nil];
}

- (IBAction)unwindFromArchive:(UIStoryboardSegue *)segue
{
    RBZArchiveViewController *vc = [segue sourceViewController];
    if (vc.hasDataChange) {
        [GoogleAnalyticsHelper trackEventWithCategory:GA_CATEGORY_UI
                                               action:GA_ACTION_CHANGE_FROM_ARCHIVE
                                                label:nil
                                                value:nil];
        [self reloadEventData];
    }
}

#pragma mark - Event View Delegate

- (void)eventDeleted:(Event *)ev
{
    [_pendingRemoveEvents addObject:ev];
}

- (void)eventCreated:(Event *)ev
{
    [_pendingAddEvents addObject:ev];
}

- (void)eventUpdated:(Event *)ev
{
    [_pendingUpdateEvents addObject:ev];
}

- (void)handlePendingRemoveEvents
{
    for (Event *ev in _pendingRemoveEvents) {
        [self removeEventRow:ev];
    }
    [_pendingRemoveEvents removeAllObjects];
}

- (void)handlePendingAddEvents
{
    for (Event *ev in _pendingAddEvents) {
        [self insertEventRow:ev isNewEvent:YES];
    }
    [_pendingAddEvents removeAllObjects];
}

- (void)handlePendingUpdateEvents
{
    for (Event *ev in _pendingUpdateEvents) {
        [self removeEventRow:ev];
        [self insertEventRow:ev isNewEvent:NO];
    }
    [_pendingUpdateEvents removeAllObjects];
}

- (void)removeEventRow:(Event *)event
{
    [self.todayTableView beginUpdates];
    [self removeEventFromTodayTable:event];
    [self.todayTableView endUpdates];
    
    [self.tomorrowTableView beginUpdates];
    [self removeEventFromTomorrowTable:event];
    [self.tomorrowTableView endUpdates];
}

- (void)removeEventFromTodayTable:(Event *)event
{
    NSInteger index = [_todayEvents indexOfObject:event];
    if (index != NSNotFound) {
        [_todayEvents removeObject:event];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        [self.todayTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void)removeEventFromTomorrowTable:(Event *)event
{
    NSInteger index = [_tomorrowEvents indexOfObject:event];
    if (index != NSNotFound) {
        [_tomorrowEvents removeObject:event];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        [self.tomorrowTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void)insertEventRow:(Event *)event isNewEvent:(BOOL)isNewEvent
{
    NSTimeInterval secondsPerDay = 86400;
    NSDate *today = _displayDate;
    NSDate *tomorrow = [NSDate dateWithTimeInterval:secondsPerDay sinceDate:today];
    
    BOOL inserted = NO;
    if ([event isOnDate:today]) {
        inserted = YES;
        [self.todayTableView beginUpdates];
        [self insertEventToTodayTable:event];
        [self.todayTableView endUpdates];
    }
    if ([event isOnDate:tomorrow]) {
        inserted = YES;
        [self.tomorrowTableView beginUpdates];
        [self insertEventToTomorrowTable:event];
        [self.tomorrowTableView endUpdates];
    }
    
    if (!inserted && isNewEvent)
        [self showEventSavedPopup];
}

- (void)insertEventToTodayTable:(Event *)event
{
    int index = 0;
    for (; index < [_todayEvents count]; index++) {
        Event *curr = _todayEvents[index];
        if ([curr.time.hour integerValue] > [event.time.hour integerValue])
            break;
        else if ([curr.time.hour integerValue] == [event.time.hour integerValue])
            if ([curr.time.minute integerValue] > [event.time.minute integerValue])
                break;
    }
    [_todayEvents insertObject:event atIndex:index];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    [self.todayTableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)insertEventToTomorrowTable:(Event *)event
{
    int index = 0;
    for (; index < [_tomorrowEvents count]; index++) {
        Event *curr = _tomorrowEvents[index];
        if ([curr.time.hour integerValue] > [event.time.hour integerValue])
            break;
        else if ([curr.time.hour integerValue] == [event.time.hour integerValue])
            if ([curr.time.minute integerValue] > [event.time.minute integerValue])
                break;
    }
    [_tomorrowEvents insertObject:event atIndex:index];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    [self.tomorrowTableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
}

#pragma mark - TableView DataSource & Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.todayTableView) {
        NSInteger count = [_todayEvents count];
        return count;
    } else if (tableView == self.tomorrowTableView) {
        NSInteger count = [_tomorrowEvents count];
        return count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL isUpcoming = NO;
    Event *ev;
    if (tableView == self.todayTableView) {
        ev = _todayEvents[indexPath.row];
        if (ev == _upcomingEvent && !_upcomingEventFromTomorrow)
            isUpcoming = YES;
    } else if (tableView == self.tomorrowTableView) {
        ev = _tomorrowEvents[indexPath.row];
        if (ev == _upcomingEvent && _upcomingEventFromTomorrow)
            isUpcoming = YES;
    }
    RBZEventListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.titleLabel.text = ev.title;
    cell.timeLabel.text = [ev.time getTimeString];
    if (isUpcoming) {
        cell.leftIndicator.hidden = NO;
        cell.rightIndicator.hidden = NO;
    } else {
        cell.leftIndicator.hidden = YES;
        cell.rightIndicator.hidden = YES;
    }
    if (indexPath.row % 2 == 1)
        cell.contentView.backgroundColor = _oddCellColor;
    else
        cell.contentView.backgroundColor = _evenCellColor;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

# pragma mark - Flip Animation

- (void)animateFlipTransition:(UIView *)fromView toView:(UIView *)toView reverse:(BOOL)reverse
{
    _tableAnimating = YES;
    [self.tableView bringSubviewToFront:fromView];
    
    CATransform3D transform = CATransform3DIdentity;
    transform.m34 = -0.002;
    [self.tableView.layer setSublayerTransform:transform];
    
    NSArray *toViewSnapshots = [self createSnapshots:toView afterScreenUpdates:YES];
    UIView *flippedSectionOfToView = toViewSnapshots[reverse ? 1 : 0];
    UIView *stillSectionOfToView = toViewSnapshots[reverse ? 0 : 1];
    
    NSArray *fromViewSnapshots = [self createSnapshots:fromView afterScreenUpdates:NO];
    UIView *flippedSectionOfFromView = fromViewSnapshots[reverse ? 0 : 1];
    UIView *stillSectionOfFromView = fromViewSnapshots[reverse ? 1 : 0];
    
    UIView *fromViewShadow = [self createShadowView:flippedSectionOfFromView reverse:!reverse];
    fromViewShadow.alpha = 0.0;
    [flippedSectionOfFromView addSubview:fromViewShadow];
    
    UIView *toViewShadow = [self createShadowView:flippedSectionOfToView reverse:reverse];
    toViewShadow.alpha = 1.0;
    [flippedSectionOfToView addSubview:toViewShadow];
    
    [self updateAnchorPointAndOffset:CGPointMake(reverse ? 1.0 : 0.0, 0.5) view:flippedSectionOfFromView];
    [self updateAnchorPointAndOffset:CGPointMake(reverse ? 0.0 : 1.0, 0.5) view:flippedSectionOfToView];
    
    flippedSectionOfToView.layer.transform = [self rotate:reverse ? -M_PI_2 : M_PI_2];
    
    [self.tableView addSubview:stillSectionOfFromView];
    [self.tableView addSubview:stillSectionOfToView];
    [self.tableView addSubview:flippedSectionOfFromView];
    [self.tableView addSubview:flippedSectionOfToView];
    [self.tableView sendSubviewToBack:fromView];
    
    // animate
    NSTimeInterval duration = 0.4;
    
    [UIView animateKeyframesWithDuration:duration
                                   delay:0.0
                                 options:0
                              animations:^{
                                  [UIView addKeyframeWithRelativeStartTime:0.0
                                                          relativeDuration:0.5
                                                                animations:^{
                                                                    // rotate the from- view to 90 degrees
                                                                    flippedSectionOfFromView.layer.transform = [self rotate:reverse ? M_PI_2 : -M_PI_2];
                                                                    fromViewShadow.alpha = 1.0;
                                                                }];
                                  [UIView addKeyframeWithRelativeStartTime:0.5
                                                          relativeDuration:0.5
                                                                animations:^{
                                                                    // rotate the to- view to 0 degrees
                                                                    flippedSectionOfToView.layer.transform = [self rotate:reverse ? -0.0 : 0.0];
                                                                    toViewShadow.alpha = 0.0;
                                                                }];
                              }
                              completion:^(BOOL finished) {
                                  [self.tableView bringSubviewToFront:toView];
                                  for (UIView *view in self.tableView.subviews) {
                                      if (view != self.todayContainerView && view != self.tomorrowContainerView) {
                                          [view removeFromSuperview];
                                      }
                                  }
                                  _tableAnimating = NO;
                              }];
}

- (NSArray *)createSnapshots:(UIView* )view afterScreenUpdates:(BOOL)afterUpdates
{
    CGRect snapshotRegion = CGRectMake(0, 0, view.frame.size.width / 2, view.frame.size.height);
    UIView *leftHandView = [view resizableSnapshotViewFromRect:snapshotRegion  afterScreenUpdates:afterUpdates withCapInsets:UIEdgeInsetsZero];
    leftHandView.frame = CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width / 2, view.frame.size.height);
    
    snapshotRegion = CGRectMake(view.frame.size.width / 2, 0, view.frame.size.width / 2, view.frame.size.height);
    UIView *rightHandView = [view resizableSnapshotViewFromRect:snapshotRegion  afterScreenUpdates:afterUpdates withCapInsets:UIEdgeInsetsZero];
    rightHandView.frame = CGRectMake(view.frame.origin.x + view.frame.size.width / 2, view.frame.origin.y, view.frame.size.width / 2, view.frame.size.height);
    
    return @[leftHandView, rightHandView];
}

- (UIView *)createShadowView:(UIView *)view reverse:(BOOL)reverse
{
    UIView *shadowView = [[UIView alloc] initWithFrame:view.bounds];
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = shadowView.bounds;
    gradient.colors = @[(id)[UIColor colorWithWhite:0.0 alpha:0.0].CGColor,
                        (id)[UIColor colorWithWhite:0.0 alpha:0.5].CGColor];
    gradient.startPoint = CGPointMake(reverse ? 1.0 : 0.0, 0.0);
    gradient.endPoint = CGPointMake(reverse ? 0.0 : 1.0, 0.0);
    [shadowView.layer addSublayer:gradient];
    
    return shadowView;
}

- (void)updateAnchorPointAndOffset:(CGPoint)anchorPoint view:(UIView*)view {
    view.layer.anchorPoint = anchorPoint;
    float xOffset =  anchorPoint.x - 0.5;
    view.frame = CGRectOffset(view.frame, xOffset * view.frame.size.width, 0);
}

- (CATransform3D)rotate:(CGFloat)angle {
    return CATransform3DMakeRotation(angle, 0.0, 1.0, 0.0);
}

@end
