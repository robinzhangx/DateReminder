//
//  RBZAddEventViewController.h
//  Date Reminder
//
//  Created by robin on 13-12-9.
//  Copyright (c) 2013年 Robin Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Event.h"
#import "RBZEventDateValueDelegate.h"

@protocol RBZEventViewDelegate <NSObject>

- (void)eventDeleted:(Event *)ev;
- (void)eventCreated:(Event *)ev;
- (void)eventUpdated:(Event *)ev;

@end

@interface RBZEventViewController
    : UIViewController <UIAlertViewDelegate, UITextViewDelegate, RBZEventDateValueDelegate>

@property Event *event;
@property (nonatomic, assign) id<RBZEventViewDelegate> delegate;

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITextView *eventText;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
@property (weak, nonatomic) IBOutlet UILabel *reminderLabel;
@property (weak, nonatomic) IBOutlet UIButton *timeCell;
@property (weak, nonatomic) IBOutlet UIButton *typeCell;
@property (weak, nonatomic) IBOutlet UIButton *reminderCell;
@property (weak, nonatomic) IBOutlet UIView *nextCell;
@property (weak, nonatomic) IBOutlet UILabel *nextLabel;
@property (weak, nonatomic) IBOutlet UIButton *createButton;

@end
