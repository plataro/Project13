hp = 3;
max_hp = hp;
flash = 0;
last_hit_id = noone;

// ★ หลอดเลือดบนหัว
hp_shown = hp;      // แถบสีขาวที่ไหลตามหลังเลือดจริง
hp_bar_timer = 0;   // นับถอยหลังแสดงหลอดหลังโดนตี
show_bar = (object_index != obj_enemy_boss);   // บอสมีหลอดใหญ่ด้านบนจอแล้ว

move_speed = 2;
sight_range = 500;

hsp = 0;
vsp = 0;
kb_x = 0;
kb_y = 0;

tint = c_white;
telegraph = false;

// กล่องชนที่เท้า บอสใช้กล่องใหญ่ (ศัตรูลูกทุกตัวสืบทอดตามนี้)
mask_index = (object_index == obj_enemy_boss) ? spr_mask_big : spr_mask_small;

// ---- ตัวปรับชั้นเชิง ----
sep_radius = 70;
sep_strength = 2;
max_attackers = 2;
ring_dist = 190;

// ขนาดตัวสำหรับกันทับกัน คิดจากรอยเท้า
var _mw = sprite_get_width(mask_index);
body_r = _mw * 0.5 + 6;
mass = sqr(_mw / 28);

has_token = false;
token_timer = 0;
token_cd = irandom_range(30, 120);
attack_token_cd = 90;   // พักก่อนได้คิวบุกใหม่หลังโจมตีจบ
retreat_timer = 0;
strafe_sign = choose(-1, 1);
strafe_timer = irandom_range(60, 150);
flank = choose(-35, 35);

// ---- การรับรู้: ต้องเห็นผู้เล่นจริง (ไม่มีกำแพงบัง) ถึงจะไล่ ----
home_x = x;
home_y = y;
alert_timer = 0;       // จำผู้เล่นได้อีกกี่เฟรมหลังมองไม่เห็น
los_clear = false;     // ผลเช็กเส้นสายตา อัปเดตทุก ~8 เฟรม (ประหยัดเฟรม)
los_timer = irandom(8);
vis = 0;               // ความทึบตอนวาด (จางเข้า/ออกตามสายตาผู้เล่น)
zone = undefined;      // [x1,y1,x2,y2] ถ้าตั้ง: ออกนอกกรอบไม่ได้ และไล่เฉพาะตอนผู้เล่นอยู่ในกรอบ
no_drop = false;       // true = ตายแล้วไม่ดรอป (ลูกน้องที่ตายตามบอส)
master = noone;        // บอสที่เรียกตัวนี้มา

// ---- จังหวะแรกตอนเจอผู้เล่น: ยังไม่ออกท่า ให้ผู้เล่นได้ตีก่อน (ผู้เล่นไม่เห็นตัวเลขนี้) ----
engaged = false;         // เจอผู้เล่นรอบนี้แล้วหรือยัง
engage_grace = 0;        // เหลือกี่เฟรมก่อนจะเริ่มออกท่าได้
engage_hits = 0;         // โดนตีไปกี่ทีในช่วงนี้
engage_hits_max = 2;     // ★ โดนตีครบกี่ทีแล้วเลิกรอ
// ★ เวลารอสูงสุด (เฟรม) ตามความยาก: ง่าย / กลาง / ยาก ยืนนิ่งใกล้ ๆ ก็ยังโดนตีเมื่อหมดเวลา
engage_grace_time = [100, 75, 50][clamp(global.difficulty, 0, 2)];
// ★ เวลารอจะเริ่มนับเมื่อผู้เล่นเข้ามาใกล้กว่านี้ (px) เท่านั้น ตอนผู้เล่นกำลังเดินเข้าหา เวลาจะยังไม่ลด
engage_range = 140;

// ---- ลอยตัว (บอสกระโดด) / วงเตือนบนพื้น [x, y, รัศมี, ล็อกแล้ว] ----
z = 0;
marker = undefined;
shield = 0;          // เกราะกันกระสุน เหลือกี่เฟรม (บอสใช้)
shield_hp = 0;       // ต้องฟันอีกกี่ทีเกราะถึงแตก

// ---- สถานะท่าโจมตี ----
atk_cur = undefined;
atk_dir = 0;
atk_state = "";   // "", "windup", "active", "recover"
atk_timer = 0;
atk_lunge = 0;

// ---- ฟังก์ชันช่วย ----
dist_to_player = function() {
    if (!instance_exists(obj_player)) return 99999;
    return point_distance(x, y, obj_player.x, obj_player.y);
}

