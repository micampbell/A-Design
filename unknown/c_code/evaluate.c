#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <time.h>
#include "headers1214.h"

int outmassnum;
int evallevel=-2, atoggle;
long t0, t1;
double kyfactor=1;
int errorcount=0;
int warningcount=0;
int stiffdirect=0; 
/*1 when going from r port, -1 when going from l, 0 otherwise */
char errormessage[300];
int debug=0;
int userlevelinput=0;
/* 0 when A-design is calling this, 1 wen it isn't */

int main() {
  double f[4];
  int pc, iter, retint;
  struct tm *ptr;
  time_t lt;
  long deltat;
  double dt;

  printf("\n");
  lt= time(NULL);
  ptr= localtime(&lt);
  printf(asctime(ptr));
  printf("\n");

  userlevelinput=1;
  printf("Enter an integer value for level.\n");
  printf(" -2: Automatic determination -1: Analytical 0:  DC  1: 100 pt AC  >1:  # of points \n");
  scanf("%d", &evallevel);

  if(debug!=0){
    printf("\nevallevel: %d\n", evallevel);
  }

  atoggle=0;
  if(evallevel>1){
    printf("Enter a value for atoggle (0=off 1=on).\n");
    scanf("%d", &atoggle);
  }

  /*
  printf("Enter an integer value for pc (0-10).\n");
  scanf("%d", &pc);

  printf("Enter an integer value for iter (0-100).\n");
  scanf("%d", &iter);
  */
  pc=0; 
  iter=0;
  retint=return_objs(pc, iter, f);

  t1=clock();
  deltat=t1-t0;
  dt=deltat/(1e6);

  printf("\nCPU time: %g sec.\n", dt);

  printf("Done.");
  return retint;
}


int return_objs (int pc, int iter, double *f) {
  char filename[25], netfile[25];
  FILE *netlist;
  int level, i, G_O_check;


  /* Set Global Values */
  if(userlevelinput!=1){
    evallevel=-2;
  }

  kyfactor=1;
  stiffdirect=0;
  errorcount=0;
  warningcount=0;
  /******************/

  if(errorcount>0){
    printf("return_objs Error detected \n");
    return 0;
  }

  for(i=0;i<4;i++){
    f[i]=defaultobjval;
  }

  strcpy(filename, "config");

  netlist=NULL;


  while(netlist==NULL) {
    strcpy(netfile, filename);
    strcat(netfile, ".sin");
    netlist=fopen(netfile, "r");

    if (!netlist){
      fprintf(stderr, "File '%s' not found.", netfile);
      printf(" Please enter filename\n");
      scanf("%s", filename);
      strcpy(netfile, filename);
      strcat(netfile, ".sin"); 
      netlist=fopen(netfile, "r");
    }
  }

  t0=clock();

  if(debug!=0){
  printf("return_objs: Opened %s.\n\n\n\n", netfile);
  }

  fclose(netlist);


  level=Find_Level(pc, iter);
  if(level==-2){
    errorcount++;
    return 0;
  }

  if(debug!=0){
    printf("\nevallevel: %d\n", evallevel);
  }
  /****/
  if(evallevel>-2){
    level=evallevel;
  }

  /*****/

  if(debug!=0){
    printf("LEVEL: %d\n\n", level);
  }

  G_O_check=Get_Objs(filename, f, level);

  if(G_O_check==0){
    return 0;
  }

  return 1;
}


int Find_Level(pc, iter){

  /*This function takes the pareto change and iteration numbers as inputs and returns the integer corresponding to the appropriate level of analysis.  -2 is returned if there is an error. */

  /*pc (pareto change) ranges from 0-10 */
  /* iter (iteration #) ranges from 0-100 */

  /* -1: Analytical (no simulation)
      0: DC operating point
      1: Full scale sine sweep
    n>1: Sine sweep with n evaluation points 
  */

 
  int retlev=0;
  int check=0;
  int leva=20, levb=30;
  int levc=45, levd=55;
  int leve=70, levf=80;
  int levg, levh;
  int aeval=-1, beval=0, ceval=10, deval=30;
  int fs=1;

  if(errorcount>0){
    printf("Error detected, Find_Level.\n");
    return -2;
  }
  if(debug!=0){
    printf("iter: %d   pc: %d\n", iter, pc);
  }

  while(check==0){
    if(iter<=leva){
      retlev=aeval;
      check=1; break;
    }

    if((iter>leva)&&(iter<levb)){
      if(pc>5){
	retlev=aeval;
	check=1; break;
      }
      else{
	retlev=beval;
	check=1; break;
      }
    }
    
    if((iter>=levb)&&(iter<=levc)){
      retlev=beval;
      check=1; break;
    }
    
    if((iter>levc)&&(iter<levd)){
      if(pc>5){
	retlev=beval;
	check=1; break;
      }
      else{
	retlev=ceval;
	check=1; break;
      }
    }
    
    if((iter>=levd)&&(iter<=leve)){
      retlev=ceval;
      check=1; break;
    }
    
    if((iter>leve)&&(iter<levf)){
      if(pc>5){
	retlev=ceval;
	check=1; break;
      }
      else{
	retlev=deval;
	check=1; break;
      }
    }
    
    if(iter>=leve){
      retlev=deval;
      check=1; break;
    }
    
    if(check!=1){
      fprintf(stderr,"Error in Find_Level.\n\n");
      strcat(errormessage, " Error in Find_Level. ");
      errorcount++;
      return -2;
      /* exit(0); */
    }
    
  }
    /*
    printf("retlev= %d\n", retlev);
    printf("Enter an integer value for level.\n");
    printf(" 0:  DC  1: 100 pt AC  >1:  # of points \n");
    scanf("%d", &retlev);
    */

  return retlev;
}


  /*
combdrive_y.combdrive_y_1_ v_s:_n1 v_r:_n2 phi_r:_n61 phi_s:_n60 x_r:_n21 y_r:_n41 y_s:_n40 x_s:_n20 Xr:_n81 PHIr:_n121 Yr:_n101 Ys:0 Xs:0 PHIs:_n120 =gap= 2u, rotor_fingers= 30, finger_length= 10u, finger_width= 2u, overlap= 5u
  */




int Get_Objs(char* filename, double *f, int n){
  FILE *outfileptr;
  char outfile[25];
  char xout[10], yout[10], phiout[10], vout[10];
  char textline[256];
  int linelength=100, fnret;
  char cond_val[5], units1_val;
  char *cond;
  double xoutval, youtval, phioutval;
  int lincount=0;
  char *units1;
  double xforcesum=0, yforcesum=0, xforce, yforce;
  char combstr[25], fxcombstr[10], fycombstr[10];
  char fysourcestr[10];
  double Kxx, Kyy, Kxy;
  double mass, area, kxcalc, kycalc;
  double omegay, sens, omegaycalc, freqycalc;
  double freqAC, freqDC, deltax, invdeltay, deltaphi;
  double obj_vals[3];
  double calc_obj_vals[4], *c_o_v_ptr;
  
  cond= cond_val;
  units1=&units1_val;
  
  if(debug!=0){
    printf("In Get_Objs\n\n");
    printf("LEVEL: %d\n", n);
  }

  c_o_v_ptr=calc_obj_vals;
  mass=defaultobjval;

  fnret=Calc_Objs(filename, c_o_v_ptr);

  if(fnret==0){
    printf("Error detected in return from Calc_Objs.\n");
    return 0;
  }

  kxcalc=calc_obj_vals[0];
  kycalc=calc_obj_vals[1];
  area=calc_obj_vals[2];
  mass=calc_obj_vals[3];

  if(debug!=0){
    printf("\n\nkycalc: %g N/m", kycalc*kyfactor);
    printf("  mass: %g kg\n\n", mass*mass_f_factor);
  }

  omegaycalc=pow(((kycalc*kyfactor)/(mass*mass_f_factor)), 0.5);
  freqycalc=(omegaycalc/(2*pi));

/*   printf("\nCalculated Frequency: %g Hz\n", freqycalc); */

  /* mass units is kg */
  if(debug!=0){
    printf("\n\nMASS: %g kg\n\n", mass); 
    printf("\n\nAREA: %g kg\n\n", area); 
  }

  if(n<0){
    f[0]=kxcalc;
    f[1]=kycalc;
    f[2]=area*(17.9/2);
    f[3]=mass; 

/*     printf("f[0](Kxx)=%g  ", f[0]); */
/*     printf("f[1](Kyy)=%g  ", f[1]); */
/*     printf("f[2](Damping)=%g", f[2]); */
/*     printf("f[3](Mass)=%g\n\n", f[3]); */
  }


  strcpy(vout, "_n3103");  

  if((n==0)||(n>1 && atoggle==0)){

    if(n!=1){
      printf("Running SABER DC\n");
      Run_SABER_DC(filename, n);
    }

    strcpy(outfile, filename);
    strcat(outfile, ".out");
    if(debug!=0){
      printf("Get_Objs: Opening %s\n", outfile);
    }
    outfileptr=NULL;
    outfileptr=fopen(outfile, "r");
    
    if(!outfileptr) {
      fprintf(stderr,"unable to open file %s \n", outfile);
      return 0;
      /*exit(0);*/
    }
    
    cond=NULL;
    cond=fgets(textline, linelength, outfileptr);
    
    lincount++;
    
    
    f[0]=defaultobjval;
    f[1]=defaultobjval;  
    f[2]=defaultobjval;
    
    deltax=defaultobjval;
    invdeltay=defaultobjval;
    deltaphi=defaultobjval;
    
    while(cond){
      
      strcpy(xout, "_n3100");
      if(strstr(textline,xout)!=0){
	/******/
	puts(textline);
	/******/
	xoutval=Find_List_Value(textline, xout, units1);
	if(debug!=0){
	  printf("\n\n\nxout value= %g %c\n\n\n", xoutval, units1_val);
	}
	xoutval=Set_Double(xoutval, units1);
	deltax=fabs(xoutval);
      }
      
      
      
      strcpy(yout, "_n3101");
      if(strstr(textline,yout)!=0){
	/******/
	puts(textline);
	/******/
	youtval=Find_List_Value(textline, yout, units1);
	if(debug!=0){
	  printf("\nyout value= %.2lf%c\n", youtval, *units1);
	}
	youtval=Set_Double(youtval, units1);
	if(youtval!=0){
	  invdeltay=fabs(1/(youtval));
	}
      }
      
      
      strcpy(phiout, "_n3102");
      if(strstr(textline,phiout)!=0){
	/******/
	if(debug!=0){
	  puts(textline);
	}
	/******/
	phioutval=Find_List_Value(textline, phiout, units1);
	if(debug!=0){
	  printf("\nphiout value= %.2lf%c\n", phioutval, *units1);
	}
	phioutval=Set_Double(phioutval, units1);
	deltaphi=fabs(phioutval);
      }
      strcpy(combstr, "combdrive");
      strcpy(fxcombstr, "fxd");
      strcpy(fycombstr, "fyd");
      
      if(strstr(textline, combstr)!=0 &&
	 strstr(textline, fxcombstr)!=0){
	if(debug!=0){
	  puts(textline);
	}
	xforce=Find_List_Value(textline, fxcombstr, units1);
	if(debug!=0){
	  printf("\nfxd value= %g%c\n", xforce, *units1);
	}
	xforce=Set_Double(xforce, units1);
	xforcesum=xforcesum+xforce;
      }
      
      if(strstr(textline, combstr)!=0 &&
	 strstr(textline, fycombstr)!=0){
	if(debug!=0){
	  puts(textline);
	}
	yforce=Find_List_Value(textline, fycombstr, units1);
	if(debug!=0){
	  printf("\nfyd value= %g%c\n", yforce, *units1);
	}

	yforce=Set_Double(yforce, units1);
	yforcesum=yforcesum+yforce;
      }
      
      strcpy(fysourcestr, "force(force.");
      /*Case where force source replaces combdrive in netlist */
      
      
      if(strstr(textline, combstr)==0 &&
	 strstr(textline, fysourcestr)!=0){
	if(debug!=0){
	  puts(textline);
	}
	yforce=Find_List_Value(textline, fysourcestr, units1);

	if(debug!=0){
	  printf("\nfysource value= %g%c\n", yforce, *units1);
	}

	yforce=Set_Double(yforce, units1);
	yforcesum=yforcesum+yforce;
      }
      
      
      cond=fgets(textline, linelength, outfileptr);
      lincount++;
    }
    
    fclose(outfileptr);
    
    Kxx=defaultobjval;
    Kxy=defaultobjval;
    Kyy=defaultobjval;
    
    if(deltax!=defaultobjval && invdeltay!=defaultobjval){
      if(debug!=0){
	printf("xoutval=%g\n", xoutval);
	printf("youtval=%g\n", youtval);
      }

      if(fabs(xoutval)>mindisp){
	/*printf("xoutval is greater than mindisp.\n");*/
	Kxx=(xforcesum/xoutval);
	Kxy=(yforcesum/xoutval);
      }
      
      if(fabs(youtval)>mindisp){
	/*printf("youtval is greater than mindisp.\n");*/
	Kyy=(yforcesum/youtval);
      }
      
      if(n==0){
	f[0]=Kxx;	
	f[1]=Kyy;
	f[3]=(mass_f_factor)*mass;      
	f[2]=(f[3]/areadensity)*(17.9/2);

	printf("f[0](Kxx)=%g  ", f[0]);
	printf("f[1](Kyy)=%g  ", f[1]);
	printf("f[2](Damping)=%g", f[2]);
	printf("f[3](Mass)=%g\n\n", f[3]);
      }
    }
    
    if(debug!=0){
      printf("\n\n");
      printf("Kxx= %g  ", Kxx);
      printf("Kyy= %g  ", Kyy);
      printf("\n\n");
    }

    if(n>=0){

      if((mass!=defaultobjval) && (Kyy!=defaultobjval)){
	if(debug!=0){
	  printf("\n\nMASS: %g kg\n\n", mass);
	} 
	omegay=pow((Kyy/(mass*mass_f_factor)), 0.5);
	freqDC=omegay/(2*pi);
	printf("\nresonant frequency (DC) = %g Hz\n\n", freqDC);    
	sens=pow(omegay,-2);
	if(debug!=0){
	  printf("\n(1/omega)^2 = %g e-12\n\n", sens*1.e12);
	}
      }

      if(mass==defaultobjval){
	fprintf(stderr,"Mass is not read\n\n");
      }

      if(Kyy==defaultobjval){
	fprintf(stderr,"Kyy is not read\n\n");
      }
    }
  }

  if(atoggle==1){
    Kxx=kxcalc;
    Kyy=kycalc;
  }

  /**  AC  Analysis ***/
  freqAC=defaultobjval;

  if(n>0){
    printf("Running SABER AC\n");

    if(atoggle==0){
      Run_SABER_AC(filename, freqDC, n);
    }
    else{
      Run_SABER_AC(filename, freqycalc, n);
    }
    printf("Finished SABER\n");
    freqAC=InterpretAC(filename);

    if(errorcount>1 || freqAC==0){
      return 0;
    }

    if(freqAC!=defaultobjval){
      printf("frequency (AC analysis): %g Hz\n\n", freqAC);

      f[0]=Kxx;
      f[1]=Kyy;
      /* Mass */
      f[3]=Kyy/(pow((freqAC*2*pi),2));
      /* Damping */
      /* (Mass/ Area_density) * (mu/ delta) */
      f[2]=(f[3]/areadensity)*(17.9/2);
	
      printf("f[0](Kxx)=%g  ", f[0]);
      printf("f[1](Kyy)=%g  ", f[1]);
      printf("f[2](Damping)=%g", f[2]);
      printf("f[3](Mass)=%g\n\n", f[3]);
    }
  }
  /*********/
}
/* End of Get_Objs*/

