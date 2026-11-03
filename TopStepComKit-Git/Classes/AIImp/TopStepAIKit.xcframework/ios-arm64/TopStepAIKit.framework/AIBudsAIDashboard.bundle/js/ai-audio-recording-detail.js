// AI 录音报告详情页面脚本
let recordingDetailData = [];
let sessionId = null;
let currentIndex = 0;
let audioContext = null;
let currentPcmSource = null;
let pcmAudioBuffer = null;

document.addEventListener('DOMContentLoaded', function() {
    const urlParams = new URLSearchParams(window.location.search);
    const index = urlParams.get('index');
    sessionId = urlParams.get('sessionId');

    if (index !== null) {
        currentIndex = parseInt(index);
    }

    if (sessionId) {
        loadRecordingDetail(sessionId);
    } else {
        console.error('未提供 sessionId 参数');
        document.getElementById('transcriptsContainer').innerHTML = '<div class="empty-state"><p>参数错误</p></div>';
    }
});

function logout() {
    fetch(API_CONFIG.getLogoutUrl(), {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ' + localStorage.getItem('aibudsclaw-token')
        }
    })
    .then(response => response.json())
    .then(data => {
        localStorage.removeItem('aibudsclaw-token');
        window.location.href = 'login.html';
    })
    .catch(error => {
        console.error('退出登录失败：', error);
        localStorage.removeItem('aibudsclaw-token');
        window.location.href = 'login.html';
    });
}

async function loadRecordingDetail(sessionId) {
    console.log('加载 AI 录音详情数据，sessionId:', sessionId);

    if (API_CONFIG.USE_API) {
        try {
            const response = await fetch(API_CONFIG.getAiAudioRecordingDetailUrl(sessionId), {
                headers: {
                    'Authorization': 'Bearer ' + localStorage.getItem('aibudsclaw-token')
                }
            });
            recordingDetailData = await API_CONFIG.handleApiResponse(response);
            console.log('从 API 加载详情数据成功');
        } catch (error) {
            console.error('从 API 加载详情数据失败：', error);
        }
    } else {
        recordingDetailData = MOCK_DATA.aiAudioRecordingDetailData || {};
        console.log('使用测试数据');
    }

    renderBasicInfo(recordingDetailData);
    renderTranscripts(recordingDetailData.transcripts || []);
    renderSpeakerSegments(recordingDetailData.speakerSegments || []);
    renderAudio(recordingDetailData);
    renderDeviceInfo(recordingDetailData.device);
    renderEventsTimeline(recordingDetailData.events || [], recordingDetailData.startTime || 0);
    renderLogs(recordingDetailData.logs || []);
}

function renderBasicInfo(data) {
    const sessionId = data.sessionId || (data.startTime ? Math.floor(data.startTime) : 'unknown');
    document.getElementById('detailChatId').textContent = `#session_${sessionId}`;
    document.getElementById('detailStartTime').textContent = formatTimestamp(data.startTime);
    document.getElementById('detailEndTime').textContent = formatTimestamp(data.endTime);
    document.getElementById('detailDuration').textContent = formatDuration(data.duration);
    document.getElementById('detailAiServiceVendor').textContent = data.aiServiceVendor || '-';
    document.getElementById('detailRecordingScene').textContent = data.recordingScene || '-';
    document.getElementById('detailLanguageForSpeechInput').textContent = getLanguageLabel(data.languageForSpeechInput) || data.languageForSpeechInput || '-';
    document.getElementById('detailIsOfflineRecording').textContent = data.isOfflineRecording ? '离线录音' : 'AI 录音';
    document.getElementById('detailIsStoppedByInterruption').textContent = data.isStoppedByInterruption ? '是' : '否';
    document.getElementById('detailHadNetworkDisconnection').textContent = data.hadNetworkDisconnection ? '是' : '否';
}

