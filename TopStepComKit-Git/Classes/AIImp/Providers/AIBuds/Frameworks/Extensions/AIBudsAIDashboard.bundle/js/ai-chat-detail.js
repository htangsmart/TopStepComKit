// AI 对话详情页面脚本
let chatDetailData = {};

document.addEventListener('DOMContentLoaded', function() {
    loadDetailData();
});

function logout() {
    // 调用退出 API
    fetch(API_CONFIG.getLogoutUrl(), {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ' + localStorage.getItem('aibudsclaw-token')
        }
    })
    .then(response => response.json())
    .then(data => {
        // 无论成功与否，都清除本地 token 并跳转到登录页
        localStorage.removeItem('aibudsclaw-token');
        window.location.href = 'login.html';
    })
    .catch(error => {
        console.error('退出登录失败：', error);
        // 即使 API 调用失败，也清除本地 token 并跳转
        localStorage.removeItem('aibudsclaw-token');
        window.location.href = 'login.html';
    });
}

function countUserSpeeches(segmentAudioFiles) {
    if (!segmentAudioFiles) return 0;
    return segmentAudioFiles.filter(e => !e.split('/').pop().startsWith('respond_')).length;
}

function countAIResponses(segmentAudioFiles) {
    if (!segmentAudioFiles) return 0;
    return segmentAudioFiles.filter(e => e.split('/').pop().startsWith('respond_')).length;
}

