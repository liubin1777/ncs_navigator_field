//
//  DatePickerButton.m
//  NCSMobile
//
//  Created by John Dzak on 12/2/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "DatePickerButton.h"
#import "NUPickerVC.h"

@interface DatePickerButton ()
- (NSString*) formatTitleUsingDate:(NSDate*)date;
@end

@implementation DatePickerButton

@synthesize date = _date;
@synthesize button = _button;
@synthesize picker = _picker;
@synthesize popover = _popover;
@synthesize dateFormatter = _dateFormatter;

- (id)initWithFrame:(CGRect)frame value:(NSDate*)value onChange:(ChangeHandler*)changeHandler {
    self = [super initWithFrame:frame];
    if (self) {
        // Create button
        self.button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        self.button.frame = CGRectMake(0, 0, 200, 30);
        [self.button setTitle:[self formatTitleUsingDate:value] forState:UIControlStateNormal];
        
        // Setup button target
        [self.button addTarget:self action:@selector(showPicker) forControlEvents:UIControlEventTouchUpInside];
        
        self.date = value;

        [self addSubview:self.button];
    }
    return self;
}

- (NSString*) formatTitleUsingDate:(NSDate*)date {
    return date ? [self.dateFormatter stringFromDate:date] : @"Pick One";
}

- (NSDateFormatter*) getDateFormatter {
    NSDateFormatter* dateFormatter = [[NSDateFormatter new] autorelease];
    [dateFormatter setDateFormat:@"MMM dd 'at' HH:mm"];
    return dateFormatter;
}

- (NUPickerVC*) initPickerVC {
    NUPickerVC* pickerVC = [[[NUPickerVC alloc] initWithNibName:@"NUPickerVC" bundle:nil] autorelease];
    pickerVC.contentSizeForViewInPopover = CGSizeMake(384.0, 260.0);
    [pickerVC loadView];
    [pickerVC setupDelegate:self withTitle:@"Pick One" date:YES];
    pickerVC.datePicker.datePickerMode = UIDatePickerModeDateAndTime;
    pickerVC.datePicker.date = self.date;
    return pickerVC;
}

- (UIPopoverController*)initPopoverVCWithPicker:(NUPickerVC*)picker {
    UIPopoverController* popoverVC = [[UIPopoverController alloc] initWithContentViewController: picker];
    popoverVC.delegate = self;
    return popoverVC;
}

- (void)showPicker {
    self.picker = [self initPickerVC];
    self.popover = [self initPopoverVCWithPicker:self.picker];
    [self.popover presentPopoverFromRect:self.frame inView:self.superview permittedArrowDirections:UIPopoverArrowDirectionLeft animated:YES];
}

- (void) pickerDone{
    [self.popover dismissPopoverAnimated:NO];
    NSUInteger selectedRow = [self.picker.picker selectedRowInComponent:0]; 
    if (selectedRow != -1) {
//        handler
        
//        [delegate deleteResponseForIndexPath:[self myIndexPathWithRow:selectedRow]];
//        [delegate newResponseForIndexPath:[self myIndexPathWithRow:selectedRow]];
//        [delegate showAndHideDependenciesTriggeredBy:[self myIndexPathWithRow:selectedRow]];
//        self.textLabel.text = [(NSDictionary *)[answers objectAtIndex:selectedRow] objectForKey:@"text"];
//        self.textLabel.textColor = RGB(1, 113, 233);
    }
}
- (void) pickerCancel{
    [self.popover dismissPopoverAnimated:NO];
}

@end
