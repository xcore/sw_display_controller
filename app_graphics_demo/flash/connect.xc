#include <xs1.h>
#include <platform.h>
#include <flashlib.h>

fl_PortHolderStruct ports = {
  XS1_PORT_1A,  /* MISO */
  XS1_PORT_1B,  /* SS */
  XS1_PORT_1C,  /* CLK */
  XS1_PORT_1D,  /* MOSI */
  XS1_CLKBLK_2
};

fl_DeviceSpec spec[1] = {
  {
#include "MX25L6445E.spec"
  }
};

int flash_connect() {
  int res;
  res = fl_connectToDevice(ports, spec, 1);
  if( res != 0 ) {
    return(0);
  }
  return 1;
}
