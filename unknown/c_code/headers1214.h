


#define freenodenum 990099
#define defaultobjval 1901000
#define defmin 1901.e-50
#define defmax 19.e39
#define inputvoltage 10 /* Volts */
/*#define beam_mass_factor 0.5
#define beam_slow_mf 0.5

*/
/* Velocity ratio of a 'fast' and 'slow' beam to the max. velocity
   C_fb= V_fb/V_max  <- Fast (unanchored) beam
   C_sb= V_sb/Vmax   <- Slow (anchored) beam
*/

#define C_fb 0.7
#define C_sb 0.3

/* C_fb and C_sb are the vvelocity ratios of a fast and slow beam, where:
   1>C_fb>C_Sb
*/

/* Effective Mass:
   m_eff= m_plate_mass + C_fb^2 * SUM m_fast_beam + C_sb^2 * SUM m_slow_beam

   Effective Area (for damping calc.)
   A_eff= A_plate_mass + C_fb * SUM A_fast_beam + C_sb * SUM A_slow_beam
*/

 
#define fincr 1.1
#define fdecr 0.9

/* fincr and fdecr compensate for moment.  fincr>1 while fdecr<1 and
   fdecr=1/fincr */

#define atype 0 
/* =0 for joint moment compensation (a correction factor (fincr or fdecr) is multiplies to the beam stiffness); =1 for beam moment compensation (a correction factor is multiplied to the compliance of each beam) */


/*E= 165*10^9 N/m^2 */
#define E .165 /* N/u^2 */
#define I 133.e-26 /* m^4 ; 2u x 2u cross sction */

/* Polysilicon Density: 2330 kg/m^3 */

#define areadensity 466.e-5 /* kg/m^2 ; Assumes 2u layer thickness */

#define mindisp .0001 /*minimum displacement, microns*/
#define maxlabel 100
#define pi 3.14159

#define mass_f_factor 1.0


struct Element
{
  char eltype[30];
  int elnum, numofports;
  char direction[5];
  int outmass; /* =1 if element is the output mass, 0 otherwise */

  struct Mass *massel;
  struct Beam *beamel;
  struct Joint *jointel;
  struct Anchor *anchorel;
  struct Combdrive *combel;

  int lnodes[4][4];

  int gnodes[3][4];

  /* [variable][port #] */
  /*[0]:x,X [1]:y,Y [2]:phi,PHI [3]:v */
  /*[0]:n,t,a [1]:w,r,b [2]:s,b [3]:e,l*/

  double deltay[4][4];
  double deltax[4][4];
  double theta[4][4];
  /*[0]:Fx [1]:Fy [2]:M [3]:theta */
  /*[0]:n,t,a [1]:w,r,b [2]:s,b [3]:e,l*/

  double length;
  double width;
  double beamangle;
  double ecompl; /* electrostatic compliance for combdrive */
  
  struct Node *elnodes[4];
  struct Element *attachedel[4];
  struct Element *prev_Element, *next_Element;
};


struct Node
{
  int nodenum;
  char nodetype[10];
  char vlabel[5];


  struct Element *attachedel[4];
  struct Node *attachednode[4];
  struct Element *atnodeels[4];
  /*atnodeels index: element attaching
    node of same attachednode index*/

  struct Node *next_Node;
  struct Node *prev_Node;

};


struct Mass
{
  int massnum;
  int outmass; 
  /* =1 if element is the output mass, 0 otherwise */
  int pfstat; 
  /* =1 if mass element is part of 'proof mass', 0 otherwise */
  int numofports;
  
  int lnodes[4][4];
  int gnodes[3][4];
  
  int nodex_t, nodey_t, nodephi_t, nodev_t;
  int nodeX_t, nodeY_t, nodePHI_t;

  int nodex_b, nodey_b, nodephi_b, nodev_b;
  int nodeX_b, nodeY_b, nodePHI_b;

  int nodex_r, nodey_r, nodephi_r, nodev_r;
  int nodeX_r, nodeY_r, nodePHI_r;

  int nodex_l, nodey_l, nodephi_l, nodev_l;
  int nodeX_l, nodeY_l, nodePHI_l;

  int nodex_ne, nodey_ne, nodephi_ne, nodev_ne;
  int nodeX_ne, nodeY_ne, nodePHI_ne;

  int outne;

  double width, length, area, mass;

  char labels[maxlabel];

  struct Mass *next_Mass, *prev_Mass;
  struct Element *mass_elem;
};

