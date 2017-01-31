//
//  FormButton.m
//  app
//
//  Created by Joel Oliveira on 17/05/14.
//  Copyright (c) 2014 Notificare. All rights reserved.
//

#import "FormButton.h"
#import "Definitions.h"

@implementation FormButton

- (id)initWithFrame:(CGRect)frame andText:(NSString *)text andTextColor:(UIColor *)textColor andBgColor:(UIColor *)bgColor
{
    if(self = [super initWithFrame:frame]) {
       
        [self setTitle:text forState:UIControlStateNormal];
        [[self titleLabel] setFont:BUTTON_TEXT];
        [[self titleLabel] setTextColor:textColor];
        [self setBackgroundColor:bgColor];
        [[self titleLabel] setShadowColor:[UIColor blackColor]];
        
        self.layer.cornerRadius= BUTTON_CORNER_RADIUS;
        self.layer.masksToBounds= YES;
        self.layer.borderColor= [BUTTON_BORDER_COLOR CGColor];
        self.layer.borderWidth= BUTTON_BORDER_WIDTH;
    }
    
    return self;
}


@end
