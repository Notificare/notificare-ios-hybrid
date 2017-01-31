//
//  FormButton.h
//  app
//
//  Created by Joel Oliveira on 17/05/14.
//  Copyright (c) 2014 Notificare. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FormButton : UIButton

@property (nonatomic, assign) UIEdgeInsets edgeInsets;

- (id)initWithFrame:(CGRect)frame andText:(NSString *)text andTextColor:(UIColor *)textColor andBgColor:(UIColor *)bgColor;

@end
