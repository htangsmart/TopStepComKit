import os


# 引入tsdb数据库测试路径
from tsdb_to_sqlite3 import trans_to_sqlite

tsdb_path = os.path.abspath('../../../../../../../buildScript/tsdb/')
sqlite = os.path.abspath('../../../../../../../buildScript/tsdb/sqlite.db')


# tsdb数据库读取失败回调处理函数
def tsdb_read_failed():
    print("tsdb_read_failed!")


# tsdb数据库读取完成回调处理函数
def tsdb_read_finish(tsdb_list):
    count = 0
    print("tsdb_read_finish!")
    for it in tsdb_list:
        print(it.value)
        print(count)
        count = count + 1


# sqlite 数据库插入数据回调处理函数
def sqlite_insert_failed():
    print("sqlite_insert_failed!")


# sqlite 数据库插入数据完成回调处理函数
def sqlite_insert_finish():
    print("sqlite_insert_finish!")


# tsdb数据库转换至sqlite数据库
trans_to_sqlite(tsdb_path,
                sqlite,
                "tsdb",
                tsdb_read_failed,
                tsdb_read_finish,
                sqlite_insert_failed,
                sqlite_insert_finish)


# sqlite数据库删除表失败回调处理函数
def sqlite_drop_table_failed():
    print("sqlite_drop_table_failed!")


# sqlite数据库删除表完成回调处理函数
def sqlite_drop_table_finish():
    print("sqlite_drop_table_finish!")


# 删除sqlite数据库表
# tsdb.drop_sqlite_table(sqlite,
#                        sqlite_drop_table_failed,
#                        sqlite_drop_table_finish)


# sqlite 数据库删除数据失败回调处理函数
def sqlite_delete_data_failed():
    print("sqlite_delete_data_failed!")


# sqlite 数据库删除数据完成回调处理函数
def sqlite_delete_data_finish():
    print("sqlite_delete_data_finish!")


# 删除sqlite数据库的表中指定时间戳的数据
# tsdb.delete_sqlite_data(sqlite,
#                         396,
#                         sqlite_delete_data_failed,
#                         sqlite_delete_data_finish)
