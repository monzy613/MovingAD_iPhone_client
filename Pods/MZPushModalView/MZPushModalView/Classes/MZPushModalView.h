//
//  MZPushModalView.h
//  Pods
//
//  Created by 张逸 on 16/4/28.
//
//

#import <UIKit/UIKit.h>
@class MZPushModalView;
@protocol MZPushModalViewDelegate <NSObject>
- (void)pushModalViewWillDismiss:(MZPushModalView *)pushModalView;
- (void)pushModalViewWillShow: (MZPushModalView *)pushModalView;
@end

@interface MZPushModalView : UIView
@property (nonatomic) CGFloat height;
@property (nonatomic, weak) id<MZPushModalViewDelegate> delegate;

- (void)showModal;
- (void)dismissModal;
- (instancetype)initWithModalView:(UIView *)modalView rootView:(UIView *)rootView;
+ (instancetype)showModalView:(UIView *)modalView rootView:(UIView *)rootView;
@end
