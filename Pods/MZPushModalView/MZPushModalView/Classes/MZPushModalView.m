//
//  MZPushModalView.m
//  Pods
//
//  Created by 张逸 on 16/4/28.
//
//

static const CGFloat ANGLE = M_PI_4 / 3;
static NSTimeInterval durationBack = 0.25;
static NSTimeInterval durationForward = 0.25;

#import "MZPushModalView.h"
@interface MZPushModalView ()
@property (nonatomic) BOOL animating;
@property (nonatomic) UIView *rootView;
@property (nonatomic) UIImageView *snapShotView;
@property (nonatomic) UIView *modalView;
@property (nonatomic) UIView *blackView;
@end

@implementation MZPushModalView

+ (instancetype)showModalView:(UIView *)modalView rootView:(UIView *)rootView
{
    MZPushModalView *pushModalView = [[MZPushModalView alloc] initWithModalView:modalView rootView:rootView];
    [pushModalView.rootView addSubview:pushModalView];
    [pushModalView showModal];
}

- (instancetype)initWithModalView:(UIView *)modalView rootView:(UIView *)rootView
{
    self = [super initWithFrame:rootView.bounds];
    if (self) {
        self.rootView = rootView;
        self.modalView = modalView;
        self.snapShotView = [self snapShot:self.rootView];
        self.height = self.modalView.bounds.size.height;
        [self addSubview:self.blackView];
        [self addSubview:self.snapShotView];
        [self addSubview:self.modalView];
        self.modalView.layer.transform = CATransform3DMakeTranslation(0, 0, sin(ANGLE) * CGRectGetHeight(self.bounds) / 2);
        self.modalView.center = CGPointMake(self.center.x, self.bounds.size.height + self.height / 2);
        [rootView addSubview:self];
    }
    return self;
}

- (void)showModal
{
    if (self.animating) {
        return;
    } else {
        self.animating = YES;
    }
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissModal)];
    [self.snapShotView addGestureRecognizer:tap];
    [self.blackView addGestureRecognizer:tap];
    [UIView animateWithDuration:[self totalDuration] animations:^{
        CGPoint showCenter = CGPointMake(self.center.x, self.bounds.size.height - self.height / 2);
        self.modalView.center = showCenter;
    } completion:^(BOOL finished) {
        if (finished) {
            self.animating = NO;
        }
    }];

    CGFloat zMove = -sin(ANGLE) * CGRectGetHeight(self.bounds) / 2;
    for (UIView *subview in [self subviews]) {
        if (![subview isEqual:self.snapShotView] && ![subview isEqual:self.modalView]) {
            subview.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, 0, zMove * 2);
        }
    }

    [UIView animateWithDuration:durationBack animations:^{
        //dismissOldView
        CATransform3D transform = CATransform3DIdentity;
        transform.m34 = -1.0 / 500.0;
        transform = CATransform3DRotate(transform, ANGLE, 1, 0, 0);
        transform = CATransform3DTranslate(transform, 0, 0, zMove);
        self.snapShotView.layer.transform = transform;
    } completion:^(BOOL finished) {
        if (finished) {
            [UIView animateWithDuration:durationForward animations:^{
                CATransform3D transform = self.snapShotView.layer.transform;
                transform.m34 = -1.0 / 500.0;
                transform = CATransform3DRotate(transform, -ANGLE, 1, 0, 0);
                self.snapShotView.layer.transform = transform;
            }];
        }
    }];
}

- (void)dismissModal
{
    if (self.animating) {
        return;
    } else {
        self.animating = YES;
    }
    [UIView animateWithDuration:[self totalDuration] animations:^{
        CGPoint showCenter = CGPointMake(self.center.x, self.bounds.size.height + self.height / 2);
        self.modalView.center = showCenter;
    } completion:^(BOOL finished) {
        if (finished) {
            self.animating = NO;
            [self.modalView removeFromSuperview];
            self.modalView = nil;
        }
    }];

    [UIView animateWithDuration:durationBack animations:^{
        CATransform3D transform = self.snapShotView.layer.transform;
        transform = CATransform3DRotate(transform, ANGLE, 1, 0, 0);
        transform.m34 = -1.0 / 500.0;
        self.snapShotView.layer.transform = transform;
    } completion:^(BOOL finished) {
        if (finished) {
            [UIView animateWithDuration:durationForward animations:^{
                self.snapShotView.layer.transform = CATransform3DIdentity;
            } completion:^(BOOL finished) {
                if (finished) {
                    for (UIView *subview in [self subviews]) {
                        if (![subview isEqual:self.snapShotView] && ![subview isEqual:self.modalView]) {
                            subview.layer.transform = CATransform3DIdentity;
                        }
                    }
                    [self.blackView removeFromSuperview];
                    self.blackView = nil;
                    [self.snapShotView removeFromSuperview];
                    self.snapShotView = nil;
                    [self removeFromSuperview];
                }
            }];
        }
    }];
}

#pragma mark - privates
- (UIImageView *)snapShot:(UIView *)view
{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, YES, 0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *snapShotImage = UIGraphicsGetImageFromCurrentImageContext();
    UIImageView *imageView = [[UIImageView alloc] initWithImage:snapShotImage];
    imageView.frame = view.bounds;
    return imageView;
}

#pragma mark - getters
- (UIView *)blackView
{
    if (!_blackView) {
        _blackView = [[UIView alloc] initWithFrame:self.bounds];
        _blackView.backgroundColor = [UIColor blackColor];
    }
    return _blackView;
}

- (NSTimeInterval)totalDuration
{
    return durationForward + durationBack;
}
@end