void Run_SABER_DC(char* filename, int n){
  FILE *script;
  char scriptfile[25];
  char command[50];
  
  strcpy(scriptfile, filename);
  strcat(scriptfile, ".scs");
  
 
  strcpy(command, "saber -b ");
  strcat(command, filename);
  

  /******************/
  script=fopen(scriptfile, "w");
  /*printf("File %s opened.\n", scriptfile);*/
  
  fprintf(script, "dc ");
  
  fprintf(script, "(siglist /...");
  fprintf(script, "\n\n");
  fprintf(script, "di dc (siglist /...\n\n");
  fclose(script);
  /******************/
  
  system(command);
  
}

void Run_SABER_AC(char* filename, double freqDC, int n){
  FILE *script;
  char scriptfile[25];
  char command[50], cdir;
  char combstr[50];

  strcpy(scriptfile, filename);
  strcat(scriptfile, ".scs");

  strcpy(command, "saber -b ");
  strcat(command, filename);

  /******************/
  script=fopen(scriptfile, "w");
  /*printf("File %s opened.\n", scriptfile);*/

  /*
  fprintf(script, "dc ");
  fprintf(script, "(siglist /...");
  fprintf(script, "\n\n");
  fprintf(script, "di dc (siglist /...\n\n");
  */

  fprintf(script, "dc\n");

  if(n==1){
    fprintf(script, "ac (fbegin 1k,fend 1meg \n");
  }

  else{
    fprintf(script, "ac (fbegin %.0lf, fend %.0lf, npoints %d \n", 
	    freqDC/10, freqDC*10, n);
  }

  fprintf(script, "meas maximum (cnames plate_mass.plate_mass_%d_/y_mid", outmassnum);
  fprintf(script, ",pfin ac,ytrans db \n");
  fprintf(script, "meas maximum (cnames plate_mass.plate_mass_%d_/x_mid", outmassnum);
  fprintf(script, ",pfin ac,ytrans db \n");



  fprintf(script, "\n");



  fclose(script);
  /******************/

  system(command);
}

/* End of Run_SABER */

double Find_List_Value(char* element, char* refer1, char *units){
  /* Returns value in output file list designated by refer1 and refer2 */
  char digits[30], number[30], entry[30], *charptr, *retptr;
  int a,i,j,k,m, elsize;
  double retdouble;
  char char_val, ret_val;
  charptr= &char_val;
  retptr= &ret_val;
  elsize=strlen(element);
  strcpy(digits, "               ");
  strcpy(number, "00");
  strcpy(entry, "00");


  if(strstr(element, refer1)==0){
    printf("Reference '%s' not found.  Find_List\n", refer1);
    return 0;

  }
  else{
    /*
      printf("Reference '%s' found.  Find_List\n", refer1);*/
    if(debug!=0){
      puts(element);
    }
    charptr=strstr(element,"  ");
    /*
    printf("charptr= ");
    printf(charptr);
    */

    j=0;
    while(*charptr!='\0'){
      entry[j]=*charptr;
      j++;
      charptr++;
    }
    entry[j-1]='\0';



    /*
      printf("\nentry= '%s'\n\n", entry);*/

    i=0;
    while(entry[i]==' '){
      i++;
    }

    j=i;
    for(k=0; k<(elsize-i); k++){
      number[k]=entry[j];
      j++;
    }
    number[k]='\0';
    /*
      printf("number: '%s'\n\n", number);*/

    i=0;
    j=0;
    k=0;
    for(i=0; i<30; i++){
      if(isalpha(number[i])==0){
	/*printf("%d", i);*/
      }
      else {
	j=i;
	/*printf("target %d", i);*/
	break;
      }
      
    }

    *units=number[j];

    number[j]='\0';
    number[j+1]=' ';

    /*printf("\n\nnumber: %s\n\n", number);*/
    retptr=&number[0];
    retdouble=atof(retptr);
    /*printf("retdouble: %lf\n\n", retdouble);*/
    return retdouble;
  }
}

/* End of Find_List_Value */

char Find_Char(char* element, char* refer, char endchar){
  char number[10], *charptr, retchar;
  int a,i,j,k,m,size,elsize,retint=0;
  char char_val;
  charptr= &char_val;

  size=strlen(refer);
  elsize=strlen(element);

  if(strstr(element, refer)==0){
    printf("Reference '%s' not found.  Find_Char\n", refer);
    return ' ';
  }

  else{
    for(i=0; i<elsize; i++){
      a=0;
      for(j=0; j<(size+1); j++){
        if(element[i+j]==refer[j]){
          a++;
          if(a==size){
            retchar=element[i+j+1];
            /*printf("retchar= %c", retchar);*/
            a=0;
            break;
          }
        }
        else{
          a=0;
        }
      }
    }
  }
  return retchar;
}

/* End of Find_Char */



int Find_Int(char* element, char* refer){
  char number[10], *charptr;
  int a,i,j,k,m,size,elsize,retint;
  char char_val;
  charptr= &char_val;

  size=strlen(refer);
  elsize=strlen(element);

  if(strstr(element, refer)==0){
    /*printf("%s: freenet ", refer);*/
    return freenodenum;
  }

  else{
    for(i=0; i<elsize; i++){
      a=0;
      for(j=0; j<(size+1); j++){
        if(element[i+j]==refer[j]){
          a++;
          if(a==size){
            k=0;
            strcpy(number, "");
            while(isdigit(element[i+j+k+1])!=0){
              number[k]=element[i+j+k+1];
              k++;
	      number[k]='\0';
              if(k>10){
                printf("Error in Find Int\n");
                break;
              }
            }
            for(m=k;m<10;m++){
              number[m]=' ';
            }
            retint=atoi(number);
            a=0;
            break;
          }
        }
        else{
          a=0;
        }
      }
    }
    return retint;
  }
}
 
/* End of Find_Int */

double Find_Double(char* element, char* refer, char *units){
  char number[20], *charptr;
  int a,i,j,k,m,size, elsize;
  double retdouble;
  char t;

  charptr= &t;
  size=strlen(refer);
  elsize=strlen(element);

  strcpy(number, " ");

  if(strstr(element, refer)==0){
    printf("Reference '%s' not found.  Find_Double\n", refer);
    return 0;
  }

  else{
    /*printf("Reference '%s' found.  Find_Double\n", refer);*/
    for(i=0; i<elsize; i++){
      a=0;
      for(j=0; j<(size+1); j++){
        if(element[i+j]==refer[j]){
          a++;
          if(a==size){
            k=0;
            strcpy(number," ");
            /*while(isalpha(element[i+j+k+1])==0){*/
	    while(isdigit(element[i+j+k+1])!=0){
              number[k]=element[i+j+k+1];
              k++;
	      number[k]='\0';
              if(k>20){
                fprintf(stderr,"Error in Find Double\n");
		return 0;
                break;
              }
            }
	    /*printf("element[i+j+k+1]== %c\n\n", element[i+j+k+1]);*/
            *units=element[i+j+k+1];
	   
            charptr=&number[0];
            retdouble=atof(charptr);
	  a=0;
	  break;
          }
        }
        else{
          a=0;
        }
      }
    }
    return retdouble;
  }
}



double Set_Double(double dimension, char *units){
  /*Adjusts a double to account for units */
  int i,j,k,l;
  double retdouble;

  retdouble=dimension;

  if(*units=='u'){
    retdouble=dimension;
    return retdouble;
  }
  if(*units=='n'){
    retdouble=dimension*1.e-3;
    return retdouble;
  }
  if(*units=='a'){
    retdouble=dimension*1.e-4;
    return retdouble;
  }
  if(*units=='p'){
    retdouble=dimension*1.e-6;
    return retdouble;
  }
  if(*units=='f'){
    retdouble=dimension*1.e-9;
    return retdouble;
  }

  if(debug!=0){
    printf("\n!! NO UNITS !!  Assuming meters\n");
  }
  return retdouble*1.e6;

}

