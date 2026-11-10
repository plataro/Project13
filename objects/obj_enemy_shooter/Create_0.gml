event_inherited();

hp = 2;
max_hp = hp;
move_speed = 1.6;
tint = c_orange;
ring_dist = 300;

fire_cd = 100;
fire_timer = irandom_range(40, 100);
telegraph_time = 22;
telegraph_timer = 0;
bullet_speed = 6;

ai = function() {
    var _d = dist_to_player();
    if (_d > sight_range) exit;

    // กำลังเล็ง: ยืนนิ่ง ตัวสั่น แล้วยิงดักทางผู้เล่น
    if (telegraph_timer > 0) {
        telegraph = true;
        telegraph_timer--;
        if (telegraph_timer <= 0) {
            telegraph = false;
            var _lead = _d / bullet_speed;
            var _tx = obj_player.x + obj_player.hsp * _lead * 0.6;
            var _ty = obj_player.y + obj_player.vsp * _lead * 0.6;
            var _a = point_direction(x, y, _tx, _ty);
            var _b = instance_create_depth(x, y, depth, obj_enemy_bullet);
            _b.direction = _a;
            _b.image_angle = _a;
            _b.speed = bullet_speed;
        }
        exit;
    }

    telegraph = false;
    if (fire_timer > 0) fire_timer--;

    if (_d < 200) {
        // ถูกบีบ: ถอย
        var _away = dir_to_player() + 180;
        hsp = lengthdir_x(move_speed * 1.3, _away);
        vsp = lengthdir_y(move_speed * 1.3, _away);
    } else if (!has_los()) {
        // กำแพงบัง: เดินเข้าหามุมยิง
        var _dir = dir_to_player();
        hsp = lengthdir_x(move_speed, _dir);
        vsp = lengthdir_y(move_speed, _dir);
    } else {
        strafe(ring_dist, move_speed);

        // ผลัดกันยิง: ไม่เริ่มเล็งถ้ามี shooter ตัวอื่นกำลังเล็งอยู่
        var _busy = false;
        with (obj_enemy_shooter) {
            if (telegraph) _busy = true;
        }
        if (fire_timer <= 0 && !_busy) {
            fire_timer = fire_cd;
            telegraph_timer = telegraph_time;
        }
    }
}