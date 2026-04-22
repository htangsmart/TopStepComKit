
/* 测量心率图表数据表 */
CREATE TABLE IF NOT EXISTS TSHeartRateTable (
    ID                  INTEGER PRIMARY KEY AUTOINCREMENT,  /* 数据ID */
    userID              TEXT NOT NULL,                      /* 用户ID */
    macAddress          TEXT NOT NULL,                      /* 设备mac地址(设备ID) */
    
    startTime           DOUBLE,                             /* 开始时间戳 */
    startTimeStr        TEXT,                               /* 开始时间字符串 YYYY-MM-DD HH:MM:SS */
    endTime             DOUBLE,                             /* 结束时间戳 */
    duration            INT,                                /* 持续时间 */

    dayStartStr         TEXT,                               /* 日期字符串 YYYY-MM-DD */
    dayStartTime        DOUBLE,                             /* 当天0点时间戳 */

    isUserInitiated     BOOL,                               /* 是否是主动测量 */
    valueType           INT,                                /* 数值类型：0普通数据，1最大值，2最小值，3静息心率 */
    value               INT,                                /* 心率数据心率值(次/分钟) */
    UNIQUE(userID, macAddress, startTime, isUserInitiated, valueType)  /* 联合唯一约束 */
);

/* 血氧饱和度数据表 */
CREATE TABLE IF NOT EXISTS TSOxySaturationTable (
    ID                  INTEGER PRIMARY KEY AUTOINCREMENT,  /* 数据ID */
    userID              TEXT NOT NULL,                      /* 用户ID */
    macAddress          TEXT NOT NULL,                      /* 设备mac地址(设备ID) */
    
    startTime           DOUBLE,                             /* 开始时间戳 */
    startTimeStr        TEXT,                               /* 开始时间字符串 YYYY-MM-DD HH:MM:SS */
    endTime             DOUBLE,                             /* 结束时间戳 */
    duration            INT,                                /* 持续时间 */

    dayStartStr         TEXT,                               /* 日期字符串 YYYY-MM-DD */
    dayStartTime        DOUBLE,                             /* 当天0点时间戳 */

    isUserInitiated     BOOL,                               /* 是否是主动测量 */
    valueType            INT,                               /* 数值类型：0普通数据，1最大值，2最小值 */
    value               INT,                                /* 血氧饱和度图表数据 */
    UNIQUE(userID, macAddress, startTime, isUserInitiated, valueType)  /* 联合唯一约束 */
);

/* 血压图表数据表 */
CREATE TABLE IF NOT EXISTS TSBloodPressureTable (
    ID                  INTEGER PRIMARY KEY AUTOINCREMENT,  /* 数据ID */
    userID              TEXT NOT NULL,                      /* 用户ID */
    macAddress          TEXT NOT NULL,                      /* 设备mac地址(设备ID) */

    startTime           DOUBLE,                             /* 开始时间戳 */
    startTimeStr        TEXT,                               /* 开始时间字符串 YYYY-MM-DD HH:MM:SS */
    endTime             DOUBLE,                             /* 结束时间戳 */
    duration            INT,                                /* 持续时间 */

    dayStartStr         TEXT,                               /* 日期字符串 YYYY-MM-DD */
    dayStartTime        DOUBLE,                             /* 当天0点时间戳 */

    isUserInitiated     BOOL,                               /* 是否是主动测量 */
    valueType            INT,                               /* 数值类型：0普通数据，1最大值，2最小值 */
    sbp                 INT,                                /* 收缩压 */
    dbp                 INT,                                /* 舒张压 */
    UNIQUE(userID, macAddress, startTime, isUserInitiated, valueType)  /* 联合唯一约束 */
);


/* 压力图表数据表 */
CREATE TABLE IF NOT EXISTS TSHealthStressTable (
    ID                  INTEGER PRIMARY KEY AUTOINCREMENT,  /* 数据ID */
    userID              TEXT NOT NULL,                      /* 用户ID */
    macAddress          TEXT NOT NULL,                      /* 设备mac地址(设备ID) */
    
    startTime           DOUBLE,                             /* 开始时间戳 */
    startTimeStr        TEXT,                               /* 开始时间字符串 YYYY-MM-DD HH:MM:SS */
    endTime             DOUBLE,                             /* 结束时间戳 */
    duration            INT,                                /* 持续时间 */

    dayStartStr         TEXT,                               /* 日期字符串 YYYY-MM-DD */
    dayStartTime        DOUBLE,                             /* 当天0点时间戳 */

    isUserInitiated     BOOL,                               /* 是否是主动测量 */
    valueType            INT,                               /* 数值类型：0普通数据，1最大值，2最小值 */
    value               INT,                                /* 压力图表数据 */
    UNIQUE(userID, macAddress, startTime, isUserInitiated, valueType)  /* 联合唯一约束 */
);


