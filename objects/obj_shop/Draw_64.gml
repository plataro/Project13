// ★ ร้านค้า (สไตล์ UI ใหม่ ขนาดเล็กลง) — placeholder
var _gw = display_get_gui_width();
var _gh = display_get_gui_height();
open_t = min(1, open_t + 1 / 10);
var _ok = 1 - power(1 - open_t, 3);
var _oy = (1 - _ok) * 24;

// พื้นมืด
draw_set_alpha(0.6 * _ok);
draw_set_color(c_black);
draw_rectangle(0, 0, _gw, _gh, false);
draw_set_alpha(1);

var _px = px;
var _py = py + _oy;
ui_panel(_px, _py, _px + pw, _py + ph, _ok);
draw_set_alpha(_ok);
draw_set_font(fnt_dialog);

// ชื่อร้าน + เส้นใต้
draw_set_halign(fa_left);
draw_set_valign(fa_middle);
ui_text_bold(_px + 22, _py + 24, shop_type_name(shop_type), 0.62, UI_GOLD);
draw_set_color(UI_GOLD_DARK);
draw_line(_px + 20, _py + 42, _px + pw - 20, _py + 42);

// เหรียญที่มี
draw_set_halign(fa_right);
ui_text(_px + pw - 40, _py + 24, string(global.save.gold), 0.55, make_color_rgb(255, 215, 90));
ui_icon("coin", _px + pw - 28, _py + 24, 7, make_color_rgb(255, 210, 80));

// แท็บ
var _tabs = [L("ซื้อ", "Buy"), L("ขาย", "Sell")];
draw_set_halign(fa_center);
for (var _t = 0; _t < 2; _t++) {
    if ((_t == 0 && !can_buy) || (_t == 1 && !can_sell)) continue;
    var _tx = tab_x(_t);
    var _ty = tab_y + _oy;
    var _on = (tab == _t);
    draw_set_color(_on ? make_color_rgb(70, 58, 34) : UI_BG);
    draw_rectangle(_tx, _ty, _tx + tab_w, _ty + tab_h, false);
    draw_set_color(_on ? UI_GOLD : UI_GOLD_DARK);
    draw_rectangle(_tx, _ty, _tx + tab_w, _ty + tab_h, true);
    if (_on) draw_rectangle(_tx + 2, _ty + tab_h - 3, _tx + tab_w - 2, _ty + tab_h - 1, false);
    if (_on) ui_text_bold(_tx + tab_w / 2, _ty + tab_h / 2, _tabs[_t], 0.55, UI_GOLD);
    else ui_text(_tx + tab_w / 2, _ty + tab_h / 2, _tabs[_t], 0.55, UI_MUTED);
}

// ไอคอนตามชนิดของ
var _icon_of = function(_id) {
    switch (_id) {
        case "potion": case "bag": return "potion";
        case "greatsword": return "sword";
        case "hammer": return "hammer";
        case "heart": return "star";
    }
    if (!is_undefined(buff_data(_id))) return "potion";
    return "gem";
};

