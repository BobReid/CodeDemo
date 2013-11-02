//
//  CDProgressIndicatorCell.m
//  CodeDemo
//
//  Created by Bob Reid on 10/29/2013.
//  Copyright (c) 2013 Bob Reid. All rights reserved.
//

#import "CDProgressIndicatorCell.h"

@implementation CDProgressIndicatorCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        _progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        [self.progressView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.contentView addSubview:self.progressView];
    }
    return self;
}

- (void)updateConstraints
{
    if(!constrainsInitialized)
    {
        NSDictionary* views = @{ @"imageView" : self.imageView,
                                 @"progress" : self.progressView };
        NSArray* cs;
        cs = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[imageView][progress]|" options:NSLayoutFormatAlignAllBottom metrics:nil views:views];
        
        [self addConstraints:cs];
        
        constrainsInitialized = YES;
    }
    
    [super updateConstraints];
}

@end
