display_set_gui_size(960, 540);
slides = [];          // ใส่โดย cutscene_start()
on_done = undefined;
idx = 0;
chars = 0;
total = 0;
wrapped = "";
shown_idx = -1;       // สไลด์ที่โหลดข้อความแล้ว
img_a = 0;            // ภาพจางเข้า
black = 1;            // ม่านดำ (1 = มืดสนิท)
closing = false;
music_key = "";       // ★ ใส่โดย cutscene_start() ("" = ใช้เพลงห้องตามปกติ)
fade_in_after = false;
t = 0;
