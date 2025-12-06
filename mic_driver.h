/*****************************************************************//**
 * @file mic_driver.h
 *
 * @brief Microphone driver class (Chu-style)
 *
 * @author Emma
 * @version v1.0
 *********************************************************************/

#ifndef _MIC_DRIVER_H_INCLUDED
#define _MIC_DRIVER_H_INCLUDED

#include "chu_init.h"

/**
 * Microphone core driver
 *  - Reads PCM samples from PDM decimator IP
 *  - Provides simple volume level calculation
 */
class MicCore {
public:
   enum {
      REG_STATUS = 0,  // [bit0=above_thresh, bit1=new_lvl_flag]
      REG_LEVEL  = 1,  // 16-bit peak level
      REG_THRESH = 2,  // R/W threshold
      REG_CTRL   = 3   // WO: bit0=clear new_lvl_flag
   };

   MicCore(uint32_t core_base_addr);
   ~MicCore();

   uint16_t read_level();        // peak level from detector
   uint16_t read_status();       // status bits
   void     write_threshold(uint16_t th);
   void     clear_flag();        // write CTRL bit0=1
   uint16_t get_volume();        // alias to read_level()
private:
   uint32_t base_addr;
};

#endif //_MIC_DRIVER_H_INCLUDED