
/// obj_player_ss - Step Event

// ==========================================
// 1. INPUT
// ==========================================

var move_input = keyboard_check(vk_right)
               - keyboard_check(vk_left);

// รองรับ A / D ด้วย
move_input += keyboard_check(ord("D"))
            - keyboard_check(ord("A"));

// จำกัดค่าไม่ให้เกิน -1 ถึง 1
move_input = clamp(move_input, -1, 1);


// ==========================================
// 2. HORIZONTAL MOVEMENT
// ==========================================

hsp = move_input * move_speed;

// หันหน้าตามทิศที่เดิน
if (move_input != 0)
{
    image_xscale = sign(move_input) * 2;
}

// ตรวจสอบการชนกำแพงและพื้น
if (hsp != 0)
{
    if (!place_meeting(x + hsp, y, obj_ground_ss))
    {
        x += hsp;
    }
    else
    {
        // เคลื่อนที่จนชิดกำแพง
        while (!place_meeting(x + sign(hsp), y, obj_ground_ss))
        {
            x += sign(hsp);
        }
    }
}


// ==========================================
// 3. GRAVITY
// ==========================================

vsp += gravity;

// จำกัดความเร็วในการตก
vsp = min(vsp, 12);


// ==========================================
// 4. VERTICAL COLLISION
// ==========================================

if (vsp != 0)
{
    if (place_meeting(x, y + vsp, obj_ground_ss))
    {
        // หาตำแหน่งที่แตะพื้นพอดี
        while (!place_meeting(x, y + sign(vsp), obj_ground_ss))
        {
            y += sign(vsp);
        }

        vsp = 0;
    }
    else
    {
        y += vsp;
    }
}


// ==========================================
// 5. CHECK GROUNDED
// ==========================================

grounded = place_meeting(x, y + 1, obj_ground_ss);


// ==========================================
// 6. ANIMATION
// ==========================================

if (grounded && move_input != 0)
{
    if (sprite_index != spr_pl_ss_walk)
    {
        sprite_index = spr_pl_ss_walk;
        image_index = 0;
    }

    image_speed = 0.15;
}
else
{
    if (sprite_index != spr_pl_ss_idle)
    {
        sprite_index = spr_pl_ss_idle;
        image_index = 0;
    }

    image_speed = 0.15;
}
