//
//  GXSqliteTool.m
//  test2
//
//  Created by JasonBourne on 2019/3/23.
//  Copyright © 2019 JasonBourne. All rights reserved.
//

#import "GXSqliteTool.h"
#import <sqlite3.h>

@interface GXSqliteTool ()

@end

@implementation GXSqliteTool

+ (instancetype)sqliteTool
{
    static GXSqliteTool *_tool = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _tool = [[GXSqliteTool alloc] init];
    });
    return _tool;
}

static sqlite3 *_db;
+ (void)initialize
{
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString *fullPath = [path stringByAppendingPathComponent:@"myShoptrolley.sqlite"];
    NSLog(@"%@", fullPath);
    // 创建数据库
    int success = sqlite3_open(fullPath.UTF8String, &_db);
    
    if (success == SQLITE_OK) {
        NSLog(@"数据库打开成功");
        /*
         参数1: 数据库对象
         参数2: SQL语句
         参数3: 执行成功的回调
         参数4: 回调函数的参数
         参数5: 错误信息
         shopImage 照片
         shopName 商品名字
         price 价格
         amount 商品个数
         shopCount 商品总数
         */

        char *error;
        NSString *sql = @"CREATE TABLE IF NOT EXISTS t_shoptrolley (id integer  PRIMARY KEY AUTOINCREMENT, shopImage text, shopName text, price text, amount int, shopCount int, goodsID int);";
        success = sqlite3_exec(_db, sql.UTF8String, NULL, NULL, &error);
        if (success == SQLITE_OK) {
            NSLog(@"创建表成功");
        } else {
            NSLog(@"创建表失败");
        }
    } else {
        NSLog(@"数据库打开失败");
    }
}

- (BOOL)insert:(KGShoppingTrolleyModel *)stu
{
    // 是否有此数据
    KGShoppingTrolleyModel *model = [[self selectWithText:stu.shopName] firstObject];
    if (model) {
        return NO;
    } else {
        //    shopImage 照片
        //    shopName 商品名字
        //    price 价格
        //    amount 商品个数
        //    shopCount 商品总数
        NSString *sql = [NSString stringWithFormat:@"insert into t_shoptrolley (shopImage, shopName, price, amount, shopCount, goodsID) values ('%@', '%@', '%@', %@, %@, %@);", stu.shopImage, stu.shopName, stu.price, stu.amount, stu.shopCount, stu.goodsId];
        char *error;
        int success = sqlite3_exec(_db, sql.UTF8String, NULL, NULL, &error);
        if (success == SQLITE_OK) {
            NSLog(@"插入数据成功");
            return YES;
        } else {
            NSLog(@"插入数据失败");
            return NO;
        }
    }
}

- (NSArray *)select
{
    sqlite3_stmt *stmt;
    NSString *sql = @"select * from t_shoptrolley";
    int success = sqlite3_prepare(_db, sql.UTF8String, -1, &stmt, NULL);
    // -1 负数是自动计算SQL语句的长度, sqlite3_stmt查出来的集合, 最后一个不知道
    if (success == SQLITE_OK) {
        NSLog(@"准备好了");
        // 取数据 
        NSMutableArray *models = [NSMutableArray array];
        while (sqlite3_step(stmt) == SQLITE_ROW) {// 调一次, 跳一行
            NSLog(@"查出有数据");
            //    shopImage 照片
            //    shopName 商品名字
            //    price 价格
            //    amount 商品个数
            //    shopCount 商品总数
            //
            const unsigned char *shopImage = sqlite3_column_text(stmt, 1);
            const unsigned char *shopName = sqlite3_column_text(stmt, 2);
            const unsigned char *price = sqlite3_column_text(stmt, 3);
            int amount = sqlite3_column_int(stmt, 4);
            int shopCount = sqlite3_column_int(stmt, 5);
            int goodsID = sqlite3_column_int(stmt, 6);
//            NSLog(@"%s, %f", text, score);
            KGShoppingTrolleyModel *stu = [[KGShoppingTrolleyModel alloc] init];
            stu.shopImage = [NSString stringWithUTF8String:(const char *)shopImage];
            stu.shopName = [NSString stringWithUTF8String:(const char *)shopName];
            stu.price = [NSString stringWithUTF8String:(const char *)price];
            stu.amount = [NSString stringWithFormat:@"%d", amount];
            stu.shopCount = [NSString stringWithFormat:@"%d", shopCount];
            stu.goodsId = [NSString stringWithFormat:@"%d", goodsID];
            [models addObject:stu];
        }
        return models;
    } else {
        NSLog(@"没TM准备好");
    }
    return nil;
}

