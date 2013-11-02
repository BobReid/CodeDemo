//
//  CDLoadingIndicatorCell.h
//  CodeDemo
//
//  Created by Bob Reid on 10/30/2013.
//  Copyright (c) 2013 Bob Reid. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CDLoadingIndicatorCell : UITableViewCell
{
@private
    BOOL constrainsInitialized;
}


@property (strong, nonatomic, readonly) UIActivityIndicatorView* activityIndicator;

@end
