import json
import sqlite3
import struct
import os
import re
import logging

import ubjson

# 配置输出日志格式
LOG_FORMAT = "%(asctime)s %(name)s %(levelname)s %(pathname)s : %(message)s"
# 配置输出时间的格式，注意月份和天数不要搞乱了
DATE_FORMAT = '%Y-%m-%d  %H:%M:%S %a '

# 常用的常量值
SECTOR_HDR_DATA_SIZE = 40
SECTOR_DATA_SIZE = 4096
LOG_IDX_DATA_SIZE = 16
SECTOR_MAGIC_WORD = 0x304C5354
FDB_WRITE_GRAN = 1
# 扇区存储状态
FDB_SECTOR_STORE_UNUSED = 0
FDB_SECTOR_STORE_EMPTY = 1
FDB_SECTOR_STORE_USING = 2
FDB_SECTOR_STORE_FULL = 3
FDB_SECTOR_STORE_STATUS_NUM = 4
# TSL使用状态
FDB_TSL_UNUSED = 0
FDB_TSL_PRE_WRITE = 1
FDB_TSL_WRITE = 2
FDB_TSL_USER_STATUS1 = 3
FDB_TSL_DELETED = 4
FDB_TSL_USER_STATUS2 = 5
FDB_TSL_STATUS_NUM = 6
# sqlite数据库操作结果
SQLITE_NO_ERR = 0
SQLITE_INSERT_FAILED = 1


# 扇区信息
class SectorHead:
    status = 0
    magic = 0
    start_time = 0
    end_info0_time = 0
    end_info0_index = 0
    end_info0_status = 0
    end_info1_time = 0
    end_info1_index = 0
    end_info1_status = 0
    reserved = 0


# 扇区数据
class SectorData:
    status = 0
    timestamp = 0
    len = 0
    value = 0


# 计算扇区与数据的当前状态处理函数
def get_status(status_table, status_num):
    i = 0
    status_num_bak = --status_num

    while status_num:
        status_num = status_num - 1
        if FDB_WRITE_GRAN == 1:
            if (status_table[int(status_num / 8)] & (0x80 >> (status_num % 8))) == 0x00:
                break
        else:  # (FDB_WRITE_GRAN == 8) ||  (FDB_WRITE_GRAN == 32) ||  (FDB_WRITE_GRAN == 64)
            if status_table[status_num * FDB_WRITE_GRAN / 8] == 0x00:
                break

        i = i + 1
    return status_num_bak - i


# 解析tsdb的扇区信息
def sector_head_analysis(sector_data):
    head = SectorHead()
    head_format = "4sIIII4sII4sI"
    head_data = sector_data[0:SECTOR_HDR_DATA_SIZE]
    # 解析hdr数据
    hdr_unpack = struct.unpack(head_format, head_data)
    # 组装hdr信息
    head.status = get_status(hdr_unpack[0], FDB_TSL_STATUS_NUM)
    head.magic = hdr_unpack[1]
    head.start_time = hdr_unpack[2]
    head.end_info0_time = hdr_unpack[3]
    head.end_info0_index = hdr_unpack[4]
    head.end_info0_status = get_status(hdr_unpack[5], FDB_TSL_STATUS_NUM)
    head.end_info1_time = hdr_unpack[6]
    head.end_info1_index = hdr_unpack[7]
    head.end_info1_status = get_status(hdr_unpack[8], FDB_TSL_STATUS_NUM)
    head.reserved = hdr_unpack[9]
    # 调试输出hdr信息
    logging.debug("head.status           = %x" % head.status)
    logging.debug("head.end_info0_status = %x" % head.end_info0_status)
    logging.debug("head.end_info1_status = %x" % head.end_info1_status)
    # 返回数据
    return head;


