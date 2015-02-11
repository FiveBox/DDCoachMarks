//
//  DDBubble.m
//  Coach Marks
//
//  Created by Darin Doria on 02/17/2014.
//  Copyright (c) 2014 Darin Doria. All rights reserved.
//

#import "DDBubble.h"

#define ARROW_SPACE 6 // space between arrow and highlighted region
#define ARROW_SIZE 8
#define PADDING 8 // padding between text and border of bubble
#define RADIUS 6
#define TEXT_COLOR [UIColor blackColor]
#define TITLE_FONT_SIZE 14

@interface DDBubble ()
{
    float _arrowOffset;
}

@end

@implementation DDBubble


#pragma mark - Initialization

-(id)initWithAttachedView:(UIView*)view title:(NSString*)title description:(NSString*)description arrowPosition:(CRArrowPosition)arrowPosition andColor:(UIColor*)color
{
    return [self initWithFrame:view.frame title:title description:description arrowPosition:arrowPosition andColor:color];
}

-(id)initWithFrame:(CGRect)frame title:(NSString*)title description:(NSString*)description arrowPosition:(CRArrowPosition)arrowPosition andColor:(UIColor*)color
{
    self = [super init];
    if(self)
    {
        if(color!=nil)
            self.color=color;
        else
            self.color=[UIColor whiteColor];
        
        self.attachedFrame = frame;
        self.title = title;
        self.bubbleText = description;
        self.arrowPosition = arrowPosition;
        [self setBackgroundColor:[UIColor clearColor]];
    }
    
    UIFont* font = [self font];
    
    // position bubble
    [self setFrame:[self calculateFrameWithFont:font]];
    [self fixFrameIfOutOfBounds];
    
    // calculate and position text
    CGSize offsets = [self offsets];
    float actualXPosition = offsets.width+PADDING*1.5;
    float actualYPosition = offsets.height+PADDING*1.25;
    float actualWidth = self.frame.size.width - offsets.width - PADDING*3;
    float actualHeight = self.frame.size.height-PADDING*2.5;
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(actualXPosition, actualYPosition, actualWidth, actualHeight)];
    [titleLabel setTextColor:TEXT_COLOR];
    [titleLabel setAlpha:0.9];
    [titleLabel setFont:font];
    [titleLabel setText:title];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [titleLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [titleLabel setNumberOfLines:0];
    [self addSubview:titleLabel];
    
    
    [self setNeedsDisplay];
    return self;
}

- (UIFont*) font {
    return [UIFont fontWithName:@"HelveticaNeue" size:TITLE_FONT_SIZE];
}


#pragma mark - Positioning and Size

- (void)fixFrameIfOutOfBounds
{
    /**
     *  Description:
     *
     *  Check if bubble is going off the screen using the
     *  position and size. If it is, return YES.
     */
    
    CGRect window = [[[UIApplication sharedApplication] keyWindow] frame];
    const float xBounds = window.size.width; // 320;
//    const float yBounds = 568;
    
    float x = self.frame.origin.x;
    float y = self.frame.origin.y;
    float width = self.frame.size.width;
    float height = self.frame.size.height;
    
    float padding = 3;
    
    // check for right most bound
    if (x + width > xBounds) {
        _arrowOffset = (x + width) - xBounds;
        x = xBounds - width;
    }
    // check for left most bound
    if (x < 0) {
        _arrowOffset = x - padding;
        x = 0;
    }
    
    [self setFrame:CGRectMake(x, y, width, height)];
}

-(CGRect)calculateFrameWithFont:(UIFont*)font
{
    //Calculation of the bubble position
    float x = self.attachedFrame.origin.x;
    float y = self.attachedFrame.origin.y;
    
    CGSize size = [self sizeWithFont:font];
    
    if(self.arrowPosition==CRArrowPositionLeft||self.arrowPosition==CRArrowPositionRight)
    {
        y+=self.attachedFrame.size.height/2-size.height/2;
        x+=(self.arrowPosition==CRArrowPositionLeft)? ARROW_SPACE+self.attachedFrame.size.width : -(ARROW_SPACE*2+size.width);
        
    }else if(self.arrowPosition==CRArrowPositionTop||self.arrowPosition==CRArrowPositionBottom)
    {
        x+=self.attachedFrame.size.width/2-size.width/2;
        y+=(self.arrowPosition==CRArrowPositionTop)? ARROW_SPACE+self.attachedFrame.size.height : -(ARROW_SPACE*2+size.height);
    }
    
    CGSize offsets = [self offsets];
    return CGRectMake(x, y, size.width+offsets.width, size.height+offsets.height);
}

