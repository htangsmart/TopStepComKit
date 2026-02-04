//
//  TSSQLOperation.h
//  TopStepToolKit
//
//  Created by 磐石 on 2025/2/28.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TSSQLOperation : NSObject

/**
 * @brief Extract SQL statements for creating tables from a specified file.
 * @chinese 从指定文件中提取创建表的SQL语句。
 * 
 * @param filePath
 * EN: The path to the file containing SQL statements.
 * CN: 包含SQL语句的文件路径。
 * 
 * @return An array of SQL statements for creating tables.
 * @chinese 返回创建表的SQL语句数组。
 */
+ (NSArray<NSString *> *)extractTableSqlsFromFile:(NSString *)filePath;

/**
 * @brief Extract fields from a CREATE TABLE SQL statement.
 * @chinese 从CREATE TABLE SQL语句中提取字段信息。
 * 
 * @param createTableSql
 * EN: The CREATE TABLE SQL statement to extract fields from.
 * CN: 要提取字段的CREATE TABLE SQL语句。
 * 
 * @return A dictionary containing field names and their types.
 * @chinese 返回包含字段名及其类型的字典。
 */
+ (NSDictionary<NSString *, id> *)extractTableFieldsFromCreateTableSql:(NSString *)createTableSql;

/**
 * @brief Extract the table name from a SQL statement.
 * @chinese 从SQL语句中提取表名。
 * 
 * @param sql
 * EN: The SQL statement from which to extract the table name.
 * CN: 要从中提取表名的SQL语句。
 * 
 * @return The name of the table extracted from the SQL statement.
 * @chinese 从SQL语句中提取的表名。
 */
+ (NSString *)extractTableNameFromSql:(NSString *)sql;

@end

NS_ASSUME_NONNULL_END
