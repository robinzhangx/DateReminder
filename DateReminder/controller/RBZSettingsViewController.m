//
//  RBZSettingsViewController.m
//  DateReminder
//
//  Created by robin on 2/24/14.
//  Copyright (c) 2014 Robin Zhang. All rights reserved.
//

#import "RBZSettingsViewController.h"
#import "RBZIAPHelper.h"
#import "RZSquaresLoading.h"
#import "GoogleAnalyticsHelper.h"
#import "iRate.h"

@interface RBZSettingsViewController ()

@end

@implementation RBZSettingsViewController {
    NSArray *_iapProducts;
}

static NSString *_buyAuthorCoffee = @"Buy author a coffee";
static NSString *_buyCoffeeDone = @";)";
static NSString *_buyCoffeeFail = @"Can't finish purchase";
static NSString *_coffeeNotAvailable = @"(Store not available)";

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
    
    [self.rateButton addTarget:self action:@selector(onRateAppTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.mailButton addTarget:self action:@selector(onContactAuthorTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.coffeeButton addTarget:self action:@selector(onBuyCoffeeTapped:) forControlEvents:UIControlEventTouchUpInside];

    RZSquaresLoading *sl = [[RZSquaresLoading alloc] initWithFrame:CGRectMake(0, 0, 12, 12)];
    sl.color = [UIColor whiteColor];
    [self.loadingView addSubview:sl];
    self.coffeeLabel.hidden = YES;
    self.coffeePriceLabel.hidden = YES;
    self.coffeeButton.enabled = NO;
    [self requestProduct];
}

- (void)viewWillAppear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(transactionPurchased:)
                                                 name:IAPHelperTransactionPurchasedNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(transactionFailed:)
                                                 name:IAPHelperTransactionFailedNotification
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Buy me a coffee

- (void)requestProduct
{
    [[RBZIAPHelper sharedInstance] requestProductsWithCompletionHandler:^(BOOL success, NSArray *products) {
        if (success) {
            [GoogleAnalyticsHelper trackEventWithCategory:GA_CATEGORY_PURCHASE
                                                   action:GA_ACTION_READY_FOR_PURCHASE
                                                    label:nil
                                                    value:nil];
            _iapProducts = products;
            [self updateCoffeePrice];
        } else {
            [GoogleAnalyticsHelper trackEventWithCategory:GA_CATEGORY_PURCHASE
                                                   action:GA_ACTION_STORE_NOT_AVAILABLE
                                                    label:nil
                                                    value:nil];
            self.loadingView.hidden = YES;
            self.coffeeLabel.text = _coffeeNotAvailable;
            self.coffeeLabel.hidden = NO;
        }
    }];
}

- (void)updateCoffeePrice
{
    if (_iapProducts && [_iapProducts count] > 0) {
        SKProduct *baac = _iapProducts[0];
        if (baac) {
            self.loadingView.hidden = YES;
            self.coffeeLabel.hidden = NO;
            self.coffeePriceLabel.hidden = NO;
            self.coffeeButton.enabled = YES;
            
            NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
            [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
            [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
            [numberFormatter setLocale:baac.priceLocale];
            NSString *priceStr = [numberFormatter stringFromNumber:baac.price];
            self.coffeePriceLabel.text = [NSString stringWithFormat:@"%@", priceStr];
            [self.coffeePriceLabel sizeToFit];
        } else {
            self.loadingView.hidden = YES;
            self.coffeeLabel.text = _coffeeNotAvailable;
            self.coffeeLabel.hidden = NO;
        }
    }
}

- (void)transactionPurchased:(NSNotification *)notification {
    
    NSString * productIdentifier = notification.object;
    if ([productIdentifier isEqualToString:RBZIAP_buyCoffee]) {
        [GoogleAnalyticsHelper trackEventWithCategory:GA_CATEGORY_PURCHASE
                                               action:GA_ACTION_ITEM_PURCHASED
                                                label:nil
                                                value:nil];
        self.coffeePriceLabel.hidden = YES;
        self.coffeeLabel.text = _buyCoffeeDone;
    }
}

- (void)transactionFailed:(NSNotification *)notification {
    
    NSString * productIdentifier = notification.object;
    if ([productIdentifier isEqualToString:RBZIAP_buyCoffee]) {
        [GoogleAnalyticsHelper trackEventWithCategory:GA_CATEGORY_PURCHASE
                                               action:GA_ACTION_PURCHASE_FAILED
                                                label:nil
                                                value:nil];
        self.coffeeLabel.text = _buyCoffeeFail;
        self.coffeeButton.enabled = YES;
    }
}

#pragma mark - Button Events

- (IBAction)onRateAppTapped:(id)sender
{
    [GoogleAnalyticsHelper trackEventWithCategory:GA_CATEGORY_UI
                                           action:GA_ACTION_RATE_APP
                                            label:nil
                                            value:nil];
    [[iRate sharedInstance] openRatingsPageInAppStore];
}

- (IBAction)onBuyCoffeeTapped:(id)sender
{
    [GoogleAnalyticsHelper trackEventWithCategory:GA_CATEGORY_UI
                                           action:GA_ACTION_BUY_COFFEE
                                            label:nil
                                            value:nil];
    SKProduct *product = _iapProducts[0];
    if (product) {
        self.coffeeButton.enabled = NO;
        self.coffeeLabel.text = @"Connecting app store...";
        [[RBZIAPHelper sharedInstance] buyProduct:product];
    } else {
        
    }
}

- (IBAction)onContactAuthorTapped:(id)sender
{
    [GoogleAnalyticsHelper trackEventWithCategory:GA_CATEGORY_UI
                                           action:GA_ACTION_CONTACT_AUTHOR
                                            label:nil
                                            value:nil];
    NSString *subject = [NSString stringWithFormat:@"[Date Reminder]"];
    NSString *mail = [NSString stringWithFormat:@"robin.zhangx@gmail.com"];
    NSURL *url = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"mailto:?to=%@&subject=%@",
                                                [mail stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding],
                                                [subject stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]]];
    [[UIApplication sharedApplication] openURL:url];
}

@end
