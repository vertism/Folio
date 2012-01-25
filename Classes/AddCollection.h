//
//  AddCollection.h
//  Folio
//
//  Created by Pep on 19/10/2010.
//  Copyright 2010 Object Get. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface AddCollection : UIViewController <UITextFieldDelegate>
{
	NSManagedObjectContext *context;
	UINavigationBar *navBar;
	UITextField *textBox;
}

@end
