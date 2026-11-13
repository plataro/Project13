depth = -12500;

// ★ 4 สาย x 6 ขั้น
px = 70;
py = 30;
pw = 820;
ph = 480;

node_w = 176;
node_h = 40;
col_x = [px + 116, px + 312, px + 508, px + 704];
row_y0 = py + 98;
row_gap = 50;

close_x1 = px + pw - 120;
close_x2 = px + pw - 20;
close_y1 = py + ph - 40;
close_y2 = py + ph - 12;
branch_icon = ["sword", "fire", "bolt", "body"];
branch_col = [make_color_rgb(240, 120, 100), make_color_rgb(255, 160, 70), make_color_rgb(170, 140, 255), make_color_rgb(120, 220, 160)];
open_t = 0;
pad_b = 0;      // ★ สาย/ขั้นที่เลือกด้วยจอย
pad_t = 0;
pad_on = (global.input_dev == "pad");
pad_mx = device_mouse_x_to_gui(0);
pad_my = device_mouse_y_to_gui(0);

branch_names = function() { return [L("ดาบ", "Sword"), L("ยิง", "Shooting"), L("เวท / ไม้ตาย", "Magic / Ult"), L("ร่างกาย", "Body")]; };
branch_subs = function() { return [L("คลิก + สกิล 3", "Click + Skill 3"), L("สกิล 1 + 2", "Skill 1 + 2"), L("สกิล 4 + ไม้ตาย", "Skill 4 + Ultimate"), L("อัปโดยรวม", "General")]; };
nodes = skill_nodes();
hover_key = "";
msg = "";
msg_timer = 0;
open_delay = 5;

node_rect = function(_n) {
    var _cx = col_x[_n.branch];
    var _y = row_y0 + _n.tier * row_gap;
    return [_cx - node_w / 2, _y, _cx + node_w / 2, _y + node_h];
}
sfx("ui_select");   // ★ เปิดสกิลทรี
