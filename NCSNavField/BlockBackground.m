//
//  BlockBackground.m


#import "BlockBackground.h"

@implementation BlockBackground

@synthesize backgroundImage = _backgroundImage;
@synthesize vignetteBackground = _vignetteBackground;

static BlockBackground *_sharedInstance = nil;

+ (BlockBackground*)sharedInstance
{
    if (_sharedInstance != nil) {
        return _sharedInstance;
    }

    @synchronized(self) {
        if (_sharedInstance == nil) {
            _sharedInstance = [[self alloc] init];
        }
    }

    return _sharedInstance;
}

- (id)init
{
    self = [super initWithFrame:[[UIScreen mainScreen] bounds]];
    if (self) {
        self.windowLevel = UIWindowLevelStatusBar;
        self.hidden = YES;
        self.userInteractionEnabled = NO;
        self.backgroundColor = [UIColor colorWithWhite:0.4 alpha:0.5f];
        self.vignetteBackground = NO;
    }
    return self;
}

- (void)addToMainWindow:(UIView *)view
{
    if (self.hidden)
    {
        _previousKeyWindow = [[UIApplication sharedApplication] keyWindow];
        self.alpha = 0.0f;
        self.hidden = NO;
        self.userInteractionEnabled = YES;
        [self makeKeyWindow];
    }
    
    if (self.subviews.count > 0)
    {
        ((UIView*)[self.subviews lastObject]).userInteractionEnabled = NO;
    }
    
    if (_backgroundImage)
    {
        UIImageView *backgroundView = [[UIImageView alloc] initWithImage:_backgroundImage];
        backgroundView.frame = self.bounds;
        backgroundView.contentMode = UIViewContentModeScaleToFill;
        [self addSubview:backgroundView];
        _backgroundImage = nil;
    }
    
    [self addSubview:view];
}

- (void)reduceAlphaIfEmpty
{
    if (self.subviews.count == 1 || (self.subviews.count == 2 && [[self.subviews objectAtIndex:0] isKindOfClass:[UIImageView class]]))
    {
        self.alpha = 0.0f;
        self.userInteractionEnabled = NO;
    }
}

- (void)removeView:(UIView *)view
{
    [view removeFromSuperview];

    UIView *topView = [self.subviews lastObject];
    if ([topView isKindOfClass:[UIImageView class]])
    {
        // It's a background. Remove it too
        [topView removeFromSuperview];
    }
    
    if (self.subviews.count == 0)
    {
        self.hidden = YES;
        [_previousKeyWindow makeKeyWindow];
        _previousKeyWindow = nil;
    }
    else
    {
        ((UIView*)[self.subviews lastObject]).userInteractionEnabled = YES;
    }
}

- (void)drawRect:(CGRect)rect 
{    
    if (_backgroundImage || !_vignetteBackground) return;
    CGContextRef context = UIGraphicsGetCurrentContext();
    
	size_t locationsCount = 2;
	CGFloat locations[2] = {0.0f, 1.0f};
	CGFloat colors[8] = {0.0f,0.0f,0.0f,0.0f,0.0f,0.0f,0.0f,0.75f}; 
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, colors, locations, locationsCount);
	CGColorSpaceRelease(colorSpace);
	
	CGPoint center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
	float radius = MIN(self.bounds.size.width , self.bounds.size.height) ;
	CGContextDrawRadialGradient (context, gradient, center, 0, center, radius, kCGGradientDrawsAfterEndLocation);
	CGGradientRelease(gradient);
}

@end
