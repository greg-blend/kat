//
//  Created by Lolay, Inc.
//  Copyright 2011 Lolay, Inc. All rights reserved.
//

#import "LolayDateField.h"
#import "LolayDateFieldDelegate.h"

@implementation LolayDateField

@synthesize button = button_;
@synthesize picker = picker_;
@synthesize toolbar = toolbar_;
@synthesize sheet = sheet_;
@synthesize delegate = delegate_;
@synthesize dateFormatter = dateFormatter_;
@dynamic date;

#pragma mark - Lifecycle

- (void) setup {
	NSDateFormatter* formatter = [[[NSDateFormatter alloc] init] autorelease];
	formatter.dateStyle = NSDateFormatterShortStyle;
	self.dateFormatter = formatter;
}

- (id) init {
	self = [super init];
	
	if (self) {
		[self setup];
	}
	
	return self;
}

- (id) initWithCoder:(NSCoder*) decoder {
	self = [super initWithCoder:decoder];
	
	if (self) {
		[self setup];
	}
	
	return self;
}

- (id) initWithFrame:(CGRect) frame {
	self = [super initWithFrame:frame];
	
	if (self) {
		[self setup];
	}
	
	return self;
}

+ (LolayDateField*) dateField {
	NSArray* items = [[NSBundle mainBundle] loadNibNamed:@"LolayDateField" owner:self options:nil];
	for (NSObject* item in items) {
		if ([item isKindOfClass:[LolayDateField class]]) {
			return (LolayDateField*) item;
		}
	}
	return nil;
}

- (void) dealloc {
	self.button = nil;
	self.picker = nil;
	self.toolbar = nil;
	self.sheet = nil;
	self.delegate = nil;
	self.dateFormatter = nil;
	
	[super dealloc];
}

#pragma mark - LolayDateFieldDelegate

- (UIView*) superviewForSheet {
	UIView* view = nil;
	if (self.delegate && [self.delegate respondsToSelector:@selector(dateFieldSuperviewForSheet:)]) {
		view = [self.delegate dateFieldSuperviewForSheet:self];
	}
	return view;
}

- (void) valueChanged {
	DLog(@"enter");
	if (self.delegate && [self.delegate respondsToSelector:@selector(dateFieldValueChanged:)]) {
		[self.delegate dateFieldValueChanged:self];
	}
}

- (void) sheetWillShow {
	DLog(@"enter");
	if (self.delegate && [self.delegate respondsToSelector:@selector(dateFieldSheetWillShow:)]) {
		[self.delegate dateFieldSheetWillShow:self];
	}
}

- (void) sheetDidShow {
	DLog(@"enter");
	if (self.delegate && [self.delegate respondsToSelector:@selector(dateFieldSheetDidShow:)]) {
		[self.delegate dateFieldSheetDidShow:self];
	}
}

- (void) sheetWillHide {
	DLog(@"enter");
	if (self.delegate && [self.delegate respondsToSelector:@selector(dateFieldSheetWillHide:)]) {
		[self.delegate dateFieldSheetWillHide:self];
	}
}

- (void) sheetDidHide {
	DLog(@"enter");
	if (self.delegate && [self.delegate respondsToSelector:@selector(dateFieldSheetDidHide:)]) {
		[self.delegate dateFieldSheetDidHide:self];
	}
}

#pragma mark - Actions

- (void) showSheet {
	DLog(@"enter");
	UIView* view = [self superviewForSheet];
	if (view == nil) {
		DLog(@"No superview for sheet, so getting window");
		view = [UIApplication sharedApplication].keyWindow;
	}
	
	if (view) {
		if (self.sheet.superview == nil) {
			self.button.highlighted = YES;
			[self sheetWillShow];
			
			CGRect startFrame = self.sheet.frame;
			startFrame.size.width = view.bounds.size.width;
			startFrame.origin.y = view.bounds.size.height;
			self.sheet.frame = startFrame;
			
			[view addSubview:self.sheet];
			
			CGRect endFrame = startFrame;
			endFrame.origin.y -= self.sheet.frame.size.height;
			
			[UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseIn animations:^{
				self.sheet.frame = endFrame;
			} completion:^(BOOL finished) {
				if (finished) {
					[self sheetDidShow];
				}
			}];
		}
	}
}

- (void) handleTitle {
	NSString* text = nil;
	if (self.dateFormatter && self.date) {
		text = [self.dateFormatter stringFromDate:self.date];
	}
	
	[self.button setTitle:text forState:UIControlStateNormal];
}

- (NSDate*) date {
	return self.picker.date;
}

- (void) setDate:(NSDate*) date {
	self.picker.date = date;
	[self handleTitle];
}

- (IBAction) buttonPressed:(id) sender {
	DLog(@"enter");
	[self showSheet];
}

- (void) hideSheet {
	DLog(@"enter");
	if (self.sheet.superview) {
		self.button.highlighted = NO;
		[self sheetWillHide];
		
		CGRect endFrame = self.sheet.frame;
		endFrame.origin.y += self.sheet.frame.size.height;
		
		[UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseIn animations:^{
			self.sheet.frame = endFrame;
		} completion:^(BOOL finished) {
			if (finished) {
				[self sheetDidHide];
			}
			[self.sheet removeFromSuperview];
		}];
	} else {
		DLog(@"Sheet has no superview, so nothing to hide");
	}
}

- (IBAction) dateChanged:(id) sender {
	DLog(@"enter");
	[self handleTitle];
	[self valueChanged];
}

- (IBAction) donePressed:(id) sender {
	DLog(@"enter");
	[self hideSheet];
}

@end