function renderTranscripts(transcripts) {
    const container = document.getElementById('transcriptsContainer');

    if (!transcripts || transcripts.length === 0) {
        container.innerHTML = '<div class="empty-state"><p>暂无转录内容</p></div>';
        return;
    }

    container.innerHTML = transcripts.map((transcript, index) => {
        const timestamp = parseFloat(transcript.timestamp) || 0;
        const timeStr = formatTimestamp(timestamp);
        const sequence = transcript.transcriptSequence;
        const text = transcript.transcript || '';
        const requestId = transcript.requestId || '';
        const modelSeq = transcript.modelResponseSequence || '-';

        return `
            <div class="transcript-item">
                <div class="transcript-header">
                    <div class="transcript-info">
                        <span class="transcript-badge">#${sequence}</span>
                        <span class="transcript-time">⏰ ${timeStr}</span>
                    </div>
                    <div class="transcript-meta">
                        <span class="meta-tag">模型序号：${modelSeq}</span>
                    </div>
                </div>
                <div class="transcript-content">
                    <p>${text || '-'}</p>
                </div>
                <div class="transcript-footer">
                    <span class="request-id">Request ID: ${requestId || '-'}</span>
                </div>
            </div>`;
    }).join('');
}

function renderSpeakerSegments(speakerSegments) {
    const container = document.getElementById('speakerSegmentsContainer');

    if (!speakerSegments || speakerSegments.length === 0) {
        container.innerHTML = '<div class="empty-state"><p>暂无说话人片段</p></div>';
        return;
    }

    container.innerHTML = speakerSegments.map((segment, index) => {
        const timestamp = isNaN(segment.timestamp) ? '-' : formatTimestamp(segment.timestamp);
        const associatedTranscriptSequence = isNaN(segment.associatedTranscriptSequence) ? '-' : segment.associatedTranscriptSequence;
        const speakerId = segment.speakerId || '-';
        const startTimeMs = segment.startTimeMs || 0;
        const endTimeMs = segment.endTimeMs || 0;
        const durationMs = endTimeMs - startTimeMs;
        const text = segment.text || '';
        const startTimeStr = formatMilliseconds(startTimeMs);
        const endTimeStr = formatMilliseconds(endTimeMs);
        const durationStr = formatMilliseconds(durationMs);

        return `
            <div class="segment-item">
                <div class="segment-header">
                    <div class="segment-title">
                        <span class="speaker-badge">👤 说话人 ${speakerId}</span>
                        <span class="segment-time">⏰ ${timestamp}</span>
                        <span class="segment-sequence">关联序号 #${associatedTranscriptSequence}</span>
                    </div>
                    <div class="segment-time-info">
                        <span class="time-badge">⏱️ 时长 ${durationStr}</span>
                    </div>
                </div>
                <div class="segment-content">
                    <p>${text || '-'}</p>
                </div>
                <div class="segment-time-range">
                    <span class="time-label">起始</span>
                    <span class="time-value">${startTimeStr}</span>
                    <span class="time-separator">→</span>
                    <span class="time-label">结束</span>
                    <span class="time-value">${endTimeStr}</span>
                </div>
            </div>`;
    }).join('');
}

function formatMilliseconds(ms) {
    const totalSeconds = Math.floor(ms / 1000);
    const hours = Math.floor(totalSeconds / 3600);
    const minutes = Math.floor((totalSeconds % 3600) / 60);
    const seconds = totalSeconds % 60;
    const milliseconds = ms % 1000;

    if (hours > 0) {
        return `${String(hours).padStart(2, '0')}:${String(minutes).padStart(2, '0')}:${String(seconds).padStart(2, '0')}.${String(milliseconds).padStart(3, '0')}`;
    }
    return `${String(minutes).padStart(2, '0')}:${String(seconds).padStart(2, '0')}.${String(milliseconds).padStart(3, '0')}`;
}

