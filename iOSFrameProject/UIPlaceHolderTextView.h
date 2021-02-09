//
//  UIPlaceHolderTextView.h
//  ECOCityProject
//
//  Created by jointsky on 16/6/15.
//  Copyright © 2016年 com.jointsky.www. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface UIPlaceHolderTextView : UITextView <UITextViewDelegate>{
    
    NSString *placeholder;
    
    UIColor *placeholderColor;
    
    
    
@private
    
    UILabel *placeHolderLabel;
    
}



@property(nonatomic, retain) UILabel *placeHolderLabel;

@property(nonatomic, retain) NSString *placeholder;

@property(nonatomic, retain) UIColor *placeholderColor;



-(void)textChanged:(NSNotification*)notification;

@end