int Calc_Objs(char* filename, double *retdouble){
  /* Returns calculated objectives array*/
  /* [0]:  Kxx  [1]: Kyy  [2]: Area  [3]: Mass */
  double mass_total=0.00;
  double area_total=0.00;
  double mass_pm=0.00, mass_bm=0.00, mass_cd=0.00;
  char netfile[25];
  char element[1000], newel[1000];
  char *cond;

  FILE *netlist;
  struct Element elemstruct1, *elem1ptr, *elemptr, *elemptrold, *elmassptr;
  struct Node nodestruct1, *node1ptr, *nodeptr, *nodeptrold;
  struct Beam beamstruct1, *beam1ptr, *beamptr, *beamptrold;
  struct Mass massstruct1, *mass1ptr, *massptr, *massptrold, *outmassptr;
  struct Joint jointstruct1, *joint1ptr, *jointptr, *jointptrold;
  struct Anchor anchorstruct1, *anchor1ptr, *anchorptr, *anchorptrold;
  struct Combdrive combstruct1, *comb1ptr,  *combptr, *combptrold;
  int i,j;
  struct Element *outmasselemptr;
  double stiff[2], *stiffptr;
 
  if(debug!=0){
    printf("In Calc_Objs\n\n\n");
  }

  elemptr=NULL; elemptrold=NULL;
  beamptr=NULL; beamptrold=NULL;
  massptr=NULL; massptrold=NULL;
  jointptr=NULL, jointptrold=NULL;
  anchorptr=NULL; anchorptrold=NULL;
  combptr=NULL; combptrold=NULL;

  elem1ptr=NULL;
  beam1ptr=NULL;
  anchor1ptr=NULL;
  mass1ptr=NULL;
  joint1ptr=NULL;
  comb1ptr=NULL;

  elemstruct1.next_Element=NULL;
  massstruct1.next_Mass=NULL;
  beamstruct1.next_Beam=NULL;
  jointstruct1.next_Joint=NULL;
  anchorstruct1.next_Anchor=NULL;
  combstruct1.next_Combdrive=NULL;

  elemptr=&elemstruct1;
  beamptr=&beamstruct1;
  anchorptr=&anchorstruct1;
  massptr=&massstruct1;
  jointptr=&jointstruct1;
  combptr=&combstruct1;

  

  for(i=0;i<4;i++){
    retdouble[i]=defaultobjval;
  }

  strcpy(netfile, filename);
  strcat(netfile, ".sin");
 
  netlist=NULL;
  netlist=fopen(netfile, "r");
 
  if(netlist == NULL){
    fprintf(stderr,"Calc_Objs: netlist is NULL \n");
    errorcount++;
    return 0;
  }


  strcpy(element, " ");
  strcpy(newel, " ");


  /******/
  cond=fgets(newel, 1000, netlist);

  while(cond && strlen(newel)>=10){

    /** Initialization  **/ 
    if(Test_Header(newel)==0){
      strcat(element,newel);
    }
    else{
      strcpy(element,newel);
    }

    for(i=0;i<4;i++){
      for(j=0;j<4;j++){
	elemptr->lnodes[i][j]=freenodenum;
	if(i<3){
	  elemptr->gnodes[i][j]=freenodenum;
	}
      }
    }
    /*********************/

   /*Mass Elements */
    if(Test_Header(element)==2){
      massptr->width=freenodenum;
      massptr->outmass=0;

      *massptr=Add_Mass(element, *massptr);

      if(debug!=0){
	printf("massptr: %d \n", massptr);
      }

      if(massptr->width != freenodenum){
	
	if(debug!=0){
	  printf("MASS %d \n", massptr->massnum);
	  printf("%s\n\n", element);
	}

	if(mass1ptr==NULL){
	  mass1ptr=massptr;
	  if(debug!=0){
	    printf("mass1ptr: %d \n", mass1ptr);
	  }
	}

	mass_total=mass_total+(massptr->mass);
	mass_pm=mass_pm+massptr->mass;
	area_total=area_total+massptr->area;


	/***********************/
	elemptr->massel=NULL;
	elemptr->massel=massptr;
	massptr->mass_elem=NULL;
	massptr->mass_elem=elemptr;

	strcpy(elemptr->eltype, "MASS");
	elemptr->elnum=massptr->massnum;
	elemptr->length=massptr->length;
	elemptr->width=massptr->width;
	elemptr->numofports=massptr->numofports;
	if(massptr->massnum==outmassnum){
	  elemptr->outmass=1;
	  massptr->outmass=1;
	}
	else{
	  elemptr->outmass=0;
	  massptr->outmass=0;
	}

	for(i=0;i<4;i++){
	  for(j=0;j<4;j++){
	    elemptr->lnodes[i][j]=massptr->lnodes[i][j];
	    if(i<3){
	      elemptr->gnodes[i][j]=massptr->gnodes[i][j];
	    }
	  }
	}

	elemptrold=elemptr;
	elemptr->next_Element=NULL;
	elemptr->next_Element=(struct Element *)malloc(sizeof(struct Element));

	if(elemptr->next_Element  == NULL){
	  fprintf(stderr, "Calc_Objs: Next_element (M) is NULL \n\n\n");
	  /* exit(0) */
	  return 0;
	}
	
	elemptr=elemptr->next_Element;
	elemptr->elnum=freenodenum;
	elemptr->next_Element=NULL;
	elemptr->prev_Element=NULL;
	elemptr->prev_Element=elemptrold;
	
	/************************/
	if(debug!=0){
	  printf("BI: massptr: %d  #%d ", massptr, massptr->massnum);
	}	
	massptrold=massptr;
	
	massptr->next_Mass=NULL;
	massptr->next_Mass=(struct Mass *)malloc(sizeof(struct Mass));
	
	if(massptr->next_Mass == NULL){
	  fprintf(stderr, "next_mass is NULL \n\n\n");
	  printf("next_mass is NULL \n\n\n");
	  /* exit (0);*/
	  return 0;
	}
	
	massptr=massptr->next_Mass;

	massptr->outmass=0;
	massptr->width=freenodenum;
	massptr->massnum=freenodenum;

	massptr->next_Mass=NULL;
	massptr->prev_Mass=NULL;
      	massptr->prev_Mass=massptrold;
	if(debug!=0){
	  printf("AI: massptr: %d  #%d ", massptr, massptr->massnum);	
	}
      }
    }


  /*Joint Elements*/
    if(Test_Header(element)==4){
      jointptr->angle=freenodenum;

      *jointptr=Add_Joint(element, *jointptr);

      if (jointptr->angle!=freenodenum){
	if(debug!=0){
	  printf("JOINT %d \n", jointptr->jointnum);
	}
	/**********************/
	
	if(joint1ptr==NULL){
	  joint1ptr=jointptr;
	  if(debug!=0){
	    printf("joint1ptr: %d \n", joint1ptr);
	  }
	}

	/* kyfactor=kyfactor*fdecr; */

	elemptr->jointel=NULL;
	elemptr->jointel=jointptr;
	jointptr->joint_elem=NULL;
	jointptr->joint_elem=elemptr;


	strcpy(elemptr->eltype, "JOINT");
	elemptr->elnum=jointptr->jointnum;
	elemptr->length=0.0;
	elemptr->width=0.0;
	elemptr->numofports=jointptr->numofports;
	strcpy(elemptr->direction, jointptr->labels);
	for(i=0;i<4;i++){
	  for(j=0;j<4;j++){
	    elemptr->lnodes[i][j]=jointptr->lnodes[i][j];
	    if(i<3){
	      elemptr->gnodes[i][j]=jointptr->gnodes[i][j];
	    }
	  }
	}
      
	elemptrold=elemptr;
	elemptr->next_Element=NULL;
	elemptr->next_Element=(struct Element *)malloc(sizeof(struct Element));
	if(elemptr->next_Element  == NULL){
	  fprintf(stderr, "Calc_Objs: Next_element (J) is NULL \n\n\n");
	  /*exit(0);*/
	  return 0;
	}
	
	elemptr=elemptr->next_Element;
	elemptr->next_Element=NULL;
	elemptr->elnum=freenodenum;
	elemptr->prev_Element=NULL;
	elemptr->prev_Element=elemptrold;

	/*********************************/
	
	jointptrold=jointptr;
	
	jointptr->next_Joint=NULL;
	jointptr->next_Joint=(struct Joint *)malloc(sizeof(struct Joint));
	
	if(jointptr->next_Joint == NULL){
	  fprintf(stderr, "next_joint is NULL \n\n\n");
	  printf("next_joint is NULL \n\n\n");
	  /*exit (0);*/
	  return 0;
	}
	
	jointptr=jointptr->next_Joint;

	jointptr->jointnum=freenodenum;
	jointptr->angle=freenodenum;
	jointptr->next_Joint=NULL;
	jointptr->prev_Joint=NULL;
      	jointptr->prev_Joint=jointptrold;

      }
    }



    /*****************/

    /*Beam Elements */  
    if(Test_Header(element)==3){
      beamptr->angle=freenodenum;
    
      *beamptr=Add_Beam(element, *beamptr);

      if(errorcount>0){
	fprintf(stderr,"Error in Add_Beam \n");
	return 0;
      }

      if (beamptr->angle != freenodenum){
	/*
        printf("BEAM %d \n", beamptr->beamnum);
	printf("%s\n\n", element);
	*/

	mass_total=mass_total+(beamptr->mass);
	mass_bm=mass_bm+beamptr->mass;
	area_total=area_total+beamptr->area;

	/***********************/
	elemptr->beamel=NULL;
	elemptr->beamel=beamptr;
	beamptr->beam_elem=NULL;
	beamptr->beam_elem=elemptr;

	strcpy(elemptr->eltype, "BEAM");
	elemptr->elnum=beamptr->beamnum;
	elemptr->length=beamptr->length;
	elemptr->width=beamptr->width;
	elemptr->beamangle=beamptr->angle;

	elemptr->numofports=beamptr->numofports;
	for(i=0;i<4;i++){
	  for(j=0;j<2;j++){
	    elemptr->lnodes[i][j]=beamptr->lnodes[i][j];
	    if(i<3){
	      elemptr->gnodes[i][j]=beamptr->gnodes[i][j];
	    }
	  }
	}

	elemptrold=elemptr;
	elemptr->next_Element=NULL;
	elemptr->next_Element=(struct Element *)malloc(sizeof(struct Element));
	if(elemptr->next_Element  == NULL){
	  fprintf(stderr, "Calc_Objs: Next_element (C) is NULL \n\n\n");
	  /* exit(0); */
	  return 0;
	}
	
	elemptr=elemptr->next_Element;
	
	elemptr->next_Element=NULL;
	elemptr->prev_Element=NULL;
	elemptr->prev_Element=elemptrold;
	
	/************************/
	
	
	beamptrold=beamptr;
	
	beamptr->next_Beam=NULL;
	beamptr->next_Beam=(struct Beam *)malloc(sizeof(struct Beam));
	
	if(beamptr->next_Beam == NULL){
	  fprintf(stderr, "next_beam is NULL \n\n\n");
	  printf("next_beam is NULL \n\n\n");
	  /*exit (0);*/
	  return 0;
	}
	
	beamptr=beamptr->next_Beam;

	beamptr->next_Beam=NULL;
	beamptr->prev_Beam=NULL;
      	beamptr->prev_Beam=beamptrold;
	
	
      }
    }

    /*Anchor Elements */
    if(Test_Header(element)==1){
     
      anchorptr->nodex=freenodenum;
      *anchorptr=Add_Anchor(element, *anchorptr);
      
      if(anchorptr->nodex != freenodenum){
	/*
        printf("ANCHOR %d \n", anchorptr->anchornum);
	printf("%s\n\n", element);
	*/

	/***********************/
	elemptr->anchorel=NULL;
	elemptr->anchorel=anchorptr;
	anchorptr->anchor_elem=NULL;
	anchorptr->anchor_elem=elemptr;

	strcpy(elemptr->eltype, "ANCHOR");
	elemptr->elnum=anchorptr->anchornum;
	elemptr->length=0.0;
	elemptr->width=0.0;
	elemptr->numofports=anchorptr->numofports;
	for(i=0;i<3;i++){
	    elemptr->lnodes[i][0]=anchorptr->lnodes[i];
	}

	elemptrold=elemptr;
	elemptr->next_Element=NULL;
	elemptr->next_Element=(struct Element *)malloc(sizeof(struct Element));
	if(elemptr->next_Element  == NULL){
	  fprintf(stderr, "Calc_Objs: Next_element (C) is NULL \n\n\n");
	  /*exit(0);*/
	  return 0;
	}
	
	elemptr=elemptr->next_Element;

	elemptr->next_Element=NULL;
	elemptr->prev_Element=NULL;
	elemptr->prev_Element=elemptrold;
	
	/************************/
	
	
	anchorptrold=anchorptr;
	
	anchorptr->next_Anchor=NULL;

	anchorptr->next_Anchor=(struct Anchor *)malloc(sizeof(struct Anchor));
	
	
	if(anchorptr->next_Anchor == NULL){
	  fprintf(stderr, "Calc_Objs: Next_anchor is NULL \n\n\n");
	  /*exit (0);*/
	  return 0;
	}
	
	anchorptr=anchorptr->next_Anchor;

	anchorptr->next_Anchor=NULL;
	anchorptr->prev_Anchor=NULL;
      	anchorptr->prev_Anchor=anchorptrold;
      }
    }
    /* Matches if(Test_Header(element)  )  */
    
    /*Combdrive Elements */
    
    if(Test_Header(element)==5){
      /*puts(element);*/
      combptr->overlap=freenodenum;
      
      *combptr=Add_Comb(element, *combptr);
   
      if (combptr->overlap != freenodenum){
	/*
        printf("COMB %d \n", combptr->combnum);
	printf("%s\n\n", element);
	*/

	mass_total=mass_total+(combptr->mass);
	mass_cd=mass_cd+combptr->mass;
	area_total=area_total+combptr->area;
	
	/***********************/
	elemptr->combel=NULL;
	elemptr->combel=combptr;
	combptr->comb_elem=NULL;
	combptr->comb_elem=elemptr;

	strcpy(elemptr->eltype, "COMB");
	elemptr->elnum=combptr->combnum;
	elemptr->length=0.0;
	elemptr->width=0.0;
	elemptr->numofports=combptr->numofports;
	strcpy(elemptr->direction,combptr->direction);
	elemptr->ecompl=combptr->compliance;
	for(i=0;i<4;i++){
	  for(j=0;j<2;j++){
	    elemptr->lnodes[i][j]=combptr->lnodes[i][j];
	    if(i<3){
	      elemptr->gnodes[i][j]=combptr->gnodes[i][j];
	    }
	  }
	}

	elemptrold=elemptr;
	elemptr->next_Element=NULL;
	elemptr->next_Element=(struct Element *)malloc(sizeof(struct Element));
	if(elemptr->next_Element  == NULL){
	  fprintf(stderr, "Calc_Objs: Next_element (C) is NULL \n\n\n");
	  /*exit(0);*/
	  return 0;
	}
	
	elemptr=elemptr->next_Element;

	elemptr->next_Element=NULL;
	elemptr->prev_Element=NULL;
	elemptr->prev_Element=elemptrold;
	
	/************************/
	
	
	combptrold=combptr;
	
	combptr->next_Combdrive=NULL;
	combptr->next_Combdrive=(struct Combdrive *)malloc(sizeof(struct Combdrive));
	
	if(combptr->next_Combdrive == NULL){
	  fprintf(stderr, "next_comb is NULL \n\n\n");
	  printf("next_comb is NULL \n\n\n");
	  /*exit (0);*/
	  return 0;
	}
	
	combptr=combptr->next_Combdrive;

	combptr->next_Combdrive=NULL;
	combptr->prev_Combdrive=NULL;
      	combptr->prev_Combdrive=combptrold;
	
	
      }
    }
    /*Matches if Test_Header(element)==5 */
    /*Increment */
    cond=fgets(newel, 1000, netlist);
  }
  /* Matches while(cond) */

 

  if(netlist == NULL){
    fprintf(stderr,"Error in Calc_Objs: Netlist is null\n\n");
    /*exit(0);*/
    return 0;
  }


  fclose(netlist);   
  Classify_Beam(beamstruct1, anchorstruct1);



  if(mass_total==0){
    fprintf(stderr,"\nError in Calc_Objs: mass_total is 0. \n");
    errorcount++;
    return 0;
  }
 


  nodestruct1.next_Node=NULL;
  nodestruct1.prev_Node=NULL;

  /***********/
  if(debug!=0){
    printf("Calc_Objs:  &elemstruct1: %d", &elemstruct1);
    printf("before C_E \n\n");
  }

  nodestruct1=Cycle_Elements(&elemstruct1, nodestruct1);

  if(errorcount>0){
    printf("Error detected in Cycle_Elements\n");
    return 0;
  }

  if(debug!=0){
    printf("after C_E \n\n");
  }

  Check_Node_Tree(&nodestruct1);

  if(debug!=0){
    printf("Calc_Objs:  &elemstruct1: %d", &elemstruct1);
  }

  outmasselemptr=Find_Element(&elemstruct1, "MASS", outmassnum);

  if(outmasselemptr==NULL){
    printf("Error Detected in Find_Element \n");
    errorcount++;
    return(0);
  }

  if(debug!=0){
    printf("outmasselemptr: %d", outmasselemptr);
  }

  /***************************/


  /**************/

  /** Meff and Aeff Calculations **/

  beamptr=&beamstruct1;
  while(beamptr->next_Beam){
    if(strstr(beamptr->anchorlabel, "S")!=0){
      /* Slow Beam */

      if(debug!=0){
	printf("\nBeam %d is attached to an anchor.\n", beamptr->beamnum);
      }

      mass_total=mass_total-(beamptr->mass);
      mass_total=mass_total+((pow(C_sb,2))*beamptr->mass);
      
      area_total=area_total-(beamptr->mass);
      area_total=area_total+(C_sb)*beamptr->mass;
    }

    else{
      /* Fast Beam */

      mass_total=mass_total-(beamptr->mass);
      mass_total=mass_total+((pow(C_fb,2))*beamptr->mass);

      area_total=area_total-(beamptr->mass);
      area_total=area_total+(C_fb)*beamptr->mass;
    }
    beamptr=beamptr->next_Beam;
  }


  /* This part seeks out mass elements which are NOT part of the proof mass, and treats them like fast beam elements for the Meff and Aeff calculations */

  massptr=&massstruct1;
  while(massptr && massptr->next_Mass){
    if(massptr->outmass!=0){
      outmassptr=massptr;
      outmassptr->pfstat=1;
      if(debug!=0){
	printf("\nMass # %d is pf. \n", outmassptr->massnum);
      }
    }
    massptr=massptr->next_Mass;
  }


  elmassptr=&elemstruct1;
  if(debug!=0){
    printf("\n\nelmassptr=%d  ", elmassptr);
    printf(" [%s %d]\n", elmassptr->eltype, elmassptr->elnum);
  }
  while(elmassptr && elmassptr->next_Element){
    if(strstr(elmassptr->eltype, "MASS")!=0){
      massptr=elmassptr->massel;
      if(debug!=0){
	printf("\n\nmassel=%d\n", massptr);
      }
      for(i=0;i<4;i++){
	if(elmassptr->attachedel[i]){
	  if(debug!=0){
	    printf("\n\nelmassptr=%d\n", elmassptr);
	  }
	  elemptr=elmassptr->attachedel[i];
	  if(!elemptr){
	    fprintf(stderr,"Error in Calc_Objs: elemptr is NULL due to");
	    fprintf(stderr,"misconfiguration of attachedel array.\n");
	    errorcount++;
	    return 0;
	  }
	  if(elemptr){

	    if(debug!=0){
	      printf("\nelemptr: %d\n", elemptr);
	      printf("\n[%s %d]\n", elemptr->eltype, elemptr->elnum);
	    }
	    
	   
	    if(strstr(elemptr->eltype, "MASS")!=0){
	      massptrold=elemptr->massel;
	      if(debug!=0){
		printf("\nmassptrold: %d\n", massptrold);
	      }
	      

	      if(massptrold->pfstat==1){
		
		if(debug!=0){
		  printf("\nMass # %d is pf. \n", massptrold->massnum);
		}
		
		massptr->pfstat=1;
	      }
	      if(massptr->pfstat==1){
		if(debug!=0){
		  printf("\nMass # %d is pf. \n", massptr->massnum); 
		}
		massptrold->pfstat=1;
	      }
	    }
	  }
	}
      }
      if(debug!=0){
	printf("Out of for loop.\n");
      }
    }
    elmassptr=elmassptr->next_Element;
  }

  massptr=&massstruct1;
  while(massptr && massptr->next_Mass){
    if(massptr->pfstat!=1){
      if(debug!=0){
	printf("\nMass # %d is NOT pf. \n", massptr->massnum);
      }

      mass_total=mass_total-(massptr->mass);
      mass_total=mass_total+((pow(C_fb,2))*massptr->mass);

      area_total=area_total-(massptr->mass);
      area_total=area_total+(C_fb)*massptr->mass;
    }
    massptr=massptr->next_Mass;
  }

  /**************/
 
  retdouble[3]=mass_total;


  /**********************/


  stiffptr=&stiff[0];

  stiffptr=Calc_Stiff(outmasselemptr, stiffptr);

  if(errorcount>0){
    printf("Error Detected in Calc_Stiff \n");
    errorcount++;
    return(0);
  }

  stiff[0]=stiffptr[0];
  stiff[1]=stiffptr[1];

  if(debug!=0){
    printf("\n");
    printf("stiff [0]: %g N/u\n", stiff[0]);
    printf("stiff [1]: %g N/u\n", stiff[1]);
  }

  stiff[0]=stiff[0]*1.e6;
  stiff[1]=stiff[1]*1.e6;

  retdouble[0]=stiff[0];
  retdouble[1]=stiff[1];

  if(debug!=0){
    printf("stiff [0]: %g N/m\n", stiff[0]);
    printf("stiff [1]: %g N/m\n", stiff[1]);
  }

  /***********/

  /*printf("node 1: %d", nodestruct1.nodenum);*/

  

  /***  Free all linked lists ****/

  elemptr=&elemstruct1;
  elemptr=elemptr->next_Element;

  if(debug!=0){
    printf("Elements: \n");
  }
  while(elemptr->next_Element && elemptr->elnum!=freenodenum) {
    elemptrold=elemptr;
    elemptr=elemptrold->next_Element;

    if(debug!=0){
      printf("[%s %d]  ", elemptrold->eltype, elemptrold->elnum);
    }

/*
    for(i=0;i<4;i++){
      for(j=0;j<4;j++){
	free(elemptrold->attachedel[i][j]);
      }
      free(elemptrold->elnodes[i]);
    }
*/

    free(elemptrold);
  }
  if(debug!=0){
    printf("\n");
  }

  nodeptr=NULL;
  nodeptr=&nodestruct1;
  if(nodeptr->next_Node){
    nodeptr=nodeptr->next_Node;
  }

  else{
    fprintf(stderr, "In Calc_Objs: nodestruct1: next_Node is NULL\n");
    /*exit(0);*/
    return 0;
  }
  if(debug!=0){
    printf("Node numbers:  ");
  }

  if(!nodeptr){
    fprintf(stderr, "In Calc_Objs: nodeptr is NULL\n");
    return 0;
  }

  if(!nodeptr->next_Node){
    printf("nodeptr->Next= NULL\n\n");
  }

  while(nodeptr && nodeptr->next_Node) {
    nodeptrold=nodeptr;
    nodeptr=nodeptrold->next_Node;
    if(debug!=0){
      printf("  %d ", nodeptrold->nodenum);
    }
    /*
    for(i=0;i<4;i++){
      free(nodeptrold->attachedel[i]);
      free(nodeptrold->attachednode[i]);
      free(nodeptrold->atnodeels[i]);
    }
    */

    free(nodeptrold);
  }
  if(debug!=0){
    printf("\n");
  }


  beamptr=&beamstruct1;
  beamptr=beamptr->next_Beam;

  if(!beamptr){
    if(debug!=0){
      printf("\nbeamptr is NULL.\n");
    }
  }

  while(beamptr && beamptr->next_Beam){
    
    beamptrold=beamptr;
    beamptr=beamptrold->next_Beam;
    if(debug!=0){
      printf("Beam %d ", beamptrold->beamnum);
    }
    free(beamptrold);
  }

  if(debug!=0){
    printf("BF: massptr: %d  #%d ", massptr, massptr->massnum);
  }
  massptr=NULL;
  massptrold=NULL;

  massptr=mass1ptr;
  if(massptr){
    if(debug!=0){
      printf("massptr: %d  #%d \n", massptr, massptr->massnum);
    }
  }

  massptr=massptr->next_Mass;

  /*
  if(massptr){
    printf("massptr: %d  #%d \n", massptr, massptr->massnum);
    printf(" massptr->next_Mass: %d  ", massptr->next_Mass);
    massptrold=massptr->next_Mass;
    printf(" #%d  ", massptrold->massnum);
  }
  */

  while(massptr->next_Mass && massptr->massnum!=freenodenum){
    massptrold=NULL;
    massptrold=massptr;
    massptr=massptrold->next_Mass;
    if(debug!=0){
      printf("IW:  massptr: %d  #%d\n", massptr, massptr->massnum);
      printf("IW: Mass %d ", massptrold->massnum);
    }
    if(massptrold!=NULL){
      /*free(massptrold);*/
    }
    else{
      fprintf(stderr,"Calc_Objs: Massptrold is null \n");
      /*exit(0);*/
      return 0;
    }
  }


  jointptr=joint1ptr;
  if(debug!=0){
    printf("\njointptr: %d ", jointptr);
  }
  if(jointptr!=NULL){
    if(debug!=0){
      printf(" %d \n", jointptr->jointnum);
    }
    jointptr=jointptr->next_Joint;
  }

  while(jointptr && jointptr->next_Joint && jointptr->angle!=freenodenum){
    jointptrold=jointptr;
    jointptr=jointptrold->next_Joint;
    if(debug!=0){
      printf("Joint %d ", jointptrold->jointnum);
    }
    free(jointptrold);
  }

  anchorptr=&anchorstruct1;
  anchorptr=anchorptr->next_Anchor;

  while(anchorptr && anchorptr->next_Anchor){
    anchorptrold=anchorptr;
    anchorptr=anchorptrold->next_Anchor;
    /*
    printf("Anchor %d ", anchorptrold->anchornum);
    */
    free(anchorptrold);
  }

  combptr=&combstruct1;
  combptr=combptr->next_Combdrive;

  while(combptr && combptr->next_Combdrive){
    combptrold=combptr;
    combptr=combptrold->next_Combdrive;
    /*
    printf("Comb %d ", combptrold->combnum);
    */
    free(combptrold);
  }



  /**** End of freeing ****/

  return 1;

}
/* End of Calc_Objs */


