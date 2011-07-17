//
//  --------------------------------------------
//  Copyright (C) 2011 by Simon Blommegård
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//  --------------------------------------------
//
//  SBTableAlert.m
//  SBTableAlert
//
//  Created by Simon Blommegård on 2011-04-08.
//  Copyright 2011 Simon Blommegård. All rights reserved.
//

#import "SBTableAlert.h"
#import <QuartzCore/QuartzCore.h>

@interface SBTableViewTopShadowView : UIView {}
@end

@implementation SBTableViewTopShadowView

- (void)drawRect:(CGRect)rect {
	[super drawRect:rect];
	
	CGContextRef context = UIGraphicsGetCurrentContext();

	// Draw top shadow
	CGFloat colors [] = { 
		0, 0, 0, 0.4,
		0, 0, 0, 0,
	};
	
	CGColorSpaceRef baseSpace = CGColorSpaceCreateDeviceRGB();
	CGGradientRef gradient = CGGradientCreateWithColorComponents(baseSpace, colors, NULL, 2);
	CGColorSpaceRelease(baseSpace), baseSpace = NULL;
	
	CGPoint startPoint = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMinY(self.bounds));
	CGPoint endPoint = CGPointMake(CGRectGetMidX(self.bounds), 8);
	
	CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
	CGGradientRelease(gradient), gradient = NULL;
}

@end

@interface SBTableView : UITableView {
	SBTableAlertStyle _alertStyle;
}
@property (nonatomic) SBTableAlertStyle alertStyle;
@end

@implementation SBTableView

@synthesize alertStyle=_alertStyle;

- (void)drawRect:(CGRect)rect {
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	if (_alertStyle == SBTableAlertStyleApple) {
		// Draw background gradient
		CGFloat colors [] = { 
			0.922, 0.925, 0.933, 1,
			0.749, 0.753, 0.761, 1,
		};
		
		CGColorSpaceRef baseSpace = CGColorSpaceCreateDeviceRGB();
		CGGradientRef gradient = CGGradientCreateWithColorComponents(baseSpace, colors, NULL, 2);
		CGColorSpaceRelease(baseSpace), baseSpace = NULL;
		
		CGPoint startPoint = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMinY(self.bounds));
		CGPoint endPoint = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMaxY(self.bounds));
		
		CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
		CGGradientRelease(gradient), gradient = NULL;
	}
	
	[super drawRect:rect];
}

@end

@interface SBTableAlertCellContentView : UIView
@end

@implementation SBTableAlertCellContentView

- (void)drawRect:(CGRect)r {
	[(SBTableAlertCell *)[[self superview] superview] drawCellContentView:r];
}

@end

@implementation SBTableViewSectionHeaderView
@synthesize title=_title;

- (id)initWithTitle:(NSString *)title {
	if ((self == [super initWithFrame:CGRectZero])) {
		[self setTitle:title];
		[self setBackgroundColor:[UIColor colorWithRed:0.165 green:0.224 blue:0.376 alpha:0.85]];
	}
	
	return self;
}

- (void)dealloc {
	[self setTitle:nil];
	[super dealloc];
}

- (void)drawRect:(CGRect)rect {
	[super drawRect:rect];
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	[[UIColor whiteColor] set];
	[_title drawAtPoint:CGPointMake(5, 5) withFont:[UIFont boldSystemFontOfSize:12]];
	
	CGContextSetLineWidth(context, 1.5);
	
	[[UIColor colorWithWhite:1 alpha:0.35] set];
	CGContextMoveToPoint(context, 0, 0);
	CGContextAddLineToPoint(context, self.bounds.size.width, 0);
	CGContextStrokePath(context);
	
	[[UIColor colorWithWhite:0 alpha:0.35] set];
	CGContextMoveToPoint(context, 0, self.bounds.size.height);
	CGContextAddLineToPoint(context, self.bounds.size.width, self.bounds.size.height);
	CGContextStrokePath(context);
}

@end

