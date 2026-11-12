var _gw = display_get_gui_width();
var _gh = display_get_gui_height();
var _gold_col = make_color_rgb(200, 170, 110);

// พื้นมืด
draw_set_alpha(0.65);
draw_set_color(c_black);
draw_rectangle(0, 0, _gw, _gh, false);
draw_set_alpha(1);

// กรอบร้าน
draw_set_color(make_color_rgb(40, 34, 52));
draw_rectangle(px, py, px + pw, py + ph, false);
draw_set_color(_gold_col);
draw_rectangle(px, py, px + pw, py + ph, true);
draw_rectangle(px + 3, py + 3, px + pw - 3, py + ph - 3, true);

draw_set_font(fnt_dialog);
draw_set_valign(fa_middle);

// แท็บ
var _tabs = ["ซื้อ", "ขาย"];
for (var _t = 0; _t < 2; _t++) {
    if ((_t == 0 && !can_buy) || (_t == 1 && !can_sell)) continue;
    var _tx = px + 24 + _t * 170;
    draw_set_color((tab == _t) ? _gold_col : make_color_rgb(70, 62, 86));
    draw_rectangle(_tx, py + 20, _tx + 160, py + 64, false);
    draw_set_color((tab == _t) ? c_black : c_white);
    draw_set_halign(fa_center);
    draw_text(_tx + 80, py + 42, _tabs[_t]);
}

// ชื่อร้าน
draw_set_halign(fa_left);
draw_set_color(_gold_col);
draw_text_transformed(px + 24, py + 6, shop_title, 0.6, 0.6, 0);

// เหรียญที่มี
draw_set_halign(fa_right);
draw_set_color(c_yellow);
draw_text(px + pw - 24, py + 42, string(global.save.gold) + " เหรียญ");

// รายการ
draw_set_halign(fa_left);
if (tab == 0) {
    for (var _i = scroll; _i < min(array_length(buy_ids), scroll + vis_rows); _i++) {
        var _info = shop_item_info(buy_ids[_i]);
        var _ry = row_y0 + (_i - scroll) * row_h;

        draw_set_color((hover_row == _i) ? make_color_rgb(78, 68, 96) : make_color_rgb(56, 48, 70));
        draw_rectangle(row_x, _ry, row_x + row_w, _ry + row_h - 6, false);

        draw_set_color(_info.ok ? c_white : c_gray);
        draw_text(row_x + 14, _ry + 18, _info.name);
        draw_set_color(c_ltgray);
        draw_text_transformed(row_x + 14, _ry + 42, _info.desc, 0.65, 0.65, 0);

        draw_set_halign(fa_right);
        if (!_info.ok) draw_set_color(c_gray);
        else draw_set_color((global.save.gold >= _info.price) ? c_yellow : c_red);
        draw_text(row_x + row_w - 14, _ry + 28, _info.ok ? ((_info.price > 0) ? (string(_info.price) + " เหรียญ") : "สวมใส่") : _info.why);
        draw_set_halign(fa_left);
    }
} else {
    if (array_length(sell_list) == 0) {
        draw_set_halign(fa_center);
        draw_set_color(c_gray);
        draw_text(px + pw / 2, row_y0 + 60, "ไม่มีของสะสมให้ขาย");
        draw_set_halign(fa_left);
    }
    for (var _i2 = scroll; _i2 < min(array_length(sell_list), scroll + vis_rows); _i2++) {
        var _kind = sell_list[_i2];
        var _item = item_data(_kind);
        var _cnt = global.save.items[$ _kind];
        var _ry2 = row_y0 + (_i2 - scroll) * row_h;

        draw_set_color((hover_row == _i2) ? make_color_rgb(78, 68, 96) : make_color_rgb(56, 48, 70));
        draw_rectangle(row_x, _ry2, row_x + row_w, _ry2 + row_h - 6, false);

        draw_set_color(_item.col);
        draw_circle(row_x + 26, _ry2 + 27, 10, false);
        draw_set_color(c_white);
        draw_text(row_x + 52, _ry2 + 18, _item.name + "  x" + string(_cnt));
        draw_set_color(c_ltgray);
        draw_text_transformed(row_x + 52, _ry2 + 42, "คลิก = ขาย 1 ชิ้น · Shift+คลิก = ขายทั้งหมด", 0.6, 0.6, 0);

        draw_set_halign(fa_right);
        draw_set_color(c_yellow);
        draw_text(row_x + row_w - 14, _ry2 + 28, "+" + string(round(_item.price * sell_mul)) + " เหรียญ");
        draw_set_halign(fa_left);
    }

    // ปุ่มขายทั้งหมด
    draw_set_color(make_color_rgb(70, 62, 86));
    draw_rectangle(px + 24, py + ph - 64, px + 224, py + ph - 20, false);
    draw_set_color(c_white);
    draw_set_halign(fa_center);
    draw_text(px + 124, py + ph - 42, "ขายทั้งหมด");
}

// ★ บอกว่ายังมีรายการให้เลื่อน
var _cnt_all = (tab == 0) ? array_length(buy_ids) : array_length(sell_list);
if (_cnt_all > vis_rows) {
    draw_set_halign(fa_center);
    draw_set_color(c_ltgray);
    draw_text_transformed(px + pw / 2, row_y0 + vis_rows * row_h + 4, "ล้อเมาส์เพื่อเลื่อน (" + string(scroll + 1) + "-" + string(min(_cnt_all, scroll + vis_rows)) + " จาก " + string(_cnt_all) + ")", 0.55, 0.55, 0);
    draw_set_halign(fa_left);
}

// ปุ่มปิด
draw_set_color(make_color_rgb(110, 60, 60));
draw_rectangle(px + pw - 164, py + ph - 64, px + pw - 24, py + ph - 20, false);
draw_set_color(c_white);
draw_set_halign(fa_center);
draw_text(px + pw - 94, py + ph - 42, "ปิด (Esc)");

// ข้อความแจ้งผล
if (msg != "") {
    draw_set_color(c_yellow);
    draw_text(px + pw / 2, py + ph - 42, msg);
}

draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);