async function loadDetailData() {
    const params = new URLSearchParams(window.location.search);

    if (!params.has('sessionId')) {
        window.location.href = 'ai-chat.html';
        return;
    }

    const sessionId = params.get('sessionId');
    

    if (API_CONFIG.USE_API) {
        try {
            const response = await fetch(API_CONFIG.getChatDetailUrl(sessionId), {
                headers: {
                    'Authorization': 'Bearer ' + localStorage.getItem('aibudsclaw-token')
                }
            });
            chatDetailData = await API_CONFIG.handleApiResponse(response);
            console.log('从 API 加载会话详情数据成功');
        } catch (error) {
            console.error('从 API 加载会话详情数据失败：', error);
        }
    } else {
        chatDetailData = MOCK_DATA.chatDetailData;
        console.log('使用测试会话详情数据');
    }
    
    const startTime = parseFloat(chatDetailData.startTime) || 0;
    const endTime = parseFloat(chatDetailData.endTime) || 0;
    const duration = parseFloat(chatDetailData.duration) || 0;
    const language = chatDetailData.language || '-';
    const aiServiceVendor = chatDetailData.aiServiceVendor || '-';
    const rawAudioFile = chatDetailData.rawAudioFile || '';
    const rawAudioFormat = chatDetailData.rawAudioFormat || '-';
    const audioChannel = chatDetailData.audioChannel || '-';
    const hasVoiceForDebugging = chatDetailData.hasVoiceForDebugging === true;
    const isVoicePlaybackEnabled = chatDetailData.isVoicePlaybackEnabled === true;
    const allowUserToInterruptAIResponse = chatDetailData.allowUserToInterruptAIResponse === true;
    const autoEndSessionAfterNoInputDuration = parseFloat(chatDetailData.autoEndSessionAfterNoInputDuration) || 0;
    const maxPause = parseFloat(chatDetailData.maxPauseDurationBeforeAIResponds) || 0;
    const userSpeechCount = countUserSpeeches(chatDetailData.segmentAudioFiles || []);
    const aiResponseCount = countAIResponses(chatDetailData.segmentAudioFiles || []);
    const audioSegments = chatDetailData.segmentAudioFiles.length || 0;
    const autoEnd = chatDetailData.wasAutoEnded === true;

    const hasDeviceInfo = chatDetailData.device !== undefined && chatDetailData.device !== null;

    let segmentFiles = chatDetailData.segmentAudioFiles || '[]';
    let events = chatDetailData.events || '[]';
    let deviceInfo = {};
    if (hasDeviceInfo) {
        deviceInfo = {
            productType: chatDetailData.device.product || '-',
            name: chatDetailData.device.name || '-',
            bluetoothName: chatDetailData.device.bluetoothName || '-',
            bluetoothMac: chatDetailData.device.macAddress || '-',
            model: chatDetailData.device.model || '-',
            projectId: chatDetailData.device.formatedProjNumber || '-',
            firmwareVersion: chatDetailData.device.formatedFirmwareVersion || '-',
            userId: chatDetailData.device.userID || '-'
        };
    }

    currentRawAudioFile = rawAudioFile;
    currentSegmentFiles = segmentFiles;
    currentStartTime = startTime;
    currentEndTime = endTime;

    document.getElementById('detailChatId').textContent = `#session_${sessionId}`;
    document.getElementById('detailLanguage').textContent = getLanguageLabel(language);
    document.getElementById('detailAiServiceVendor').textContent = aiServiceVendor;
    document.getElementById('detailDuration').textContent = formatDuration(duration);
    document.getElementById('detailStartTime').textContent = formatTimestamp(startTime);
    document.getElementById('detailEndTime').textContent = formatTimestamp(endTime);
    document.getElementById('detailHasVoiceForDebugging').textContent = hasVoiceForDebugging ? '是' : '否';
    document.getElementById('detailAllowUserToInterruptAIResponse').textContent = allowUserToInterruptAIResponse ? '是' : '否';
    document.getElementById('detailAutoEndSessionAfterNoInputDuration').textContent = formatDuration(autoEndSessionAfterNoInputDuration);
    document.getElementById('detailUserSpeechCount').textContent = userSpeechCount;
    document.getElementById('detailAIResponseCount').textContent = aiResponseCount;
    document.getElementById('detailAudioSegments').textContent = audioSegments;
    document.getElementById('detailAutoEnd').textContent = autoEnd ? '是' : '否';

    const rawAudioContainer = document.getElementById('rawAudioContainer');
    const audioControlsWrapper = rawAudioContainer.querySelector('.audio-controls-wrapper');
    const audioWaveform = rawAudioContainer.querySelector('.audio-waveform');
    const audioInfoRow = rawAudioContainer.querySelector('.audio-info-row');
    const audioPlayer = audioControlsWrapper.querySelector('audio');

    if (rawAudioFile) {
        audioPlayer.src = API_CONFIG.getAudioUrl(rawAudioFile);
        audioControlsWrapper.style.display = 'block';
        audioWaveform.style.display = 'block';
        audioInfoRow.style.display = 'flex';
    } else {
        audioControlsWrapper.innerHTML = '<p class="empty-state">暂无原始音频</p>';
        audioControlsWrapper.style.display = 'block';
        audioWaveform.style.display = 'none';
        audioInfoRow.style.display = 'none';
    }

    if (audioPlayer) {
        audioPlayer.addEventListener('play', function() {
            audioWaveform.classList.add('playing');
        });

        audioPlayer.addEventListener('pause', function() {
            audioWaveform.classList.remove('playing');
        });

        audioPlayer.addEventListener('ended', function() {
            audioWaveform.classList.remove('playing');
        });
    }
    document.getElementById('detailRawAudioFormat').textContent = rawAudioFormat;
    document.getElementById('detailAudioChannel').textContent = audioChannel;
    document.getElementById('detailAudioDuration').textContent = formatDuration(duration);
    document.getElementById('detailAudioChannel2').textContent = audioChannel;
    document.getElementById('detailVoicePlayback').textContent = isVoicePlaybackEnabled ? '启用' : '禁用';
    document.getElementById('detailMaxPause').textContent = maxPause > 0 ? `${maxPause}秒` : '-';

    document.getElementById('segmentCount').textContent = segmentFiles.length;

    // 渲染设备信息
    renderDeviceInfo(deviceInfo);

    renderAudioSegments(segmentFiles, events, startTime);
    renderEventsTimeline(events, startTime);
    loadSessionLogs();
}