/* 睡眠数据表 */
CREATE TABLE IF NOT EXISTS TSSleepTable (
    ID                  INTEGER PRIMARY KEY AUTOINCREMENT,  /* 数据ID */
    userID              TEXT NOT NULL,                      /* 用户ID */
    macAddress          TEXT NOT NULL,                      /* 设备mac地址(设备ID) */

    startTime           DOUBLE,                             /* 开始时间戳 */
    startTimeStr        TEXT,                               /* 开始时间字符串 YYYY-MM-DD HH:MM:SS */
    endTime             DOUBLE,                             /* 结束时间戳 */
    duration            INT,                                /* 持续时间 */

    belongingDate       DOUBLE,                             /* 当天0点时间戳 */
    sleepStage          INT,                                /* 睡眠阶段类型 参考 TSSleepStageType */
    UNIQUE(userID, macAddress, startTime, duration)         /* 联合唯一约束 */
);


/* 每日活动数据表 */
CREATE TABLE IF NOT EXISTS TSDailyExerciseTable (
    ID                  INTEGER PRIMARY KEY AUTOINCREMENT,  /* 数据ID */
    userID              TEXT NOT NULL,                      /* 用户ID */
    macAddress          TEXT NOT NULL,                      /* 设备mac地址(设备ID) */

    startTime           DOUBLE,                             /* 开始时间戳 */
    startTimeStr        TEXT,                               /* 开始时间字符串 YYYY-MM-DD HH:MM:SS */
    endTime             DOUBLE,                             /* 结束时间戳 */
    duration            INT,                                /* 持续时间 */

    dayStartStr         TEXT,                               /* 日期字符串 YYYY-MM-DD */
    dayStartTime        DOUBLE,                             /* 当天0点时间戳 */

    steps               INT,                                /* 总步数 */
    calories            INT,                                /* 卡路里(小卡) */
    distance            INT,                                /* 距离(米) */

    exercisesDuration   INT,                                /* 运动时长(分钟) */
    exercisesTimes      INT,                                /* 运动次数(次) */
    
    activityDuration    INT,                                /* 活动时长(分钟) */
    activityTimes       INT,                                /* 活动次数(次) */

    UNIQUE(userID, macAddress, startTime)                   /* 联合唯一约束 */
);


/* 运动记录表 */
CREATE TABLE IF NOT EXISTS TSSportRecordTable (
    ID                  INTEGER PRIMARY KEY AUTOINCREMENT,  /* 数据ID */
    userID              TEXT NOT NULL,                      /* 用户ID */
    macAddress          TEXT NOT NULL,                      /* 设备mac地址(设备ID) */
    sportID             DOUBLE NOT NULL,                    /* 运动记录ID(时间戳) */
   
    startTime           DOUBLE,                             /* 开始时间戳 */
    startTimeStr        TEXT,                               /* 开始时间字符串 YYYY-MM-DD HH:MM:SS */
    endTime             DOUBLE,                             /* 结束时间戳 */
    duration            INT,                                /* 持续时间 */

    dayStartStr         TEXT,                               /* 日期字符串 YYYY-MM-DD */
    dayStartTime        DOUBLE,                             /* 当天0点时间戳 */

    type                INT,                                /* 运动类型 */
    steps               INT,                                /* 步数(步) */
    distance            INT,                                /* 距离(米) */
    calorie             INT,                                /* 热量(小卡) */
    
    maxHrValue          INT,                                /* 最大心率 */
    minHrValue          INT,                                /* 最小心率 */
    avgHrValue          INT,                                /* 平均心率 */
    
    minPace             FLOAT,                              /* 最小配速(s/km) */
    maxPace             FLOAT,                              /* 最大配速(s/km) */
    avgPace             FLOAT,                              /* 平均配速(s/km) */

    minCadence          FLOAT,                              /* 最小步频(步/min) */
    maxCadence          FLOAT,                              /* 最大步频(步/min) */
    avgCadence          FLOAT,                              /* 平均步频(步/min) */

    maxSpeed            FLOAT,                              /* 最大速度(m/s) */
    minSpeed            FLOAT,                              /* 最小速度(m/s) */
    avgSpeed            FLOAT,                              /* 平均速度(m/s) */

    warmHrDuration      INT,                                /* 热身心率持续时间(秒) */
    fatBurnHrDuration   INT,                                /* 燃脂心率持续时间(秒) */
    aerobicHrDuration   INT,                                /* 有氧心率持续时间(秒) */
    anaerobicHrDuration INT,                                /* 无氧心率持续时间(秒) */
    extremeHrDuration   INT,                                /* 极限心率持续时间(秒) */
    
    warmHrRatio         INT,                                /* 热身心率比例(%) */
    fatBurnHrRatio      INT,                                /* 燃脂心率比例(%) */
    aerobicHrRatio      INT,                                /* 有氧心率比例(%) */
    anaerobicHrRatio    INT,                                /* 无氧心率比例(%) */
    extremeHrRatio      INT,                                /* 极限心率比例(%) */
    
    displayConfigs      BLOB,                               /* 显示配置位图 */
    UNIQUE(userID, macAddress, sportID)                     /* 联合唯一约束 */
);

