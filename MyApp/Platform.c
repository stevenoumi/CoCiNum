#include "Platform.h"

// Le contrôleur d'interruptions.
InterruptController *const intc = (InterruptController*)0x81000000;

// L'interface série asynchrone (UART).
static UART uart_priv = {
    // L'adresse de base des registres de l'UART.
    .address     = 0x82000000,
    // Le masque des événements en réception.
    .rx_evt_mask = EVT_MASK(0),
    // Le masque des événements en émission.
    .tx_evt_mask = EVT_MASK(1),
    // Le contrôleur d'interruption qui gère les événements de l'UART
    .intc        = intc
};

UART *const uart = &uart_priv;

// Le timer à usage général.
static Timer timer_priv = {
    // L'adresse de base des registres du timer.
    .address  = 0x83000000,
    // Le masque des événements périodiques.
    .evt_mask = EVT_MASK(2),
    // Le contrôleur d'interruption qui gère les événements du timer
    .intc     = intc
};

Timer *const timer = &timer_priv;

static I2CMaster i2c_priv = {
    // L'adresse de base des registres du contrôleur I2C.
    .address  = 0x86000000,
    // Le masque des événements de fin de trame.
    .evt_mask = EVT_MASK(4),
    // Le contrôleur d'interruption qui gère les événements du contrôleur I2C.
    .intc     = intc
};

I2CMaster *const i2c = &i2c_priv;

static I2CDevice tmp_priv = {
    // Le contrôleur I2C utilisé pour communiquer avec le capteur de température.
    .i2c           = i2c,
    // L'adresse du capteur de température sur le bus I2C.
    .slave_address = 0x4B
};
I2CDevice *const tmp = &tmp_priv;

static UART sonar_uart_priv = {
    .address     = 0x84000000,
    .rx_evt_mask = EVT_MASK(3),
    .tx_evt_mask = EVT_MASK_OFF, // Pas d'événement en émission sur cette interface.
    .intc        = intc
};

UART *const sonar_uart = &sonar_uart_priv;
static Sonar sonar_priv = {
    .uart = sonar_uart
};

Sonar *const sonar = &sonar_priv;

//JOYSTICK




// Le timer utilisé pour les communications SPI.
static Timer spi_timer_priv = {
    .address  = 0x88000000,
    .evt_mask = EVT_MASK(5),
    .intc     = intc
};

Timer *const spi_timer = &spi_timer_priv;

// Le contrôleur SPI.
static SPIMaster spi_master_priv = {
    // L'adresse de base des registres du contrôleur SPI.
    .address  = 0x89000000,
    // Le masque des événements de fin de trame.
    .evt_mask = EVT_MASK(6),
    // Le contrôleur d'interruption qui gère les événements du contrôleur SPI.
    .intc     = intc
};

SPIMaster *const spi_master = &spi_master_priv;


static SPIDevice jstk_priv = {
    // Le contrôleur SPI utilisé pour communiquer avec le joystick.
    .spi            = spi_master,
    // Le timer utilisé pour mesurer les temps d'attente.
    .timer          = spi_timer,
    // La polarité de l'horloge SPI.
    .polarity       = 0,
    // La phase de l'horloge SPI.
    .phase          = 0,
    // La vitesse de communication, en périodes d'horloge par bit.
    .cycles_per_bit = CLK_FREQUENCY_HZ / 1000000, // 1 Mbit/sec
    // Le temps d'attente, en périodes d'horloge.
    .cycles_per_gap = CLK_FREQUENCY_HZ / 25000    // 40us (> 25 us)
};

SPIDevice *const jstk = &jstk_priv;
