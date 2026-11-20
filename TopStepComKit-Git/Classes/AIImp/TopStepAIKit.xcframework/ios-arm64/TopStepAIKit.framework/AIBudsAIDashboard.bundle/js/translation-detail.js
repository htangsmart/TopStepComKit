// 同声传译详情页面脚本
let translationDetailData = null;
let sessionId = null;

document.addEventListener('DOMContentLoaded', function() {
    const params = new URLSearchParams(window.location.search);
    sessionId = params.get('sessionId') || 'unknown';

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

async function loadDetailData() {
    console.log('加载同声传译详情数据...');

    const params = new URLSearchParams(window.location.search);
    const index = params.get('index');
    const sessionId = params.get('sessionId');

    if (API_CONFIG.USE_API) {
        try {
            const response = await fetch(API_CONFIG.getTranslationDetailUrl(sessionId), {
                headers: {
                    'Authorization': 'Bearer ' + localStorage.getItem('aibudsclaw-token')
                }
            });
            translationDetailData = await API_CONFIG.handleApiResponse(response);
            console.log(translationDetailData);
            console.log('从 API 加载详情数据成功');
        } catch (error) {
            console.error('从 API 加载详情数据失败：', error);
        }
    } else {
        const mockData = MOCK_DATA.translationData || [];
        const dataIndex = parseInt(index) || 0;
        translationDetailData = mockData[dataIndex] || {};
        console.log('使用测试数据');
    }

    if (translationDetailData) {
        renderDetail();
    }
}

function renderDetail() {
    renderBasicInfo();
    renderTranslationContent();
    renderOriginalAudio();
    renderSpeakerSegments();
    renderTtsSegments();
    renderDeviceInfo();
    renderEventsTimeline(translationDetailData.events || [], translationDetailData.startTime || 0);
    renderLogs();
}

function renderBasicInfo() {
    const data = translationDetailData;

    const sessionId = data.sessionId || (data.startTime ? Math.floor(data.startTime) : 'unknown');
    document.getElementById('detailChatId').textContent = `#session_${sessionId}`;
    document.getElementById('detailStartTime').textContent = formatTimestamp(data.startTime);
    document.getElementById('detailEndTime').textContent = formatTimestamp(data.endTime);
    document.getElementById('detailDuration').textContent = formatDuration(data.duration);
    document.getElementById('detailAiServiceVendor').textContent = data.aiServiceVendor || '-';
    document.getElementById('detailSourceLanguage').textContent = getLanguageLabel(data.sourceLanguage) || data.sourceLanguage || '-';
    document.getElementById('detailTargetLanguage').textContent = getLanguageLabel(data.targetLanguage) || data.targetLanguage || '-';
    document.getElementById('detailEnableTTS').textContent = data.enableTTS ? '是' : '否';
    document.getElementById('detailTtsFormat').textContent = data.ttsFormat || '-';
    document.getElementById('detailUsesInternalAudioRecording').textContent = data.usesInternalAudioRecording ? '是' : '否';
    document.getElementById('detailPreferSpeakerOutput').textContent = data.preferSpeakerOutput ? '是' : '否';
    document.getElementById('detailEnableVoicePlayback').textContent = data.enableVoicePlayback ? '是' : '否';
    document.getElementById('detailStopReason').textContent = data.stopReason || '-';
}

function renderTranslationContent() {
    const container = document.getElementById('translationContentContainer');
    const sourceSentences = translationDetailData.sourceSentences || [];
    const targetSentences = translationDetailData.targetSentences || [];
    const ttsSegments = translationDetailData.ttsSegments || [];

    if (sourceSentences.length === 0 && targetSentences.length === 0) {
        container.innerHTML = '<div class="empty-state"><p>暂无翻译内容</p></div>';
        return;
    }

    const sourceMap = new Map();
    sourceSentences.forEach(s => {
        if (s && s.sentenceSequence !== undefined) {
            sourceMap.set(s.sentenceSequence, s);
        }
    });

    const targetMap = new Map();
    targetSentences.forEach(t => {
        if (t && t.sentenceSequence !== undefined) {
            targetMap.set(t.sentenceSequence, t);
        }
    });

    const allSequences = new Set([...sourceMap.keys(), ...targetMap.keys()]);
    const sortedSequences = [...allSequences].sort((a, b) => a - b);

    container.innerHTML = sortedSequences.map((seq, idx) => {
        const sourceItem = sourceMap.get(seq);
        const targetItem = targetMap.get(seq);
        const sourceText = sourceItem ? sourceItem.sentenceText : '';
        const targetText = targetItem ? targetItem.sentenceText : '';
        const timestamp = sourceItem ? sourceItem.timestamp : (targetItem ? targetItem.timestamp : 0);
        const moment = sourceItem ? sourceItem.moment : (targetItem ? targetItem.moment : '');
        const formattedTimestamp = formatTimestamp(timestamp);

        const matchedTtsSegments = ttsSegments.filter(tts => {
            return tts.associatedTargetTextSequence !== undefined && 
                   parseInt(tts.associatedTargetTextSequence) === seq;
        });

        matchedTtsSegments.sort((a, b) => {
            const seqA = parseInt(a.modelResponseSequence) || 0;
            const seqB = parseInt(b.modelResponseSequence) || 0;
            return seqA - seqB;
        });

        const audioUrls = matchedTtsSegments
            .filter(tts => tts.ttsSegmentAudioFile)
            .map(tts => API_CONFIG.getAudioUrl(tts.ttsSegmentAudioFile));

        const hasAudio = audioUrls.length > 0;
        const audioDataId = `audio-${seq}`;

        if (hasAudio) {
            window[audioDataId] = {
                urls: audioUrls,
                currentIndex: 0,
                audio: null,
                nextAudio: null,
                isPlaying: false
            };
        }

        const playButton = hasAudio ? `
            <button class="play-audio-btn" id="${audioDataId}-btn" onclick="playTranslationAudio('${audioDataId}')" title="播放译文音频">
                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <polygon points="11 5 6 9 2 9 2 15 6 15 11 19 11 5"></polygon>
                    <path class="wave wave1" d="M15.54 8.46a5 5 0 0 1 0 7.07"></path>
                    <path class="wave wave2" d="M19.07 4.93a10 10 0 0 1 0 14.14"></path>
                </svg>
            </button>
        ` : '';

        return `
            <div class="translation-item">
                <div class="translation-header">
                    <div class="translation-header-left">
                        <span class="translation-number">#${String(idx + 1).padStart(3, '0')}</span>
                        ${moment ? `<span class="translation-moment">${moment}</span>` : ''}
                    </div>
                    <span class="translation-timestamp">${formattedTimestamp}</span>
                </div>
                <div class="translation-content">
                    <div class="source-text">
                        <span class="lang-label">原文 (${getLanguageLabel(translationDetailData.sourceLanguage)})</span>
                        <p>${sourceText || '-'}</p>
                    </div>
                    <div class="target-text">
                        <div class="target-text-header">
                            <span class="lang-label">译文 (${getLanguageLabel(translationDetailData.targetLanguage)})</span>
                            ${playButton}
                        </div>
                        <p>${targetText || '-'}</p>
                    </div>
                </div>
            </div>`;
    }).join('');
}

function playTranslationAudio(audioDataId) {
    const audioData = window[audioDataId];
    if (!audioData || audioData.urls.length === 0) return;

    if (audioData.isPlaying) {
        audioData.isPlaying = false;
        if (audioData.audio) {
            audioData.audio.pause();
            audioData.audio = null;
        }
        updatePlayButton(audioDataId, false);
        return;
    }

    audioData.isPlaying = true;
    updatePlayButton(audioDataId, true);

    const audioFiles = audioData.urls.map(url => {
        let path = new URL(url).pathname.substring(1);
        if (path.startsWith('/')) {
            path = path.substring(1);
        }
        return path;
    });

    fetch(API_CONFIG.getMergeAudioUrl(), {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ' + localStorage.getItem('aibudsclaw-token')
        },
        body: JSON.stringify(audioFiles)
    })
    .then(response => response.blob())
    .then(blob => {
        const audioUrl = URL.createObjectURL(blob);
        const audio = new Audio(audioUrl);
        audioData.audio = audio;

        audio.onended = () => {
            URL.revokeObjectURL(audioUrl);
            audioData.isPlaying = false;
            audioData.audio = null;
            updatePlayButton(audioDataId, false);
        };

        audio.onerror = () => {
            audioData.isPlaying = false;
            audioData.audio = null;
            updatePlayButton(audioDataId, false);
        };

        audio.play().catch(() => {
            audioData.isPlaying = false;
            updatePlayButton(audioDataId, false);
        });
    })
    .catch(() => {
        audioData.isPlaying = false;
        updatePlayButton(audioDataId, false);
    });
}

function updatePlayButton(audioDataId, isPlaying) {
    const btn = document.getElementById(`${audioDataId}-btn`);
    if (!btn) return;

    if (isPlaying) {
        btn.innerHTML = `
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" class="speaker-icon">
                <polygon points="11 5 6 9 2 9 2 15 6 15 11 19 11 5"></polygon>
                <path class="wave wave1" d="M15.54 8.46a5 5 0 0 1 0 7.07"></path>
                <path class="wave wave2" d="M19.07 4.93a10 10 0 0 1 0 14.14"></path>
            </svg>
        `;
        btn.classList.add('playing');
    } else {
        btn.innerHTML = `
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" class="speaker-icon">
                <polygon points="11 5 6 9 2 9 2 15 6 15 11 19 11 5"></polygon>
                <path class="wave wave1" d="M15.54 8.46a5 5 0 0 1 0 7.07"></path>
                <path class="wave wave2" d="M19.07 4.93a10 10 0 0 1 0 14.14"></path>
            </svg>
        `;
        btn.classList.remove('playing');
    }
}

function renderOriginalAudio() {
    const data = translationDetailData;

    document.getElementById('detailRawAudioFormat').textContent = data.rawAudioFormat || '-';
    document.getElementById('detailAudioChannel').textContent = data.rawAudioChannel || '单声道';
    document.getElementById('detailAudioDuration').textContent = formatDuration(data.duration);

    const rawAudioContainer = document.getElementById('rawAudioContainer');
    const audioControlsWrapper = rawAudioContainer.querySelector('.audio-controls-wrapper');
    const audioWaveform = rawAudioContainer.querySelector('.audio-waveform');
    const audioInfoRow = rawAudioContainer.querySelector('.audio-info-row');
    const audioPlayer = audioControlsWrapper.querySelector('audio');
    const rawAudioFile = data.rawAudioFile;

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

    const waveformContainer = document.querySelector('#audioWaveform .waveform-container');
    if (waveformContainer) {
        waveformContainer.innerHTML = generateWaveformBars(50).map(h =>
            `<span class="wave-bar" style="--base-height: ${h}px;"></span>`
        ).join('');
    }
}

function downloadRawAudio() {
    const rawAudioFile = translationDetailData.rawAudioFile;
    if (!rawAudioFile) {
        alert('暂无原始音频文件');
        return;
    }
    const link = document.createElement('a');
    link.href = API_CONFIG.getAudioUrl(rawAudioFile);
    link.download = rawAudioFile.split('/').pop() || 'raw_audio.mp3';
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
}

function renderSpeakerSegments() {
    const container = document.getElementById('speakerSegmentsContainer');
    const segments = translationDetailData.speakerSegments || [];

    if (segments.length === 0) {
        container.innerHTML = '<div class="empty-state"><p>暂无说话人片段</p></div>';
        return;
    }

    container.innerHTML = segments.map((segment, index) => {
        const startTime = parseFloat(segment.startTime) || 0;
        const endTime = parseFloat(segment.endTime) || 0;
        const duration = endTime - startTime;

        return `
            <div class="segment-card">
                <div class="segment-header">
                    <span class="segment-number">#${String(index + 1).padStart(3, '0')}</span>
                    <span class="speaker-id">说话人：${segment.speakerId || '未知'}</span>
                </div>
                <div class="segment-time">
                    <span>${formatTimestamp(startTime)}</span>
                    <span>→</span>
                    <span>${formatTimestamp(endTime)}</span>
                    <span class="duration-badge">${formatDuration(duration)}</span>
                </div>
                <div class="segment-text">
                    <p>${segment.text || '-'}</p>
                </div>
                <div class="segment-waveform">
                    <div class="waveform-visual">
                        ${generateWaveformBars(30).map(h => `<span style="height: ${h}px;"></span>`).join('')}
                    </div>
                </div>
            </div>`;
    }).join('');
}

function renderTtsSegments() {
    const container = document.getElementById('ttsSegmentsContainer');
    const segments = translationDetailData.ttsSegments || [];

    if (segments.length === 0) {
        container.innerHTML = '<div class="empty-state"><p>暂无 TTS 片段</p></div>';
        return;
    }

    let html = '<div class="tts-segments-header">';
    html += '<div class="tts-segment-item">序号</div>';
    html += '<div class="tts-segment-item">时间</div>';
    html += '<div class="tts-segment-item">关联译文</div>';
    html += '<div class="tts-segment-item">请求 ID</div>';
    html += '<div class="tts-segment-item">响应序号</div>';
    html += '<div class="tts-segment-item">波形</div>';
    html += '<div class="tts-segment-item">音频</div>';
    html += '</div>';

    segments.forEach((segment, index) => {
        const timestamp = parseFloat(segment.timestamp) || 0;
        const audioFile = segment.ttsSegmentAudioFile;
        const base64Audio = segment.base64AudioData;
        const hasAudio = audioFile && audioFile.trim();
        const hasBase64 = base64Audio && base64Audio.trim();
        const audioId = 'tts-audio-' + index;

        html += '<div class="tts-segment-row">';
        html += '<div class="tts-segment-item"><span class="tts-segment-number">#';
        html += String(index + 1).padStart(3, '0') + '</span></div>';

        html += '<div class="tts-segment-item"><span class="tts-segment-time">';
        html += formatTimestamp(timestamp) + '</span></div>';

        html += '<div class="tts-segment-item tts-segment-text">';
        html += '<span>' + (segment.associatedTargetTextSequence) + '</span></div>';

        html += '<div class="tts-segment-item"><span>';
        html += (segment.requestId || '-') + '</span></div>';

        html += '<div class="tts-segment-item"><span>';
        html += (segment.modelResponseSequence) + '</span></div>';

        html += '<div class="tts-segment-item tts-segment-waveform"><div class="mini-waveform" id="waveform-' + audioId + '">';
        const bars = generateWaveformBars(15);
        bars.forEach(h => {
            html += '<span class="mini-wave-bar" style="height: ' + h + 'px;"></span>';
        });
        html += '</div></div>';

        html += '<div class="tts-segment-item tts-segment-player">';
        if (hasAudio) {
            html += '<audio id="' + audioId + '" class="tts-audio-player" src="' + API_CONFIG.getAudioUrl(audioFile) + '" controls>';
            html += '您的浏览器不支持音频播放';
            html += '</audio>';
        } else {
            html += '<span class="no-audio">-</span>';
        }
        html += '</div></div>';

        if (hasBase64) {
            const dataUri = base64Audio;
            const truncated = dataUri.length > 200;
            const displayStr = truncated ? dataUri.substring(0, 100) + '...' + dataUri.substring(dataUri.length - 100) : dataUri;

            html += '<div class="tts-segment-base64" id="base64-' + audioId + '">';
            html += '<div class="tts-base64-header">';
            html += '<span class="tts-base64-label">🔊 Base64 音频字符串 (PCM 音频原始数据的 Base64 编码，非标准音频格式)</span>';
            html += '<div class="tts-base64-actions">';
            html += `<button class="tts-base64-copy" onclick="copyBase64('${audioId}', '${dataUri.replace(/'/g, "\\'")}')">复制</button>`;
            html += '</div></div>';
            html += `<div class="tts-base64-value" id="base64-value-${audioId}">`;
            html += `<code>${displayStr}</code>`;
            if (truncated) {
                html += `<button class="tts-base64-expand" onclick="expandBase64('${audioId}', '${dataUri.replace(/'/g, "\\'")}')">显示全部</button>`;
            }
            html += '</div>';
            html += `<span class="tts-base64-copy-tip" id="copy-tip-${audioId}"></span>`;
            html += '</div>';
        } else {
            html += '<div class="tts-segment-base64 tts-base64-empty" id="base64-' + audioId + '">';
            html += '<span class="tts-base64-label">🔊 Base64 音频字符串</span>';
            html += '<span class="tts-base64-no-data">暂无数据</span>';
            html += '</div>';
        }
    });

    container.innerHTML = html;

    segments.forEach((segment, index) => {
        const audioId = 'tts-audio-' + index;
        const audio = document.getElementById(audioId);
        const waveform = document.getElementById('waveform-' + audioId);
        
        if (audio && waveform) {
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
    });
}

function expandBase64(audioId, fullBase64) {
    const valueEl = document.getElementById('base64-value-' + audioId);
    const codeEl = valueEl.querySelector('code');
    const btnEl = valueEl.querySelector('button');
    codeEl.textContent = fullBase64;
    valueEl.classList.add('expanded');
    btnEl.textContent = '收起';
    btnEl.setAttribute('onclick', `collapseBase64('${audioId}', '${fullBase64.replace(/'/g, "\\'")}')`);
}

function collapseBase64(audioId, fullBase64) {
    const valueEl = document.getElementById('base64-value-' + audioId);
    const codeEl = valueEl.querySelector('code');
    const btnEl = valueEl.querySelector('button');
    const displayStr = fullBase64.substring(0, 100) + '...' + fullBase64.substring(fullBase64.length - 100);
    codeEl.textContent = displayStr;
    valueEl.classList.remove('expanded');
    btnEl.textContent = '显示全部';
    btnEl.setAttribute('onclick', `expandBase64('${audioId}', '${fullBase64.replace(/'/g, "\\'")}')`);
}

function copyBase64(audioId, base64String) {
    navigator.clipboard.writeText(base64String).then(() => {
        const tipEl = document.getElementById('copy-tip-' + audioId);
        tipEl.textContent = '已复制!';
        tipEl.classList.add('show');
        setTimeout(() => {
            tipEl.classList.remove('show');
        }, 2000);
    }).catch(err => {
        console.error('复制失败:', err);
    });
}

function renderDeviceInfo() {
    const container = document.getElementById('deviceInfoContainer');
    const device = translationDetailData.device;

    if (!device) {
        container.innerHTML = '<div class="empty-state"><p>暂无设备信息</p></div>';
        return;
    }

    const deviceInfo = [
        { label: '产品类型', value: device.product || '-', icon: '📱' },
        { label: '名称', value: device.name || '-', icon: '🏷️' },
        { label: '蓝牙名称', value: device.bluetoothName || '-', icon: '🔵' },
        { label: '蓝牙 MAC', value: device.macAddress || '-', icon: '📶' },
        { label: '设备型号', value: device.model || '-', icon: '🆙' },
        { label: '项目号', value: device.formatedProjNumber || '-', icon: '📊' },
        { label: '固件版本', value: device.formatedFirmwareVersion || '-', icon: '🔧' },
        { label: '绑定用户 ID', value: device.userID || '-', icon: '👤' }
    ];

    container.innerHTML = deviceInfo.map(item => `
        <div class="info-card">
            <div class="info-card-header">
                <span class="info-card-icon">${item.icon}</span>
                <span class="info-card-label">${item.label}</span>
            </div>
            <div class="info-card-value">${item.value}</div>
        </div>
    `).join('');
}

function renderLogs() {
    const container = document.getElementById('logsContainer');
    const countEl = document.getElementById('logCount');
    const logs = translationDetailData.logs || [];

    countEl.textContent = logs.length;

    if (logs.length === 0) {
        container.innerHTML = '<p class="empty-state">暂无错误警告日志</p>';
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

function generateWaveformBars(count) {
    const bars = [];
    for (let i = 0; i < count; i++) {
        bars.push(Math.floor(Math.random() * 20) + 8);
    }
    return bars;
}

function formatTimestamp(timestamp) {
    if (!timestamp) return '-';
    const date = new Date(parseFloat(timestamp) * 1000);
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

function getLanguageLabel(language) {
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
        'sk': '斯洛伐克语'
    };
    return languageMap[language] || language;
}

function exportCurrentReport() {
    if (!translationDetailData) {
        alert('暂无数据可导出');
        return;
    }

    const exporter = window.TranslationReportExporter;
    if (exporter && exporter.exportReport) {
        exporter.exportReport(translationDetailData, sessionId);
    } else {
        alert('导出模块未加载');
    }
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
        'aiRespondVoicePlaybackDidStart': { icon: '🔊', color: 'purple' },
        'aiRespondVoicePlaybackDidStop': { icon: '🔇', color: 'purple' },
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
