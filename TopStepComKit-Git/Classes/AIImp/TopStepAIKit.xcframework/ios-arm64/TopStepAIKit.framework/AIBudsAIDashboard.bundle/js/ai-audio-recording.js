// AI 录音报告列表页面脚本
let recordingData = [];

document.addEventListener('DOMContentLoaded', function() {
    loadRecordingData();
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

function refreshList() {
    loadRecordingData();
}

async function loadRecordingData() {
    console.log('加载 AI 录音数据...');

    if (API_CONFIG.USE_API) {
        try {
            const response = await fetch(API_CONFIG.getAiAudioRecordingUrl(), {
                headers: {
                    'Authorization': 'Bearer ' + localStorage.getItem('aibudsclaw-token')
                }
            });
            recordingData = await API_CONFIG.handleApiResponse(response);
            console.log('从 API 加载数据成功：', recordingData.length, '条');
        } catch (error) {
            console.error('从 API 加载数据失败：', error);
        }
    } else {
        recordingData = MOCK_DATA.aiAudioRecordingData || [];
        console.log('使用测试数据');
    }

    updateOverviewStats();
    renderRecordingList(recordingData);
}

function updateOverviewStats() {
    const totalSessions = recordingData.length;

    let totalDuration = 0;
    recordingData.forEach(item => {
        totalDuration += parseFloat(item.duration) || 0;
    });

    const avgDuration = totalSessions > 0 ? totalDuration / totalSessions : 0;

    document.getElementById('totalSessions').textContent = totalSessions;
    document.getElementById('avgSessionDuration').textContent = formatDuration(avgDuration);
}

function renderRecordingList(data) {
    const container = document.getElementById('recordingListContainer');

    if (!data || data.length === 0) {
        container.innerHTML = '<div class="empty-state"><p>暂无 AI 录音记录</p></div>';
        return;
    }

    container.innerHTML = data.map((item, index) => {
        const startTime = formatTimestamp(item.startTime);
        const duration = formatDuration(item.duration);
        const transcriptCount = item.transcriptCount || 0;
        const speakerSegmentCount = item.speakerSegmentCount || 0;
        const isOfflineRecording = item.isOfflineRecording ? '离线录音' : 'AI 录音';
        const sessionId = extractSessionId(item);

        return `
            <div class="chat-card" onclick="goToDetail(${index})">
                <div class="chat-card-header">
                    <div class="session-badge">
                        <span class="session-icon">🎙️</span>
                        <span class="session-id">#${String(index + 1).padStart(3, '0')}</span>
                    </div>
                    <div class="session-time">${startTime}</div>
                </div>
                <div class="chat-card-body">
                    <div class="chat-main-info">
                        <div class="recording-scene">
                            <span class="scene-tag">${item.recordingScene || '-'}</span>
                        </div>
                        <div class="session-meta">
                            <span class="meta-tag duration">⏱️ ${duration}</span>
                            <span class="meta-tag offline">${isOfflineRecording}</span>
                        </div>
                    </div>
                    <div class="chat-stats-row">
                        <div class="mini-stat">
                            <span class="mini-stat-icon">📝</span>
                            <span class="mini-stat-value">${transcriptCount}</span>
                            <span class="mini-stat-label">转录数</span>
                        </div>
                        <div class="mini-stat">
                            <span class="mini-stat-icon">👥</span>
                            <span class="mini-stat-value">${speakerSegmentCount}</span>
                            <span class="mini-stat-label">说话片段数</span>
                        </div>
                    </div>
                </div>
                <div class="chat-card-footer">
                    <span class="ai-vendor">${item.aiServiceVendor || '-'}</span>
                    <button class="btn btn-primary btn-sm" onclick="event.stopPropagation(); goToDetail(${index})">
                        查看详情
                        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <line x1="5" y1="12" x2="19" y2="12"></line>
                            <polyline points="12 5 19 12 12 19"></polyline>
                        </svg>
                    </button>
                </div>
            </div>`;
    }).join('');
}

function goToDetail(index) {
    const item = recordingData[index];
    if (!item) return;

    const params = new URLSearchParams({
        index: index,
        sessionId: item.startTime ? Math.floor(item.startTime) : index
    });

    window.location.href = 'ai-audio-recording-detail.html?' + params.toString();
}

function extractSessionId(item) {
    if (item.sessionId) return item.sessionId;
    if (item.session_id) return item.session_id;
    if (item.id) return item.id;
    if (item._id) return item._id;
    return 'unknown';
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
        'sk': '斯洛伐克语'
    };
    return languageMap[lang] || lang || '-';
}

function formatDuration(seconds) {
    if (isNaN(seconds)) {
        return '-';
    }
    const mins = Math.floor(seconds / 60);
    const secs = Math.floor(seconds % 60);
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
    return `${year}-${month}-${day} ${hours}:${minutes}:${seconds}`;
}