int Test_Header(char* element){
  char head[5];
  char massstr[50], beamstr[50], anchorstr[50], combstr[50];
  char spcstr[25], teststr[30];
  char jointstr[50];

  /*
  strcpy(spcstr, "           ");

  strcpy(massstr, "plate_mass");
  strcpy(beamstr, "beam.beam");
  strcpy(anchorstr, "anchor.anchor");
  strcpy(combstr, "combdrive_");
  strcpy(jointstr, "joint.joint");
  strcpy(voltstr, "v.v");
  strcpy(anglestr, "angle.angle");
  */

  strcpy(teststr, "anchor.anchor");
  if(strstr(element,teststr)!=0){
    return 1;
  }
  strcpy(teststr, "plate_mass");
  if(strstr(element,teststr)!=0){
    return 2;
  }
  strcpy(teststr, "beam.beam");
  if(strstr(element,teststr)!=0){
    return 3;
  }
  strcpy(teststr, "joint.joint");
  if(strstr(element,teststr)!=0){
    return 4;
  }
  strcpy(teststr, "combdrive_");
  if(strstr(element,teststr)!=0){
    return 5;
  }
  strcpy(teststr, "v.v");
  if(strstr(element,teststr)!=0){
    return 9;
  }

  strcpy(teststr, "             ");

  if(strncmp(element,teststr,10)==0){
    return 9;
  }

  else{
    return 0;
  }
}


struct Mass Add_Mass(char* element, struct Mass mass){
  char refer1[10], refer2[10], refer3[10];
  char *charptr, diml[10], dimw[10], char_type;
  int i,j;
  char *units1, unit_type;

  charptr=&char_type;
  units1=&unit_type;

  strcpy(diml, " ");
  strcpy(dimw, " ");

  /*
plate_mass.plate_mass_1_ phi_ne:_n3102 phi_nw:freeNet2 phi_sw:freeNet3 phi_se:freeNet4 x_ne:_n3100 x_nw:freeNet6 x_sw:freeNet7 x_se:freeNet8 y_ne:_n3101 y_nw:freeNet10 y_sw:freeNet11 y_se:freeNet12 v_ne:_n3103 v_nw:freeNet14 v_sw:freeNet15 v_se:freeNet16 PHIne:freeNet17 PHInw:freeNet18 PHIsw:freeNet19 PHIse:freeNet20 Xne:freeNet21 Xnw:freeNet22 Xsw:freeNet23 Xse:freeNet24 Yne:freeNet25 Ynw:freeNet26 Ysw:freeNet27 Yse:freeNet28 phi_b:freeNet29 x_b:freeNet30 y_b:freeNet31 v_b:freeNet32 PHIb:freeNet33 Xb:freeNet34 Yb:freeNet35 phi_r:_n62 x_r:_n22 y_r:_n42 v_r:_n3 PHIr:_n122 Xr:_n82 Yr:_n102 phi_t:_n61 x_t:_n21 y_t:_n41 v_t:_n2 PHIt:_n121 Xt:_n81 Yt:_n101 phi_l:freeNet36 x_l:freeNet37 y_l:freeNet38 v_l:freeNet39 PHIl:freeNet40 Xl:freeNet41 Yl:freeNet42 = l= 100u, w= 100u 
  */

  strcpy(refer1, "mass_");
  if(isdigit(Find_Char(element, refer1, '_'))!=0){
    mass.massnum=Find_Int(element, refer1);
    if(debug!=0){
      printf("\n plate mass_%d ", mass.massnum);
    }
  }

  strcpy(refer1, "l= ");
  mass.length=Find_Double(element, refer1, units1);
  if(debug!=0){
    printf("pmass length=%g%c ", mass.length, *units1);
  }
  mass.length=Set_Double(mass.length, units1);

  strcpy(refer1, "w= ");
  mass.width=Find_Double(element, refer1, units1);
  if(debug!=0){
    printf("pmass width=%g%c ", mass.width, *units1);
  }
  mass.width=Set_Double(mass.width, units1);

  strcpy(refer1, "x_ne:_n");
  mass.nodex_ne=Find_Int(element, refer1);
  /*printf("x_ne: %d ",mass.nodex_ne);*/

  if(mass.nodex_ne==3100){
    mass.outne=1;
    outmassnum=mass.massnum;
    mass.outmass==1;
  }

  strcpy(refer1, "y_ne:_n");
  mass.nodex_ne=Find_Int(element, refer1);
  /*printf("y_ne: %d ",mass.nodex_ne);*/

  /*lnodes [variable, position]*/
  /*x:0, y:1, phi:2, v:3*/
  /*t:0, r:1, b:2, r:3*/

  for(i=0;i<4;i++){
    for(j=0;j<4;j++){
      mass.lnodes[i][j]=freenodenum;
      if(i<3){
	mass.gnodes[i][j]=freenodenum;
      }
    }
  }

  strcpy(refer1, "x_t:_n");
  mass.lnodes[0][0]=Find_Int(element, refer1);

  strcpy(refer1, "x_r:_n");
  mass.lnodes[0][1]=Find_Int(element, refer1);