function renderDeviceInfo(deviceInfo) {
    const deviceInfoSection = document.getElementById('deviceInfoSection');
    
    if (!deviceInfo || Object.keys(deviceInfo).length === 0) {
        deviceInfoSection.style.display = 'none';
        return;
    }
    
    deviceInfoSection.style.display = 'block';
    
    document.getElementById('deviceProductType').textContent = deviceInfo.productType || '-';
    document.getElementById('deviceName').textContent = deviceInfo.name || '-';
    document.getElementById('deviceBluetoothName').textContent = deviceInfo.bluetoothName || '-';
    document.getElementById('deviceBluetoothMac').textContent = deviceInfo.bluetoothMac || '-';
    document.getElementById('deviceModel').textContent = deviceInfo.model || '-';
    document.getElementById('deviceProjectId').textContent = deviceInfo.projectId || '-';
    document.getElementById('deviceFirmwareVersion').textContent = deviceInfo.firmwareVersion || '-';
    document.getElementById('deviceUserId').textContent = deviceInfo.userId || '-';
}

function renderAudioSegments(segmentFiles, events, startTime) {
    
    const container = document.getElementById('audioSegmentsContainer');

    if (!segmentFiles || segmentFiles.length === 0) {
        container.innerHTML = '<p class="empty-state">暂无音频片段</p>';
        return;
    }

    const userSpeechEvents = events.filter(e => e.eventId === 'vadEndSpeaking');
    const aiResponseEvents = events.filter(e => e.eventId === 'aiRespondVoicePlaybackDidStart');

    container.innerHTML = segmentFiles.map((file, index) => {
        const fileName = file.split('/').pop();
        const fileUrl = API_CONFIG.getAudioUrl(file);
        const segmentTime = extractSegmentTime(fileName);
        let speaker = '用户';
        if (fileName.includes('respond_')) {
            speaker = 'AI';
        }
        
        // 计算相对于 session 开始的偏移时间
        const offsetTime = calculateOffsetTime(fileName, startTime);

        return `
            <div class="segment-card">
                <div class="segment-header">
                    <div class="segment-info-left">
                        <span class="segment-number">片段 ${index + 1}</span>
                        <span class="segment-speaker ${speaker === '用户' ? 'user' : 'ai'}">${speaker === '用户' ? '🎤 用户' : '🤖 AI'}</span>
                        <span class="segment-offset">+${offsetTime}</span>
                    </div>
                    <span class="segment-time">${segmentTime}</span>
                </div>
                <div class="segment-body">
                    <div class="segment-waveform">
                        <div class="waveform-visual">
                            ${generateWaveformBars()}
                        </div>
                    </div>
                    <audio controls class="segment-audio-player">
                        <source src="${fileUrl}" type="audio/mpeg">
                        您的浏览器不支持音频播放
                    </audio>
                </div>
                <div class="segment-footer">
                    <span class="segment-filename">${fileName}</span>
                    <button class="btn btn-download btn-sm" onclick="downloadSegment(${index})">
                        <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"></path>
                            <polyline points="7 10 12 15 17 10"></polyline>
                            <line x1="12" y1="15" x2="12" y2="3"></line>
                        </svg>
                        下载
                    </button>
                </div>
            </div>
        `;
    }).join('');

    // 设置音频片段的波形动画事件
    requestAnimationFrame(() => {
        const audioPlayers = container.querySelectorAll('.segment-audio-player');
        
        audioPlayers.forEach((audio, index) => {
            const card = audio.closest('.segment-card');
            const waveform = card ? card.querySelector('.segment-waveform') : null;
            
            if (waveform) {
                setupAudioWaveformEvents(audio, waveform);
            }
        });
    });
}

// 复用的音频波形事件设置函数
function setupAudioWaveformEvents(audio, waveform) {
    audio.addEventListener('play', function() {
        waveform.classList.add('playing');
    });
    audio.addEventListener('pause', function() {
        waveform.classList.remove('playing');
    });
    audio.addEventListener('ended', function() {
        waveform.classList.remove('playing');
    });
}

