// AI 录音报告导出功能
function exportAiAudioRecordingReport(data, sessionId) {
    const html = generateAiAudioRecordingReportHTML(data, sessionId);
    const blob = new Blob([html], { type: 'text/html;charset=utf-8' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    const timestamp = new Date().toISOString().slice(0, 19).replace(/[:-]/g, '');
    a.href = url;
    a.download = `AI 录音报告_${timestamp}.html`;
    document.body.appendChild(a);
    a.click();
    document.body.removeChild(a);
    URL.revokeObjectURL(url);
}

function getLanguageLabel(lang) {
    const langMap = {
        'zh-CN': '简体中文',
        'zh-HK': '繁体中文 (香港)',
        'zh-TW': '繁体中文 (台湾)',
        'en': 'English',
        'ja': '日本語',
        'ko': '한국어',
        'fr': 'Français',
        'de': 'Deutsch',
        'es': 'Español',
        'ru': 'Русский',
        'pt': 'Português',
        'ar': 'العربية',
        'hi': 'हिन्दी'
    };
    return langMap[lang] || lang;
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

function generateAiAudioRecordingReportHTML(data, sessionId) {
    const startTime = formatTimestamp(data.startTime);
    const endTime = formatTimestamp(data.endTime);
    const duration = formatDuration(data.duration);

    const transcripts = data.transcripts || [];
    const speakerSegments = data.speakerSegments || [];

    const transcriptsHTML = transcripts.length > 0 ? transcripts.map((t, i) => {
        const timestamp = parseFloat(t.timestamp) || 0;
        const timeStr = formatTimestamp(timestamp);
        const sequence = t.transcriptSequence || (i + 1);
        return `
        <div class="transcript-item">
            <div class="transcript-header">
                <div class="transcript-info">
                    <span class="transcript-badge">#${sequence}</span>
                    <span class="transcript-time">⏰ ${timeStr}</span>
                </div>
                <div class="transcript-meta">
                    <span class="meta-tag">模型序号：${t.modelResponseSequence || '-'}</span>
                </div>
            </div>
            <div class="transcript-content">
                <p>${t.transcript || '-'}</p>
            </div>
            <div class="transcript-footer">
                <span class="request-id">Request ID: ${t.requestId || '-'}</span>
            </div>
        </div>`;
    }).join('') : '<div class="empty-state"><p>暂无转录内容</p></div>';

    const speakerSegmentsHTML = speakerSegments.length > 0 ? speakerSegments.map((s, i) => {
        const sequence = s.sequence || (i + 1);
        const speakerId = s.speakerId || '-';
        const startTimeMs = s.startTimeMs || 0;
        const endTimeMs = s.endTimeMs || 0;
        const durationMs = endTimeMs - startTimeMs;
        const startTimeStr = formatMilliseconds(startTimeMs);
        const endTimeStr = formatMilliseconds(endTimeMs);
        const durationStr = formatMilliseconds(durationMs);
        return `
        <div class="segment-item">
            <div class="segment-header">
                <div class="segment-title">
                    <span class="speaker-badge">👤 说话人 ${speakerId}</span>
                    <span class="segment-sequence">片段 #${sequence}</span>
                </div>
                <div class="segment-time-info">
                    <span class="time-badge">⏱️ 时长 ${durationStr}</span>
                </div>
            </div>
            <div class="segment-content">
                <p>${s.transcript || '-'}</p>
            </div>
            <div class="segment-time-range">
                <span class="time-label">起始</span>
                <span class="time-value">${startTimeStr}</span>
                <span class="time-separator">→</span>
                <span class="time-label">结束</span>
                <span class="time-value">${endTimeStr}</span>
            </div>
        </div>`;
    }).join('') : '<div class="empty-state"><p>暂无说话人片段</p></div>';

    const logs = data.logs || [];
    const logsHTML = logs.length > 0 ? logs.map(log => {
        const timestamp = parseFloat(log.timestamp) || 0;
        const level = log.level || 'INFO';
        const levelClass = level.toLowerCase().includes('error') || level.toLowerCase().includes('fault') ? 'log-error' :
                          level.toLowerCase().includes('warn') ? 'log-warn' : 'log-info';
        return `
        <div class="log-item ${levelClass}">
            <span class="log-time">${formatTimestamp(timestamp)}</span>
            <span class="log-level">${level}</span>
            <span class="log-message">${log.message || ''}</span>
        </div>`;
    }).join('') : '<div class="empty-state"><p>暂无日志</p></div>';

    const device = data.device || {};
    const deviceHTML = Object.keys(device).length > 0 ? `
    <div class="info-cards">
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
    </div>` : '<div class="empty-state"><p>暂无设备信息</p></div>';

    const audioInfoHTML = data.rawAudioFile ? `
    <div class="info-cards">
        <div class="info-card">
            <div class="info-card-header">
                <span class="info-card-icon">🎵</span>
                <span class="info-card-label">原始音频格式</span>
            </div>
            <div class="info-card-value">${(data.rawAudioFormat || '-').toUpperCase()}</div>
        </div>
        <div class="info-card">
            <div class="info-card-header">
                <span class="info-card-icon">🔊</span>
                <span class="info-card-label">音频声道</span>
            </div>
            <div class="info-card-value">${data.audioChannel || '-'}</div>
        </div>
        <div class="info-card">
            <div class="info-card-header">
                <span class="info-card-icon">⏱️</span>
                <span class="info-card-label">音频时长</span>
            </div>
            <div class="info-card-value">${formatDuration(data.duration) || '-'}</div>
        </div>
        ${data.sampleRate ? `
        <div class="info-card">
            <div class="info-card-header">
                <span class="info-card-icon">📊</span>
                <span class="info-card-label">采样率</span>
            </div>
            <div class="info-card-value">${data.sampleRate} Hz</div>
        </div>
        ` : ''}
        ${data.bitsPerSample ? `
        <div class="info-card">
            <div class="info-card-header">
                <span class="info-card-icon">🔢</span>
                <span class="info-card-label">位深度</span>
            </div>
            <div class="info-card-value">${data.bitsPerSample} bit</div>
        </div>
        ` : ''}
    </div>` : '';

    return `<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>AI 录音报告</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            background: linear-gradient(135deg, #1a1a2e 0%, #16213e 100%);
            color: #fff;
            padding: 20px;
            min-height: 100vh;
        }
        .report-container {
            max-width: 1200px;
            margin: 0 auto;
            background: rgba(22, 33, 62, 0.95);
            border-radius: 16px;
            padding: 30px;
            box-shadow: 0 8px 32px rgba(0, 122, 255, 0.3);
        }
        .report-header {
            text-align: center;
            margin-bottom: 30px;
            padding-bottom: 20px;
            border-bottom: 1px solid rgba(255, 255, 255, 0.1);
        }
        .report-header h1 {
            font-size: 28px;
            margin-bottom: 10px;
            background: linear-gradient(135deg, #007AFF, #6A11CB);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }
        .report-header p {
            color: #888;
            font-size: 14px;
        }
        .detail-section {
            margin-bottom: 30px;
        }
        .section-title {
            font-size: 18px;
            margin-bottom: 15px;
            padding-bottom: 10px;
            border-bottom: 1px solid rgba(255, 255, 255, 0.1);
            display: flex;
            align-items: center;
            gap: 10px;
        }
        .info-cards {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
            gap: 15px;
        }
        .info-card {
            background: rgba(255, 255, 255, 0.05);
            border-radius: 10px;
            padding: 15px;
        }
        .info-card-header {
            display: flex;
            align-items: center;
            gap: 8px;
            margin-bottom: 8px;
        }
        .info-card-icon { font-size: 16px; }
        .info-card-label { font-size: 12px; color: #888; }
        .info-card-value { font-size: 14px; color: #fff; }
        
        /* 转录内容样式 */
        .transcripts-container, .segments-container {
            display: flex;
            flex-direction: column;
            gap: 16px;
        }
        
        .transcript-item {
            background: rgba(255, 255, 255, 0.03);
            border-radius: 12px;
            padding: 18px;
            border: 1px solid rgba(255, 255, 255, 0.08);
            display: flex;
            flex-direction: column;
            gap: 14px;
        }
        
        .transcript-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 12px;
        }
        
        .transcript-info {
            display: flex;
            align-items: center;
            gap: 12px;
        }
        
        .transcript-badge {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            min-width: 32px;
            height: 26px;
            background: linear-gradient(135deg, rgba(0, 122, 255, 0.2), rgba(0, 122, 255, 0.1));
            border: 1px solid rgba(0, 122, 255, 0.3);
            border-radius: 6px;
            font-size: 12px;
            font-weight: 600;
            color: #0a84ff;
        }
        
        .transcript-time {
            font-size: 12px;
            color: rgba(255, 255, 255, 0.5);
            font-family: 'SF Mono', Monaco, 'Courier New', monospace;
        }
        
        .transcript-meta {
            display: flex;
            align-items: center;
        }
        
        .meta-tag {
            padding: 3px 10px;
            background: rgba(52, 199, 89, 0.12);
            border: 1px solid rgba(52, 199, 89, 0.25);
            border-radius: 20px;
            font-size: 11px;
            color: #34c759;
        }
        
        .transcript-content {
            padding: 14px;
            background: rgba(0, 0, 0, 0.25);
            border-radius: 8px;
            border-left: 3px solid #0a84ff;
        }
        
        .transcript-content p {
            margin: 0;
            font-size: 14px;
            line-height: 1.7;
            color: rgba(255, 255, 255, 0.9);
        }
        
        .transcript-footer {
            display: flex;
            justify-content: flex-start;
        }
        
        .request-id {
            font-size: 11px;
            color: rgba(255, 255, 255, 0.35);
            font-family: 'SF Mono', Monaco, 'Courier New', monospace;
        }
        
        /* 说话人片段样式 */
        .segment-item {
            display: flex;
            flex-direction: column;
            gap: 12px;
            padding: 16px;
            background: rgba(255, 255, 255, 0.05);
            border-radius: 10px;
            border: 1px solid rgba(255, 255, 255, 0.08);
        }
        
        .segment-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 12px;
        }
        
        .segment-title {
            display: flex;
            align-items: center;
            gap: 12px;
        }
        
        .speaker-badge {
            display: inline-flex;
            align-items: center;
            padding: 4px 10px;
            background: rgba(0, 122, 255, 0.2);
            border: 1px solid rgba(0, 122, 255, 0.3);
            border-radius: 20px;
            font-size: 13px;
            color: #0a84ff;
        }
        
        .segment-sequence {
            font-size: 13px;
            color: rgba(255, 255, 255, 0.6);
        }
        
        .segment-time-info {
            display: flex;
            align-items: center;
        }
        
        .time-badge {
            padding: 4px 10px;
            background: rgba(52, 199, 89, 0.15);
            border: 1px solid rgba(52, 199, 89, 0.3);
            border-radius: 20px;
            font-size: 12px;
            color: #34c759;
        }
        
        .segment-content {
            padding: 12px;
            background: rgba(0, 0, 0, 0.2);
            border-radius: 8px;
            border-left: 3px solid #0a84ff;
        }
        
        .segment-content p {
            margin: 0;
            font-size: 14px;
            line-height: 1.6;
            color: rgba(255, 255, 255, 0.9);
        }
        
        .segment-time-range {
            display: flex;
            align-items: center;
            gap: 8px;
            font-size: 12px;
            color: rgba(255, 255, 255, 0.5);
        }
        
        .time-label {
            color: rgba(255, 255, 255, 0.4);
            font-size: 11px;
        }
        
        .time-value {
            font-family: 'SF Mono', Monaco, 'Courier New', monospace;
            color: rgba(255, 255, 255, 0.7);
            background: rgba(255, 255, 255, 0.05);
            padding: 2px 8px;
            border-radius: 4px;
        }
        
        .time-separator {
            color: rgba(255, 255, 255, 0.3);
        }

        .logs-list {
            max-height: 400px;
            overflow-y: auto;
        }
        .log-item {
            display: flex;
            gap: 10px;
            padding: 10px;
            border-radius: 6px;
            margin-bottom: 5px;
            font-size: 12px;
            background: rgba(255, 255, 255, 0.03);
        }
        .log-item.log-error { background: rgba(244, 67, 54, 0.1); border-left: 3px solid #f44336; }
        .log-item.log-warn { background: rgba(255, 152, 0, 0.1); border-left: 3px solid #ff9800; }
        .log-item.log-info { border-left: 3px solid #2196f3; }
        .log-time { color: #888; min-width: 140px; font-family: 'SF Mono', Monaco, 'Courier New', monospace; }
        .log-level { min-width: 60px; font-weight: 600; }
        .log-error .log-level { color: #f44336; }
        .log-warn .log-level { color: #ff9800; }
        .log-info .log-level { color: #2196f3; }
        .log-message { flex: 1; color: #e0e0e0; word-break: break-all; }
        .log-source { color: #666; max-width: 200px; overflow: hidden; text-overflow: ellipsis; }
        .empty-state {
            text-align: center;
            padding: 30px;
            color: #666;
            background: rgba(255, 255, 255, 0.03);
            border-radius: 10px;
        }
        .report-footer {
            background: linear-gradient(135deg, rgba(0,122,255,0.1) 0%, rgba(88,86,214,0.1) 100%);
            border-radius: 16px;
            padding: 30px;
            text-align: center;
            margin-top: 30px;
            border: 1px solid rgba(255,255,255,0.08);
        }
        .report-footer .footer-brand {
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 10px;
            margin-bottom: 12px;
        }
        .report-footer .footer-icon {
            width: 32px;
            height: 32px;
            background: rgba(0,122,255,0.2);
            border-radius: 8px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 16px;
        }
        .report-footer .footer-name {
            font-size: 16px;
            font-weight: 600;
            color: #007AFF;
        }
        .report-footer p {
            font-size: 12px;
            color: #6b6b7e;
            margin-bottom: 4px;
        }
        .report-footer .footer-meta {
            font-size: 11px;
            color: #4b4b5e;
            margin-top: 8px;
            padding-top: 12px;
            border-top: 1px solid rgba(255,255,255,0.05);
        }
    </style>
</head>
<body>
    <div class="report-container">
        <div class="report-header">
            <h1>🎙️ AI 录音报告</h1>
            <p>生成时间：${new Date().toLocaleString('zh-CN')}</p>
        </div>

        <div class="detail-section">
            <h3 class="section-title">🆔 基本信息</h3>
            <div class="info-cards">
                <div class="info-card">
                    <div class="info-card-header">
                        <span class="info-card-icon">📅</span>
                        <span class="info-card-label">开始时间</span>
                    </div>
                    <div class="info-card-value">${startTime}</div>
                </div>
                <div class="info-card">
                    <div class="info-card-header">
                        <span class="info-card-icon">📅</span>
                        <span class="info-card-label">结束时间</span>
                    </div>
                    <div class="info-card-value">${endTime}</div>
                </div>
                <div class="info-card">
                    <div class="info-card-header">
                        <span class="info-card-icon">⏱️</span>
                        <span class="info-card-label">持续时长</span>
                    </div>
                    <div class="info-card-value">${duration}</div>
                </div>
                <div class="info-card">
                    <div class="info-card-header">
                        <span class="info-card-icon">🧠</span>
                        <span class="info-card-label">AI 服务提供商</span>
                    </div>
                    <div class="info-card-value">${data.aiServiceVendor || '-'}</div>
                </div>
                <div class="info-card">
                    <div class="info-card-header">
                        <span class="info-card-icon">🎬</span>
                        <span class="info-card-label">录音场景</span>
                    </div>
                    <div class="info-card-value">${data.recordingScene || '-'}</div>
                </div>
                <div class="info-card">
                    <div class="info-card-header">
                        <span class="info-card-icon">🌐</span>
                        <span class="info-card-label">语音输入语言</span>
                    </div>
                    <div class="info-card-value">${getLanguageLabel(data.languageForSpeechInput) || data.languageForSpeechInput || '-'}</div>
                </div>
                <div class="info-card">
                    <div class="info-card-header">
                        <span class="info-card-icon">📡</span>
                        <span class="info-card-label">录音模式</span>
                    </div>
                    <div class="info-card-value">${data.isOfflineRecording ? '离线' : '在线'}</div>
                </div>
                <div class="info-card">
                    <div class="info-card-header">
                        <span class="info-card-icon">⏹️</span>
                        <span class="info-card-label">中断停止</span>
                    </div>
                    <div class="info-card-value">${data.isStoppedByInterruption ? '是' : '否'}</div>
                </div>
                <div class="info-card">
                    <div class="info-card-header">
                        <span class="info-card-icon">📝</span>
                        <span class="info-card-label">转录数量</span>
                    </div>
                    <div class="info-card-value">${data.transcriptCount || 0}</div>
                </div>
                <div class="info-card">
                    <div class="info-card-header">
                        <span class="info-card-icon">👥</span>
                        <span class="info-card-label">说话人片段</span>
                    </div>
                    <div class="info-card-value">${data.speakerSegmentCount || 0}</div>
                </div>
            </div>
        </div>

        ${audioInfoHTML ? `
        <div class="detail-section">
            <h3 class="section-title">🎵 音频信息</h3>
            ${audioInfoHTML}
        </div>
        ` : ''}

        <div class="detail-section">
            <h3 class="section-title">📝 转录内容 (${transcripts.length})</h3>
            <div class="transcripts-container">
                ${transcriptsHTML}
            </div>
        </div>

        <div class="detail-section">
            <h3 class="section-title">👥 说话人片段 (${speakerSegments.length})</h3>
            <div class="segments-container">
                ${speakerSegmentsHTML}
            </div>
        </div>

        <div class="detail-section">
            <h3 class="section-title">📱 设备信息</h3>
            ${deviceHTML}
        </div>

        <div class="detail-section">
            <h3 class="section-title">⚠️ 错误警告 (${logs.length})</h3>
            <div class="logs-list">
                ${logsHTML}
            </div>
        </div>

        <div class="report-footer">
            <div class="footer-brand">
                <div class="footer-icon">🎙️</div>
                <span class="footer-name">AIBudsClaw</span>
            </div>
            <p>本报告由 AIBuds iOS SDK 智能分析系统自动生成</p>
            <p>会话 ID: ${sessionId}</p>
            <div class="footer-meta">
                导出时间：${new Date().toISOString()} | 版本：1.0.0
            </div>
        </div>
    </div>
</body>
</html>`;
}