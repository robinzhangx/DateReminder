//
//  RBZArchiveViewController.m
//  DateReminder
//
//  Created by robin on 2/24/14.
//  Copyright (c) 2014 Robin Zhang. All rights reserved.
//

#import "RBZArchiveViewController.h"
#import "RBZArchiveTableSectionHeaderView.h"
#import "RBZArchiveListCell.h"
#import "RBZDateReminder.h"
#import "RBZUtils.h"
#import "GoogleAnalyticsHelper.h"

@interface ListData : NSObject
@property NSString *title;
@property NSMutableArray *events;
@property BOOL show;
- (id)initWithTitle:(NSString *)title events:(NSMutableArray *)events show:(BOOL)show;
@end

@implementation ListData
- (id)initWithTitle:(NSString *)title events:(NSMutableArray *)events show:(BOOL)show
{
    self = [super init];
    if (self) {
        self.title = title;
        self.events = events;
        self.show = show;
    }
    return self;
}
@end

@interface RBZArchiveViewController ()

@end

@implementation RBZArchiveViewController {
    UIColor *_mainColor;
    UIColor *_highlightColor;
    UIColor *_oddCellColor;
    UIColor *_evenCellColor;
    
    NSMutableArray *_data;
    NSMutableArray *_onceEvents;
    NSMutableArray *_dailyEvents;
    NSMutableArray *_weeklyEvents;
    NSMutableArray *_monthlyEvents;
    NSMutableArray *_yearlyEvents;
    NSMutableArray *_expiredEvents;
    
    NSMutableSet *_pendingRemoveEvents;
    NSMutableSet *_pendingUpdateEvents;
}

static NSString *const GA_VC_ARCHIVE_VIEW = @"Archive View";
static NSString *const _headerIdentifier = @"header";

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
    
    [self.tableView registerNib:[UINib nibWithNibName:@"ArchiveTableSectionHeader" bundle:nil] forHeaderFooterViewReuseIdentifier:_headerIdentifier];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.tableFooterView = [[UIView alloc] init];
    
    [self reloadEventData];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [RBZUtils dropShadow:self.listContainerView];
    [RBZUtils roundedCornerMask:self.headerContainerView corners:UIRectCornerTopLeft|UIRectCornerTopRight radius:3.0];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [GoogleAnalyticsHelper trackScreen:GA_VC_ARCHIVE_VIEW];
    [self handlePendingUpdateEvents];
    [self handlePendingRemoveEvents];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.tableView setEditing:NO];
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
    _oddCellColor = [UIColor colorWithRed:249.0/255.0 green:249.0/255.0 blue:249.0/255.0 alpha:1.0];
    _evenCellColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
    
    float cornerRadius = 3.0;
    self.listContainerView.layer.cornerRadius = cornerRadius;
}

- (void)reloadEventData
{
    _pendingRemoveEvents = [[NSMutableSet alloc] init];
    _pendingUpdateEvents = [[NSMutableSet alloc] init];
    
    _onceEvents = [[NSMutableArray alloc] init];
    _dailyEvents = [[NSMutableArray alloc] init];
    _weeklyEvents = [[NSMutableArray alloc] init];
    _monthlyEvents = [[NSMutableArray alloc] init];
    _yearlyEvents = [[NSMutableArray alloc] init];
    _expiredEvents = [[RBZDateReminder instance] getExpiredEvents];
    for (Event *ev in [[RBZDateReminder instance] getActiveEvents]) {
        switch ([ev.date.type integerValue]) {
            case RBZEventOnce: [_onceEvents addObject:ev]; break;
            case RBZEventDaily: [_dailyEvents addObject:ev]; break;
            case RBZEventWeekly: [_weeklyEvents addObject:ev]; break;
            case RBZEventMonthly: [_monthlyEvents addObject:ev]; break;
            case RBZEventYearly: [_yearlyEvents addObject:ev]; break;
        }
    }
    
    _data = [[NSMutableArray alloc] init];
    ListData *data = [[ListData alloc] initWithTitle:@"One-time"
                                              events:_onceEvents
                                                show:NO];
    [_data addObject:data];
    
    data = [[ListData alloc] initWithTitle:@"Daily"
                                    events:_dailyEvents
                                      show:NO];
    [_data addObject:data];
    
    data = [[ListData alloc] initWithTitle:@"Weekly"
                                    events:_weeklyEvents
                                      show:NO];
    [_data addObject:data];
    
    data = [[ListData alloc] initWithTitle:@"Monthly"
                                    events:_monthlyEvents
                                      show:NO];
    [_data addObject:data];
    
    data = [[ListData alloc] initWithTitle:@"Yearly"
                                    events:_yearlyEvents
                                      show:NO];
    [_data addObject:data];
    
    data = [[ListData alloc] initWithTitle:@"Expired"
                                    events:_expiredEvents
                                      show:NO];
    [_data addObject:data];
    
    [self.tableView reloadData];
}

