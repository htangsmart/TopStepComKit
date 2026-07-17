# from wearable.file import *
# import os
# import random
# import time
# from wearable.file import file_cb
# from wearable import json_lpc

# LOG_LVL = logging.INFO
# LOG_TAG = 'persimwear.testcase'
# logger = logging.getLogger(LOG_TAG)
# logger.setLevel(LOG_LVL)

# PUSH_LOG_PATH = ''
# PULL_LOG_PATH = ''


# def testcase_push_pull_file(input):
#     local_push_dir = input["push_local"]
#     local_pull_dir = input["pull_local"]
#     remote_path = input["remote"]
#     test_times = input["test_times"]
#     file_max_size = input["file_max_size"]
#     if not os.path.exists(local_push_dir):
#         os.makedirs(local_push_dir)
#     if not os.path.exists(local_pull_dir):
#         os.makedirs(local_pull_dir)
#     success_test_times = 0
#     failed_test_times = 0
#     start_time = time.asctime(time.localtime(time.time()))
#     logger.info("test case start time: {}".format(start_time))
#     while True:
#         # 生成 push 文件
#         file_size = random.randint(0, file_max_size)
#         uuid_str = time.strftime("%Y-%m-%d_%H%M%S", time.localtime())
#         tmp_file_name = 'push_{}'.format(uuid_str)
#         push_local_path = os.path.join(local_push_dir, tmp_file_name)
#         alphabet = 'abcdefghijklmnopqrstuvwxyz!@#$%^&*()'
#         push_file_content = ''
#         with open(push_local_path, "w") as f:
#             # 生成不可压缩文件
#             if (success_test_times % 2) == 0:
#                 for i in range(file_size):
#                     push_file_content += random.choice(alphabet)
#                 f.write(push_file_content)
#             # 生成可压缩文件
#             else:
#                 f.write("0x00 " * file_size)
#         push_remote_path = remote_path + str(tmp_file_name)
#         pull_local_path = os.path.join(local_pull_dir, "pull_{}".format(uuid_str))

#         try:
#             push(push_local_path, push_remote_path, sync=False, callback=file_push_cb)
#             pull(pull_local_path, push_remote_path, sync=False, callback=file_pull_cb)
#         except Exception as e:
#             remove(push_remote_path)
#             end_time = time.asctime(time.localtime(time.time()))
#             logger.error("test times: {}, end_time: {}".format(success_test_times, end_time))
#             return json_lpc.gen_failed_output_json(e)

#         with open(pull_local_path, "rb") as f:
#             pull_file_content = f.read()
#         with open(push_local_path, "rb") as f:
#             push_file_content = f.read()

#         remove(push_remote_path)
#         os.remove(pull_local_path)
#         os.remove(push_local_path)
#         if push_file_content != pull_file_content:
#             failed_test_times += 1
#             logger.error("push pull test failed, test times: {}".format(failed_test_times))
#         else:
#             success_test_times += 1
#             logger.info("push pull test success, test times: {}".format(success_test_times))
#             time.sleep(0.5)
#         if success_test_times + failed_test_times >= test_times:
#             break

#     logger.info(
#         "success test times: {}, failed test times: {}, end_time: {}".format(success_test_times, failed_test_times,
#                                                                              time.asctime(time.localtime(time.time()))))
#     if failed_test_times > 0:
#         return json_lpc.gen_failed_output_json("push pull test failed")

#     return json_lpc.gen_success_output_json()


# def file_push_sync_cb(event, status, path, start_time, cur_size, total_size):
#     with open(PUSH_LOG_PATH, "a+") as f:
#         f.write(str(event))
#     return file_cb('file.sync.trans', status, event, path, start_time, cur_size, total_size)


# def file_push_cb(event, status, path, start_time, cur_size, total_size):
#     with open(PUSH_LOG_PATH, "a+") as f:
#         f.write(str(event))
#     return file_cb('file.trans', status, event, path, start_time, cur_size, total_size)


# def file_pull_sync_cb(event, status, path, start_time, cur_size, total_size):
#     with open(PULL_LOG_PATH, "a+") as f:
#         f.write(str(event))
#     return file_cb('file.sync.trans', status, event, path, start_time, cur_size, total_size)


# def file_pull_cb(event, status, path, start_time, cur_size, total_size):
#     with open(PULL_LOG_PATH, "a+") as f:
#         f.write(str(event))
#     return file_cb('file.trans', status, event, path, start_time, cur_size, total_size)


