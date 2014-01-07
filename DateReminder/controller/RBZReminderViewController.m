//
//  RBZReminderViewController.m
//  Date Reminder
//
//  Created by robin on 13-12-23.
//  Copyright (c) 2013年 Robin Zhang. All rights reserved.
//

#import "RBZReminderViewController.h"

@interface RBZReminderViewController ()

@property UIColor *highlightColor;
@property NSInteger selectedRow;

@end

static NSString *const FLURRY_VC_REMINDER_VIEW = @"vc_reminder_view";

@implementation RBZReminderViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [Flurry logEvent:FLURRY_VC_REMINDER_VIEW timed:YES];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [Flurry endTimedEvent:FLURRY_VC_REMINDER_VIEW withParameters:nil];
    [super viewWillDisappear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    self.highlightColor = [UIColor colorWithRed:1.0 green:153.0/255.0 blue:0.0 alpha:0.2];
    
    if (self.hasReminder) {
        if (![self.hasReminder boolValue]) {
            self.selectedRow = 0;
        } else {
            NSInteger m = [self.minutesBefore integerValue];
            if (m == 1) {
                self.selectedRow = 1;
            } else if (m == 5) {
                self.selectedRow = 2;
            } else if (m == 10) {
                self.selectedRow = 3;
            } else if (m == 15) {
                self.selectedRow = 4;
            } else if (m == 30) {
                self.selectedRow = 5;
            } else if (m == 60) {
                self.selectedRow = 6;
            } else {
                self.selectedRow = -1;
            }
        }
    } else {
        self.selectedRow = -1;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if (sender == self.noCell) {
        self.hasReminder = [NSNumber numberWithBool:NO];
    } else if (sender == self.m1Cell) {
        self.hasReminder = [NSNumber numberWithBool:YES];
        self.minutesBefore = [NSNumber numberWithInt:1];
    } else if (sender == self.m5Cell) {
        self.hasReminder = [NSNumber numberWithBool:YES];
        self.minutesBefore = [NSNumber numberWithInt:5];
    } else if (sender == self.m10Cell) {
        self.hasReminder = [NSNumber numberWithBool:YES];
        self.minutesBefore = [NSNumber numberWithInt:10];
    } else if (sender == self.m15Cell) {
        self.hasReminder = [NSNumber numberWithBool:YES];
        self.minutesBefore = [NSNumber numberWithInt:15];
    } else if (sender == self.m30Cell) {
        self.hasReminder = [NSNumber numberWithBool:YES];
        self.minutesBefore = [NSNumber numberWithInt:30];
    } else if (sender == self.h1Cell) {
        self.hasReminder = [NSNumber numberWithBool:YES];
        self.minutesBefore = [NSNumber numberWithInt:60];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIView *selectionView = [[UIView alloc] init];
    selectionView.backgroundColor = self.highlightColor;
    cell.selectedBackgroundView = selectionView;
    if (indexPath.row == self.selectedRow) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedRow = indexPath.row;
    [self.tableView reloadData];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
