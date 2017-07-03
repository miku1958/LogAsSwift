//
//  LogAsSwift.h
//  LogAsSwift
//
//  Created by mikun on 2017/6/28.
//  Copyright © 2017年 mikun. All rights reserved.
//


#if __has_include(<UIKit/UIKit.h>)
#import <UIKit/UIKit.h>
#else
#import <Foundation/Foundation.h>
#endif



#ifdef __OBJC__

///快速格式化字符串
NSString * string(NSString *Format,...);

#pragma mark - 自动去除Debug用的打印
/*	仅在调试界面输出信息,一般请使用newLog()
	如果直接传进来一个C语言数组,比如int[],是处理不了的,因为没有专门的格式化符号
 */
void repalceLog(const char *type, const void *object);
	//OC跟C++一样,不允许直接传入一个临时变量的地址,而基本数据的临时变量作为参数时,是值复制,拿到手后获取类型是地址内容,就不能知道它的类型了,
	//而且OC不支持把id和C基本类型进行赋值运算,至少ARC下不允许
	//而又不能把结构体/指针等用@()来包装(used in a boxed expression)
	//而OC指针又不能隐式转换为void*类型,需要用(__bridge void*)来显式转换,才能用NSValue包装
	//所以才这么麻烦,这个办法是从github的stanislaw大神学习的,感谢stanislaw想出的这个办法(虽然还是处理不了C数组,但我解决了字符数组的解析.详情请看文档说明)
	//按照字符串数组的办法来修改普通数组,却发现指针指向的内容是不同的....所以为也不知道怎么弄了,对内存不是很熟

#ifdef DEBUG
//MARK:	稍微提升一下性能,这里也用#ifdef DEBUG来判断

//gcc要求在头文件中使用__typeof__而不是typeof(虽然也没有问题)
#define newLog(object) repalceLog(@encode(__typeof__(object)), (__typeof__(object) []){ object });
	//在OC++下不能用 (__typeof__(object) []){ object }转换成const void*类型,只能用下面的方法,但是用下面的方法就不能直接打印基本数据类型了
	//#define newLog(object) repalceLog(@encode(__typeof__(object)), (__bridge void *)object);
#define print(object) repalceLog(@encode(__typeof__(object)), (__typeof__(object) []){ object });

#define NSLog(...) newLog(string(__VA_ARGS__))
	//这是为了应对第三方/遗留的大量NSLog做的处理


#else
//详细说明查看debug版本

#define newLog(object)

#define print(object)

#define NSLog(...)


#endif

#endif





