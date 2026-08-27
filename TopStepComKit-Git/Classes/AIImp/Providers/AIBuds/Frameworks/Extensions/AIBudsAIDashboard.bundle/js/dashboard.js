// Dashboard页面脚本
 document.addEventListener('DOMContentLoaded', function() {
    // 初始化图表
    initCharts();
    
    // 初始化页面
    showSection('overview');
});

// 显示指定区块
function showSection(sectionId) {
    // 隐藏所有区块
    document.querySelectorAll('.section').forEach(section => {
        section.classList.remove('active');
    });
    
    // 显示目标区块
    document.getElementById(sectionId).classList.add('active');
    
    // 更新导航项状态
    document.querySelectorAll('.nav-item').forEach(item => {
        item.classList.remove('active');
    });
    
    const navItem = document.querySelector(`a[href="#${sectionId}"]`).parentElement;
    navItem.classList.add('active');
}

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

// 查看对话详情
function viewChatDetail(chatId) {
    // 更新模态框内容
    document.getElementById('detailChatId').textContent = `#${chatId}`;
    
    // 显示模态框
    document.getElementById('chatDetailModal').style.display = 'block';
}

// 查看翻译详情
function viewTranslationDetail(translationId) {
    // 这里可以实现翻译详情的逻辑
    alert(`查看翻译 #${translationId} 详情`);
}

// 关闭模态框
function closeModal() {
    document.getElementById('chatDetailModal').style.display = 'none';
}

// 导出对话报告
function exportChatReport() {
    alert('导出对话报告功能');
}

// 初始化图表
function initCharts() {
    // 对话趋势图表
    const chatTrendCtx = document.getElementById('chatTrendChart').getContext('2d');
    new Chart(chatTrendCtx, {
        type: 'line',
        data: {
            labels: ['00:00', '03:00', '06:00', '09:00', '12:00', '15:00', '18:00', '21:00'],
            datasets: [{
                label: '对话次数',
                data: [5, 3, 2, 15, 25, 30, 20, 10],
                borderColor: '#007AFF',
                backgroundColor: 'rgba(0, 122, 255, 0.1)',
                tension: 0.4,
                fill: true
            }]
        },
        options: {
            responsive: true,
            plugins: {
                legend: {
                    labels: {
                        color: '#b0b0b0'
                    }
                }
            },
            scales: {
                y: {
                    beginAtZero: true,
                    grid: {
                        color: 'rgba(255, 255, 255, 0.1)'
                    },
                    ticks: {
                        color: '#b0b0b0'
                    }
                },
                x: {
                    grid: {
                        color: 'rgba(255, 255, 255, 0.1)'
                    },
                    ticks: {
                        color: '#b0b0b0'
                    }
                }
            }
        }
    });
    
    // 对话时长分布图表
    const durationCtx = document.getElementById('durationChart').getContext('2d');
    new Chart(durationCtx, {
        type: 'bar',
        data: {
            labels: ['1-2分钟', '2-5分钟', '5-10分钟', '10分钟以上'],
            datasets: [{
                label: '对话次数',
                data: [30, 50, 35, 13],
                backgroundColor: [
                    'rgba(0, 122, 255, 0.8)',
                    'rgba(106, 17, 203, 0.8)',
                    'rgba(76, 175, 80, 0.8)',
                    'rgba(255, 152, 0, 0.8)'
                ]
            }]
        },
        options: {
            responsive: true,
            plugins: {
                legend: {
                    labels: {
                        color: '#b0b0b0'
                    }
                }
            },
            scales: {
                y: {
                    beginAtZero: true,
                    grid: {
                        color: 'rgba(255, 255, 255, 0.1)'
                    },
                    ticks: {
                        color: '#b0b0b0'
                    }
                },
                x: {
                    grid: {
                        color: 'rgba(255, 255, 255, 0.1)'
                    },
                    ticks: {
                        color: '#b0b0b0'
                    }
                }
            }
        }
    });
    
    // 语言使用分布图表
    const languageCtx = document.getElementById('languageChart').getContext('2d');
    new Chart(languageCtx, {
        type: 'pie',
        data: {
            labels: ['中文', '英语', '日语', '其他'],
            datasets: [{
                data: [60, 30, 5, 5],
                backgroundColor: [
                    '#007AFF',
                    '#6A11CB',
                    '#4CAF50',
                    '#FF9800'
                ]
            }]
        },
        options: {
            responsive: true,
            plugins: {
                legend: {
                    labels: {
                        color: '#b0b0b0'
                    }
                }
            }
        }
    });
    
    // 功能使用比例图表
    const featureCtx = document.getElementById('featureChart').getContext('2d');
    new Chart(featureCtx, {
        type: 'doughnut',
        data: {
            labels: ['AI对话', '同声传译', '其他功能'],
            datasets: [{
                data: [65, 30, 5],
                backgroundColor: [
                    '#007AFF',
                    '#6A11CB',
                    '#4CAF50'
                ]
            }]
        },
        options: {
            responsive: true,
            plugins: {
                legend: {
                    labels: {
                        color: '#b0b0b0'
                    }
                }
            }
        }
    });
}

// 点击模态框外部关闭
window.onclick = function(event) {
    const modal = document.getElementById('chatDetailModal');
    if (event.target == modal) {
        modal.style.display = 'none';
    }
};

// 模拟数据加载
function loadData() {
    // 这里可以添加从iOS端HTTP服务器获取数据的逻辑
    console.log('加载数据...');
    
    // 模拟数据加载延迟
    setTimeout(() => {
        console.log('数据加载完成');
    }, 1000);
}

// 自动刷新数据
setInterval(loadData, 30000); // 每30秒刷新一次