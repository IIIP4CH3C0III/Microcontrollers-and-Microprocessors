/*---------------------------------------------------------------------------------------------------------
; 
; File    : delayEquationSolver.c 
; 
; Created : 03-09-2023
; Author  : Fábio Pacheco
;
; Descrip : Being able to calcalute the X, Y and Z needed for the delays
;
---------------------------------------------------------------------------------------------------------*/


#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <math.h>

#define NUMBER_OF_INSTRUCTIONS 20

#define DELAY                  0
#define TIMER                  1


int
main( int argc , char * argv[] ) {
  if ( argc <= 1 ) {
    printf("You have to provide the time you want, in order to have x, y and z.\n");
    printf("./delayEQ -t 0.50 -f 16 \n");
    exit(-1);
  }	

  unsigned int frequency, 
               precision,
               mode; 

  double time, 
         precisionUP   = 1.0 ,   
         precisionDOWN = 0.9 ,
         addPreUP      = 0.1 ,
         addPreDN      = 0.09;
   
  for( int i = 0 ; i < argc ; i++ ) {
  	if ( strcmp( argv[i], "-t" ) == 0 )
  	  time = atof( argv[i+1] );
 	if ( strcmp( argv[i], "-f" ) == 0 )
  	  frequency = atoi( argv[i+1] );
 	if ( strcmp( argv[i], "-p" ) == 0 )
  	  precision = atoi( argv[i+1] );
 	if ( strcmp( argv[i], "-m" ) == 0 )
  	  mode = atoi( argv[i+1] );

  }
 
  if ( time == 0 ) { 
    printf("Either the format is wrong, or the argument of time was 0, try again.\n");
    printf("./delayEQ -t 0.50 -f 16 \n");
    exit(-1);
  }

  for ( int i = 0 ; i < (int)precision ; i++ ) {
    precisionDOWN += addPreDN ;
    precisionUP   = 1 + addPreUP ;
    addPreDN *= 0.1;
    addPreUP *= 0.1;
  }
 
  double delay , target ;

  if ( mode == DELAY )
    for ( int z = 0 ; z < 255 ; z++ ) 
      for ( int y = 0 ; y < 255 ; y++ )
  	    for ( int x = 0 ; x < 255 ; x++ ) {
          delay = NUMBER_OF_INSTRUCTIONS + 3 * z * ( 1 + y + x*y )    ;
  		  delay /= ( frequency * pow( 10 , 6 ) )  ; 

          target = time / delay ; 
        
         if ( target > precisionDOWN && target < precisionUP ) {
            printf("Delay values finder, made by Fábio Pacheco.\n");
            printf("Version 1.0, capable of doing 3 loops.\n\n");
        	printf("Found! The values are:\n");
        	printf("\tDream Delay: %.8lf seconds\n",time);
        	printf("\tReal Delay: %.8lf seconds\n",delay);
        	printf("\tDivision: %.4lf\n",target);
        	printf("\tX: %d\n",x);
        	printf("\tY: %d\n",y);
        	printf("\tZ: %d\n\n",z);
        	return 0;
        }
  	  }

  printf("Delay values finder, made by Fábio Pacheco.\n");
  printf("Version 1.0, capable of doing 3 loops.\n\n");
  printf("Not Found! Values exced the max time : %0.4lf s\n\n", delay);
 
}