# 解析tsdb的数据信息
def sector_data_analysis(sector_data, DataList):
    data_format = "4sIII"
    data_index = SECTOR_HDR_DATA_SIZE
    data_addr = 0;

    while (data_index + LOG_IDX_DATA_SIZE) < len(sector_data):
        # 遍历扇区的数据
        data = sector_data[data_index: data_index + LOG_IDX_DATA_SIZE]
        data_index = data_index + LOG_IDX_DATA_SIZE
        # 解析log的结构体
        data_unpack = struct.unpack(data_format, data)
        # 读取数据状态信息
        data_status = get_status(data_unpack[0], FDB_TSL_STATUS_NUM)
        # 如果数据不为 FDB_TSL_PRE_WRITE 与 FDB_TSL_DELETED 状态，则读取数据，推送数据至缓冲区
        if data_status != FDB_TSL_UNUSED and data_status != FDB_TSL_PRE_WRITE:
            # 遍历输出日志的结构信息
            data = SectorData()
            data.status = data_status
            data.timestamp = data_unpack[1]
            data.len = data_unpack[2]
            data_addr = data_unpack[3]
            if data_addr > SECTOR_DATA_SIZE:
                data_addr = (data_addr % SECTOR_DATA_SIZE)
            data.value = sector_data[data_addr: (data_unpack[2] + data_addr)]
            # 数据推送至数据缓冲区
            DataList.append(data)
        else:
            break


# 查找指定路径下含有 fdb 符号的文件
def find_file(path):
    # 遍历该路径下所有带有fdb关键字的文件
    for root, ds, fs in os.walk(path):
        for f in fs:
            if re.match(r'.*fdb.*', f):
                fullname = os.path.join(root, f)
                yield fullname


# sqlite 数据库插入数据处理函数
def sqlite_insert(sqlite, DataList, table_name):
    connect = None
    try:
        # 连接数据库
        connect = sqlite3.connect(sqlite)
        cur = connect.cursor()
        # 创建表
        sql = "CREATE TABLE IF NOT EXISTS {}(timestamp INTEGER PRIMARY KEY, status INTEGER, len INTEGER, value BLOB)".format(table_name)
        # 开启游标
        cur.execute(sql)
        # 遍历tsdb的数据
        while len(DataList):
            # 取出第一个数据
            tsl = DataList.pop(0)
            # 调试数据缓冲区内的数据
            logging.info("tsl.time   = %d" % tsl.timestamp)
            logging.info("tsl.status = %d" % tsl.status)
            logging.info("tsl.len    = %d" % tsl.len)
            logging.info("tsl.data   = %s" % json.dumps((ubjson.loadb(tsl.value))))
            # 添加数据，将 value 从 ubjson 转为 JSON 格式，方便上层应用访问
            cur.execute("INSERT OR IGNORE INTO {} values(?, ?, ?, ?)".format(table_name), (tsl.timestamp, tsl.status, tsl.len, json.dumps((ubjson.loadb(tsl.value)))))
        # 提交数据库
        connect.commit()
        # 关闭游标
        cur.close()
        # 断开数据库连接
        connect.close()
        # 插入数据成功
        return SQLITE_NO_ERR
    except Exception as error:
        # 捕获到异常后执行的代码
        logging.error(error)
        if connect is None:
            # 数据库连接失败
            return
        # 触发异常数据回滚
        connect.rollback()
        # 关闭游标
        cur.close()
        # 断开数据库连接
        connect.close()
        
        # 返回插入数据失败
        return SQLITE_INSERT_FAILED


# sqlite数据库删除表操作函数
def drop_sqlite_table(sqlite, sqlite_drop_table_failed, sqlite_drop_table_finish):
    try:
        # 连接数据库
        connect = sqlite3.connect(sqlite)
        cur = connect.cursor()
        #   删除整张表
        sql = "DROP TABLE tsdb if exist"
        # 开启游标
        cur.execute(sql)
        # 提交数据库
        connect.commit()
        # 关闭游标
        cur.close()
        # 断开数据库连接
        connect.close()
        # 执行删除完成回调函数
        if sqlite_drop_table_finish is not None:
            sqlite_drop_table_finish()
        # 插入数据成功
        return SQLITE_NO_ERR
    except Exception as error:
        # 触发异常数据回滚
        connect.rollback()
        # 关闭游标
        cur.close()
        # 断开数据库连接
        connect.close()
        # 执行删除失败回调函数
        if sqlite_drop_table_failed is not None:
            sqlite_drop_table_failed()
        # 捕获到异常后执行的代码
        logging.warning(error)
        # 返回插入数据失败
        return SQLITE_INSERT_FAILED