dir_to_player = function() {
    if (!instance_exists(obj_player)) return 0;
    return point_direction(x, y, obj_player.x, obj_player.y);
}

// ทิศไปยังตำแหน่งที่ผู้เล่นกำลังจะไปถึงในอีก _lead เฟรม
// ★ ผู้เล่นกำลังกลิ้ง = ไม่เล็งดักทางกลิ้ง (เดิมเอาความเร็วกลิ้งมาคูณ เลยเล็งไปรอปลายทางที่กลิ้งไปพอดี)
aim_at_player = function(_lead) {
    if (!instance_exists(obj_player)) return atk_dir;
    var _p = obj_player;
    if (_p.state == PState.ROLL) _lead = 0;
    var _tx = _p.x + _p.hsp * _lead;
    var _ty = _p.y + _p.vsp * _lead;
    return point_direction(x, y, _tx, _ty);
}

// ผู้เล่นกำลังกลิ้ง/อมตะอยู่ไหม (ศัตรูจะไม่หมุนตาม)
player_dodging = function() {
    if (!instance_exists(obj_player)) return false;
    return obj_player.state == PState.ROLL || obj_player.dodge_timer > 0;
}

// เช็กจริง (แพง) เรียกเฉพาะใน Step ทุก ~8 เฟรม
los_check = function() {
    if (!instance_exists(obj_player)) return false;
    return collision_line(x, y - 20, obj_player.x, obj_player.y - 20, obj_wall, false, true) == noone;
}

// ผลที่ AI ใช้ (อ่านจากแคช)
has_los = function() {
    return los_clear;
}

count_attackers = function() {
    var _n = 0;
    with (obj_enemy) {
        if (has_token) _n++;
    }
    return _n;
}

try_get_token = function() {
    if (has_token || token_cd > 0) return;
    if (count_attackers() < max_attackers) {
        has_token = true;
        token_timer = 240;
    }
}

release_token = function(_cooldown) {
    has_token = false;
    token_cd = _cooldown;
}

on_hit_player = function() {
    release_token(90);
    retreat_timer = 40;
}

strafe = function(_ring, _spd) {
    var _d = dist_to_player();
    var _dir = dir_to_player();

    strafe_timer--;
    if (strafe_timer <= 0) {
        strafe_sign *= -1;
        strafe_timer = irandom_range(60, 150);
    }

    var _tx = lengthdir_x(_spd * 0.8, _dir + 90 * strafe_sign);
    var _ty = lengthdir_y(_spd * 0.8, _dir + 90 * strafe_sign);
    var _r = clamp((_d - _ring) / 60, -1, 1) * _spd;
    hsp = _tx + lengthdir_x(_r, _dir);
    vsp = _ty + lengthdir_y(_r, _dir);
}

// เพิ่งเจอผู้เล่น (เห็นตัว หรือโดนตีก่อน) = เริ่มช่วงรอ สุ่มยาวสั้นนิดหน่อยให้ไม่พร้อมกันทั้งฝูง
engage = function() {
    if (engaged) return;
    engaged = true;
    engage_hits = 0;
    engage_grace = round(engage_grace_time * random_range(0.8, 1.2));
}

// ออกท่าได้หรือยัง (ทุก AI เช็กก่อนเริ่มท่า)
can_attack = function() {
    return engage_grace <= 0;
}

// เริ่มท่าโจมตี _name (ดูข้อมูลที่ enemy_attack_data)
begin_attack = function(_name) {
    atk_cur = enemy_attack_data(_name);
    if (is_undefined(atk_cur)) return;
    atk_state = "windup";
    atk_timer = atk_cur.windup;
    atk_dir = aim_at_player(atk_cur.lead);
    telegraph = true;
}

