display_set_gui_size(960, 540);
shown_end = false;
end_t = 0;        // ★ นับเฟรมหลังขึ้นหน้าจบ (แอนิเมชัน + เครดิตเลื่อน)
// บทสนทนาตอนจบ -> สไลด์ภาพประกอบ -> หน้าจบ
dialogue_start(story_lines("ending_" + global.ending), ending_after_dialogue);