@implementation SBTableAlertCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	if((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
		CGRect frame = CGRectMake(0.0, 0.0, self.contentView.bounds.size.width, self.contentView.bounds.size.height);
		
		_cellContentView = [[SBTableAlertCellContentView alloc] initWithFrame:frame];
		[_cellContentView setBackgroundColor:[UIColor clearColor]];
		[_cellContentView setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];
		[self.contentView addSubview:_cellContentView];
		[self.contentView bringSubviewToFront:_cellContentView];
		[_cellContentView release];
		
		[[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidChangeStatusBarOrientationNotification object:nil queue:nil usingBlock:^(NSNotification *not) {
			[self setNeedsDisplay];
		}];
	}
	return self;
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[super dealloc];
}

- (void)layoutSubviews {
	[super layoutSubviews];
	
	float editingOffset = 0.;
	if (self.editing)
		editingOffset = -self.contentView.frame.origin.x;
	
	_cellContentView.frame = CGRectMake(editingOffset,
																			_cellContentView.frame.origin.y,
																			self.frame.size.width - editingOffset,
																			_cellContentView.frame.size.height);
	
	[self.textLabel setBackgroundColor:[UIColor clearColor]];
	[self.detailTextLabel setBackgroundColor:[UIColor clearColor]];
	[self setBackgroundColor:[UIColor clearColor]];
	
	[self setNeedsDisplay];
}

- (void)setNeedsDisplay {
	[super setNeedsDisplay];
	[_cellContentView setNeedsDisplay];
}

- (void)drawCellContentView:(CGRect)r {
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSetLineWidth(context, 1.5);
		
	[[UIColor colorWithWhite:1 alpha:0.8] set];
	CGContextMoveToPoint(context, 0, 0);
	CGContextAddLineToPoint(context, self.bounds.size.width, 0);
	CGContextStrokePath(context);
		
	[[UIColor colorWithWhite:0 alpha:0.35] set];
	CGContextMoveToPoint(context, 0, self.bounds.size.height);
	CGContextAddLineToPoint(context, self.bounds.size.width, self.bounds.size.height);
	CGContextStrokePath(context);
}

@end

@interface SBTableAlert ()

- (id)initWithTitle:(NSString *)title cancelButtonTitle:(NSString *)cancelTitle messageFormat:(NSString *)format args:(va_list)args;
- (void)increaseHeightBy:(CGFloat)delta;
- (void)layout;

@end

@implementation SBTableAlert

@synthesize view=_alertView;
@synthesize tableView=_tableView;
@synthesize type=_type;
@synthesize style=_style;
@synthesize maximumVisibleRows=_maximumVisibleRows;
@synthesize rowHeight=_rowHeigh;

@synthesize delegate=_delegate;
@synthesize dataSource=_dataSource;

@synthesize tableViewDelegate=_tableViewDelegate;
@synthesize tableViewDataSource=_tableViewDataSource;
@synthesize alertViewDelegate=_alertViewDelegate;


- (id)initWithTitle:(NSString *)title cancelButtonTitle:(NSString *)cancelTitle messageFormat:(NSString *)format args:(va_list)args {
	if ((self = [super init])) {
		NSString *message = format ? [[[NSString alloc] initWithFormat:format arguments:args] autorelease] : nil;
		
		_alertViewDelegate = self;
		_alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:_alertViewDelegate cancelButtonTitle:cancelTitle otherButtonTitles:nil];
		
		_maximumVisibleRows = 4;
		_rowHeigh = 40.;
		_tableViewDelegate = self;
		_tableViewDataSource = self;
		_tableView = [[SBTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
		
		[_tableView setDelegate:_tableViewDelegate];
		[_tableView setDataSource:_tableViewDataSource];
		[_tableView setBackgroundColor:[UIColor whiteColor]];
		[_tableView setRowHeight:_rowHeigh];
		[_tableView setSeparatorColor:[UIColor lightGrayColor]];
		[_tableView.layer setCornerRadius:kTableCornerRadius];
		
		[_alertView addSubview:_tableView];
		
		_shadow = [[SBTableViewTopShadowView alloc] initWithFrame:CGRectZero];
		[_shadow setBackgroundColor:[UIColor clearColor]];
		[_shadow setHidden:YES];
		[_shadow.layer setCornerRadius:kTableCornerRadius];
		[_shadow.layer setMasksToBounds:YES];
		
		[_alertView addSubview:_shadow];
		[_alertView bringSubviewToFront:_shadow];
		
		[[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidChangeStatusBarOrientationNotification object:nil queue:nil usingBlock:^(NSNotification *n) {
			dispatch_after(DISPATCH_TIME_NOW, dispatch_get_main_queue(), ^{[self layout];});
		}];
	}
	
	return self;
}

- (id)initWithTitle:(NSString *)title cancelButtonTitle:(NSString *)cancelTitle messageFormat:(NSString *)message, ... {
	va_list list;
	va_start(list, message);
	self = [self initWithTitle:title cancelButtonTitle:cancelTitle messageFormat:message args:list];
	va_end(list);
	return self;
}

+ (id)alertWithTitle:(NSString *)title cancelButtonTitle:(NSString *)cancelTitle messageFormat:(NSString *)message, ... {
	return [[[SBTableAlert alloc] initWithTitle:title cancelButtonTitle:cancelTitle messageFormat:message] autorelease];
}

- (void)dealloc {
	[self setTableView:nil];
	[self setView:nil];
	
	[_shadow release], _shadow = nil;
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[super dealloc];
}

#pragma mark -

- (void)show {
	[_tableView reloadData];
	[_alertView show];
}

#pragma mark - Properties

- (void)setStyle:(SBTableAlertStyle)style {
	if (style == SBTableAlertStyleApple) {
		[_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
		[_tableView setAlertStyle:SBTableAlertStyleApple];
		[_shadow setHidden:NO];
	} else if (style == SBTableAlertStylePlain) {
		[_tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
		[_tableView setAlertStyle:SBTableAlertStylePlain];
		[_shadow setHidden:YES];
	}
	_style = style;
}

#pragma mark - Private

- (void)increaseHeightBy:(CGFloat)delta {
	CGPoint c = _alertView.center;
	CGRect r = _alertView.frame;
	r.size.height += delta;
	_alertView.frame = r;
	_alertView.center = c;
	_alertView.frame = CGRectIntegral(_alertView.frame);
	
	for(UIView *subview in [_alertView subviews]) {
		if([subview isKindOfClass:[UIControl class]]) {
			CGRect frame = subview.frame;
			frame.origin.y += delta;
			subview.frame = frame;
		}
	}
}


- (void)layout {
	// todo: fix height calulations according to cell height + header height
	NSInteger visibleRows = 0;
	for (NSInteger section = 0; section < [_tableView numberOfSections]; section++)
		visibleRows += [_tableView numberOfRowsInSection:section];
	
	if (visibleRows > _maximumVisibleRows)
		visibleRows = _maximumVisibleRows;
	
	[self increaseHeightBy:(_tableView.rowHeight * visibleRows)];
	
	[_tableView setFrame:CGRectMake(12,
																	_alertView.frame.size.height-(_tableView.rowHeight * visibleRows)-65,
																	_alertView.frame.size.width - 24,
																	(_tableView.rowHeight * visibleRows))];
	
	[_shadow setFrame:CGRectMake(_tableView.frame.origin.x,
															 _tableView.frame.origin.y,
															 _tableView.frame.size.width,
															 8)];
}

#pragma mark -
#pragma mark UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([_delegate respondsToSelector:@selector(tableAlert:heightForRowAtIndexPath:)])
        return [_delegate tableAlert:self heightForRowAtIndexPath:indexPath];

    return _tableView.rowHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (_type == SBTableAlertTypeSingleSelect)
		[_alertView dismissWithClickedButtonIndex:-1 animated:YES];
	
	if ([_delegate respondsToSelector:@selector(tableAlert:didSelectRowAtIndexPath:)])
		[_delegate tableAlert:self didSelectRowAtIndexPath:indexPath];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	if ([_dataSource respondsToSelector:@selector(tableAlert:titleForHeaderInSection:)]) {
		NSString *title = [_dataSource tableAlert:self titleForHeaderInSection:section];
		if (!title)
			return nil;
		
		return [[[SBTableViewSectionHeaderView alloc] initWithTitle:title] autorelease];
	}

	return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return 25;
}

#pragma mark -
#pragma mark UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {	
	return [_dataSource tableAlert:self	cellForRowAtIndexPath:indexPath];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [_dataSource tableAlert:self numberOfRowsInSection:section];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	if ([_dataSource respondsToSelector:@selector(numberOfSectionsInTableAlert:)])
		return [_dataSource numberOfSectionsInTableAlert:self];

	return 1;
}

#pragma mark -
#pragma mark UIAlertViewDelegate

- (void)alertViewCancel:(UIAlertView *)alertView {
	if ([_delegate respondsToSelector:@selector(tableAlertCancel:)])
		[_delegate tableAlertCancel:self];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if ([_delegate respondsToSelector:@selector(tableAlert:clickedButtonAtIndex:)])
		[_delegate tableAlert:self clickedButtonAtIndex:buttonIndex];
}

- (void)willPresentAlertView:(UIAlertView *)alertView {
	if (!_presented)
		[self layout];
	_presented = YES;
	if ([_delegate respondsToSelector:@selector(willPresentTableAlert:)])
		[_delegate willPresentTableAlert:self];
}
- (void)didPresentAlertView:(UIAlertView *)alertView {
	if ([_delegate respondsToSelector:@selector(didPresentTableAlert:)])
		[_delegate didPresentTableAlert:self];
}

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex {
	if ([_delegate respondsToSelector:@selector(tableAlert:willDismissWithButtonIndex:)])
		[_delegate tableAlert:self willDismissWithButtonIndex:buttonIndex];
}
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
	_presented = NO;
	if ([_delegate respondsToSelector:@selector(tableAlert:didDismissWithButtonIndex:)])
		[_delegate tableAlert:self didDismissWithButtonIndex:buttonIndex];
}

@end