function renderAudio(data) {
    const rawAudioContainer = document.getElementById('rawAudioContainer');
    const convertedAudioContainer = document.getElementById('convertedAudioContainer');
    const originalAudioPlayer = document.getElementById('originalAudioPlayer');
    const convertedAudioPlayer = document.getElementById('convertedAudioPlayer');
    const rawAudioControls = document.getElementById('rawAudioControls');

    const rawFormat = (data.rawAudioFormat || '-').toUpperCase();
    const isPcm = rawFormat === 'PCM' || rawFormat === 'RAW';

    if (data.rawAudioFile) {
        document.getElementById('detailRawAudioFormat').textContent = rawFormat;

        if (isPcm) {
            originalAudioPlayer.style.display = 'none';
            rawAudioControls.style.display = 'flex';
            setupPcmPlayer(data.rawAudioFile, data);
        } else {
            originalAudioPlayer.style.display = 'block';
            rawAudioControls.style.display = 'none';
            const audioUrl = API_CONFIG.getAudioUrl(data.rawAudioFile);
            originalAudioPlayer.src = audioUrl;
        }
        rawAudioContainer.style.display = 'block';
    } else {
        rawAudioContainer.style.display = 'none';
    }

    const convertedFormat = (data.convertedAudioFormat || '-').toUpperCase();
    const isConvertedPcm = convertedFormat === 'PCM' || convertedFormat === 'RAW';

    if (data.convertedAudioFile) {
        document.getElementById('detailConvertedAudioFormat').textContent = convertedFormat;

        if (isConvertedPcm) {
            convertedAudioPlayer.style.display = 'none';
        } else {
            convertedAudioPlayer.style.display = 'block';
            const audioUrl = API_CONFIG.getAudioUrl(data.convertedAudioFile);
            convertedAudioPlayer.src = audioUrl;
        }
        convertedAudioContainer.style.display = 'block';
    } else {
        convertedAudioContainer.style.display = 'none';
    }
}

function setupPcmPlayer(audioFile, data) {
    const playBtn = document.getElementById('pcmPlayBtn');
    const stopBtn = document.getElementById('pcmStopBtn');
    const progressBar = document.getElementById('pcmProgress');
    const currentTimeSpan = document.getElementById('pcmCurrentTime');
    const durationSpan = document.getElementById('pcmDuration');
    const pcmStatus = document.getElementById('pcmStatus');
    const waveformContainer = document.getElementById('pcmWaveform');

    const sampleRate = data.sampleRate || 16000;
    const channels = data.audioChannel === 'Stereo' ? 2 : 1;
    const bitsPerSample = data.bitsPerSample || 16;

    let isPlaying = false;
    let startTime = 0;
    let pauseTime = 0;

    playBtn.onclick = async () => {
        if (isPlaying) {
            pausePcm();
        } else {
            await playPcm(audioFile, sampleRate, channels, bitsPerSample);
        }
    };

    stopBtn.onclick = () => {
        stopPcm();
    };

    async function playPcm(file, sr, ch, bps) {
        try {
            pcmStatus.textContent = '加载中...';
            playBtn.disabled = true;
            playBtn.classList.remove('playing');

            if (!audioContext) {
                audioContext = new (window.AudioContext || window.webkitAudioContext)();
            }

            if (audioContext.state === 'suspended') {
                await audioContext.resume();
            }

            if (pauseTime === 0) {
                const response = await fetch(API_CONFIG.getAudioUrl(file), {
                    headers: {
                        'Authorization': 'Bearer ' + localStorage.getItem('aibudsclaw-token')
                    }
                });
                const arrayBuffer = await response.arrayBuffer();

                const numFrames = arrayBuffer.byteLength / (ch * bps / 8);
                pcmAudioBuffer = audioContext.createBuffer(ch, numFrames, sr);

                const audioData = new Int16Array(arrayBuffer);
                const channelData = pcmAudioBuffer.getChannelData(0);
                for (let i = 0; i < audioData.length; i++) {
                    channelData[i] = audioData[i] / 32768;
                }
                if (ch === 2) {
                    const channelData2 = pcmAudioBuffer.getChannelData(1);
                    for (let i = 0; i < audioData.length / 2; i++) {
                        channelData2[i] = audioData[audioData.length / 2 + i] / 32768;
                    }
                }

                durationSpan.textContent = formatPcmTime(pcmAudioBuffer.duration);
            }

            if (currentPcmSource) {
                currentPcmSource.stop();
            }

            currentPcmSource = audioContext.createBufferSource();
            currentPcmSource.buffer = pcmAudioBuffer;
            currentPcmSource.connect(audioContext.destination);

            if (pauseTime > 0) {
                currentPcmSource.start(0, pauseTime);
            } else {
                currentPcmSource.start(0);
            }

            startTime = audioContext.currentTime - pauseTime;
            isPlaying = true;
            playBtn.innerHTML = `<svg width="18" height="18" viewBox="0 0 24 24" fill="currentColor"><rect x="6" y="4" width="4" height="16"></rect><rect x="14" y="4" width="4" height="16"></rect></svg>`;
            playBtn.classList.add('playing');
            pcmStatus.textContent = '播放中';
            playBtn.disabled = false;
            
            if (waveformContainer) {
                waveformContainer.classList.remove('paused');
            }

            currentPcmSource.onended = () => {
                if (isPlaying) {
                    stopPcm();
                }
            };

            updateProgress();

        } catch (error) {
            console.error('PCM 播放失败：', error);
            pcmStatus.textContent = '播放失败';
            playBtn.disabled = false;
            playBtn.classList.remove('playing');
            if (waveformContainer) {
                waveformContainer.classList.add('paused');
            }
        }
    }

    function pausePcm() {
        if (currentPcmSource && isPlaying) {
            pauseTime = audioContext.currentTime - startTime;
            currentPcmSource.stop();
            isPlaying = false;
            playBtn.innerHTML = `<svg width="18" height="18" viewBox="0 0 24 24" fill="currentColor"><polygon points="5 3 19 12 5 21 5 3"></polygon></svg>`;
            playBtn.classList.remove('playing');
            pcmStatus.textContent = '已暂停';
            if (waveformContainer) {
                waveformContainer.classList.add('paused');
            }
        }
    }

    function stopPcm() {
        if (currentPcmSource) {
            try {
                currentPcmSource.stop();
            } catch (e) {}
        }
        isPlaying = false;
        pauseTime = 0;
        playBtn.innerHTML = `<svg width="18" height="18" viewBox="0 0 24 24" fill="currentColor"><polygon points="5 3 19 12 5 21 5 3"></polygon></svg>`;
        playBtn.classList.remove('playing');
        pcmStatus.textContent = '已停止';
        currentTimeSpan.textContent = '00:00';
        progressBar.style.width = '0%';
        if (waveformContainer) {
            waveformContainer.classList.add('paused');
        }
    }

    function updateProgress() {
        if (!isPlaying) return;

        const currentTime = audioContext.currentTime - startTime;
        const duration = pcmAudioBuffer ? pcmAudioBuffer.duration : 0;
        const progress = duration > 0 ? (currentTime / duration) * 100 : 0;

        currentTimeSpan.textContent = formatPcmTime(currentTime);
        progressBar.style.width = Math.min(progress, 100) + '%';

        requestAnimationFrame(updateProgress);
    }

    function formatPcmTime(seconds) {
        const mins = Math.floor(seconds / 60);
        const secs = Math.floor(seconds % 60);
        return `${String(mins).padStart(2, '0')}:${String(secs).padStart(2, '0')}`;
    }
}

