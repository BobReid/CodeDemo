//
//  CDLoadingIndicatorCell.m
//  CodeDemo
//
//  Created by Bob Reid on 10/30/2013.
//  Copyright (c) 2013 Bob Reid. All rights reserved.
//

#import "CDLoadingIndicatorCell.h"

@implementation CDLoadingIndicatorCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [self.activityIndicator setColor:[UIColor blackColor]];
        [self.activityIndicator setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.contentView addSubview:self.activityIndicator];
    }
    return self;
}

- (void)updateConstraints
{
    if(!constrainsInitialized)
    {
        NSLayoutConstraint* c;
        c = [NSLayoutConstraint constraintWithItem:self.activityIndicator attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0];
        [self addConstraint:c];
        
        c = [NSLayoutConstraint constraintWithItem:self.activityIndicator attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0];
        [self addConstraint:c];
        
        constrainsInitialized = YES;
    }
    
    [super updateConstraints];
}


@end
