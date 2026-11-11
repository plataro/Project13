// ชื่อที่ขึ้นตอนเข้าห้อง ปล่อยว่างถ้าไม่อยากให้ขึ้น
function room_title_text() {
    switch (room) {
        case rm_the_sanctuary_ss:          return "The Sanctuary";
        case rm_level_1_the_forest:        return "The Forest";
        case rm_the_village:               return "The Village";
        case rm_level_2_the_abandoned_mine: return "The Abandoned Mine";
        case rm_level_3_the_castle:        return "The Castle";
        case rm_the_final_ss:              return "The Final Hall";
    }
    return "";
}