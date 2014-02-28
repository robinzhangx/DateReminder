//
//  RBZEventViewController.h
//  DateReminder
//
//  Created by robin on 2/14/14.
//  Copyright (c) 2014 Robin Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RBZDateReminder.h"
#import "RBZQuickCalendarPickerView.h"
#import "RBZQuickReminderPickerView.h"
#import "RBZArrowView.h"

@protocol RBZEventViewDelegate <NSObject>
- (void)eventDeleted:(Event *)ev;
- (void)eventCreated:(Event *)ev;
- (void)eventUpdated:(Event *)ev;
@end

@interface RBZEventViewController : UIViewController
<UIAlertViewDelegate, UITextViewDelegate, UIGestureRecognizerDelegate,
UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout,
RBZQuickCalendarPickerViewDelegate, RBZQuickReminderPickerViewDelegate>

@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (weak, nonatomic) IBOutlet UIButton *discardButton;
@property (weak, nonatomic) IBOutlet UIButton *createButton;

@property (weak, nonatomic) IBOutlet UIView *eventContainerView;
@property (weak, nonatomic) IBOutlet UIView *textViewContainer;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIView *controlContainer;
@property (weak, nonatomic) IBOutlet UIView *quickControlView;
@property (weak, nonatomic) IBOutlet UICollectionView *badgeCollectionView;
@property (weak, nonatomic) IBOutlet UIView *loadingView;
@property (weak, nonatomic) IBOutlet UILabel *countdownLabel;
@property (weak, nonatomic) IBOutlet UIImageView *repeatImageView;

@property (weak, nonatomic) IBOutlet UIView *controlsView;
@property (weak, nonatomic) IBOutlet UIButton *timeButton;
@property (weak, nonatomic) IBOutlet UIButton *dateButton;
@property (weak, nonatomic) IBOutlet UIButton *reminderButton;
@property (weak, nonatomic) IBOutlet UIButton *infoButton;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *eventContainerTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *quickControlViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *controlViewBottonSpace;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *countdownLabelTrailingSpace;

@property Event *event;
@property (nonatomic, assign) id<RBZEventViewDelegate> delegate;
- (IBAction)onTimePicked:(UIStoryboardSegue *)segue;
- (IBAction)onDatePicked:(UIStoryboardSegue *)segue;

@end
