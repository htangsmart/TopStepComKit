// 登录页面脚本

function loadSettings() {
    const savedSettings = localStorage.getItem('aibudsclaw-settings');
    if (savedSettings) {
        const settings = JSON.parse(savedSettings);
        console.log(settings);
        // 设置输入框的值
        if (settings.deviceIp) {
            document.getElementById('deviceIp').value = settings.deviceIp;
            API_CONFIG.DEVICE_IP = settings.deviceIp;
        }
        else {
            document.getElementById('deviceIp').value = '';
        }
        if (settings.devicePort) {
            document.getElementById('devicePort').value = settings.devicePort;
            API_CONFIG.DEVICE_PORT = settings.devicePort;
        }
        else {
            document.getElementById('devicePort').value = '';
        }
        
    }
}

function saveSettings() {
    const deviceIp = document.getElementById('deviceIp').value;
    const devicePort = document.getElementById('devicePort').value;
    
    const settings = {
        deviceIp: deviceIp,
        devicePort: devicePort
    };
    
    localStorage.setItem('aibudsclaw-settings', JSON.stringify(settings));
    
    // 更新 API 配置
    if (deviceIp) {
        API_CONFIG.DEVICE_IP = deviceIp;
    }
    if (devicePort) {
        API_CONFIG.DEVICE_PORT = devicePort;
    }
}

function toggleCollapse() {
    const collapseSection = document.querySelector('.data-source-section');
    collapseSection.classList.toggle('collapsed');
}

document.addEventListener('DOMContentLoaded', function() {
    // 加载保存的设置
    loadSettings();
    
    // 默认折叠数据源设置区域
    const collapseSection = document.querySelector('.data-source-section');
    collapseSection.classList.add('collapsed');
    
    // 折叠/展开切换事件
    const collapseToggle = document.getElementById('collapseToggle');
    collapseToggle.addEventListener('click', toggleCollapse);
    
    // 单独保存设置按钮事件
    const saveSettingsBtn = document.getElementById('saveSettingsBtn');
    saveSettingsBtn.addEventListener('click', function() {
        saveSettings();
        alert('数据源设置已保存');
    });
    
    const loginForm = document.getElementById('loginForm');
    
    loginForm.addEventListener('submit', function(e) {
        e.preventDefault();
        
        // 保存数据源设置
        saveSettings();
        
        const username = document.getElementById('username').value;
        const password = document.getElementById('password').value;
        
        // API 登录验证
        fetch(API_CONFIG.getLoginUrl(), {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                username: username,
                password: password
            })
        })
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                // 登录成功，保存 token 并跳转到数据概览页面
                localStorage.setItem('aibudsclaw-token', data.token);
                window.location.href = 'overview.html';
            } else {
                // 登录失败，显示错误提示
                alert(data.message || '账号或密码错误');
            }
        })
        .catch(error => {
            console.error('登录请求失败：', error);
            alert('登录请求失败，请检查网络连接或设备配置');
        });
    });
    
    // 添加键盘回车事件
    document.getElementById('password').addEventListener('keypress', function(e) {
        if (e.key === 'Enter') {
            e.preventDefault();
            loginForm.dispatchEvent(new Event('submit'));
        }
    });
});

function togglePasswordVisibility() {
    const passwordInput = document.getElementById('password');
    const toggleBtn = document.getElementById('togglePassword');
    const icon = toggleBtn.querySelector('svg');
    
    if (passwordInput.type === 'password') {
        passwordInput.type = 'text';
        // 切换为隐藏图标（斜杠穿过眼睛）
        icon.innerHTML = '<line x1="1" y1="1" x2="23" y2="23"/><path d="M12 4.5C7 4.5 2.73 7.61 1 12c1.73 4.39 6 7.5 11 7.5s9.27-3.11 11-7.5c-1.73-4.39-6-7.5-11-7.5z"/><circle cx="12" cy="12" r="3"/>';
    } else {
        passwordInput.type = 'password';
        // 切换为显示图标（正常眼睛）
        icon.innerHTML = '<path d="M12 4.5C7 4.5 2.73 7.61 1 12c1.73 4.39 6 7.5 11 7.5s9.27-3.11 11-7.5c-1.73-4.39-6-7.5-11-7.5z"/><circle cx="12" cy="12" r="3"/>';
    }
}