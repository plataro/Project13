
/// obj_player_ss - Create Event

// ==========================================
// SPRITE
// ==========================================

sprite_index = spr_pl_ss_idle;
image_index = 0;

// ความเร็วแอนิเมชัน
image_speed = 0.15;

// ขนาดตัวละครบนหน้าจอ
image_xscale = 2;
image_yscale = 2;

// หันหน้าไปทางขวา
image_xscale = 2;

// ==========================================
// MOVEMENT VARIABLES
// ==========================================

hsp = 0;
vsp = 0;

move_speed = 4;
run_speed = 6;

gravity = 0.5;
jump_speed = 10;

grounded = false;

// ==========================================
// ANIMATION STATE
// ==========================================

anim_state = "idle";