struct Anchor
{
  int anchornum;
  int numofports;
  int lnodes[3];

  int nodex, nodey, nodephi;
  struct Anchor *next_Anchor, *prev_Anchor;
  struct Beam *beam;
  struct Element *anchor_elem;
};

struct Beam
{
  int beamnum;
  char direction[5];

  int numofports;
  int lnodes[4][2];
  int gnodes[3][2];

  int nodex_a, nodey_a, nodephi_a, nodev_a;
  int nodeXa, nodeYa, nodePHIa;

  int nodex_b, nodey_b, nodephi_b, nodev_b;
  int nodeXb, nodeYb, nodePHIb;

  double length, width, angle, area, mass;

  char blabel[maxlabel];
  char anchorlabel[5];
  char label_a[maxlabel];
  char label_b[maxlabel];

  struct Beam *next_Beam, *prev_Beam;
  struct Anchor *anchor_a, *anchor_b;
  struct Element *beam_elem;
};


struct Joint
{
  int jointnum;

  int numofports;
  int lnodes[4][4];
  int gnodes[3][4];

  int nodex_n, nodey_n, nodephi_n, nodev_n;
  int nodeX_n, nodeY_n, nodePHI_n;

  int nodex_s, nodey_s, nodephi_s, nodev_s;
  int nodeX_s, nodeY_s, nodePHI_s;

  int nodex_e, nodey_e, nodephi_e, nodev_e;
  int nodeX_e, nodeY_e, nodePHI_e;

  int nodex_w, nodey_w, nodephi_w, nodev_w;
  int nodeX_w, nodeY_w, nodePHI_w;

  double angle;

  char labels[maxlabel];
  struct Joint *next_Joint, *prev_Joint;
  struct Beam *beam_n, *beam_s, *beam_e, *beam_w;
  struct Element *joint_elem;
};


struct Combdrive
{
  int combnum;
  int numofports;

  int lnodes[4][2];
  int gnodes[3][2];

  char direction[5];
  int nodex_s, nodey_s, nodephi_s, nodev_s;
  int nodeXs, nodeYs, nodePHIs;

  int nodex_r, nodey_r, nodephi_r, nodev_r;
  int nodeXr, nodeYr, nodePHIr;

  int rotor_fingers;
  double finger_length, finger_width, overlap;
  double gap, mass, area, compliance;

  struct Combdrive *next_Combdrive, *prev_Combdrive;
  struct Element *comb_elem;

};

int return_objs (int pc, int iter, double *f);
int Get_Objs(char* filename, double *f, int n);
void Run_SABER_DC(char* filename, int n);
void Run_SABER_AC(char* filename, double freqDC, int n);
char Find_Char(char* element, char* refer, char endchar);
int Find_Int(char* element, char* refer);
double Find_Double(char* element, char* refer,char *units);
double Find_List_Value(char* element, char* refer, char *units);
double Set_Double(double dimension, char *units);
int Calc_Objs(char* filename, double *objs);
int Test_Header(char* element);
struct Mass Add_Mass(char* element, struct Mass mass);
struct Joint Add_Joint(char* element, struct Joint joint);
struct Beam Add_Beam(char* element, struct Beam beam);
struct Anchor Add_Anchor(char* element, struct Anchor anchor);
struct Combdrive Add_Comb(char* element, struct Combdrive comb);
void Classify_Beam(struct Beam beamstruct1, struct Anchor anchorstruct1);
double InterpretAC(char* filename);
/****/

int Clean_Elements(struct Element *elem1);
struct Element *Find_Element(struct Element *elem1ptr, char *type, int number);
struct Node *Find_Node(struct Node *node1ptr, int number);
struct Node Cycle_Elements(struct Element *elem1, struct Node node1);
int Set_Node(struct Node *node, struct Element *elem);
struct Node Cycle_Nodes(struct Node node1);
void Check_Node_Tree(struct Node *node1);
double *Calc_Stiff(struct Element *elemref, double *kvals);
int Find_Numofunvnodes(struct Element *elemptr);


void Calc_Branch_Stiff(struct Element *elem1, 
		       struct Node *fromnode, double *r);


void Calc_Forces(struct Combdrive *comb1);

struct Node *Get_Outnode(struct Element *elem1);


/****/
extern int outmassnum;
extern int evallevel, atoggle;
extern long t0, t1;
extern int errorcount, warningcount;
extern char errormessage[300];