/* 运动详情条目表 */
CREATE TABLE IF NOT EXISTS TSSportDetailItemTable (
    ID                  INTEGER PRIMARY KEY AUTOINCREMENT,  /* 数据ID */
    userID              TEXT NOT NULL,                      /* 用户ID */
    macAddress          TEXT NOT NULL,                      /* 设备mac地址(设备ID) */
    sportID             DOUBLE NOT NULL,                    /* 运动记录ID(时间戳) */
   
    startTime           DOUBLE,                             /* 开始时间戳 */
    startTimeStr        TEXT,                               /* 开始时间字符串 YYYY-MM-DD HH:MM:SS */
    endTime             DOUBLE,                             /* 结束时间戳 */
    duration            INT,                                /* 持续时间 */

    dayStartStr         TEXT,                               /* 日期字符串 YYYY-MM-DD */
    dayStartTime        DOUBLE,                             /* 当天0点时间戳 */

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
    UNIQUE(userID, macAddress, sportID, startTime)          /* 联合唯一约束 */
);


/* 运动心率表 */
CREATE TABLE IF NOT EXISTS TSSportHeartRateTable (
    ID                  INTEGER PRIMARY KEY AUTOINCREMENT,  /* 数据ID */
    userID              TEXT NOT NULL,                      /* 用户ID */
    macAddress          TEXT NOT NULL,                      /* 设备mac地址(设备ID) */
    sportID             DOUBLE NOT NULL,                    /* 运动记录ID（时间戳） */

    startTime           DOUBLE,                             /* 开始时间戳 */
    startTimeStr        TEXT,                               /* 开始时间字符串 YYYY-MM-DD HH:MM:SS */
    endTime             DOUBLE,                             /* 结束时间戳 */
    duration            INT,                                /* 持续时间 */

    dayStartStr         TEXT,                               /* 日期字符串 YYYY-MM-DD */
    dayStartTime        DOUBLE,                             /* 当天0点时间戳 */

    value               INT,                                /* 心率值 */
    UNIQUE(userID, macAddress, sportID, startTime)          /* 联合唯一约束 */
);


/* 轨迹表 */
CREATE TABLE IF NOT EXISTS TSSportGPSItemTable (
    ID                  INTEGER PRIMARY KEY AUTOINCREMENT,  /* 数据ID */
    userID              TEXT NOT NULL,                      /* 用户ID */
    macAddress          TEXT NOT NULL,                      /* 设备mac地址(设备ID) */
    sportID             DOUBLE NOT NULL,                    /* 运动记录ID(时间戳) */
    type                INT,                                /* 运动类型 */

    startTime           DOUBLE,                             /* 开始时间戳 */
    startTimeStr        TEXT,                               /* 开始时间字符串 YYYY-MM-DD HH:MM:SS */
    endTime             DOUBLE,                             /* 结束时间戳 */
    duration            INT,                                /* 持续时间 */

    dayStartStr         TEXT,                               /* 日期字符串 YYYY-MM-DD */
    dayStartTime        DOUBLE,                             /* 当天0点时间戳 */
   
    longitude           DOUBLE,                             /* 经度 */
    latitude            DOUBLE,                             /* 纬度 */
    altitude            DOUBLE,                             /* 海拔 */
    satellitesCount     INT,                                /* 卫星数量 */
    UNIQUE(userID, macAddress, sportID, startTime)          /* 联合唯一约束 */
);

/* 连接设备存储表 */
CREATE TABLE IF NOT EXISTS TSPeripheralTable (
    ID                  INTEGER PRIMARY KEY AUTOINCREMENT,  /* 数据ID */
    userID              TEXT NOT NULL,                      /* 用户ID */
    
    bleName             TEXT NOT NULL,                      /* 设备蓝牙名称 */
    macAddress          TEXT NOT NULL,                      /* 设备mac地址 */
    uuidString          TEXT NOT NULL,                      /* 设备UUIDString */
    
    projectId           TEXT NOT NULL,                      /* 设备项目号 */
    firmVersion         TEXT NOT NULL,                      /* 设备固件版本号 */

    isConnected         BOOL,                               /* 绑定类型（1 绑定，0解绑）*/
    connectTime         DOUBLE,                             /* 绑定成功时间戳 */
    formatConnectTime   TEXT NOT NULL,                      /* 绑定成功时间 */

    UNIQUE(userID, macAddress )                             /* 联合唯一约束 */
);