// เดินเครื่องท่าโจมตี คืนค่า true ถ้ายังโจมตีอยู่ (ai ต้องไม่ทำอย่างอื่นพร้อมกัน)
run_attack = function() {
    if (atk_state == "") return false;

    switch (atk_state) {
        case "windup":
            // เล็งล่วงหน้าตามผู้เล่น จนเหลือ lock เฟรมสุดท้ายถึงล็อกทิศ
            if (atk_timer > atk_cur.lock) atk_dir = aim_at_player(atk_cur.lead);
            atk_timer--;
            if (atk_timer <= 0) {
                telegraph = false;
                atk_state = "active";
                atk_timer = atk_cur.active;
                atk_lunge = atk_cur.lunge_frames;
                var _h = instance_create_depth(x, y, depth, obj_enemy_hitbox);
                _h.owner = id;
                _h.atk = atk_cur;
                _h.image_angle = atk_dir;
                _h.lift = atk_cur.lift;
            }
            break;

        case "active":
            // หมุนตามผู้เล่นระหว่าง hitbox ทำงาน (turn องศาต่อเฟรม)
            // ★ ผู้เล่นกลิ้งหลบอยู่ = ไม่หมุนตาม (หลบด้านข้างได้จริง)
            if (atk_cur.turn > 0 && !player_dodging()) {
                var _want = aim_at_player(atk_cur.lead * 0.5);
                var _diff = ((_want - atk_dir + 540) mod 360) - 180;
                atk_dir += clamp(_diff, -atk_cur.turn, atk_cur.turn);
                atk_dir = (atk_dir + 360) mod 360;
            }
            if (atk_lunge > 0) {
                hsp = lengthdir_x(atk_cur.lunge_speed, atk_dir);
                vsp = lengthdir_y(atk_cur.lunge_speed, atk_dir);
                atk_lunge--;
            }
            atk_timer--;
            if (atk_timer <= 0) {
                atk_state = "recover";
                atk_timer = atk_cur.recover;
            }
            break;

        case "recover":
            atk_timer--;
            if (atk_timer <= 0) {
                atk_state = "";
                atk_cur = undefined;
                if (has_token) release_token(attack_token_cd);
            }
            break;
    }
    return true;
}

// พฤติกรรมเริ่มต้น (Chaser): เข้าใกล้แล้วฟัน
ai = function() {
    if (run_attack()) exit;

    var _d = dist_to_player();
    if (_d > sight_range) exit;

    if (token_cd > 0) token_cd--;

    if (retreat_timer > 0) {
        retreat_timer--;
        var _away = dir_to_player() + 180;
        hsp = lengthdir_x(move_speed, _away);
        vsp = lengthdir_y(move_speed, _away);
        exit;
    }

    try_get_token();

    if (has_token) {
        token_timer--;
        if (_d < 110 && has_los() && can_attack()) {
            begin_attack("slash");
            exit;
        }
        if (_d < 110 && !can_attack()) {
            // ยังไม่ถึงจังหวะ: ขยับเลี่ยงข้าง ๆ เหมือนหาช่อง (ไม่ยืนนิ่งให้ดูออก)
            strafe(95, move_speed * 0.6);
        } else if (_d > 70) {   // ใกล้พอแล้วหยุด ไม่เดินทับผู้เล่น
            var _dir = dir_to_player() + flank * clamp((_d - 80) / 200, 0, 1);
            hsp = lengthdir_x(move_speed * 1.2, _dir);
            vsp = lengthdir_y(move_speed * 1.2, _dir);
        }
        if (token_timer <= 0) release_token(90);
    } else {
        strafe(ring_dist, move_speed);
    }
}

take_damage = function(_dmg, _dir, _crit = false, _src = "melee") {
    hp -= _dmg;
    flash = 6;
    fx_enemy_hit(id, _dmg, _dir);
    alert_timer = 300;   // โดนตี = รู้ตัวทันที

    // ช่วงรอจังหวะแรก: นับครั้งที่โดนตี ครบแล้วเว้นจังหวะนิดนึงค่อยสวนกลับ (ดูเป็นธรรมชาติ ไม่สวนทันที)
    engage();
    if (engage_grace > 0) {
        engage_hits++;
        if (engage_hits >= engage_hits_max) engage_grace = min(engage_grace, 14);
    }
    hp_bar_timer = 180;   // ★ แสดงหลอดเลือด 3 วินาทีหลังโดนตี
    kb_x = lengthdir_x(8, _dir);
    kb_y = lengthdir_y(8, _dir);

    // ★ เลขดาเมจลอยเหนือหัว
    var _r = enemy_hurt_rect(id);
    spawn_damage_text((_r[0] + _r[2]) / 2 + irandom_range(-14, 14), _r[1] + 6, _dmg, _crit);

    // ตีโดนตอนเตรียมโจมตี = ขัดจังหวะ (ศัตรูตัวเล็กเท่านั้น ลบบล็อกนี้ได้ถ้าไม่ชอบ)
    if (object_index != obj_enemy_boss && atk_state == "windup") {
        atk_state = "";
        atk_cur = undefined;
        telegraph = false;
    }
}