// 页面加载时添加事件委托，确保动态元素也能响应
document.addEventListener('DOMContentLoaded', function() {
    const segmentsContainer = document.getElementById('audioSegmentsContainer');
    if (segmentsContainer) {
        // 事件委托 - 监听所有音频播放事件
        segmentsContainer.addEventListener('play', function(e) {
            const audio = e.target;
            if (audio.classList.contains('segment-audio-player')) {
                const card = audio.closest('.segment-card');
                const waveform = card ? card.querySelector('.segment-waveform') : null;
                if (waveform) {
                    waveform.classList.add('playing');
                }
            }
        }, true);
        
        segmentsContainer.addEventListener('pause', function(e) {
            const audio = e.target;
            if (audio.classList.contains('segment-audio-player')) {
                const card = audio.closest('.segment-card');
                const waveform = card ? card.querySelector('.segment-waveform') : null;
                if (waveform) {
                    waveform.classList.remove('playing');
                }
            }
        }, true);
        
        segmentsContainer.addEventListener('ended', function(e) {
            const audio = e.target;
            if (audio.classList.contains('segment-audio-player')) {
                const card = audio.closest('.segment-card');
                const waveform = card ? card.querySelector('.segment-waveform') : null;
                if (waveform) {
                    waveform.classList.remove('playing');
                }
            }
        }, true);
    }
});

function renderEventsTimeline(events, startTime) {
    const container = document.getElementById('eventsTimelineContainer');

    if (!events || events.length === 0) {
        container.innerHTML = '<p class="empty-state">暂无事件记录</p>';
        return;
    }

    const eventIcons = {
        'userInitiatedToStart': { icon: '👤', color: 'green' },
        'sessionStarted': { icon: '🚀', color: 'green' },
        'aiServiceConnected': { icon: '🔗', color: 'blue' },
        'vadStartSpeaking': { icon: '🎤', color: 'orange' },
        'vadEndSpeaking': { icon: '🎤', color: 'orange' },
        'aiRespondVoicePlaybackDidStart': { icon: '🔊', color: 'purple' },
        'aiRespondVoicePlaybackDidStop': { icon: '🔇', color: 'purple' },
        'aiIntentReceived': { icon: '💡', color: 'yellow' },
        'autoEndSessionTriggered': { icon: '⏰', color: 'red' },
        'userInitiatedToEndSession': { icon: '👤', color: 'red' },
        'sessionEnded': { icon: '🏁', color: 'gray' },
        'aiServiceStartRecording': { icon: '📝', color: 'cyan' },
        'aiServiceEndRecording': { icon: '📝', color: 'cyan' },
        'appWillTerminate': { icon: '📍', color: 'red' }
    };

    container.innerHTML = events.map((event, index) => {
        const eventInfo = eventIcons[event.eventId] || { icon: '📌', color: 'gray' };
        const relativeTime = formatDuration(event.timeSinceSessionStart);
        const isRelativeTimeNegative = relativeTime.startsWith('-');
        const actualTime = formatTimestamp(startTime + event.timeSinceSessionStart);
        const isLast = index === events.length - 1;

        return `
            <div class="timeline-item ${eventInfo.color}">
                <div class="timeline-marker">
                    <span class="timeline-icon">${eventInfo.icon}</span>
                    ${!isLast ? '<div class="timeline-line"></div>' : ''}
                </div>
                <div class="timeline-content">
                    <div class="timeline-header">
                        <div class="timeline-times">
                            <span class="timeline-actual-time">${actualTime}</span>
                            <span class="timeline-time">${isRelativeTimeNegative ? '' : '+'}${relativeTime}</span>
                        </div>
                        <span class="timeline-event-id">${event.eventId}</span>
                    </div>
                    <div class="timeline-description">${event.description}</div>
                    ${event.evidence ? `<div class="timeline-evidence">${event.evidence}</div>` : ''}
                </div>
            </div>
        `;
    }).join('');
}

