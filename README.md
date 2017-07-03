# LogAsSwift

## 简介
本代码在转换指针到OC对象和C基本数据类型的部分,修改自

	https://github.com/stanislaw/NSStringFromAnyObject
并对算法做了逻辑简化和增加了对C语言字符串数组的解析(还是不能解析普通数组,无解)

## 简介2
虽然叫LogAsSwift但并不能实现swift的

	"I am\(self)"
这种格式(毕竟是swift的语法特性...)

## 注意事项
本工具并不能在OC\++下使用,因为在OC\++下不能用(__typeof__(object) []){ object }转换成const void*类型

也就是说,如果你想手动导入用百度地图SDK的bitcode版就不能用这个工具了.....

其余说明请查看头文件

## 简单用法:

	newLog(任意变量)
比如:

	newLog(@"Hello, World!");
	newLog(@[@"Hello, World!"])
	newLog([NSDate date])
	newLog(1)
	newLog("下班啦")
	newLog(CGRectZero)
	newLog([NSIndexPath new])
	
等等等等
打印如下:

	Hello, World!
	@[
		Hello, World!
	]
	2017-07-03 03:20:17 +0000
	1
	下班啦
	CGRect: {{0, 0}, {0, 0}}
	NSIndexPath:{
		length = 0
		section = unknwon,row(item) = unknwon
	}
	NSIndexPath:{
		length = 10
		section = unknwon,row(item) = unknwon
	}

如果在iOS项目下(import了UIKit)打印NSIndexPath:
	newLog([NSIndexPath indexPathForRow:1 inSection:1])
打印如下:
	NSIndexPath:{
		length = 2
		section = 1,row(item) = 1
	}

	
## 其他:
以上的newLog都可以用print代替,用法一样

本工具同样替换了NSLog,但用法和原来的一样,方便格式化字符串用

也就是说:

	NSLog(@"%@",xxx)
等价于

	newLog(string(@"%@",xxx))

如果需要原版的Xocde打印(自动前缀时间项目名这些),可以打开.m文件,把

	BOOL printAsNSLog = NO;
改为YES
