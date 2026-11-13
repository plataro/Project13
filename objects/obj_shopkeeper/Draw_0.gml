draw_shadow(x, y, 22, 8);

// ★ ภาพพ่อค้าแม่ค้าตามชนิดร้าน (ภาพนิ่ง หายใจเบา ๆ)
var _spr = spr_npc_villager;
switch (shop_type) {
    case "smith":     _spr = spr_npc_smith; break;
    case "buyer":     _spr = spr_npc_buyer; break;
    case "jeweler":   _spr = spr_npc_jeweler; break;
    case "alchemist": _spr = spr_npc_alchemist; break;
}
var _br = sin(current_time / 420 + x) * 0.03;
draw_sprite_ext(_spr, 0, round(x), round(y), 2.5, 2.5 * (1 + _br), 0, c_white, 1);

draw_set_font(fnt_dialog);
draw_set_halign(fa_center);
draw_set_color(c_white);
draw_text_transformed(round(x), round(y) - 112, shop_type_name(shop_type), 0.6, 0.6, 0);
if (!variable_instance_exists(id, "pr_a")) pr_a = 0;
pr_a = lerp(pr_a, (near && !instance_exists(obj_shop)) ? 1 : 0, 0.2);
ui_prompt(round(x), round(y) - 124, input_label("interact"), (room == rm_shop_ss) ? L("ซื้อขาย", "Trade") : L("เข้าร้าน", "Enter shop"), pr_a);

draw_set_halign(fa_left);
draw_set_color(c_white);