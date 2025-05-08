
/* 测量心率图表数据表 */
CREATE TABLE IF NOT EXISTS TSHeartRateTable (
    ID                  INTEGER PRIMARY KEY AUTOINCREMENT,  /* 数据ID */
    userID              TEXT NOT NULL,                      /* 用户ID */
    macAddress          TEXT NOT NULL,                      /* 设备mac地址(设备ID) */
    
    startTime           DOUBLE,                             /* 开始时间戳 */
    endTime             DOUBLE,                             /* 结束时间戳 */
    duration            INT,                                /* 持续时间 */

    isUserInitiated     BOOL,                              /* 是否是主动测量 */
    value               INT,                                /* 心率数据心率值(次/分钟) */
    UNIQUE(userID, macAddress, startTime)                  /* 联合唯一约束 */
);

/* 血氧饱和度数据表 */
CREATE TABLE IF NOT EXISTS TSOxySaturationTable (
    ID                  INTEGER PRIMARY KEY AUTOINCREMENT,  /* 数据ID */
    userID              TEXT NOT NULL,                      /* 用户ID */
    macAddress          TEXT NOT NULL,                      /* 设备mac地址(设备ID) */
    
    startTime           DOUBLE,                             /* 开始时间戳 */
    endTime             DOUBLE,                             /* 结束时间戳 */
    duration            INT,                                /* 持续时间 */

    isUserInitiated     BOOL,                              /* 是否是主动测量 */
    value               INT,                                /* 血氧饱和度图表数据 */
    UNIQUE(userID, macAddress, startTime)                  /* 联合唯一约束 */
);

/* 血压图表数据表 */
CREATE TABLE IF NOT EXISTS TSBloodPressureTable (
    ID                  INTEGER PRIMARY KEY AUTOINCREMENT,  /* 数据ID */
    userID              TEXT NOT NULL,                      /* 用户ID */
    macAddress          TEXT NOT NULL,                      /* 设备mac地址(设备ID) */

    startTime           DOUBLE,                             /* 开始时间戳 */
    endTime             DOUBLE,                             /* 结束时间戳 */
    duration            INT,                                /* 持续时间 */

    isUserInitiated     BOOL,                              /* 是否是主动测量 */
    sbp                 INT,                                /* 收缩压 */
    dbp                 INT,                                /* 舒张压 */
    UNIQUE(userID, macAddress, startTime)                  /* 联合唯一约束 */
);


/* 压力图表数据表 */
CREATE TABLE IF NOT EXISTS TSHealthStressTable (
    ID                  INTEGER PRIMARY KEY AUTOINCREMENT,  /* 数据ID */
    userID              TEXT NOT NULL,                      /* 用户ID */
    macAddress          TEXT NOT NULL,                      /* 设备mac地址(设备ID) */
    
    startTime           DOUBLE,                             /* 开始时间戳 */
    endTime             DOUBLE,                             /* 结束时间戳 */
    duration            INT,                                /* 持续时间 */

    isUserInitiated     BOOL,                               /* 是否是主动测量 */
    value               INT,                                /* 压力图表数据 */
    UNIQUE(userID, macAddress, startTime)                   /* 联合唯一约束 */
);


/* 睡眠数据表 */
CREATE TABLE IF NOT EXISTS TSSleepTable (
    ID                  INTEGER PRIMARY KEY AUTOINCREMENT,  /* 数据ID */
    userID              TEXT NOT NULL,                      /* 用户ID */
    macAddress          TEXT NOT NULL,                      /* 设备mac地址(设备ID) */

    startTime           DOUBLE,                             /* 开始时间戳 */
    endTime             DOUBLE,                             /* 结束时间戳 */
    duration            INT,                                /* 持续时间 */

    dayStartTimestamp   DOUBLE,                             /* 睡眠属于哪一天，秒级时间戳，取那天的0时0分0秒 */
    sleepStageType      INT,                                /* 睡眠阶段类型 参考 TSSleepStageType */
    sleepPeriodType     INT,                                /* 睡眠周期类型 参考 TSSleepPeriodType */
    UNIQUE(userID, macAddress, startTime, duration)         /* 联合唯一约束 */
);


/* 每日活动数据表 */
CREATE TABLE IF NOT EXISTS TSDailyExerciseTable (
    ID                  INTEGER PRIMARY KEY AUTOINCREMENT,  /* 数据ID */
    userID              TEXT NOT NULL,                      /* 用户ID */
    macAddress          TEXT NOT NULL,                      /* 设备mac地址(设备ID) */

    startTime           DOUBLE,                             /* 开始时间戳 */
    endTime             DOUBLE,                             /* 结束时间戳 */
    duration            INT,                                /* 持续时间 */

    steps               INT,                                /* 总步数 */
    activityDuration    INT,                                /* 活动时长(分钟) */
    exercisesDuration   INT,                                /* 运动时长(分钟) */
    exercisesNum        INT,                                /* 运动次数(次) */
    calories            INT,                                /* 卡路里(小卡) */
    distance            INT,                                /* 距离(米) */

    UNIQUE(userID, macAddress, startTime)                   /* 联合唯一约束 */
);


