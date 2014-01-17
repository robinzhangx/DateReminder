//
//  RBZTypeViewController.m
//  Date Reminder
//
//  Created by robin on 13-12-22.
//  Copyright (c) 2013年 Robin Zhang. All rights reserved.
//

#import "RBZTypeViewController.h"
#import "RBZDateViewController.h"
#import "RBZDateValueViewController.h"
#import "RBZDateTypeCell.h"

@interface RBZTypeViewController ()

@property UIColor *highlightColor;

@property NSArray *typeSections;
@property NSArray *notRepeatType;
@property NSArray *repeatType;

@property NSCalendar *calendar;
@property NSDate *today;
@property NSDateComponents *todayComps;
@property NSDate *tomorrow;
@property NSDateComponents *tomorrowComps;

@property NSString *todayStr;
@property NSString *tomorrowStr;
@end

static NSString *const FLURRY_VC_TYPE_VIEW = @"vc_type_view";

@implementation RBZTypeViewController

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
    self.highlightColor = [UIColor colorWithRed:1.0 green:153.0/255.0 blue:0.0 alpha:0.2];
    [self loadData];
    [self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [Flurry logEvent:FLURRY_VC_TYPE_VIEW timed:YES];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [Flurry endTimedEvent:FLURRY_VC_TYPE_VIEW withParameters:nil];
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadData
{
    self.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSTimeInterval secondsPerDay = 24 * 60 * 60;
    self.today = [[NSDate alloc] init];
    self.todayComps = [self.calendar components:NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit fromDate:self.today];
    self.tomorrow = [[NSDate alloc] initWithTimeIntervalSinceNow:secondsPerDay];
    self.tomorrowComps = [self.calendar components:NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit fromDate:self.tomorrow];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setCalendar:self.calendar];
    [formatter setDateFormat:@"MMMM dd"];
    self.todayStr = [formatter stringFromDate:self.today];
    self.tomorrowStr = [formatter stringFromDate:self.tomorrow];
    [formatter setDateFormat:@"EE"];
    self.todayStr = [NSString stringWithFormat:@"%@, %@", [formatter stringFromDate:self.today], self.todayStr];
    self.tomorrowStr = [NSString stringWithFormat:@"%@, %@", [formatter stringFromDate:self.tomorrow], self.tomorrowStr];

    self.typeSections = @[@"", @"Repeat"];
    self.notRepeatType = @[@"Today", @"Tomorrow", @"Pick a day"];
    self.repeatType = @[@"Every Day", @"Every Week", @"Every Month", @"Every Year"];
}

- (BOOL)isPickedToday
{
    if (self.type && [self.type integerValue] == RBZEventOnce) {
        if ([self.day integerValue] == self.todayComps.day
            && [self.month integerValue] == self.todayComps.month
            && [self.year integerValue] == self.todayComps.year)
            return YES;
    }
    return NO;
}

- (BOOL)isPickedTomorrow
{
    if (self.type && [self.type integerValue] == RBZEventOnce) {
        if ([self.day integerValue] == self.tomorrowComps.day
            && [self.month integerValue] == self.tomorrowComps.month
            && [self.year integerValue] == self.tomorrowComps.year)
            return YES;
    }
    return NO;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.typeSections count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return self.typeSections[section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0: return [self.notRepeatType count];
        case 1: return [self.repeatType count];
    }
    return 0;
}

