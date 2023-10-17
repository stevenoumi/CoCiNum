
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.Virgule_pkg.all;
use work.Computer_pkg.all;

entity Computer is
    port(
    
        clk_i        : in  std_logic;
        btn_center_i : in  std_logic;
        uart_rx_i    : in  std_logic;
        uart_tx_o    : out std_logic;
        switches_i   : in  std_logic_vector(15 downto 0);
        leds_o       : out std_logic_vector(15 downto 0);
       
       --ports de notre projet
       
       pmod_a1       : in std_logic;
       pmod_a2       : in std_logic;
       pmod_a3       : in std_logic;
       pmod_a4       : in std_logic;

        --accelerometre
       pmod_b3       : inout std_logic;
       pmod_b4       : inout std_logic;
       scl_io        : inout std_logic;
       sda_io        : inout std_logic;
       
       --JOYSTICK
       pmod_c1       : out std_logic;
       pmod_c2       : out std_logic;
       pmod_c3       : in  std_logic;
       pmod_c4       : out std_logic
      

    );
end Computer;

architecture Structural of Computer is
    signal sync_reset    : std_logic;
    signal sync_uart_rx  : std_logic;

    signal core_valid    : std_logic;
    signal core_ready    : std_logic;
    signal core_address  : word_t;
    signal core_rdata    : word_t;
    signal core_wdata    : word_t;
    signal core_write    : std_logic_vector(3 downto 0);
    signal core_irq      : std_logic;

    alias dev_address    : byte_t is core_address(31 downto 24);

    signal mem_valid     : std_logic;
    signal mem_ready     : std_logic;
    signal mem_rdata     : word_t;

    signal io_valid      : std_logic;
    signal io_ready      : std_logic;
    signal io_rdata      : word_t;
    
    signal uart_rdata    : word_t;
    signal uart_ready    : std_logic;
    signal uart_valid    : std_logic;
    signal uart_rx_evt   : std_logic;
    signal uart_tx_evt   : std_logic;
    
    signal intc_valid    : std_logic;
    signal intc_events   : word_t;
    signal intc_rdata    : word_t;
    signal intc_ready    : std_logic;
    
    signal timer_valid   : std_logic;
    signal timer_evt     : std_logic;
    signal timer_rdata   : word_t;
    signal timer_ready   : std_logic;
    
    --projet sonar
    signal sync_sonar_rx       : std_logic;
    signal sonar_uart_rdata    : word_t;
    signal sonar_uart_ready    : std_logic;
    signal sonar_uart_valid    : std_logic;
    signal sonar_uart_rx_evt   : std_logic;
    signal sonar_uart_tx_evt   : std_logic;
    
    --temperature accelerometre
    signal I2CMaster_valid   : std_logic;
    signal I2CMaster_evt     : std_logic;
    signal I2CMaster_rdata   : word_t;
    signal I2CMaster_ready   : std_logic;
    
    --Joystick
    
    signal sync_spi_miso : std_logic;
    signal spim_valid    : std_logic;
    signal spim_ready    : std_logic;
    signal spim_rdata    : word_t;
    signal spim_events   : std_logic;
    signal spit_rdata    : word_t;
    signal spit_ready    : std_logic;
    signal spit_valid    : std_logic;
    signal spit_events   : std_logic;