  strcpy(refer1, "x_b:_n");
  mass.lnodes[0][2]=Find_Int(element, refer1);

  strcpy(refer1, "x_l:_n");
  mass.lnodes[0][3]=Find_Int(element, refer1);


  strcpy(refer1, "y_t:_n");
  mass.lnodes[1][0]=Find_Int(element, refer1);

  strcpy(refer1, "y_r:_n");
  mass.lnodes[1][1]=Find_Int(element, refer1);

  strcpy(refer1, "y_b:_n");
  mass.lnodes[1][2]=Find_Int(element, refer1);

  strcpy(refer1, "y_l:_n");
  mass.lnodes[1][3]=Find_Int(element, refer1);


  strcpy(refer1, "phi_t:_n");
  mass.lnodes[2][0]=Find_Int(element, refer1);

  strcpy(refer1, "phi_r:_n");
  mass.lnodes[2][1]=Find_Int(element, refer1);

  strcpy(refer1, "phi_b:_n");
  mass.lnodes[2][2]=Find_Int(element, refer1);

  strcpy(refer1, "phi_l:_n");
  mass.lnodes[2][3]=Find_Int(element, refer1);


  strcpy(refer1, "v_t:_n");
  mass.lnodes[3][0]=Find_Int(element, refer1);

  strcpy(refer1, "v_r:_n");
  mass.lnodes[3][1]=Find_Int(element, refer1);

  strcpy(refer1, "v_b:_n");
  mass.lnodes[3][2]=Find_Int(element, refer1);

  strcpy(refer1, "v_l:_n");
  mass.lnodes[3][3]=Find_Int(element, refer1);


  strcpy(refer1, "X_t:_n");
  mass.gnodes[0][0]=Find_Int(element, refer1);

  strcpy(refer1, "X_r:_n");
  mass.gnodes[0][1]=Find_Int(element, refer1);

  strcpy(refer1, "X_b:_n");
  mass.gnodes[0][2]=Find_Int(element, refer1);

  strcpy(refer1, "X_l:_n");
  mass.gnodes[0][3]=Find_Int(element, refer1);

  if(debug!=0){
    printf("massnodes:\n");
    for(i=0;i<4;i++){
      for(j=0;j<4;j++){
	printf("[%d, %d]: %d  ",i,j,mass.lnodes[i][j]);
      }
      printf("\n");
    }
  }

  mass.area=(mass.length*mass.width)*(1.e-6)*(1.e-6);
  mass.mass=mass.area*areadensity;

  if(debug!=0){
    printf("\n\npm mass=%g kg\n",  mass.mass);
  }

  return(mass);
}

/* End of Add_Mass */


struct Joint Add_Joint(char* element, struct Joint joint){
  char refer1[10], refer2[10];
  char *charptr, *units1, char_type, units_type;
  int i,j;

  charptr=&char_type;
  units1=&units_type;

  strcpy(refer1, "joint_");
  strcpy(refer2, "ang=");

  if(isdigit(Find_Char(element, refer1, '_'))!=0){
    joint.jointnum=Find_Int(element, refer1);
    if(debug!=0){
      printf("\n joint_%d ", joint.jointnum);
    }
  }

  /*lnodes [variable, position] */
  /*x:0, y:1, phi:2, v:3*/
  /*n:0, e:1, s:2, w:3*/


  strcpy(refer1, "x_n:_n");
  joint.nodex_n=Find_Int(element, refer1);
  joint.lnodes[0][0]=Find_Int(element, refer1);

  strcpy(refer1, "y_n:_n");
  joint.nodey_n=Find_Int(element, refer1);
  joint.lnodes[1][0]=Find_Int(element, refer1);

  strcpy(refer1, "phi_n:_n");
  joint.nodephi_n=Find_Int(element, refer1);
  joint.lnodes[2][0]=Find_Int(element, refer1);

  strcpy(refer1, "vn:_n");
  joint.nodev_n=Find_Int(element, refer1);
  joint.lnodes[3][0]=Find_Int(element, refer1);

  strcpy(refer1, "Xn:_n");
  joint.nodeX_n=Find_Int(element, refer1);
  joint.gnodes[0][0]=Find_Int(element, refer1);

  strcpy(refer1, "Yn:_n");
  joint.nodeY_n=Find_Int(element, refer1);
  joint.gnodes[1][0]=Find_Int(element, refer1);

  strcpy(refer1, "PHIn:_n");
  joint.nodePHI_n=Find_Int(element, refer1);
  joint.gnodes[2][0]=Find_Int(element, refer1);
 
  if(joint.lnodes[0][0]!=freenodenum){
    strcat(joint.labels, "T");
  }

  /************************/
  strcpy(refer1, "x_s:_n");
  joint.nodex_s=Find_Int(element, refer1);
  joint.lnodes[0][2]=Find_Int(element, refer1);

  strcpy(refer1, "y_s:_n");
  joint.nodey_s=Find_Int(element, refer1);
  joint.lnodes[1][2]=Find_Int(element, refer1);

  strcpy(refer1, "phi_s:_n");
  joint.nodephi_s=Find_Int(element, refer1);
  joint.lnodes[2][2]=Find_Int(element, refer1);

  strcpy(refer1, "vs:_n");
  joint.nodev_s=Find_Int(element, refer1);
  joint.lnodes[3][2]=Find_Int(element, refer1);

  strcpy(refer1, "Xs:_n");
  joint.nodeX_s=Find_Int(element, refer1);
  joint.gnodes[0][2]=Find_Int(element, refer1);

  strcpy(refer1, "Ys:_n");
  joint.nodeY_s=Find_Int(element, refer1);
  joint.gnodes[1][2]=Find_Int(element, refer1);

  strcpy(refer1, "PHIs:_n");
  joint.nodePHI_s=Find_Int(element, refer1);
  joint.gnodes[2][2]=Find_Int(element, refer1);  
  
  if(joint.lnodes[0][2]!=freenodenum){
    strcat(joint.labels, "B");
  }

  /***********************/
  strcpy(refer1, "x_e:_n");
  joint.nodex_e=Find_Int(element, refer1);
  joint.lnodes[0][3]=Find_Int(element, refer1);

  strcpy(refer1, "y_e:_n");
  joint.nodey_e=Find_Int(element, refer1);
  joint.lnodes[1][3]=Find_Int(element, refer1);

  strcpy(refer1, "phi_e:_n");
  joint.nodephi_e=Find_Int(element, refer1);
  joint.lnodes[2][3]=Find_Int(element, refer1);

  strcpy(refer1, "ve:_n");
  joint.nodev_e=Find_Int(element, refer1);
  joint.lnodes[3][3]=Find_Int(element, refer1);

  strcpy(refer1, "Xe:_n");
  joint.nodeX_e=Find_Int(element, refer1);
  joint.gnodes[0][3]=Find_Int(element, refer1);

  strcpy(refer1, "Ye:_n");
  joint.nodeY_e=Find_Int(element, refer1);
  joint.gnodes[1][3]=Find_Int(element, refer1);

  strcpy(refer1, "PHIe:_n");
  joint.nodePHI_e=Find_Int(element, refer1);
  joint.gnodes[2][3]=Find_Int(element, refer1);

  if(joint.lnodes[0][3]!=freenodenum){
    strcat(joint.labels, "L");
  }

  /***********************/
  strcpy(refer1, "x_w:_n");
  joint.nodex_w=Find_Int(element, refer1);
  joint.lnodes[0][1]=Find_Int(element, refer1);

  strcpy(refer1, "y_w:_n");
  joint.nodey_w=Find_Int(element, refer1);
  joint.lnodes[1][1]=Find_Int(element, refer1);

  strcpy(refer1, "phi_w:_n");
  joint.nodephi_w=Find_Int(element, refer1);
  joint.lnodes[2][1]=Find_Int(element, refer1);

  strcpy(refer1, "vw:_n");
  joint.nodev_w=Find_Int(element, refer1);
  joint.lnodes[3][1]=Find_Int(element, refer1);

  strcpy(refer1, "Xw:_n");
  joint.nodeX_w=Find_Int(element, refer1);
  joint.gnodes[0][1]=Find_Int(element, refer1);

  strcpy(refer1, "Yw:_n");
  joint.nodeY_w=Find_Int(element, refer1);
  joint.gnodes[1][1]=Find_Int(element, refer1);

  strcpy(refer1, "PHIw:_n");
  joint.nodePHI_w=Find_Int(element, refer1);
  joint.gnodes[2][1]=Find_Int(element, refer1);

  if(joint.lnodes[0][1]!=freenodenum){
    strcat(joint.labels, "R");
  }

  /************************/
  strcpy(refer2, "ang=");
  joint.angle=Find_Double(element, refer2, units1);
  if(debug!=0){
    printf("jointnodes\n");
    for(i=0;i<4;i++){
      for(j=0;j<4;j++){
	printf("[%d,%d]: %d  ",i,j,joint.lnodes[i][j]);
      }
      printf("\n");
    }
  }

  return(joint);
}

/* End of Add_Joint */





struct Beam Add_Beam(char* element, struct Beam beam){
  char refer1[10], refer2[10], refer3[10], refer4[10];
  char angle[3], *charptr;
  int i,j,k,m,n;
  char *units1, unit_char;

  units1=NULL;
  units1=&unit_char;

  strcpy(beam.blabel, "   ");
  strcpy(beam.label_a, "   ");
  strcpy(beam.label_b, "   ");

  strcpy(refer1, "beam_");
  beam.beamnum=Find_Int(element, refer1);

  if(debug!=0){
    printf("\n beam_%d ", beam.beamnum);
  }

  strcpy(refer3, "l= ");
  beam.length=Find_Double(element, refer3, units1); 
  beam.length=Set_Double(beam.length, units1);

  if(debug!=0){
    printf(" length: %gu ", beam.length);
  }

  strcpy(refer4, "w= ");
  beam.width=Find_Double(element, refer4, units1);
  beam.width=Set_Double(beam.width, units1);

  if(debug!=0){
    printf(" width: %gu ", beam.width);
  }

  /*lnodes [variable, position]*/ 
  /*x:0, y:1, phi:2, v:3   
  /*a:0, b:1*/ 

  for(i=0;i<4;i++){
    for(j=0; j<2; j++){
      beam.lnodes[i][j]=freenodenum;
      if(i<3){
	beam.gnodes[i][j]=freenodenum;
      }
    }
  }

  strcpy(refer1, "x_a:_n");
  beam.lnodes[0][0]=Find_Int(element, refer1);
  beam.nodex_a=Find_Int(element, refer1);

  strcpy(refer1, "x_b:_n");
  beam.lnodes[0][1]=Find_Int(element, refer1);
  beam.nodex_b=Find_Int(element, refer1);

  strcpy(refer1, "y_a:_n");
  beam.lnodes[1][0]=Find_Int(element, refer1);
  beam.nodex_a=Find_Int(element, refer1);

  strcpy(refer1, "y_b:_n");
  beam.lnodes[1][1]=Find_Int(element, refer1);
  beam.nodex_b=Find_Int(element, refer1);

  strcpy(refer1, "phi_a:_n");
  beam.lnodes[2][0]=Find_Int(element, refer1);
  beam.nodex_a=Find_Int(element, refer1);

  strcpy(refer1, "phi_b:_n");
  beam.lnodes[2][1]=Find_Int(element, refer1);
  beam.nodex_b=Find_Int(element, refer1);

  strcpy(refer1, "v_a:_n");
  beam.lnodes[3][0]=Find_Int(element, refer1);
  beam.nodev_a=Find_Int(element, refer1);

  strcpy(refer1, "v_b:_n");
  beam.lnodes[3][1]=Find_Int(element, refer1);
  beam.nodev_b=Find_Int(element, refer1);

  strcpy(refer1, "Xa:_n");
  beam.gnodes[0][0]=Find_Int(element, refer1);
  beam.nodeXa=Find_Int(element, refer1);

  strcpy(refer1, "Xb:_n");
  beam.gnodes[0][1]=Find_Int(element, refer1);
  beam.nodeXb=Find_Int(element, refer1);

  /*************************************/ 
  if(debug!=0){
    printf("beamnodes:\n");
    for(i=0;i<4;i++){
      for(j=0; j<2; j++){
	printf("[%d, %d]: %d  ",i,j,beam.lnodes[i][j]);
      }
      printf("\n");
    }
  }

  strcpy(refer1, "angle=");
  beam.angle=freenodenum;
  beam.angle=Find_Double(element, refer1, units1);

  if(beam.angle==freenodenum){
    fprintf(stderr,"Add_Beam: error in beam angle \n\n");
    /*exit(0);*/
    errorcount++;
    return (beam);
  }

  if(beam.angle< 45.0){
    strcpy(beam.direction,"x");
  }
    if(beam.angle>= 45.0 ){
    strcpy(beam.direction,"y");
  }

  beam.area=(beam.length*beam.width)*(1.e-6)*(1.e-6);
  beam.mass=beam.area*areadensity;
  if(debug!=0){
    printf("beam mass=%g  kg\n",  beam.mass);
  }
  units1 = NULL;

  return(beam);
}

/* End of Add Beam */



struct Combdrive Add_Comb(char* element, struct Combdrive comb){
  char refer1[10], refer2[10], dir, direct[5];
  char *charptr, diml[10], dimw[10];
  int i,j;
  char *units;
  char unit_val;
  char char_val;
  double complnum, complden;

  charptr=&char_val;
  units = &unit_val;



  strcpy(diml, " ");
  strcpy(dimw, " ");
  strcpy(refer1, "combdrive_");

  dir=Find_Char(element, refer1, '_');
  
  direct[0]=dir;
  direct[1]='\0';

  strcpy(comb.direction, direct);

  if(debug!=0){
    printf("\n combdrive_%s ", comb.direction);
  }

  if(dir=='x'){
    strcpy(refer1, "combdrive_x_");
    comb.combnum=Find_Int(element, refer1);
    if(debug!=0){
      printf("_%d", comb.combnum);
    }
  }

