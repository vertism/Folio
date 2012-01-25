//
//  FoTabBarController.h
//  Folio
//
//  Created by Pep on 18/10/2010.
//  Copyright 2010 Object Get. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FoTabBarController : NSObject <UITabBarDelegate>
{

}

- (NSArray*)Items;
- (void)tabBar:(UITabBar *)myTabBar didSelectItem:(UITabBarItem *)item didPressTab:(BOOL)tab;
- (void)GoTo:(UITabBarItem*)tab;

@end
