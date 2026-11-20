// AI 对话报告列表页面脚本
let chatData = [];
let currentFilter = 'all';

document.addEventListener('DOMContentLoaded', function() {
    loadChatData();
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

function refreshList() {
    loadChatData();
}

async function loadChatData() {
    console.log('加载对话数据...');

    if (API_CONFIG.USE_API) {
        try {
            const response = await fetch(API_CONFIG.getChatUrl(), {
                headers: {
                    'Authorization': 'Bearer ' + localStorage.getItem('aibudsclaw-token')
                }
            });
            chatData = await API_CONFIG.handleApiResponse(response);
            console.log('从 API 加载数据成功：', chatData.length, '条');
        } catch (error) {
            console.error('从 API 加载数据失败：', error);
        }
    } else {
        chatData = MOCK_DATA.chatData;
        console.log('使用测试数据');
    }

    updateOverviewStats();
    renderChatList(chatData);
}

function updateOverviewStats() {
    const totalSessions = chatData.length;
    
    let totalDuration = 0;
    chatData.forEach(item => {
        totalDuration += parseFloat(item.duration) || 0;
    });
    
    const avgDuration = totalSessions > 0 ? totalDuration / totalSessions : 0;

    document.getElementById('totalSessions').textContent = totalSessions;
    document.getElementById('avgSessionDuration').textContent = formatDuration(avgDuration);
}

function renderChatList(data) {
    const container = document.getElementById('chatListContainer');

    if (!data || data.length === 0) {
        container.innerHTML = '<div class="empty-state"><p>暂无对话记录</p></div>';
        return;
    }

    container.innerHTML = data.map((item, index) => {
        const startTime = formatTimestamp(item.startTime);
        const duration = formatDuration(item.duration);
        const userSpeechCount = countUserSpeeches(item);
        const aiResponseCount = countAIResponses(item);
        const languageLabel = getLanguageLabel(item.language);
        const wasAutoEnded = item.wasAutoEnded || false;
        const segments = item.segmentAudioFiles ? item.segmentAudioFiles.length : 0;
        const sessionId = extractSessionId(item);

        return `
            <div class="chat-card" onclick="goToDetail(${index})">
                <div class="chat-card-header">
                    <div class="session-badge">
                        <span class="session-icon">💬</span>
                        <span class="session-id">#${String(index + 1).padStart(3, '0')}</span>
                    </div>
                    <div class="session-time">${startTime}</div>
                </div>
                <div class="chat-card-body">
                    <div class="chat-main-info">
                        <h4 class="session-title">AI 对话会话</h4>
                        <p class="session-meta">
                            <span class="meta-tag language">${languageLabel}</span>
                            <span class="meta-tag duration">⏱️ ${duration}</span>
                            ${wasAutoEnded ? '<span class="meta-tag auto-end">⏰ 自动结束</span>' : ''}
                        </p>
                    </div>
                    <div class="chat-stats-row">
                        <div class="mini-stat">
                            <span class="mini-stat-icon">🎤</span>
                            <span class="mini-stat-value">${userSpeechCount}</span>
                            <span class="mini-stat-label">用户发言</span>
                        </div>
                        <div class="mini-stat">
                            <span class="mini-stat-icon">🤖</span>
                            <span class="mini-stat-value">${aiResponseCount}</span>
                            <span class="mini-stat-label">AI 响应</span>
                        </div>
                        <div class="mini-stat">
                            <span class="mini-stat-icon">🎵</span>
                            <span class="mini-stat-value">${segments}</span>
                            <span class="mini-stat-label">音频片段</span>
                        </div>
                    </div>
                </div>
                <div class="chat-card-footer">
                    <div class="session-id-small">ID: session_${sessionId}</div>
                    <button class="btn btn-primary btn-sm" onclick="event.stopPropagation(); goToDetail(${index})">
                        查看详情
                        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <line x1="5" y1="12" x2="19" y2="12"></line>
                            <polyline points="12 5 19 12 12 19"></polyline>
                        </svg>
                    </button>
                </div>
            </div>
        `;
    }).join('');
}

function goToDetail(index) {
    const item = chatData[index];
    if (!item) return;

    const params = new URLSearchParams({
        index: index,
        sessionId: extractSessionId(item)
    });

    window.location.href = `ai-chat-detail.html?${params.toString()}`;
}

function extractSessionId(item) {
    return Math.abs(Math.floor(item.startTime));
}

function formatTimestamp(timestamp) {
    if (!timestamp) return '-';
    const date = new Date(timestamp * 1000);
    const year = date.getFullYear();
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const day = String(date.getDate()).padStart(2, '0');
    const hours = String(date.getHours()).padStart(2, '0');
    const minutes = String(date.getMinutes()).padStart(2, '0');
    return `${year}-${month}-${day} ${hours}:${minutes}`;
}

function formatDuration(seconds) {
    if (!seconds && seconds !== 0) return '-';
    const secs = Math.floor(seconds);
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

function countUserSpeeches(item) {
    if (!item) return 0;
    if (!item.segmentAudioFiles) return 0;
    return item.segmentAudioFiles.filter(e => !e.split('/').pop().startsWith('respond_')).length;
}

function countAIResponses(item) {
    if (!item) return 0;
    if (!item.segmentAudioFiles) return 0;
    return item.segmentAudioFiles.filter(e => e.split('/').pop().startsWith('respond_')).length;
}

function getLanguageLabel(lang) {
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
    return labels[lang] || lang || '-';
}

setInterval(loadChatData, 30000);