  if(dir=='y'){
    strcpy(refer1, "combdrive_y_");
    comb.combnum=Find_Int(element, refer1);
    if(debug!=0){
      printf("_%d", comb.combnum);
    }
  }

  strcpy(refer2, "gap= ");
  comb.gap=Find_Double(element, refer2, units);
  comb.gap=Set_Double(comb.gap, units);

  strcpy(refer2, "rotor_fingers= ");
  comb.rotor_fingers=Find_Int(element, refer2);

  strcpy(refer2, "finger_length= ");
  comb.finger_length=Find_Double(element, refer2, units);
  comb.finger_length=Set_Double(comb.finger_length, units);

  strcpy(refer2, "finger_width= ");
  comb.finger_width=Find_Double(element, refer2, units);
  comb.finger_width=Set_Double(comb.finger_width, units);

  strcpy(refer2, "overlap= ");
  comb.overlap=Find_Double(element, refer2, units);
  comb.overlap=Set_Double(comb.overlap, units);

  /* ky= 2*e*t(fl+xmax)*V^2*N/ g^3 */

  complnum=(pow((comb.gap*1.e-6),3));
  complden=2*885.e-14*(2*1.e-6)*(comb.overlap+2)*1.e-6*(pow(inputvoltage,2))*comb.rotor_fingers;

  comb.compliance=complnum/complden; /* m/N */
  comb.compliance=comb.compliance*1.e-6;  /* u/N */

  /*
combdrive_y.combdrive_y_1_ v_s:_n1 v_r:_n2 phi_r:_n61 phi_s:_n60 x_r:_n21 y_r:_n41 y_s:_n40 x_s:_n20 Xr:_n81 PHIr:_n121 Yr:_n101 Ys:0 Xs:0 PHIs:_n120 =gap= 2u, rotor_fingers= 30, finger_length= 10u, finger_width= 2u, overlap= 5u
   */

  /*lnodes [variable, position]*/
  /*x:0, y:1, phi:2, v:3 */
  /*s:0, r:1*/

  for(i=0; i<4; i++){
    for(j=0; j<2; j++){
      comb.lnodes[i][j]=freenodenum;
      if(i<3){
	comb.gnodes[i][j]=freenodenum;
      }
    }
  }
  
  strcpy(refer1, "x_s:_n");
  comb.lnodes[0][0]=Find_Int(element, refer1);
  /* printf("x_s: %d", comb.lnodes[0][0]);*/

  strcpy(refer1, "x_r:_n");
  comb.lnodes[0][1]=Find_Int(element, refer1);
  /*printf("x_r: %d", comb.lnodes[0][1]); printf("x_s: %d", comb.lnodes[0][0]);*/


  strcpy(refer1, "y_s:_n");
  comb.lnodes[1][0]=Find_Int(element, refer1);
  /*printf("y_s: %d", comb.lnodes[1][0]);*/

  strcpy(refer1, "y_r:_n");
  comb.lnodes[1][1]=Find_Int(element, refer1);
  /*printf("y_r: %d", comb.lnodes[1][1]);*/

  strcpy(refer1, "phi_s:_n");
  comb.lnodes[2][0]=Find_Int(element, refer1);
  /*printf("phi_s: %d", comb.lnodes[2][0]);*/

  strcpy(refer1, "phi_r:_n");
  comb.lnodes[2][1]=Find_Int(element, refer1);
  /*printf("phi_r: %d", comb.lnodes[2][1]);*/

  strcpy(refer1, "v_s:_n");
  comb.lnodes[3][0]=Find_Int(element, refer1);
  /*printf("v_s: %d", comb.lnodes[3][0]);*/

  strcpy(refer1, "v_r:_n");
  comb.lnodes[3][1]=Find_Int(element, refer1);
  /*printf("v_r: %d", comb.lnodes[3][1]);*/

  strcpy(refer1, "Xs:_n");
  comb.gnodes[0][0]=Find_Int(element, refer1);
  /*printf("X_s: %d", comb.gnodes[0][0]);*/

  strcpy(refer1, "Xr:_n");
  comb.gnodes[0][1]=Find_Int(element, refer1);
  /*printf("X_r: %d", comb.gnodes[0][1]);*/

  if(debug!=0){
    printf("combnodes:\n");
    for(i=0; i<4; i++){
      for(j=0; j<2; j++){
	printf("[%d,%d]:  %d", i, j, comb.lnodes[i][j]);
      }
      printf("\n");
    }
  }

  comb.area=(comb.finger_length*comb.finger_width*comb.rotor_fingers)*(1e-6)*(1e-6);
  comb.mass=comb.area*areadensity;

  if(debug!=0){
    printf("\ncomb %d mass = %g kg\n\n", comb.combnum, comb.mass);
  }

  return comb;
}


/* End of Add_Comb */


struct Anchor Add_Anchor(char* element, struct Anchor anchor){
  char refer1[10], number[10];
  char *charptr, char_val;
  int i,j;

  charptr=&char_val;

  strcpy(number, " ");

  /*lnodes [variable] */
  /*x:0, y:1, phi:2 */

  for(i=0; i<3; i++){
    anchor.lnodes[i]=freenodenum;
  }

  strcpy(refer1, "anchor_");
  anchor.anchornum=Find_Int(element, refer1);
  if(debug!=0){
    printf("\n anchor_%d ", anchor.anchornum);
  }
  strcpy(refer1, " x:_n");
  anchor.lnodes[0]=Find_Int(element, refer1);
  anchor.nodex=Find_Int(element, refer1);

  strcpy(refer1, " y:_n");
  anchor.lnodes[1]=Find_Int(element, refer1);
  anchor.nodey=Find_Int(element, refer1);

  strcpy(refer1, "phi:_n");
  anchor.lnodes[2]=Find_Int(element, refer1);
  anchor.nodephi=Find_Int(element, refer1);


  for(i=0; i<3; i++){
    /*printf("[%d]: %d  ",i,anchor.lnodes[i]);*/
  }
  if(debug!=0){
    printf("\n");
  }

  return anchor;
}


/* End of Add_Anchor */

void Classify_Beam(struct Beam beamstruct1, struct Anchor anchorstruct1){
  struct Beam *beamptr;
  struct Anchor *anchorptr;
  int i,j,k;

  /*printf("In C_B\n\n\n\n\n");*/
  beamptr=&beamstruct1;
  anchorptr=&anchorstruct1;
  /*printf("In C_B2\n\n\n\n\n");*/
  while(beamptr->next_Beam){
    /*printf("beam %d anchor %d\n\n\n", beamptr->beamnum, anchorptr->anchornum);*/

    anchorptr=&anchorstruct1;
    while(anchorptr->next_Anchor){

      for(i=0;i<2;i++){
	if((beamptr->lnodes[0][i]==anchorptr->lnodes[0])&&
	   beamptr->lnodes[0][i]!=freenodenum){
	  if(debug!=0){
	    printf("Beam %d", beamptr->beamnum);
	    printf(" is attached to");
	    printf(" Anchor %d.", anchorptr->anchornum);
	  }
	  strcpy(beamptr->anchorlabel, "S");
	}
      }

      anchorptr=anchorptr->next_Anchor;
    }

    beamptr=beamptr->next_Beam;
  }
}

/* End of Classify_Beam */


double InterpretAC(char* filename) {
  FILE *outfileptr;
  char outfile[25], refer1[10];
  char textline[256], freqchar[20];
  int linelength=250;
  char *cond, dir;
  double freqx=0, freqy=0.00, freq=0;
  int i, j, detect=0, count=0, lincount=0;

  strcpy(outfile, filename);
  strcat(outfile, ".out");

  if(debug!=0){
    printf("Interpret AC: Opening %s\n", outfile);
  }

  outfileptr=fopen(outfile, "r");


  if(!outfileptr) {
    fprintf(stderr,"unable to open file %s \n", outfile);
    /*exit(0);*/
    errorcount++;
    return 0;
  }




  cond=fgets(textline, linelength, outfileptr);

  while(cond){

    lincount++;

    /* Look for number */
    detect=0;

    for(i=0;i<5;i++){
      strcpy(refer1, "Maximum of DB");
      if(strstr(textline,refer1)!=0){

	if(lincount>5){
	  detect=1;
	  /*
	  printf("The word 'Maximum' detected at: \n %s\n", textline);
	  */
	  break;
	}
      }
    }

    /*
    printf("detect: %d\n\n", detect);
    */

    /* The word 'at' is found */
    if(detect!=0){
      /*printf(" in if \n\n");*/
      /*printf("freqchar: ");*/
      strcpy(refer1, " at ");
      freq=Find_Int(textline, refer1);
      printf("freq= %g\n\n", freq);

 
      puts(textline);

      strcpy(refer1, "y_mid");

      if(strstr(textline, refer1)!=0){
	dir='Y';
	printf("****Y******\n\n");
	freqy=freq;
      }

      strcpy(refer1, "x_mid");

      if(strstr(textline, refer1)!=0){
	dir='X';
	printf("****X******\n\n");
	freqx=freq;
      }

      /*
      count++;
      if(count==1){
	dir='Y';
      }
      else if(count==2){
	dir='X';
      }
      */

      printf("\n%c direction ",dir);
      printf("frequency = %g Hz\n", freq);

      detect=0;
    }
   
    /************************/

    cond=fgets(textline, linelength, outfileptr);
    if(cond!=0){
      /*puts(textline);*/
      /*printf("cond = '%c'\n", *cond);*/
    }
  }
  fclose(outfileptr);
  return freqy;
}


int Clean_Elements(struct Element *elem1){
  /*This function removes duplicate elements*/
  struct Element *elemptr, *elpt2, *elcptr1, *elcptr2;
  int i,j,k,m,n;

  elemptr=NULL; elpt2=NULL; elcptr1=NULL; elcptr2=NULL;

  if(debug!=0){
    printf("In clean \n\n");
  }

  elemptr=elem1;

  while(elemptr->next_Element){
    /*printf("elemptr: %s  %d  \n", elemptr->eltype, elemptr->elnum);*/
    elpt2=elem1;
    
    while(elpt2->next_Element){
      /*printf("elpt2: %s  %d   \n\n", elpt2->eltype, elpt2->elnum);*/

      elcptr1=Find_Element(elem1,elemptr->eltype,elemptr->elnum);
      elcptr2=Find_Element(elem1,elpt2->eltype,elpt2->elnum);

      /*
      printf("elc1=%d\n\n", elcptr1);
      */

      if((elcptr1!=NULL) && (elcptr1==elcptr2) && 
	 elemptr!=elpt2 && elemptr->elnum!=freenodenum){

	printf("Erasing %s %d\n", elpt2->eltype, elpt2->elnum);
	strcpy(elpt2->eltype," ");
	elpt2->elnum=freenodenum;
	for(m=0;m<4;m++){
	  for(n=0;n<4;n++){
	    elpt2->lnodes[m][n]=freenodenum;
	    if(m<3){
	      elpt2->gnodes[m][n]=freenodenum;
	    }
	  }
	}
      }
      elpt2=elpt2->next_Element;
    }
    elemptr=elemptr->next_Element;
  }

  return 1;
}


struct Element *Find_Element(struct Element *elem1ptr, char *type, int number){
  struct Element *elemptr, *retelemptr;
  int i,j,k;

  elemptr=NULL;
  retelemptr=NULL;


  elemptr=elem1ptr;

  /*
    printf("In Find_Element\n\n");
  */

  while(elemptr->next_Element){
    if((strstr(elemptr->eltype, type)!=0)&&
       elemptr->elnum==number){
      retelemptr=elemptr;
      break;
    }
    elemptr=elemptr->next_Element;
  }

  /*printf("retelemptr: %d \n\n", retelemptr);*/
  
  return retelemptr;
}


struct Node *Find_Node(struct Node *node1ptr, int number){
  struct Node *nodeptr, *retnode;
  int b=0;

  nodeptr=NULL;
  retnode=NULL;

  nodeptr=node1ptr;

  /*printf("In Find_Node\n\n");*/

  /*
  if(node1.nodenum==number){
    b=1;
    retnode=nodeptr;
    printf("F_N:  nodeptr= %d\n", nodeptr);
    printf("F_N:  &node1= %d\n", &node1);
  }
  */

  while(nodeptr->next_Node && b==0){
    if(nodeptr->nodenum==number){
      retnode=nodeptr;
      b=1;  
      break;
    }
    nodeptr=nodeptr->next_Node;
  }

  /*
  printf("F_N:  retnode: %d\n\n", retnode);
  */

  return retnode;
}




struct Node Cycle_Elements(struct Element *elem1, struct Node node1){
  struct Element *elemptr, *elpt2;
  struct Node *nodeptr, *oldnode, *nodept2, *atchnullnode, *noderef;
  int i,j,k,m,n,q,r,s,elindex,ncount=0, S_N_check;

  elemptr=NULL; elpt2=NULL;
  nodeptr=NULL; oldnode=NULL; nodept2=NULL;
  atchnullnode=NULL;


  nodeptr=&node1;
  /*
  printf("nodeptr:  %d",  nodeptr);

  printf("before clean \n\n");

  printf("Cycle_Elements:  elem1: %d", elem1);
  */

  Clean_Elements(elem1);


  /*These loops configure connections between elements*/
  elemptr=elem1;

  if(elemptr->next_Element==NULL){
    printf("Cycle_Elements: Next Element is NULL");
  }

