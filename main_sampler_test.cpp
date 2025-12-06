/*****************************************************************//**
 * @file mic_main.cpp
 *
 * @brief Volume threshold test using Nexys4 DDR microphone + 7‑seg
 *
 * @author Emma
 * @version v1.0
 *********************************************************************/

#include "chu_init.h"
#include "mic_driver.h"
#include "sseg_core.h"
#include "gpio_cores.h"

/**
 * check microphone volume and display HI/LO
 * @param mic_p pointer to microphone instance
 * @param sseg_p pointer to seven‑seg instance
 * @param led_p  pointer to LED instance (optional debug)
 */

/**
 * core instances
 *   - addresses assigned in Vivado Address Editor
 *   - macros resolved by get_slot_addr()
 */
GpoCore led(get_slot_addr(BRIDGE_BASE, S2_LED));
MicCore mic(get_slot_addr(BRIDGE_BASE, S4_USER));   // assume mic mapped to slot 4
SsegCore sseg(get_slot_addr(BRIDGE_BASE, S8_SSEG));

int main() {   // sanity check like Chu’s examples

   mic.write_threshold(1200);
   sseg.set_dp(0);
   for(int i = 2; i < 8; i++){
      sseg.write_1ptn(0xff, i);
   }
   while (1) { 
      uint16_t status = mic.read_status();  // blink pattern to indicate mic test
      if (status & 0x2) {            // new level flag
         uint16_t level = mic.read_level();
         mic.clear_flag();
         uart.disp(level);
         if (level >= 1) {
            sseg.write_1ptn(0x79, 0);
            sseg.write_1ptn(0x09, 1);
            led.write(0xFFFF);
         } else {
            sseg.write_1ptn(0x40, 0);
            sseg.write_1ptn(0x47, 1);
            led.write(0x0000);
         }
      }
      sleep_ms(10);
   }
}
