// ดาบใน Sanctuary: เดินเข้าใกล้แล้วกด E เพื่อหยิบ (ใส่ภาพจริงได้โดยสร้าง sprite ชื่อ spr_sword_item)
picked = flag_get("sword");
if (picked) instance_destroy();
t = 0;
prompt_a = 0;
start_t = -1;
