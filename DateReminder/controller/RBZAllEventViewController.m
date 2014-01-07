//
//  RBZAllEventViewController.m
//  Date Reminder
//
//  Created by robin on 13-12-24.
//  Copyright (c) 2013年 Robin Zhang. All rights reserved.
//

#import "UIViewController+MMDrawerController.h"
#import "RBZAllEventViewController.h"
#import "RBZEventViewController.h"
#import "RBZSettingsViewController.h"
#import "RBZAllEventListCell.h"
#import "RBZDateReminder.h"
#import "Flurry.h"

@interface RBZAllEventViewController ()

@property NSMutableArray *data;
@property NSMutableArray *onceEvents;
@property NSMutableArray *dailyEvent;
@property NSMutableArray *weeklyEvents;
@property NSMutableArray *monthlyEvents;
@property NSMutableArray *yearlyEvents;
@property NSMutableArray *expiredEvents;

@property UIColor *highlightColor;

@end

static NSString *const FLURRY_VC_ALL_EVENT = @"vc_all_event";

@implementation RBZAllEventViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.highlightColor = [UIColor colorWithRed:1.0 green:153.0/255.0 blue:0.0 alpha:0.2];
    self.tableView.tableFooterView = [[UIView alloc] init];
    
    UIBarButtonItem *todayBtn = [[UIBarButtonItem alloc] initWithTitle:@"Today/Tomorrow"
                                                                 style:UIBarButtonItemStyleBordered
                                                                target:self
                                                                action:@selector(onTodayButtonTapped:)];
    self.navigationItem.leftBarButtonItem = todayBtn;
    
    [self loadData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [Flurry logEvent:FLURRY_VC_ALL_EVENT timed:YES];
    if (self.mm_drawerController) {
        [self.mm_drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeNone];
        [self.mm_drawerController setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeNone];
    }
    [super viewWillAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [Flurry endTimedEvent:FLURRY_VC_ALL_EVENT withParameters:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)eventDeleted:(Event *)ev
{
    [self loadData];
    self.changed = YES;
    RBZSettingsViewController *settingsVc = (RBZSettingsViewController *)self.mm_drawerController.leftDrawerViewController;
    [settingsVc updateAllEventsLabel];
}

- (void)eventCreated:(Event *)ev
{
    [self loadData];
    self.changed = YES;
    RBZSettingsViewController *settingsVc = (RBZSettingsViewController *)self.mm_drawerController.leftDrawerViewController;
    [settingsVc updateAllEventsLabel];
}

- (void)eventUpdated:(Event *)ev
{
    [self loadData];
    self.changed = YES;
}

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

- (IBAction)onTodayButtonTapped:(id)sender
{
    UINavigationController *nav = [self.storyboard instantiateViewControllerWithIdentifier:@"nav_today"];
    [Flurry logAllPageViews:nav];
    [self.mm_drawerController setCenterViewController:nav
                                   withCloseAnimation:YES
                                           completion:nil];
}

#pragma mark - Table view data source

- (void)loadData
{
    self.onceEvents = [[NSMutableArray alloc] init];
    self.dailyEvent = [[NSMutableArray alloc] init];
    self.weeklyEvents = [[NSMutableArray alloc] init];
    self.monthlyEvents = [[NSMutableArray alloc] init];
    self.yearlyEvents = [[NSMutableArray alloc] init];
    self.expiredEvents = [[RBZDateReminder instance] getExpiredEvents];
    for (Event *ev in [[RBZDateReminder instance] getActiveEvents]) {
        switch ([ev.date.type integerValue]) {
            case RBZEventOnce:
                [self.onceEvents addObject:ev];
                break;
            case RBZEventDaily:
                [self.dailyEvent addObject:ev];
                break;
            case RBZEventWeekly:
                [self.weeklyEvents addObject:ev];
                break;
            case RBZEventMonthly:
                [self.monthlyEvents addObject:ev];
                break;
            case RBZEventYearly:
                [self.yearlyEvents addObject:ev];
                break;
        }
    }
    self.data = [[NSMutableArray alloc] init];
    if ([self.onceEvents count] > 0)
        [self.data addObject:@[@"Specific Date", self.onceEvents]];
    if ([self.dailyEvent count] > 0)
        [self.data addObject:@[@"Daily", self.dailyEvent]];
    if ([self.weeklyEvents count] > 0)
        [self.data addObject:@[@"Weekly", self.weeklyEvents]];
    if ([self.monthlyEvents count] > 0)
        [self.data addObject:@[@"Monthly", self.monthlyEvents]];
    if ([self.yearlyEvents count] > 0)
        [self.data addObject:@[@"Yearly", self.yearlyEvents]];
    if ([self.expiredEvents count] > 0)
        [self.data addObject:@[@"Expired", self.expiredEvents]];
    
    [self.tableView reloadData];
}

- (Event *)getEventAtIndexPath:(NSIndexPath *)indexPath
{
    Event *ev = self.data[indexPath.section][1][indexPath.row];
    return ev;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.data count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return self.data[section][0];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.data[section][1] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"event_cell";
    RBZAllEventListCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    Event *ev = [self getEventAtIndexPath:indexPath];
    cell.titleLabel.text = ev.title;
    cell.typeLabel.text = [ev.date getTypeString];
    
    UIView *selectionView = [[UIView alloc] init];
    selectionView.backgroundColor = self.highlightColor;
    cell.selectedBackgroundView = selectionView;
    return cell;
}

/*
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIView *selectionView = [[UIView alloc] init];
    selectionView.backgroundColor = self.highlightColor;
    cell.selectedBackgroundView = selectionView;
}
*/

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    header.textLabel.font = [UIFont fontWithName:@"AvenirNextCondensed-Regular" size:12.0];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Event *ev = self.data[indexPath.section][1][indexPath.row];
        NSManagedObjectContext *localContext = [NSManagedObjectContext MR_defaultContext];
        [ev MR_deleteInContext:localContext];
        [localContext MR_saveToPersistentStoreAndWait];
        [[RBZDateReminder instance] removeEvent:ev];
        [self.data[indexPath.section][1] removeObjectAtIndex:indexPath.row];
        if ([self.data[indexPath.section][1] count] == 0) {
            [self.data removeObjectAtIndex:indexPath.section];
            NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:indexPath.section];
            [self.tableView deleteSections:indexSet withRowAnimation:YES];
        } else {
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:YES];
        }
        self.changed = YES;
        RBZSettingsViewController *settingsVc = (RBZSettingsViewController *)self.mm_drawerController.leftDrawerViewController;
        [settingsVc updateAllEventsLabel];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
