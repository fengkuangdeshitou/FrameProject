/**
 * @header CALayer
 * @abstract 为CALayer添加一个UIColor的属性
 * @author作者
 * @version 1.00 2016/06/14 Creation
 */

#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>

@interface CALayer (Additions)

@property(nonatomic, strong) UIColor *borderColorFromUIColor;

- (void)setBorderColorFromUIColor:(UIColor *)color;

@end
