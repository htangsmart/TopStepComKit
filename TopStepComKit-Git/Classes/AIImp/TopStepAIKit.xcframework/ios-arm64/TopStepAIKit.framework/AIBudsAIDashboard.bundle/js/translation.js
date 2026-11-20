// 同声传译报告列表页面脚本
let translationData = [];

document.addEventListener('DOMContentLoaded', function() {
    loadTranslationData();
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
    loadTranslationData();
}

async function loadTranslationData() {
    console.log('加载同声传译数据...');

    if (API_CONFIG.USE_API) {
        try {
            const response = await fetch(API_CONFIG.getTranslationUrl(), {
                headers: {
                    'Authorization': 'Bearer ' + localStorage.getItem('aibudsclaw-token')
                }
            });
            translationData = await API_CONFIG.handleApiResponse(response);
            console.log('从 API 加载数据成功：', translationData.length, '条');
        } catch (error) {
            console.error('从 API 加载数据失败：', error);
        }
    } else {
        translationData = MOCK_DATA.translationData || [];
        console.log('使用测试数据');
    }

    updateOverviewStats();
    renderTranslationList(translationData);
}

function updateOverviewStats() {
    const totalSessions = translationData.length;
    
    let totalDuration = 0;
    translationData.forEach(item => {
        totalDuration += parseFloat(item.duration) || 0;
    });
    
    const avgDuration = totalSessions > 0 ? totalDuration / totalSessions : 0;

    document.getElementById('totalSessions').textContent = totalSessions;
    document.getElementById('avgSessionDuration').textContent = formatDuration(avgDuration);
}

function renderTranslationList(data) {
    const container = document.getElementById('translationListContainer');

    if (!data || data.length === 0) {
        container.innerHTML = '<div class="empty-state"><p>暂无同声传译记录</p></div>';
        return;
    }

    container.innerHTML = data.map((item, index) => {
        const startTime = formatTimestamp(item.startTime);
        const duration = formatDuration(item.duration);
        const sourceLanguage = getLanguageLabel(item.sourceLanguage) || item.sourceLanguage || '-';
        const targetLanguage = getLanguageLabel(item.targetLanguage) || item.targetLanguage || '-';
        const enableTTS = item.enableTTS ? '启用' : '禁用';

        return `
            <div class="chat-card" onclick="goToDetail(${index})">
                <div class="chat-card-header">
                    <div class="session-badge">
                        <span class="session-icon">🌐</span>
                        <span class="session-id">#${String(index + 1).padStart(3, '0')}</span>
                    </div>
                    <div class="session-time">${startTime}</div>
                </div>
                <div class="chat-card-body">
                    <div class="chat-main-info">
                        <div class="language-pair">
                            <span class="language-tag">${sourceLanguage}</span>
                            <span class="arrow">→</span>
                            <span class="language-tag">${targetLanguage}</span>
                        </div>
                        <div class="session-meta">
                            <span class="meta-tag duration">⏱️ ${duration}</span>
                            <span class="meta-tag tts">🔊 ${enableTTS}</span>
                        </div>
                    </div>
                    <div class="chat-stats-row">
                        <div class="mini-stat">
                            <span class="mini-stat-icon">🎤</span>
                            <span class="mini-stat-value">${countSpeakerSegments(item)}</span>
                            <span class="mini-stat-label">说话人片段</span>
                        </div>
                        <div class="mini-stat">
                            <span class="mini-stat-icon">🔊</span>
                            <span class="mini-stat-value">${countTtsSegments(item)}</span>
                            <span class="mini-stat-label">TTS 片段</span>
                        </div>
                        <div class="mini-stat">
                            <span class="mini-stat-icon">📝</span>
                            <span class="mini-stat-value">${countSentences(item)}</span>
                            <span class="mini-stat-label">翻译句数</span>
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

function countSpeakerSegments(item) {
    return item.sourceSentencesCount || 0;
}

function countTtsSegments(item) {
    return item.ttsSegmentsCount || 0;
}

function countSentences(item) {
    return item.targetSentencesCount || 0;
}

function goToDetail(index) {
    const item = translationData[index];
    const sessionId = item.startTime ? Math.floor(item.startTime) : index;
    window.location.href = `translation-detail.html?sessionId=${sessionId}&index=${index}`;
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
    return `${year}-${month}-${day} ${hours}:${minutes}:${seconds}`;
}

function formatDuration(seconds) {
    if (!seconds || seconds <= 0) return '-';
    const mins = Math.floor(seconds / 60);
    const secs = Math.floor(seconds % 60);
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