function generateWaveformBars() {
    let bars = '';
    for (let i = 0; i < 40; i++) {
        const height = Math.random() * 30 + 10;
        bars += `<span class="wave-bar" style="height: ${height}%"></span>`;
    }
    return bars;
}

function calculateOffsetTime(currentFile, startTime) {
    const currentTime = extractTimeFromFile(currentFile);
    
    // startTime 可能是毫秒或秒，需要判断
    let startTimeMs = startTime;
    // 如果 startTime 是 10 位数，说明是秒，需要转换为毫秒
    if (startTime < 10000000000) {
        startTimeMs = startTime * 1000;
    }

    
    const offsetSeconds = Math.floor((currentTime - startTimeMs) / 1000);
    
    if (offsetSeconds < 0) return '0:00';

    if(currentTime - startTimeMs < 1000) {
        return '.' + Math.floor(currentTime - startTimeMs)
    }
    
    const minutes = Math.floor(offsetSeconds / 60);
    const seconds = offsetSeconds % 60;
    
    return `${minutes}:${String(seconds).padStart(2, '0')}`;
}

function extractTimeFromFile(filePath) {
    const match = filePath.match(/(\d{4}-\d{2}-\d{2})_(\d{2})-(\d{2})-(\d{2})/);
    if (match) {
        const [, datePart, hours, minutes, seconds] = match;
        const formattedDate = `${datePart}T${hours}:${minutes}:${seconds}`;
        return new Date(formattedDate).getTime();
    }
    return 0;
}

function extractSegmentTime(filePath) {
    const match = filePath.match(/(\d{4}-\d{2}-\d{2})_(\d{2})-(\d{2})-(\d{2})/);
    if (match) {
        const [, datePart, hours, minutes, seconds] = match;
        const formattedDate = `${datePart}T${hours}:${minutes}:${seconds}`;
        const date = new Date(formattedDate);
        if (isNaN(date.getTime())) {
            return '--:--:--';
        }
        const h = String(date.getHours()).padStart(2, '0');
        const m = String(date.getMinutes()).padStart(2, '0');
        const s = String(date.getSeconds()).padStart(2, '0');
        return `${h}:${m}:${s}`;
    }
    return '--:--:--';
}

function truncateEvidence(evidence) {
    if (evidence.length > 100) {
        return evidence.substring(0, 100) + '...';
    }
    return evidence;
}

function formatTimestamp(timestamp) {
    if (!timestamp) return '-';
    const date = new Date(timestamp * 1000);
    const year = date.getFullYear();
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const day = String(date.getDate()).padStart(2, '0');
    const hours = String(date.getHours()).padStart(2, '0');
    const minutes = String(date.getMinutes()).padStart(2, '0');
    const seconds = String(date.getSeconds()).padStart(2, '0');
    const milliseconds = String(date.getMilliseconds()).padStart(3, '0');
    return `${year}-${month}-${day} ${hours}:${minutes}:${seconds}.${milliseconds}`;
}

function formatDuration(seconds) {
    if (!seconds && seconds !== 0) return '-';
    const isNegative = seconds < 0;
    const secs = isNegative ? -Math.floor(Math.abs(seconds)) : Math.floor(seconds);
    if (secs < 60) {
        return `${secs}秒`;
    }
    const mins = Math.floor(secs / 60);
    const remainingSecs = secs % 60;
    if (mins < 60) {
        return `${mins}分${remainingSecs}秒`;
    }
    const hours = Math.floor(mins / 60);
    const remainingMins = mins % 60;
    return `${hours}小时${remainingMins}分`;
}