# sqlite数据库删除数据处理函数
def delete_sqlite_data(sqlite, timestamp, sqlite_delete_data_failed, sqlite_delete_data_finish):
    try:
        # 连接数据库
        connect = sqlite3.connect(sqlite)
        cur = connect.cursor()
        #   删除整张表
        sql = "DELETE FROM tsdb WHERE timestamp = %d" % timestamp
        # 开启游标
        cur.execute(sql)
        # 提交数据库
        connect.commit()
        # 关闭游标
        cur.close()
        # 断开数据库连接
        connect.close()
        # 执行删除完成回调函数
        if sqlite_delete_data_finish is not None:
            sqlite_delete_data_finish()
        # 插入数据成功
        return SQLITE_NO_ERR
    except Exception as error:
        # 触发异常数据回滚
        connect.rollback()
        # 关闭游标
        cur.close()
        # 断开数据库连接
        connect.close()
        # 执行删除失败回调函数
        if sqlite_delete_data_failed is not None:
            sqlite_delete_data_failed()
        # 捕获到异常后执行的代码
        logging.warning(error)
        # 返回插入数据失败
        return SQLITE_INSERT_FAILED


# tsdb 数据库转换至sqlite数据库处理函数
def trans_to_sqlite(tsdb_path,
                    sqlite,
                    table_name,
                    tsdb_read_failed=None,
                    tsdb_read_finish=None,
                    sqlite_insert_failed=None,
                    sqlite_insert_finish=None):
    # 用于标识是否发现了tsdb数据库
    find_tsdb = False
    # 数据缓冲区
    DataList = []

    # 遍历文件路径，查找对应的数据库文件
    for file_name in find_file(tsdb_path):
        logging.info("tsdb file: %s", file_name)
        # 打开文件
        fd = open(file=file_name, mode='rb')
        # 读取数据
        data = fd.read()
        # 判断读取数据长度是否符合要求
        if (len(data) >= SECTOR_DATA_SIZE):
            sector = sector_head_analysis(data)
            # 如果扇区为TSL扇区
            if sector.magic == SECTOR_MAGIC_WORD:
                # 如果此扇区状态为 FDB_SECTOR_STORE_USING 或者 FDB_SECTOR_STORE_FULL 则读取扇区数据
                if sector.status == FDB_SECTOR_STORE_USING or sector.status == FDB_SECTOR_STORE_FULL:
                    # 数据库为使用状态或者为存满状态，则读取数据
                    sector_data_analysis(data, DataList)
                # 设置已经找到了tsdb
                find_tsdb = True
            else:
                logging.warning("file:%s type is not TSDB file!" % file_name);
        else:
            logging.warning("file:%s size is not enough %d bytes!" % (file_name, SECTOR_DATA_SIZE));
        # 关闭文件
        fd.close()
    # 判断如果找到了tsdb
    if find_tsdb:
        # tsdb文件分析完成,执行回调处理函数
        if tsdb_read_finish is not None:
            tsdb_read_finish(DataList)

        # 在此处执行数据库的插入操作
        if sqlite is not None:
            sqlite_res = sqlite_insert(sqlite, DataList, table_name)
            if sqlite_res is not SQLITE_NO_ERR:
                logging.warning("sqlite insert failed: %s(%d).", sqlite, sqlite_res)
                if sqlite_insert_failed is not None:
                    sqlite_insert_failed()
            else:
                # sqlite数据库插入完成，执行回调处理函数
                logging.info("sqlite insert success: %s.", sqlite)
                if sqlite_insert_finish is not None:
                    sqlite_insert_finish()
        else:
            logging.warning("tsdb to sqlite failed, not specify sqlite file.")
            if sqlite_insert_failed is not None:
                sqlite_insert_failed()
    else:
        logging.warning("tsdb to sqlite failed, not find tsdb file: %s.", tsdb_path)
        if tsdb_read_failed is not None:
            tsdb_read_failed()
