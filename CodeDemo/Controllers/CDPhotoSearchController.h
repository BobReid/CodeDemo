//
//  CDPhotoSearchController.h
//  CodeDemo
//
//  Created by Bob Reid on 10/30/2013.
//  Copyright (c) 2013 Bob Reid. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CDPhotoSearchController;
@class CDPhotoDescription;

@protocol CDPhotoSearchControllerDelegate <NSObject>

@required
- (void)photoSearchController:(CDPhotoSearchController*)photoSearchController didSelectPhoto:(CDPhotoDescription*)photo;

@end

@interface CDPhotoSearchController : NSObject < UITableViewDataSource,
                                                UITableViewDelegate,
                                                UISearchDisplayDelegate,
                                                UISearchBarDelegate,
                                                UIScrollViewDelegate>

@property (strong, nonatomic, readonly) NSMutableArray* searchResults;
@property (strong, nonatomic, readonly) UISearchDisplayController* searchDisplayController;
@property (weak, nonatomic) id <CDPhotoSearchControllerDelegate> delegate;

- (id)initWithSearchDisplayController:(UISearchDisplayController*)searchDisplayController;

@end
