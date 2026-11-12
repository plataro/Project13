depth = -12000;

// ★ ขนาดเล็กลง (เดิม 740x460)
px = 190;
py = 62;
pw = 580;
ph = 416;

row_x = px + 20;
row_w = pw - 40;
row_y0 = py + 96;
row_h = 56;

// แท็บ / ปุ่ม (ใช้ทั้ง Draw และ Step)
tab_y = py + 50;
tab_w = 110;
tab_h = 30;
tab_x = function(_t) { return px + 20 + _t * (tab_w + 8); };
btn_y1 = py + ph - 46;
btn_y2 = py + ph - 16;
close_x1 = px + pw - 130;
close_x2 = px + pw - 20;
sell_x1 = px + 20;
sell_x2 = px + 160;
open_t = 0;          // แอนิเมชันเปิด
pad_row = 0;         // ★ แถวที่เลือกด้วยจอย/ลูกศร
pad_on = (global.input_dev == "pad");
pad_mx = device_mouse_x_to_gui(0);
pad_my = device_mouse_y_to_gui(0);

tab = 0;             // 0 = ซื้อ, 1 = ขาย
msg = "";
msg_timer = 0;
open_delay = 5;      // กันปุ่ม E ที่เปิดร้านถูกนับซ้ำ
hover_row = -1;
scroll = 0;          // ★ เลื่อนรายการ (ล้อเมาส์) เมื่อสินค้าเยอะ
vis_rows = 4;

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
        case "jeweler":   // ★ เครื่องประดับ
            buy_ids = acc_shop_list();
            can_sell = false;
            break;
        case "alchemist": // ★ บัฟ
            buy_ids = buff_list();
            can_sell = false;
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