function renderDeviceInfo(device) {
    const container = document.getElementById('deviceInfoContainer');

    if (!device) {
        container.innerHTML = '<div class="empty-state"><p>暂无设备信息</p></div>';
        return;
    }

    container.innerHTML = `
        <div class="info-card">
            <div class="info-card-header">
                <span class="info-card-icon">📱</span>
                <span class="info-card-label">产品型号</span>
            </div>
            <div class="info-card-value">${device.product || '-'}</div>
        </div>
        <div class="info-card">
            <div class="info-card-header">
                <span class="info-card-icon">📛</span>
                <span class="info-card-label">设备名称</span>
            </div>
            <div class="info-card-value">${device.name || '-'}</div>
        </div>
        ${device.bluetoothName ? `
        <div class="info-card">
            <div class="info-card-header">
                <span class="info-card-icon">📶</span>
                <span class="info-card-label">蓝牙名称</span>
            </div>
            <div class="info-card-value">${device.bluetoothName}</div>
        </div>
        ` : ''}
        ${device.macAddress ? `
        <div class="info-card">
            <div class="info-card-header">
                <span class="info-card-icon">🔗</span>
                <span class="info-card-label">MAC 地址</span>
            </div>
            <div class="info-card-value">${device.macAddress}</div>
        </div>
        ` : ''}
        ${device.model ? `
        <div class="info-card">
            <div class="info-card-header">
                <span class="info-card-icon">💻</span>
                <span class="info-card-label">型号</span>
            </div>
            <div class="info-card-value">${device.model}</div>
        </div>
        ` : ''}
        ${device.formatedProjNumber ? `
        <div class="info-card">
            <div class="info-card-header">
                <span class="info-card-icon">🔢</span>
                <span class="info-card-label">项目编号</span>
            </div>
            <div class="info-card-value">${device.formatedProjNumber}</div>
        </div>
        ` : ''}
        ${device.formatedFirmwareVersion ? `
        <div class="info-card">
            <div class="info-card-header">
                <span class="info-card-icon">📦</span>
                <span class="info-card-label">固件版本</span>
            </div>
            <div class="info-card-value">${device.formatedFirmwareVersion}</div>
        </div>
        ` : ''}
        ${device.userID ? `
        <div class="info-card">
            <div class="info-card-header">
                <span class="info-card-icon">👤</span>
                <span class="info-card-label">用户 ID</span>
            </div>
            <div class="info-card-value">${device.userID}</div>
        </div>
        ` : ''}
    `;
}

