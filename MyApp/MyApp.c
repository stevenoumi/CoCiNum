#include "Platform.h"
#include <Utilities/int_to_string.h>
static volatile unsigned tick;

#define LED_ADDRESS 0x80000000
uint16_t led = 0b0000000000000001;
bool mode = true;

__attribute__((interrupt("machine")))
void irq_handler(void) {
    // Appeler le gestionnaire d'interruptions du pilote de l'interface série.
    UART_irq_handler(uart);
    UART_irq_handler(sonar_uart);	
    // Incrémenter le compteur tick à chaque interruption du timer.
    if (Timer_has_events(timer)) {
        Timer_clear_event(timer);
        tick ++;
    }
}

void main(void) {
    // Initialiser le pilote de l'interface série
    // et afficher un message de bienvenue.
	    UART_init(uart);
	    UART_puts(uart, "Thermometer Demo.\n");
	    UART_puts(uart, "Sonar Demo.\n");
	    UART_puts(uart, "Joystick Demo.\n");
	    
	     
    // Configurer le timer pour demander des interruptions dix fois par seconde.
	    Timer_init(timer);
	    Timer_set_limit(timer, CLK_FREQUENCY_HZ / 10);
	    Timer_enable_interrupts(timer);

	//initialisation du sonar
	  
	 
    	// Initialiser le contrôleur I2C et le pilote du capteur de température.   	
    	Thermometer_init(tmp);
   
    // Initialiser le contrôleur SPI et le pilote du joystick.
		     Joystick_init(jstk);
		     JoystickState jstk_state;
	              
			    tick = 0;
	    unsigned tock = 0;
	    
		      jstk_state.red   = 0;
		      jstk_state.green = 0;
		      jstk_state.blue  = 0;

    // Exécuter jusqu'à ce que l'utilisateur presse une touche.
    
    while (!UART_has_data(uart)) {
    
	    char d[INT_TO_STRING_LEN];
	    char p[INT_TO_STRING_LEN];
    
        // Si une ou plusieurs interruptions du timer ont été détectées.
	     uint32_t dist = Sonar_update(sonar);
	     int32_to_string(d, dist );            
   if (tick != tock) {

        // Mettre à jour les données du joystick
                  Joystick_update(jstk, &jstk_state); 
       
       //initialisation repetitive du sonar
        	   Sonar_init(sonar);  
 		   int16_t t = Thermometer_get_temperature(tmp);
 		   int16_t temp = t/16;
 		   		   
 	//convertir les entiers en chaine de caractere
                 int32_to_string(p, temp); 
                 

	// si le joystick est positionné vers le haut , la led s'allume en rouge  

	if(jstk_state.x<200){
		 UART_puts(uart, "la temperature de la salle est : ");
		      UART_puts(uart, p);
		      
		      UART_puts(uart, " °C \n");
		      
		      jstk_state.red   = 255;

		      jstk_state.green = 0;

		      jstk_state.blue  = 0;
		     
   	}

// si le joystick est positionné vers la droite ,     

// la led s'allume en vert et on change l'etat de la barre de led change

 

   	else if(jstk_state.y<200){
		      jstk_state.red   = 0;

		      jstk_state.green = 255;

		      jstk_state.blue  = 0;

			if(mode){
		      led =(led<<1)+1;
   	}

		else{
		
		led =(led<<1);
		
		       if(led==0){

			led = 0b1000000000000000;
			}
		}
	}
// si le joystick est positionné vers la gauche ,     

// la led s'allume en bleu et on change l'etat de la barre de led change      

	else if(jstk_state.y>800){
		jstk_state.red   = 0;
		jstk_state.green = 0;
		jstk_state.blue  = 255;

 	if(mode){
	led = led>>1;
		if(led == 0){

		led = 0b0000000000000001;
		}
	}

	else{
	led = led|(led>>1);
	}
	}
// si le joystick est positionné vers le bas ,  

// la led s'allume en bleu 
   
	else if(jstk_state.x>800){
		UART_puts(uart, "un objet a ete detecte à : ");
		UART_puts(uart, d);
		UART_puts(uart, " cm \n");
		jstk_state.red   = 255;
		jstk_state.green = 255;
		jstk_state.blue  = 255;

	} 
// si le bouton est pressé ,  

// la led s'etteint     
	else if(jstk_state.trigger==1){
		jstk_state.red   = 0;
		jstk_state.green = 0;
		jstk_state.blue  = 0;
	}

// si le joystick est pressé ,      
// on change de mode

	else if(jstk_state.pressed==1){
		led = ~led;
		mode = !mode;
	}
	
// on change l'etat des LED  
	*(uint32_t*)LED_ADDRESS = led ;
	
            Joystick_update(jstk, &jstk_state);               
            tock ++;
	}
            
 // lire les coordonnées du joystick et l'état des boutons.
 
        }
    }