function getLanguageLabel(lang) {
    if (lang === undefined || lang === 'undefined') return '未指定';
    
    const labels = {
        'zh-CN': '中文',
        'zh-TW': '繁体中文',
        'zh-HK': '繁体中文（香港）',
        'en-US': '英文',
        'en-GB': '英文（英国）',
        'en-CA': '英文（加拿大）',
        'en-AU': '英文（澳大利亚）',
        'en-IN': '英文（印度）',
        'ja-JP': '日语',
        'ko-KR': '韩语',
        'fr-FR': '法语',
        'fr-CA': '法语（加拿大）',
        'de-DE': '德语',
        'es-ES': '西班牙语',
        'es-MX': '西班牙语（墨西哥）',
        'it-IT': '意大利语',
        'pt-PT': '葡萄牙语',
        'pt-BR': '葡萄牙语（巴西）',
        'ru-RU': '俄语',
        'ar-SA': '阿拉伯语',
        'hi-IN': '印地语',
        'th-TH': '泰语',
        'vi-VN': '越南语',
        'id-ID': '印尼语',
        'ms-MY': '马来语',
        'tr-TR': '土耳其语',
        'pl-PL': '波兰语',
        'nl-NL': '荷兰语',
        'sv-SE': '瑞典语',
        'no-NO': '挪威语',
        'da-DK': '丹麦语',
        'fi-FI': '芬兰语',
        'cs-CZ': '捷克语',
        'hu-HU': '匈牙利语',
        'el-GR': '希腊语',
        'he-IL': '希伯来语',
        'uk-UA': '乌克兰语',
        'ro-RO': '罗马尼亚语',
        'bg-BG': '保加利亚语',
        'hr-HR': '克罗地亚语',
        'sk-SK': '斯洛伐克语',
        'sl-SI': '斯洛文尼亚语',
        'lt-LT': '立陶宛语',
        'lv-LV': '拉脱维亚语',
        'et-EE': '爱沙尼亚语'
    };
    return labels[lang] || lang || '未指定';
}

function exportCurrentReport() {
    if (window.AIChatReportExporter && typeof AIChatReportExporter.exportReport === 'function') {
        AIChatReportExporter.exportReport();
    } else {
        alert('导出模块加载失败，请刷新页面重试');
    }
}


let currentRawAudioFile = '';
let currentSegmentFiles = [];
let currentStartTime = 0;
let currentEndTime = 0;

function downloadRawAudio() {
    if (!currentRawAudioFile) {
        alert('暂无原始音频文件');
        return;
    }
    const link = document.createElement('a');
    link.href = API_CONFIG.getAudioUrl(currentRawAudioFile);
    link.download = currentRawAudioFile.split('/').pop() || 'raw_audio.mp3';
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
}

function downloadSegment(index) {
    if (!currentSegmentFiles[index]) {
        alert('音频片段不存在');
        return;
    }
    const file = currentSegmentFiles[index];
    const link = document.createElement('a');
    link.href = API_CONFIG.getAudioUrl(file);
    link.download = file.split('/').pop() || `segment_${index + 1}.mp3`;
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
}

async function loadSessionLogs() {
    const container = document.getElementById('sessionLogsContainer');
    const countEl = document.getElementById('logCount');

    try {
        let logs = chatDetailData.logs || [];
        countEl.textContent = logs.length;
        renderLogs(logs);
        
    } catch (error) {
        console.error('加载错误警告日志失败：', error);
        container.innerHTML = '<p class="empty-state">加载错误警告日志失败，请重试</p>';
    }
}

function renderLogs(logs) {
    const container = document.getElementById('sessionLogsContainer');

    if (!logs || logs.length === 0) {
        container.innerHTML = '<p class="empty-state">暂无错误警告日志记录</p>';
        return;
    }

    container.innerHTML = logs.map(log => {
        const time = formatTimestamp(log.timestamp);
        const level = log.level || 'info';
        const message = log.message || log.msg || '-';

        return `
            <div class="log-item">
                <span class="log-time">${time}</span>
                <span class="log-level ${level}">${level.toUpperCase()}</span>
                <span class="log-message">${message}</span>
            </div>
        `;
    }).join('');
}

function escapeHtml(text) {
    const div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
}
