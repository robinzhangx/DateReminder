//
//  RBZSettingsTableViewController.m
//  Date Reminder
//
//  Created by robin on 14-1-4.
//  Copyright (c) 2014年 Robin Zhang. All rights reserved.
//

#import <StoreKit/StoreKit.h>
#import "RBZSettingsTableViewController.h"
#import "RBZEventListViewController.h"
#import "RBZDateReminder.h"
#import "RBZIAPHelper.h"

@interface RBZSettingsTableViewController ()

@property NSArray *iapProducts;

@end

@implementation RBZSettingsTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productPurchased:) name:IAPHelperProductPurchasedNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self updateAllEventsLabel];
    [[RBZIAPHelper sharedInstance] requestProductsWithCompletionHandler:^(BOOL success, NSArray *products) {
        if (success) {
            self.iapProducts = products;
            [self updateBuyAuthorCoffeeLabel];
        }
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)productPurchased:(NSNotification *)notification {
    
    NSString * productIdentifier = notification.object;
    if ([productIdentifier isEqualToString:RBZIAP_buyCoffee]) {
        self.buyCoffeeLabel.text = @"Thanks for using Date Reminder";
        self.buyCoffeePriceLabel.text = @"";
    }
}

- (void)updateAllEventsLabel
{
    self.listAllLabel.text = [NSString stringWithFormat:@"List all %d events", [Event MR_countOfEntities]];
}

- (void)updateBuyAuthorCoffeeLabel
{
    SKProduct *baac = self.iapProducts[0];
    if (baac) {
        self.buyCoffeeLabel.text = baac.localizedTitle;
        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
        [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
        [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
        [numberFormatter setLocale:baac.priceLocale];
        NSString *priceStr = [numberFormatter stringFromNumber:baac.price];
        self.buyCoffeePriceLabel.text = [NSString stringWithFormat:@"%@", priceStr];
    }
}

- (void)onListAllTapped
{
    [self.delegate onListAllTapped];
}

- (void)onContactAuthorTapped
{
    [Flurry logEvent:FLURRY_CONTACT_AUTHOR];
    NSString *subject = [NSString stringWithFormat:@"[Date Reminder]"];
    NSString *mail = [NSString stringWithFormat:@"robin.zhangx@gmail.com"];
    NSURL *url = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"mailto:?to=%@&subject=%@",
                                                [mail stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding],
                                                [subject stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]]];
    [[UIApplication sharedApplication] openURL:url];
}

- (void)onBuyCoffeeTapped
{
    [Flurry logEvent:FLURRY_BUY_COFFEE];
    SKProduct *product = self.iapProducts[0];
    NSLog(@"Buying %@...", product.productIdentifier);
    if (product)
        [[RBZIAPHelper sharedInstance] buyProduct:product];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.section) {
        case 0: {
            switch (indexPath.row) {
                case 0: [self onListAllTapped]; break;
            }
            break;
        }
        case 1: {
            switch (indexPath.row) {
                case 0: [self onContactAuthorTapped]; break;
                case 1: [self onBuyCoffeeTapped]; break;
            }
            break;
        }
    }
}

@end
