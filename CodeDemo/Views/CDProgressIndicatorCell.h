//
//  CDProgressIndicatorCell.h
//  CodeDemo
//
//  Created by Bob Reid on 10/29/2013.
//  Copyright (c) 2013 Bob Reid. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CDProgressIndicatorCell : UITableViewCell
{
@private
    BOOL constrainsInitialized;
}

@property (strong, nonatomic) UIProgressView* progressView;

@end
