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
    
    [self setupThemeColorButtons];
    [self.rateButton addTarget:self action:@selector(onRateAppTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.mailButton addTarget:self action:@selector(onContactAuthorTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.coffeeButton addTarget:self action:@selector(onBuyCoffeeTapped:) forControlEvents:UIControlEventTouchUpInside];

    self.coffeeLabel.hidden = YES;
    self.coffeePriceLabel.hidden = YES;
    self.coffeeButton.enabled = NO;
    [self requestProduct];
}

- (void)viewDidLayoutSubviews
{
    [self updateThemeColorHighlight];
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
    [self updateThemeColorHighlight];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupThemeColorButtons
{
    self.color0Image.layer.cornerRadius = 12.0;
    self.color1Image.layer.cornerRadius = 12.0;
    self.color2Image.layer.cornerRadius = 12.0;
    self.color3Image.layer.cornerRadius = 12.0;
    
    self.color0Button.tag = kThemeColorDefault;
    [self.color0Button addTarget:self action:@selector(onThemeColorButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    self.color1Button.tag = kThemeColorGreen;
    [self.color1Button addTarget:self action:@selector(onThemeColorButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
     self.color2Button.tag = kThemeColorBlue;
    [self.color2Button addTarget:self action:@selector(onThemeColorButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    self.color3Button.tag = kThemeColorPurple;
    [self.color3Button addTarget:self action:@selector(onThemeColorButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)updateThemeColorHighlight
{
    int index = [[RBZDateReminder instance] getThemeColor];
    switch (index) {
        case kThemeColorGreen: self.colorCheckmark.frame = self.color1Button.frame; break;
        case kThemeColorBlue: self.colorCheckmark.frame = self.color2Button.frame; break;
        case kThemeColorPurple: self.colorCheckmark.frame = self.color3Button.frame; break;
        case kThemeColorDefault:
        default: self.colorCheckmark.frame = self.color0Button.frame; break;
    }
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

- (IBAction)onThemeColorButtonTapped:(UIControl *)sender
{
    [GoogleAnalyticsHelper trackEventWithCategory:GA_CATEGORY_UI
                                           action:GA_ACTION_CHANGE_THEME_COLOR
                                            label:[RBZDateReminder getThemeColorName:sender.tag]
                                            value:nil];
    [[RBZDateReminder instance] setThemeColor:sender.tag];
    [self updateThemeColorHighlight];
    UIView *view;
    switch (sender.tag) {
        case kThemeColorGreen: view = self.color1Image; break;
        case kThemeColorBlue: view = self.color2Image; break;
        case kThemeColorPurple: view = self.color3Image; break;
        case kThemeColorDefault:
        default: view = self.color0Image; break;
    }
    CAKeyframeAnimation *scaleAnim = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    scaleAnim.duration = 0.2;
    scaleAnim.keyTimes = @[@(0.0), @(0.5), @(1.0)];
    scaleAnim.values = @[
                         [NSValue valueWithCATransform3D:CATransform3DIdentity],
                         [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.2, 1.2, 1.0)],
                         [NSValue valueWithCATransform3D:CATransform3DIdentity]];
    [view.layer addAnimation:scaleAnim forKey:@"tap"];
}

@end