function renderLogs(logs) {
    const container = document.getElementById('logsContainer');
    const logCount = document.getElementById('logCount');

    logCount.textContent = logs.length;

    if (!logs || logs.length === 0) {
        container.innerHTML = '<div class="empty-state"><p>暂无日志</p></div>';
        return;
    }

    const sortedLogs = logs.sort((a, b) => (a.timestamp || 0) - (b.timestamp || 0));

    container.innerHTML = sortedLogs.map(log => {
        const timestamp = parseFloat(log.timestamp) || 0;
        const timeStr = formatTimestamp(timestamp);
        const level = log.level || 'INFO';
        const message = log.message || '';
        const subsystem = log.subsystem || '';
        const category = log.category || '';

        const levelClass = level.toLowerCase().includes('error') || level.toLowerCase().includes('fault') ? 'log-error' :
                          level.toLowerCase().includes('warn') ? 'log-warn' : 'log-info';

        return `
            <div class="log-item ${levelClass}">
                <span class="log-time">${timeStr}</span>
                <span class="log-level">${level}</span>
                <span class="log-message">${message}</span>
            </div>`;
    }).join('');
}

function downloadRawAudio() {
    if (recordingDetailData.rawAudioFile) {
        const url = API_CONFIG.getAudioUrl(recordingDetailData.rawAudioFile);
        window.open(url, '_blank');
    }
}

function downloadConvertedAudio() {
    if (recordingDetailData.convertedAudioFile) {
        const url = API_CONFIG.getAudioUrl(recordingDetailData.convertedAudioFile);
        window.open(url, '_blank');
    }
}

function exportCurrentReport() {
    if (recordingDetailData && Object.keys(recordingDetailData).length > 0) {
        exportAiAudioRecordingReport(recordingDetailData, sessionId);
    } else {
        alert('暂无数据可导出');
    }
}

function getLanguageLabel(lang) {
    const languageMap = {
        'zh-CN': '中文',
        'zh': '中文',
        'en': '英语',
        'en-US': '英语',
        'ja': '日语',
        'ko': '韩语',
        'fr': '法语',
        'de': '德语',
        'es': '西班牙语',
        'ru': '俄语',
        'pt': '葡萄牙语',
        'it': '意大利语',
        'ar': '阿拉伯语',
        'hi': '印地语',
        'th': '泰语',
        'vi': '越南语',
        'id': '印尼语',
        'ms': '马来语',
        'tr': '土耳其语',
        'pl': '波兰语',
        'nl': '荷兰语',
        'sv': '瑞典语',
        'no': '挪威语',
        'da': '丹麦语',
        'fi': '芬兰语',
        'cs': '捷克语',
        'hu': '匈牙利语',
        'ro': '罗马尼亚语',
        'bg': '保加利亚语',
        'hr': '克罗地亚语',
        'sk': '斯洛伐克语',
        'auto_lang': '自动检测'
    };
    return languageMap[lang] || lang || '-';
}

function formatDuration(seconds) {
    if (isNaN(seconds)) {
        return '-';
    }
    const isNegative = seconds < 0;
    const mins = isNegative ? -Math.floor(Math.abs(seconds) / 60) : Math.floor(seconds / 60);
    const secs = isNegative ? -Math.floor(Math.abs(seconds) % 60) : Math.floor(seconds % 60);

    if (mins > 0) {
        return `${mins}分${secs}秒`;
    }
    return `${secs}秒`;
}

function formatTimestamp(timestamp) {
    if (!timestamp) {
        return '-';
    }
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