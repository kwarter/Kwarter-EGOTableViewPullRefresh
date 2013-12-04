//
//  EGORefreshTableHeaderView.m
//  Demo
//
//  Created by Devin Doty on 10/14/09October14.
//  Copyright 2009 enormego. All rights reserved.
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
//

#import "EGORefreshTableHeaderView.h"
#import <UILabel+NUI.h>

#define ARROW_IMAGE_NAME            @"blueArrow.png"
#define TEXT_COLOR                  [UIColor colorWithRed:87.0/255.0 green:108.0/255.0 blue:137.0/255.0 alpha:1.0]
#define SHADOW_OFFSET               CGSizeMake(0.0f, 1.0f)
#define SHADOW_COLOR                [UIColor colorWithWhite:0.9f alpha:1.0f]
#define BACKGROUND_COLOR            [UIColor colorWithRed:226.0/255.0 green:231.0/255.0 blue:237.0/255.0 alpha:1.0]
#define ACTIVITY_INDICATOR_STYLE    UIActivityIndicatorViewStyleGray
#define FLIP_ANIMATION_DURATION     0.18f

@interface EGORefreshTableHeaderView (Private)
- (void)setState:(EGOPullRefreshState)aState;
@end

@implementation EGORefreshTableHeaderView

@synthesize delegate=_delegate;

- (id)initWithFrame:(CGRect)frame arrowImageName:(NSString *)arrow
          textColor:(UIColor *)textColor shadowOffset:(CGSize)shadowOffset shadowColor:(UIColor *)shadowColor
    backgroundColor:(UIColor *)backgroundColor activityIndicatorStyle:(UIActivityIndicatorViewStyle)activityIndicatorStyle
scrollViewContentInset:(UIEdgeInsets)contentInset {
    
    if((self = [super initWithFrame:frame])) {
		
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		self.backgroundColor = backgroundColor;
        _contentInset = contentInset;
        
		UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, frame.size.height - 30.0f - _contentInset.top, self.frame.size.width, 20.0f)];
		label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		label.font = [UIFont systemFontOfSize:12.0f];
		label.textColor = textColor;
		label.shadowColor = shadowColor;
		label.shadowOffset = shadowOffset;
		label.backgroundColor = [UIColor clearColor];
		label.textAlignment = UITextAlignmentCenter;
		[self addSubview:label];
		_lastUpdatedLabel = label;
		[label release];
		
		label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, frame.size.height - 48.0f- _contentInset.top, self.frame.size.width, 20.0f)];
		label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		label.font = [UIFont boldSystemFontOfSize:13.0f];
		label.textColor = textColor;
		label.shadowColor = shadowColor;
		label.shadowOffset = shadowOffset;
		label.backgroundColor = [UIColor clearColor];
		label.textAlignment = UITextAlignmentCenter;
		[self addSubview:label];
		_statusLabel = label;
		[label release];
		
		_statusLabel.nuiClass = @"pullToRefreshLabel";
		_lastUpdatedLabel.nuiClass = @"pullToRefreshLabel";
		
		CALayer *layer = [CALayer layer];
        layer.frame = CGRectMake(20.0f, frame.size.height - 60.0f - _contentInset.top, 50.0f, 60.0f);
		layer.contentsGravity = kCAGravityResizeAspect;
		layer.contents = (id)[UIImage imageNamed:arrow].CGImage;
		
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 40000
		if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
			layer.contentsScale = [[UIScreen mainScreen] scale];
		}
#endif
		
		[[self layer] addSublayer:layer];
		_arrowImage = layer;
		
		UIActivityIndicatorView *view = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:ACTIVITY_INDICATOR_STYLE];
		view.frame = CGRectMake(25.0f, frame.size.height - 38.0f - _contentInset.top, 20.0f, 20.0f);
		[self addSubview:view];
		_activityView = view;
		[view release];
		
		[self setState:EGOOPullRefreshNormal];
    }
	
    return self;
}

- (id)initWithFrame:(CGRect)frame  {
    return [self initWithFrame:frame arrowImageName:ARROW_IMAGE_NAME
                     textColor:TEXT_COLOR shadowOffset:SHADOW_OFFSET shadowColor:SHADOW_COLOR
               backgroundColor:BACKGROUND_COLOR activityIndicatorStyle:ACTIVITY_INDICATOR_STYLE
        scrollViewContentInset:UIEdgeInsetsZero];
}

#pragma mark -
#pragma mark Setters

- (void)refreshLastUpdatedDate {
	
	if ([_delegate respondsToSelector:@selector(egoRefreshTableHeaderDataSourceLastUpdated:)]) {
		
		NSDate *date = [_delegate egoRefreshTableHeaderDataSourceLastUpdated:self];
		
		[NSDateFormatter setDefaultFormatterBehavior:NSDateFormatterBehaviorDefault];
		NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
		[dateFormatter setDateStyle:NSDateFormatterShortStyle];
		[dateFormatter setTimeStyle:NSDateFormatterShortStyle];
        
		_lastUpdatedLabel.text = [NSString stringWithFormat:@"Last Updated: %@", [dateFormatter stringFromDate:date]];
		[[NSUserDefaults standardUserDefaults] setObject:_lastUpdatedLabel.text forKey:@"EGORefreshTableView_LastRefresh"];
		[[NSUserDefaults standardUserDefaults] synchronize];
		
	} else {
		
		_lastUpdatedLabel.text = nil;
		
	}
    
}

