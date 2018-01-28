//
//  ViewController.m
//  Light Step
//
//  Created by Roger Jönsson on 13/11/16.
//  Copyright © 2016 Roger Jönsson. All rights reserved.
//

#import "ViewController.h"
#import "GradientLayerView.h"
#import "CoreMotion/CoreMotion.h"

@interface ViewController ()

@property (weak, nonatomic) UILabel *label;

@property (weak) NSTimer *timer;

@end

@implementation ViewController


- (void)loadView
{
	self.view = [[GradientLayerView alloc] initWithFrame:UIScreen.mainScreen.bounds];
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	UILabel * const label = [[UILabel alloc] initWithFrame:CGRectInset(self.view.frame, 20, 20)];
	label.textAlignment = NSTextAlignmentCenter;
	label.numberOfLines = 0;
	label.font = [UIFont systemFontOfSize:24];
	label.text = @"This text will disappear when you move.\n\nMake sure to keep this app in the foreground and allow access to motion & fitness activities.\n\nGood luck with your training!";
	label.center = self.view.center;
	[self.view addSubview:label];

	[NSTimer scheduledTimerWithTimeInterval:6 target:self selector:@selector(changeColor) userInfo:nil repeats:YES];
	[self changeColor];

	__block CGFloat labelAlpha = label.alpha; // Don't access GUI component from some other thread.
	void (^toggleText)(BOOL) = ^void(BOOL hidden) {
		const BOOL newLabelAlpha = (hidden ? 0 : 1);
		if(newLabelAlpha != labelAlpha)
		{
			dispatch_async(dispatch_get_main_queue(), ^{
				[UIView animateWithDuration:1 animations:^{
					label.alpha = newLabelAlpha;
				} completion:^(BOOL finished) {
					labelAlpha = label.alpha;
				}];
			});
		}
	};
	
	CMMotionActivityManager * const motionActivityManager = [CMMotionActivityManager new];
	[motionActivityManager startActivityUpdatesToQueue:[NSOperationQueue new] withHandler:^(CMMotionActivity * _Nullable activity) { toggleText(activity.walking || activity.running); }];
}

- (BOOL)prefersStatusBarHidden
{
	return YES;
}

- (BOOL)prefersHomeIndicatorAutoHidden
{
	return YES;
}

- (void)changeColor
{
	NSAssert([self.view.layer isKindOfClass:CAGradientLayer.class], @"Wrong layer class.");
	CAGradientLayer * const gradientLayer = (CAGradientLayer *)self.view.layer;

	id const oldColors = gradientLayer.colors;

	const float hue0 = ((float)arc4random() / UINT32_MAX);
	const float hue1 = ((float)arc4random() / UINT32_MAX);
	UIColor * const color0 = [UIColor colorWithHue:hue0 saturation:1 brightness:1 alpha:1];
	UIColor * const color1 = [UIColor colorWithHue:hue1 saturation:1 brightness:1 alpha:1];
	gradientLayer.colors = @[(id)color0.CGColor, (id)color1.CGColor];
	
	CABasicAnimation * const animation = [CABasicAnimation animationWithKeyPath:@"colors"];
	animation.fromValue = oldColors;
	animation.toValue = gradientLayer.colors;
	animation.duration = 0.8;
	[gradientLayer addAnimation:animation forKey:@"colors"];
}

@end
