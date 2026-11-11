if (open_delay > 0) open_delay--;
if (msg_timer > 0) {
    msg_timer--;
    if (msg_timer <= 0) msg = "";
}

if (open_delay <= 0 && (keyboard_check_pressed(vk_escape) || keyboard_check_pressed(ord("E")))) {
    instance_destroy();
    exit;
}

var _mx = device_mouse_x_to_gui(0);
var _my = device_mouse_y_to_gui(0);
var _click = (open_delay <= 0) && mouse_check_button_pressed(mb_left);

refresh_sell();

// แถวที่เมาส์ชี้
hover_row = -1;
var _count = (tab == 0) ? array_length(buy_ids) : array_length(sell_list);
for (var _i = 0; _i < _count; _i++) {
    var _ry = row_y0 + _i * row_h;
    if (point_in_rectangle(_mx, _my, row_x, _ry, row_x + row_w, _ry + row_h - 6)) hover_row = _i;
}

if (_click) {
    if (can_buy && point_in_rectangle(_mx, _my, px + 24, py + 20, px + 184, py + 64)) {
        tab = 0;
    }
    else if (can_sell && point_in_rectangle(_mx, _my, px + 194, py + 20, px + 354, py + 64)) {
        tab = 1;
    }
    else if (point_in_rectangle(_mx, _my, px + pw - 164, py + ph - 64, px + pw - 24, py + ph - 20)) {
        instance_destroy();
        exit;
    }
    else if (tab == 1 && point_in_rectangle(_mx, _my, px + 24, py + ph - 64, px + 224, py + ph - 20)) {
        var _total = 0;
        var _kinds = item_kinds();
        for (var _j = 0; _j < array_length(_kinds); _j++) _total += shop_sell(_kinds[_j], true, sell_mul);
        msg = (_total > 0) ? ("ขายทั้งหมดได้ " + string(_total) + " เหรียญ") : "ไม่มีของให้ขาย";
        msg_timer = 120;
    }
    else if (hover_row >= 0) {
        if (tab == 0) {
            var _r = shop_buy(buy_ids[hover_row]);
            msg = (_r == "") ? "ซื้อแล้ว!" : _r;
        } else {
            var _got = shop_sell(sell_list[hover_row], keyboard_check(vk_shift), sell_mul);
            msg = "ได้รับ " + string(_got) + " เหรียญ";
        }
        msg_timer = 120;
    }
}