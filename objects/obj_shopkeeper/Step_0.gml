// ★ ในหมู่บ้าน: กด E = เดินเข้าร้าน (ฉาก side-scroll rm_shop_ss)
//   ในร้าน: พ่อค้ายืนหลังเคาน์เตอร์ กด E = เปิดหน้าซื้อขาย
var _interior = (room == rm_shop_ss);
if (!inited) {
    inited = true;
    if (_interior && variable_global_exists("shop_visit") && is_struct(global.shop_visit)) {
        shop_type = global.shop_visit.type;
        shop_name = global.shop_visit.name;
    }
}

var _p = _interior ? instance_find(obj_player_ss, 0) : instance_find(obj_player, 0);
near = (_p != noone) && point_distance(x, y, _p.x, _p.y) < (_interior ? 140 : 100);

if (near && input_pressed("interact")
    && !instance_exists(obj_shop) && !instance_exists(obj_dialogue) && !instance_exists(obj_fade) && !instance_exists(obj_status)) {
    if (_interior) {
        var _sh = instance_create_depth(0, 0, -12000, obj_shop);
        _sh.setup(shop_type, shop_name);
    } else {
        global.shop_visit = { type: shop_type, name: shop_name, rx: x, ry: y + 70 };
        global.player_hp = obj_player.hp;
        global.arrive = "";
        var _f = instance_create_depth(0, 0, -10000, obj_fade);
        _f.target_room = rm_shop_ss;
    }
}

depth = -y;
