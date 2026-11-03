const API_CONFIG = {
    DEVICE_IP: '__DEVICE_IP__',
    DEVICE_PORT: '__DEVICE_PORT__',
    USE_API: true,
    CHAT_API: '/reports/aichat',
    TRANSLATION_API: '/reports/simultaneous_interpretation',
    AI_AUDIO_RECORDING_API: '/reports/ai_audio_recording',
    OVERVIEW_API: '/reports/overview',
    LOG_API: '/logs',
    AUDIO_MERGE_API: '/audio/merge',
    LOGIN_API: '/login',
    LOGOUT_API: '/logout',

    getBaseUrl: function() {
        return 'http://' + this.DEVICE_IP + ':' + this.DEVICE_PORT;
    },
    getChatUrl: function() {
        return this.getBaseUrl() + this.CHAT_API;
    },
    getChatDetailUrl: function(sessionId) {
        return this.getBaseUrl() + this.CHAT_API + "?session_id=" + sessionId;
    },
    getTranslationUrl: function() {
        return this.getBaseUrl() + this.TRANSLATION_API;
    },
    getTranslationDetailUrl: function(sessionId) {
        return this.getBaseUrl() + this.TRANSLATION_API + "?session_id=" + sessionId;
    },
    getAiAudioRecordingUrl: function() {
        return this.getBaseUrl() + this.AI_AUDIO_RECORDING_API;
    },
    getAiAudioRecordingDetailUrl: function(sessionId) {
        return this.getBaseUrl() + this.AI_AUDIO_RECORDING_API + "?session_id=" + sessionId;
    },
    getOverviewUrl: function() {
        return this.getBaseUrl() + this.OVERVIEW_API;
    },
    getLogUrl: function() {
        return this.getBaseUrl() + this.LOG_API;
    },
    getAudioUrl: function(audioFile) {
        return this.getBaseUrl() + "/" + audioFile;
    },
    getMergeAudioUrl: function() {
        return this.getBaseUrl() + this.AUDIO_MERGE_API;
    },
    getLoginUrl: function() {
        return this.getBaseUrl() + this.LOGIN_API;
    },
    getLogoutUrl: function() {
        return this.getBaseUrl() + this.LOGOUT_API;
    },
    handleApiResponse: async function(response) {
        if (response.status === 401) {
            localStorage.removeItem('aibudsclaw-token');
            alert('登录已过期，请重新登录');
            window.location.href = 'login.html';
            throw new Error('Unauthorized');
        }
        if (!response.ok) {
            throw new Error(`HTTP ${response.status}`);
        }
        return response.json();
    }
};