  while(elemptr->next_Element){

    for(elindex=0; elindex<4; elindex++){
      elemptr->elnodes[elindex]=NULL;
      elemptr->attachedel[elindex]=NULL;
    }

    if(elemptr->elnum != freenodenum){
      /*printf("\n**%s %d \n", elemptr->eltype,elemptr->elnum);*/
    }
    else{
      /*printf("nil ");*/
    }

    elpt2=elem1;
    while(elpt2->next_Element){
      for(i=0;i<4;i++){
	for(j=0;j<4;j++){

	  /*elemptr->elnodes[i]=NULL;*/

	  /* This'if' compares x node numbers at each port 
	     and searches for a connectivity between the 
	     two elements denoted by elemptr and elpt2 */

	  if((elemptr->lnodes[0][i]==elpt2->lnodes[0][j])&&
	     (elemptr->lnodes[0][i]!=freenodenum) &&
	     elemptr!=elpt2){
	    
	    /* Connection found. */
	    
	    if(debug!=0){
	      printf("\n**%s %d \n", elemptr->eltype,elemptr->elnum);
	      printf("    is attached to ");
	      printf("%s %d ", elpt2->eltype,elpt2->elnum);
	      printf("on side %d \n", i);
	    }

	    elemptr->attachedel[i]=elpt2;

	    r=elemptr->lnodes[0][i];
	    
	    if(debug!=0){
	      printf(" r= %d\n\n", r);
	    }

	    nodept2=Find_Node(&node1, r); 

	    if(debug!=0){
	      printf("nodept2: %d, r: %d\n\n", nodept2, r);
	    }

	    if(nodept2==NULL){
	      /* New node */ 
	      ncount++;

	      /*printf("123nodeptr:  %d",  nodeptr);*/

	      s=elemptr->lnodes[0][i];
	      nodeptr->nodenum=s;
	      /*printf("\n\n node %d is a new node", nodeptr->nodenum);*/
	      
	      strcpy(nodeptr->vlabel, "   ");
	      /* This for loop intitializes the node struct */
	      for(q=0;q<4;q++){

		nodeptr->attachedel[q]=NULL;

		nodeptr->attachednode[q]=NULL;
		nodeptr->atnodeels[q]=NULL;

		/*
		nodeptr->attachednode[q]=(struct Node *)
		  malloc(sizeof(struct Node));
		

	        atchnullnode=nodeptr->attachednode[q];
	        atchnullnode->nodenum=freenodenum;
		*/
		
	      }

	      /*printf("456nodeptr:  %d",  nodeptr);*/

	      S_N_check=Set_Node(nodeptr, elemptr);

	      if(S_N_check==0){
		printf("Error detected in Set_Node\n");
		errorcount++;
		return(node1);
	      }
		/* exit(0); */
	      /*printf("789nodeptr:  %d",  nodeptr);*/

	      elemptr->elnodes[i]=nodeptr;
	
	      /*
	      printf("\nCycle Elements\n");
 	      printf("elemptr: %d  ", elemptr);
	      printf("[%s %d] [i= %d]:", elemptr->eltype, elemptr->elnum, i);
	      printf("nodeptr: %d", nodeptr);
	      printf("# %d \n\n", nodeptr->nodenum);
	      */

	      oldnode=nodeptr;
	      nodeptr->next_Node=NULL;
	      nodeptr->next_Node=(struct Node *)malloc(sizeof(struct Node));

	      if(nodeptr->next_Node==NULL){
		fprintf(stderr,"Cycle_Elements: next_Node is NULL\n\n");
		errorcount++;
		return(node1);
		/* exit(0); */
	      }




	      nodeptr=nodeptr->next_Node;
	      nodeptr->next_Node=NULL;

	      nodeptr->prev_Node=NULL;
	      nodeptr->prev_Node=oldnode;
	    }
	    
	    else{
	      /* Previously existing node*/ 
	      /*printf("\n\nnode %d is an existing node", nodept2->nodenum);*/

	      S_N_check=Set_Node(nodept2, elemptr);

	      if(S_N_check==0){
		printf("Error detected in Set_Node\n");
		errorcount++;
		return(node1);
	      }

	      elemptr->elnodes[i]=nodept2;

	      /*
	      printf("\nCycle Elements\n");
	      printf("elemptr: %d  ", elemptr);
	      printf("[%s %d] [i= %d]:", elemptr->eltype, elemptr->elnum, i);
	      printf("nodeptr: %d", nodeptr);
	      printf("# %d \n\n", nodeptr->nodenum);
	      */
	    }
	    
	    /*Node 1 check */
	    m=r;
	    if(debug!=0){
	      printf("Cycle Elements:  node1:#%d   %d\n", node1.nodenum, &node1);
	    }
	    noderef=Find_Node(&node1, m);
	    if(debug!=0){
	      printf("noderef: %d, r: %d\n\n", noderef, r);
	    }
	    if(m==node1.nodenum){
	      if(noderef!=&node1){
		fprintf(stderr,"Cycle Elements: mismatch hack 2\n");
		errorcount++;
		return(node1);
		/* exit(0); */
	      }
	    }

	    /*********/

	    /*attachedel[port #] */
	    
	    if(elemptr->attachedel[i]==NULL){
	      /*elemptr->attachedel[i]=elpt2;*/
	      break;
	    }
	    
	    /*printf("k: %d",k);*/ 
	    /*********************/ 
	  }/* Matches if(... elemptr!=elpt2) */ 
	  
		
	  else{
  /*printf("%d %d",elemptr->lnodes[0][i],elpt2->lnodes[0][j]);*/
	  }
	   
	} /* Matches for(j...) */
      } /* Matches for(i...) */
      
      elpt2=elpt2->next_Element;
    }
    if(debug!=0){
      printf("\n");
    }
    elemptr=elemptr->next_Element;
  }

  if(debug!=0){
    printf("before C_N node1: ");
    printf("%d", node1.nodenum);
    printf("  %d\n", &node1);
  }

  nodeptr=Find_Node(&node1, node1.nodenum);


  if(nodeptr!= &node1){
    printf("\n&node1 = %d\n", &node1);
    printf("nodeptr= %d\n", nodeptr);
    fprintf(stderr,"Error in Cycle_Elements: Node 1 pointer.\n\n");
    errorcount++;
    return(node1);
    /* exit(0); */

  }

  /*********/

  elemptr=elem1;
  nodept2=NULL;
  elpt2=NULL;

  if(debug!=0){
    printf("In Test loop. elemptr: %d\n", elemptr);
    while(elemptr->next_Element){
      printf("\n!@#$ ELEMENT ");
      printf("[%s %d] ", elemptr->eltype, elemptr->elnum);
      for(i=0;i<4;i++){
	if(elemptr->elnodes[i]!=NULL){
	  nodept2=elemptr->elnodes[i];
	  elpt2=elemptr->attachedel[i];
	  printf("[i=%d]: %d ", i, nodept2->nodenum);
	  printf(" %s %d  ", elpt2->eltype, elpt2->elnum);
	}
	else{
	  printf("[i=%d]: NULL ", i);
	}
	printf("\n");
      }
      elemptr=elemptr->next_Element;
    }
  }

  /****/

  if(node1.next_Node==NULL){
    fprintf(stderr,"Error in Cycle_Elements: node1.next_Node=NULL\n\n");
    errorcount++;
    return(node1);
    /* exit(0); */
    
  }

  /*
  nodeptr=&node1;
  elpt2=NULL;
  while(nodeptr->next_Node){
    
    printf("\n!@#$ NODE %d", nodeptr->nodenum);
    
    for(i=0;i<4;i++){
      elpt2=nodeptr->attachedel[i];
      if(elpt2!=NULL){
	printf("   attachedel[%d]: %s %d", i,elpt2->eltype, elpt2->elnum);
      }
    }
    nodeptr=nodeptr->next_Node;
  }

  */

  node1=Cycle_Nodes(node1);  

  return node1;
}


int Set_Node(struct Node *nodeptr, struct Element *elemptr){
  int q,j,i;
  struct Element *elem2;
  
  /*assigns elements to a node struct in attachedel array*/
  if(debug!=0){ 
    printf("\nSet Node node # %d: %d ", nodeptr->nodenum, nodeptr);
    printf(" elem:  %s  %d \n", elemptr->eltype, elemptr->elnum);
    printf("\n");
  }

  j=0;
  

  for(q=0;(q<5 && j==0);q++){
    
    if(nodeptr->attachedel[q]!=NULL  &&  nodeptr->nodenum!=freenodenum){

      elem2=NULL;
      elem2=nodeptr->attachedel[q];
      if(debug!=0){
	printf("[q=%d]: %s %d", q, elem2->eltype, elem2->elnum);
      }
    }
    
    if((q<4)&&((nodeptr->attachedel[q]==NULL) || 
	       nodeptr->nodenum==freenodenum)){

      if(nodeptr->attachedel[q]==NULL){
	/*printf("node %d [%d] is NULL", node.nodenum, q);*/
	/*node.attachedel[q]=(struct Element *)malloc(sizeof(struct Element));*/
      }
      /*
      printf(" *  ");
      */
      nodeptr->attachedel[q]=elemptr;
      if(debug!=0){ 
	printf("[q=%d]: %s %d", q, elemptr->eltype, elemptr->elnum);
      }

      j=1;
      break;
    }
    if(q==4){
      fprintf(stderr,"\nq=4 error.");
      errorcount++;
      return(0);
      /* exit(0); */
    }
  }


  if(q<=1){
    strcpy(nodeptr->nodetype, "series");
  }
  if(q>1){
    strcpy(nodeptr->nodetype, "parallel");
  }
  
  /*printf(" %s  %d ", node.nodetype, node.nodenum);
  printf(" q= %d", q);
  */

  return 1;
}


struct Node Cycle_Nodes(struct Node node1){
  /*This function builds a node tree */
  struct Element *elemptr;
  struct Node *nodeptr, *nodept2, *atchnode;
  int i,j,k=0,m,n, fromnode, tonode, check=0;

  nodeptr=&node1;
  

  while(nodeptr->next_Node){
    /*printf("\n\n* NODE: %d\n", nodeptr->nodenum);*/

    for(i=0;i<4;i++){
      if(nodeptr->attachedel[i]!=NULL){
	elemptr=nodeptr->attachedel[i];
	/*
	printf("elemptr: %s %d\n", elemptr->eltype, elemptr->elnum);
	*/
	fromnode=nodeptr->nodenum;
	/*
        printf("fromnode: %d\n", fromnode);
	*/
	for(m=0;m<4;m++){
	  /*printf(" %d ", elemptr->lnodes[0][m]);*/
	}

	/*printf("\n");*/


	for(j=0;j<4;j++){
	  if(((elemptr->lnodes[0][j])!=fromnode) &&
	     (elemptr->lnodes[0][j])!=freenodenum){

	    tonode=elemptr->lnodes[0][j];
	    
	    /*printf("node 1 : %d  tonode %d\n", node1.nodenum, tonode);*/

	    nodept2=Find_Node(&node1, tonode);

	    if(nodept2==NULL){
	      fprintf(stderr,"nodept2 is NULL\n");
	      printf("elemptr: %s %d", elemptr->eltype, elemptr->elnum);
	      printf("node1:%d  tonode: %d\n", node1.nodenum, tonode); 
	    }
	    else{
	      /*
	      printf("   tonode: %d ", tonode);
	      printf("   nodept2: %d", nodept2->nodenum);
	      */
	    }

	    check=0;
	    for(k=0;(k<4 && check==0);k++){

	      atchnode=nodeptr->attachednode[k];

	      if(atchnode==NULL){

		nodeptr->attachednode[k]=nodept2;

		/*printf("  nodept2->nodenum: %d", nodept2->nodenum);*/
		/*printf(" k: %d ", k);*/

		nodeptr->atnodeels[k]=elemptr;
		/*printf("%s %d\n", elemptr->eltype, elemptr->elnum);*/

		check=1;
	      }
	    }
	  }
	}
      }
    }


    /*printf(" k= %d ", k);*/
    if(k<2){
      strcpy(nodeptr->nodetype, "terminal");
    }
    
    if(k>2){
      strcpy(nodeptr->nodetype, "parallel");
    }
    /* printf("%s", nodeptr->nodetype);*/

    nodeptr=nodeptr->next_Node;
  }
  /* End of while loop */
  /*printf("calling C_N_T from Cycle Nodes\n");*/
  Check_Node_Tree(&node1);
  /*********************************************/

  return node1;
}


void Check_Node_Tree(struct Node *node1){
  int check, fromnode, i;
  struct Node *getnode, *atchnodecnt, *atchnodecnt2;
  struct Element *elemptr, *atchel;
  char response[5];


  check=0;

  /*Checking Function */

  /*
  strcpy(response, " ");

  printf("Do you want to check node tree?\n");
  scanf("%s", response);

  if((strstr(response,"y")!=0) || (strstr(response,"Y")!=0)){
    check=1;
  }
  */

  while(check!=0){
    printf("C_N_T: node1 is %d \n\n", node1->nodenum);

    printf("Enter node number: ");
    scanf ("%d", &fromnode);
    getnode=Find_Node(node1, fromnode);
    
    while(getnode==NULL){
      printf("Enter node number: ");
      scanf ("%d", &fromnode);
      getnode=Find_Node(node1, fromnode);
    }
    

    if(getnode!=NULL){
      printf("retrieved node [#%d]: %d\n", getnode->nodenum, getnode);
      printf("attachednodes:\n");
      for(i=0; i<4; i++){

	atchnodecnt2=getnode->attachednode[i];

	if(atchnodecnt2!=NULL && atchnodecnt2->nodenum!=freenodenum){

	  atchnodecnt=getnode->attachednode[i];
	
	  elemptr=getnode->atnodeels[i];
	  printf("i:%d  [#%d]: %d", i, atchnodecnt->nodenum, atchnodecnt);
	  printf("via %s %d ", elemptr->eltype, elemptr->elnum);
	  printf("next node: %d ", atchnodecnt->next_Node);
	  printf("\n");
	}
      }
      for(i=0;i<4;i++){
	if(getnode->attachedel[i]!=NULL){
	  atchel=getnode->attachedel[i];
	  printf("[i: %d] %s %d", i, atchel->eltype, atchel->elnum);
	  printf("\n");
	}
      }
    }
    printf("\nEnter 0 to end C_N_T.\n");
    scanf("%d", &check);
  }
  /* End of while(check) */
}

struct Node *Get_Outnode(struct Element *elem1){
  struct Node *retnode, *massnode;
  struct Mass *outmassptr;
  struct Element *elemmass;
  int i;


