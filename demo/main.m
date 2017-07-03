//
//  main.m
//  demo
//
//  Created by 庄黛淳华 on 2017/7/3.
//
//

#import <Foundation/Foundation.h>
#import "LogAsSwift.h"
int main(int argc, const char * argv[]) {
	@autoreleasepool {
	    newLog(@"Hello, World!");
		newLog(@[@"Hello, World!"])
		newLog([NSDate date])
		newLog(1)
		newLog(CGRectZero)
		newLog([NSIndexPath new])
	}
	return 0;
}