static NSString *cellIdentifier = @"cell_dateType";
static NSString *vcDateView = @"vc_dateView";
static NSString *vcDateValueView = @"vc_dateValueView";

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RBZDateTypeCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    switch (indexPath.section) {
        case 0: {
            cell.typeLabel.text = self.notRepeatType[indexPath.row];
            switch (indexPath.row) {
                case 0: // today
                    cell.detailLabel.text = self.todayStr;
                    if ([self isPickedToday]) {
                        cell.accessoryType = UITableViewCellAccessoryCheckmark;
                    } else {
                        cell.accessoryType = UITableViewCellAccessoryNone;
                    }
                    break;
                case 1: // tomorrow
                    cell.detailLabel.text = self.tomorrowStr;
                    if ([self isPickedTomorrow]) {
                        cell.accessoryType = UITableViewCellAccessoryCheckmark;
                    } else {
                        cell.accessoryType = UITableViewCellAccessoryNone;
                    }
                    break;
                case 2: // pick a day
                    if ([self.type integerValue] == RBZEventOnce) {
                        if (![self isPickedToday] && ![self isPickedTomorrow]) {
                            cell.detailLabel.text = [EventDate getOnceValueString:self.day month:self.month year:self.year];
                            cell.accessoryType = UITableViewCellAccessoryCheckmark;
                        }
                    }
                    break;
            }
            break;
        }
        case 1: {
            cell.typeLabel.text = self.repeatType[indexPath.row];
            switch (indexPath.row) {
                case 0: // daily
                    if (self.type && [self.type integerValue] == RBZEventDaily) {
                        cell.accessoryType = UITableViewCellAccessoryCheckmark;
                    } else {
                        cell.accessoryType = UITableViewCellAccessoryNone;
                    }
                    break;
                case 1: // weekly
                    if (self.type && [self.type integerValue] == RBZEventWeekly) {
                        cell.detailLabel.text = [EventDate getWeeklyValueString:self.weekday];
                        cell.accessoryType = UITableViewCellAccessoryCheckmark;
                    }
                    break;
                case 2: // monthly
                    if (self.type && [self.type integerValue] == RBZEventMonthly) {
                        cell.detailLabel.text = [EventDate getMonthlyValueString:self.day];
                        cell.accessoryType = UITableViewCellAccessoryCheckmark;
                    }
                    break;
                case 3: //yearly
                    if (self.type && [self.type integerValue] == RBZEventYearly) {
                        cell.detailLabel.text = [EventDate getYearlyValueString:self.day month:self.month];
                        cell.accessoryType = UITableViewCellAccessoryCheckmark;
                    }
                    break;
            }
            break;
        }
    }
    UIView *selectionView = [[UIView alloc] init];
    selectionView.backgroundColor = self.highlightColor;
    cell.selectedBackgroundView = selectionView;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.section) {
        case 0: [self didSelectNotRepeatType:indexPath]; break;
        case 1: [self didSelectRepeatType:indexPath]; break;
    }
}

- (void)didSelectNotRepeatType:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0: { // today
            NSDateComponents *comps = [self.calendar components:NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit
                                                       fromDate:self.today];
            [self.delegate eventDateOncePicked:[NSNumber numberWithInteger:comps.day]
                                         month:[NSNumber numberWithInteger:comps.month]
                                          year:[NSNumber numberWithInteger:comps.year]];
            [self.navigationController popViewControllerAnimated:YES];
            break;
        }
        case 1: { // tomorrow
            NSDateComponents *comps = [self.calendar components:NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit
                                                       fromDate:self.tomorrow];
            [self.delegate eventDateOncePicked:[NSNumber numberWithInteger:comps.day]
                                         month:[NSNumber numberWithInteger:comps.month]
                                          year:[NSNumber numberWithInteger:comps.year]];
            [self.navigationController popViewControllerAnimated:YES];
            break;
        }
        case 2: { // pick a day
            RBZDateViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:vcDateView];
            if (self.type && [self.type integerValue] == RBZEventOnce) {
                vc.day = self.day;
                vc.month = self.month;
                vc.year = self.year;
            }
            [self.navigationController pushViewController:vc animated:YES];
            break;
        }
    }
}

- (void)didSelectRepeatType:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0: { // daily
            [self.delegate eventDateDailyPicked];
            [self.navigationController popViewControllerAnimated:YES];
            break;
        }
        case 1: { // weekly
            RBZDateValueViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:vcDateValueView];
            vc.type = [NSNumber numberWithInteger:RBZEventWeekly];
            if (self.type && [self.type integerValue] == RBZEventWeekly) {
                vc.weekday = self.weekday;
            }
            [self.navigationController pushViewController:vc animated:YES];
            break;
        }
        case 2: { // monthly
            RBZDateValueViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:vcDateValueView];
            vc.type = [NSNumber numberWithInteger:RBZEventMonthly];
            if (self.type && [self.type integerValue] == RBZEventMonthly) {
                vc.day = self.day;
            }
            [self.navigationController pushViewController:vc animated:YES];
            break;
        }
        case 3: { // yearly
            RBZDateValueViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:vcDateValueView];
            vc.type = [NSNumber numberWithInteger:RBZEventYearly];
            if (self.type && [self.type integerValue] == RBZEventYearly) {
                vc.day = self.day;
                vc.month = self.month;
            }
            [self.navigationController pushViewController:vc animated:YES];
            break;
        }
    }
}

@end
