if (open_delay > 0) open_delay--;
if (msg_timer > 0) {
    msg_timer--;
    if (msg_timer <= 0) msg = "";
}

if (open_delay <= 0 && (keyboard_check_pressed(vk_escape) || keyboard_check_pressed(ord("E")))) {
    save_commit();   // ★ ซื้อ/ขายแล้วเซฟเลย
    instance_destroy();
    exit;
}

var _mx = device_mouse_x_to_gui(0);
var _my = device_mouse_y_to_gui(0);
var _click = (open_delay <= 0) && mouse_check_button_pressed(mb_left);

refresh_sell();

// แถวที่เมาส์ชี้ (รองรับเลื่อนด้วยล้อเมาส์)
hover_row = -1;
var _count = (tab == 0) ? array_length(buy_ids) : array_length(sell_list);
var _maxs = max(0, _count - vis_rows);
if (mouse_wheel_down()) scroll = min(scroll + 1, _maxs);
if (mouse_wheel_up()) scroll = max(scroll - 1, 0);
scroll = clamp(scroll, 0, _maxs);
for (var _i = scroll; _i < min(_count, scroll + vis_rows); _i++) {
    var _ry = row_y0 + (_i - scroll) * row_h;
    if (point_in_rectangle(_mx, _my, row_x, _ry, row_x + row_w, _ry + row_h - 6)) hover_row = _i;
}

if (_click) {
    if (can_buy && point_in_rectangle(_mx, _my, tab_x(0), tab_y, tab_x(0) + tab_w, tab_y + tab_h)) {
        tab = 0;
    }
    else if (can_sell && point_in_rectangle(_mx, _my, tab_x(1), tab_y, tab_x(1) + tab_w, tab_y + tab_h)) {
        tab = 1;
    }
    else if (point_in_rectangle(_mx, _my, close_x1, btn_y1, close_x2, btn_y2)) {
        save_commit();
        instance_destroy();
        exit;
    }
    else if (tab == 1 && point_in_rectangle(_mx, _my, sell_x1, btn_y1, sell_x2, btn_y2)) {
        var _total = 0;
        var _kinds = item_kinds();
        for (var _j = 0; _j < array_length(_kinds); _j++) _total += shop_sell(_kinds[_j], true, sell_mul);
        msg = (_total > 0) ? (L("ขายทั้งหมดได้ ", "Sold all for ") + string(_total) + L(" เหรียญ", " gold")) : L("ไม่มีของให้ขาย", "Nothing to sell");
        msg_timer = 120;
    }
    else if (hover_row >= 0) {
        if (tab == 0) {
            var _r = shop_buy(buy_ids[hover_row]);
            msg = (_r == "") ? L("ซื้อแล้ว!", "Purchased!") : _r;
        } else {
            var _got = shop_sell(sell_list[hover_row], keyboard_check(vk_shift), sell_mul);
            msg = L("ได้รับ ", "Got ") + string(_got) + L(" เหรียญ", " gold");
        }
        msg_timer = 120;
    }
}