- (void)setState:(EGOPullRefreshState)aState {
	
	switch (aState) {
		case EGOOPullRefreshPulling:
			
			_statusLabel.text = NSLocalizedString(@"Release to refresh...", @"Release to refresh status");
			[CATransaction begin];
			[CATransaction setAnimationDuration:FLIP_ANIMATION_DURATION];
			_arrowImage.transform = CATransform3DMakeRotation((M_PI / 180.0) * 180.0f, 0.0f, 0.0f, 1.0f);
			[CATransaction commit];
			
			break;
		case EGOOPullRefreshNormal:
			
			if (_state == EGOOPullRefreshPulling) {
				[CATransaction begin];
				[CATransaction setAnimationDuration:FLIP_ANIMATION_DURATION];
				_arrowImage.transform = CATransform3DIdentity;
				[CATransaction commit];
			}
			
			_statusLabel.text = NSLocalizedString(@"Pull down to refresh...", @"Pull down to refresh status");
			[_activityView stopAnimating];
			[CATransaction begin];
			[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
			_arrowImage.hidden = NO;
			_arrowImage.transform = CATransform3DIdentity;
			[CATransaction commit];
			
			[self refreshLastUpdatedDate];
			
			break;
		case EGOOPullRefreshLoading:
			
			_statusLabel.text = NSLocalizedString(@"Loading...", @"Loading Status");
			[_activityView startAnimating];
			[CATransaction begin];
			[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
			_arrowImage.hidden = YES;
			[CATransaction commit];
			
			break;
		default:
			break;
	}
	
	_state = aState;
}

#pragma mark -
#pragma mark ScrollView Methods

- (void)egoRefreshScrollViewDidScroll:(UIScrollView *)scrollView {
	
	if (_state == EGOOPullRefreshLoading) {
		
		CGFloat offset = MAX(scrollView.contentOffset.y * -1, 0);
		offset = MIN(offset, 60);
		scrollView.contentInset = UIEdgeInsetsMake(offset + _contentInset.top, _contentInset.left, _contentInset.bottom, _contentInset.right);
		
	} else if (scrollView.isDragging) {
		
		BOOL _loading = NO;
		if ([_delegate respondsToSelector:@selector(egoRefreshTableHeaderDataSourceIsLoading:)]) {
			_loading = [_delegate egoRefreshTableHeaderDataSourceIsLoading:self];
		}
		
		if (_state == EGOOPullRefreshPulling && scrollView.contentOffset.y + _contentInset.top > -65.0f && scrollView.contentOffset.y < 0.0f && !_loading) {
			[self setState:EGOOPullRefreshNormal];
		} else if (_state == EGOOPullRefreshNormal && scrollView.contentOffset.y + _contentInset.top < -65.0f && !_loading) {
			[self setState:EGOOPullRefreshPulling];
		}
		
		if (scrollView.contentInset.top != _contentInset.top) {
			scrollView.contentInset = _contentInset;
		}
		
	}
	
}

- (void)egoRefreshScrollViewDidEndDragging:(UIScrollView *)scrollView {
	
	BOOL _loading = NO;
	if ([_delegate respondsToSelector:@selector(egoRefreshTableHeaderDataSourceIsLoading:)]) {
		_loading = [_delegate egoRefreshTableHeaderDataSourceIsLoading:self];
	}
	
	if (scrollView.contentOffset.y + _contentInset.top <= - 65.0f && !_loading) {
		
		if ([_delegate respondsToSelector:@selector(egoRefreshTableHeaderDidTriggerRefresh:)]) {
			[_delegate egoRefreshTableHeaderDidTriggerRefresh:self];
		}
		
		[self setState:EGOOPullRefreshLoading];
        [UIView animateWithDuration:0.2 animations:^{
            scrollView.contentInset = UIEdgeInsetsMake(60.0f + _contentInset.top, _contentInset.left, _contentInset.bottom, _contentInset.right);
        }];
	}
	
}

- (void)egoRefreshScrollViewDataSourceDidFinishedLoading:(UIScrollView *)scrollView {
	[self setState:EGOOPullRefreshNormal];
    [UIView animateWithDuration:.3 animations:^{
        [scrollView setContentInset:_contentInset];
    }];
}

#pragma mark -
#pragma mark Dealloc

- (void)dealloc {
	_delegate = nil;
	_activityView = nil;
	_statusLabel = nil;
	_arrowImage = nil;
	_lastUpdatedLabel = nil;
    [super dealloc];
}

@end
