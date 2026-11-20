const AIChatReportExporter = (function() {
    function generateWaveformBars(count = 32) {
        const heights = [];
        for (let i = 0; i < count; i++) {
            heights.push(Math.floor(Math.random() * 37) + 8);
        }
        return heights;
    }

    function collectReportData() {
        const params = new URLSearchParams(window.location.search);
        const sessionId = params.get('sessionId') || 'unknown';

        const reportData = {
            sessionId,
            chatId: document.getElementById('detailChatId')?.textContent || '-',
            basicInfo: [
                { icon: '📅', label: '开始时间', id: 'detailStartTime' },
                { icon: '📅', label: '结束时间', id: 'detailEndTime' },
                { icon: '⏱️', label: '持续时长', id: 'detailDuration' },
                { icon: '🗣️', label: '语音输入语言', id: 'detailLanguage' },
                { icon: '🔊', label: '音频通道方案', id: 'detailAudioChannel2' },
                { icon: '🧠', label: 'AI 服务提供商', id: 'detailAiServiceVendor' },
                { icon: '🎵', label: '是否包含调试语音', id: 'detailHasVoiceForDebugging' },
                { icon: '🔈', label: '是否开启 AI 语音响应播报', id: 'detailVoicePlayback' },
                { icon: '⏸️', label: '讲话最大允许的停顿时间（秒）', id: 'detailMaxPause' },
                { icon: '🚫', label: '是否允许用户打断 AI 语音播报', id: 'detailAllowUserToInterruptAIResponse' },
                { icon: '⏳', label: '无输入自动结束会话时间（秒）', id: 'detailAutoEndSessionAfterNoInputDuration' },
                { icon: '🎤', label: '用户发言', id: 'detailUserSpeechCount' },
                { icon: '🤖', label: 'AI 响应', id: 'detailAIResponseCount' },
                { icon: '🎵', label: '音频片段', id: 'detailAudioSegments' },
                { icon: '⏰', label: '自动结束', id: 'detailAutoEnd' }
            ],
            audioConfig: {
                rawAudioFormat: document.getElementById('detailRawAudioFormat')?.textContent || '-',
                audioChannel: document.getElementById('detailAudioChannel')?.textContent || '-',
                audioDuration: document.getElementById('detailAudioDuration')?.textContent || '-'
            }
        };

        const deviceCards = document.querySelectorAll('#deviceInfoSection .info-card');
        const deviceInfo = [];
        deviceCards.forEach(card => {
            const label = card.querySelector('.info-card-label')?.textContent;
            const value = card.querySelector('.info-card-value')?.textContent;
            if (label && value) {
                deviceInfo.push({ label, value });
            }
        });

        const segmentCards = document.querySelectorAll('.segment-card');
        const segments = [];
        segmentCards.forEach((card, index) => {
            segments.push({
                index: index + 1,
                speaker: card.querySelector('.segment-speaker')?.textContent || '-',
                time: card.querySelector('.segment-time')?.textContent || '-',
                offset: card.querySelector('.segment-offset')?.textContent || '-',
                filename: card.querySelector('.segment-filename')?.textContent || '-',
                waveformHeights: generateWaveformBars(60)
            });
        });

        const eventItems = document.querySelectorAll('.timeline-item');
        const events = [];
        eventItems.forEach((item) => {
            events.push({
                eventId: item.querySelector('.timeline-event-id')?.textContent || '',
                timeRelative: item.querySelector('.timeline-time')?.textContent || '-',
                timeAbsolute: item.querySelector('.timeline-actual-time')?.textContent || '-',
                type: item.querySelector('.timeline-event-id')?.textContent || '-',
                detail: item.querySelector('.timeline-description')?.textContent || '-',
                evidence: item.querySelector('.timeline-evidence')?.textContent || ''
            });
        });

        const logRows = document.querySelectorAll('.log-item');
        const logs = [];
        logRows.forEach(row => {
            logs.push({
                time: row.querySelector('.log-time')?.textContent || '-',
                level: row.querySelector('.log-level')?.textContent || '-',
                message: row.querySelector('.log-message')?.textContent || '-'
            });
        });

        return { reportData, deviceInfo, segments, events, logs, rawWaveformHeights: generateWaveformBars(250) };
    }

    function generateReportHTML(data, deviceInfo, segments, events, logs, rawWaveformHeights) {
        const basicInfoHTML = `
        <div class="detail-section">
            <h3 class="section-title">🆔 基本信息</h3>
            <div class="info-cards-grid">
                <div class="info-card">
                    <div class="info-card-header">
                        <span class="info-card-icon">💬</span>
                        <span class="info-card-label">会话 ID</span>
                    </div>
                    <div class="info-card-value">${data.chatId}</div>
                </div>
                ${data.basicInfo.map(item => `
                <div class="info-card">
                    <div class="info-card-header">
                        <span class="info-card-icon">${item.icon}</span>
                        <span class="info-card-label">${item.label}</span>
                    </div>
                    <div class="info-card-value">${document.getElementById(item.id)?.textContent || '-'}</div>
                </div>`).join('')}
            </div>
        </div>`;

        const deviceInfoHTML = deviceInfo.length > 0 ? `
        <div class="detail-section">
            <h3 class="section-title">📱 设备信息</h3>
            <div class="info-cards-grid">
                ${deviceInfo.map(item => {
                    const iconMap = {
                        '产品类型': '📱',
                        '名称': '🏷️',
                        '蓝牙名称': '🔵',
                        '蓝牙 MAC': '📶',
                        '设备型号': '🆙',
                        '项目号': '📊',
                        '固件版本': '🔧',
                        '绑定用户 ID': '👤'
                    };
                    const icon = iconMap[item.label] || '📦';
                    return `
                <div class="info-card">
                    <div class="info-card-header">
                        <span class="info-card-icon">${icon}</span>
                        <span class="info-card-label">${item.label}</span>
                    </div>
                    <div class="info-card-value">${item.value}</div>
                </div>`;
                }).join('')}
            </div>
        </div>` : '';

        const rawAudioWaveform = rawWaveformHeights.map(h => `<span style="height: ${Math.min(Math.floor(h * 0.6), 24)}px;"></span>`).join('');

        const segmentsHTML = segments.length > 0 ? `
        <div class="detail-section">
            <h3 class="section-title">🎵 音频片段 (${segments.length})</h3>
            <div class="segments-list">
                ${segments.map(s => {
                    const segmentWaveform = s.waveformHeights.map(h => `<span style="height: ${Math.min(Math.floor(h * 0.6), 24)}px;"></span>`).join('');
                    return `
                <div class="segment-card">
                    <div class="segment-header">
                        <div class="segment-info-left">
                            <span class="segment-number">片段 ${s.index}</span>
                            <span class="segment-speaker ${s.speaker.includes('用户') ? 'user' : 'ai'}">${s.speaker}</span>
                            ${s.offset ? `<span class="segment-offset">${s.offset}</span>` : ''}
                        </div>
                        <span class="segment-time">${s.time}</span>
                    </div>
                    <div class="segment-waveform">
                        <div class="waveform-visual">
                            ${segmentWaveform}
                        </div>
                    </div>
                    <div class="segment-footer">
                        <span class="segment-filename">${s.filename}</span>
                    </div>
                </div>`;
                }).join('')}
            </div>
        </div>` : '';

        const eventsHTML = events.length > 0 ? `
        <div class="detail-section">
            <h3 class="section-title">📊 会话事件 (${events.length})</h3>
            <div class="events-timeline">
                ${events.map(e => {
                    const eventIconMap = {
                        'userInitiatedToStart': '👤',
                        'sessionStarted': '🚀',
                        'aiServiceConnected': '🔗',
                        'vadStartSpeaking': '🎤',
                        'vadEndSpeaking': '🎤',
                        'aiRespondVoicePlaybackDidStart': '🔊',
                        'aiRespondVoicePlaybackDidStop': '🔇',
                        'aiIntentReceived': '💡',
                        'autoEndSessionTriggered': '⏰',
                        'sessionEnded': '🏁',
                        'aiServiceStartRecording': '📝',
                        'aiServiceEndRecording': '📝',
                        'appWillTerminate': '📍'
                    };
                    const icon = eventIconMap[e.eventId] || '📌';
                    return `
                <div class="timeline-item">
                    <div class="timeline-marker">
                        <span class="timeline-icon">${icon}</span>
                    </div>
                    <div class="timeline-content">
                        <div class="timeline-header">
                            <div class="timeline-times">
                                <span class="timeline-actual-time">${e.timeAbsolute}</span>
                                <span class="timeline-time">${e.timeRelative}</span>
                            </div>
                            <span class="timeline-event-id">${e.type}</span>
                        </div>
                        <div class="timeline-description">${e.detail}</div>
                        ${e.evidence ? `<div class="timeline-evidence">${e.evidence}</div>` : ''}
                    </div>
                </div>`;
                }).join('')}
            </div>
        </div>` : '';

        const logsHTML = logs.length > 0 ? `
        <div class="detail-section">
            <h3 class="section-title">⚠️ 错误警告 (${logs.length})</h3>
            <div class="log-table">
                <div class="log-header">
                    <span>时间</span>
                    <span>级别</span>
                    <span>日志详细信息</span>
                </div>
                ${logs.map(log => `
                <div class="log-row">
                    <span class="log-time">${log.time}</span>
                    <span class="log-level ${log.level.toLowerCase()}">${log.level}</span>
                    <span class="log-message">${log.message}</span>
                </div>`).join('')}
            </div>
        </div>` : '';

        return `<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>会话报告 - ${data.sessionId}</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif; background: #1a1a2e; color: #fff; line-height: 1.6; min-height: 100vh; }
        
        .report-header { background: linear-gradient(135deg, #007AFF 0%, #5856D6 100%); padding: 50px 40px; text-align: center; position: relative; overflow: hidden; }
        .report-header::before { content: ''; position: absolute; top: -50%; left: -50%; width: 200%; height: 200%; background: radial-gradient(circle, rgba(255,255,255,0.1) 0%, transparent 60%); }
        .report-header .brand { display: flex; align-items: center; justify-content: center; gap: 12px; margin-bottom: 20px; }
        .report-header .brand-icon { width: 48px; height: 48px; background: rgba(255,255,255,0.2); border-radius: 12px; display: flex; align-items: center; justify-content: center; font-size: 24px; }
        .report-header .brand-name { font-size: 24px; font-weight: 700; color: #fff; }
        .report-header h1 { font-size: 36px; font-weight: 700; color: #fff; margin-bottom: 16px; text-shadow: 0 2px 8px rgba(0,0,0,0.2); position: relative; }
        .report-header .meta-info { display: flex; justify-content: center; gap: 16px; flex-wrap: wrap; position: relative; }
        .report-header .meta-item { padding: 6px 16px; background: rgba(255,255,255,0.15); border-radius: 20px; font-size: 13px; color: #fff; backdrop-filter: blur(10px); }
        .report-header .meta-item.session-id { font-family: monospace; font-weight: 600; }
        
        .report-container { max-width: 1200px; margin: 0 auto; padding: 40px 20px; }
        
        .detail-section { background: rgba(255,255,255,0.03); border-radius: 16px; padding: 24px; margin-bottom: 24px; border: 1px solid rgba(255,255,255,0.08); }
        .section-title { font-size: 18px; font-weight: 600; color: #fff; margin-bottom: 20px; padding-bottom: 14px; border-bottom: 1px solid rgba(255,255,255,0.1); display: flex; align-items: center; gap: 10px; }
        
        .info-cards-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 16px; }
        .info-card { background: rgba(255,255,255,0.05); border-radius: 12px; padding: 16px; border: 1px solid rgba(255,255,255,0.06); }
        .info-card-header { display: flex; align-items: center; gap: 8px; margin-bottom: 8px; }
        .info-card-icon { font-size: 16px; }
        .info-card-label { font-size: 12px; color: #8b8b9e; font-weight: 500; }
        .info-card-value { font-size: 13px; font-weight: 500; color: #fff; word-break: break-all; line-height: 1.4; }
        
        .original-audio-section { background: rgba(255,255,255,0.03); border-radius: 16px; padding: 24px; margin-bottom: 24px; border: 1px solid rgba(255,255,255,0.08); }
        .original-audio-section .section-title { font-size: 18px; font-weight: 600; color: #fff; margin-bottom: 16px; padding-bottom: 14px; border-bottom: 1px solid rgba(255,255,255,0.1); display: flex; align-items: center; gap: 10px; }
        .audio-info-row { display: flex; gap: 12px; margin-bottom: 16px; }
        .audio-format-badge { padding: 4px 12px; background: rgba(0, 122, 255, 0.2); color: #007AFF; border-radius: 6px; font-size: 12px; }
        .audio-channel, .audio-duration { padding: 4px 12px; background: rgba(255, 255, 255, 0.1); color: #b0b0b0; border-radius: 6px; font-size: 12px; }
        
        .audio-waveform {
            margin-top: 16px;
            margin-bottom: 12px;
        }
        .waveform-visual {
            display: flex;
            align-items: center;
            gap: 2px;
            height: 30px;
        }
        .waveform-visual span {
            width: 3px;
            background: rgba(0, 122, 255, 0.4);
            border-radius: 2px;
        }
        
        .segments-list { display: grid; grid-template-columns: repeat(auto-fill, minmax(280px, 1fr)); gap: 14px; }
        .segment-card { background: rgba(255,255,255,0.05); border-radius: 12px; overflow: hidden; border: 1px solid rgba(255,255,255,0.06); }
        .segment-header { display: flex; justify-content: space-between; align-items: center; padding: 14px 16px; background: rgba(255,255,255,0.03); border-bottom: 1px solid rgba(255,255,255,0.05); }
        .segment-info-left { display: flex; align-items: center; gap: 10px; }
        .segment-number { font-size: 12px; color: #8b8b9e; }
        .segment-speaker { font-size: 12px; padding: 3px 10px; border-radius: 4px; }
        .segment-speaker.user { background: rgba(0,122,255,0.2); color: #007AFF; font-weight: 500; }
        .segment-speaker.ai { background: rgba(168,85,247,0.2); color: #a855f7; font-weight: 500; }
        .segment-offset { font-size: 11px; color: #059669; padding: 2px 6px; background: rgba(5,150,105,0.15); border-radius: 4px; }
        .segment-time { font-size: 12px; color: #888; font-family: monospace; }
        
        .segment-waveform {
            padding: 12px 16px;
            background: rgba(0, 122, 255, 0.03);
        }

        .segment-footer { padding: 10px 16px; }
        .segment-filename { font-size: 11px; color: #6b6b7e; font-family: monospace; }
        
        .events-timeline { display: flex; flex-direction: column; gap: 16px; }
        .timeline-item { display: flex; gap: 16px; }
        .timeline-marker { display: flex; flex-direction: column; align-items: center; }
        .timeline-icon { width: 36px; height: 36px; border-radius: 50%; background: rgba(0,122,255,0.2); display: flex; align-items: center; justify-content: center; font-size: 14px; }
        .timeline-content { flex: 1; background: rgba(255,255,255,0.03); border-radius: 12px; padding: 14px 18px; border: 1px solid rgba(255,255,255,0.06); }
        .timeline-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 8px; flex-wrap: wrap; gap: 8px; }
        .timeline-times { display: flex; align-items: center; gap: 12px; }
        .timeline-actual-time { font-size: 12px; color: #888; font-family: monospace; }
        .timeline-time { font-size: 13px; color: #00D4FF; font-weight: 500; font-family: monospace; }
        .timeline-event-id { font-size: 10px; color: #666; background: rgba(255,255,255,0.05); padding: 3px 8px; border-radius: 4px; font-family: monospace; }
        .timeline-description { font-size: 14px; color: #fff; }
        .timeline-evidence { margin-top: 10px; padding: 10px; background: rgba(0,0,0,0.3); border-radius: 6px; font-size: 11px; color: #888; font-family: monospace; word-break: break-all; }
        
        .log-table { background: rgba(0,0,0,0.2); border-radius: 12px; overflow: hidden; border: 1px solid rgba(255,255,255,0.06); }
        .log-header { display: flex; padding: 14px 16px; background: rgba(255,255,255,0.05); font-weight: 600; font-size: 12px; color: #8b8b9e; text-transform: uppercase; letter-spacing: 0.5px; }
        .log-header span:first-child { width: 190px; }
        .log-header span:nth-child(2) { width: 70px; }
        .log-header span:last-child { flex: 1; }
        .log-row { display: flex; padding: 12px 16px; border-top: 1px solid rgba(255,255,255,0.05); font-size: 13px; }
        .log-row:hover { background: rgba(255,255,255,0.02); }
        .log-time { width: 190px; color: #6b6b7e; font-family: monospace; white-space: nowrap; }
        .log-level { width: 70px; text-align: center; padding: 2px 8px; border-radius: 4px; font-size: 11px; font-weight: 600; text-transform: uppercase; }
        .log-level.info { color: #00D4FF; background: rgba(0,212,255,0.15); }
        .log-level.warn { color: #ff9800; background: rgba(255,152,0,0.15); }
        .log-level.error { color: #ff3b30; background: rgba(255,59,48,0.15); }
        .log-level.debug { color: #888; background: rgba(136,136,136,0.15); }
        .log-message { flex: 1; color: #fff; word-break: break-all; }
        
        .report-footer { background: linear-gradient(135deg, rgba(0,122,255,0.1) 0%, rgba(88,86,214,0.1) 100%); border-radius: 16px; padding: 30px; text-align: center; margin-top: 30px; border: 1px solid rgba(255,255,255,0.08); }
        .report-footer .footer-brand { display: flex; align-items: center; justify-content: center; gap: 10px; margin-bottom: 12px; }
        .report-footer .footer-icon { width: 32px; height: 32px; background: rgba(0,122,255,0.2); border-radius: 8px; display: flex; align-items: center; justify-content: center; font-size: 16px; }
        .report-footer .footer-name { font-size: 16px; font-weight: 600; color: #007AFF; }
        .report-footer p { font-size: 12px; color: #6b6b7e; margin-bottom: 4px; }
        .report-footer .footer-meta { font-size: 11px; color: #4b4b5e; margin-top: 8px; padding-top: 12px; border-top: 1px solid rgba(255,255,255,0.05); }
        
        @media print {
            body { background: #fff; color: #333; }
            .report-header { background: #4a4a6a !important; -webkit-print-color-adjust: exact; print-color-adjust: exact; }
            .report-header .brand-name, .report-header h1, .report-header .meta-item { color: #fff !important; }
            .detail-section { background: #fff; border-color: #e0e0e0; }
            .section-title { color: #333; border-bottom-color: #e0e0e0; }
            .info-card { background: #f5f5f7; border-color: #e0e0e0; }
            .info-card-label { color: #666; }
            .info-card-value { color: #333; }
            .original-audio-section { background: #f5f5f7; border-color: #e0e0e0; }
            .original-audio-section .section-title { color: #333; border-bottom-color: #e0e0e0; }
            .audio-waveform { background: #f0f7ff; border-color: #c7e0f4; }
            .wave-bar { opacity: 0.6; }
            .segment-card { background: #f5f5f7; border-color: #e0e0e0; }
            .segment-header { background: #eee; border-bottom-color: #e0e0e0; }
            .segment-number { color: #666; }
            .segment-waveform { background: #f0f7ff; }
            .segment-wave-bar { opacity: 0.6; }
            .segment-filename { color: #666; }
            .timeline-icon { background: rgba(0,122,255,0.2); }
            .timeline-content { background: #f9f9f9; border-color: #e0e0e0; }
            .timeline-time { color: #007AFF; }
            .timeline-event-id { background: #eee; color: #666; }
            .timeline-description, .timeline-evidence { color: #333; }
            .timeline-evidence { background: #f0f0f0; }
            .log-table { background: #fff; border-color: #e0e0e0; }
            .log-header { background: #f5f5f5; color: #666; }
            .log-row { border-top-color: #e0e0e0; }
            .log-time { color: #666; }
            .log-message { color: #333; }
            .report-footer { background: #f5f5f5; border-color: #e0e0e0; }
            .report-footer .footer-name { color: #007AFF; }
            .report-footer p, .report-footer .footer-meta { color: #666; }
            .detail-section, .original-audio-section { break-inside: avoid; }
            .info-cards-grid { grid-template-columns: repeat(2, 1fr); }
        }
        
        @media (max-width: 768px) {
            .info-cards-grid { grid-template-columns: 1fr; }
            .segments-list { grid-template-columns: 1fr; }
            .log-header, .log-row { flex-direction: column; gap: 8px; }
            .log-header span, .log-time, .log-level, .log-message { width: 100%; }
            .report-header h1 { font-size: 28px; }
        }
    </style>
</head>
<body>
    <header class="report-header">
        <div class="brand">
            <div class="brand-icon">🦾</div>
            <span class="brand-name">AIBudsClaw</span>
        </div>
        <h1>📋 会话详情报告</h1>
        <div class="meta-info">
            <span class="meta-item session-id">会话 ID: ${data.sessionId}</span>
            <span class="meta-item">导出时间：${new Date().toLocaleString('zh-CN')}</span>
        </div>
    </header>
    
    <main class="report-container">
        ${basicInfoHTML}
        
        <div class="original-audio-section">
            <h3 class="section-title">🔊 原始音频</h3>
            <div class="audio-info-row">
                <span class="audio-format-badge">${data.audioConfig.rawAudioFormat}</span>
                <span class="audio-channel">${data.audioConfig.audioChannel}</span>
                <span class="audio-duration">${data.audioConfig.audioDuration}</span>
            </div>
            <div class="segment-waveform">
                <div class="waveform-visual">
                    ${rawAudioWaveform}
                </div>
            </div>
        </div>
        
        ${deviceInfoHTML}
        ${segmentsHTML}
        ${eventsHTML}
        ${logsHTML}
        
        <footer class="report-footer">
            <div class="footer-brand">
                <div class="footer-icon">🦾</div>
                <span class="footer-name">AIBudsClaw</span>
            </div>
            <p>本报告由 AIBuds iOS SDK 智能分析系统自动生成</p>
            <p>会话 ID: ${data.sessionId}</p>
            <div class="footer-meta">
                导出时间：${new Date().toISOString()} | 版本：1.0.0
            </div>
        </footer>
    </main>
</body>
</html>`;
    }

    function exportReport() {
        const { reportData, deviceInfo, segments, events, logs, rawWaveformHeights } = collectReportData();
        const htmlContent = generateReportHTML(reportData, deviceInfo, segments, events, logs, rawWaveformHeights);
        
        const sessionId = reportData.sessionId;
        const dateStr = new Date().toISOString().slice(0, 10);
        const filename = `会话报告_${sessionId}_${dateStr}.html`;
        
        const blob = new Blob([htmlContent], { type: 'text/html;charset=utf-8' });
        const url = URL.createObjectURL(blob);
        const link = document.createElement('a');
        link.href = url;
        link.download = filename;
        document.body.appendChild(link);
        link.click();
        document.body.removeChild(link);
        URL.revokeObjectURL(url);
    }

    return {
        exportReport: exportReport,
        collectReportData: collectReportData,
        generateReportHTML: generateReportHTML
    };
})();

if (typeof window !== 'undefined') {
    window.AIChatReportExporter = AIChatReportExporter;
}
