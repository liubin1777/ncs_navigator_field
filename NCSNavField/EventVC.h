//
//  EventVC.h
//  NCSNavField
//
//  Created by John Dzak on 6/29/12.
//  Copyright (c) 2012 Northwestern University. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Event;
@class NUScrollView;

@interface EventVC : UIViewController {
    Event* _event;
    UIScrollView* _scrollView;
}

@property(nonatomic,retain) Event* event;
@property(nonatomic,retain) UIScrollView* scrollView;

- (id)initWithEvent:event;

- (UIView*) toolbarWithFrame:(CGRect)frame;

- (void) setDefaults:(Event*)event;

- (UIView*) leftEventContentWithFrame:(CGRect)frame event:(Event*)e;
- (UIView*) rightEventContentWithFrame:(CGRect)frame event:(Event*)e;

- (void) cancel;
- (void) done;

- (void) startTransaction;
- (void) endTransction;
- (void) commitTransaction;
- (void) rollbackTransaction;

- (void)registerForKeyboardNotifications;

@end