#pragma mark - Event Handling

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"segue_detailedEvent"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        Event *ev = [self getEventAtIndexPath:indexPath];
        RBZEventViewController *dest = [segue destinationViewController];
        dest.delegate = self;
        dest.event = ev;
    }
}

#pragma mark - Event View Delegates

- (void)eventDeleted:(Event *)ev
{
    self.hasDataChange = YES;
    [_pendingRemoveEvents addObject:ev];
}

- (void)eventCreated:(Event *)ev
{
    // shouldn't be called
}

- (void)eventUpdated:(Event *)ev
{
    self.hasDataChange = YES;
    [_pendingUpdateEvents addObject:ev];
}

- (void)handlePendingRemoveEvents
{
    for (Event *ev in _pendingRemoveEvents) {
        [self updateTableForEvent:ev deleted:YES];
    }
    [_pendingRemoveEvents removeAllObjects];
}

- (void)handlePendingUpdateEvents
{
    for (Event *ev in _pendingUpdateEvents) {
        [self updateTableForEvent:ev deleted:NO];
    }
    [_pendingUpdateEvents removeAllObjects];
}

#pragma mark - TableView DataSource & Delegate

- (void)updateTableForEvent:(Event *)event deleted:(BOOL)deleted
{
    [self.tableView beginUpdates];
    int prev = -1;
    for (int i = 0; i < [_data count]; i++) {
        ListData *d = _data[i];
        if ([d.events containsObject:event]) {
            prev = i;
            break;
        }
    }
    
    if (deleted) {
        if (prev >= 0) {
            ListData *d = _data[prev];
            [d.events removeObject:event];
            NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:prev];
            [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationFade];
        }
    } else {
        int curr = -1;
        if ([event isExpired:[NSDate date]]) {
            curr = 5;
        } else {
            switch ([event.date.type integerValue]) {
                case RBZEventOnce: curr = 0; break;
                case RBZEventDaily: curr = 1; break;
                case RBZEventWeekly: curr = 2; break;
                case RBZEventMonthly: curr = 3; break;
                case RBZEventYearly: curr = 4; break;
            }
        }
        if (curr != prev) {
            if (prev >= 0) {
                ListData *d = _data[prev];
                [d.events removeObject:event];
                NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:prev];
                [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationFade];
            }
            if (curr >= 0) {
                ListData *d = _data[curr];
                [d.events addObject:event];
                NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:curr];
                [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationFade];
            }
        } else {
            if (curr >= 0) {
                NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:curr];
                [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationFade];
            }
        }
    }
    [self.tableView endUpdates];
}

- (Event *)getEventAtIndexPath:(NSIndexPath *)indexPath
{
    ListData *data = _data[indexPath.section];
    Event *ev = data.events[indexPath.row];
    return ev;
}

- (IBAction)onSectionHeaderTapped:(UIView *)sender
{
    NSInteger section = sender.tag;
    ListData *data = _data[section];
    data.show = !data.show;
    NSIndexSet *index = [NSIndexSet indexSetWithIndex:section];
    [self.tableView reloadSections:index withRowAnimation:UITableViewRowAnimationFade];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [_data count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 44.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    RBZArchiveTableSectionHeaderView *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:_headerIdentifier];
    header.contentControlView.tag = section;
    [header.contentControlView addTarget:self action:@selector(onSectionHeaderTapped:) forControlEvents:UIControlEventTouchUpInside];
    ListData *data = _data[section];
    header.titleLabel.text = data.title;
    header.countLabel.text = [NSString stringWithFormat:@"%d", [data.events count]];
    return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    ListData *data = _data[section];
    if (data.show)
        return [data.events count];
    else
        return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Event *ev = [self getEventAtIndexPath:indexPath];
    RBZArchiveListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.titleLabel.text = ev.title;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [GoogleAnalyticsHelper trackEventWithCategory:GA_CATEGORY_UI
                                               action:GA_ACTION_DELETE_FROM_ARCHIVE
                                                label:nil
                                                value:nil];
        Event *ev = [self getEventAtIndexPath:indexPath];
        [GoogleAnalyticsHelper trackDeleteEvent:ev];
        NSManagedObjectContext *localContext = [NSManagedObjectContext MR_defaultContext];
        [ev MR_deleteInContext:localContext];
        [localContext MR_saveToPersistentStoreAndWait];
        [[RBZDateReminder instance] removeEvent:ev];
        
        self.hasDataChange = YES;
        [self updateTableForEvent:ev deleted:YES];
    }
}

@end