/* 连接历史记录存储表 */
CREATE TABLE IF NOT EXISTS TSConnectHistoryTable (
    ID                  INTEGER PRIMARY KEY AUTOINCREMENT,  /* 数据ID */
    userID              TEXT NOT NULL,                      /* 用户ID */
    macAddress          TEXT NOT NULL,                      /* 设备mac地址 */
    
    bleName             TEXT,                                /* 设备蓝牙名称 */
    uuidString          TEXT,                                /* 设备UUIDString */
    projectId           TEXT,                                /* 设备项目号 */
    firmVersion         TEXT,                                /* 设备固件版本号 */
    
    operationType       INT NOT NULL,                       /* 操作类型：1绑定，0解绑，2连接，3断开 */
    operationTime       DOUBLE,                             /* 操作时间戳 */
    formatOperationTime TEXT NOT NULL,                      /* 操作时间字符串 */
    operationResult     INT DEFAULT 1,                      /* 操作结果：1成功，0失败 */
    errorMessage        TEXT,                               /* 失败时的错误信息 */
    
    UNIQUE(userID, macAddress, operationTime,operationType) /* 防止重复记录 */
);

-- ========================================
-- 索引设计 - 支持高效查询
-- ========================================

-- 心率表索引
CREATE INDEX IF NOT EXISTS idx_heartrate_raw_time ON TSHeartRateTable(userID, macAddress, startTime);
CREATE INDEX IF NOT EXISTS idx_heartrate_daily ON TSHeartRateTable(userID, macAddress, dayStartStr);

-- 血氧表索引
CREATE INDEX IF NOT EXISTS idx_oxy_raw_time ON TSOxySaturationTable(userID, macAddress, startTime);
CREATE INDEX IF NOT EXISTS idx_oxy_daily ON TSOxySaturationTable(userID, macAddress, dayStartStr);

-- 血压表索引
CREATE INDEX IF NOT EXISTS idx_bp_raw_time ON TSBloodPressureTable(userID, macAddress, startTime);
CREATE INDEX IF NOT EXISTS idx_bp_daily ON TSBloodPressureTable(userID, macAddress, dayStartStr);

-- 压力表索引
CREATE INDEX IF NOT EXISTS idx_stress_raw_time ON TSHealthStressTable(userID, macAddress, startTime);
CREATE INDEX IF NOT EXISTS idx_stress_daily ON TSHealthStressTable(userID, macAddress, dayStartStr);

-- 睡眠表索引
CREATE INDEX IF NOT EXISTS idx_sleep_raw_time ON TSSleepTable(userID, macAddress, startTime);
CREATE INDEX IF NOT EXISTS idx_sleep_daily ON TSSleepTable(userID, macAddress, dayStartStr);

-- 每日活动表索引
CREATE INDEX IF NOT EXISTS idx_daily_raw_time ON TSDailyExerciseTable(userID, macAddress, startTime);
CREATE INDEX IF NOT EXISTS idx_daily_daily ON TSDailyExerciseTable(userID, macAddress, dayStartStr);

-- 运动记录表索引
CREATE INDEX IF NOT EXISTS idx_sport_raw_time ON TSSportRecordTable(userID, macAddress, startTime);
CREATE INDEX IF NOT EXISTS idx_sport_daily ON TSSportRecordTable(userID, macAddress, dayStartStr);

-- 运动详情表索引
CREATE INDEX IF NOT EXISTS idx_sport_detail_raw_time ON TSSportDetailItemTable(userID, macAddress, startTime);
CREATE INDEX IF NOT EXISTS idx_sport_detail_daily ON TSSportDetailItemTable(userID, macAddress, dayStartStr);

-- 运动心率表索引
CREATE INDEX IF NOT EXISTS idx_sport_hr_raw_time ON TSSportHeartRateTable(userID, macAddress, startTime);
CREATE INDEX IF NOT EXISTS idx_sport_hr_daily ON TSSportHeartRateTable(userID, macAddress, dayStartStr);

-- 轨迹表索引
CREATE INDEX IF NOT EXISTS idx_gps_raw_time ON TSSportGPSItemTable(userID, macAddress, startTime);
CREATE INDEX IF NOT EXISTS idx_gps_daily ON TSSportGPSItemTable(userID, macAddress, dayStartStr);