- (void)deleteWithText:(NSString *)text
{
    NSString *sql = [NSString stringWithFormat:@"delete from t_shoptrolley WHERE goodsID = %@", text];
    char *error;
    int success = sqlite3_exec(_db, sql.UTF8String, NULL, NULL, &error);
    if (success == SQLITE_OK) {
        NSLog(@"删除数据成功");
    } else {
        NSLog(@"删除数据失败");
    }
}

- (void)delete
{
    NSString *sql = @"delete from t_shoptrolley";
    char *error;
    int success = sqlite3_exec(_db, sql.UTF8String, NULL, NULL, &error);
    if (success == SQLITE_OK) {
        NSLog(@"删除数据成功");
    } else {
        NSLog(@"删除数据失败");
    }
}

- (NSArray *)selectWithText:(NSString *)text
{
    NSString *sql = [NSString stringWithFormat:@"select * from t_shoptrolley WHERE shopName = '%@'", text];
    sqlite3_stmt *stmt;
    int success = sqlite3_prepare(_db, sql.UTF8String, -1, &stmt, NULL);
    if (success == SQLITE_OK) {
        NSLog(@"准备好了");
        NSMutableArray *models = [NSMutableArray array];
        while (sqlite3_step(stmt) == SQLITE_ROW) {
             NSLog(@"查出有数据");
            //    shopImage 照片
            //    shopName 商品名字
            //    price 价格
            //    amount 商品个数
            //    shopCount 商品总数
            const unsigned char *shopImage = sqlite3_column_text(stmt, 1);
            const unsigned char *shopName = sqlite3_column_text(stmt, 2);
            const unsigned char *price = sqlite3_column_text(stmt, 3);
            int amount = sqlite3_column_int(stmt, 4);
            int shopCount = sqlite3_column_int(stmt, 5);
            int goodsID = sqlite3_column_int(stmt, 6);
            //            NSLog(@"%s, %f", text, score);
            KGShoppingTrolleyModel *stu = [[KGShoppingTrolleyModel alloc] init];
            stu.shopImage = [NSString stringWithUTF8String:(const char *)shopImage];
            stu.shopName = [NSString stringWithUTF8String:(const char *)shopName];
            stu.price = [NSString stringWithUTF8String:(const char *)price];
            stu.amount = [NSString stringWithFormat:@"%d", amount];
            stu.shopCount = [NSString stringWithFormat:@"%d", shopCount];
            stu.goodsId = [NSString stringWithFormat:@"%d", goodsID];
            [models addObject:stu];
        }
        return models;
        
    } else {
        NSLog(@"没有准备好");
        return nil;
    }
    
}

- (BOOL)updataWithText:(KGShoppingTrolleyModel *)model
{
    NSInteger number = [model.amount integerValue];
    number++;
    model.amount = [NSString stringWithFormat:@"%ld", number];
    NSString *sql = [NSString stringWithFormat:@"update t_shoptrolley set amount = '%ld' WHERE shopName = '%@'", number, model.shopName];
    char *error;
    int success = sqlite3_exec(_db, sql.UTF8String, NULL, NULL, &error);
    if (success == SQLITE_OK) {
        NSLog(@"更改数据成功");
        return YES;
    } else {
        NSLog(@"更改数据失败");
        return NO;
    }
}

@end
