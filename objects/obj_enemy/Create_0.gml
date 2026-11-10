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
aim_at_player = function(_lead) {
    if (!instance_exists(obj_player)) return atk_dir;
    var _tx = obj_player.x + obj_player.hsp * _lead;
    var _ty = obj_player.y + obj_player.vsp * _lead;
    return point_direction(x, y, _tx, _ty);
}

has_los = function() {
    if (!instance_exists(obj_player)) return false;
    return collision_line(x, y, obj_player.x, obj_player.y, obj_wall, false, true) == noone;
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
            if (atk_cur.turn > 0) {
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
        if (_d < 110 && has_los()) {
            begin_attack("slash");
            exit;
        }
        if (_d > 70) {   // ใกล้พอแล้วหยุด ไม่เดินทับผู้เล่น
            var _dir = dir_to_player() + flank * clamp((_d - 80) / 200, 0, 1);
            hsp = lengthdir_x(move_speed * 1.2, _dir);
            vsp = lengthdir_y(move_speed * 1.2, _dir);
        }
        if (token_timer <= 0) release_token(90);
    } else {
        strafe(ring_dist, move_speed);
    }
}

take_damage = function(_dmg, _dir) {
    hp -= _dmg;
    flash = 6;
    hp_bar_timer = 180;   // ★ แสดงหลอดเลือด 3 วินาทีหลังโดนตี
    kb_x = lengthdir_x(8, _dir);
    kb_y = lengthdir_y(8, _dir);

    // ★ เลขดาเมจลอยเหนือหัว
    var _r = enemy_hurt_rect(id);
    spawn_damage_text((_r[0] + _r[2]) / 2 + irandom_range(-14, 14), _r[1] + 6, _dmg);

    // ตีโดนตอนเตรียมโจมตี = ขัดจังหวะ (ศัตรูตัวเล็กเท่านั้น ลบบล็อกนี้ได้ถ้าไม่ชอบ)
    if (object_index != obj_enemy_boss && atk_state == "windup") {
        atk_state = "";
        atk_cur = undefined;
        telegraph = false;
    }
}