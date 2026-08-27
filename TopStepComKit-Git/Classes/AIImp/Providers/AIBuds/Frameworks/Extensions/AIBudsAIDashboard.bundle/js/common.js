// 公共函数库

// 加载数据源设置
function loadSettings() {
    const savedSettings = localStorage.getItem('aibudsclaw-settings');
    if (savedSettings) {
        const settings = JSON.parse(savedSettings);
        
        // 更新 API 配置
        if (settings.deviceIp) {
            API_CONFIG.DEVICE_IP = settings.deviceIp;
        }
        if (settings.devicePort) {
            API_CONFIG.DEVICE_PORT = settings.devicePort;
        }
    }
}

// 页面初始化时自动加载设置
document.addEventListener('DOMContentLoaded', function() {
    loadSettings();
});