# def testcase_push_pull_sync_file(input):
#     local_push_dir = input["push_local"]
#     local_pull_dir = input["pull_local"]
#     remote_path = input["remote"]
#     test_times = input["test_times"]
#     file_max_size = input["file_max_size"]
#     logger.info("test_times: {}".format(input["test_times"]))
#     if not os.path.exists(local_push_dir):
#         os.makedirs(local_push_dir)
#     if not os.path.exists(local_pull_dir):
#         os.makedirs(local_pull_dir)
#     success_test_times = 0
#     start_time = time.asctime(time.localtime(time.time()))
#     logger.info("test case start time: {}".format(start_time))
#     while True:
#         # 生成 push 文件
#         file_size = random.randint(0, file_max_size)
#         uuid_str = time.strftime("%Y-%m-%d_%H%M%S", time.localtime())
#         tmp_file_name = 'push_{}'.format(uuid_str)
#         push_local_path = os.path.join(local_push_dir, tmp_file_name)
#         alphabet = 'abcdefghijklmnopqrstuvwxyz!@#$%^&*()'
#         push_file_content = ''
#         for i in range(file_size):
#             push_file_content += random.choice(alphabet)
#         with open(push_local_path, "w") as f:
#             f.write(push_file_content)
#         push_remote_path = remote_path + str(tmp_file_name)
#         pull_local_path = os.path.join(local_pull_dir, "pull_{}".format(uuid_str))
#         global PUSH_LOG_PATH
#         PUSH_LOG_PATH = os.path.join(local_push_dir, "push.log")
#         global PULL_LOG_PATH
#         PULL_LOG_PATH = os.path.join(local_push_dir, "push.log")
#         if os.path.exists(PUSH_LOG_PATH):
#             os.remove(PUSH_LOG_PATH)
#         if os.path.exists(PULL_LOG_PATH):
#             os.remove(PUSH_LOG_PATH)
#         push_sync_result = True
#         pull_sync_result = True
#         try:
#             # push file to remote
#             with open(PUSH_LOG_PATH, "w") as f:
#                 f.write("push sync test log:\n")
#             push(push_local_path, push_remote_path, sync=False, callback=file_push_cb)
#             # push sync file
#             push(push_local_path, push_remote_path, sync=True, callback=file_push_sync_cb)

#             with open(PULL_LOG_PATH, "w") as f:
#                 f.write("pull sync test log:\n")
#             pull(pull_local_path, push_remote_path, sync=False, callback=file_pull_cb)
#             pull(pull_local_path, push_remote_path, sync=True, callback=file_pull_sync_cb)
#         except Exception as e:
#             remove(push_remote_path)
#             end_time = time.asctime(time.localtime(time.time()))
#             logger.error("test times: {}, end_time: {}".format(success_test_times, end_time))
#             return json_lpc.gen_failed_output_json(e)

#         with open(pull_local_path, "rb") as f:
#             pull_file_content = f.read()
#         with open(push_local_path, "rb") as f:
#             push_file_content = f.read()
#         with open(PUSH_LOG_PATH, "r") as f:
#             log = f.read()
#         # this synchronization fails.
#         if "onSuccess" not in log:
#             push_sync_result = False
#             logger.error("push sync file failed")
#         with open(PULL_LOG_PATH, "r") as f:
#             log = f.read()
#         if "onSuccess" not in log:
#             pull_sync_result = False
#             logger.error("pull sync file failed")

#         remove(push_remote_path)
#         os.remove(pull_local_path)
#         os.remove(push_local_path)

#         if push_file_content == pull_file_content and pull_sync_result and push_sync_result:
#             success_test_times += 1
#             logger.info("push pull sync test success, test_times: {}, current time: {}, file_size: {}".
#                         format(success_test_times, time.asctime(time.localtime(time.time())), file_size))
#         else:
#             if push_file_content != pull_file_content:
#                 logger.error("push and pull file content not equal")
#             remove(push_remote_path)
#             logger.info("push pull sync test failed, test_times: {}, current time: {}, file_size: {}".
#                         format(success_test_times, time.asctime(time.localtime(time.time())), file_size))
#             return json_lpc.gen_failed_output_json("push pull test failed")

#         if success_test_times >= test_times:
#             break

#     end_time = time.asctime(time.localtime(time.time()))
#     logger.debug("test times: {}, end_time: {}".format(success_test_times, end_time))
#     return json_lpc.gen_success_output_json()


