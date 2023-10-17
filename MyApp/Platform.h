#ifndef PLATFORM_H_
#define PLATFORM_H_
#include <UART/Sonar.h>
#include <InterruptController/InterruptController.h>
#include <UART/UART.h>
#include <Timer/Timer.h>
#include <I2C/I2C.h>
#include <I2C/Thermometer.h>
#include <SPI/SPI.h>
#include <SPI/Joystick.h>
#define CLK_FREQUENCY_HZ     100000000

extern SPIDevice 		*const jstk;
extern Timer    	 	*const spi_timer;
extern SPIMaster 		*const spi_master;
extern InterruptController 	*const intc;
extern UART                	*const uart;
extern Timer               	*const timer;
extern I2CMaster 		*const i2c;
extern I2CDevice 		*const tmp;
extern UART 			*const sonar_uart;
extern Sonar 			*const sonar;
#endif
