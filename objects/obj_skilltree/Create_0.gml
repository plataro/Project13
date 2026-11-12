depth = -12500;

px = 60;
py = 30;
pw = 840;
ph = 480;

node_w = 220;
node_h = 50;
col_x = [px + 140, px + 420, px + 700];
row_y0 = py + 98;
row_gap = 64;

branch_names = ["ดาบ", "ยิง", "ร่างกาย"];
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