// รายการ
draw_set_halign(fa_left);
var _hl = function(_x1, _y1, _x2, _y2, _hover) {
    draw_set_color(_hover ? make_color_rgb(52, 44, 66) : make_color_rgb(30, 27, 42));
    draw_rectangle(_x1, _y1, _x2, _y2, false);
    draw_set_color(_hover ? UI_GOLD : make_color_rgb(70, 62, 86));
    draw_rectangle(_x1, _y1, _x2, _y2, true);
    if (_hover) ui_highlight(_x1 + 1, _y1 + 1, _x2 - 1, _y2 - 1, 0.6);
};
if (tab == 0) {
    for (var _i = scroll; _i < min(array_length(buy_ids), scroll + vis_rows); _i++) {
        var _info = shop_item_info(buy_ids[_i]);
        var _ry = row_y0 + (_i - scroll) * row_h + _oy;
        var _hov = (hover_row == _i);
        _hl(row_x, _ry, row_x + row_w, _ry + row_h - 6, _hov);

        // ช่องไอคอน
        draw_set_color(UI_BG);
        draw_rectangle(row_x + 8, _ry + 7, row_x + 44, _ry + row_h - 13, false);
        draw_set_color(UI_GOLD_DARK);
        draw_rectangle(row_x + 8, _ry + 7, row_x + 44, _ry + row_h - 13, true);
        var _bd = buff_data(buy_ids[_i]);
        ui_icon(_icon_of(buy_ids[_i]), row_x + 26, _ry + (row_h - 6) / 2, 11, is_undefined(_bd) ? (_info.ok ? UI_GOLD : c_gray) : _bd.col);

        ui_text_bold(row_x + 56, _ry + 16, _info.name, ui_fit(_info.name, 0.5, row_w - 170), _info.ok ? UI_TEXT : c_gray, false);
        ui_text(row_x + 56, _ry + 36, _info.desc, ui_fit(_info.desc, 0.4, row_w - 140), UI_MUTED);

        draw_set_halign(fa_right);
        var _pc = !_info.ok ? c_gray : ((global.save.gold >= _info.price) ? make_color_rgb(255, 215, 90) : make_color_rgb(255, 100, 100));
        var _pt = _info.ok ? ((_info.price > 0) ? string(_info.price) : L("สวมใส่", "Equip")) : _info.why;
        ui_text_bold(row_x + row_w - ((_info.ok && _info.price > 0) ? 30 : 14), _ry + (row_h - 6) / 2, _pt, 0.5, _pc);
        if (_info.ok && _info.price > 0) ui_icon("coin", row_x + row_w - 18, _ry + (row_h - 6) / 2, 6, make_color_rgb(255, 210, 80));
        draw_set_halign(fa_left);
    }
} else {
    if (array_length(sell_list) == 0) {
        draw_set_halign(fa_center);
        ui_text(_px + pw / 2, row_y0 + 60 + _oy, L("ไม่มีของสะสมให้ขาย", "Nothing to sell"), 0.55, UI_MUTED);
        draw_set_halign(fa_left);
    }
    for (var _i2 = scroll; _i2 < min(array_length(sell_list), scroll + vis_rows); _i2++) {
        var _kind = sell_list[_i2];
        var _item = item_data(_kind);
        var _cnt = global.save.items[$ _kind];
        var _ry2 = row_y0 + (_i2 - scroll) * row_h + _oy;
        _hl(row_x, _ry2, row_x + row_w, _ry2 + row_h - 6, hover_row == _i2);

        draw_set_color(UI_BG);
        draw_rectangle(row_x + 8, _ry2 + 7, row_x + 44, _ry2 + row_h - 13, false);
        draw_set_color(UI_GOLD_DARK);
        draw_rectangle(row_x + 8, _ry2 + 7, row_x + 44, _ry2 + row_h - 13, true);
        ui_icon("gem", row_x + 26, _ry2 + (row_h - 6) / 2, 11, _item.col);

        ui_text_bold(row_x + 56, _ry2 + 16, _item.name + "  x" + string(_cnt), 0.5, UI_TEXT, false);
        ui_text(row_x + 56, _ry2 + 36, L("คลิก = ขาย 1 ชิ้น | Shift+คลิก = ขายทั้งหมด", "Click = sell 1 | Shift+Click = sell all"), 0.4, UI_MUTED);

        draw_set_halign(fa_right);
        ui_text_bold(row_x + row_w - 30, _ry2 + (row_h - 6) / 2, "+" + string(round(_item.price * sell_mul)), 0.5, make_color_rgb(255, 215, 90));
        ui_icon("coin", row_x + row_w - 18, _ry2 + (row_h - 6) / 2, 6, make_color_rgb(255, 210, 80));
        draw_set_halign(fa_left);
    }
}

// ★ บอกว่ายังมีรายการให้เลื่อน
var _cnt_all = (tab == 0) ? array_length(buy_ids) : array_length(sell_list);
if (_cnt_all > vis_rows) {
    draw_set_halign(fa_center);
    ui_text(_px + pw / 2, row_y0 + vis_rows * row_h + 6 + _oy, L("ล้อเมาส์เพื่อเลื่อน (", "Scroll wheel (") + string(scroll + 1) + "-" + string(min(_cnt_all, scroll + vis_rows)) + L(" จาก ", " of ") + string(_cnt_all) + ")", 0.42, UI_MUTED);
    draw_set_halign(fa_left);
}

// ปุ่ม
var _mx = device_mouse_x_to_gui(0);
var _my = device_mouse_y_to_gui(0);
var _button = function(_x1, _y1, _x2, _y2, _txt, _col, _mx, _my) {
    var _h = point_in_rectangle(_mx, _my, _x1, _y1, _x2, _y2);
    draw_set_color(_h ? merge_color(_col, c_white, 0.15) : _col);
    draw_rectangle(_x1, _y1, _x2, _y2, false);
    draw_set_color(_h ? UI_GOLD : UI_GOLD_DARK);
    draw_rectangle(_x1, _y1, _x2, _y2, true);
    draw_set_halign(fa_center);
    ui_text(( _x1 + _x2) / 2, (_y1 + _y2) / 2, _txt, 0.5, UI_TEXT);
    draw_set_halign(fa_left);
};
if (tab == 1) _button(sell_x1, btn_y1 + _oy, sell_x2, btn_y2 + _oy, L("ขายทั้งหมด", "Sell All"), make_color_rgb(40, 70, 50), _mx, _my);
_button(close_x1, btn_y1 + _oy, close_x2, btn_y2 + _oy, L("ปิด (E)", "Close (E)"), make_color_rgb(80, 40, 44), _mx, _my);

// ข้อความแจ้งผล
if (msg != "") {
    draw_set_halign(fa_center);
    ui_text_bold(_px + pw / 2, (btn_y1 + btn_y2) / 2 + _oy, msg, 0.5, make_color_rgb(255, 225, 120));
}

draw_set_alpha(1);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