begin
    -- Concurrent statements
    core_inst : entity work.Virgule(rtl)
        port map(
        
            clk_i       =>  clk_i,
            reset_i     =>  sync_reset,
            irq_i       =>  core_irq,
            rdata_i     =>  core_rdata,
            wdata_o     =>  core_wdata,
            write_o     =>  core_write,
            address_o   =>  core_address,
            ready_i     =>  core_ready,
            valid_o     =>  core_valid
            
            );
            
            --mem_inst entité
            
     mem_inst   : entity work.VMemory(Behavioral)
        generic map(
                CONTENT => MEM_CONTENT
         )
        port map(
        
            clk_i       =>  clk_i,
            reset_i     =>  sync_reset,
            rdata_o     =>  mem_rdata,
            wdata_i     =>  core_wdata,
            write_i     =>  core_write,
            address_i   =>  core_address(31 downto 2),
            ready_o     =>  mem_ready,
            valid_i     =>  mem_valid
            
            );
            -- sync_inst entity
            
     sync_inst      : entity work.InputSynchronizer(Behavioral)
        generic map(
                WIDTH => 20
         )
        port map(
        
            clk_i                =>  clk_i,
            data_i(0)            =>  btn_center_i,
            data_i(16 downto 1)  =>  switches_i,
            data_i(17)           =>  uart_rx_i,
            data_i(18)           =>   pmod_a3, --projet
            data_i(19)           =>   pmod_c3, 
            data_o(16 downto 1)  => io_rdata(15 downto 0),
            data_o(0)            =>  sync_reset,
            data_o(17)           =>  sync_uart_rx,      
            data_o(18)           => sync_sonar_rx,  --projet
            data_o(19)           => sync_spi_miso
         );
            
                     
     uart_inst      : entity work.UART(Structural)
        generic map(
             CLK_FREQUENCY_HZ  => CLK_FREQUENCY_HZ ,
             BIT_RATE_HZ       => UART_BIT_RATE_HZ  
         )
        port map(
        
            clk_i       =>  clk_i,
            reset_i     =>  sync_reset,
            wdata_i     => core_wdata(7 downto 0),
            write_i     => core_write(0),
            valid_i     => uart_valid,
            rx_i        => sync_uart_rx,
            rdata_o     => uart_rdata(7 downto 0),
            ready_o     => uart_ready,
            rx_evt_o    => uart_rx_evt,
            tx_evt_o    => uart_tx_evt,
            tx_o        => uart_tx_o

            );
            
     intc_inst : entity work.VInterruptController(Behavioral)
        port map(
        
            clk_i       =>  clk_i,
            reset_i     =>  sync_reset,
            wdata_i     =>  core_wdata,
            write_i     =>  core_write,
            address_i   =>  core_address(2),
            valid_i     =>  intc_valid,
            events_i    =>  intc_events,
            irq_o       =>  core_irq,
            rdata_o     =>  intc_rdata,
            ready_o     =>  intc_ready

            );
            
    timer_inst : entity work.Timer(Behavioral)
        port map(
        
            clk_i       =>  clk_i,
            reset_i     =>  sync_reset,
            wdata_i     =>  core_wdata,
            write_i     =>  core_write,
            address_i   =>  core_address(2),
            valid_i     =>  timer_valid,
            evt_o       =>  timer_evt,
            rdata_o     =>  timer_rdata,
            ready_o     =>  timer_ready

            );
            
            --architecture de notre projet : second UART
      sonar_uart_inst      : entity work.UART(Structural)
        generic map(
             CLK_FREQUENCY_HZ  => CLK_FREQUENCY_HZ ,
             BIT_RATE_HZ       => SONAR_UART_BIT_RATE_HZ  
         )
        port map(
        
            clk_i       =>  clk_i,
            reset_i     => sync_reset,
            wdata_i     => core_wdata(7 downto 0),
            write_i     => core_write(0),
            valid_i     => sonar_uart_valid,
            rx_i        => sync_sonar_rx,
            rdata_o     => sonar_uart_rdata(7 downto 0),
            ready_o     => sonar_uart_ready,
            rx_evt_o    => sonar_uart_rx_evt,
            tx_evt_o    => sonar_uart_tx_evt
           
            );
            
            --architecture temperature
    I2CMaster_inst : entity work.I2CMaster(rtl)
        port map(
        
            clk_i       =>  clk_i,
            reset_i     =>  sync_reset,
            wdata_i     =>  core_wdata,
            write_i     =>  core_write,
            address_i   =>  core_address(2),
            valid_i     =>  I2CMaster_valid,
            evt_o       =>  I2CMaster_evt,
            rdata_o     =>  I2CMaster_rdata, 
            ready_o     =>  I2CMaster_ready,
            scl_io      =>  pmod_b3,
            sda_io      =>  pmod_b4
            );
            
        -- SPI_MASTER
     spim_inst : entity work.SPIMaster(rtl)
        port map(
            clk_i => clk_i,
            reset_i => sync_reset,
            valid_i => spim_valid,
            ready_o => spim_ready,
            address_i => core_address(3 downto 2),
            write_i => core_write(0),
            wdata_i => core_wdata(7 downto 0),
            rdata_o => spim_rdata(7 downto 0),
            evt_o => spim_events,
            miso_i => pmod_c3,
            mosi_o => pmod_c2,
            sclk_o => pmod_c4,
            cs_n_o => pmod_c1
        );
        
        --SPI_TIMER
        
    spit_inst : entity work.Timer(Behavioral)
        port map(
            clk_i => clk_i,
            reset_i => sync_reset,
            rdata_o => spit_rdata,
            wdata_i => core_wdata,
            write_i => core_write,
            address_i => core_address(2),
            ready_o => spit_ready,
            valid_i => spit_valid,
            evt_o => spit_events
        );
          -- GESTION DES DONNEES DE L'UART
        intc_events(INTC_EVENTS_UART_TX)  <= uart_tx_evt;
        intc_events(INTC_EVENTS_UART_RX)  <= uart_rx_evt;
        intc_events(INTC_EVENTS_TIMER)    <= timer_evt;
         --projet
        intc_events(INTC_EVENTS_SONAR_UART)  <= sonar_uart_rx_evt;
        --I2C
        intc_events(INTC_EVENTS_I2C) <= I2CMaster_evt;
        --JOYSTICK
        intc_events(INTC_EVENTS_SPI_MASTER) <= spim_events;
        intc_events(INTC_EVENTS_SPI_TIMER) <= spit_events; 
                
           --GESTIONN DES transferttvde donnees
    mem_valid    <= core_valid when dev_address = MEM_ADDRESS   else '0';
    io_valid     <= core_valid when dev_address = IO_ADDRESS    else '0';
    uart_valid   <= core_valid when dev_address = UART_ADDRESS  else '0';
    intc_valid   <= core_valid when dev_address = INTC_ADDRESS  else '0';
    timer_valid  <= core_valid when dev_address = TIMER_ADDRESS else '0'; --projet
    sonar_uart_valid <= core_valid when dev_address = SONAR_UART_ADDRESS else '0';
    --I2C
    I2CMaster_valid <= core_valid when dev_address = I2C_ADDRESS else '0';
    -- JOYSTICK
    spim_valid <= core_valid when dev_address = SPI_MASTER_ADDRESS else '0';
    spit_valid <= core_valid when dev_address = SPI_TIMER_ADDRESS else '0';
    
          --GESTION DES BUS DE DONNEES DANS LA MEMOIRE
       with dev_address select 
        core_rdata <= mem_rdata   when  MEM_ADDRESS ,
                      io_rdata    when  IO_ADDRESS,
                      intc_rdata  when  INTC_ADDRESS,
                      uart_rdata  when  UART_ADDRESS,
                sonar_uart_rdata  when  SONAR_UART_ADDRESS,--projet
                      timer_rdata when  TIMER_ADDRESS,
                  I2CMaster_rdata when  I2C_ADDRESS ,          
                       spim_rdata when SPI_MASTER_ADDRESS,
                       spit_rdata when SPI_TIMER_ADDRESS,
                      X"00000000"    when  others;
            
            --processus des leds 7 à 0
          
        p_leds_seven_zero  : process(clk_i, sync_reset)
            begin
                if(sync_reset = '1') then 
                
                    leds_o(7 downto 0) <= x"00";
                    
                elsif(rising_edge(clk_i)) then
                
                    if(io_valid = '1'and core_write(0) ='1') then
                    
                       leds_o(7 downto 0) <= core_wdata(7 downto 0) ;
                       
                     end if;
                end if;
         end process p_leds_seven_zero;
          
          -- processu des leds 15 à 8  
         p_leds_next   : process(clk_i, sync_reset)
            begin
                if(sync_reset = '1') then 
                
                    leds_o(15 downto 8) <= x"00";
                    
                elsif(rising_edge(clk_i)) then
                
                    if(io_valid = '1'and core_write(1) ='1') then
                    
                       leds_o(15 downto 8) <= core_wdata(15 downto 8) ;
                       
                     end if;
                end if;
         end process p_leds_next;
         
         io_rdata(31 downto 16)   <= x"0000";
         uart_rdata(31 downto 8)  <= x"000000";
        -- sonar_uart_rdata(31 downto 8) <= x"000000";
        --I2CMaster_rdata(31 downto 8) <= x"000000";
         core_ready <= mem_ready   when dev_address      = MEM_ADDRESS else 
                        uart_ready when dev_address     = UART_ADDRESS else 
                        intc_ready when dev_address     = INTC_ADDRESS else 
                       timer_ready when dev_address    = TIMER_ADDRESS else 
                  sonar_uart_ready when dev_address    = SONAR_UART_ADDRESS else --projet   
                   I2CMaster_ready when dev_address    = I2C_ADDRESS else 
                        spim_ready when dev_address = SPI_MASTER_ADDRESS else
                        spit_ready when dev_address = SPI_TIMER_ADDRESS else    
                        core_valid;
         
      

end Structural;
