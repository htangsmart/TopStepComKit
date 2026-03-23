import React from 'react';
import Link from '@docusaurus/Link';
import useDocusaurusContext from '@docusaurus/useDocusaurusContext';
import Layout from '@theme/Layout';
import styles from './index.module.css';

const CONTENT = {
  zh: {
    layoutTitle: 'SDK 文档',
    layoutDesc: 'TopStepComKit iOS SDK 技术文档',
    badge: 'iOS SDK · Objective-C',
    subtitle: '智能穿戴设备 iOS 接入 SDK，统一的接口层覆盖蓝牙连接、健康数据、设备控制全场景，支持 iOS 12.0+，CocoaPods 一行接入。',
    primaryBtn: '快速开始 →',
    secondaryBtn: '浏览 API 文档',
    featuresTitle: '功能全覆盖',
    featuresSubtitle: '38 个功能模块，153 个接口定义，覆盖穿戴设备开发全场景',
    quickTitle: '快速导航',
    features: [
      { icon: '📡', title: '蓝牙连接管理', desc: '5 阶段状态机，覆盖搜索、绑定、认证、断开、解绑全流程，支持高级扫描过滤。' },
      { icon: '❤️', title: '健康数据监测', desc: '心率、血氧、血压、压力、体温、心电、睡眠、运动、日常活动，共 9 大健康指标。' },
      { icon: '🔄', title: '数据同步', desc: '支持按时间范围批量同步历史健康数据，原始数据与每日汇总两种粒度。' },
      { icon: '🎨', title: '表盘管理', desc: '内置、自定义、云端表盘推送，支持多平台设备差异化处理。' },
      { icon: '⚙️', title: '设备控制', desc: '闹钟、消息通知、联系人、天气、语言、单位、OTA 固件升级等完整设备功能。' },
      { icon: '🔌', title: '多平台支持', desc: '统一接口层屏蔽底层差异，一套代码适配中科、新平台、柿子穿、伸聚、CRP 等设备。' },
    ],
    quickLinks: [
      { icon: '🚀', label: '快速开始', to: '/docs/quick-start' },
      { icon: '📡', label: '蓝牙连接', to: '/docs/api/ble-connect' },
      { icon: '❤️', label: '健康数据', to: '/docs/api/health/overview' },
      { icon: '🔄', label: '数据同步', to: '/docs/api/data-sync' },
      { icon: '🎨', label: '表盘管理', to: '/docs/api/device/dial' },
      { icon: '📐', label: '架构说明', to: '/docs/architecture' },
    ],
  },
  en: {
    layoutTitle: 'SDK Documentation',
    layoutDesc: 'TopStepComKit iOS SDK Technical Documentation',
    badge: 'iOS SDK · Objective-C',
    subtitle: 'iOS SDK for TopStep wearable devices. A unified interface layer covering BLE connection, health data, and device control. Supports iOS 12.0+, one-line CocoaPods integration.',
    primaryBtn: 'Get Started →',
    secondaryBtn: 'Browse API Reference',
    featuresTitle: 'Full Coverage',
    featuresSubtitle: '38 functional modules, 153 interface definitions — everything you need for wearable device development',
    quickTitle: 'Quick Navigation',
    features: [
      { icon: '📡', title: 'BLE Connection', desc: '5-state machine covering scan, bind, auth, disconnect, and unbind. Advanced scan filter support.' },
      { icon: '❤️', title: 'Health Monitoring', desc: 'Heart rate, SpO2, blood pressure, stress, temperature, ECG, sleep, sport, and daily activity — 9 health metrics.' },
      { icon: '🔄', title: 'Data Sync', desc: 'Batch sync historical health data by time range. Raw data and daily summary granularity supported.' },
      { icon: '🎨', title: 'Watch Face', desc: 'Built-in, custom, and cloud push watch faces. Multi-platform device support.' },
      { icon: '⚙️', title: 'Device Control', desc: 'Alarms, notifications, contacts, weather, language, units, OTA firmware upgrade, and more.' },
      { icon: '🔌', title: 'Multi-platform', desc: 'Unified interface layer abstracts device differences. One codebase for all supported device platforms.' },
    ],
    quickLinks: [
      { icon: '🚀', label: 'Quick Start', to: '/docs/quick-start' },
      { icon: '📡', label: 'BLE Connect', to: '/docs/api/ble-connect' },
      { icon: '❤️', label: 'Health Data', to: '/docs/api/health/overview' },
      { icon: '🔄', label: 'Data Sync', to: '/docs/api/data-sync' },
      { icon: '🎨', label: 'Watch Face', to: '/docs/api/device/dial' },
      { icon: '📐', label: 'Architecture', to: '/docs/architecture' },
    ],
  },
};

export default function Home() {
  const { i18n } = useDocusaurusContext();
  const lang = i18n.currentLocale === 'en' ? 'en' : 'zh';
  const c = CONTENT[lang];

  return (
    <Layout title={c.layoutTitle} description={c.layoutDesc}>
      {/* Hero */}
      <header className={styles.heroBanner}>
        <div className={styles.heroContent}>
          <span className={styles.heroBadge}>{c.badge}</span>
          <h1 className={styles.heroTitle}>TopStepComKit SDK</h1>
          <p className={styles.heroSubtitle}>{c.subtitle}</p>
          <div className={styles.heroButtons}>
            <Link className={styles.heroPrimary} to="/docs/quick-start">
              {c.primaryBtn}
            </Link>
            <Link className={styles.heroSecondary} to="/docs/api/ble-connect">
              {c.secondaryBtn}
            </Link>
          </div>
        </div>
      </header>

      <main>
        {/* Feature Cards */}
        <section className={styles.featuresSection}>
          <h2 className={styles.featuresTitle}>{c.featuresTitle}</h2>
          <p className={styles.featuresSubtitle}>{c.featuresSubtitle}</p>
          <div className={styles.featuresGrid}>
            {c.features.map((f) => (
              <div key={f.title} className={styles.featureCard}>
                <span className={styles.featureIcon}>{f.icon}</span>
                <div className={styles.featureTitle}>{f.title}</div>
                <p className={styles.featureDesc}>{f.desc}</p>
              </div>
            ))}
          </div>
        </section>

        {/* Quick Links */}
        <section className={styles.quickSection}>
          <h2 className={styles.featuresTitle}>{c.quickTitle}</h2>
          <div className={styles.quickGrid}>
            {c.quickLinks.map((l) => (
              <Link key={l.label} className={styles.quickLink} to={l.to}>
                <span className={styles.quickLinkIcon}>{l.icon}</span>
                {l.label}
              </Link>
            ))}
          </div>
        </section>
      </main>
    </Layout>
  );
}
