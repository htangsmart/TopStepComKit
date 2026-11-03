const MOCK_DATA = {
    chatDetailData: {
        segmentAudioFiles: [
            ".aibuds/ai/audios/ai_chat/user199/2026-05-09_18-29-22/segments/2026-05-09_18-29-41.mp3",
            ".aibuds/ai/audios/ai_chat/user199/2026-05-09_18-29-22/segments/2026-05-09_18-29-59.mp3"
        ],
        autoEndSessionAfterNoInputDuration: 15,
        startTime: 1778322562.019936,
        segmentAudioFilesFormat: "MP3",
        events: [
            { timestamp: 1778322562.019936, timeSinceSessionStart: 0, eventId: "sessionStarted", description: "会话开始事件" },
            { timestamp: 1778322564.881645, timeSinceSessionStart: 2.86, eventId: "aiServiceConnected", description: "AI 服务成功连接" },
            { timestamp: 1778322581.9682798, timeSinceSessionStart: 19.95, eventId: "vadStartSpeaking", description: "VAD 检测到用户开始说话" },
            { timestamp: 1778322583.829165, timeSinceSessionStart: 21.81, eventId: "vadEndSpeaking", description: "VAD 检测到用户结束说话" },
            { timestamp: 1778322586.4190159, timeSinceSessionStart: 24.40, eventId: "aiRespondVoicePlaybackDidStart", description: "AI 响应语音播放开始" },
            { timestamp: 1778322599.715275, timeSinceSessionStart: 37.70, eventId: "vadStartSpeaking", description: "VAD 检测到用户开始说话" },
            { timestamp: 1778322600.965116, timeSinceSessionStart: 38.95, eventId: "vadEndSpeaking", description: "VAD 检测到用户结束说话" },
            { timestamp: 1778322600.9779248, timeSinceSessionStart: 38.96, eventId: "aiRespondVoicePlaybackDidStop", description: "AI 响应语音播放结束" },
            { timestamp: 1778322601.649606, timeSinceSessionStart: 39.63, eventId: "aiIntentReceived", description: "AI 意图已接收" },
            { timestamp: 1778322615.97922, timeSinceSessionStart: 53.96, eventId: "autoEndSessionTriggered", description: "自动结束会话被触发" },
            { timestamp: 1778322615.994957, timeSinceSessionStart: 53.98, eventId: "sessionEnded", description: "会话结束事件" }
        ],
        audioChannel: "Opus",
        maxPauseDurationBeforeAIResponds: 0.8,
        language: "zh-CN",
        endTime: 1778322615.994957,
        isVoicePlaybackEnabled: true,
        rawAudioFormat: "MP3",
        segmentAudioFilePaths: [
            "/var/mobile/Containers/Data/Application/E0736025-3E61-44D5-915F-0D780066344F/Documents/.aibuds/ai/audios/ai_chat/user199/2026-05-09_18-29-22/segments/2026-05-09_18-29-41.mp3",
            "/var/mobile/Containers/Data/Application/E0736025-3E61-44D5-915F-0D780066344F/Documents/.aibuds/ai/audios/ai_chat/user199/2026-05-09_18-29-22/segments/2026-05-09_18-29-59.mp3"
        ],
        duration: 53.97502088546753,
        hasVoiceForDebugging: false,
        rawAudioFile: "/var/mobile/Containers/Data/Application/E0736025-3E61-44D5-915F-0D780066344F/Documents/.aibuds/ai/audios/ai_chat/user199/2026-05-09_18-29-22/raw_audio.mp3"
    },
    chatData: [
        {
            segmentAudioFiles: [
                ".aibuds/ai/audios/ai_chat/user199/2026-05-09_18-29-22/segments/2026-05-09_18-29-41.mp3",
                ".aibuds/ai/audios/ai_chat/user199/2026-05-09_18-29-22/segments/2026-05-09_18-29-59.mp3"
            ],
            autoEndSessionAfterNoInputDuration: 15,
            startTime: 1778322562.019936,
            segmentAudioFilesFormat: "MP3",
            events: [
                { timestamp: 1778322562.019936, timeSinceSessionStart: 0, eventId: "sessionStarted", description: "会话开始事件" },
                { timestamp: 1778322564.881645, timeSinceSessionStart: 2.86, eventId: "aiServiceConnected", description: "AI 服务成功连接" },
                { timestamp: 1778322581.9682798, timeSinceSessionStart: 19.95, eventId: "vadStartSpeaking", description: "VAD 检测到用户开始说话" },
                { timestamp: 1778322583.829165, timeSinceSessionStart: 21.81, eventId: "vadEndSpeaking", description: "VAD 检测到用户结束说话" },
                { timestamp: 1778322586.4190159, timeSinceSessionStart: 24.40, eventId: "aiRespondVoicePlaybackDidStart", description: "AI 响应语音播放开始" },
                { timestamp: 1778322599.715275, timeSinceSessionStart: 37.70, eventId: "vadStartSpeaking", description: "VAD 检测到用户开始说话" },
                { timestamp: 1778322600.965116, timeSinceSessionStart: 38.95, eventId: "vadEndSpeaking", description: "VAD 检测到用户结束说话" },
                { timestamp: 1778322600.9779248, timeSinceSessionStart: 38.96, eventId: "aiRespondVoicePlaybackDidStop", description: "AI 响应语音播放结束" },
                { timestamp: 1778322601.649606, timeSinceSessionStart: 39.63, eventId: "aiIntentReceived", description: "AI 意图已接收" },
                { timestamp: 1778322615.97922, timeSinceSessionStart: 53.96, eventId: "autoEndSessionTriggered", description: "自动结束会话被触发" },
                { timestamp: 1778322615.994957, timeSinceSessionStart: 53.98, eventId: "sessionEnded", description: "会话结束事件" }
            ],
            audioChannel: "Opus",
            maxPauseDurationBeforeAIResponds: 0.8,
            language: "zh-CN",
            endTime: 1778322615.994957,
            isVoicePlaybackEnabled: true,
            rawAudioFormat: "MP3",
            segmentAudioFilePaths: [
                "/var/mobile/Containers/Data/Application/E0736025-3E61-44D5-915F-0D780066344F/Documents/.aibuds/ai/audios/ai_chat/user199/2026-05-09_18-29-22/segments/2026-05-09_18-29-41.mp3",
                "/var/mobile/Containers/Data/Application/E0736025-3E61-44D5-915F-0D780066344F/Documents/.aibuds/ai/audios/ai_chat/user199/2026-05-09_18-29-22/segments/2026-05-09_18-29-59.mp3"
            ],
            duration: 53.97502088546753,
            hasVoiceForDebugging: false,
            rawAudioFile: "/var/mobile/Containers/Data/Application/E0736025-3E61-44D5-915F-0D780066344F/Documents/.aibuds/ai/audios/ai_chat/user199/2026-05-09_18-29-22/raw_audio.mp3"
        },
        {
            segmentAudioFiles: [
                ".aibuds/ai/audios/ai_chat/user200/2026-05-09_19-00-00/segments/2026-05-09_19-00-15.mp3",
                ".aibuds/ai/audios/ai_chat/user200/2026-05-09_19-00-00/segments/2026-05-09_19-00-45.mp3",
                ".aibuds/ai/audios/ai_chat/user200/2026-05-09_19-00-00/segments/2026-05-09_19-01-10.mp3"
            ],
            autoEndSessionAfterNoInputDuration: 15,
            startTime: 1778325600.000000,
            segmentAudioFilesFormat: "MP3",
            events: [
                { timestamp: 1778325600.000000, timeSinceSessionStart: 0, eventId: "sessionStarted", description: "会话开始事件" },
                { timestamp: 1778325602.500000, timeSinceSessionStart: 2.5, eventId: "aiServiceConnected", description: "AI 服务成功连接" },
                { timestamp: 1778325620.000000, timeSinceSessionStart: 20, eventId: "vadStartSpeaking", description: "VAD 检测到用户开始说话" },
                { timestamp: 1778325625.000000, timeSinceSessionStart: 25, eventId: "vadEndSpeaking", description: "VAD 检测到用户结束说话" },
                { timestamp: 1778325628.000000, timeSinceSessionStart: 28, eventId: "aiRespondVoicePlaybackDidStart", description: "AI 响应语音播放开始" },
                { timestamp: 1778325650.000000, timeSinceSessionStart: 50, eventId: "aiRespondVoicePlaybackDidStop", description: "AI 响应语音播放结束" },
                { timestamp: 1778325650.500000, timeSinceSessionStart: 50.5, eventId: "sessionEnded", description: "会话结束事件" }
            ],
            audioChannel: "Opus",
            maxPauseDurationBeforeAIResponds: 0.8,
            language: "en-US",
            endTime: 1778325650.500000,
            isVoicePlaybackEnabled: true,
            rawAudioFormat: "MP3",
            segmentAudioFilePaths: [
                "/var/mobile/Containers/Data/Application/E0736025-3E61-44D5-915F-0D780066344F/Documents/.aibuds/ai/audios/ai_chat/user200/2026-05-09_19-00-00/segments/2026-05-09_19-00-15.mp3",
                "/var/mobile/Containers/Data/Application/E0736025-3E61-44D5-915F-0D780066344F/Documents/.aibuds/ai/audios/ai_chat/user200/2026-05-09_19-00-00/segments/2026-05-09_19-00-45.mp3",
                "/var/mobile/Containers/Data/Application/E0736025-3E61-44D5-915F-0D780066344F/Documents/.aibuds/ai/audios/ai_chat/user200/2026-05-09_19-00-00/segments/2026-05-09_19-01-10.mp3"
            ],
            duration: 50.5,
            hasVoiceForDebugging: false,
            rawAudioFile: "/var/mobile/Containers/Data/Application/E0736025-3E61-44D5-915F-0D780066344F/Documents/.aibuds/ai/audios/ai_chat/user200/2026-05-09_19-00-00/raw_audio.mp3"
        },
        {
            segmentAudioFiles: [
                ".aibuds/ai/audios/ai_chat/user201/2026-05-09_20-15-00/segments/2026-05-09_20-15-20.mp3"
            ],
            autoEndSessionAfterNoInputDuration: 15,
            startTime: 1778332500.000000,
            segmentAudioFilesFormat: "MP3",
            events: [
                { timestamp: 1778332500.000000, timeSinceSessionStart: 0, eventId: "sessionStarted", description: "会话开始事件" },
                { timestamp: 1778332503.000000, timeSinceSessionStart: 3, eventId: "aiServiceConnected", description: "AI 服务成功连接" },
                { timestamp: 1778332520.000000, timeSinceSessionStart: 20, eventId: "vadStartSpeaking", description: "VAD 检测到用户开始说话" },
                { timestamp: 1778332528.000000, timeSinceSessionStart: 28, eventId: "vadEndSpeaking", description: "VAD 检测到用户结束说话" },
                { timestamp: 1778332532.000000, timeSinceSessionStart: 32, eventId: "aiRespondVoicePlaybackDidStart", description: "AI 响应语音播放开始" },
                { timestamp: 1778332560.000000, timeSinceSessionStart: 60, eventId: "aiRespondVoicePlaybackDidStop", description: "AI 响应语音播放结束" },
                { timestamp: 1778332575.000000, timeSinceSessionStart: 75, eventId: "autoEndSessionTriggered", description: "自动结束会话被触发" },
                { timestamp: 1778332575.500000, timeSinceSessionStart: 75.5, eventId: "sessionEnded", description: "会话结束事件" }
            ],
            audioChannel: "Opus",
            maxPauseDurationBeforeAIResponds: 0.8,
            language: "zh-CN",
            endTime: 1778332575.500000,
            isVoicePlaybackEnabled: false,
            rawAudioFormat: "MP3",
            segmentAudioFilePaths: [
                "/var/mobile/Containers/Data/Application/E0736025-3E61-44D5-915F-0D780066344F/Documents/.aibuds/ai/audios/ai_chat/user201/2026-05-09_20-15-00/segments/2026-05-09_20-15-20.mp3"
            ],
            duration: 75.5,
            hasVoiceForDebugging: false,
            rawAudioFile: "/var/mobile/Containers/Data/Application/E0736025-3E61-44D5-915F-0D780066344F/Documents/.aibuds/ai/audios/ai_chat/user201/2026-05-09_20-15-00/raw_audio.mp3"
        }
    ],
    logs: [
        { timestamp: 0, level: 'info', message: '会话开始，初始化语音服务' },
        { timestamp: 0.5, level: 'debug', message: '加载语言模型：zh-CN' },
        { timestamp: 1.2, level: 'info', message: 'VAD (语音活动检测) 已初始化' },
        { timestamp: 2.5, level: 'info', message: 'AI 服务连接成功' },
        { timestamp: 2.8, level: 'debug', message: '音频编解码器：Opus' },
        { timestamp: 5.0, level: 'debug', message: '等待用户语音输入...' },
        { timestamp: 19.5, level: 'info', message: '检测到用户开始说话' },
        { timestamp: 20.1, level: 'debug', message: '音频缓冲区状态：填充中' },
        { timestamp: 21.5, level: 'info', message: '用户语音结束，停止录音' },
        { timestamp: 21.8, level: 'debug', message: '发送语音数据到 AI 服务...' },
        { timestamp: 24.0, level: 'info', message: 'AI 响应开始' },
        { timestamp: 24.5, level: 'debug', message: 'AI 意图已接收' },
        { timestamp: 25.0, level: 'info', message: 'AI 响应语音播放开始' },
        { timestamp: 28.0, level: 'debug', message: '音频片段 #1 生成完成' },
        { timestamp: 37.0, level: 'info', message: '检测到用户开始说话' },
        { timestamp: 38.5, level: 'info', message: '用户语音结束' },
        { timestamp: 38.8, level: 'info', message: 'AI 响应语音播放结束' },
        { timestamp: 39.5, level: 'debug', message: 'AI 意图已接收' },
        { timestamp: 42.0, level: 'debug', message: '等待语音活动检测...' },
        { timestamp: 53.5, level: 'warn', message: '无语音输入超时，开始倒计时' },
        { timestamp: 53.8, level: 'info', message: '自动结束会话被触发' },
        { timestamp: 54.0, level: 'info', message: '会话结束，释放资源' },
        { timestamp: 54.2, level: 'debug', message: '音频录制器已停止' },
        { timestamp: 54.5, level: 'debug', message: 'AI 服务连接已关闭' }
    ],
    getLogs: function(startTime) {
        return this.logs.map(log => ({
            ...log,
            timestamp: startTime + log.timestamp
        }));
    }
};