  elemmass=Find_Element(elem1, "MASS", outmassnum);
  outmassptr=elemmass->massel;


  for(i=0;i<4;i++){
    if(elemmass->elnodes[i]!=NULL){
      massnode=elemmass->elnodes[i];
      if(debug!=0){ 
	printf("outmassnode is %d", massnode->nodenum);
      }
      i=6;
    }
    if(i==3){
      fprintf(stderr,"error: all elnodes are null");
    }
  }
  /*printf("i= %d", i);*/
  if(i==7){
    if(debug!=0){ 
      printf("\n\nmassnode is %d\n\n", massnode->nodenum);
    }
    retnode=massnode;
  }


  return retnode;
}

int Find_Numofunvnodes(struct Element *elemptr){
  int retint, index, count=0;
  struct Node *nodeptr;

  if(debug!=0){ 
    printf("In F_N\n");
    printf("elemptr: %d", elemptr);
    printf("\n[%s %d] Nodes:\n", elemptr->eltype, elemptr->elnum);
  }

  for(index=0;index<4;index++){
    if(elemptr->elnodes[index]!=NULL){
      nodeptr=elemptr->elnodes[index];

      if(debug!=0){ 
	printf("[%d]  ", nodeptr->nodenum);
      }

      if(strstr(nodeptr->vlabel, "V")==0){

	count++;

      }
    }
  }
  if(debug!=0){ 
    printf("\n");
  }

  retint=count;

  if(debug!=0){ 
    printf("There are %d unvisited nodes.\n", retint);
  }

  return retint;
}

/*int stiffdirect=0; */
/*1 when going from r port, -1 when going from l, 0 otherwise */

double *Calc_Stiff(struct Element *elemref, double *kvals){
  int numofunvnodes, i, j;
  double *retdouble, *kparaptr, complser[2], complpara[2], compl[2];
  double kpara[2], beamcompliance[2];
  double check, dblspc[2];
  double Lx=0, Ly=0, Ix=0, Iy=0;
  struct Node *nodeptr, nodespc;
  struct Element *elemptr, *parenelemptr, *elptr2;
  int outmasscheck=0; /* 1 when elemptr is mass connected to output, 0 otherwise */
  int momentsign=0; /* 1 for positive, 0 for negative */
  int beamdirect; /* 1 for horiz,  0 for vert */

  /* int stiffdirect=0; -> 1 when going from r port, -1 when going from l, 0 otherwise */

  nodeptr=&nodespc;
  for(i=0;i<2;i++){
    complser[i]=0;
    complpara[i]=0;
    compl[i]=0;
    kpara[i]=0;
  }

  retdouble=kvals;

  if(debug!=0){ 
    printf("\n\nIn Calc_Stiff\n");
    printf("elemref:  %d", elemref);
  }

  if(elemref==NULL){
    fprintf(stderr,"elemref is NULL\n");
    errorcount++;
    return 0;
    /*exit(0);*/
  }

  if(debug!=0){ 
    printf("\n[%s %d]:\n  ", elemref->eltype, elemref->elnum);
  }

  numofunvnodes=Find_Numofunvnodes(elemref);
  elemptr=elemref;

  while(numofunvnodes==1){
    if(strstr(elemptr->eltype, "BEAM")!=0){
      if(debug!=0){ 
	printf("This beam is ");
      }
      if(elemptr->beamangle<45){
	if(debug!=0){ 
	  printf("horizontal. \n");
	}
	beamdirect=1;
	Lx=elemptr->length;
	Ly=elemptr->width;
      }
      else{
	if(debug!=0){ 
	  printf("vertical. \n");
	}
	beamdirect=0;
	Lx=elemptr->width;
	Ly=elemptr->length;
      }

      Ix=2*(pow(Lx,3))/12;
      if(debug!=0){ 
	printf("\n Lx: %gu Ix: %gu^4 \n", Lx, Ix);
	printf("\n pow(Lx,3)= %g\n", pow(Lx,3));
      }
      Iy=2*(pow(Ly,3))/12;
      if(debug!=0){ 
	printf("\n Ly: %gu Iy: %gu^4 \n", Ly, Iy);
      }
      /* x-direction compliance */
      beamcompliance[0]=((pow(Ly,3))/(3*E*Ix));
      /*complser[0]=complser[0]+((pow(Ly,3))/(3*E*Ix));*/
      if(debug!=0){ 
	printf("\n 3EIx: %g \n", (3*E*Ix));
	printf("complser [x] : %g \n", ((pow(Ly,3))/(3*E*Ix)));
	printf("complser total [x]: %g\n", complser[0]);
      }
      /* y-direction compliance */
      beamcompliance[1]=((pow(Lx,3))/(3*E*Iy));
      /*complser[1]=complser[1]+((pow(Lx,3))/(3*E*Iy));*/
      if(debug!=0){ 
	printf("complser [y] : %g \n", ((pow(Lx,3))/(3*E*Iy)));
	printf("complser total [y]: %g\n", complser[1]);
      }
      /*
	Ix=(1/12)*2*pow(Lx,3);
	kvals[0]=kvals[0]+[(3*E*Ix)/(pow(Ly,3))];
	
	Iy=(1/12)*2*pow(Ly,3);
	kvals[1]=kvals[1]+[(3*E*Iy)/(pow(Lx,3))];
      */

      if(atype!=0){
	if(momentsign==0){
	  momentsign=stiffdirect;
	}
	if(momentsign>0){
	  complser[beamdirect]=complser[beamdirect]+(beamcompliance[beamdirect]*fincr);
	  if(debug!=0){ 
	    printf("\n\nIncreasing [%d] compliance\n\n", beamdirect);
	  }
	}
	if(momentsign<0){
	  complser[beamdirect]=complser[beamdirect]+(beamcompliance[beamdirect]*fdecr);
	  if(debug!=0){ 
	    printf("\n\nDecreasing [%d] compliance\n\n", beamdirect);
	  }
	}
      }

      if(atype==0){
	complser[0]=complser[0]+((pow(Ly,3))/(3*E*Ix));
	complser[1]=complser[1]+((pow(Lx,3))/(3*E*Iy));
      }

    }

    /* Negative spring effect of combdrive */
    if(strstr(elemptr->eltype, "COMB")!=0){
      if(debug!=0){ 
	printf("This combdrive is ");
      }
      if(strstr(elemptr->direction, "x")!=0){
	if(debug!=0){ 
	  printf(" x-direction \n");
	}
	complser[0]=defmax;
	complser[1]=complser[1]-elemptr->ecompl;
	if(debug!=0){ 
	  printf("complser [y] : %g \n", elemptr->ecompl);
	  printf("complser total [y]: %g\n", complser[1]);
	}
      }
      if(strstr(elemptr->direction, "y")!=0){
	if(debug!=0){ 
	  printf(" y-direction \n");
	}
	complser[0]=complser[0]-elemptr->ecompl;
	complser[1]=defmax;
	if(debug!=0){ 
	  printf("complser [x] : %g \n", elemptr->ecompl);
	  printf("complser total [x]: %g\n", complser[0]);
	}
      }
    }

    
    if(strstr(elemptr->eltype, "JOINT")!=0){
      if(stiffdirect==0){
	if(elemptr->attachedel[0]!=NULL){
	  stiffdirect=1;
	}
	if(elemptr->attachedel[3]!=NULL){
	  stiffdirect=-1;
	}
      }

      if((strstr(elemptr->direction, "T")!=0 &&
	 strstr(elemptr->direction, "L")!=0) ||
	 (strstr(elemptr->direction, "B")!=0 &&
	 strstr(elemptr->direction, "R")!=0)){
	/* Top - Left or Bottom - Right Connection */
	if(stiffdirect==1){
	  momentsign=1;
	  if(atype==0){
	    complser[0]=complser[0]*fincr;
	    complser[1]=complser[1]*fincr;
	  }
	}

	if(stiffdirect==-1){
	  momentsign=-1;
	  if(atype==0){
	    complser[0]=complser[0]*fdecr;
	    complser[1]=complser[1]*fdecr;
	  }
	}
      }

      if((strstr(elemptr->direction, "T")!=0 &&
	 strstr(elemptr->direction, "R")!=0) ||
	 (strstr(elemptr->direction, "B")!=0 &&
	 strstr(elemptr->direction, "L")!=0)){
	/* Top - Right or Bottom - Left Connection */
	if(stiffdirect==1){
	  momentsign=1;
	  if(atype==0){
	    complser[0]=complser[0]*fdecr;
	    complser[1]=complser[1]*fdecr;
	  }
	}
	if(stiffdirect==-1){
	  momentsign=-1;
	  if(atype==0){
	    complser[0]=complser[0]*fincr;
	    complser[1]=complser[1]*fincr;
	  }
	}
      }
    }





  
    for(i=0;i<4;i++){
      if (elemptr->attachedel[i]!=NULL){
	nodeptr=elemptr->elnodes[i];
	if(strstr(nodeptr->vlabel, "V")==0){
	  /* node is unvisited */
	  elemptr=elemptr->attachedel[i];
	  strcpy(nodeptr->vlabel, "V");
	  numofunvnodes=Find_Numofunvnodes(elemptr);
	  i=4; break;
	}
      }
    }
  }

  /* Branch */
  if(numofunvnodes>1){
    parenelemptr=elemptr;
    elemptr=NULL;
    if(debug!=0){ 
      printf("Parallel: \n");
      printf("Element (parenelemptr):  %s  %d \n", parenelemptr->eltype, parenelemptr->elnum);
    }
    
    for(i=0;i<4;i++){
      if (parenelemptr->attachedel[i]!=NULL){
	
	
	/* If parenelemptr is a Mass, this determines whether parenelemptr or its adjoining mass element is the output mass */
	
	if(strstr(parenelemptr->eltype, "MASS")!=0){
	  if(parenelemptr->elnum==outmassnum){
	    outmasscheck=1;
	    if(parenelemptr->outmass!=1){
	      fprintf(stderr,"Error in Calc_Stiff: Outmass determination.\n");
	      errorcount++;
	      return 0;
	      /* exit(0); */
	    }
	  }
	  
	  else{
	    for(j=0;j<4;j++){
	      if(parenelemptr->attachedel[j]){
		elptr2=parenelemptr->attachedel[j];
		if(elptr2->outmass==1){
		  outmasscheck=1;
		  if(strstr(elptr2->eltype, "MASS")==0){
		    fprintf(stderr,"Error in Calc_Stiff: Adj. outmass determination.\n");
		    errorcount++;
		    return 0;
		    /*exit(0);*/
		  }
		}
	      }
	    }
	  }
	}
	


    /******/


	nodeptr=parenelemptr->elnodes[i];
	if(strstr(nodeptr->vlabel, "V")==0){
	  /* node is unvisited */
	  elemptr=parenelemptr->attachedel[i];
	  strcpy(nodeptr->vlabel, "V");

	  if(outmasscheck!=0){
	    if(i==1){
	      stiffdirect=1;
	    }
	    if(i==3){
	      stiffdirect=-1;
	    }
	  }

	  kparaptr=&dblspc[0];
	  if(debug!=0){ 
	    printf("Element:  %s  %d ", elemptr->eltype, elemptr->elnum);
	  }
	  kparaptr=Calc_Stiff(elemptr, kparaptr);

	  if(errorcount>0){
	    printf("Error Detected in Calc_Stiff \n");
	    errorcount++;
	    return(0);
	  }

	  for(j=0;j<2;j++){
	    if(debug!=0){ 
	      printf("\nkparaptr[%d]=%g ", j, kparaptr[j]);
	      printf(" kparaold[%d]=%g\n", j, kpara[j]);
	    }
	    if(fabs(kparaptr[j])<defmax){
	      kpara[j]=kpara[j]+kparaptr[j];
	    }
	    if(fabs(kparaptr[j])>=defmax){
	      kpara[j]=defmax;
	    }
	    if(debug!=0){ 
	      printf(" kpara[%d]=%g\n", j, kpara[j]);
	    }
	  }
	}
      }
    }

    for(i=0;i<2;i++){
      if(fabs(kpara[i])<=1.e-6){
	fprintf(stderr,"kpara[%d] is zero ",i);
	kpara[i]=defmin;
      }
      else{
	complpara[i]=complpara[i]+(1/kpara[i]);
	if(fabs(complpara[i])<=defmin){
	  complpara[i]=0;
	}
	if(debug!=0){ 
	  printf("\ncomplpara [%d] : %g \n", i, complpara[i]);
	}
      }
    }
  }

  if(numofunvnodes<1){
    if(strstr(elemptr->eltype,"ANCHOR")==0){
      for(i=0;i<2;i++){
	complser[i]=defmax;
      }
    }
  }

  for(i=0;i<2;i++){
    if(fabs(complser[i])<=defmin){
      complser[i]=0;
    }
    if(debug!=0){ 
      printf("\ncomplser[%d] = %g  ",i,complser[i]);
    }
    if(fabs(complpara[i])<=defmin){
      complpara[i]=0;
    }
    if(debug!=0){ 
      printf("complpara[%d] = %g  \n",i,complpara[i]);
    }
  }

  for(i=0;i<2;i++){
    compl[i]=complpara[i]+complser[i];
    if(debug!=0){ 
      printf("\n %g + %g :", complpara[i], complser[i]);
      printf("compl[%d] = %g\n",i,compl[i]);
    }
  }

  for(i=0;i<2;i++){
    if(compl[i]==0){
      if(debug!=0){ 
	printf("compl[%d] is zero ",i);
      }
      compl[i]=0;
      kvals[i]=defmax;
    }
    else{
      kvals[i]=1/compl[i];
    }
    if(debug!=0){ 
      printf("\nkvals[%d]: %g\n", i, kvals[i]);
    }
  }
  if(numofunvnodes<1){
    if(debug!=0){ 
      printf("\nTERMINATION (anchor) \n\n\n");
    }
  }
  return kvals;
}
