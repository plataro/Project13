depth = -12000;

px = 110;
py = 40;
pw = 740;
ph = 460;

row_x = px + 24;
row_w = pw - 48;
row_y0 = py + 90;
row_h = 62;

tab = 0;             // 0 = ซื้อ, 1 = ขาย
msg = "";
msg_timer = 0;
open_delay = 5;      // กันปุ่ม E ที่เปิดร้านถูกนับซ้ำ
hover_row = -1;

buy_ids = ["potion", "heart", "bag"];
sell_list = [];

refresh_sell = function() {
    sell_list = [];
    var _k = item_kinds();
    for (var _i = 0; _i < array_length(_k); _i++) {
        var _n = variable_struct_exists(global.save.items, _k[_i]) ? global.save.items[$ _k[_i]] : 0;
        if (_n > 0) array_push(sell_list, _k[_i]);
    }
}
refresh_sell();