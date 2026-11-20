// 同声传译报告导出模块
const TranslationReportExporter = (function() {
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
            'zh-CN': '中文', 'zh': '中文', 'en': '英语', 'en-US': '英语',
            'ja': '日语', 'ko': '韩语', 'fr': '法语', 'de': '德语',
            'es': '西班牙语', 'ru': '俄语', 'pt': '葡萄牙语', 'it': '意大利语',
            'ar': '阿拉伯语', 'hi': '印地语', 'th': '泰语', 'vi': '越南语',
            'id': '印尼语', 'ms': '马来语', 'tr': '土耳其语', 'pl': '波兰语',
            'nl': '荷兰语', 'sv': '瑞典语', 'no': '挪威语', 'da': '丹麦语',
            'fi': '芬兰语', 'cs': '捷克语', 'hu': '匈牙利语', 'ro': '罗马尼亚语',
            'bg': '保加利亚语', 'hr': '克罗地亚语', 'sk': '斯洛伐克语'
        };
        return languageMap[language] || language;
    }

    function generateReportHTML(data, sessionId) {
        const sourceSentences = data.sourceSentences || [];
        const targetSentences = data.targetSentences || [];
        const ttsSegments = data.ttsSegments || [];

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

        const basicInfoHTML = `
        <div class="detail-section">
            <h3 class="section-title">🆔 基本信息</h3>
            <div class="info-cards-grid">
                <div class="info-card">
                    <div class="info-card-header">
                        <span class="info-card-icon">📅</span>
                        <span class="info-card-label">开始时间</span>
                    </div>
                    <div class="info-card-value">${formatTimestamp(data.startTime)}</div>
                </div>
                <div class="info-card">
                    <div class="info-card-header">
                        <span class="info-card-icon">📅</span>
                        <span class="info-card-label">结束时间</span>
                    </div>
                    <div class="info-card-value">${formatTimestamp(data.endTime)}</div>
                </div>
                <div class="info-card">
                    <div class="info-card-header">
                        <span class="info-card-icon">⏱️</span>
                        <span class="info-card-label">持续时长</span>
                    </div>
                    <div class="info-card-value">${formatDuration(data.duration)}</div>
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
                        <span class="info-card-icon">🌐</span>
                        <span class="info-card-label">源语言</span>
                    </div>
                    <div class="info-card-value">${getLanguageLabel(data.sourceLanguage) || data.sourceLanguage || '-'}</div>
                </div>
                <div class="info-card">
                    <div class="info-card-header">
                        <span class="info-card-icon">🌍</span>
                        <span class="info-card-label">目标语言</span>
                    </div>
                    <div class="info-card-value">${getLanguageLabel(data.targetLanguage) || data.targetLanguage || '-'}</div>
                </div>
                <div class="info-card">
                    <div class="info-card-header">
                        <span class="info-card-icon">🔊</span>
                        <span class="info-card-label">启用 TTS</span>
                    </div>
                    <div class="info-card-value">${data.enableTTS ? '是' : '否'}</div>
                </div>
                <div class="info-card">
                    <div class="info-card-header">
                        <span class="info-card-icon">🎵</span>
                        <span class="info-card-label">TTS 格式</span>
                    </div>
                    <div class="info-card-value">${data.ttsFormat || '-'}</div>
                </div>
                <div class="info-card">
                    <div class="info-card-header">
                        <span class="info-card-icon">🎙️</span>
                        <span class="info-card-label">SDK 内部拾音</span>
                    </div>
                    <div class="info-card-value">${data.usesInternalAudioRecording ? '是' : '否'}</div>
                </div>
                <div class="info-card">
                    <div class="info-card-header">
                        <span class="info-card-icon">🔈</span>
                        <span class="info-card-label">扬声器播放译文语音</span>
                    </div>
                    <div class="info-card-value">${data.preferSpeakerOutput ? '是' : '否'}</div>
                </div>
                <div class="info-card">
                    <div class="info-card-header">
                        <span class="info-card-icon">🔈</span>
                        <span class="info-card-label">语音播报</span>
                    </div>
                    <div class="info-card-value">${data.enableVoicePlayback ? '是' : '否'}</div>
                </div>
                <div class="info-card">
                    <div class="info-card-header">
                        <span class="info-card-icon">⏹️</span>
                        <span class="info-card-label">停止原因</span>
                    </div>
                    <div class="info-card-value">${data.stopReason || '-'}</div>
                </div>
            </div>
        </div>`;

        const translationContentHTML = sortedSequences.length > 0 ? `
        <div class="detail-section">
            <h3 class="section-title">🔤 翻译内容 (${sortedSequences.length})</h3>
            <div class="translation-content-list">
                ${sortedSequences.map((seq, idx) => {
                    const sourceItem = sourceMap.get(seq);
                    const targetItem = targetMap.get(seq);
                    const sourceText = sourceItem ? sourceItem.sentenceText : '';
                    const targetText = targetItem ? targetItem.sentenceText : '';
                    const timestamp = sourceItem ? sourceItem.timestamp : (targetItem ? targetItem.timestamp : 0);
                    const moment = sourceItem ? sourceItem.moment : (targetItem ? targetItem.moment : '');

                    const matchedTtsSegments = ttsSegments.filter(tts => {
                        return tts.associatedTargetTextSequence !== undefined && 
                               parseInt(tts.associatedTargetTextSequence) === seq;
                    });

                    return `
                    <div class="translation-item">
                        <div class="translation-header">
                            <div class="translation-header-left">
                                <span class="translation-number">#${String(idx + 1).padStart(3, '0')}</span>
                                ${moment ? `<span class="translation-moment">${moment}</span>` : ''}
                            </div>
                            <span class="translation-timestamp">${formatTimestamp(timestamp)}</span>
                        </div>
                        <div class="translation-content">
                            <div class="source-text">
                                <span class="lang-label">原文 (${getLanguageLabel(data.sourceLanguage)})</span>
                                <p>${sourceText || '-'}</p>
                            </div>
                            <div class="target-text">
                                <span class="lang-label">译文 (${getLanguageLabel(data.targetLanguage)})</span>
                                <p>${targetText || '-'}</p>
                            </div>
                        </div>
                    </div>`;
                }).join('')}
            </div>
        </div>` : '';

        const rawAudioHTML = data.rawAudioFile ? `
        <div class="detail-section">
            <h3 class="section-title">🔊 原始音频</h3>
            <div class="original-audio-section">
                <div class="audio-info-row">
                    <span class="audio-format-badge">${data.rawAudioFormat || '-'}</span>
                    <span class="audio-channel">${data.rawAudioChannel || '单声道'}</span>
                    <span class="audio-duration">${formatDuration(data.duration)}</span>
                </div>
                <div class="audio-waveform">
                    <div class="waveform-visual">
                        ${generateWaveformBars(50).map(h => `<span style="height: ${h}px;"></span>`).join('')}
                    </div>
                </div>
            </div>
        </div>` : '';

        const speakerSegments = data.speakerSegments || [];
        const speakerSegmentsHTML = speakerSegments.length > 0 ? `
        <div class="detail-section">
            <h3 class="section-title">🎤 说话人片段 (${speakerSegments.length})</h3>
            <div class="segments-list">
                ${speakerSegments.map((segment, index) => {
                    const startTime = parseFloat(segment.startTime) || 0;
                    const endTime = parseFloat(segment.endTime) || 0;
                    const duration = endTime - startTime;
                    return `
                    <div class="segment-card">
                        <div class="segment-header">
                            <div class="segment-info-left">
                                <span class="segment-number">#${String(index + 1).padStart(3, '0')}</span>
                                <span class="segment-speaker">${segment.speakerId || '未知'}</span>
                            </div>
                            <span class="segment-time">${formatTimestamp(startTime)} → ${formatTimestamp(endTime)}</span>
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
                }).join('')}
            </div>
        </div>` : '';

        const ttsSegmentsHTML = ttsSegments.length > 0 ? `
        <div class="detail-section">
            <h3 class="section-title">🎵 TTS 片段 (${ttsSegments.length})</h3>
            <div class="tts-segments-table">
                <div class="tts-segments-header">
                    <div class="tts-segment-item">序号</div>
                    <div class="tts-segment-item">时间</div>
                    <div class="tts-segment-item">关联译文</div>
                    <div class="tts-segment-item">请求 ID</div>
                    <div class="tts-segment-item">响应序号</div>
                    <div class="tts-segment-item">波形</div>
                    <div class="tts-segment-item">Base64</div>
                </div>
                ${ttsSegments.map((segment, index) => {
                    const timestamp = parseFloat(segment.timestamp) || 0;
                    const base64Audio = segment.base64AudioData;
                    const hasBase64 = base64Audio && base64Audio.trim();
                    const dataUri = hasBase64 ? base64Audio : '';
                    const truncatedBase64 = hasBase64 && dataUri.length > 100 ? dataUri.substring(0, 50) + '...' + dataUri.substring(dataUri.length - 50) : dataUri;
                    return `
                    <div class="tts-segment-row">
                        <div class="tts-segment-item"><span class="tts-segment-number">#${String(index + 1).padStart(3, '0')}</span></div>
                        <div class="tts-segment-item"><span class="tts-segment-time">${formatTimestamp(timestamp)}</span></div>
                        <div class="tts-segment-item tts-segment-text">${segment.associatedTargetTextSequence}</div>
                        <div class="tts-segment-item">${segment.requestId || '-'}</div>
                        <div class="tts-segment-item">${segment.modelResponseSequence}</div>
                        <div class="tts-segment-item tts-segment-waveform">
                            <div class="mini-waveform">
                                ${generateWaveformBars(15).map(h => `<span class="mini-wave-bar" style="height: ${h}px;"></span>`).join('')}
                            </div>
                        </div>
                        <div class="tts-segment-item tts-segment-base64-cell">${hasBase64 ? `<code class="base64-truncated" title="${dataUri}">${truncatedBase64}</code>` : '<span class="base64-none">无</span>'}</div>
                    </div>`;
                }).join('')}
            </div>
        </div>` : '';

        const device = data.device;
        const deviceInfo = device ? [
            { label: '产品类型', value: device.product || '-', icon: '📱' },
            { label: '名称', value: device.name || '-', icon: '🏷️' },
            { label: '蓝牙名称', value: device.bluetoothName || '-', icon: '🔵' },
            { label: '蓝牙 MAC', value: device.macAddress || '-', icon: '📶' },
            { label: '设备型号', value: device.model || '-', icon: '🆙' },
            { label: '项目号', value: device.formatedProjNumber || '-', icon: '📊' },
            { label: '固件版本', value: device.formatedFirmwareVersion || '-', icon: '🔧' },
            { label: '绑定用户 ID', value: device.userID || '-', icon: '👤' }
        ] : [];
        const deviceHTML = deviceInfo.length > 0 ? `
        <div class="detail-section">
            <h3 class="section-title">📱 设备信息</h3>
            <div class="info-cards-grid">
                ${deviceInfo.map(item => `
                <div class="info-card">
                    <div class="info-card-header">
                        <span class="info-card-icon">${item.icon}</span>
                        <span class="info-card-label">${item.label}</span>
                    </div>
                    <div class="info-card-value">${item.value}</div>
                </div>`).join('')}
            </div>
        </div>` : '';

        const logs = data.logs || [];
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
                    <span class="log-time">${formatTimestamp(log.timestamp)}</span>
                    <span class="log-level ${log.level ? log.level.toLowerCase() : 'info'}">${log.level || 'INFO'}</span>
                    <span class="log-message">${log.message || log.msg || '-'}</span>
                </div>`).join('')}
            </div>
        </div>` : '';

        return `<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>同声传译报告 - ${sessionId}</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif; background: #0f0f1a; color: #fff; padding: 40px 20px; }
        .report-container { max-width: 1200px; margin: 0 auto; }
        
        .report-header { text-align: center; margin-bottom: 40px; padding: 30px; background: linear-gradient(135deg, rgba(0,122,255,0.15) 0%, rgba(88,86,214,0.15) 100%); border-radius: 20px; border: 1px solid rgba(255,255,255,0.1); }
        .report-header .brand-icon { width: 60px; height: 60px; background: rgba(0,122,255,0.2); border-radius: 16px; display: flex; align-items: center; justify-content: center; margin: 0 auto 16px; font-size: 28px; }
        .report-title { font-size: 28px; font-weight: 700; color: #fff; margin-bottom: 8px; }
        .report-subtitle { font-size: 14px; color: #888; }
        .report-meta { display: flex; justify-content: center; gap: 20px; margin-top: 16px; flex-wrap: wrap; }
        .report-meta-item { font-size: 12px; color: #6b6b7e; background: rgba(255,255,255,0.05); padding: 6px 12px; border-radius: 6px; }
        
        .detail-section { background: rgba(255,255,255,0.03); border-radius: 16px; padding: 24px; margin-bottom: 24px; border: 1px solid rgba(255,255,255,0.08); }
        .section-title { font-size: 18px; font-weight: 600; color: #fff; margin-bottom: 20px; padding-bottom: 14px; border-bottom: 1px solid rgba(255,255,255,0.1); display: flex; align-items: center; gap: 10px; }
        
        .info-cards-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 16px; }
        .info-card { background: rgba(255,255,255,0.05); border-radius: 12px; padding: 16px; border: 1px solid rgba(255,255,255,0.06); }
        .info-card-header { display: flex; align-items: center; gap: 8px; margin-bottom: 8px; }
        .info-card-icon { font-size: 16px; }
        .info-card-label { font-size: 12px; color: #8b8b9e; font-weight: 500; }
        .info-card-value { font-size: 14px; font-weight: 500; color: #fff; word-break: break-all; line-height: 1.4; }
        
        .original-audio-section { background: rgba(255,255,255,0.03); border-radius: 16px; padding: 24px; border: 1px solid rgba(255,255,255,0.08); }
        .audio-info-row { display: flex; gap: 12px; margin-bottom: 16px; flex-wrap: wrap; }
        .audio-format-badge { padding: 4px 12px; background: rgba(0, 122, 255, 0.2); color: #007AFF; border-radius: 6px; font-size: 12px; }
        .audio-channel, .audio-duration { padding: 4px 12px; background: rgba(255, 255, 255, 0.1); color: #b0b0b0; border-radius: 6px; font-size: 12px; }
        .audio-waveform { margin-top: 16px; background: rgba(0, 122, 255, 0.05); border-radius: 12px; padding: 16px; }
        .waveform-visual { display: flex; align-items: center; gap: 2px; height: 30px; }
        .waveform-visual span { width: 3px; background: rgba(0, 122, 255, 0.5); border-radius: 2px; }
        
        .translation-content-list { display: flex; flex-direction: column; gap: 16px; }
        .translation-item { background: rgba(255,255,255,0.05); border-radius: 12px; padding: 16px; border: 1px solid rgba(255,255,255,0.06); }
        .translation-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 14px; flex-wrap: wrap; gap: 8px; }
        .translation-header-left { display: flex; align-items: center; gap: 10px; }
        .translation-number { font-size: 12px; font-weight: 600; color: #007AFF; background: rgba(0, 122, 255, 0.15); padding: 2px 10px; border-radius: 4px; }
        .translation-moment { font-size: 12px; color: #8b8b9e; }
        .translation-timestamp { font-size: 12px; color: #6b6b7e; font-family: monospace; }
        .translation-content { display: grid; grid-template-columns: 1fr 1fr; gap: 16px; }
        .source-text, .target-text { background: rgba(255,255,255,0.03); border-radius: 8px; padding: 12px; }
        .lang-label { font-size: 11px; color: #007AFF; margin-bottom: 8px; display: block; font-weight: 500; }
        .source-text p, .target-text p { font-size: 14px; line-height: 1.6; color: #fff; }
        
        .segments-list { display: grid; grid-template-columns: repeat(auto-fill, minmax(280px, 1fr)); gap: 14px; }
        .segment-card { background: rgba(255,255,255,0.05); border-radius: 12px; overflow: hidden; border: 1px solid rgba(255,255,255,0.06); }
        .segment-header { display: flex; justify-content: space-between; align-items: center; padding: 14px 16px; background: rgba(255,255,255,0.03); border-bottom: 1px solid rgba(255,255,255,0.05); flex-wrap: wrap; gap: 8px; }
        .segment-info-left { display: flex; align-items: center; gap: 10px; }
        .segment-number { font-size: 12px; color: #8b8b9e; }
        .segment-speaker { font-size: 12px; padding: 3px 10px; border-radius: 4px; background: rgba(0,122,255,0.2); color: #007AFF; font-weight: 500; }
        .segment-time { font-size: 11px; color: #6b6b7e; font-family: monospace; }
        .segment-text { padding: 14px 16px; }
        .segment-text p { font-size: 14px; color: #fff; line-height: 1.5; }
        .segment-waveform { padding: 12px 16px; background: rgba(0, 122, 255, 0.03); }
        
        .tts-segments-table { background: rgba(255,255,255,0.03); border-radius: 12px; overflow: hidden; border: 1px solid rgba(255,255,255,0.06); }
        .tts-segments-header { display: flex; background: rgba(255,255,255,0.05); padding: 12px 16px; font-size: 12px; font-weight: 600; color: #8b8b9e; text-transform: uppercase; }
        .tts-segment-item { display: flex; align-items: center; }
        .tts-segments-header .tts-segment-item:nth-child(1) { width: 70px; }
        .tts-segments-header .tts-segment-item:nth-child(2) { width: 160px; }
        .tts-segments-header .tts-segment-item:nth-child(3) { width: 100px; }
        .tts-segments-header .tts-segment-item:nth-child(4) { flex: 1; min-width: 200px; }
        .tts-segments-header .tts-segment-item:nth-child(5) { width: 80px; }
        .tts-segments-header .tts-segment-item:nth-child(6) { width: 120px; justify-content: center; }
        .tts-segments-header .tts-segment-item:nth-child(7) { width: 200px; justify-content: center; }
        .tts-segment-row { display: flex; align-items: center; padding: 12px 16px; border-bottom: 1px solid rgba(255,255,255,0.05); font-size: 13px; }
        .tts-segment-row:last-child { border-bottom: none; }
        .tts-segment-row:hover { background: rgba(255,255,255,0.02); }
        .tts-segment-row .tts-segment-item:nth-child(1) { width: 70px; }
        .tts-segment-row .tts-segment-item:nth-child(2) { width: 160px; }
        .tts-segment-row .tts-segment-item:nth-child(3) { width: 100px; }
        .tts-segment-row .tts-segment-item:nth-child(4) { flex: 1; min-width: 200px; color: #6b6b7e; font-size: 11px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
        .tts-segment-row .tts-segment-item:nth-child(5) { width: 80px; }
        .tts-segment-row .tts-segment-item:nth-child(6) { width: 120px; justify-content: center; }
        .tts-segment-row .tts-segment-item:nth-child(7) { width: 200px; justify-content: center; }
        .tts-segment-number { font-size: 12px; font-weight: 600; color: #007AFF; background: rgba(0, 122, 255, 0.15); padding: 2px 8px; border-radius: 4px; }
        .tts-segment-time { font-family: monospace; color: #888; font-size: 12px; }
        .tts-segment-text { color: #b0b0b0; }
        .mini-waveform { display: flex; align-items: center; gap: 2px; height: 24px; }
        .mini-wave-bar { width: 3px; background: rgba(0, 122, 255, 0.4); border-radius: 2px; }
        .tts-segment-base64-cell { overflow: hidden; }
        .base64-truncated { font-family: 'SF Mono', Monaco, Consolas, monospace; font-size: 9px; color: #6b6b7e; background: rgba(0,0,0,0.3); padding: 2px 6px; border-radius: 3px; word-break: break-all; max-width: 200px; display: inline-block; }
        .base64-none { font-size: 11px; color: #666; }

        .log-table { background: rgba(0,0,0,0.2); border-radius: 12px; overflow: hidden; border: 1px solid rgba(255,255,255,0.06); }
        .log-header { display: flex; padding: 14px 16px; background: rgba(255,255,255,0.05); font-weight: 600; font-size: 12px; color: #8b8b9e; text-transform: uppercase; letter-spacing: 0.5px; }
        .log-header span:first-child { width: 150px; }
        .log-header span:nth-child(2) { width: 70px; }
        .log-header span:last-child { flex: 1; }
        .log-row { display: flex; padding: 12px 16px; border-top: 1px solid rgba(255,255,255,0.05); font-size: 13px; }
        .log-row:hover { background: rgba(255,255,255,0.02); }
        .log-time { width: 150px; color: #6b6b7e; font-family: monospace; white-space: nowrap; }
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
            .report-header { background: #f5f5f7 !important; border-color: #e0e0e0 !important; }
            .report-header .brand-icon { background: rgba(0,122,255,0.1); }
            .report-title, .report-subtitle, .report-meta-item { color: #333 !important; }
            .detail-section { background: #fff; border-color: #e0e0e0; }
            .section-title { color: #333; border-bottom-color: #e0e0e0; }
            .info-card { background: #f5f5f7; border-color: #e0e0e0; }
            .info-card-label { color: #666; }
            .info-card-value { color: #333; }
            .original-audio-section { background: #f5f5f7; border-color: #e0e0e0; }
            .audio-waveform { background: #f0f7ff; border-color: #c7e0f4; }
            .waveform-visual span { background: rgba(0, 122, 255, 0.4); }
            .translation-item, .segment-card, .tts-segments-table { background: #f5f5f7; border-color: #e0e0e0; }
            .translation-number, .segment-speaker { background: rgba(0,122,255,0.1); color: #007AFF; }
            .source-text, .target-text, .segment-header, .segment-waveform { background: rgba(0,0,0,0.03); }
            .segment-text p, .tts-segment-time, .tts-segment-text { color: #333; }
            .log-table { background: #f5f5f7; }
            .log-header { background: #e8e8ed; color: #666; }
            .log-time, .log-message { color: #333; }
            .report-footer { background: #f5f5f7; border-color: #e0e0e0; }
            .footer-icon { background: rgba(0,122,255,0.1); }
            .footer-name { color: #007AFF; }
        }
    </style>
</head>
<body>
    <div class="report-container">
        <div class="report-header">
            <div class="brand-icon">🌐</div>
            <h1 class="report-title">同声传译报告</h1>
            <p class="report-subtitle">Session ID: ${sessionId}</p>
            <div class="report-meta">
                <span class="report-meta-item">📅 ${new Date().toLocaleString('zh-CN')}</span>
                <span class="report-meta-item">⏱️ 持续 ${formatDuration(data.duration)}</span>
            </div>
        </div>
        
        ${basicInfoHTML}
        ${translationContentHTML}
        ${rawAudioHTML}
        ${speakerSegmentsHTML}
        ${ttsSegmentsHTML}
        ${deviceHTML}
        ${logsHTML}
        
        <div class="report-footer">
            <div class="footer-brand">
                <div class="footer-icon">🌐</div>
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

    function exportReport(data, sessionId) {
        const htmlContent = generateReportHTML(data, sessionId);
        const dateStr = new Date().toISOString().slice(0, 10);
        const filename = `同声传译报告_${sessionId}_${dateStr}.html`;

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

    return { exportReport, generateReportHTML };
})();

window.TranslationReportExporter = TranslationReportExporter;
