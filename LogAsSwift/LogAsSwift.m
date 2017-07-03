//
//  LogAsSwift.m
//  LogAsSwift
//
//  Created by mikun on 2017/6/28.
//  Copyright © 2017年 mikun. All rights reserved.
//


#import "LogAsSwift.h"

BOOL printAsNSLog = NO;

#ifdef __OBJC__

NSString * string(NSString *Format,...){
va_list args;
va_start(args, Format);
	NSString *str = [[NSString alloc]initWithFormat:Format arguments:args];
va_end(args);
	return str;
}

//转换指针到OC对象和C基本数据类型的部分,修改自
	//https://github.com/stanislaw/NSStringFromAnyObject
//算法做了逻辑简化
void repalceLog(const char *type, const void *voidObject){
#ifdef DEBUG
	
	__unsafe_unretained id object = nil;
	NSString *printStr;
	
	switch (type[0]) {
		case '@': {//NS对象
			object = *(__unsafe_unretained id *)voidObject;
			break;
		}
		case '#': {//NS类
			object = *(Class *)voidObject;
			break;
		}
		case ':': {//方法对象
			object = NSStringFromSelector(*(SEL *)voidObject);
			break;
		}
		default:
			break;
	}
	
	if (object){
		
		if ([object isKindOfClass:NSString.class]) {
			printStr = object;
		}else if([object isKindOfClass:NSArray.class]){
#pragma mark - 处理NSArray的中文
			NSArray *arrObject = object;
			
			// 开头有个[
			NSMutableString *string = @"@[\n".mutableCopy;
			
			// 遍历所有的元素
			[arrObject enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
				[string appendFormat:@"\t%@,\n", obj];
			}];
			
			// 结尾有个]
			[string appendString:@"]"];
			
			// 查找最后一个逗号
			NSRange range = [string rangeOfString:@"," options:NSBackwardsSearch];
			if (range.location != NSNotFound)
				[string deleteCharactersInRange:range];
			printStr = string.copy;
			
		}else if([object isKindOfClass:NSDictionary.class]){
#pragma mark - 处理NSDictionary的中文
			NSDictionary *dicObject = object;
			
			// 开头有个{
			NSMutableString *string = @"@{\n".mutableCopy;
			
			// 遍历所有的键值对
			[dicObject enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
				[string appendFormat:@"\t%@", key];
				[string appendString:@" : "];
				[string appendFormat:@"%@,\n", obj];
			}];
			
			// 结尾有个}
			[string appendString:@"}"];
			
			// 查找最后一个逗号
			NSRange range = [string rangeOfString:@"," options:NSBackwardsSearch];
			if (range.location != NSNotFound)
				[string deleteCharactersInRange:range];
			
			printStr = string.copy;
		}else if ([object isKindOfClass:NSIndexPath.class]) {
			NSIndexPath *indexPathObject = object;
			
			// 开头有个NSIndexPath:{
			NSMutableString *str = @"NSIndexPath:{\n".mutableCopy;
			
			[str appendString:string(@"\tlength = %d\n",indexPathObject.length)];
			@try {
				//如果开了Exception Breakpoint会停在这里,继续就行了
				//为了通用,这里import的是<Foundation/Foundation.h>,所以找不到section这个属性
				id section = [indexPathObject valueForKeyPath:@"section"];
				[str appendString:string(@"\tsection = %d",[section integerValue])];
			} @catch (NSException *exception) {
				[str appendString:string(@"\tsection = unknwon")];
			}
			
			@try {
				//如果开了Exception Breakpoint会停在这里,继续就行了
				//如果是使用[NSIndexPath indexPathWithIndex:]来初始化的,内部的_indexes[1]不会有值,也就会崩溃
				id row = [indexPathObject valueForKeyPath:@"row"];
				[str appendString:string(@",row(item) = %d\n",[row integerValue])];
			} @catch (NSException *exception) {
				[str appendString:string(@",row(item) = unknwon\n")];
			}
			
			// 结尾有个]
			[str appendString:@"}"];
			
			printStr = str.copy;
			
		}else  if ([object isKindOfClass:NSObject.class]) {
			NSObject* nsobj = object;
			printStr = nsobj.description;
		}

	}else{
#pragma mark
//FIXME:	这里写的比较激进,默认了只要不是NSObject的子类,都是基本数据类型/结构体,可能有无继承的类,但那些我也解析不了
		
#pragma mark - C numeric types
		//对浮点数简单做了处理,要放到最前面判断
		if (strcmp(@encode(double), type) == 0) {
			printStr = string(@"%f",*(double *)voidObject);
		}
		
		if (strcmp(@encode(float), type) == 0){
			printStr = string(@"%ff",*(float *)voidObject);
		}
		
		if (printStr.length>2) {//x.y
			while ([[printStr substringFromIndex:printStr.length-1] isEqualToString:@"0"]) {
				printStr = [printStr substringToIndex:printStr.length-1];
			}
			if ([[printStr substringFromIndex:printStr.length-1] isEqualToString:@"."]) {
				printStr = string(@"%@0",printStr);
			}
		}
		
		
		if (strcmp(@encode(BOOL), type) == 0){
			if (strcmp(@encode(BOOL), @encode(signed char)) == 0){
				// 32 bit
				char ch = *(signed char *)voidObject;
				if ((char)YES == ch) printStr =  @"true";
				if ((char)NO == ch) printStr =  @"false";
			}
			
			else if (strcmp(@encode(BOOL), @encode(bool)) == 0){
				// 64 bit
				bool boolValue = *(bool *)voidObject;
				if (boolValue) {
					printStr =  @"true";
				}else{
					printStr =  @"false";
				}
			}
		}
		
		
		if (strcmp(@encode(int), type) == 0){
			printStr = string(@"%d",*(int *)voidObject);
		}
		
		if (strcmp(@encode(short), type) == 0){
			printStr = string(@"%d",*(short *)voidObject);
		}
		
		if (strcmp(@encode(long), type) == 0){
			printStr = string(@"%ldL", *(long *)voidObject);
		}
		
		if (strcmp(@encode(long long), type) == 0) {
			printStr = string(@"%lldLL", *(long long *)voidObject);
		}
		
		if (strcmp(@encode(unsigned int), type) == 0){
			printStr = string(@"%u", *(unsigned int *)voidObject);
		}
		
		if (strcmp(@encode(unsigned short), type) == 0){
			printStr = string(@"%u", *(unsigned short *)voidObject);
		}
		
		if (strcmp(@encode(unsigned long), type) == 0){
			printStr = string(@"%lu", *(unsigned long *)voidObject);
		}
		
		if (strcmp(@encode(unsigned long long), type) == 0){
			printStr = string(@"%llu", *(unsigned long long *)voidObject);
		}

#pragma mark - C char (*) strings
		if (strcmp(@encode(const char *), type) == 0) {
			printStr = string(@"%s", *(const char **)voidObject);
		}
		if (strcmp(@encode(char *), type) == 0) {
			printStr = string(@"%s", *(const char **)voidObject);
		}
		if (strcmp(@encode(char), type) == 0){
			char ch = *(char *)voidObject;
			printStr = string(@"%c",ch);
		}
		if (strcmp(@encode(unsigned char), type) == 0){
			printStr = string(@"%c", *(unsigned char *)voidObject);
		}
		NSString *NSType = [NSString stringWithUTF8String:type];
		if ([NSType hasSuffix:@"c]"]) {
			char* charObject = (char*)voidObject;
			printStr = [NSString stringWithUTF8String:charObject];
		}
		
#pragma mark - C语言数据都匹配不到
		if (!printStr) {
			printStr = [NSValue valueWithBytes:voidObject objCType:type].description;
			printStr = [printStr stringByReplacingOccurrencesOfString:@"NS" withString:@"CG"];
			printStr = [printStr stringByReplacingOccurrencesOfString:@"CGRange" withString:@"NSRange"];
		}

	}
	if (printStr) {
		
		if (printAsNSLog) {
		//类似NSLog的打印,因为我不知道项目名后面的[]是什么所以没加
			NSDate *date = [NSDate date];
			NSTimeZone *zone = [NSTimeZone systemTimeZone];
			NSInteger interval = [zone secondsFromGMTForDate: date];
			NSDate *localeDate = [date dateByAddingTimeInterval: interval];
			
			NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
			fmt.dateFormat = @"yyyy-MM-dd HH:mm:ss.SSS";
			NSString* dateStr = [fmt stringFromDate:localeDate];
			
			NSString *displayName = [NSBundle.mainBundle.infoDictionary objectForKey:(__bridge NSString*)kCFBundleNameKey];
			
			printStr = string(@"%@ %@ %@",dateStr,displayName,printStr);
		}
		
		printf("%s\n",printStr.UTF8String);
	}
	
#endif
}

#endif
