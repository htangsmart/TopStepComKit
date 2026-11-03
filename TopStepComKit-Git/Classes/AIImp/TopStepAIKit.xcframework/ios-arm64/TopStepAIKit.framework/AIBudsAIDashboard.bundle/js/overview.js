// 数据概览页面脚本
document.addEventListener('DOMContentLoaded', function() {
    // 加载会话数量
    loadSessionCounts();
});

// 退出登录
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

// 加载会话数量
async function loadSessionCounts() {
    if (API_CONFIG.USE_API) {
        try {
            const response = await fetch(API_CONFIG.getOverviewUrl(), {
                headers: {
                    'Authorization': 'Bearer ' + localStorage.getItem('aibudsclaw-token')
                }
            });
            const data = await API_CONFIG.handleApiResponse(response);
            
            document.getElementById('aiChatCount').textContent = data.aiChatSessionCount || 0;
            document.getElementById('translationCount').textContent = data.simultaneousInterpretationCount || 0;
            document.getElementById('aiAudioRecordingCount').textContent = data.aiAudioRecordingCount || 0;
        } catch (error) {
            console.error('加载会话数量失败：', error);
            // 使用本地存储数据作为备用
            loadLocalSessionCounts();
        }
    } else {
        loadLocalSessionCounts();
    }
}

// 从本地存储加载会话数量
function loadLocalSessionCounts() {
    const aiChatSessions = JSON.parse(localStorage.getItem('aiChatSessions') || '[]');
    const translationSessions = JSON.parse(localStorage.getItem('translationSessions') || '[]');
    const aiAudioRecordingSessions = JSON.parse(localStorage.getItem('aiAudioRecordingSessions') || '[]');
    
    document.getElementById('aiChatCount').textContent = aiChatSessions.length;
    document.getElementById('translationCount').textContent = translationSessions.length;
    document.getElementById('aiAudioRecordingCount').textContent = aiAudioRecordingSessions.length;
}

// 自动刷新数据
setInterval(loadSessionCounts, 30000); // 每30秒刷新一次