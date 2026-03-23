import type {SidebarsConfig} from '@docusaurus/plugin-content-docs';

const sidebars: SidebarsConfig = {
  mainSidebar: [
    {type: 'doc', id: 'intro', label: '概述'},
    {type: 'doc', id: 'quick-start', label: '快速开始'},
    {type: 'doc', id: 'architecture', label: '架构说明'},
    {
      type: 'category',
      label: '集成指南',
      collapsed: false,
      items: [
        'guide/installation',
        'guide/initialization',
        'guide/ble-connect-flow',
        'guide/data-sync-guide',
        'guide/error-handling',
      ],
    },
    {
      type: 'category',
      label: 'API 参考',
      collapsed: false,
      items: [
        'api/ble-connect',
        {
          type: 'category',
          label: '健康数据',
          collapsed: false,
          items: [
            'api/health/overview',
            'api/health/heart-rate',
            'api/health/sleep',
            'api/health/blood-oxygen',
            'api/health/blood-pressure',
            'api/health/stress',
            'api/health/temperature',
            'api/health/electrocardio',
            'api/health/sport',
            'api/health/daily-activity',
            'api/health/auto-monitor',
          ],
        },
        'api/data-sync',
        {
          type: 'category',
          label: '设备管理',
          collapsed: true,
          items: [
            'api/device/battery',
            'api/device/find',
            'api/device/lock',
            'api/device/firmware',
            'api/device/dial',
          ],
        },
        {
          type: 'category',
          label: '通讯功能',
          collapsed: true,
          items: [
            'api/communication/message',
            'api/communication/contact',
            'api/communication/alarm',
            'api/communication/reminders',
            'api/communication/camera',
          ],
        },
        {
          type: 'category',
          label: '系统设置',
          collapsed: true,
          items: [
            'api/settings/user-info',
            'api/settings/unit',
            'api/settings/language',
            'api/settings/time',
            'api/settings/setting',
            'api/settings/weather',
          ],
        },
        {
          type: 'category',
          label: '扩展功能',
          collapsed: true,
          items: [
            'api/extras/music',
            'api/extras/glasses',
            'api/extras/female-health',
            'api/extras/prayers',
            'api/extras/ai-chat',
            'api/extras/world-clock',
            'api/extras/card-bag',
            'api/extras/app-store',
          ],
        },
      ],
    },
    {type: 'doc', id: 'changelog', label: '更新日志'},
  ],
};

export default sidebars;
