//
//  RBZSettingsViewController.m
//  Date Reminder
//
//  Created by robin on 14-1-4.
//  Copyright (c) 2014年 Robin Zhang. All rights reserved.
//

#import <StoreKit/StoreKit.h>
#import "UIViewController+MMDrawerController.h"
#import "RBZSettingsViewController.h"
#import "RBZEventListViewController.h"
#import "RBZSettingsTableViewController.h"
#import "RBZAllEventViewController.h"
#import "RBZDateReminder.h"
#import "RBZIAPHelper.h"

@interface RBZSettingsViewController ()

@property RBZSettingsTableViewController *tableController;

@end

@implementation RBZSettingsViewController

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
    
    self.tableController = (RBZSettingsTableViewController *)[self.childViewControllers objectAtIndex:0];
    self.tableController.delegate = self;
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

- (void)updateAllEventsLabel
{
    [self.tableController updateAllEventsLabel];
}

- (void)onListAllTapped
{
    UINavigationController *nav = (UINavigationController *)self.mm_drawerController.centerViewController;
    UIViewController *vc = nav.childViewControllers[0];
    if ([vc isKindOfClass:[RBZEventListViewController class]]) {
        nav = [self.storyboard instantiateViewControllerWithIdentifier:@"nav_allEvent"];
    } else {
        nav = [self.storyboard instantiateViewControllerWithIdentifier:@"nav_today"];
    }
    [self.mm_drawerController setCenterViewController:nav withFullCloseAnimation:YES completion:nil];
}

@end
