depth = -12500;

// ★ เล็กลง (เดิม 840x480)
px = 130;
py = 46;
pw = 700;
ph = 448;

node_w = 184;
node_h = 42;
col_x = [px + 120, px + 350, px + 580];
row_y0 = py + 92;
row_gap = 54;

close_x1 = px + pw - 120;
close_x2 = px + pw - 20;
close_y1 = py + ph - 40;
close_y2 = py + ph - 12;
branch_icon = ["sword", "fire", "star"];
branch_col = [make_color_rgb(240, 120, 100), make_color_rgb(255, 160, 70), make_color_rgb(120, 200, 255)];
open_t = 0;
pad_b = 0;      // ★ สาย/ขั้นที่เลือกด้วยจอย
pad_t = 0;
pad_on = (global.input_dev == "pad");
pad_mx = device_mouse_x_to_gui(0);
pad_my = device_mouse_y_to_gui(0);

branch_names = function() { return [L("ดาบ", "Sword"), L("ยิง", "Shooting"), L("ร่างกาย", "Body")]; };
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