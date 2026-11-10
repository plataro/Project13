// ตารางท่าของผู้เล่น: spr = sprite, n = จำนวนเฟรมต่อ 1 ทิศ, fps = ความเร็ว (เฉพาะท่าที่วนซ้ำ)
// ต้องสร้าง sprite ชื่อเหล่านี้ให้ครบก่อน ไม่งั้นจะคอมไพล์ไม่ผ่าน
function anim_config() {
    return {
        idle:   { spr: spr_pl_idle_down,   n: 10, fps: 8 },
        walk:   { spr: spr_pl_walk,   n: 6,  fps: 10 },
        run:    { spr: spr_pl_walk,   n: 6,  fps: 16 },
        roll:   { spr: spr_pl_roll,   n: 8,  fps: 0 },
        hurt:   { spr: spr_pl_hurt,   n: 5,  fps: 0 },
        attack: { spr: spr_pl_attack, n: 8,  fps: 0 }
    };
}

// หน้าจอ face (0=ขวา 1=บน 2=ซ้าย 3=ล่าง) ไปอยู่แถวที่เท่าไหร่ของตาราง (นับจาก 0)
// เดาไว้ว่าแถว 0=ล่าง 1=ซ้าย 2=ขวา 3=บน ถ้าซ้าย-ขวากลับกันตอนเล่น ให้สลับเลข 2 กับ 1
global.face_row = [2, 3, 1, 0];

// ขยายภาพตัวละคร (ต้องเป็นจำนวนเต็ม ไม่งั้นพิกเซลเบลอ)
global.pl_scale = 2;