-(CGSize)sizeWithFont:(UIFont*)font
{
    // Calcultation of the bubble size
    // size of bubble title determined by the strings attributes
    CGSize offset = [self offsets];
    CGRect window = [[[UIApplication sharedApplication] keyWindow] frame];
    
    CGSize result = [_title sizeWithFont:font constrainedToSize:CGSizeMake(window.size.width - offset.width - (PADDING*4), FLT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
    
    return CGSizeMake(result.width + (PADDING*3), result.height + (PADDING*2.5));
}

-(CGSize)offsets
{
    return CGSizeMake((self.arrowPosition==CRArrowPositionLeft)? ARROW_SIZE : 0, (self.arrowPosition==CRArrowPositionTop)? ARROW_SIZE : 0);
}



#pragma mark - Drawing and Animation

- (void)drawRect:(CGRect)rect
{
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSaveGState(ctx);
    
    CGSize size = [self sizeWithFont:[self font]];
    
    CGPathRef clippath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake([self offsets].width,[self offsets].height, size.width, size.height) cornerRadius:RADIUS].CGPath;
    CGContextAddPath(ctx, clippath);
    
    CGContextSetFillColorWithColor(ctx, self.color.CGColor);
    
    CGContextClosePath(ctx);
    CGContextFillPath(ctx);

    [self.color set];
    
    //  tip of arrow needs to be centered under highlighted region
    //  this center area is always arrow size divided by 2
    float center = ARROW_SIZE/2;
    
    //  points used to draw arrow
    //  Wide Arrow --> x = center + - ArrowSize
    //  Skinny Arrow --> x = center + - center
    //  Normal Arrow -->
    CGPoint startPoint = CGPointMake(center - ARROW_SIZE, ARROW_SIZE);
    CGPoint midPoint = CGPointMake(center, 0);
    CGPoint endPoint = CGPointMake(center + ARROW_SIZE, ARROW_SIZE);
    
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:startPoint];
    [path addLineToPoint:endPoint];
    [path addLineToPoint:midPoint];
    [path addLineToPoint:startPoint];
    
    
    if(self.arrowPosition==CRArrowPositionTop)
    {
        CGAffineTransform trans = CGAffineTransformMakeTranslation(size.width/2-(ARROW_SIZE)/2+_arrowOffset, 0);
        [path applyTransform:trans];
    }else if(self.arrowPosition==CRArrowPositionBottom)
    {
        CGAffineTransform rot = CGAffineTransformMakeRotation(M_PI);
        CGAffineTransform trans = CGAffineTransformMakeTranslation(size.width/2+(ARROW_SIZE)/2+_arrowOffset, size.height+ARROW_SIZE);
        [path applyTransform:rot];
        [path applyTransform:trans];
    }else if(self.arrowPosition==CRArrowPositionLeft)
    {
        CGAffineTransform rot = CGAffineTransformMakeRotation(M_PI*1.5);
        CGAffineTransform trans = CGAffineTransformMakeTranslation(0, (size.height+ARROW_SIZE)/2);
        [path applyTransform:rot];
        [path applyTransform:trans];
    }else if(self.arrowPosition==CRArrowPositionRight)
    {
        CGAffineTransform rot = CGAffineTransformMakeRotation(M_PI*0.5);
        CGAffineTransform trans = CGAffineTransformMakeTranslation(size.width+ARROW_SIZE, (size.height-ARROW_SIZE)/2);
        [path applyTransform:rot];
        [path applyTransform:trans];
    }
    
    [path closePath]; // Implicitly does a line between p4 and p1
    [path fill]; // If you want it filled, or...
    [path stroke]; // ...if you want to draw the outline.
    CGContextRestoreGState(ctx);
}

- (void)animate
{
    [UIView animateWithDuration:2.0f
                          delay:0.3
                        options:(UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse)
                     animations:^ {
                         self.transform = CGAffineTransformMakeTranslation(0, -5);
                     }
                     completion:^(BOOL finished) {
                     }];
}

@end
