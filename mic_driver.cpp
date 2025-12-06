#include "mic_driver.h"

MicCore::MicCore(uint32_t core_base_addr) : base_addr(core_base_addr) {}
MicCore::~MicCore() {}

uint16_t MicCore::read_level() {
   uint32_t word = io_read(base_addr, REG_LEVEL);     // addr 1
   return static_cast<uint16_t>(word & 0xFFFF);
}

uint16_t MicCore::read_status() {
   uint32_t word = io_read(base_addr, REG_STATUS);    // addr 0
   return static_cast<uint16_t>(word & 0x0003);       // only two bits used
}

void MicCore::write_threshold(uint16_t th) {
   io_write(base_addr, REG_THRESH, th);
}

void MicCore::clear_flag() {
   io_write(base_addr, REG_CTRL, 0x0001);             // bit0=1 clears new_lvl_flag
}

uint16_t MicCore::get_volume() {
   return read_level();
}
