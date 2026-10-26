import io, sys
base = sys.argv[1]
KEYS = [
 ('preset_custom',            '自定义组合', 'Custom combination', 'कस्टम संयोजन'),
 ('preset_face_scene',        '问路、接待', 'Directions, reception', 'रास्ता पूछना, स्वागत'),
 ('preset_private_scene',     '商务、会议', 'Business, meetings', 'व्यापार, बैठक'),
 ('preset_portable_scene',    '临时交流', 'Quick chats', 'त्वरित बातचीत'),
 ('preset_face_desc',         '我用手机，对方用充电仓。各自收音、各自看译文。', 'You use the phone, the other person uses the charging case. Each side records and reads on its own device.', 'आप फ़ोन इस्तेमाल करते हैं, सामने वाला चार्जिंग केस। हर पक्ष अपने डिवाइस पर बोलता और पढ़ता है।'),
 ('preset_private_desc',      '我戴耳机说和听，对方用充电仓。不用把手机递给对方。', 'You speak and listen through the earbuds, the other person uses the charging case. No need to hand over your phone.', 'आप ईयरबड्स से बोलते-सुनते हैं, सामने वाला चार्जिंग केस इस्तेमाल करता है। फ़ोन देने की ज़रूरत नहीं।'),
 ('preset_portable_desc',     '我戴耳机，对方用手机。充电仓只需在线，不参与展示。', 'You use the earbuds, the other person uses the phone. The case only needs to stay connected.', 'आप ईयरबड्स, सामने वाला फ़ोन इस्तेमाल करता है। केस केवल कनेक्ट रहना चाहिए।'),
 ('preset_custom_desc',       '按下面矩阵里的选择收音与播报。', 'Capture and playback follow the matrix below.', 'रिकॉर्डिंग और प्लेबैक नीचे की तालिका के अनुसार।'),
 ('setup_title',              'AI 对话翻译', 'AI Conversation', 'AI बातचीत अनुवाद'),
 ('setup_section_languages',  '双方语言', 'Languages', 'भाषाएँ'),
 ('setup_section_mode',       '怎么交流', 'How to talk', 'कैसे बात करें'),
 ('setup_section_matrix',     '谁收音、在哪听译文', 'Who records, who listens', 'कौन रिकॉर्ड करे, कौन सुने'),
 ('setup_section_playback',   '播报', 'Playback', 'प्लेबैक'),
 ('setup_me_key',             '我说', 'I speak', 'मैं बोलता हूँ'),
 ('setup_peer_key',           '对方说', 'They speak', 'वे बोलते हैं'),
 ('setup_lang_hint_fmt',      '%@收音 · 译文经%@', 'Mic: %@ · hear on %@', 'माइक: %@ · सुनें: %@'),
 ('matrix_col_me',            '我', 'Me', 'मैं'),
 ('matrix_col_peer',          '对方', 'Them', 'वे'),
 ('matrix_row_capture',       '收音', 'Record', 'रिकॉर्ड'),
 ('matrix_row_playback',      '听译文', 'Listen', 'सुनें'),
 ('note_case_required',       'AI 功能需连接充电仓后使用：打开仓盖靠近手机，或到设备页连接。', 'AI features need the charging case: open the lid near your phone, or connect it from the device page.', 'AI सुविधाओं के लिए चार्जिंग केस चाहिए: ढक्कन खोलकर फ़ोन के पास रखें या डिवाइस पेज से कनेक्ट करें।'),
 ('note_case_participates',   '充电仓屏端会自动进入对话翻译。使用过程中请保持充电仓在线。', 'The case screen enters conversation mode automatically. Keep the case connected while in use.', 'केस स्क्रीन अपने आप बातचीत मोड में आ जाएगी। उपयोग के दौरान केस कनेक्ट रखें।'),
 ('note_case_idle',           '充电仓负责鉴权，需保持在线；本组合下屏端不做反馈。', 'The case handles authorization and must stay connected; its screen stays idle in this combination.', 'केस प्रमाणीकरण करता है और कनेक्ट रहना चाहिए; इस संयोजन में इसकी स्क्रीन निष्क्रिय रहती है।'),
 ('setup_auto_speak',         '手机自动播报译文', 'Auto-play translations on phone', 'फ़ोन पर अनुवाद स्वतः चलाएँ'),
 ('setup_auto_speak_hint',    '关闭后仍可逐句点击收听；耳机与充电仓始终自动播报', 'When off you can still tap any turn to listen; earbuds and case always play automatically', 'बंद होने पर भी किसी भी पंक्ति पर टैप करके सुन सकते हैं; ईयरबड्स और केस हमेशा स्वतः चलाते हैं'),
 ('setup_auto_speak_na',      '本配置没有用手机播报', 'The phone is not a playback device in this setup', 'इस सेटअप में फ़ोन प्लेबैक डिवाइस नहीं है'),
 ('setup_start_case_required','先连接充电仓', 'Connect the case first', 'पहले केस कनेक्ट करें'),
 ('setup_help_toast',         '选好双方语言和交流方式，再点「开始对话翻译」', 'Pick both languages and a mode, then tap "Start conversation"', 'दोनों भाषाएँ और मोड चुनें, फिर "बातचीत शुरू करें" दबाएँ'),
 ('live_busy',                '对方正在说，请稍候', 'The other side is speaking, please wait', 'सामने वाला बोल रहा है, कृपया प्रतीक्षा करें'),
 ('live_device_exit_requested','充电仓请求退出，正在收尾', 'The case asked to leave; finishing up', 'केस ने बाहर निकलने का अनुरोध किया; समाप्त हो रहा है'),
 ('live_self_fmt',            '我 · %@', 'Me · %@', 'मैं · %@'),
 ('live_peer_fmt',            '对方 · %@', 'Them · %@', 'वे · %@'),
 ('live_route_fmt',           '译文经%@ / %@', 'Playback: %@ / %@', 'प्लेबैक: %@ / %@'),
 ('live_empty_fmt',           '任一方按住说话，原文和译文会出现在这里。\n对方也可以直接按住%@说话', 'Hold to talk on either side; original and translation appear here.\nThe other person can also hold the %@ to speak', 'किसी भी ओर से दबाकर बोलें; मूल और अनुवाद यहाँ दिखेंगे।\nसामने वाला सीधे %@ दबाकर भी बोल सकता है'),
 ('confirm_title',            '结束这次对话翻译？', 'End this conversation?', 'यह बातचीत समाप्त करें?'),
 ('confirm_body_case',        '充电仓会退出对话翻译回到首页，本次记录会保留在报告里。', 'The case will leave conversation mode and return home. This record is kept in the report.', 'केस बातचीत मोड से बाहर होकर होम पर लौट जाएगा। यह रिकॉर्ड रिपोर्ट में रहेगा।'),
 ('confirm_body',             '本次记录会保留在报告里。', 'This record is kept in the report.', 'यह रिकॉर्ड रिपोर्ट में रहेगा।'),
 ('confirm_stop',             '结束对话翻译', 'End conversation', 'बातचीत समाप्त करें'),
 ('confirm_count_fmt',        '%lu 轮', '%lu turns', '%lu बार'),
 ('confirm_stat_mode',        '模式', 'Mode', 'मोड'),
 ('live_release_to_send',     '松开发送', 'Release to send', 'भेजने के लिए छोड़ें'),
 ('live_peer_speaking',       '对方说话中', 'Other side speaking', 'सामने वाला बोल रहा है'),
 ('live_self_speaking',       '我说话中', 'You are speaking', 'आप बोल रहे हैं'),
 ('live_status_connecting',   '正在连接充电仓…', 'Connecting to the case…', 'केस से कनेक्ट हो रहा है…'),
 ('live_status_ready',        '准备好了，任一方按住说话', 'Ready. Hold to talk on either side', 'तैयार। किसी भी ओर से दबाकर बोलें'),
 ('live_status_replaying',    '正在回放译文，开新一轮会打断', 'Replaying; starting a new turn interrupts it', 'पुनः चल रहा है; नई बारी शुरू करने पर रुक जाएगा'),
 ('live_status_listening_fmt','正在听 %@ 说 · 松开后翻译', 'Listening to %@ · release to translate', '%@ को सुन रहे हैं · छोड़ने पर अनुवाद'),
 ('live_status_translating',  '识别完成，正在翻译', 'Recognized, translating', 'पहचान पूरी, अनुवाद हो रहा है'),
 ('live_status_exiting',      '正在结束…', 'Ending…', 'समाप्त हो रहा है…'),
 ('live_turn_translating',    '翻译中', 'Translating', 'अनुवाद हो रहा है'),
 ('live_turn_device_input_fmt','%@输入中', '%@ input', '%@ इनपुट'),
 ('live_turn_replaying',      '回放中', 'Replaying', 'पुनः चल रहा है'),
 ('live_turn_played_fmt',     '已经%@播报', 'Played on %@', '%@ पर चलाया गया'),
 ('live_turn_not_played',     '未播报，点击播放', 'Not played, tap to listen', 'नहीं चलाया, सुनने के लिए टैप करें'),
 ('live_sync',                '屏端同步', 'Case sync', 'केस सिंक'),
 ('live_stop',                '停止', 'Stop', 'रोकें'),
 ('live_play',                '播放', 'Play', 'चलाएँ'),
 ('report_empty',             '这次没有翻译任何内容。', 'Nothing was translated this time.', 'इस बार कुछ अनुवाद नहीं हुआ।'),
 ('report_copied_fmt',        '已复制 %lu 轮', 'Copied %lu turns', '%lu बारी कॉपी हुईं'),
 ('report_turns',             '轮', 'turns', 'बारी'),
 ('report_split',             '我 / 对方', 'me / them', 'मैं / वे'),
 ('report_list',              '逐轮记录', 'Turn by turn', 'बारी-दर-बारी'),
]
for lang, col in (('zh-Hans', 1), ('en', 2), ('hi', 3)):
    path = '%s/%s.lproj/Localizable.strings' % (base, lang)
    text = io.open(path, encoding='utf-8').read()
    lines = text.split('\n')
    last = max(i for i, l in enumerate(lines) if l.startswith('"ai_conversation.'))
    new = []
    for row in KEYS:
        key = '"ai_conversation.%s"' % row[0]
        if key in text:
            continue
        val = row[col].replace('\\', '\\\\').replace('"', '\\"').replace('\n', '\\n')
        new.append('%s = "%s";' % (key, val))
    lines[last + 1:last + 1] = new
    io.open(path, 'w', encoding='utf-8').write('\n'.join(lines))
    print(lang, 'added', len(new))