# def testcase_push_sync_file(input):
#     local_push_dir = input["push_local"]
#     remote_path = input["remote"]
#     test_times = input["test_times"]
#     file_max_size = input["file_max_size"]
#     logger.info("test_times: {}".format(input["test_times"]))
#     if not os.path.exists(local_push_dir):
#         os.makedirs(local_push_dir)
#     success_test_times = 0
#     start_time = time.asctime(time.localtime(time.time()))
#     logger.info("test case start time: {}".format(start_time))
#     while True:
#         # 生成 push 文件
#         file_size = random.randint(0, file_max_size)
#         uuid_str = time.strftime("%Y-%m-%d_%H%M%S", time.localtime())
#         tmp_file_name = 'push_{}'.format(uuid_str)
#         push_local_path = os.path.join(local_push_dir, tmp_file_name)
#         alphabet = 'abcdefghijklmnopqrstuvwxyz!@#$%^&*()'
#         push_file_content = ''
#         for i in range(file_size):
#             push_file_content += random.choice(alphabet)
#         with open(push_local_path, "w") as f:
#             f.write(push_file_content)
#         push_remote_path = remote_path + str(tmp_file_name)
#         global PUSH_LOG_PATH
#         PUSH_LOG_PATH = os.path.join(local_push_dir, "push.log")
#         global PULL_LOG_PATH
#         PULL_LOG_PATH = os.path.join(local_push_dir, "push.log")
#         if os.path.exists(PUSH_LOG_PATH):
#             os.remove(PUSH_LOG_PATH)
#         if os.path.exists(PULL_LOG_PATH):
#             os.remove(PUSH_LOG_PATH)
#         push_sync_result = True
#         push_sync_time_spent = 0
#         pull_sync_time_spent = 0
#         try:
#             # push file to remote
#             with open(PUSH_LOG_PATH, "w") as f:
#                 f.write("push sync test log:\n")

#             push(push_local_path, push_remote_path, sync=False, callback=file_push_cb)
#             # push sync file
#             push_sync_time_spent = time.time()
#             push(push_local_path, push_remote_path, sync=True, callback=file_push_sync_cb)
#             push_sync_time_spent = time.time() - push_sync_time_spent

#             # pull sync 模式暂未实现
#             # with open(PULL_LOG_PATH, "w") as f:
#             #     f.write("pull sync test log:\n")
#             # pull_sync_time_spent = time.time()
#             # pull(push_local_path, push_remote_path, sync=True, callback=file_pull_sync_cb)
#             # pull_sync_time_spent = time.time() - pull_sync_time_spent
#         except Exception as e:
#             logger.error(e)
#             logger.error(traceback.format_exc())
#             remove(push_remote_path)
#             end_time = time.asctime(time.localtime(time.time()))
#             logger.error("test times: {}, end_time: {}".format(success_test_times, end_time))
#             return json_lpc.gen_failed_output_json(e)

#         # this synchronization fails.
#         with open(PUSH_LOG_PATH, "r") as f:
#             log = f.read()
#         if "onSuccess" not in log:
#             push_sync_result = False
#             logger.error("push sync file failed")
#         # pull sync 模式暂未实现
#         # with open(PULL_LOG_PATH, "r") as f:
#         #     log = f.read()
#         # if "onSuccess" not in log:
#         #     pull_sync_result = False
#         #     logger.error("pull sync file failed")

#         if push_sync_time_spent > 20 or pull_sync_time_spent > 20:
#             push_sync_result = False
#             # pull sync 和 push sync 消耗时间过长，说明远端与本地文件不一致，测试失败
#             logger.error("push failed, sync push is spent more time: %d", push_sync_time_spent)

#         remove(push_remote_path)
#         os.remove(push_local_path)

#         if push_sync_result:
#             success_test_times += 1
#             logger.info("push sync test success, test_times: {}, current time: {}, file_size: {}".
#                         format(success_test_times, time.asctime(time.localtime(time.time())), file_size))
#         else:
#             remove(push_remote_path)
#             logger.info("push sync test failed, test_times: {}, current time: {}, file_size: {}".
#                         format(success_test_times, time.asctime(time.localtime(time.time())), file_size))
#             return json_lpc.gen_failed_output_json("push pull test failed")

#         if success_test_times >= test_times:
#             break

#     end_time = time.asctime(time.localtime(time.time()))
#     logger.debug("test times: {}, end_time: {}".format(success_test_times, end_time))
#     return json_lpc.gen_success_output_json()

