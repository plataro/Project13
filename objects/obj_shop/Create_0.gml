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

shop_type = "general";
shop_title = "พ่อค้า";
sell_mul = 1;        // ตัวคูณราคารับซื้อของร้านนี้
can_buy = true;
can_sell = true;
buy_ids = ["potion", "heart", "bag"];
sell_list = [];

// ตั้งชนิดร้าน: general = ซื้อ+ขาย, smith = อาวุธ/เกราะ, buyer = รับซื้อของราคาดี
setup = function(_type, _title) {
    shop_type = _type;
    shop_title = _title;
    switch (_type) {
        case "smith":
            buy_ids = ["greatsword", "hammer", "armor1", "armor2"];
            can_sell = false;
            break;
        case "buyer":
            buy_ids = [];
            can_buy = false;
            sell_mul = 1.4;
            tab = 1;
            break;
    }
}

refresh_sell = function() {
    sell_list = [];
    var _k = item_kinds();
    for (var _i = 0; _i < array_length(_k); _i++) {
        var _n = variable_struct_exists(global.save.items, _k[_i]) ? global.save.items[$ _k[_i]] : 0;
        if (_n > 0) array_push(sell_list, _k[_i]);
    }
}
refresh_sell();