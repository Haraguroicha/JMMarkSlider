//
//  JMMarkSlider.m
//  JMMarkSlider
//
//  Created by JOSE MARTINEZ on 22/07/2014.
//  Copyright (c) 2014 desarrolloios. All rights reserved.
//

#import "JMMarkSlider.h"

@implementation JMMarkSlider

- (id)initWithFrame:(CGRect)frame {
    if (frame.size.height < 35)
        frame.size.height = 35;
    self = [super initWithFrame:frame];
    if (self) {
        // Default configuration
        self.markColor = [UIColor colorWithRed:106/255.0 green:106/255.0 blue:124/255.0 alpha:0.7];
        self.markPositions = @[@10,@20,@30,@40,@50,@60,@70,@80,@90];
        self.markWidth = 1.0;
        self.selectedBarColor = [UIColor colorWithRed:179/255.0 green:179/255.0 blue:193/255.0 alpha:0.8];
        self.unselectedBarColor = [UIColor colorWithRed:55/255.0 green:55/255.0 blue:94/255.0 alpha:0.8];
        self.minimumSnapValue = 0.1;
        self.scrollInset = 3.0;
        UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sliderTappedOrTouched:)];
        [self addGestureRecognizer:tgr];
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(sliderTappedOrTouched:)];
        [self addGestureRecognizer:pan];
        [self addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        CGRect frame = self.frame;
        if (frame.size.height < 35)
            frame.size.height = 35;
        self.frame = frame;
        // Default configuration
        self.markColor = [UIColor colorWithRed:106/255.0 green:106/255.0 blue:124/255.0 alpha:0.7];
        self.markPositions = @[@10,@20,@30,@40,@50,@60,@70,@80,@90];
        self.markWidth = 1.0;
        self.selectedBarColor = [UIColor colorWithRed:179/255.0 green:179/255.0 blue:193/255.0 alpha:0.8];
        self.unselectedBarColor = [UIColor colorWithRed:55/255.0 green:55/255.0 blue:94/255.0 alpha:0.8];
        self.minimumSnapValue = 0.1;
        self.scrollInset = 3.0;
        UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sliderTappedOrTouched:)];
        [self addGestureRecognizer:tgr];
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(sliderTappedOrTouched:)];
        [self addGestureRecognizer:pan];
        [self addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return self;
}

- (void)sliderTappedOrTouched:(UIGestureRecognizer *)g {
    JMMarkSlider *s = (JMMarkSlider *)g.view;
    if (s.highlighted)
        return;
    CGPoint pt = [g locationInView:s];
    CGFloat value = s.minimumValue + pt.x / s.bounds.size.width * (s.maximumValue - s.minimumValue);
    [s setValue:value animated:YES];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

- (void)sliderValueChanged:(JMMarkSlider *)sender {
    if (sender.minimumSnapValue > 0) {
        float snap = 1 / sender.minimumSnapValue;
        float f = roundf(sender.value * snap) / snap;
        //NSLog(@"slider value = %f => %f", sender.value, f);
        if(f != sender.tag) {
            [sender setTag:f];
            [sender setValue:f animated:YES];
            [self sendActionsForControlEvents:UIControlEventEditingDidEnd];
        }
    }
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];

    // We create an innerRect in which we paint the lines
    CGRect innerRect = CGRectInset(rect, 0.0, (CGRectGetHeight(rect) - self.scrollInset) / 2);

    UIGraphicsBeginImageContextWithOptions(innerRect.size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();

    // Selected side
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetLineWidth(context, 12.0);
    CGContextMoveToPoint(context, 10, CGRectGetHeight(innerRect)/2);
    CGContextAddLineToPoint(context, innerRect.size.width - 20, CGRectGetHeight(innerRect)/2);
    CGContextSetStrokeColorWithColor(context, [self.selectedBarColor CGColor]);
    CGContextStrokePath(context);
    UIImage *selectedSide = [UIGraphicsGetImageFromCurrentImageContext() resizableImageWithCapInsets:UIEdgeInsetsZero];

    // Unselected side
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetLineWidth(context, 12.0);
    CGContextMoveToPoint(context, 9, CGRectGetHeight(innerRect)/2);
    CGContextAddLineToPoint(context, innerRect.size.width - 18, CGRectGetHeight(innerRect)/2);
    CGContextSetStrokeColorWithColor(context, [self.unselectedBarColor CGColor]);
    CGContextStrokePath(context);
    UIImage *unselectedSide = [UIGraphicsGetImageFromCurrentImageContext() resizableImageWithCapInsets:UIEdgeInsetsZero];

    // Set trips on selected side
    [selectedSide drawAtPoint:CGPointMake(0,0)];
    for (int i = 0; i < [self.markPositions count]; i++) {
        CGContextSetLineWidth(context, self.markWidth);
        float position = [self.markPositions[i]floatValue] * (innerRect.size.width - 20) / 100.0 + 10;
        CGContextMoveToPoint(context, position, CGRectGetHeight(innerRect)/2 - 5);
        CGContextAddLineToPoint(context, position, CGRectGetHeight(innerRect)/2 + 5);
        CGContextSetStrokeColorWithColor(context, [self.markColor CGColor]);
        CGContextStrokePath(context);
    }
    UIImage *selectedStripSide = [UIGraphicsGetImageFromCurrentImageContext() resizableImageWithCapInsets:UIEdgeInsetsZero];

    // Set trips on unselected side
    [unselectedSide drawAtPoint:CGPointMake(0,0)];
    for (int i = 0; i < [self.markPositions count]; i++) {
        CGContextSetLineWidth(context, self.markWidth);
        float position = [self.markPositions[i]floatValue] * (innerRect.size.width - 20) / 100.0 + 10;
        CGContextMoveToPoint(context, position, CGRectGetHeight(innerRect)/2 - 5);
        CGContextAddLineToPoint(context, position, CGRectGetHeight(innerRect)/2 + 5);
        CGContextSetStrokeColorWithColor(context, [self.markColor CGColor]);
        CGContextStrokePath(context);
    }
    UIImage *unselectedStripSide = [UIGraphicsGetImageFromCurrentImageContext() resizableImageWithCapInsets:UIEdgeInsetsZero];

    UIGraphicsEndImageContext();

    [self setMinimumTrackImage:selectedStripSide forState:UIControlStateNormal];
    [self setMaximumTrackImage:unselectedStripSide forState:UIControlStateNormal];
    if (self.handlerImage != nil) {
        [self setThumbImage:self.handlerImage forState:UIControlStateNormal];
    } else if (self.handlerColor != nil) {
        [self setThumbImage:[UIImage new] forState:UIControlStateNormal];
        [self setThumbTintColor:self.handlerColor];
    }
}

@end
