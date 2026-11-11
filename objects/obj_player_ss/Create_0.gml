// กระเบื้องที่ตัวละครยืน/ชนได้ (เพิ่มประตู/ลังตรงนี้ทีหลัง)
global.ss_solids = [obj_ground_ss];
global.ss_cam_ready = false;

mask_index = spr_mask_ss;
depth = -100;
image_speed = 0;       // คุมเฟรมเอง
sc = 2;                // ขนาดภาพ
face = 1;              // 1 = ขวา, -1 = ซ้าย

hsp = 0;
vsp = 0;

walk_speed = 4;
run_speed  = 6;        // กด Shift
accel_g = 0.5;  fric_g = 0.7;    // บนพื้น
accel_a = 0.35; fric_a = 0.12;   // กลางอากาศ

grav       = 0.55;
jump_speed = 11.5;
max_fall   = 14;
jump_cut   = 4;        // ปล่อยปุ่มกระโดดเร็ว = กระโดดเตี้ย

coyote_max = 6;        // ออกจากขอบแล้วยังกระโดดได้อีก 6 เฟรม
buffer_max = 6;        // กดกระโดดก่อนลงพื้น 6 เฟรมก็นับ
coyote = 0;
jump_buffer = 0;
grounded = false;

anim_state = "idle";
anim_t = 0;

// จุดเกิดใหม่ (ชนจุดเซฟแล้วเปลี่ยน)
check_x = x;
check_y = y;
respawn_timer = 0;

die = function() {
    x = check_x;
    y = check_y;
    hsp = 0;
    vsp = 0;
    respawn_timer = 40;
}

instance_create_depth(0, 0, -15000, obj_title_card);