/* 运动记录表 */
CREATE TABLE IF NOT EXISTS TSSportRecordTable (
    ID                  INTEGER PRIMARY KEY AUTOINCREMENT,  /* 数据ID */
    userID              TEXT NOT NULL,                      /* 用户ID */
    macAddress          TEXT NOT NULL,                      /* 设备mac地址(设备ID) */
    sportID             LONG NOT NULL,                      /* 运动记录ID(时间戳) */
   
    startTime           DOUBLE,                             /* 开始时间戳 */
    endTime             DOUBLE,                             /* 结束时间戳 */
    duration            INT,                                /* 持续时间 */

    type                INT,                                /* 运动类型 */
    steps               INT,                                /* 步数(步) */
    distance            INT,                                /* 距离(米) */
    calorie             INT,                                /* 热量(小卡) */
    
    maxHrValue          INT,                                /* 最大心率 */
    minHrValue          INT,                                /* 最小心率 */
    avgHrValue          INT,                                /* 平均心率 */
    
    maxPace             FLOAT,                              /* 最大配速(min/km) */
    minPace             FLOAT,                              /* 最小配速(min/km) */
    avgPace             FLOAT,                              /* 平均配速(min/km) */

    maxSpeed            FLOAT,                              /* 最大速度(m/s) */
    minSpeed            FLOAT,                              /* 最小速度(m/s) */
    avgSpeed            FLOAT,                              /* 平均速度(m/s) */

    warmHrDuration      INT,                                /* 热身心率持续时间(秒) */
    fatBurnHrDuration   INT,                                /* 燃脂心率持续时间(秒) */
    aerobicHrDuration   INT,                                /* 有氧心率持续时间(秒) */
    anaerobicHrDuration INT,                                /* 无氧心率持续时间(秒) */
    ExtremeHrDuration   INT,                                /* 极限心率持续时间(秒) */
    
    warmHrRatio         INT,                                /* 热身心率比例(%) */
    fatBurnHrRatio      INT,                                /* 燃脂心率比例(%) */
    aerobicHrRatio      INT,                                /* 有氧心率比例(%) */
    anaerobicHrRatio    INT,                                /* 无氧心率比例(%) */
    ExtremeHrRatio      INT,                                /* 极限心率比例(%) */
    UNIQUE(userID, macAddress, sportID)                    /* 联合唯一约束 */
);

/* 运动详情条目表 */
CREATE TABLE IF NOT EXISTS TSSportDetailItemTable (
    ID                  INTEGER PRIMARY KEY AUTOINCREMENT,  /* 数据ID */
    userID              TEXT NOT NULL,                      /* 用户ID */
    macAddress          TEXT NOT NULL,                      /* 设备mac地址(设备ID) */
    sportID             LONG NOT NULL,                      /* 运动记录ID(时间戳) */
   
    startTime           DOUBLE,                             /* 开始时间戳 */
    endTime             DOUBLE,                             /* 结束时间戳 */
    duration            INT,                                /* 持续时间 */

    type                INT,                                /* 运动类型 */
    steps               INT,                                /* 步数 */
    distance            INT,                                /* 距离(米) */
    calorie             INT,                                /* 热量(小卡) */
    pace                FLOAT,                              /* 配速(min/km) */

    swimStyle           INT,                                /* 泳姿   1: 自由泳 2:蛙泳 3:仰泳 4:蝶泳 */
    swimLaps            INT,                                /* 游泳趟数 */
    swimStrokes         INT,                                /* 游泳划水次数 */
    swimStrokeFreq      INT,                                /* 游泳划水频率 */
    swolf               INT,                                /* 游泳效率 */
    
    jumpCount           INT,                                /* 跳绳-触发次数 */
    jumpBkCount         INT,                                /* 跳绳-中断次数 */
    jumpConsCount       INT,                                /* 跳绳-连续次数 */

    elCount             INT,                                /* 椭圆机-触发次数 */
    elFrequecy          INT,                                /* 椭圆机-触发频率 */
    elMaxFrequecy       INT,                                /* 椭圆机-最大触发频率 */
    elMinFrequecy       INT,                                /* 椭圆机-最小触发频率 */
    
    rowCount            INT,                                /* 划船机-触发次数 */
    rowFrequecy         INT,                                /* 划船机-触发频率 */
    rowMaxFrequecy      INT,                                /* 划船机-最大触发频率 */
    rowMinFrequecy      INT,                                /* 划船机-最小触发频率 */
    UNIQUE(userID, macAddress, sportID, startTime)         /* 联合唯一约束 */
);


/* 运动心率表 */
CREATE TABLE IF NOT EXISTS TSSportHeartRateTable (
    ID                  INTEGER PRIMARY KEY AUTOINCREMENT,  /* 数据ID */
    userID              TEXT NOT NULL,                      /* 用户ID */
    macAddress          TEXT NOT NULL,                      /* 设备mac地址(设备ID) */
    sportID             LONG NOT NULL,                      /* 运动记录ID（时间戳） */

    startTime           DOUBLE,                             /* 开始时间戳 */
    endTime             DOUBLE,                             /* 结束时间戳 */
    duration            INT,                                /* 持续时间 */

    value               INT,                                /* 心率值 */
    UNIQUE(userID, macAddress, sportID, startTime)         /* 联合唯一约束 */
);


/* 轨迹表 */
CREATE TABLE IF NOT EXISTS TSSportGPSItemTable (
    ID                  INTEGER PRIMARY KEY AUTOINCREMENT,  /* 数据ID */
    userID              TEXT NOT NULL,                      /* 用户ID */
    macAddress          TEXT NOT NULL,                      /* 设备mac地址(设备ID) */
    sportID             LONG NOT NULL,                      /* 运动记录ID(时间戳) */
    type                INT,                                /* 运动类型 */

    startTime           DOUBLE,                             /* 开始时间戳 */
    endTime             DOUBLE,                             /* 结束时间戳 */
    duration            INT,                                /* 持续时间 */
   
    longitude           DOUBLE,                             /* 经度 */
    latitude            DOUBLE,                             /* 纬度 */
    altitude            DOUBLE,                             /* 海拔 */
    satellitesCount     INT,                                /* 卫星数量 */
    UNIQUE(userID, macAddress, sportID, startTime)         /* 联合唯一约束 */
);




