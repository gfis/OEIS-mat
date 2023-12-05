#include <math.h>
#include <unistd.h>
#include <time.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <search.h>
#include <signal.h>

/////////////////////
// FILE readme.txt //
/////////////////////

/*
This program computes the number of ways, counted up to symmetry, to build a contiguous building with n LEGO blocks of size 2x3.
This program can deal with n<=10.

This program can be compiled with a 64 GNU C++ compiler, e.g.
  gcc version 4.9.1 (x86_64-win32-sjlj-rev2, Built by MinGW-W64 project)

Compile this program as follows
1) Store this file into an empty directory
2) With "cd", go to that directory
3) Enter the command
     g++ -o lego23.exe -O2 lego23.cpp

To compute e.g. a(4), one needs to proceed as follows:
1) With "cd", go to the directory where "lego23.exe" is located
2) Create a data directory by the command
     mkdir data
2) Start the computation with the command
     lego23 -print nfig4nbrick 4 data
   Then, the program will produce a lot of output.
   If no error occurs, in the second last line of the output a(4) is displayed.
3) The directory data is populated with a lot of files with intermediate results.
   You may remove them after the computation
4) A log file "log.txt" is produced.

For larger n, it is recommended to compute the result not with one call, but to compute intermediate results one by one.   
To interrupt a computation, press CRTL-C. Then, after a while, the computation will be saved in a file of the "data" directory.
To continue that computation, repeat the "lego23" command.

One cannot run several instances for the sme data directory in parallel, because then he common file "npos4nbrick(*)graph.dat"
would be destroyed.
   
The command
  lego23.exe -help  
gives a short introduction to this program and its usage.

The command
  lego23.exe -help make
gives a short introduction about what intermediate files exist and how they can be produced.

*/

//////////////////
// FILE accdb.h //
//////////////////

#define MY_ACCDB_H


/////////////////
// FILE elem.h //
/////////////////

#define MY_ELEM_H

#define FKT static const char *fkt=

class Str;

/* --- byte --- */

typedef unsigned char byte;

/* --- DWORD --- */

typedef unsigned int DWORD;

/* --- Nocopy --- */

class Nocopy {
  private:
  Nocopy(const Nocopy&);
  void operator=(const Nocopy&);

  public:
  Nocopy() {}
};

/* --- Performer --- */

template<class T> class Performer : public Nocopy {
  public:
  virtual ~Performer();
  virtual bool perform(const T&)=0;
};

/* --- Cond --- */

template<class T> class Cond : public Nocopy {
  public:
  virtual bool holds(const T&)=0;
};

/* --- True --- */

template<class T> class True : public Cond<T> {
  public:
  bool holds(const T&);
};

/* --- Performer4Pair --- */

// May alter the value

template<class K, class V> class Performer4Pair : public Nocopy {
  public:
  virtual bool perform(const K&, V&)=0;
};

/* --- ProcessorClosable --- */

template<class T> class PerformerClosable : public Performer<T> {
  bool open;

  protected:
  virtual bool perform4open (const T&)=0;
  virtual bool perform_close()=0;

  public:
  PerformerClosable();
  bool perform(const T&);
  bool close();
};

/* --- Counter --- */

template<class T> class Counter : public Performer<T> {
  public:
  int n;
  Counter();
  bool perform(const T&);
};


/* --- CounterPassing --- */

template<class T> class CounterPassing : public Performer<T> {
  Performer<T> &target;
  public:
  int n;
  CounterPassing(Performer<T> &target);
  bool perform(const T&);
};


template<class K, class V> class Counter4Pair : public Performer4Pair<K,V> {
  public:
  int n;
  Counter4Pair();
  bool perform(const K&, V&);
};

/* --- Storer --- */

template<class T> class Storer : public Performer<T> {
  const int size;
  int n;
  T *arr;

  public:
  Storer(T *arr, int size);
  bool perform(const T&);
};

/* --- exported functions --- */

void pl(Str);
void pl(const char*);
void pl(const char *fmt, int prm);
void pl(const char *fmt, int prm1, int prm2);
int max_int(int,int);
void add2int(int &var, int inc);
void set_int(int &var, int val);
int min_int(int,int);
int min_int(int,int, int);
int cmp_int(int,int);
int cmp_arr_int(const int*, const int*, int n);
void swap_arr_int(int*, int*, int n);
int cmp_dword(DWORD,DWORD);
int cmp_dbl(double,double);
int cmp_dbl4qsort(const void*, const void*);
int fac(int);
void set(bool *arr, int n, bool val);
bool is(const bool *arr, int n, bool val);
void inverse(const bool *arr, int n, bool *arr_inverse);
int get_i_first4val(const bool *arr, int n, bool val);
void adv(bool *arr, int n);
int get_n4val(const bool *arr, int n, bool val);
void swap(int&, int&);
void swap(bool&, bool&);
int get_i_insert(const void *arr, int n_elem, int size_elem, const void *ptr_key, int (*ptr_cmp_elem_key)(const void*, const void*));
// const char *to_nts_unsigned(double, char *buff, int size_buff);


//////////////////
// FILE graph.h //
//////////////////

#define MY_GRAPH_H


////////////////
// FILE err.h //
////////////////

#define MY_ERR_H


class Str;

extern bool expect_errstop; // For test purposes

/* --- exported functions --- */

void errstop(const char *fkt, const Str &txt);
void errstop(const char *fkt, const char *txt);
void errstop_index(const char *fkt);
void errstop_memoverflow(const char *fkt);
bool err(const char *txt, const char *prm1, const char *prm2);
bool err(const char *txt);
bool err(const char *txt, int prm1);
bool err(const char *txt, int prm1, unsigned int prm2);
bool err(Str txt);
bool err_silent(Str &out, const char *txt);
bool err_silent(Str &out, Str in);
bool err_test_fkt(const char *fkt_test, const char *fkt_tested, int i_call, const Str &errtxt);
bool err_check_failed(const char *fkt_test, int i_check);
bool got_errstop();


/////////////////
// FILE part.h //
/////////////////

#define MY_PART_H


//////////////////
// FILE brick.h //
//////////////////

#define MY_BRICK_H


#define N_BRICK_MAX 10
#define L_BRICK      3
#define W_BRICK      2
  // It must hold: L_BRICK>=W_BRICK>0

#if L_BRICK==W_BRICK
#define FOR_ALL_ROTATED(rotated, i) for (i=0, rotated=false; i<=0; ++i, rotated=true)
#else
#define FOR_ALL_ROTATED(rotated, i) for (i=0, rotated=false; i<=1; ++i, rotated=true)
#endif

#define DIM_BRICK_X4ROTATED(rotated) (rotated ? W_BRICK : L_BRICK)
#define DIM_BRICK_Y4ROTATED(rotated) (rotated ? L_BRICK : W_BRICK)

/* --- PosBrickXY --- */

struct PosBrickXY {
  int x,y;
  bool rotated;
  int get_x_max() const;
  int get_y_max() const;
  unsigned int hashind() const;
};

/* --- exported functions --- */

int cmp_lex_xy(const PosBrickXY&, const PosBrickXY&);
bool overlap(const PosBrickXY&, const PosBrickXY&);
bool operator!=(const PosBrickXY&, const PosBrickXY&);
int cmp_rotated(bool rotated_a, bool rotated_b);



/////////////////
// FILE part.h //
/////////////////

class Str;
struct Perm;
class In;

/* --- Part --- */

class Part {
  int arr_n_brick4layer[N_BRICK_MAX];
  int n_brick, n_layer;

  static bool iterate_rek(int n_brick, Part&, Performer<Part>&);

  private:
  bool iterate_perm_conform_rek(int n_brick_set, bool *arr_used, const int *arr_i_layer4brick, int *arr_i_brick, Performer<Perm>&) const;

  public:
  Part();
  bool add_layer_silent(int n_brick4layer, Str &errtxt);
  void add_layer(int n_brick4layer);
  Str to_str() const;
  int get_n_layer() const {
    return n_layer;
  }
  int get_n_brick() const {
    return n_brick;
  }
  int get_n_brick4layer(int) const;
  void clear() {
    n_brick=n_layer=0;
  }
  void get_arr_i_layer4brick(int *arr_i_layer) const;
  void get_arr_ij_brick4link(int *arr_i_brick4i_link, int *arr_j_brick4i_link, int &n_link) const;
  int get_n_perm() const;
  int get_n_link() const;
  bool iterate_perm_conform(Performer<Perm>&) const;
  void revert();
  friend int cmp(const Part&, const Part&);

  static bool iterate(int n_brick, Performer<Part>&);
};

bool read_silent(In &in, Part&, Str &errtxt);
bool read_evtl(In &in, Part&);
// bool read4file(const Str &in, int &pos, Part&, const Str &filename);
inline bool operator>(const Part &a, const Part &b) {
  return cmp(a,b)>0;
}
inline bool operator<(const Part &a, const Part &b) {
  return cmp(a,b)<0;
}


////////////////
// FILE set.h //
////////////////

// From c:\kombin\lego2\footprnt

#define MY_SET_H


#define N_ELEM4PAGE_SET 1024

/* --- Set --- */

template<class T> class Set : public Nocopy {
  struct Item {
    T t;
    Item *ptr_next;
  };
  
  struct Page {
    Item data[N_ELEM4PAGE_SET];
    Page *ptr_next;
  };

  int n, size_arr_hash, n_item_page_first;    
  Page *ptr_page_first;
  Item **arr_hash;

  private:
  void delete_page_rek(Page*);
  
  public:
  Set();
  ~Set();
  bool iterate(Performer<T>&) const;
  int get_n() const {
    return n;
  }
  void insert(const T&);
  bool contains(const T&) const;
  void clear();
  virtual unsigned int hashind(const T&) const =0;
  virtual bool equal(const T&, const T&) const =0;
};

/* --- SetInt --- */

class SetInt : public Set<int> {  
  unsigned int hashind(const int&) const;
  bool equal(const int&, const int&) const;
};


////////////////
// FILE str.h //
////////////////

// From c:\consql

#define MY_STR_H


/* --- Str --- */

class Str {
  struct Data : public Nocopy {
    int size, n_ref;
    char *s;
    Data(int size);
    ~Data();
  };
  
  Data *ptr;
  int l,start;

  public:
  Str();
  ~Str();
  void operator=(const Str&);
  void operator=(const char *nts);
  Str(const Str&);
  Str(const Str&, int start, int end);
  Str(const char *nts);
  Str(const char *data, int l);
  void operator+=(char);
  void operator+=(const char *nts);
  void operator+=(Str);
  int get_l() const {
    return l;
  }
  int get_pos_first(char) const;
  char get(int) const;
  bool print(FILE*) const;
  void dump_bin(char*) const; 
  void dump_nts(char*) const; 
  friend int cmp(const Str&, const Str&);
  friend bool operator==(Str, Str);
};

/* --- exported functions --- */

Str operator+(Str, Str);
Str str4card(int);
inline bool operator!=(Str a, Str b) {
  return !(a==b);
}
Str enquote(Str);
Str embrace(Str);


////////////////
// FILE map.h //
////////////////

// Taken from lego4

#define MY_MAP_H


#define SIZE_PAGE4MAP 0xff00

/* --- Map --- */

template<class K, class D> class Map : public Nocopy {
  private:
  struct Item {
    K k;
    D d;
    Item *ptr_next;
  };
  struct Page {
    Item arr[SIZE_PAGE4MAP/sizeof(Item)];
    Page *ptr_next;
  };

  Item **arr_ptr4hashind;
  int n, size_hash, n4page_current;
  Page *ptr_page_current;
  const int n_max4page;

  private:
  virtual unsigned int hashind(const K&) const=0;
  virtual bool equal(const K&, const K&) const=0;

  private:
  void resize_hash(int size_hash_new);
  void alloc_page();

  public:
  Map();
  ~Map();
  bool query(const K&, D&) const;
  void clear();
  bool iterate(Performer4Pair<K,D>&) const;
  bool iterate_data(Performer<D>&) const;
  void insert(const K&, const D&);
  int get_n() const {
    return n;
  }
};


///////////////////
// FILE bigint.h //
///////////////////

// From lego4

#define MY_CARD64_H


////////////////
// FILE set.h //
////////////////

// From c:\kombin\lego2\footprnt



///////////////////
// FILE bigint.h //
///////////////////

class Str;
class Card128;
class Checksummer4In;
class Checksummer4Out;
class In;

#define N_DIGIT4CARD64 20
#define N_DIGIT4INT64  (N_DIGIT4CARD64+1)
#define N_DIGIT4CARD128 39
#define N_DIGIT4INT128  (N_DIGIT4CARD128+1)

/* --- Card64 --- */

class Card64 {
  DWORD low, high;

  public:
  Card64() {}
  Card64(DWORD p_low): low(p_low), high(DWORD(0)) {}
  Card64(DWORD p_high, DWORD p_low): low(p_low), high(p_high) {}
  void operator=(DWORD);
  void operator+=(DWORD);
  void operator-=(DWORD);
  void operator+=(Card64);
  void operator|=(Card64);
  void operator&=(Card64);
  void operator-=(Card64);
  void dbl();
  void half();
  int to_int() const;
  double to_dbl() const;
  bool is_zero() const {
    return !low && !high;
  }
  bool is_odd() {
    return (low & DWORD(1))!=DWORD(0);
  }
  void operator--();
  void operator++();
  void comp(DWORD);
  unsigned int hashind() const {
    return (unsigned int) (low^high);
  }
  public:
  static const Card64 zero;
  static const Card64 one;

  public:
  friend int cmp(Card64 a, Card64 b);
  friend int cmp_card64_dword(Card64, DWORD);
  friend int cmp_card128_card64(const Card128&, const Card64&);
  friend DWORD operator&(Card64 a, DWORD b) {
    return a.low & b;
  }
  friend Card64 operator*(Card64, Card64);
  friend class Card128;
};

/* --- Card128 --- */

// Unsigned 128 bit integer.

class Card128 {
  DWORD a[4]; // The value of this Card64 is sum_(i=0..3) a[i]*2^(32*i)

  public:
  Card128() {}
  Card128(DWORD a0);
  void operator=(const Card64&);
  void operator+=(Card128);
  void operator+=(const Card64 &);
  void operator-=(const Card64 &);
  void operator-=(const Card128&);
  void dbl();
  void half();
  bool is_zero() const;
  bool is_odd() {
    return (a[0] & DWORD(1))!=DWORD(0);
  }
  void operator--();
  void comp(const Card64&);
  bool is_card64(Card64&) const;

  public:
  static const Card128 zero;

  public:
  friend int cmp(const Card128&, const Card128&);
  friend int cmp_card128_card64(const Card128&, const Card64&);
};

/* --- Int64 --- */

class Int64 {
  Card64 abs;
  int sign;

  public:
  Int64() {}
  Int64(DWORD);
  Int64(Card64);
  Int64(int sign, Card64);
  void operator+=(Int64);
  void operator-=(Int64);
  void operator+=(int);
  void operator-=(int);
  int get_sign() const {
    return sign;
  }
  bool is_zero() const {
    return sign==0;
  }
  const Card64& get_abs() const {
    return abs;
  }
  Int64 operator-() const;
  void neg() {
    sign=-sign;
  }

  public:
  static const Int64 zero;
  friend Int64 operator*(Int64, Int64);
};

/* --- Int128 --- */

class Int128 {
  Card128 abs;
  int sign;

  public:
  Int128() {}
  // Int64(DWORD);
  Int128(const Card128&);
  Int128(int sign, const Card128&);
  void operator+=(const Int128&);
  void operator+=(const Int64&);
  void operator-=(const Int64&);
  // void operator+=(int);
  // void operator-=(int);
  int get_sign() const {
    return sign;
  }
  void neg() {
    sign=-sign;
  }
  bool is_zero() const {
    return sign==0;
  }
  const Card128& get_abs() const {
    return abs;
  }
  bool is_card64(Card64&) const;

  public:
  static const Int128 zero;
};

/* --- SetCard64 --- */

class SetCard64 : public Set<Card64> {
  unsigned int hashind(const Card64&) const;
  bool equal(const Card64&, const Card64&) const;
};

/* --- Inserter4Card64 --- */

class Inserter4Card64 : public Performer<Card64> {
  Set<Card64> &set;

  bool perform(const Card64&);

  public:
  Inserter4Card64(Set<Card64>&);
};

/* --- exported functions --- */

char *to_nts(const Card64&, char *buff, int size_buff);
char *to_nts(const Int64&, char *buff, int size_buff);
char *to_nts(const Int128&, char *buff, int size_buff);
Card64 mul(DWORD, DWORD);
Int128 mul(Int64, Card64);
Card128 mul(Card64, Card64);
void divmod(Card64 nom, Card64 denom, Card64 &quot, Card64 &rem);
Card64 operator-(Card64, Card64);
Card64 operator+(Card64, Card64);
Card64 plus_not_neg(Card64, int);
Card64 operator|(Card64, Card64);
Card64 operator&(Card64, Card64);
Int64 operator+(Int64, Int64);
inline bool operator< (Card64 a, Card64 b) {return cmp(a,b)< 0;}
inline bool operator> (Card64 a, Card64 b) {return cmp(a,b)> 0;}
inline bool operator>=(Card64 a, Card64 b) {return cmp(a,b)>=0;}
inline bool operator<=(Card64 a, Card64 b) {return cmp(a,b)<=0;}
inline bool operator==(Card64 a, Card64 b) {return cmp(a,b)==0;}
inline bool operator!=(Card64 a, Card64 b) {return cmp(a,b)!=0;}
bool read(In&, Card64&);
bool read(In&, Int64& );
bool read(In&, Int128&);
bool read_silent(In&, Int64&, Str &errtxt);
bool read_silent(In&, Card64&, Str &errtxt);
bool read_silent(In&, Int128&, Str &errtxt);
bool read_silent(In&, Card128&, Str &errtxt);

/* --- test functions --- */

void test128();
void testc64();
void testi64();



//////////////////
// FILE graph.h //
//////////////////

#define OVERLAP_BRICK    1
#define NOOVERLAP_BRICK  2
#define MAYOVERLAP_BRICK 3
#define N_LINK_MAX (N_BRICK_MAX*(N_BRICK_MAX-1)/2)
  // Number of sorted pairs of bricks
#define N_BYTE4FAMGRAPH_CPR ((N_LINK_MAX/5)+(N_LINK_MAX%5 ? 1 : 0))
#define N_BYTE4GRAPH_CPR ((N_LINK_MAX/8) + (N_LINK_MAX%8 ? 1 : 0))
  // Number of bytes to store a <Famgraph> in a compressed format: 5 elements per byte, since 3^5 <= 2^8 < 3^6

class Card64;
class In;
class Out;
struct GraphFac;
class GraphCpr;

bool operator==(const GraphCpr&, const GraphCpr&);

extern const char *fkt_graph_is_linked;

/* --- Graph --- */

class Graph {
  bool data[N_BRICK_MAX][N_BRICK_MAX];

  private:
  void set_connected_to(bool *arr_connected_to, int i_brick_from) const;

  public:
  const int n_brick;
  Graph();
  Graph(int n_brick);
  void clear(int n_brick);
  void operator=(const Graph&);
  void set_linked(int i_brick, int j_brick, bool linked);
  bool set_linked_silent(int i_brick, int j_brick, bool linked, Str &errtxt);
  bool is_connected() const;
  inline bool is_linked(int i_brick, int j_brick) const {
    if (!(0<=i_brick && i_brick<n_brick && 0<=j_brick && j_brick<n_brick)) errstop_index(fkt_graph_is_linked);
    return data[i_brick][j_brick];
  }
  bool is_conform(const Part&) const;
  bool write(Out&) const;
  bool write_fast(Out&) const;
  Card64 get_i() const;
  static void get4i(Card64 i, Graph&);

  friend class FamGraph;
};

/* --- FamGraph --- */

class FamGraph {
  int data[N_BRICK_MAX][N_BRICK_MAX];

  private:
  void set_connected_to_sure (bool *arr_connected_to, int i_brick_from) const;
  void set_connected_to_maybe(bool *arr_connected_to, int i_brick_from, const int *arr_i_layer4brick) const;

  public:
  const int n_brick;
  FamGraph();
  FamGraph(int n_brick);
  void clear();
  void operator=(const FamGraph&);

  bool set_overlap_silent(int i_brick, int j_brick, int overlap, Str &errtxt);
  void set_overlap(int i_brick, int j_brick, int overlap);
  int get_overlap(int i_brick, int j_brick) const;
  bool is_conform(const Part&) const;
  void get_arr_i_comp_conn_sure(int *arr_i_comp, int &n_comp) const;
  bool write(Out&) const;
  bool write_fast(Out&) const;
  void swap_row(int i_brick, int j_brick);
  bool is_connected_sure() const;
  bool is_not_connected_sure(const int *arr_i_layer4brick) const;
  unsigned int hashind() const;
  void graph_linked_sure(Graph&) const;
  int get_n_link4overlap(int) const;
  void get4overlap(int val, int &i_brick, int &j_brick) const;
  bool query4overlap(int val, int &i_brick, int &j_brick) const;

  friend int cmp(const FamGraph&, const FamGraph&);

};

/* --- PrinterGraph --- */

class PrinterGraph : public Performer<Graph> {
  bool perform(const Graph&);
};

/* --- WriterPairGraphCprCard64 --- */

class WriterPairGraphCprCard64 : public Performer4Pair<GraphCpr, Card64> {
  Out &out;

  public:
  WriterPairGraphCprCard64(Out&);
  bool perform(const GraphCpr&, Card64&);
};

/* --- WriterFamGraph --- */

class WriterFamGraph : public Performer<FamGraph> {
  Out &out;

  public:
  WriterFamGraph(Out&);
  bool perform(const FamGraph&);
};

/* --- TransformerPairFamGraphInt64_2_GraphFac --- */

class TransformerPairFamGraphInt64_2_GraphFac : public Performer4Pair<FamGraph, Int64> {
  Performer<GraphFac> &target;

  public:
  TransformerPairFamGraphInt64_2_GraphFac(Performer<GraphFac>&);
  bool perform(const FamGraph&, Int64&);
};

/* --- WriterPairFamGraphInt64 --- */

class WriterPairFamGraphInt64 : public Performer4Pair<FamGraph, Int64> {
  Out &out;
  const bool fast;

  public:
  WriterPairFamGraphInt64(Out&, bool fast);
  bool perform(const FamGraph&, Int64&);
};

/* --- TransformerCard642Graph --- */

class TransformerCard642Graph : public Performer<Card64> {
  const int n_brick;
  Performer<Graph> &target;

  public:
  TransformerCard642Graph(int n_brick, Performer<Graph> &target);
  bool perform(const Card64&);
};

/* --- GraphFac --- */

struct GraphFac {
  Graph graph;
  Int64 fac;

  public:
  GraphFac();
  GraphFac(int n_brick);
  bool write(Out&) const;
};

/* --- FamGraphFac --- */

struct FamGraphFac {
  FamGraph fam_graph;
  int fac;

  public:
  FamGraphFac();
  FamGraphFac(int n_brick);
  bool write(Out&) const;
};

/* --- FamGraphFac64 --- */

struct FamGraphFac64 {
  FamGraph fam_graph;
  Int64 fac;

  public:
  FamGraphFac64();
  FamGraphFac64(int n_brick);
  bool write(Out&) const;
  bool write_fast(Out&) const;
};

/* --- TransformerFamGraphInt64_2_Pair --- */

class TransformerFamGraphInt64_2_Pair : public Performer4Pair<FamGraph, Int64> {
  Performer<FamGraphFac64> &target;

  public:
  TransformerFamGraphInt64_2_Pair(Performer<FamGraphFac64>&);
  bool perform(const FamGraph&, Int64&);
};

/* --- TransformerFamGraphFac2FamGraph --- */

class TransformerFamGraphFac2FamGraph : public Performer<FamGraphFac> {
  Performer<FamGraph> &target;

  public:
  TransformerFamGraphFac2FamGraph(Performer<FamGraph> &target);
  bool perform(const FamGraphFac&);
};

/* --- TransformerFamGraphFac642GraphFac --- */

class TransformerFamGraphFac642GraphFac : public Performer<FamGraphFac64> {
  Performer<GraphFac> &target;

  public:
  TransformerFamGraphFac642GraphFac(Performer<GraphFac> &target);
  bool perform(const FamGraphFac64&);
};

/* --- FamGraphCpr --- */

class FamGraphCpr {
  byte data[N_BYTE4FAMGRAPH_CPR+1];

  public:
  FamGraphCpr();
  FamGraphCpr(const FamGraph&);
  void get(FamGraph&) const;
  unsigned int hashind() const;
  int get_n_brick() const;
  int get_n_byte_used() const;
  friend bool operator==(const FamGraphCpr&, const FamGraphCpr&);
};

/* --- GraphCpr --- */

class GraphCpr {
  byte data[N_BYTE4GRAPH_CPR+1];

  public:
  GraphCpr();
  GraphCpr(const Graph&);
  void get(Graph&) const;
  unsigned int hashind() const;
  int get_n_brick() const;
  // int get_n_byte_used() const;
  friend int cmp(const GraphCpr&, const GraphCpr&);
};

/* --- SetGraphCpr --- */

class SetGraphCpr : public Set<GraphCpr> {
  public:
  inline unsigned int hashind(const GraphCpr &cpr) const {
    return cpr.hashind();
  }
  inline bool equal(const GraphCpr &a, const GraphCpr &b) const {
    return a==b;
  }
};

/* --- SetGraphCprEquiv --- */

class SetGraphCprEquiv {
  SetGraphCpr inner;

  public:
  inline bool iterate(Performer<GraphCpr> &performer) const {
    return inner.iterate(performer);
  }
  inline int get_n() const {
    return inner.get_n();
  }
  bool insert(const Graph&, Str &errtxt);
};

/* --- GraphCprFac --- */

struct GraphCprFac {
  GraphCpr graph;
  Int64 fac;

  public:
  GraphCprFac();
  GraphCprFac(int n_brick);
  GraphCprFac(const GraphFac&);
  // bool write(Out&) const;
};

/* --- Compressor4GraphFac --- */

class Compressor4GraphFac : public Performer<GraphFac> {
  Performer<GraphCprFac> &target;

  public:
  Compressor4GraphFac(Performer<GraphCprFac> &target);
  bool perform(const GraphFac&);
};

/* --- FamGraphCprFac64 --- */

struct FamGraphCprFac64 {
  FamGraphCpr fam_graph;
  Int64 fac;

  public:
  FamGraphCprFac64();
  FamGraphCprFac64(int n_brick);
  bool write(Out&) const;
  bool write_fast(Out&) const;
};

/* --- MapFamGraph2Int64 --- */

class MapFamGraph2Int64  : public Nocopy {
  struct Item {
    FamGraphCpr key;
    Int64 val;
    Item *ptr_next;
  };

  struct Page {
    Item data[1024];
    Page *ptr_next;
  };

  int n, size_arr_hash, n_item_page_first;
  Page *ptr_page_first;
  Item **arr_hash;
  bool locked;

  private:
  void delete_page_rek(Page*);
  bool iterate_no_zero_intern(Performer4Pair<FamGraph, Int64>&) const;

  public:
  MapFamGraph2Int64();
  ~MapFamGraph2Int64();
  bool iterate_no_zero(Performer4Pair<FamGraph, Int64>&) const;
  bool iterate_no_zero(Performer<FamGraphFac64>&) const;
  void add(const FamGraph &key, const Int64 &val);
  int get_n() const {
    return n;
  }
  void clear();
  int get_n_no_zero() const;
};

/* --- MapGraphCpr2Card64 --- */

class MapGraphCpr2Card64 : public Map<GraphCpr, Card64> {
  private:
  unsigned int hashind(const GraphCpr&) const;
  bool equal(const GraphCpr&, const GraphCpr&) const;
};

/* --- MapGraph2Card64 --- */

// A mapping from graphs with <n_brick> nodes to <Card64>.

class MapGraph2Card64 {
  MapGraphCpr2Card64 map4cpr;

  public:
  void clear();
  bool query(const GraphCpr&, Card64&) const;
  bool query(const Graph&, Card64&) const;
  bool contains(const Graph&) const;
  void insert(const Graph&, const Card64&);
  void insert(const GraphCpr&, const Card64&);
  bool iterate(Performer4Pair<GraphCpr,Card64>&) const;
  int get_n() const {
    return map4cpr.get_n();
  }
};

/* --- MapGraph2Int64 --- */

// A mapping from all connected graphs with <n_brick> nodes to <Int64>.

class MapGraph2Int64 : public Nocopy {
  private:
  struct Item {
    Card64 i_graph; // Index of the graph
    Int64 fac;
    bool used;
    Item();
  };

  const int n_brick;
  int size, n;
  Item *arr;

  public:
  MapGraph2Int64(int n_brick);
  ~MapGraph2Int64();
  void clear();
  void add(const Graph&, const Int64&);
  int get_n() const {
    return n;
  }
  bool iterate(Performer<GraphFac>&) const;
};

/* --- Inserter4GraphFac --- */

class Inserter4GraphFac : public Performer<GraphFac> {
  MapGraph2Int64 &map;

  public:
  Inserter4GraphFac(const MapGraph2Int64&);
  bool perform(const GraphFac&);
};

/* --- Reper4GraphFac --- */

class Reper4GraphFac : public Performer<GraphFac> {
  Performer<GraphFac> &target;

  public:
  Reper4GraphFac(const Performer<GraphFac>&);
  bool perform(const GraphFac&);
};

struct RowGraphPartial {
  int n,i_brick_origin;
  int data[N_BRICK_MAX-1];
};

/* --- Neighbourhood4Grp --- */

// Describes a neibourhood from a node to the nodes of a group

struct Neighbourhood4Grp {
  int n_overlap   ; // Number of neighours which must overlap
  int n_nooverlap ; // Number of neighours which must not overlap
  int n_mayoverlap; // Number of neighours which may or may not overlap
};

/* --- Neighbourhood --- */

// Describes the neibourhoods from a node to the nodes of a group

struct Neighbourhood {
  int i_brick_origin; // Original node number
  int i_grp; // Own group
  int n_grp; // Number of valid elements in <arr4grp>
  Neighbourhood4Grp arr4grp[N_BRICK_MAX];
};

/* --- SelectorMatLeast --- */

class SelectorMatLeast : public Performer<Perm> {
  int mat[N_BRICK_MAX][N_BRICK_MAX];

  public:
  const int n_brick;
  bool set_perm;
  int mat_perm[N_BRICK_MAX][N_BRICK_MAX], perm[N_BRICK_MAX];

  SelectorMatLeast(int n_brick, int mat[N_BRICK_MAX][N_BRICK_MAX]);
  bool perform(const Perm&);
};

/* --- exported functions --- */

bool comp_mat_rep(int mat[N_BRICK_MAX][N_BRICK_MAX], int n_brick, int mat_rep[N_BRICK_MAX][N_BRICK_MAX], int perm[N_BRICK_MAX], int &n_perm, Str &errtxt);
void narrow(const Graph&, Graph &graph_narrow, int *arr_i_brick_pred);
bool get_graph_rep(const Graph&, Graph &rep, Str &errtxt);
bool get_fam_graph_rep_fast(const FamGraph&, FamGraph &rep, int &n_perm, Str &errtxt);
bool read(In&, int n_brick, FamGraph&);
bool read_fast(In&, int n_brick, FamGraph&);
bool read_fast(In&, int n_brick, Graph&);
bool read_silent(In&, int n_brick, FamGraph&, Str &errtxt);
bool read_fast_silent(In&, int n_brick, FamGraph&, Str &errtxt);
bool read_fast_silent(In&, int n_brick, Graph&, Str &errtxt);
bool read_evtl(const Str &in, int &pos, int n_brick, FamGraph&);
bool read_silent(In &in, int n_brick, Graph&, Str &errtxt);
bool read(In&, int n_brick, Graph&);
bool iterate_connected(int n_brick, Performer<Graph>&);
bool read(In&, int n_brick, GraphFac&);
bool read(In&, int n_brick, FamGraphFac&);
bool read(In&, int n_brick, FamGraphFac64&);
bool read_fast(In&, int n_brick, FamGraphFac64&);
bool read_fast(In&, int n_brick, FamGraphCprFac64&);
bool compatible(int, int);
int cmp(const RowGraphPartial&, const RowGraphPartial&);
int cmp(const Neighbourhood4Grp&, const Neighbourhood4Grp&);
int cmp_fam_graph644qsort(const void*, const void*);
int cmp_row_partial4qsort(const void*, const void*);
int cmp(const FamGraphCpr&, const FamGraphCpr&);
int cmp_graph_cpr4qsort(const void*, const void*);
int get_n_graph_conn4n_brick(int);
inline bool operator==(const GraphCpr &a, const GraphCpr &b) {
  return cmp(a,b)==0;
}
inline bool operator!=(const GraphCpr &a, const GraphCpr &b) {
  return cmp(a,b)!=0;
}
inline bool operator==(const FamGraph &a, const FamGraph &b) {
  return cmp(a,b)==0;
}
inline bool operator>(const FamGraph &a, const FamGraph &b) {
  return cmp(a,b)>0;
}
inline bool operator>=(const FamGraph &a, const FamGraph &b) {
  return cmp(a,b)>=0;
}
inline bool operator!=(const FamGraph &a, const FamGraph &b) {
  return cmp(a,b)!=0;
}


////////////////
// FILE lst.h //
////////////////

// From kombin/dodeka

#define MY_LST_H


/* --- Lst --- */

template<class T> class Lst : public Nocopy {
  private:
  int size, n;
  T *arr;

  public:
  Lst() : size(0), n(0), arr(0) {}
  ~Lst() {
    clear();
  }

  void append(const T&);
  void clear();

  T get(int) const;
  int get_n() const {
    return n;
  }
};

/* --- Appender --- */

template<class T> class Appender : public Performer<T> {
  Lst<T> &lst;

  public:
  Appender(Lst<T>&);
  bool perform(const T&);
};


////////////////
// FILE str.h //
////////////////

// From c:\consql



//////////////////
// FILE accdb.h //
//////////////////

#define TIMEOUT_ACCESS2DB_MS 1000

class In;
class Checksummer4Out;

/* --- Access2Db --- */

// provides synchronized access to the database wich contains the number of solutions for each graph.

class Access2Db {
  const int n_brick;
  MapGraph2Card64 map; // Assigns the number of solutions for each computed graph
  Lst<GraphCpr> lst_graph_new; // The graphs which are new since the last load
  bool opened;
  const Str path_dir;

  private:
  // const char *get_name4mutex_db(int n_brick, char *buff);
  bool save_changes();
  bool save_map(Checksummer4Out&) const;
  bool save_map() const;
  bool load_map();
  bool insert2map(In&);

  public:
  Access2Db(const Str &path_dir, int n_brick);
  ~Access2Db();
  bool open();
  bool commit();
  void rollback();
  bool query(const Graph &graph, Card64 &val);
  void insert(const Graph &graph, const Card64 &val);
  Str get_path() const;
  Str get_filename() const;
};



/////////////////////
// FILE fileutil.h //
/////////////////////

#define MY_FILEUTIL_H


class Str;

/* --- exported fields --- */

extern const Str sep_path;

/* --- exported functions --- */

bool exists_file(Str filename);
bool load_file_txt(Str filename, Str &content);
bool open_file_txt_write(Str filename, FILE *&);
bool remove_file(Str filename);
bool open_file(const Str &path, const char *mode, FILE*&);


/////////////////
// FILE read.h //
/////////////////

#define MY_READ_H


///////////////////
// FILE bigint.h //
///////////////////

// From lego4


////////////////
// FILE str.h //
////////////////

// From c:\consql



/////////////////
// FILE read.h //
/////////////////

#define SIZE_BUFF_IN 128 /* Must be a power of 2 */

/* --- In --- */

class In : public Nocopy {

  private:

  public:
  virtual ~In();
  bool read_str_given_silent(const Str &given, Str &errtxt);
  bool read_str_given(const Str &given);
  bool read_card(int&);
  bool read_evtl_card(int&);
  bool read_unsigned(double&);
  bool read_unsigned_silent(double&, Str &errtxt);
  bool read_card_silent(int&, Str &errtxt);
  bool read_int(int&);
  bool read_eoln_silent(Str &errtxt);
  bool read_eoln();
  bool read_evtl_char_given(char given);
  bool read_char_given(char given);
  bool read_char_given_silent(char given, Str &errtxt);
  bool err_at(const char *txt) const;
  bool err_at(Str) const;
  virtual bool operator++()=0;
  virtual char operator*()=0;
  virtual const Card64& get_pos() const=0;
  virtual bool at_end() const =0;
  virtual bool err_at(Str txt, Card64 pos) const=0;
  virtual bool err_at(Str txt, int i_line, int i_col) const=0;
};

/* --- InBuffered --- */

class InBuffered : public In {

  // pure virtuals
  public:
  virtual void set_pos(const Card64&) =0;
  // virtual bool err_at(const Str&, const Card64 &pos_err) const =0;
  // virtual int get_i_line(const Card64 &pos) const=0;
  // virtual int get_i_col (const Card64 &pos) const=0;

  public:
  virtual ~InBuffered();
  bool read_evtl_str_given(const Str &given);
  bool err_at(const char *txt, const Card64 &pos_err) const;
};

/* --- InBuffering --- */

class InBuffering : public InBuffered {
  In &in;
  Card64 pos, pos_max;
  char buff[SIZE_BUFF_IN];
  int arr_i_line[SIZE_BUFF_IN], arr_i_col[SIZE_BUFF_IN];
  bool arr_at_end[SIZE_BUFF_IN];
  int i_line, i_col;

  public:
  InBuffering(In&);
  void set_pos(const Card64&);
  bool operator++();
  char operator*();
  bool at_end() const;
  const Card64& get_pos() const;
  int get_i_line(Card64 pos) const;
  int get_i_col (Card64 pos) const;
  bool err_at(Str txt, Card64 pos) const;
  bool err_at(Str txt, int i_line, int i_col) const;
};

/* --- In4Str --- */

class In4Str : public InBuffered {
  Str data;
  Card64 pos,l;

  public:
  In4Str(const Str&);
  In4Str(const char *nts);
  const Card64 &get_pos() const;
  void set_pos(const Card64&);
  char operator*();
  bool at_end() const;
  bool operator++();
  bool err_at_current(const char *txt) const;
  bool err_at_current(const Str&) const;
  bool err_at(Str txt, Card64 pos) const;
  bool err_at(Str txt, int i_line, int i_col) const;
};

/* --- In4File --- */

class In4File : public In {
  // int buff_i_line[SIZE_BUFF_IN], buff_i_col[SIZE_BUFF_IN]/*, buff_c[SIZE_BUFF_IN]*/;
    // Contains line and column indices and characters for charaters with index i = <n_advanced-SIZE_BUFF_IN>...<n_advanced-1>
    // line and column indices of i is stored in buff[i&(SIZE_BUFF_IN-1)]
  Card64 n_advanced; // Number of getc-calls
  Card64 pos; // Current read position
  // int i_line, i_col;
  int c; // Current character, or -1 if at end of file
  FILE *f;
  Str path;

  public:
  In4File();
  bool open(Str path);
  bool close();
  const Card64 &get_pos() const;
  char operator*();
  bool at_end() const;
  bool operator++();
  bool err_at(Str txt, Card64 pos) const;
  bool err_at(Str txt, int i_line, int i_col) const;
};

/* --- ProcessorIn --- */

class ProcessorIn {
  public:
  virtual bool process(In&) const=0;
};


/////////////////
// FILE comp.h //
/////////////////

#define MY_COMP_H


////////////////
// FILE lst.h //
////////////////

// From kombin/dodeka


////////////////
// FILE ptr.h //
////////////////

// From kombin/dodeka

#define MY_PTR_H

template<class T> class Pt {
  int *ptr_n_ref; // Referenzzaehler
  T *ptr_native; // Zeiger auf Daten 

  public:
  Pt() : ptr_n_ref(0), ptr_native(0) {}
  Pt(const Pt&);
  Pt(T *newed_or_null); 
  Pt(T *ptr_native, int *ptr_n_ref);
  void operator=(const Pt&);
  ~Pt();

  T* get_pt_native() const {
    return ptr_native;
  }
  int *get_pt_n_ref() const {
    return ptr_n_ref;
  }
  T& operator*() const;
  T* operator->() const;
  bool is_null() const {
    return ptr_native==0;
  }
};

/* --- exported functions --- */

template<class D, class B> void convert(Pt<D>, Pt<B>&);


////////////////
// FILE str.h //
////////////////

// From c:\consql



/////////////////
// FILE comp.h //
/////////////////

class InBuffered;
class Out;
class ProcessorIn;
class In4File;


/* --- Comp --- */

class Comp : public Nocopy {
  bool complete, prepared, inited;

  private:
  Str get_path4work() const;
  bool prepare(bool &stopped); // Makes sure all needed file are computed

  public:
  const Str path_dir;

  protected:
  bool set_complete();

  protected:
  virtual bool init_work()=0;
  virtual bool run4prepared_inited()=0;
  virtual bool load_work  (InBuffered&)=0;
  virtual bool load_result(InBuffered&)=0;
  virtual bool save_work  (Out&) const=0;
  virtual bool save_result(Out&) const=0;
  virtual bool setup_lst_comp_prepare(Lst<Pt<Comp> > &lst) const=0;

  public:
  virtual Str get_filename4result() const=0;
  virtual Str get_filename4work() const=0;
    // puts filenames of all computations into <lst> which are required for <this> computation.
    // On entry, <lst> is empty

  public:
  Comp(const Str &path_dir);
  virtual ~Comp();
  Str get_path4filename(Str filename) const;
  bool check_stopped();
  bool add_fileclause();
  bool run(); 
    // Performs the computation. 
    // Returns false on error
    // If the computation was interrupted, <true> is returned, and <is_complete> will return false.
    // If the computation was performed, <true> is returned, and <is_complete> will return <true>.
  bool delet(); 
    // Deletes this computation. The computation must be complete.
  bool is_complete() const {
    return complete;
  }
  bool is_result_computed() const;
  Str get_path4result() const;
  // bool process_file_result_inner(ProcessorIn&) const;
  bool open_file_result4inner(In4File&, unsigned int &chksum) const;
  bool close_file_result4inner(In4File&, unsigned int chksum) const;

  public:
  static bool read_fileclause (InBuffered&, Str filename);
  static bool write_fileclause(Out&, Str filename);
};

typedef Pt<Comp> PtComp;


/////////////////
// FILE main.h //
/////////////////

#define MY_MAIN_H


#define LOGPERIOD_DEFAULT 60
#define N_HEX4LINE_DB     80
  // Default log perion, in seconds

struct Perm;

extern bool signalled_stop;
extern int n_step_max;
extern int logperiod;
  // The progress is logged each <logperiond> seconds

/* --- PrinterPerm --- */

class PrinterPerm : public Performer<Perm> {
  public:
  bool perform(const Perm&);
};

/* --- LoggerPerm --- */

class LoggerPerm : public Performer<Perm> {
  public:
  bool perform(const Perm&);
};


////////////////
// FILE log.h //
////////////////

#define MY_LOG_H


//////////////////
// FILE write.h //
//////////////////

#define MY_WRITE_H


////////////////
// FILE str.h //
////////////////

// From c:\consql



//////////////////
// FILE write.h //
//////////////////

class Int64;
class Card64;

/* --- Out --- */

class Out : public Nocopy {

  private:
  bool print2dollar(const char *txt, int &pos);
  bool print2end(const char *txt, int &pos);

  public:
  bool print_uint(unsigned int);
  bool print_int(int);
  bool print_udbl(double);
  bool print_nts(const char *txt);
  bool print_eoln();
  bool print(Str);
  bool printf(const char *txt);
  bool printf(const char *txt, int prm);
  bool printf(const char *txt, const Int64&);
  bool printf(const char *txt, Str);
  bool printf(const char *txt, Str, int);
  bool printf(const char *txt, Str, const Card64&);
  bool printf(const char *txt, Str, Str, int);
  bool printf(const char *txt, Str, Str, Str, int);
  bool printf(const char *txt, Str, Str, Str, Str);
  bool printf(const char *txt, Str, Str, Str, Str, int);
  bool printf(const char *txt, Str, Str);
  bool printf(const char *txt, Str, Str, Str);
  bool printf(const char *txt, const char *prm);
  bool printf(const char *txt, int prm1, int prm2, const char *prm3);
  bool printf(const char *txt, const Card64 &prm1, const Card64 &prm2, const char *prm3);
  bool printf(const char *txt, int prm1, int prm2);
  bool printf(const char *txt, int prm1, char prm2, int prm3);
  bool printf(const char *txt, int prm1, int prm2, int prm3, int prm4);
  bool printf(const char *txt, int prm1, int prm2, int prm3, int prm4, int prm5);

  virtual bool print_char(char)=0;
  virtual bool err_write()=0;
};

/* --- Stdout --- */

class Stdout : public Out {
  public:
  bool print_char(char);
  bool err_write();

  static Stdout instance;
};

/* --- Out4File --- */

class Out4File : public Out {
  FILE *f;
  Str path;

  public:
  Out4File();
  ~Out4File();
  bool print_char(char);
  bool err_write();
  bool open(Str path);
  bool close();
};



////////////////
// FILE log.h //
////////////////

class Str;
class Card64;

#define NAME_LOGFILE "log.txt"

/* --- Logger --- */

class Logger : public Out {
  FILE *f;
  bool opened;

  public:
  Logger();
  void open();
  void close();
  bool print_char(char);
  bool err_write();
};

/* --- exported functions --- */

void log(const char *txt);
void log(Str);
void log(const char *txt, Str prm);
void log(const char *txt, Str prm1, Card64 prm2);
void log(const char *txt, Str prm1, Str prm2);
void log(const char *txt, Str prm1, Str prm2, int prm3);
void log(const char *txt, Str prm1, Str prm2, Str prm3);
void log(const char *txt, Str prm1, Str prm2, Str prm3, Str prm4);
void log(const char *txt, Str prm1, Str prm2, Str prm3, int prm4);
void log(const char *txt, Str prm1, Str prm2, Str prm3, Str prm4, int prm5);
void log(const char *txt, int prm1, int prm2);
void log(const char *txt, int prm1, int prm2, int prm3, int prm4);
void log(const char *txt, int prm1, int prm2, int prm3, int prm4, int prm5);
void log(const char *txt, int prm);
void log(const char *txt, int prm1, int prm2, const char *prm3);
void log(const char *txt, const Card64 &prm1, const Card64 &prm2, const char *prm3);
void log(const char *txt, Str prm1, int prm2);
void log(const char *txt, const char *prm);
void log(const char *txt, const char *prm1, int prm2);
void log_progress(const char *txt, int n_done, int n_todo);
void log_progress(const char *txt, const Card64 &n_done, const Card64 &n_todo);
void log_progress_imm(const char *txt, const Card64 &n_done, const Card64 &n_todo);
void log_progress(const char *txt, Str prm1, const char *prm2);
void log_progress_start();
void log_progress_end();
void log_progress_start(const char *msg);
void log_progress_start(const char *msg, Str prm);
void log_progress_end(const char *msg);
void log_progress_end(const char *msg, Str prm1, int prm2);
void log_progress_end(const char *msg, int prm);
void log_progress_end(const char *msg, Str prm);


///////////////////
// FILE chksum.h //
///////////////////

#define MY_CHKSUM_H


///////////////////
// FILE bigint.h //
///////////////////

// From lego4



///////////////////
// FILE chksum.h //
///////////////////

class Str;

/* --- Chksummer --- */

class Chksummer {
  unsigned int chksum;

  public:
  Chksummer();
  Chksummer(unsigned int chksum);
  void process(char);
  int get_chksum_masked() const;
  inline unsigned int get_chksum() const {
    return chksum;
  }
};

/* --- Chksummer4In --- */

class Chksummer4In : public InBuffered {
  Chksummer chksummer;
  InBuffered &in;
  Card64 pos; // Current read position
  Card64 pos_max; // <chksummer> contains the checksum of position <pos_max>
  unsigned int arr_chksum[SIZE_BUFF_IN]; 
    // The size of this array bust be a power ot 
    // arr_chksum[p%n] = checksum at position p for max(0, pos_max-n+1)<=p<=pos,
    // and n is the number of elements in arr_chksum

  private:
  int get_next();

  public:
  Chksummer4In(InBuffered&);
  Chksummer4In(InBuffered&, unsigned int chksum_start);
  int get_chksum_masked() const {
    return chksummer.get_chksum_masked();
  }
  bool read_chksum();
  const Card64 &get_pos() const;
  void set_pos(const Card64&);
  char operator*();
  bool at_end() const;
  bool operator++();
  bool err_at(Str txt, Card64 pos) const;
  bool err_at(Str txt, int i_line, int i_col) const;
  unsigned int get_chksum() const;
};

/* --- Checksummer4Out --- */

class Checksummer4Out : public Out {
  Chksummer chksummer;
  Out &out;

  public:
  Checksummer4Out(Out&);
  bool write_chksum();
  bool print_char(char);
  bool err_write();
};


////////////////////
// FILE lstimpl.h //
////////////////////

#define MY_LSTIMPL_H


////////////////
// FILE lst.h //
////////////////

// From kombin/dodeka



////////////////////
// FILE lstimpl.h //
////////////////////

/* === Lst =============================================================== */

/* --- get --- */

template<class T> T Lst<T>::get(int i) const {
  FKT "Lst<T>::get";
  if (!(0<=i && i<n)) errstop_index(fkt);
  return arr[i];
}

/* --- clear --- */

template<class T> void Lst<T>::clear() {
  if (arr) {
    delete[] arr;
    arr=0;
  }
  n=size=0;
}

/* --- append --- */

template<class T> void Lst<T>::append(const T &t) {
  FKT "Lst<T>::append(T)";

  // Enlarge <arr>, if necesary
  if (n>=size) {
    T *arr_old = arr;
    int i;

    size = 3*n/2+10;
    arr = new T[size];
    if (arr==0) errstop(fkt, "Memory overflow");
    for (i=0; i<n; ++i) arr[i]=arr_old[i];
    if (arr_old) delete[] arr_old;
  }

  arr[n]=t;
  ++n;
}


/* === Appender ========================================================== */

/* --- constructor --- */

template<class T> Appender<T>::Appender(Lst<T> &p_lst) : lst(p_lst) {}

/* --- perform --- */

template<class T> bool Appender<T>::perform(const T &t) {
  lst.append(t);
  return true;
}



////////////////////
// FILE mapimpl.h //
////////////////////

// Taken fron lego4

#define MY_MAPIMPL_H


////////////////
// FILE map.h //
////////////////

// Taken from lego4




////////////////////
// FILE mapimpl.h //
////////////////////

/* === Map =============================================================== */

/* --- Constructor --- */

template<class K, class D> Map<K,D>::Map() : arr_ptr4hashind(0), n(0), size_hash(0), ptr_page_current(0), n_max4page(SIZE_PAGE4MAP/sizeof(Item)) {}

/* --- Destructor --- */

template<class K, class D> Map<K,D>::~Map() {
  if (arr_ptr4hashind) delete[] arr_ptr4hashind;

  Page *ptr_page = ptr_page_current;
  while (ptr_page) {
    Page *ptr_page_next = ptr_page->ptr_next;
    delete ptr_page;
    ptr_page = ptr_page_next;
  }
}

/* --- clear --- */

template<class K, class D> void Map<K,D>::clear() {
  if (arr_ptr4hashind) {
    delete[] arr_ptr4hashind;
    arr_ptr4hashind=0;
  }

  Page *ptr_page = ptr_page_current;
  while (ptr_page) {
    Page *ptr_page_next = ptr_page->ptr_next;
    delete ptr_page;
    ptr_page = ptr_page_next;
  }

  ptr_page_current=0;

  n = size_hash = 0;
}

/* --- query --- */

template<class K, class D> bool Map<K,D>::query(const K &k, D &d) const {
  if (size_hash==0) return false;

  int i = int(hashind(k)%(unsigned int)size_hash);
  Item *ptr_item = arr_ptr4hashind[i];
  while (ptr_item) {
    if (equal(ptr_item->k,k)) {
      d = ptr_item->d;
      return true;
    }
    ptr_item = ptr_item->ptr_next;
  }
  return false;
}

/* --- resize_hash --- */

template<class K, class D> void Map<K,D>::resize_hash(int size_hash_new) {

  // Backup old array and create new one
  int size_hash_old = size_hash;
  Item **arr_old = arr_ptr4hashind;
  size_hash = size_hash_new;
  arr_ptr4hashind = new Item*[size_hash];

  // Initialize new array
  int i;
  for (i=0; i<size_hash; ++i) arr_ptr4hashind[i] = 0;

  // Populate new array from old one
  int i_old;
  for (i_old=0; i_old<size_hash_old; ++i_old) {
    Item *ptr_item=arr_old[i_old], *ptr_item_next;
    while (ptr_item) {

      // Put the new element in from of the linked list
      i = int(hashind(ptr_item->k)%(unsigned int)size_hash);
      ptr_item_next=ptr_item->ptr_next;
      ptr_item->ptr_next = arr_ptr4hashind[i];
      arr_ptr4hashind[i] = ptr_item;
      ptr_item=ptr_item_next;
    }
  }

  // Drop old array
  if (arr_old) delete[] arr_old;
}

/* --- alloc_page --- */

template<class K, class D> void Map<K,D>::alloc_page() {
  Page *ptr_page_new = new Page();
  ptr_page_new->ptr_next = ptr_page_current;
  ptr_page_current = ptr_page_new;
  n4page_current=0;
}

/* --- insert --- */

template<class K, class D> void Map<K,D>::insert(const K &k, const D &d) {
  if (n+1>2*size_hash) resize_hash(n+10);
  if (ptr_page_current==0 || n4page_current>=n_max4page) alloc_page();

  Item &item = ptr_page_current->arr[n4page_current]; // The new entry will go here
  item.k = k;
  item.d = d;
  ++n4page_current;

  // Put the new element in from of the linked list
  int i = int(hashind(k)%(unsigned int)size_hash);
  item.ptr_next = arr_ptr4hashind[i];
  arr_ptr4hashind[i] = &item;

  ++n;
}

/* --- iterate_data --- */

template<class K, class D> bool Map<K,D>::iterate_data(Performer<D> &performer) const {
  if (ptr_page_current==0) return true;

  // First page
  int i;
  Item *data_page = ptr_page_current->arr;
  for (i=0; i<n4page_current; ++i) {
    Item &item = data_page[i];
    if (!performer.perform(item.d)) return false;
  }

  // Subsequent pages
  Page *ptr_page = ptr_page_current->ptr_next;
  while (ptr_page!=0) {
    Item *data_page = ptr_page->arr;
    for (i=0; i<int(SIZE_PAGE4MAP/sizeof(Item)); ++i) {
      Item &item = data_page[i];
      if (!performer.perform(item.d)) return false;
    }
    ptr_page = ptr_page->ptr_next;
  }

  return true;
}

/* --- iterate --- */

template<class K, class D> bool Map<K,D>::iterate(Performer4Pair<K,D> &performer) const {
  if (ptr_page_current==0) return true;

  // First page
  int i;
  Item *data_page = ptr_page_current->arr;
  for (i=0; i<n4page_current; ++i) {
    Item &item = data_page[i];
    if (!performer.perform(item.k, item.d)) return false;
  }

  // Subsequent pages
  Page *ptr_page = ptr_page_current->ptr_next;
  while (ptr_page!=0) {
    Item *data_page = ptr_page->arr;
    for (i=0; i<SIZE_PAGE4MAP/(int)sizeof(Item); ++i) {
      Item &item = data_page[i];
      if (!performer.perform(item.k, item.d)) return false;
    }
    ptr_page = ptr_page->ptr_next;
  }

  return true;
}


//////////////////
// FILE const.h //
//////////////////

#define MY_CONST_H

class Str;

extern const Str c_end_filename_result, c_end_filename_work, c_nlinkmax, c_n_eq, c_ntodo_eq, c_ndone_eq, c_block;



////////////////////
// FILE accdb.cpp //
////////////////////

/* === Access2Db ========================================================= */

/* --- insert2map --- */

bool Access2Db::insert2map(In &in) {

  int n;
  if (!(in.read_str_given(c_n_eq) && in.read_card(n) && in.read_eoln())) return false;

  int i;
  for (i=0; i<n; ++i) {
    Card64 fac;
    Graph graph;

    if (!(read(in, n_brick, graph) && in.read_char_given(':') && in.read_char_given(' ') && read(in, fac) && in.read_eoln())) return false;
    map.insert(graph, fac);
  }

  return true;
}

/* --- get_filename --- */

Str Access2Db::get_filename() const {
  static const Str s_start("npos4nbrick"), s_end("graph.dat");
  return s_start + embrace(str4card(n_brick)) + s_end;
}

/* --- get_path --- */

Str Access2Db::get_path() const {
  return path_dir + sep_path + get_filename();
}

/* --- load_map --- */

bool Access2Db::load_map() {
  map.clear();

  // Does database exist? if not, keep map empty
  Str path = get_path();
  if (!exists_file(path)) {
    return true;
  }

  // Open file
  In4File in4file;
  if (!in4file.open(path)) return false;

  // Open input
  InBuffering in_buffered(in4file);
  Chksummer4In chksummer(in_buffered);

  // read file clause
  if (!Comp::read_fileclause(chksummer, get_filename())) return false;

  // Load database from input stream
  if (!insert2map(chksummer)) {
    in4file.close();
    return false;
  }

  // read checksum
  if (!chksummer.read_chksum()) {
    in4file.close();
    return false;
  }

  // Close file
  if (!in4file.close()) return false;

  return true;
}

/* --- constructor --- */

Access2Db::Access2Db(const Str &p_path_dir, int p_n_brick) : n_brick(p_n_brick), opened(false), path_dir(p_path_dir) {
  FKT "Access2Db::Access2Db";

  if (!(0<=n_brick && n_brick<=N_BRICK_MAX)) errstop_index(fkt);
}

/* --- save_map --- */

bool Access2Db::save_map() const {

  Out4File out4file;
  if (!out4file.open(get_path())) return false;

  Checksummer4Out out(out4file);
  bool ok = save_map(out);
  if (!out4file.close()) return false;

  return ok;
}

/* --- save_map(Checksummer4Out) --- */

bool Access2Db::save_map(Checksummer4Out &out) const {

  if (!Comp::write_fileclause(out, get_filename())) return false;
  if (!out.printf("n=$\n", map.get_n())) return false;

  WriterPairGraphCprCard64 writer(out);
  if (!map.iterate(writer)) return false;

  if (!out.write_chksum()) return false;
  return true;
}

/* --- save_changes --- */

// Adds new graphs to the current database

bool Access2Db::save_changes() {
  FKT "Access2Db::save_changes";

  // Get number of solutions for new graphs
  Lst<Card64> lst_val;
  int n = lst_graph_new.get_n(), i;
  for (i=0; i<n; ++i) {
    Card64 val;
    GraphCpr cpr = lst_graph_new.get(i);

    if (!map.query(cpr, val)) errstop(fkt, "!map.query()");
    lst_val.append(val);
  }

  // Reload map
  if (!load_map()) return false;

  // Insert new values
  for (i=0; i<n; ++i) {
    Card64 val = lst_val.get(i);
    GraphCpr cpr = lst_graph_new.get(i);
    map.insert(cpr,val);
  }

  // Save
  if (!save_map()) return false;

  return true;
}


/* --- open --- */

bool Access2Db::open() {
  FKT "Access2Db::open";

  if (opened) errstop(fkt, "opened");

  bool ok;
  ok=load_map();

  lst_graph_new.clear();

  opened=ok;
  return ok;
}

/* --- commit --- */

bool Access2Db::commit() {
  if (!opened) return true;

  if (lst_graph_new.get_n()==0) {
    opened=false;
    return true;
  }

  bool ok;
  ok=save_changes();

  map.clear();
  lst_graph_new.clear();

  opened=false;
  return ok;
}

/* --- rollback --- */

void Access2Db::rollback() {
  if (!opened) return;
  map.clear();
  lst_graph_new.clear();
  opened=false;
}

/* --- destructor --- */

Access2Db::~Access2Db() {
  if (opened) rollback();
}

/* --- insert --- */

void Access2Db::insert(const Graph &graph, const Card64 &val) {
  FKT "Access2Db::insert";

  if (!opened) errstop(fkt, "!opened");
  if (map.contains(graph)) return;

  map.insert(graph, val);
  lst_graph_new.append(graph);
}

/* --- query --- */

bool Access2Db::query(const Graph &graph, Card64 &val) {
  FKT "Access2Db::query";

  if (!opened) errstop(fkt, "!opened");
  return map.query(graph, val);
}



///////////////////
// FILE bigint.h //
///////////////////

// From lego4


////////////////
// FILE str.h //
////////////////

// From c:\consql


////////////////////
// FILE setimpl.h //
////////////////////

// From c:\kombin\lego2\footprnt

#define MY_SETIMPL_H


////////////////
// FILE set.h //
////////////////

// From c:\kombin\lego2\footprnt



////////////////////
// FILE setimpl.h //
////////////////////

/* === Set =============================================================== */

/* --- conctructor --- */

template<class T> Set<T>::Set() : n(0), size_arr_hash(0), n_item_page_first(0), ptr_page_first(0), arr_hash(0) {}

/* --- desctructor --- */

template<class T> Set<T>::~Set() {
  clear();
}

/* --- contains --- */

template<class T> bool Set<T>::contains(const T &t) const {
  if (size_arr_hash==0) return false;

  int i = int(hashind(t)%(unsigned int)size_arr_hash);
  Item *ptr_item = arr_hash[i];
  while (ptr_item!=0) {
    if (equal(t, ptr_item->t)) return true;
    ptr_item=ptr_item->ptr_next;
  }

  return false;
}

/* --- insert --- */

template<class T> void Set<T>::insert(const T &t) {
  static const char *fkt="Set<T>::insert";

  // Seek element; if found, do not insert
  int i;
  if (size_arr_hash>0) {
    i = int(hashind(t)%(unsigned int)size_arr_hash);
    Item *ptr_item = arr_hash[i];
    while (ptr_item!=0) {
      if (equal(t, ptr_item->t)) return;
      ptr_item=ptr_item->ptr_next;
    }
  }

  // Resize hash array, if necessary
  if (4*n>=3*size_arr_hash) {
    int size_arr_hash_old = size_arr_hash;
    Item **arr_hash_old = arr_hash;

    int i_new;
    size_arr_hash = 5*n/3+11;
    arr_hash = new Item*[size_arr_hash];
    if (arr_hash==0) errstop(fkt, "Memory overflow");
    for (i_new=0; i_new<size_arr_hash; ++i_new) arr_hash[i_new]=0;

    int i_old;
    for (i_old=0; i_old<size_arr_hash_old; ++i_old) {
      Item *ptr_item = arr_hash_old[i_old];
      while (ptr_item!=0) {
        Item &item = *ptr_item;
        Item *ptr_item_next = item.ptr_next;

        int i_new = int(hashind(item.t)%(unsigned int)size_arr_hash);
        item.ptr_next = arr_hash[i_new];
        arr_hash[i_new] = ptr_item;
        ptr_item = ptr_item_next;
      }
    }

    if (arr_hash_old!=0) delete[] arr_hash_old;
  }

  // Get new page, if necessary
  if (ptr_page_first==0 || n_item_page_first==N_ELEM4PAGE_SET) {
    Page *ptr_page_new = new Page();
    ptr_page_new->ptr_next = ptr_page_first;
    ptr_page_first = ptr_page_new;
    n_item_page_first=0;
  }

  // Alloc item
  Item &item_new = ptr_page_first->data[n_item_page_first];
  ++n_item_page_first;
  ++n;

  // Put data into item
  item_new.t = t;

  // link element into hash table
  i = int(hashind(t)%(unsigned int)size_arr_hash);
  item_new.ptr_next = arr_hash[i];
  arr_hash[i] = &item_new;
}

/* --- iterate --- */

template<class T> bool Set<T>::iterate(Performer<T> &performer) const {
  if (ptr_page_first==0) return true;

  // First page
  int i;
  Item *data_page = ptr_page_first->data;
  for (i=0; i<n_item_page_first; ++i) {
    if (!performer.perform(data_page[i].t)) return false;
  }

  // Subsequent pages
  Page *ptr_page = ptr_page_first->ptr_next;
  while (ptr_page!=0) {
    Item *data_page = ptr_page->data;
    for (i=0; i<N_ELEM4PAGE_SET; ++i) {
      if (!performer.perform(data_page[i].t)) return false;
    }
    ptr_page = ptr_page->ptr_next;
  }

  return true;
}

/* --- clear --- */

template<class T> void Set<T>::clear() {
  if (arr_hash!=0) delete[] arr_hash;
  size_arr_hash=0;
  arr_hash=0;

  Page *ptr_page=ptr_page_first;
  while (ptr_page!=0) {
    Page *ptr_page_next = ptr_page->ptr_next;
    delete ptr_page;
    ptr_page = ptr_page_next;
  }
  n_item_page_first=0;
  ptr_page_first=0;

  n=0;
}


/////////////////////
// FILE elemimpl.h //
/////////////////////

#define MY_ELEMIMPL_H



/* === Performer ======================================================== */

template<class T>  Performer<T>::~Performer() {}


/* === PerformerClosable ================================================ */

/* --- constructor --- */

template<class T> PerformerClosable<T>::PerformerClosable() : open(true) {}

/* --- close --- */

template<class T> bool PerformerClosable<T>::close() {
  static char *fkt="PerformerClosable<T>::close";
  if (!open) errstop(fkt, "!open");
  if (!perform_close()) return false;
  open=false;
  return true;
}

/* --- perform --- */

template<class T> bool PerformerClosable<T>::perform(const T &t) {
  static char *fkt="PerformerClosable<T>::perform";
  if (!open) errstop(fkt, "!open");
  if (!perform4open(t)) return false;
  return true;
}


/* === Counter =========================================================== */

/* --- constructor --- */

template<class T> Counter<T>::Counter() : n(0) {}

/* --- perform --- */

template<class T> bool Counter<T>::perform(const T&) {
  ++n;
  return true;
}


/* === CounterPassing ==================================================== */

/* --- constructor --- */

template<class T> CounterPassing<T>::CounterPassing(Performer<T> &p_target) : target(p_target), n(0) {}

/* --- perform --- */

template<class T> bool CounterPassing<T>::perform(const T &t) {
  ++n;
  return target.perform(t);
}


/* === True ============================================================== */

/* --- holds --- */

template<class T> bool True<T>::holds(const T&) {
  return true;
}


/* === Counter4Pair ====================================================== */

/* --- constructor --- */

template<class K, class V> Counter4Pair<K,V>::Counter4Pair() : n(0) {}

/* --- perform --- */

template<class K, class V> bool Counter4Pair<K,V>::perform(const K&, V&) {
  ++n;
  return true;
}


/* === Storer ============================================================ */

/* --- constructor --- */

template<class T> Storer<T>::Storer(T *p_arr, int p_size) : size(p_size), n(0), arr(p_arr) {
  FKT "Storer::Storer";
  if (size<0) errstop(fkt, "size<0");
}

/* --- perform --- */

template<class T> bool Storer<T>::perform(const T &t) {
  if (n>=size) return err("Array zu klein");
  arr[n]=t;
  ++n;
  return true;
}



/////////////////////
// FILE bigint.cpp //
/////////////////////

#define LW(x) (x&DWORD(0xffff))
#define HW(x) (x>>16)

/* --- declare static functions --- */

static void compute_arr_digit(Card64 , int arr_digit[N_DIGIT4CARD64 ]);
static void compute_arr_digit(Card128, int arr_digit[N_DIGIT4CARD128]);


/* === Card64 ============================================================ */

/* --- static fields --- */

const Card64 Card64::zero(DWORD(0));
const Card64 Card64::one (DWORD(1));

void Card64::operator=(DWORD dw) {
  high=DWORD(0);
  low=dw;
}

/* --- Card64+=Card64 --- */

void Card64::operator+=(Card64 inc) {
  FKT "Card64::operator+=(Card64)";

  DWORD low_bak = low;
  low+=inc.low;
  if (low<low_bak) { // Overflow on low
    ++high;
    if (!high) {
      errstop(fkt, "Overflow");
    }
  }

  DWORD high_bak = high;
  high+=inc.high;
  if (high<high_bak) { // Overflow on high
    errstop(fkt, "Overflow");
  }
}

/* --- Card64|=Card64 --- */

void Card64::operator|=(Card64 c) {
  low |=c.low ;
  high|=c.high;
}

/* --- Card64&=Card64 --- */

void Card64::operator&=(Card64 c) {
  low &=c.low ;
  high&=c.high;
}

/* --- Card64+=DWORD --- */

// Covered by test64

void Card64::operator+=(DWORD inc) {
  FKT "Card64::operator+=(DWORD)";

  DWORD low_bak = low;
  low+=inc;
  if (low<low_bak) { // Overflow on low
    ++high;
    if (!high) {
      errstop(fkt, "Overflow"); return;
    }
  }
}

/* --- Card64-=Card64 --- */

// Covered by test64

void Card64::operator-=(Card64 dec) {
  FKT "Card64::operator-=(Card64)";

  if (high<dec.high) {
    errstop(fkt, "Underflow"); return;
  }
  high-=dec.high;

  if (low<dec.low) {
    if (!high) {
      errstop(fkt, "Underflow");return;
    }
    --high;
  }
  low-=dec.low;
}

/* --- Card64-=DWORD --- */

void Card64::operator-=(DWORD dec) {
  FKT "Card64::operator-=(DWORD)";

  if (low<dec) {
    if (!high) {
      errstop(fkt, "Underflow");
    }
    --high;
  }
  low-=dec;
}

/* --- dbl --- */

void Card64::dbl() {
  FKT "Card64::dbl";

  if (high>=DWORD(0x80000000)) errstop(fkt, "Overflow");
  high<<=1;
  if (low>=DWORD(0x80000000)) ++high;
  low<<=1;
}

/* --- to_int --- */

// Covered by testc64

int Card64::to_int() const {
  FKT "Card64::to_int";

  if (high) {
    errstop(fkt, "Too large"); return 0;
  }
  int n = low;
  if (n<0 || (DWORD)n!=low) {
    errstop(fkt, "Too large"); return 0;
  }

  return n;
}

/* --- to_dbl --- */

double Card64::to_dbl() const {
  return double(low) + 4294967296e0*double(high);
}

/* --- half --- */

void Card64::half() {
  low>>=1;
  if (high & DWORD(1)) {
    low |= DWORD(0x80000000);
  }
  high>>=1;
}

/* --- comp --- */

void Card64::comp(DWORD dw) {
  FKT "Card64::comp";

  if (high) errstop(fkt, "Underflow");
  if (low>dw) errstop(fkt, "Underverflow");
  low=dw-low;
}

/* --- --Card64 --- */

// Covered by test64

void Card64::operator--() {
  FKT "Card64::operator--";

  if (!low) {
    if (!high) {
      errstop(fkt, "Underflow");
    }
    --high;
  }
  --low;
}

/* --- ++Card64 --- */

// Covered by test64

void Card64::operator++() {
  FKT "Card64::operator++";

  ++low;
  if (!low) {
    ++high;
    if (!high) {
      errstop(fkt, "Overflow"); return;
    }
  }
}

/* --- cmp --- */

int cmp(Card64 a, Card64 b) {
  int res;
  res=cmp_dword(a.high, b.high); if (res) return res;
  res=cmp_dword(a.low , b.low );
  return res;
}

/* --- cmp_card64_dword --- */

int cmp_card64_dword(Card64 a, DWORD b) {
  if (a.high) return 1;
  return cmp_dword(a.low, b);
}


/* === Int64 ============================================================= */

/* --- static fields --- */

const Int64 Int64::zero(DWORD(0));

/* --- Int64-=Int64 --- */

void Int64::operator-=(Int64 dec) {
  dec.neg();
  *this += dec;
}

/* --- Int64+=Int64 --- */

void Int64::operator+=(Int64 inc) {
  if (inc.sign==0) {
    return;
  }
  if (sign==0) {
    *this=inc; return;
  }

  // From here on: sign<>0, inc.sign<>0

  if (sign*inc.sign>0) {
    abs+=inc.abs;
    return;
  }

  // From here on: sign*inc.sign<0
  int x=cmp(abs, inc.abs);
  if (x==0) {
    abs=Card64::zero;
    sign=0;
    return;
  }
  if (x>0) {
    abs-=inc.abs;
    return;
  }

  // From here on: sign*inc.sign<0, abs<inc.abs => change sign
  abs=inc.abs-abs;
  sign=-sign;
}

/* --- Card64-=int --- */

Int64 Int64::operator-() const {
  return Int64(-sign, abs);
}

/* --- Card64-=int --- */

void Int64::operator-=(int dec) {
  FKT "Int64::operator-=(int)";

  if (dec==0) return;

  if (dec<0) {
    dec=-dec;
    if (dec<0) errstop(fkt, "abs(inc) zu gross");
    (*this)+=dec;
    return;
  }

  DWORD dec_dw = (DWORD)dec;
  if ((int)dec_dw!=dec) errstop(fkt, "dec zu gross fuer DWORD");

  if (sign==0) {
    abs=dec_dw;
    sign=-1;
    return;
  }

  if (sign<0) {
    abs+=dec_dw;
    return;
  }

  // From here on: sign>0

  int cmp = cmp_card64_dword(abs, dec_dw);
  if (cmp==0) {
    abs=Card64::zero;
    sign=0;
    return;
  }
  if (cmp<0) {
    sign=-1;
    abs.comp(dec_dw);
  }
  if (cmp>0) {
    abs-=dec_dw;
  }
}

/* --- Card64+=int --- */

void Int64::operator+=(int inc) {
  FKT "Int64::operator+=(int)";

  if (inc==0) return;

  if (inc<0) {
    inc=-inc;
    if (inc<0) errstop(fkt, "abs(inc) zu gross");
    (*this)-=inc;
    return;
  }

  DWORD inc_dw = (DWORD)inc;
  if ((int)inc_dw!=inc) errstop(fkt, "inc zu gross fuer DWORD");

  if (sign==0) {
    abs=inc_dw;
    sign=1;
    return;
  }

  if (sign>0) {
    abs+=inc_dw;
    return;
  }

  // From here on: sign<0

  int cmp = cmp_card64_dword(abs, inc_dw);
  if (cmp==0) {
    abs=Card64::zero;
    sign=0;
    return;
  }
  if (cmp<0) {
    sign=1;
    abs.comp(inc_dw);
  }
  if (cmp>0) {
    abs-=inc_dw;
  }
}

/* --- constructor(DWORD) --- */

Int64::Int64(DWORD abs_dw) : abs(abs_dw), sign(abs_dw ? 1 : 0) {}

/* --- constructor(sign, abs) --- */

Int64::Int64(int p_sign, Card64 p_abs) {
  if (p_sign==0 || p_abs.is_zero()) {
    sign=0;
    return;
  }
  abs=p_abs;
  if (p_sign>0) sign=1;
  if (p_sign<0) sign=-1;
}

/* --- constructor(abs) --- */

Int64::Int64(Card64 p_abs) {
  if (p_abs.is_zero()) {
    sign=0;
  } else {
    abs=p_abs;
    sign=1;
  }
}


/* === Card128 =========================================================== */

/* --- static fields --- */

const Card128 Card128::zero(DWORD(0)); // Covered by test128.

/* --- Constructor(DWORD) --- */

// Covered by test128.

Card128::Card128(DWORD a0) {
  a[0]=a0;
  a[1]=a[2]=a[3]=DWORD(0);
}

/* --- half --- */

// Covered by test128.

void Card128::half() {
  a[0]>>=1; if (a[1] & DWORD(1)) a[0]|=DWORD(0x80000000);
  a[1]>>=1; if (a[2] & DWORD(1)) a[1]|=DWORD(0x80000000);
  a[2]>>=1; if (a[3] & DWORD(1)) a[2]|=DWORD(0x80000000);
  a[3]>>=1;
}

/* --- --Card64 --- */

// Covered by test128.

void Card128::operator--() {
  FKT "Card128::operator--";

  if (!a[0]) {
    if (!a[1]) {
      if (!a[2]) {
        if (!a[3]) {
          errstop(fkt, "Underflow");
        }
        --a[3];
      }
      --a[2];
    }
    --a[1];
  }
  --a[0];
}

/* --- dbl --- */

// Covered by test128.

void Card128::dbl() {
  FKT "Card128::dbl";
  bool carry[4];

  carry[0] = (a[0]>=DWORD(0x80000000)); a[0]<<=1;
  carry[1] = (a[1]>=DWORD(0x80000000)); a[1]<<=1; if (carry[0]) ++a[1];
  carry[2] = (a[2]>=DWORD(0x80000000)); a[2]<<=1; if (carry[1]) ++a[2];
  carry[3] = (a[3]>=DWORD(0x80000000)); a[3]<<=1; if (carry[2]) ++a[3];
  if (carry[3]) errstop(fkt, "Overflow");
}

/* --- is_card64 --- */

// Covered by test128.

bool Card128::is_card64(Card64 &card64) const {
  if (!a[3] && !a[2]) {
    card64 = Card64(a[1], a[0]);
    return true;
  } else {
    return false;
  }
}

/* --- is_zero --- */

// Covered by test128.

bool Card128::is_zero() const {
  return !a[0] && !a[1] && !a[2] && !a[3];
}

/* --- Card128=Card64 --- */

// Covered by test128.

void Card128::operator=(const Card64 &card64) {
  a[0]=card64.low ;
  a[1]=card64.high;
  a[2] = a[3] = DWORD(0);
}

/* --- cmp --- */

// Covered by test128.

int cmp(const Card128 &a, const Card128 &b) {
  int res, i;

  for (i=3; i>=0; --i) {
    res = cmp_dword(a.a[i], b.a[i]);
    if (res) {
      return res;
    }
  }

  return 0;
}

/* --- Card128-=Card128 --- */

// Covered by test128.

void Card128::operator-=(const Card128 &dec) {
  FKT "Card128::operator-=";
  int i;
  bool carry=false, carry_next;

  for (i=0; i<4; ++i) {

    DWORD &ai=a[i], dec_ai=dec.a[i];
    carry_next=false;
    if (ai<dec_ai) {
      carry_next=true;
    }
    ai-=dec_ai;
    if (carry) {
      if (!ai) {
        carry_next=true;
      }
      --ai;
    }

    carry=carry_next;
  }

  if (carry) {
    errstop(fkt, "Underflow");
  }
}

/* --- Card128+=Card64 --- */

// Covered by test128.

void Card128::operator+=(const Card64 &inc) {
  FKT "Card128::operator+=(Card64)";

  DWORD a_bak;
  bool carry[4];

  a_bak=a[0]; a[0]+=inc.low ; carry[0] = (a[0]<a_bak);
  a_bak=a[1]; a[1]+=inc.high; carry[1] = (a[1]<a_bak); if (carry[0]) {++a[1]; if (!a[1]) carry[1]=true;}
                              carry[2] = false       ; if (carry[1]) {++a[2]; if (!a[2]) carry[2]=true;}
                              carry[3] = false       ; if (carry[2]) {++a[3]; if (!a[3]) carry[3]=true;}
                                                       if (carry[3]) errstop(fkt, "Overflow");
}

/* --- Card128-=Card64 --- */

// Covered by test128.

void Card128::operator-=(const Card64 &dec) {
  FKT "Card128::operator-=(Card64)";

  DWORD a_bak;
  bool carry[4];

  a_bak=a[0]; a[0]-=dec.low ; carry[0] = (a[0]>a_bak);
  a_bak=a[1]; a[1]-=dec.high; carry[1] = (a[1]>a_bak); if (carry[0]) {if (!a[1]) carry[1]=true; --a[1];}
                              carry[2] = false       ; if (carry[1]) {if (!a[2]) carry[2]=true; --a[2];}
                              carry[3] = false       ; if (carry[2]) {if (!a[3]) carry[3]=true; --a[3];}
                                                       if (carry[3]) errstop(fkt, "Underflow");
}

/* --- Card128+=Card128 --- */

// Covered by test128.

void Card128::operator+=(Card128 inc) {
  FKT "Card128::operator+=(Card128)";

  DWORD a_bak;
  bool carry[4];

  a_bak=a[0]; a[0]+=inc.a[0]; carry[0] = (a[0]<a_bak);
  a_bak=a[1]; a[1]+=inc.a[1]; carry[1] = (a[1]<a_bak); if (carry[0]) {++a[1]; if (!a[1]) carry[1]=true;}
  a_bak=a[2]; a[2]+=inc.a[2]; carry[2] = (a[2]<a_bak); if (carry[1]) {++a[2]; if (!a[2]) carry[2]=true;}
  a_bak=a[3]; a[3]+=inc.a[3]; carry[3] = (a[3]<a_bak); if (carry[2]) {++a[3]; if (!a[3]) carry[3]=true;}
                                                       if (carry[3]) errstop(fkt, "Overflow");
}

/* --- comp --- */

// Sets <*this> = <x> - <*this>
// Covered by test128.

void Card128::comp(const Card64 &x) {
  FKT "Card128::compl";

  if (a[3] || a[2]) {errstop(fkt, "Underflow"); return;}

  if (a[0]>x.low) {
    if (!x.high) {errstop(fkt, "Underflow"); return;}
    ++a[1];
  }
  if (a[1]>x.high) {errstop(fkt, "Underflow"); return;}
  a[0] = x.low  - a[0];
  a[1] = x.high - a[1];
}

/* --- cmp_card128_card64 --- */

// Covered by test128.

int cmp_card128_card64(const Card128 &a, const Card64 &b) {
  if (a.a[3]) {
    return 1;
  }
  if (a.a[2]) {
    return 1;
  }

  int cmp =  cmp_dword(a.a[1], b.high);
  if (cmp) {
    return cmp;
  }
  return cmp_dword(a.a[0], b.low);
}


/* === Int128 ============================================================ */

/* --- static fields --- */

const Int128 Int128::zero(Card128::zero); // Covered by test128.

/* --- constructor(sign, abs) --- */

// Covered by test128.

Int128::Int128(int p_sign, const Card128 &p_abs) {
  if (p_sign==0 || p_abs.is_zero()) {
    sign=0;
    return;
  }
  abs=p_abs;
  if (p_sign>0) sign=1;
  if (p_sign<0) sign=-1;
}

/* --- constructor(Card128) --- */

// Covered by test128.

Int128::Int128(const Card128 &p_abs) : abs(p_abs), sign(p_abs.is_zero() ? 0 : 1) {}

/* --- Int128+=Int128 --- */

// Covered by test128.

void Int128::operator+=(const Int128 &inc) {
  if (inc.sign==0) {
    return;
  }
  if (sign==0) {
    *this=inc; return;
  }

  // From here on: sign<>0, inc.sign<>0

  if (sign*inc.sign>0) {
    abs+=inc.abs;
    return;
  }

  // From here on: sign*inc.sign<0
  int x=cmp(abs, inc.abs);
  if (x==0) {
    abs=Card128::zero;
    sign=0;
    return;
  }
  if (x>0) {
    abs-=inc.abs;
    return;
  }

  // From here on: sign*inc.sign<0, abs<inc.abs => change sign
  Card128 tmp=abs;
  abs=inc.abs;
  abs-=tmp;
  sign=-sign;
}

/* --- is_card64 --- */

// Covered by test128.

bool Int128::is_card64(Card64 &card64) const {
  if (sign<0) return false;
  if (sign==0) {card64=Card64::zero; return true;}
  return abs.is_card64(card64);
}

/* --- Int128+=Int64 --- */

// Covered by test128.

void Int128::operator+=(const Int64 &inc) {
  // FKT "Int64::operator+=(int)";

  // Handle case inc is zero
  int sign_inc = inc.get_sign();
  if (sign_inc==0) return;

  // Handle case inc is negativr
  if (sign_inc<0) {
    Int64 neg_inc(inc);
    neg_inc.neg();
    (*this)-=neg_inc;
    return;
  }

  // From here on, inc is positive

  // Handle case this is zero
  const Card64 &abs_inc = inc.get_abs();
  if (sign==0) {
    abs=abs_inc;
    sign=1;
    return;
  }

  // Handle case this is positive
  if (sign>0) {
    abs+=abs_inc;
    return;
  }

  // From here on: <this> is negative and inc is positive

  int cmp = cmp_card128_card64(abs, abs_inc);
  if (cmp==0) {
    abs=Card128::zero;
    sign=0;
    return;
  }

  if (cmp<0) {
    sign=1;
    abs.comp(abs_inc);
  }
  if (cmp>0) {
    abs-=abs_inc;
  }
}


/* --- Int128-=Int64 --- */

// Covered by test128.

void Int128::operator-=(const Int64 &inc) {

  // Handle case inc is zero
  int sign_inc = inc.get_sign();
  if (sign_inc==0) {
    return;
  }

  // Handle case inc is negative
  const Card64 &abs_inc = inc.get_abs();
  if (sign_inc<0) {
    Int64 neg_inc(inc);
    neg_inc.neg();
    (*this)+=neg_inc;
    return;
  }

  // From here on, inc is positive

  // Handle case that <this> is zero
  if (sign==0) {
    abs=abs_inc;
    sign=-1;
    return;
  }

  // Handle case that <this> is negative
  if (sign<0) {
    abs+=abs_inc;
    return;
  }

  // From here on: <this> is positive and <inc> is positive

  int cmp = cmp_card128_card64(abs, abs_inc);
  if (cmp==0) {
    abs=Card128::zero;
    sign=0;
  }
  if (cmp<0) {
    sign=-1;
    abs.comp(abs_inc);
  }
  if (cmp>0) {
    abs-=abs_inc;
  }
}


/* === SetCard64 ========================================================= */

/* --- equal --- */

bool SetCard64::equal(const Card64 &a, const Card64 &b) const {
  return a==b;
}

/* --- hashind --- */

unsigned int SetCard64::hashind(const Card64 &x) const {
  return x.hashind();
}

/* === Inserter4Card64 =================================================== */

/* --- constructor --- */

Inserter4Card64::Inserter4Card64(Set<Card64> &p_set) : set(p_set) {}

/* --- perform --- */

bool Inserter4Card64::perform(const Card64 &x) {
  set.insert(x);
  return true;
}

/* === exported functions ================================================ */

/* --- plus_not_neg --- */

// Covered by test64

Card64 plus_not_neg(Card64 a, int b) {
  FKT "plus_not_neg";
  DWORD b_dw = (DWORD) b;
  if (b<0) {
    errstop(fkt, "b<0"); return Card64::zero;
  }
  if ((int)b_dw!=b) errstop(fkt, "Conversion to DWORD failed");
  a+=b_dw;
  return a;
}

/* --- read_silent(Card64) --- */

bool read_silent(In &in, Card64 &out, Str &errtxt) {

  if (in.at_end()) return err_silent(errtxt, "Unerwartetes Ende der Eingabe");

  char c=*in;
  if (!('0'<=c && c<='9')) return err_silent(errtxt, "Ziffernfolge erwartet");
  out = Card64(DWORD(c)-DWORD('0'));
  if (!++in) return false;

  while (!in.at_end() && (c=*in, '0'<=c && c<='9')) {

    // *10
    Card64 bak=out;
    out.dbl();
    out.dbl();
    out+=bak;
    out.dbl();

    out+=Card64(DWORD(c)-DWORD('0'));

    if (!++in) return false;
  }
  return true;
}

/* --- read_silent(Card128) --- */

bool read_silent(In &in, Card128 &out, Str &errtxt) {

  if (in.at_end()) return err_silent(errtxt, "Unerwartetes Ende der Eingabe");

  char c=*in;
  if (!('0'<=c && c<='9')) return err_silent(errtxt, "Ziffernfolge erwartet");
  out = Card128(DWORD(c)-DWORD('0'));
  if (!++in) return false;

  while (!in.at_end() && (c=*in, '0'<=c && c<='9')) {

    // *10
    Card128 bak=out;
    out.dbl();
    out.dbl();
    out+=bak;
    out.dbl();

    out+=Card128(DWORD(c)-DWORD('0'));

    if (!++in) return false;
  }

  return true;
}

/* --- read(Int64) --- */

bool read(In &in, Int64 &out) {
  Str errtxt;
  if (!read_silent(in, out, errtxt)) return in.In::err_at(errtxt);
  return true;
}

/* --- read(Int128) --- */

bool read(In &in, Int128 &out) {
  Str errtxt;
  if (!read_silent(in, out, errtxt)) return in.In::err_at(errtxt);
  return true;
}

/* --- read(Card64) --- */

bool read(In &in, Card64 &out) {
  Str errtxt;
  if (!read_silent(in, out, errtxt)) return in.In::err_at(errtxt);
  return true;
}

/* --- read_silent(Int64) --- */

bool read_silent(In &in, Int64 &out, Str &errtxt) {

  if (in.at_end()) return err_silent(errtxt, "Unerwartetes Ende der Eingabe");

  char c=*in, sign=1;
  if (c=='-') {
    sign=-1;
    if (!++in) return false;
  } else if (c=='+') {
    if (!++in) return false;
  }

  Card64 abs;
  if (!read_silent(in, abs, errtxt)) return false;

  out=Int64(sign, abs);
  return true;
}

/* --- read_silent(Int128) --- */

bool read_silent(In &in, Int128 &out, Str &errtxt) {

  if (in.at_end()) return err_silent(errtxt, "Unerwartetes Ende der Eingabe");

  char c=*in, sign=1;
  if (c=='-') {
    sign=-1;
    if (!++in) return false;
  } else if (c=='+') {
    if (!++in) return false;
  }

  Card128 abs;
  if (!read_silent(in, abs, errtxt)) return false;

  out=Int128(sign, abs);
  return true;
}

/* --- Int64*Card64--- */

Int64 operator*(Int64 a, Int64 b) {
  return Int64(a.sign*b.sign, a.abs*b.abs);
}

/* --- Card64*Card64--- */

Card64 operator*(Card64 a, Card64 b) {
  FKT "operator*(Card64, Card64)";

  DWORD a0=LW(a.low), a1=HW(a.low), a2=LW(a.high), a3=HW(a.high);
  DWORD b0=LW(b.low), b1=HW(b.low), b2=LW(b.high), b3=HW(b.high);
  DWORD p00=a0*b0;
  DWORD p01=a0*b1;
  DWORD p10=a1*b0;
  DWORD p20=a2*b0;
  DWORD p11=a1*b1;
  DWORD p02=a0*b2;
  DWORD p30=a3*b0;
  DWORD p21=a2*b1;
  DWORD p12=a1*b2;
  DWORD p03=a0*b3;

  if (a3 && (b1 || b2 || b3)) errstop(fkt, "Overflow");
  if (a2 && (b2 || b3)) errstop(fkt, "Overflow");
  if (a1 && b3) errstop(fkt, "Overflow");
  if (HW(p30) || HW(p12) || HW(p21) || HW(p03)) errstop(fkt, "Overflow");

  DWORD sum_lw_p3 = p03+p12+p21+p30;
  if (sum_lw_p3>DWORD(0xffff)) errstop(fkt, "Overflow");

  Card64 res(p02, p00);
  res+=Card64(HW(p01), LW(p01)<<16);
  res+=Card64(HW(p10), LW(p10)<<16);
  res+=Card64(p11, DWORD(0));
  res+=Card64(p20, DWORD(0));
  res+=Card64(sum_lw_p3<<16, DWORD(0));

  return res;
}

/* --- mul(Card64,Card64) --- */

// Covered by test128

Card128 mul(Card64 a, Card64 b) {
  if (a>b) {
    return mul(b,a);
  }

  // From here on, b<=a
  if (b.is_zero()) {
    return Card128::zero;
  }

  // From here on, 0<b<=a

  // If b is odd,use a*b = a*(b-1)+a
  Card128 res;
  if (b.is_odd()) {
    --b;
    res=mul(a,b);
    res+=a;
    return res;
  }

  // From here on, 0<b<=a, and b is even
  b.half();
  res=mul(a,b);
  res.dbl();

  return res;
}

/* --- mul(Int64,Card64) --- */

// Covered by test128

Int128 mul(Int64 a, Card64 b) {
  int sign = a.get_sign();
  if (sign==0) {
    return Int128::zero;
  }
  return Int128(sign, mul(a.get_abs(), b));
}

/* --- mul(DWORD,DWORD) --- */

Card64 mul(DWORD a, DWORD b) {
  DWORD ha = HW(a), la = LW(a);
  DWORD hb = HW(b), lb = LW(b);
  DWORD l = la*lb, h=ha*hb, m1=ha*lb, m2=hb*la;

  Card64 res(h,l);
  res+=Card64(HW(m1), LW(m1)<<16);
  res+=Card64(HW(m2), LW(m2)<<16);

  return res;
}

/* --- divmod --- */

// Computes quot=nom/denom, rem=nom%denom

void divmod(Card64 nom, Card64 denom, Card64 &quot, Card64 &rem) {
  FKT "divmod";

  if (denom.is_zero()) errstop(fkt, "Division durch 0");

  if (nom<denom) {
    quot=Card64::zero;
    rem=nom;
    return;
  }

  static Card64 limit4shift(DWORD(1)<<31, DWORD(0));
  if (denom>=limit4shift) {
    quot=Card64::one;
    rem=nom-denom;
    return;
  }

  Card64 denom_dbl(denom);
  denom_dbl.dbl();

  divmod(nom, denom_dbl, quot, rem);
  quot.dbl();
  if (rem>=denom) {
    rem-=denom;
    ++quot;
  }
}

/* --- to_nts(Card64) --- */

char *to_nts(const Card64 &p, char *buff, int size_buff) {
  FKT "to_nts(Card64)";
  int arr_digit[N_DIGIT4CARD64];
  compute_arr_digit(p, arr_digit);

  int n_digit;
  n_digit=N_DIGIT4CARD64; while (n_digit>1 && arr_digit[n_digit-1]==0) --n_digit;

  if (size_buff<=n_digit) errstop(fkt, "Buffer to small");

  int i_digit;
  for (i_digit=0; i_digit<n_digit; ++i_digit) {
    buff[n_digit-i_digit-1] = char(int('0') + arr_digit[i_digit]);
  }
  buff[n_digit]='\0';

  return buff;
}

/* --- to_nts(Card128) --- */

char *to_nts(const Card128 &p, char *buff, int size_buff) {
  FKT "to_nts(Card128)";
  int arr_digit[N_DIGIT4CARD128];
  compute_arr_digit(p, arr_digit);

  int n_digit;
  n_digit=N_DIGIT4CARD128; while (n_digit>1 && arr_digit[n_digit-1]==0) --n_digit;

  if (size_buff<=n_digit) errstop(fkt, "Buffer to small");

  int i_digit;
  for (i_digit=0; i_digit<n_digit; ++i_digit) {
    buff[n_digit-i_digit-1] = char(int('0') + arr_digit[i_digit]);
  }
  buff[n_digit]='\0';

  return buff;
}

/* --- to_nts(Int64) --- */

char* to_nts(const Int64 &p, char *buff, int size_buff) {
  FKT "to_nts(Int64)";
  int sign=p.get_sign();

  if (sign<0) {
    if (size_buff<1) errstop(fkt, "Buffer to small");
    buff[0]='-';

    to_nts(p.get_abs(), buff+1, size_buff-1);
  }

  if (sign==0) {
    if (size_buff<2) errstop(fkt, "Buffer to small");
    buff[0]='0';
    buff[1]='\0';
  }

  if (sign>0) {
    to_nts(p.get_abs(), buff, size_buff);
  }

  return buff;
}

/* --- to_nts(Int128) --- */

char* to_nts(const Int128 &p, char *buff, int size_buff) {
  FKT "to_nts(Int128)";
  int sign=p.get_sign();

  if (sign<0) {
    if (size_buff<1) errstop(fkt, "Buffer to small");
    buff[0]='-';

    to_nts(p.get_abs(), buff+1, size_buff-1);
  }

  if (sign==0) {
    if (size_buff<2) errstop(fkt, "Buffer to small");
    buff[0]='0';
    buff[1]='\0';
  }

  if (sign>0) {
    to_nts(p.get_abs(), buff, size_buff);
  }

  return buff;
}

/* --- Card64-Card64 --- */

Card64 operator-(Card64 a, Card64 b) {
  a-=b;
  return a;
}

/* --- Card64+Card64 --- */

Card64 operator+(Card64 a, Card64 b) {
  a+=b;
  return a;
}

/* --- Int64+Int64--- */

Int64 operator+(Int64 a, Int64 b) {
  a+=b;
  return a;
}


/* --- Card64|Card64 --- */

Card64 operator|(Card64 a, Card64 b) {
  a|=b;
  return a;
}

/* --- Card64&Card64 --- */

Card64 operator&(Card64 a, Card64 b) {
  a&=b;
  return a;
}


/* === static functions ================================================== */

/* --- compute_arr_digit --- */

static void compute_arr_digit(Card64 p, int arr_digit[N_DIGIT4CARD64]) {
  int i_digit;

  if (p.is_zero()) {
    for (i_digit=0; i_digit<N_DIGIT4CARD64; ++i_digit) {
      arr_digit[i_digit]=0;
    }
    return;
  }

  if (p.is_odd()) {
    --p;
    compute_arr_digit(p, arr_digit);
    i_digit=0;
    while (true) {
      int &digit = arr_digit[i_digit];
      if (digit==9) {
        digit=0;
        ++i_digit;
      } else {
        ++digit;
        break;
      }
    }
    return;
  }

  // p is neither odd nor zero
  int carry=0;
  p.half();
  compute_arr_digit(p, arr_digit);
  for (i_digit=0; i_digit<N_DIGIT4CARD64; ++i_digit) {
    int &digit = arr_digit[i_digit];
    digit<<=1;
    digit+=carry;
    if (digit>=10) {
      digit-=10;
      carry=1;
    } else {
      carry=0;
    }
  }
}


/* --- compute_arr_digit(Card128) --- */

static void compute_arr_digit(Card128 p, int arr_digit[N_DIGIT4CARD128]) {
  int i_digit;

  if (p.is_zero()) {
    for (i_digit=0; i_digit<N_DIGIT4CARD128; ++i_digit) {
      arr_digit[i_digit]=0;
    }
    return;
  }

  if (p.is_odd()) {
    --p;
    compute_arr_digit(p, arr_digit);
    i_digit=0;
    while (true) {
      int &digit = arr_digit[i_digit];
      if (digit==9) {
        digit=0;
        ++i_digit;
      } else {
        ++digit;
        break;
      }
    }
    return;
  }

  // p is neither odd nor zero
  int carry=0;
  p.half();
  compute_arr_digit(p, arr_digit);
  for (i_digit=0; i_digit<N_DIGIT4CARD128; ++i_digit) {
    int &digit = arr_digit[i_digit];
    digit<<=1;
    digit+=carry;
    if (digit>=10) {
      digit-=10;
      carry=1;
    } else {
      carry=0;
    }
  }
}

/* === test functions ==================================================== */

/* --- declare static test functions --- */

static bool test128_01();
static bool test128_02();
static bool test128_03();
static bool test128_04();
static bool test128_05();
static bool test128_06();
static bool test128_07();
static bool test128_08();
static bool test128_09();
static bool test128_10();
static bool test128_11();
static bool test128_12();
static bool test128_13();
static bool test128_14();
static bool test128_15();
static bool test128_16();
static bool test128_17();
static bool test128_18();
static bool testi64_01();
static bool testc64_01();
static bool testc64_02();
static bool testc64_03();
static bool testc64_04();
static bool testc64_05();
static bool testc64_06();
static bool eq(const Int128&, const char *nts);
static bool eq(const Card64&, const char *nts);
static bool eq(const Int64 &, const char *nts);
static Card128 pow2(int exp);
static Int128  atoi128(const char *s);
static Int64   atoi64 (const char *s);
static Card128 atoc128(const char *s);
static Card64  atoc64 (const char *s);

/* --- test128 --- */

void test128() {
  int n_success=0, n_done=0;

  if (test128_01()) ++n_success; 
  ++n_done;
  if (test128_02()) ++n_success; 
  ++n_done;
  if (test128_03()) ++n_success; 
  ++n_done;
  if (test128_04()) ++n_success; 
  ++n_done;
  if (test128_05()) ++n_success; 
  ++n_done;
  if (test128_06()) ++n_success; 
  ++n_done;
  if (test128_07()) ++n_success; 
  ++n_done;
  if (test128_08()) ++n_success; 
  ++n_done;
  if (test128_09()) ++n_success; 
  ++n_done;
  if (test128_10()) ++n_success; 
  ++n_done;
  if (test128_11()) ++n_success; 
  ++n_done;
  if (test128_12()) ++n_success; 
  ++n_done;
  if (test128_13()) ++n_success; 
  ++n_done;
  if (test128_14()) ++n_success; 
  ++n_done;
  if (test128_15()) ++n_success; 
  ++n_done;
  if (test128_16()) ++n_success; 
  ++n_done;
  if (test128_17()) ++n_success; 
  ++n_done;
  if (test128_18()) ++n_success; 
  ++n_done;

  printf("%d/%d Tests erfolgreich.\n", n_success, n_done);
}

/* --- testc64 --- */

void testc64() {
  int n_success=0, n_done=0;

  if (testc64_01()) ++n_success; 
  ++n_done;
  if (testc64_02()) ++n_success; 
  ++n_done;
  if (testc64_03()) ++n_success; 
  ++n_done;
  if (testc64_04()) ++n_success; 
  ++n_done;
  if (testc64_05()) ++n_success; 
  ++n_done;
  if (testc64_06()) ++n_success; 
  ++n_done;

  printf("%d/%d Tests erfolgreich.\n", n_success, n_done);
}

/* --- testi64 --- */

void testi64() {
  int n_success=0, n_done=0;

  if (testi64_01()) ++n_success; 
  ++n_done;

  printf("%d/%d Tests erfolgreich.\n", n_success, n_done);
}

/* === static test functions ============================================= */

/* --- testc64_06 --- */

static bool testc64_06() {
  FKT "testc64_06";
  Card64 a,b;

  a = atoc64("1000000000"); a+=DWORD(1000000000); if (!eq(a,"2000000000")) return err_check_failed(fkt, 1);
  a = atoc64("4000000000"); a+=DWORD(1000000000); if (!eq(a,"5000000000")) return err_check_failed(fkt, 2);

  a=atoc64("18446744073709000000");
  expect_errstop=true;
  a+=DWORD(1000000000);
  if (!got_errstop()) return err_check_failed(fkt, 3);

  a=atoc64("5000000000");
  b=atoc64("50000000000");
  expect_errstop=true;
  a-=b;
  if (!got_errstop()) return err_check_failed(fkt, 4);

  a=atoc64("5000");
  b=atoc64("50000");
  expect_errstop=true;
  a-=b;
  if (!got_errstop()) return err_check_failed(fkt, 5);

  a = atoc64("40000"      ); b=atoc64("30000"     ); a-=b; if (!eq(a,"10000"      )) return err_check_failed(fkt, 6);
  a = atoc64("50000000000"); b=atoc64("5000000000"); a-=b; if (!eq(a,"45000000000")) return err_check_failed(fkt, 7);
  a = atoc64("4294967300" ); b=atoc64("67300"     ); a-=b; if (!eq(a,"4294900000" )) return err_check_failed(fkt, 8);

  a=atoc64("18446744073709551615");
  expect_errstop=true;
  ++a;
  if (!got_errstop()) return err_check_failed(fkt, 9);

  a=atoc64("4294967295"); ++a; if (!eq(a,"4294967296")) return err_check_failed(fkt, 10);

  a=atoc64("50000000000"); b=plus_not_neg(a,46); if (!eq(b,"50000000046")) return err_check_failed(fkt, 11);
  a=atoc64("50000000000"); b=plus_not_neg(a, 0); if (!eq(b,"50000000000")) return err_check_failed(fkt, 12);
  a=atoc64("4294967295"); b=plus_not_neg(a, 1); if (!eq(b,"4294967296")) return err_check_failed(fkt, 13);
  expect_errstop=true;
  b=plus_not_neg(a, -1);
  if (!got_errstop()) return err_check_failed(fkt, 14);

  return true;
}

/* --- testc64_05 --- */

static bool testc64_05() {
  FKT "testc64_05";
  Card64 a,b;
  a = atoc64("4294967296"); b=a; --a; if (!(a<=b)) return err_check_failed(fkt, 1);
  a = atoc64("4294967296"); b=a;      if (!(a<=b)) return err_check_failed(fkt, 1);
  a = atoc64("4294967296"); b=a; --b; if (  a<=b ) return err_check_failed(fkt, 1);

  return true;
}

/* --- testc64_04 --- */

static bool testc64_04() {
  FKT "testc64_04";

  Card64 a;
  a = atoc64("4294967296"); --a; if (!eq(a,"4294967295")) return err_check_failed(fkt, 1);
  a = atoc64("4294967295"); --a; if (!eq(a,"4294967294")) return err_check_failed(fkt, 2);
  a = atoc64("1"); --a; if (!a.is_zero()) return err_check_failed(fkt, 3);
  expect_errstop=true;
  --a;
  if (!got_errstop()) return err_check_failed(fkt, 4);

  return true;
}

/* --- testi64_01 --- */

static bool testi64_01() {
  FKT "testi64_01";

  Int64 a, b, c;
  a = atoi64(         "1000"); b = atoi64(        "1000"); c=a+b; if (!eq(c,         "2000")) return err_check_failed(fkt,  1);
  a = atoi64(         "1000"); b = atoi64(           "0"); c=a+b; if (!eq(c,         "1000")) return err_check_failed(fkt,  2);
  a = atoi64(            "0"); b = atoi64(        "1000"); c=a+b; if (!eq(c,         "1000")) return err_check_failed(fkt,  3);
  a = atoi64(            "0"); b = atoi64(           "0"); c=a+b; if (!eq(c,            "0")) return err_check_failed(fkt,  4);
  a = atoi64(        "-1000"); b = atoi64(        "1000"); c=a+b; if (!eq(c,            "0")) return err_check_failed(fkt,  5);
  a = atoi64(        "-1000"); b = atoi64(           "0"); c=a+b; if (!eq(c,        "-1000")) return err_check_failed(fkt,  6);
  a = atoi64(         "1000"); b = atoi64(       "-1000"); c=a+b; if (!eq(c,            "0")) return err_check_failed(fkt,  7);
  a = atoi64(            "0"); b = atoi64(       "-1000"); c=a+b; if (!eq(c,        "-1000")) return err_check_failed(fkt,  8);
  a = atoi64(        "-1000"); b = atoi64(       "-1000"); c=a+b; if (!eq(c,        "-2000")) return err_check_failed(fkt,  9);
  a = atoi64(   "4000000000"); b = atoi64(  "4000000000"); c=a+b; if (!eq(c,   "8000000000")) return err_check_failed(fkt, 10);
  a = atoi64(   "4000000000"); b = atoi64( "-4000000000"); c=a+b; if (!eq(c,            "0")) return err_check_failed(fkt, 11);
  a = atoi64(  "-4000000000"); b = atoi64(  "4000000000"); c=a+b; if (!eq(c,            "0")) return err_check_failed(fkt, 12);
  a = atoi64(  "-4000000000"); b = atoi64( "-4000000000"); c=a+b; if (!eq(c,  "-8000000000")) return err_check_failed(fkt, 13);
  a = atoi64(  "12000000000"); b = atoi64(  "4000000000"); c=a+b; if (!eq(c,  "16000000000")) return err_check_failed(fkt, 14);
  a = atoi64(  "12000000000"); b = atoi64( "-4000000000"); c=a+b; if (!eq(c,   "8000000000")) return err_check_failed(fkt, 15);
  a = atoi64( "-12000000000"); b = atoi64(  "4000000000"); c=a+b; if (!eq(c,  "-8000000000")) return err_check_failed(fkt, 16);
  a = atoi64( "-12000000000"); b = atoi64( "-4000000000"); c=a+b; if (!eq(c, "-16000000000")) return err_check_failed(fkt, 17);
  a = atoi64(   "4000000000"); b = atoi64( "12000000000"); c=a+b; if (!eq(c,  "16000000000")) return err_check_failed(fkt, 18);
  a = atoi64(  "-4000000000"); b = atoi64( "12000000000"); c=a+b; if (!eq(c,   "8000000000")) return err_check_failed(fkt, 19);
  a = atoi64(   "4000000000"); b = atoi64("-12000000000"); c=a+b; if (!eq(c,  "-8000000000")) return err_check_failed(fkt, 20);
  a = atoi64(  "-4000000000"); b = atoi64("-12000000000"); c=a+b; if (!eq(c, "-16000000000")) return err_check_failed(fkt, 21);

  a = atoi64("9223372036854775808"); b=a;
  expect_errstop=true;
  c=a+b;
  if (!got_errstop()) return err_check_failed(fkt, 30);

  a = atoi64("-9223372036854775808"); b=a;
  expect_errstop=true;
  c=a+b;
  if (!got_errstop()) return err_check_failed(fkt, 31);

  return true;
}

/* --- testc64_01 --- */

static bool testc64_01() {
  FKT "testc64_01";

  Card64 a(DWORD(4),DWORD(6666)+DWORD(0x100000));
  DWORD m = a&DWORD(0xffff);

  if (m!=DWORD(6666)) return err_check_failed(fkt, 1);
  return true;
}
/* --- testc64_03 --- */

static bool testc64_03() {
  FKT "testc64_03";

  Card64 a = atoc64("111111111111");
  Card64 b = atoc64("222222222222");
  a.dbl();
  if (a!=b) return err_check_failed(fkt, 1);

  return true;
}

/* --- testc64_02 --- */

static bool testc64_02() {
  FKT "testc64_02";

  int n;
  Card64 c64(DWORD(5555));
  n = c64.to_int();
  if (n!=5555) return err_check_failed(fkt, 1);

  c64 = Card64(DWORD(0xffffffff));
  expect_errstop=true;
  n = c64.to_int();
  if (!got_errstop()) return err_check_failed(fkt, 2);

  c64 = Card64(DWORD(1), DWORD(0));
  expect_errstop=true;
  n = c64.to_int();
  if (!got_errstop()) return err_check_failed(fkt, 3);

  return true;
}

/* --- test128_16 --- */

// Tests mul(Int64, Card64)

static bool test128_16() {
  FKT "test128_16";

  Int64  a;
  Card64 b;
  Int128 c;
  a=atoi64( "1000000000001"); b=atoc64( "111111111111" ); c = mul(a,b); if (!eq(c,  "111111111111111111111111")) return err_check_failed(fkt, 1);
  a=atoi64( "111111111111" ); b=atoc64( "1000000000001"); c = mul(a,b); if (!eq(c,  "111111111111111111111111")) return err_check_failed(fkt, 2);
  a=atoi64("-1000000000001"); b=atoc64( "111111111111" ); c = mul(a,b); if (!eq(c, "-111111111111111111111111")) return err_check_failed(fkt, 3);
  a=atoi64("-111111111111" ); b=atoc64( "1000000000001"); c = mul(a,b); if (!eq(c, "-111111111111111111111111")) return err_check_failed(fkt, 4);

  a=Int64 ::zero; b=atoc64( "111111111111"); c=mul(a,b); if (!c.is_zero()) return err_check_failed(fkt,  9);
  b=Card64::zero; a=atoi64( "111111111111"); c=mul(a,b); if (!c.is_zero()) return err_check_failed(fkt, 10);
  b=Card64::zero; a=atoi64("-111111111111"); c=mul(a,b); if (!c.is_zero()) return err_check_failed(fkt, 12);

  a=Int64 ::zero; b=Card64::zero; c=mul(a,b); if (!c.is_zero()) return err_check_failed(fkt, 13);
  return true;
}

/* --- test128_18 --- */

// Tests Card128-=Card128

static bool test128_18() {
  FKT "test128_18";

  Card128 a,b;
  a=atoc128("4294967296"); b=atoc128("10"); a-=b; if (!eq(a,"4294967286")) return err_check_failed(fkt, 1);
  expect_errstop=true;
  a=atoc128("10"); b=atoc128("4294967296"); a-=b;
  if (!got_errstop()) return err_check_failed(fkt, 2);
  a=atoc128("18446744073709551616"); b=atoc128("1"); a-=b; if (!eq(a,"18446744073709551615")) return err_check_failed(fkt, 4);

  return true;
}

/* --- test128_17 --- */

// Tests Int128+=Int128

static bool test128_17() {
  FKT "test128_17";

  Int128 a,b;
  a=atoi128("123456789123456789"); a+=Int128::zero; if (!eq(a,  "123456789123456789")) return err_check_failed(fkt, 1);
  a=Int128::zero; b=atoi128("123456789123456789"); a+=b; if (!eq(a,  "123456789123456789")) return err_check_failed(fkt, 2);
  a=atoi128("123456789123456789"); b=a; a+=b; if (!eq(a,  "246913578246913578")) return err_check_failed(fkt, 3);
  a=atoi128("123456789123456789"); b=a; b.neg(); a+=b; if (!a.is_zero()) return err_check_failed(fkt, 4);
  a=atoi128("123456789"); b=atoi128("-123456789123456789"); a+=b; if (!eq(a, "-123456789000000000")) return err_check_failed(fkt, 4);
  a=atoi128("-123456789123456789"); b=atoi128("123456789"); a+=b; if (!eq(a, "-123456789000000000")) return err_check_failed(fkt, 5);

  return true;
}


/* --- test128_15 --- */

static bool test128_15() {
  FKT "test128_15";

  Card128 c128, c1;
  c128 = pow2(96);
  --c128;
  if (!eq(c128, "79228162514264337593543950335")) return err_check_failed(fkt, 1);
  c1=Card64::one;
  c128 += c1;

  if (!eq(c128, "79228162514264337593543950336")) return err_check_failed(fkt, 1);

  c128 = Card128::zero;
  int e;
  for (e=0; e<128; ++e) {
    c128+=pow2(e);
  }
  expect_errstop=true;
  c128 += c1;
  if (!got_errstop()) return err_check_failed(fkt, 2);

  return true;
}

/* --- test128_14 --- */

static bool test128_14() {
  FKT "test128_14";

  Card128 c128;
  Card64 c64;
  c128 = pow2(32);
  c128-=Card64::one;
  if (!eq(c128, "4294967295")) return err_check_failed(fkt, 1);

  c128 = pow2(64);
  c128-=Card64::one;
  if (!eq(c128, "18446744073709551615")) return err_check_failed(fkt, 2);

  c128 = pow2(96);
  c128-=Card64::one;
  if (!eq(c128, "79228162514264337593543950335")) return err_check_failed(fkt, 2);

  c128 = Card128::zero;
  expect_errstop=true;
  c128-=Card64::one;
  if (!got_errstop()) return err_check_failed(fkt, 3);

  return true;
}

/* --- test128_13 --- */

static bool test128_13() {
  FKT "test128_13";

  Card128 c128;
  Card64 c64;
  c128 = pow2(70); c64=Card64(1);
  expect_errstop=true;
  c128.comp(c64);
  if (!got_errstop()) return err_check_failed(fkt, 1);

  c128=Card128(DWORD(6666));
  c64 =Card64 (DWORD(5555));
  expect_errstop=true;
  c128.comp(c64);
  if (!got_errstop()) return err_check_failed(fkt, 2);

  c64=Card64(DWORD(10), DWORD(0));
  c128=c64;
  c64 =Card64 (DWORD(5555));
  expect_errstop=true;
  c128.comp(c64);
  if (!got_errstop()) return err_check_failed(fkt, 3);

  Int128 i128;
  c64 =Card64(DWORD(1), DWORD(5555));
  c128=Card128(DWORD(6666));
  c128.comp(c64);
  i128=Int128(c128);
  if (!eq(i128, "4294966185"))  return err_check_failed(fkt, 4);
  return true;
}

/* --- test128_12 --- */

static bool test128_12() {
  FKT "test128_12";
  Card128 x;
  x = atoc128("18446744073709551615");
  x+=Card64(DWORD(1));
  if (!eq(x, "18446744073709551616")) return err_check_failed(fkt, 1);

  x = atoc128("79228162514264337593543950335");
  x+=Card64(DWORD(1));
  if (!eq(x, "79228162514264337593543950336")) return err_check_failed(fkt, 2);

  x = Card64(DWORD(1));
  x+=Card64(DWORD(1));

  expect_errstop=true;
  x=pow2(127);
  --x;
  x.dbl();
  x+=Card64(DWORD(5));
  if (!got_errstop()) return err_check_failed(fkt, 3);


  return true;
}

/* --- test128_11 --- */

static bool test128_11() {
  FKT "test128_11";

  Card128 x;
  x = atoc128("79228162514264337593543950336");
  --x;
  if (!eq(x, "79228162514264337593543950335")) return err_check_failed(fkt, 1);
  x = atoc128("18446744073709551616");
  --x;
  if (!eq(x, "18446744073709551615")) return err_check_failed(fkt, 1);
  x = atoc128("4294967296");
  --x;
  if (!eq(x, "4294967295")) return err_check_failed(fkt, 1);
  x = atoc128("1111");
  --x;
  if (!eq(x, "1110")) return err_check_failed(fkt, 1);

  return true;
}

/* --- test128_08 --- */

static bool test128_08() {
  FKT "test128_08";

  Card128 c8(DWORD(8));
  Card64 c64;
  Int128 i128;

  i128=Int128(-1, c8);
  if (i128.is_card64(c64)) return err_check_failed(fkt, 0);

  char out_nts[N_DIGIT4CARD128+1];
  i128=Int128::zero;
  if (!i128.is_card64(c64)) return err_check_failed(fkt, 1);
  to_nts(i128, out_nts, sizeof(out_nts));
  if (strcmp("0", out_nts)) return err_check_failed(fkt, 2);

  i128=Int128(1, c8);
  if (!i128.is_card64(c64)) return err_check_failed(fkt, 3);
  to_nts(i128, out_nts, sizeof(out_nts));
  if (strcmp("8", out_nts)) return err_check_failed(fkt, 4);

  const char *nts="888888888888";
  i128 = atoi128(nts);
  if (!i128.is_card64(c64)) return err_check_failed(fkt, 5);
  to_nts(i128, out_nts, sizeof(out_nts));
  if (strcmp(nts, out_nts)) return err_check_failed(fkt, 6);

  nts = "888888888888888888888888";
  i128 = atoi128(nts);
  if (i128.is_card64(c64)) return err_check_failed(fkt, 7);

  return true;
}
/* --- test128_01 --- */

static bool test128_01() {
  FKT "test128_01";
  const char *in_nts="111111111111111111111111111111111111";
  Int128 i128;

  i128 = atoi128(in_nts);

  char out_nts[N_DIGIT4INT128+1];
  to_nts(i128, out_nts, sizeof(out_nts));
  if (strcmp(in_nts, out_nts)!=0) {
    return err_check_failed(fkt, 0);
  }

  return true;
}

/* --- test128_03 --- */

static bool test128_03() {
  FKT "test128_03";
  const char *in_nts="-111111111111111111111111111111111111";
  Int128 i128;
  i128 = atoi128(in_nts);

  char out_nts[N_DIGIT4INT128+1];
  to_nts(i128, out_nts, sizeof(out_nts));
  if (strcmp(in_nts, out_nts)!=0) {
    return err_check_failed(fkt, 0);
  }

  return true;
}

/* --- test128_06 --- */

static bool test128_06() {
  FKT "test128_06";

  char out_nts[N_DIGIT4INT128+1];
  to_nts(Int128 ::zero, out_nts, sizeof(out_nts)); if (strcmp(out_nts, "0")!=0) return err_check_failed(fkt, 0);
  to_nts(Card128::zero, out_nts, sizeof(out_nts)); if (strcmp(out_nts, "0")!=0) return err_check_failed(fkt, 1);

  return true;
}

/* --- test128_07 --- */

static bool test128_07() {
  FKT "test128_07";

  Card128 c8(DWORD(8));
  Int128 i8(c8);

  char out_nts[N_DIGIT4INT128+1];
  to_nts(i8, out_nts, sizeof(out_nts)); if (strcmp(out_nts, "8")!=0) return err_check_failed(fkt, 0);

  return true;
}

/* --- test128_05 --- */

static bool test128_05() {
  FKT "test128_05";
  Card128 c128(DWORD(55555));
  Int128 i128_n (-1,c128);
  Int128 i128_0a( 0,c128);
  Int128 i128_0b( 0,Card128::zero);
  Int128 i128_0c( 1,Card128::zero);
  Int128 i128_p ( 1,c128);

  char out_nts[N_DIGIT4INT128+1];

  to_nts(i128_n , out_nts, sizeof(out_nts)); if (strcmp("-55555", out_nts)!=0) return err_check_failed(fkt, 0);
  to_nts(i128_0a, out_nts, sizeof(out_nts)); if (strcmp("0"     , out_nts)!=0) return err_check_failed(fkt, 1);
  to_nts(i128_0b, out_nts, sizeof(out_nts)); if (strcmp("0"     , out_nts)!=0) return err_check_failed(fkt, 2);
  to_nts(i128_0c, out_nts, sizeof(out_nts)); if (strcmp("0"     , out_nts)!=0) return err_check_failed(fkt, 3);
  to_nts(i128_p , out_nts, sizeof(out_nts)); if (strcmp("55555" , out_nts)!=0) return err_check_failed(fkt, 4);

  return true;
}

/* --- test128_02 --- */

static bool test128_02() {
  FKT "test128_02";
  const char *in_nts       ="111111111111111111111111111111111111";
  const char *out_check_nts="222222222222222222222222222222222222";
  Str in_str(in_nts), errtxt;
  Card128 c128;

  c128 = atoc128(in_nts);
  c128.dbl();

  char out_nts[N_DIGIT4INT128+1];
  to_nts(c128, out_nts, sizeof(out_nts));
  if (strcmp(out_nts, out_check_nts)!=0) {
    return err_check_failed(fkt, 0);
  }

  return true;
}

/* --- test128_04 --- */

static bool test128_04() {
  FKT "test128_04";
  const char *a_nts  =  "111111111111111111111111111111111111";
  const char *b_nts  =                    "111111111111111111";
  const char *d_nts  =                             "111111111";
  const char *s1_nts =  "111111111111111111222222222222222222";
  const char *s3_nts =  "111111111111111111000000000000000000";
  const char *s4_nts =                    "111111111000000000";
  const char *s6_nts = "-111111111111111111000000000000000000";

  Int128 a, d;
  Int64 b;
  a = atoi128(a_nts);
  b = atoi64 (b_nts);
  d = atoi128(d_nts);

  Int64 b_neg(b);
  b_neg.neg();

  Int128 s1;
  s1=a; s1+=b;
  if (!eq(s1, s1_nts)!=0) return err_check_failed(fkt, 0);

  Int128 s2;
  s2=a; s2+=Int64::zero;
  if (!eq(s2, a_nts)!=0) return err_check_failed(fkt, 1);

  Int128 s3;
  s3=a; s3+=b_neg;
  if (!eq(s3, s3_nts)!=0) return err_check_failed(fkt, 2);

  Int128 s4;
  s4=d; s4.neg(); s4+=b;
  if (!eq(s4, s4_nts)!=0) return err_check_failed(fkt, 3);

  Int128 s5(Int128::zero);
  s5+=b; s5.neg(); s5+=b;
  if (!eq(s5, "0")!=0) return err_check_failed(fkt, 4);

  Int128 s6(a);
  s6=a; s6.neg(); s6+=b;
  if (!eq(s6, s6_nts)!=0) return err_check_failed(fkt, 5);

  return true;
}

/* --- test128_10 --- */

static bool test128_10() {
  FKT "test128_10";

  const char *a_nts  = "111111111111111111111111";
  const char *b_nts  =            "1111111111111";

  Card128 a = atoc128(a_nts);
  Card64  b = atoc64 (b_nts);

  int cmp = cmp_card128_card64(a, b);
  if (cmp<=0) return err_check_failed(fkt, 5);

  return true;
}

/* --- test128_09 --- */

static bool test128_09() {
  FKT "test128_09";
  const char *a_nts  =  "111111111111111111111111111111111111";
  const char *b_nts  =                    "111111111111111111";
  const char *d_nts  =                             "111111111";
  const char *s1_nts =  "111111111111111111000000000000000000";
  const char *s3_nts =  "111111111111111111222222222222222222";
  const char *s4_nts =                   "-111111111000000000";
  const char *s6_nts =  "111111111111111111000000000000000000";
  const char *s7_nts =                   "-111111111111111111";
  const char *s8_nts = "-111111111111111111222222222222222222";

  Int128 a = atoi128(a_nts), d = atoi128(d_nts);
  Int64 b = atoi64(b_nts);

  Int64 b_neg(b);
  b_neg.neg();

  Int128 s1;
  s1=a; s1-=b;
  if (!eq(s1, s1_nts)!=0) return err_check_failed(fkt, 0);

  Int128 s2;
  s2=a; s2-=Int64::zero;
  if (!eq(s2, a_nts)!=0) return err_check_failed(fkt, 1);

  Int128 s3;
  s3=a; s3-=b_neg;
  if (!eq(s3, s3_nts)!=0) return err_check_failed(fkt, 2);

  Int128 s4;
  s4=d; s4-=b;
  if (!eq(s4, s4_nts)!=0) return err_check_failed(fkt, 3);

  Int128 s5(Int128::zero);
  s5+=b; s5-=b;
  if (!eq(s5, "0")!=0) return err_check_failed(fkt, 4);

  Int128 s6(a);
  s6-=b;
  if (!eq(s6, s6_nts)!=0) return err_check_failed(fkt, 5);

  Int128 s7(Int128::zero);
  s7-=b;
  if (!eq(s7, s7_nts)!=0) return err_check_failed(fkt, 5);

  Int128 s8(a);
  s8.neg(); s8-=b;
  if (!eq(s8, s8_nts)!=0) return err_check_failed(fkt, 5);

  return true;
}

/* --- eq --- */

static Card128 pow2(int exp) {
  int i;
  Card128 res(DWORD(1));

  for (i=0; i<exp; ++i) res.dbl();
  return res;
}

/* --- eq(Int128) --- */

static bool eq(const Int128 &i128, const char *nts) {
  char buff[N_DIGIT4INT128+1];
  to_nts(i128, buff, sizeof(buff));
  return strcmp(buff, nts)==0;
}

/* --- eq(Int64) --- */

static bool eq(const Int64 &i64, const char *nts) {
  char buff[N_DIGIT4INT64+1];
  to_nts(i64, buff, sizeof(buff));
  return strcmp(buff, nts)==0;
}

/* --- eq(Card64) --- */

static bool eq(const Card64 &c64, const char *nts) {
  char buff[N_DIGIT4CARD64+1];
  to_nts(c64, buff, sizeof(buff));
  return strcmp(buff, nts)==0;
}

/* --- atoc128 --- */

static Card128 atoc128(const char *nts) {
  FKT "atoc128";
  Str errtxt;
  In4Str in(nts);
  Card128 c128;
  if (!read_silent(in, c128, errtxt)) errstop(fkt, "Invalid input");
  return c128;
}

/* --- atoi128 --- */

static Int128 atoi128(const char *nts) {
  FKT "atoi128";
  Str errtxt;
  In4Str in(nts);
  Int128 i128;
  if (!read_silent(in, i128, errtxt)) errstop(fkt, "Invalid input");
  return i128;
}

/* --- atoc64 --- */

static Card64 atoc64(const char *nts) {
  FKT "atoc64";
  In4Str in(nts);
  Str errtxt;
  Card64 c64;
  if (!read_silent(in, c64, errtxt)) errstop(fkt, "Invalid input");
  return c64;
}

/* --- atoi64 --- */

static Int64 atoi64(const char *nts) {
  FKT "atoi64";
  In4Str in(nts);
  Str errtxt;
  Int64 i64;
  if (!read_silent(in, i64, errtxt)) errstop(fkt, "Invalid input");
  return i64;
}




////////////////////
// FILE brick.cpp //
////////////////////

/* === PosBrickXY ======================================================== */

/* --- hashind --- */

unsigned int PosBrickXY::hashind() const {
  return int(rotated && W_BRICK!=L_BRICK) | (x+17*y)<<1;
}

/* --- get_x_max --- */

int PosBrickXY::get_x_max() const {
  return x + (rotated ? W_BRICK : L_BRICK) - 1;
}

/* --- get_y_max --- */

int PosBrickXY::get_y_max() const {
  return y + (rotated ? L_BRICK : W_BRICK) - 1;
}


/* === exported functions ================================================ */

/* --- cmp_rotated --- */

int cmp_rotated(bool rotated_a, bool rotated_b) {
  if (rotated_a==rotated_b) return 0;
  if (L_BRICK==W_BRICK) return 0;
  return rotated_a ? 1 : -1;
}

/* --- cmp_lex_xy --- */

int cmp_lex_xy(const PosBrickXY &a, const PosBrickXY &b) {
  int res = cmp_int(a.x, b.x);
  if (res) return res;
  return cmp_int(a.y, b.y);
}

/* --- operlap(PosBrickXY) --- */

bool overlap(const PosBrickXY &a, const PosBrickXY &b) {
  int min_intersect_x = max_int(a.x, b.x), max_intersect_x = min_int(a.get_x_max(), b.get_x_max());
  int min_intersect_y = max_int(a.y, b.y), max_intersect_y = min_int(a.get_y_max(), b.get_y_max());
  return min_intersect_x<=max_intersect_x && min_intersect_y<=max_intersect_y;
}

/* --- PosBrickXY!=PosBrickXY --- */

bool operator!=(const PosBrickXY &a, const PosBrickXY &b) {
  return a.x!=b.x || a.y!=b.y || (L_BRICK!=W_BRICK && a.rotated!=b.rotated);
}

///////////////////
// FILE cgraph.h //
///////////////////

#define MY_CGRAPH_H


////////////////
// FILE str.h //
////////////////

// From c:\consql


////////////////
// FILE lst.h //
////////////////

// From kombin/dodeka




///////////////////
// FILE cgraph.h //
///////////////////

class Int64;
struct Perm;
class InBuffered;
class Out;
class Access2Db;

/* --- CompGraph4NBrick --- */

// Computes all graphs with a given number of nodes

class CompGraph4NBrick : public Comp {
  const int n_brick;
  GraphCpr *arr;
  const int n;

  public:
  CompGraph4NBrick(int n_brick, const Str &path_dir);
  ~CompGraph4NBrick();
  int get_n() const;
  void get(int i, Graph&) const;
  static bool read_evtl_filename4result(const Str &filename, int &n_brick);
  static const Str start_filename;

  // Implementation of <Comp>
  protected:
  bool init_work();
  bool run4prepared_inited();
  bool load_work  (InBuffered&);
  bool load_result(InBuffered&);
  bool save_work  (Out&) const;
  bool save_result(Out&) const;
  bool setup_lst_comp_prepare(Lst<Pt<Comp> > &lst) const;
  Str get_filename4result() const;
  Str get_filename4work() const;

  private:
  // void insert4linked4last_rek(Graph&, int n_link2last_defined);
};


/* --- CompFamGraph4Part --- */

// Computes all connected graphs for a given partition.
// The graphs are representes as classes of graph families.

class CompFamGraph4Part : public Comp {
  const Part &part;

  FamGraph stack_todo[N_BRICK_MAX*N_BRICK_MAX];
  int n_todo;

  Lst<FamGraph> lst_result;

  private:
  bool load_result(int &pos, const Str &content, const Str &filename);

  // Implementation of <Comp>
  protected:
  bool init_work();
  bool run4prepared_inited();
  bool load_work  (InBuffered&);
  bool load_result(InBuffered&);
  bool save_work  (Out&) const;
  bool save_result(Out&) const;
  bool setup_lst_comp_prepare(Lst<Pt<Comp> > &lst) const;
  public:
  Str get_filename4result() const;
  Str get_filename4work() const;

  public:
  CompFamGraph4Part(const Part&, const Str &path_dir);
  ~CompFamGraph4Part();
  int get_n() const;
  FamGraph get(int i) const;

  public:
  static bool read_evtl_filename4result(const Str &filename, Part&);
  static const Str start_filename;
};

/* --- SetFamGraph4Part --- */

class SetFamGraph4Part : public Nocopy {
  union Node;
  struct Branching {
    Node *ptr_next4overlap, *ptr_next4nooverlap, *ptr_next4mayoverlap;
  };
  struct Leaf {
    int i; // Index of the graph family
  };
  union Node {
    Leaf leaf;
    Branching branching;
  };

  const Part part;
  int n_var; // Number of variable links
  int arr_i_brick4i_var[N_BRICK_MAX*N_BRICK_MAX], arr_j_brick4i_var[N_BRICK_MAX*N_BRICK_MAX]; // Start and end node of variable links
  Node *arr_node, *ptr_start;
  int n_data_max, n_fam_graph_max, n_data, n;

  void alter_rek(Node *&ptr_start, const FamGraph&, void (*ptr_alter)(int &var, int prm), int i_var, int prm);
  int get_rek(Node *ptr_start, const FamGraph&, int i_var) const;
  bool iterate_rec(Node*, FamGraphFac&, Performer<FamGraphFac>&, int i_var) const;

  public:
  SetFamGraph4Part(const Part&, int n_fam_graph_max);
  ~SetFamGraph4Part();
  void clear();
  int get(const FamGraph&) const;
  void add(const FamGraph&, int inc);
  void set(const FamGraph&, int val);
  int get_n() const {
    return n;
  }
  bool iterate_non_zero(Performer<FamGraphFac>&) const;
  bool iterate(Performer<FamGraphFac>&) const;
  void export_non_zero(Lst<FamGraphFac>&) const;
};

/* --- CompRepFamGraph4Part --- */

// Computes representative graph families.

class CompRepFamGraph4Part : public Comp {
  const Part &part;
  Lst<FamGraphFac> lst_result;
  // const int n_bit;
  // int arr_i_brick4i_bit[N_BRICK_MAX*N_BRICK_MAX], arr_j_brick4i_bit[N_BRICK_MAX*N_BRICK_MAX];

  private:
  static int get_n_bit(const Part&);

  // Implementation of <Comp>
  protected:
  bool init_work();
  bool run4prepared_inited();
  bool load_work  (InBuffered&);
  bool load_result(InBuffered&);
  bool save_work  (Out&) const;
  bool save_result(Out&) const;
  bool setup_lst_comp_prepare(Lst<Pt<Comp> > &lst) const;
  public:
  Str get_filename4result() const;
  Str get_filename4work() const;

  public:
  CompRepFamGraph4Part(const Part&, const Str &path_dir);
  ~CompRepFamGraph4Part();
  int get_n() const;
  FamGraphFac get(int i) const;

  public:
  static bool read_evtl_filename4result(const Str &filename, Part&);
  static const Str start_filename;
};

/* --- Setter4SetFamGraph4Part --- */

class Setter4SetFamGraph4Part : public Performer<FamGraph> {
  SetFamGraph4Part &target;
  const int val;

  public:
  Setter4SetFamGraph4Part(SetFamGraph4Part &target, int val);
  bool perform(const FamGraph&);
};

/* --- FilterContained4FamGraph --- */

class FilterContained4FamGraph : public Performer<FamGraph> {
  SetFamGraph4Part &pass;
  Performer<FamGraph> &target;

  public:
  FilterContained4FamGraph(SetFamGraph4Part &pass, Performer<FamGraph> &target);
  bool perform(const FamGraph&);
};

/* --- FilterFamGraphFacNonzero --- */

class FilterFamGraphFacNonzero : public Performer<FamGraphFac> {
  Performer<FamGraphFac> &performer;

  public:
  FilterFamGraphFacNonzero(Performer<FamGraphFac>&);
  bool perform(const FamGraphFac&);
};

/* --- Permutor4FamGraph --- */

class Permutor4FamGraph : public Performer<Perm> {
  const FamGraph &fam_graph;
  Performer<FamGraph> &target;

  public:
  Permutor4FamGraph(const FamGraph&, Performer<FamGraph> &target);
  bool perform(const Perm&);
};

/* --- WriterGraphFac --- */

class WriterGraphFac : public Performer<GraphFac> {
  Out &out;
  const Str filename;

  public:
  WriterGraphFac(Out&);
  bool perform(const GraphFac&);
};

/* --- exported functions --- */

bool get_n_pos4fam_graph(const FamGraph&, Card64 &res, Str &errtxt, int size_cache_max);
bool get_n_pos(const Graph&, Card64 &n_pos, Access2Db&, bool &hit);



////////////////////
// FILE ptrimpl.h //
////////////////////

#define MY_PTRIMPL_H


////////////////
// FILE ptr.h //
////////////////

// From kombin/dodeka



////////////////////
// FILE ptrimpl.h //
////////////////////

/* --- destructor --- */

template<class T> Pt<T>::~Pt() {
  if (ptr_n_ref && --*ptr_n_ref==0) {
    delete ptr_n_ref;
    delete ptr_native;
  }
}

/* --- constructor(n_ref) --- */

template<class T> Pt<T>::Pt(T *p_ptr_native, int *p_ptr_n_ref) : ptr_n_ref(p_ptr_n_ref), ptr_native(p_ptr_native) {
  FKT "Pt<T>::Pt(T*, int*)";
  if (ptr_native==0 || ptr_n_ref==0) errstop(fkt, "ptr_native!=0 || ptr_n_ref==0");
  ++*ptr_n_ref;
}

/* --- Copy-Construktor --- */

template<class T> Pt<T>::Pt(const Pt<T> &var) : ptr_n_ref(var.ptr_n_ref), ptr_native(var.ptr_native) {
  if (ptr_n_ref) ++*ptr_n_ref;
}

/* --- *Pt --- */

template<class T> T& Pt<T>::operator*() const {
  FKT "Pt<T>::operator*()";
  if (ptr_native==0) errstop(fkt, "null pointer");
  return *ptr_native;
}

/* --- Pt-> --- */

template<class T> T* Pt<T>::operator->() const {
  FKT "Pt<T>::operator->()";
  if (ptr_native==0) errstop(fkt, "null pointer");
  return ptr_native;
}

/* --- Construktor(native) --- */

template<class T> Pt<T>::Pt(T *newed_or_null) : ptr_n_ref(newed_or_null==0 ? 0 : new int(1)), ptr_native(newed_or_null) {}

/* --- Pt=Pt --- */

template<class T> void Pt<T>::operator=(const Pt<T> &var) {

  // Attach to <var>
  if (var.ptr_n_ref) ++*var.ptr_n_ref;

  // Detach from this
  if (ptr_n_ref && --*ptr_n_ref==0) {
    delete ptr_n_ref;
    delete ptr_native;
  }

  // Copy pointer
  ptr_n_ref  = var.ptr_n_ref ;
  ptr_native = var.ptr_native;
}


/* === exported functions ================================================ */

/* --- convert --- */

template<class D, class B> void convert(Pt<D> pt_derived, Pt<B> &pt_base) {
  if (pt_derived.is_null()) {
    pt_base=Pt<B>();
  } else {
    pt_base = Pt<B>(pt_derived.get_pt_native(), pt_derived.get_pt_n_ref());
  }
}


////////////////////
// FILE setimpl.h //
////////////////////

// From c:\kombin\lego2\footprnt


////////////////////
// FILE mapimpl.h //
////////////////////

// Taken fron lego4


///////////////////
// FILE bigint.h //
///////////////////

// From lego4


/////////////////
// FILE perm.h //
/////////////////

#define MY_PERM_H


////////////////
// FILE set.h //
////////////////

// From c:\kombin\lego2\footprnt



/////////////////
// FILE perm.h //
/////////////////

/* --- Perm --- */

struct Perm {
  const int n;
  int* const data;

  Perm(int n, int *data);
  
  static bool iterate(int n, Performer<Perm>&);
  unsigned int hashind() const;
  void set_i(int);
  int get_i() const;

  private:
  static bool iterate_rek(Perm&, int i, bool *arr_used, Performer<Perm>&);

  friend bool operator==(const Perm&, const Perm&);
    
};

/* --- SetPerm --- */

class SetPerm {
  SetInt inner;
  const int n;

  public:
  SetPerm(int n);
  bool iterate(Performer<Perm>&) const;
  void clear();
  void insert(const Perm&);
};

/* --- TransformerInt2Perm --- */

class TransformerInt2Perm : public Performer<int> {
  Performer<Perm> &inner;
  const int n;

  public:
  TransformerInt2Perm(int n, Performer<Perm> &inner);
  bool perform(const int&);
};


////////////////
// FILE fun.h //
////////////////

#define MY_FUN_H


////////////////
// FILE ptr.h //
////////////////

// From kombin/dodeka


////////////////
// FILE lst.h //
////////////////

// From kombin/dodeka


////////////////
// FILE map.h //
////////////////

// Taken from lego4


/////////////////
// FILE mdim.h //
/////////////////

#define MY_MDIM_H


/* --- MDim --- */

class MDim : public Nocopy {
  int arr_lb[N_BRICK_MAX], arr_l[N_BRICK_MAX], *arr, arr_i_var[N_BRICK_MAX], n_var, n_elem;

  public:
  MDim(const int *arr_lb, const int *arr_ub, const int *arr_i_var, int n_dim);
  ~MDim();
  int &get_ref(int *arr_var);
  void set_all(int val);
};

/* --- CacheDword4Bound --- */

class CacheDword4Bound : public Nocopy {
  int arr_lb[N_BRICK_MAX], arr_l[N_BRICK_MAX], arr_i_var[N_BRICK_MAX], n_dim, n_elem;
  DWORD *arr;

  public:
  CacheDword4Bound(const int *arr_lb, const int *arr_ub, const bool *arr_is_prm, int n_brick);
  ~CacheDword4Bound();
  DWORD &get_ref(const int *arr_var);
  static double get_size(const int *arr_lb, const int *arr_ub, const bool *arr_is_prm, int n_brick);
  void set_all(DWORD val);
};



////////////////
// FILE fun.h //
////////////////

class Graph;

#define N_VAR_MAX N_BRICK_MAX
#define STATUS_VAR_UNUSED 0
  // A variable in this status will not be changed and not influence tghe result by <FunArrPosPartial2Dword>
#define STATUS_VAR_PRM  1
  // A variable in this status will not be changed, but it will influence the result by <FunArrPosPartial2Dword>
#define STATUS_VAR_FREE 2
  // A variable in this status will be changed and will not influence the result by <FunArrPosPartial2Dword>

/* --- FunArrPosPartial2Dword --- */

class FunArrPosPartial2Dword {

  private:
  static Pt<FunArrPosPartial2Dword> create_rek(const Graph&, const bool *arr_rotated, const bool *arr_brick_prm, const bool *arr_brick_considered, char dir);
  static void set_comp_conn(const Graph&, const bool *arr_brick_considered, int *arr, int i_brick_start, int i_conn_comp);
  static void get_comp_conn(const Graph&, const bool *arr_brick_considered, int *arr, int &n);

  public:
  const int n_var;
  FunArrPosPartial2Dword(int n_var);
  virtual ~FunArrPosPartial2Dword();
  double get_size_cache() const;
  // void dim_cache(int size_cache_max);
  // int get_n_prm() const;
  virtual DWORD eval(int *arr_koor) const=0;
  virtual void append_lst_size_cache(Lst<double>&) const=0;
  // virtual void dim_cache_rek(int *arr_size, bool *arr_used, int n_size)=0;
  virtual int get_status_var(int i_var) const=0;
};

typedef Pt<FunArrPosPartial2Dword> PtFunArrPosPartial2Dword;

/* --- FunArrPosPartial2DwordCached --- */

class FunArrPosPartial2DwordCached : public FunArrPosPartial2Dword {
  const PtFunArrPosPartial2Dword pt_fun;
  FunArrPosPartial2Dword &fun;
  const int n_prm, i_prm_first;
  const char dir; // 'x' or 'y'
  int arr_ub[N_VAR_MAX], arr_lb[N_VAR_MAX];
  bool arr_is_prm4var[N_VAR_MAX];
  double size_cache;
  Pt<CacheDword4Bound> pt_cache;
  
  private:
  void set_ub_rek(int i_var, int ub, bool *arr_set, const Graph&, const bool *arr_rotated);
  void set_lb_rek(int i_var, int lb, bool *arr_set, const Graph&, const bool *arr_rotated);

  // Implementation of FunArrPosPartial2Dword
  public:
  DWORD eval(int *arr_koor) const;
  // void dim_cache_rek(int *arr_size, bool *arr_used, int n_size);
  void append_lst_size_cache(Lst<double>&) const;
  int get_status_var(int i_var) const;
  double get_size_cache_own() const {
    return size_cache;
  }
  void dim_cache();

  public:
  FunArrPosPartial2DwordCached(const Graph&, const bool *arr_rotated, const PtFunArrPosPartial2Dword&, char dir);
};

typedef Pt<FunArrPosPartial2DwordCached> PtFunArrPosPartial2DwordCached;

/* --- FunArrPosPartial2DwordSumOverVar --- */

class FunArrPosPartial2DwordSumOverVar : public FunArrPosPartial2Dword {
  const int i_var;
  const PtFunArrPosPartial2Dword pt_fun;
  FunArrPosPartial2Dword &fun;
  int n_prm, arr_lb_shift4prm[N_VAR_MAX], arr_ub_shift4prm[N_VAR_MAX], arr_i_var4prm[N_VAR_MAX];

  // Implementation of FunArrPosPartial2Dword
  public:
  DWORD eval(int *arr_koor) const;
  void append_lst_size_cache(Lst<double>&) const;
  // void dim_cache_rek(int *arr_size, bool *arr_used, int n_size);
  int get_status_var(int i_var) const;

  public:
  FunArrPosPartial2DwordSumOverVar(int i_var, const PtFunArrPosPartial2Dword&, const Graph &graph, const bool *arr_rotated, char dir); 
};

/* --- FunArrPosPartial2DwordAddPrm --- */

// Some unused variables are declared as parameters or as free.

class FunArrPosPartial2DwordAddPrm : public FunArrPosPartial2Dword {
  int arr_status_var[N_VAR_MAX];
  const PtFunArrPosPartial2Dword pt_fun;
  FunArrPosPartial2Dword &fun;

  // Implementation of FunArrPosPartial2Dword
  public:
  DWORD eval(int *arr_koor) const;
  void append_lst_size_cache(Lst<double>&) const;
  // void dim_cache_rek(int *arr_size, bool *arr_used, int n_size);
  int get_status_var(int i_var) const;

  public:
  FunArrPosPartial2DwordAddPrm(const int *arr_var_status, const PtFunArrPosPartial2Dword&); 
};

/* --- FunArrPosPartial2DwordProd --- */

class FunArrPosPartial2DwordProd : public FunArrPosPartial2Dword {
  const PtFunArrPosPartial2Dword pt_fun_a, pt_fun_b;
  FunArrPosPartial2Dword &fun_a, &fun_b;
  int arr_status_var[N_VAR_MAX];

  // Implementation of FunArrPosPartial2Dword
  public:
  DWORD eval(int *arr_koor) const;
  void append_lst_size_cache(Lst<double>&) const;
  // void dim_cache_rek(int *arr_size, bool *arr_used, int n_size);
  int get_status_var(int i_var) const;
  
  // The single instance
  public:
  FunArrPosPartial2DwordProd(const PtFunArrPosPartial2Dword&, const PtFunArrPosPartial2Dword&);
};

/* --- FunArrPosPartial2Dword1 --- */

class FunArrPosPartial2Dword1 : public FunArrPosPartial2Dword {
  int arr_status_var[N_VAR_MAX];

  // Implementation of FunArrPosPartial2Dword
  public:
  FunArrPosPartial2Dword1(const int *arr_status_var, int n_var);
  DWORD eval(int *arr_koor) const;
  void append_lst_size_cache(Lst<double>&) const;
  // void dim_cache_rek(int *arr_size, bool *arr_used, int n_size);
  int get_status_var(int i_var) const;  
};

/* --- ArrStatusVarRotated --- */

struct ArrStatusVarRotated {
  int arr_status_var[N_VAR_MAX];
  int arr_extend   [N_VAR_MAX]; // Extension of the brick; either <L_BRICK> or <W_BRICK>

  // void operator=(const ArrStatusVarRotated&);
  ArrStatusVarRotated();
  ArrStatusVarRotated(const int *arr_status_var, const bool *arr_rotated, int n_var, char dir);
};

/* --- MapFunCached --- */

class MapFunCached : public Map<ArrStatusVarRotated, PtFunArrPosPartial2DwordCached> {
  const int n_var;

  private:
  unsigned int hashind(const ArrStatusVarRotated&) const;
  bool equal(const ArrStatusVarRotated&, const ArrStatusVarRotated&) const;

  public:
  MapFunCached(int n_var);
};

/* --- FunArrDelta2Dword --- */

class FunArrDelta2Dword : public Nocopy {
  public:
  virtual DWORD eval(int *arr_delta) const=0;
  virtual ~FunArrDelta2Dword();
};

typedef Pt<FunArrDelta2Dword> PtFunArrDelta2Dword;

/* --- FunArrDelta2Dword1 --- */

class FunArrDelta2Dword1 : public FunArrDelta2Dword {
  DWORD eval(int *arr_delta) const;
};

/* --- FunCachedArrDelta2Dword --- */

class FunCachedArrDelta2Dword : public FunArrDelta2Dword {
  PtFunArrDelta2Dword pt_cached;
  FunArrDelta2Dword &cached;
  int arr_i_delta4depend_on[N_BRICK_MAX], arr_lb4depend_on[N_BRICK_MAX];
  int arr_l[N_BRICK_MAX]; // Array dimensions
  const int n_depend_on;
  DWORD *data_cache;
  
  public:
  FunCachedArrDelta2Dword(const int *arr_i_delta4depend_on, const int *arr_lb4depend_on, const int *arr_ub4depend_on, int n_depend_on, PtFunArrDelta2Dword pt_cached);
  ~FunCachedArrDelta2Dword();
  DWORD eval(int *arr_delta) const;
};

/* --- FunCheckRangeArrDelta2Dword --- */

class FunCheckRangeArrDelta2Dword : public FunArrDelta2Dword {
  const int n_i_delta, ub,lb;
  int arr_i_delta[N_BRICK_MAX], arr_fac4i_delta[N_BRICK_MAX];
  const PtFunArrDelta2Dword pt_checked;
  FunArrDelta2Dword &checked;

  public:
  FunCheckRangeArrDelta2Dword(const int *arr_i_delta, const int *arr_fac4i_delta, int n_i_delta, int lb, int ub, const PtFunArrDelta2Dword &pt_checked);
  DWORD eval(int *arr_delta) const;
};

/* --- FunSumArrDelta2Dword --- */

class FunSumArrDelta2Dword : public FunArrDelta2Dword {
  const int ub,lb, i_delta;
  const PtFunArrDelta2Dword pt_summed;
  FunArrDelta2Dword &summed;

  public:
  FunSumArrDelta2Dword(int i_delta, int lb, int ub, const PtFunArrDelta2Dword &pt_summed);
  DWORD eval(int *arr_delta) const;
};

/* --- FunArrRotated2FunArrDelta2Dword --- */

class FunArrRotated2FunArrDelta2Dword : public Nocopy {
  public:
  const int n_delta;
  FunArrRotated2FunArrDelta2Dword(int n_delta);
  virtual PtFunArrDelta2Dword eval(char dir, const bool *arr_rotated) const=0;
  virtual ~FunArrRotated2FunArrDelta2Dword();
  virtual bool depends_on(int i_delta) const=0;
};

typedef Pt<FunArrRotated2FunArrDelta2Dword> PtFunArrRotated2FunArrDelta2Dword;

/* --- FunArrRotated2FunArrDelta2Dword1 --- */

class FunArrRotated2FunArrDelta2Dword1 : public FunArrRotated2FunArrDelta2Dword {
  public:
  FunArrRotated2FunArrDelta2Dword1(int n_delta);
  PtFunArrDelta2Dword eval(char dir, const bool *arr_rotated) const;
  bool depends_on(int i_delta) const;
};

/* --- FunArrRotated2FunCheckRangeArrDelta2Dword --- */

class FunArrRotated2FunCheckRangeArrDelta2Dword : public FunArrRotated2FunArrDelta2Dword {
  const int i_brick_pred, i_brick;
  int n_i_delta, arr_i_delta[N_BRICK_MAX], arr_fac4i_delta[N_BRICK_MAX], arr_fac4delta[N_BRICK_MAX];
  const PtFunArrRotated2FunArrDelta2Dword pt_checked;

  public:
  FunArrRotated2FunCheckRangeArrDelta2Dword(const int *arr_fac4delta, int i_brick, int j_brick, PtFunArrRotated2FunArrDelta2Dword);
  PtFunArrDelta2Dword eval(char dir, const bool *arr_rotated) const;
  bool depends_on(int i_delta) const;
};


/* --- FunArrRotated2FunSumArrDelta2Dword --- */

class FunArrRotated2FunSumArrDelta2Dword : public FunArrRotated2FunArrDelta2Dword {
  const int i_brick_pred, i_brick;
  PtFunArrRotated2FunArrDelta2Dword pt_summed;

  public:
  FunArrRotated2FunSumArrDelta2Dword(int i_brick_pred, int i_brick, const PtFunArrRotated2FunArrDelta2Dword &pt_summed);
  PtFunArrDelta2Dword eval(char dir, const bool *arr_rotated) const;
  bool depends_on(int i_delta) const;
};

/* --- FunArrRotated2FunCachedArrDelta2Dword --- */

class FunArrRotated2FunCachedArrDelta2Dword : public FunArrRotated2FunArrDelta2Dword {
  const PtFunArrRotated2FunArrDelta2Dword pt_cached;
  int arr_i_brick_pred[N_BRICK_MAX];

  public:
  FunArrRotated2FunCachedArrDelta2Dword(int arr_i_brick_pred[N_BRICK_MAX], const PtFunArrRotated2FunArrDelta2Dword &pt_cached);
  PtFunArrDelta2Dword eval(char dir, const bool *arr_rotated) const;
  bool depends_on(int i_delta) const;
};

/* --- exported functions --- */

PtFunArrPosPartial2Dword create_fun_n_sol4graph(int i_brick_start, const Graph&, const bool *arr_rotated, char dir, MapFunCached&);



/////////////////////
// FILE cgraph.cpp //
/////////////////////

/* === FamGraphFac ======================================================= */

/* --- default constructor --- */

FamGraphFac::FamGraphFac() {}

/* --- constructor(n_brick) --- */

FamGraphFac::FamGraphFac(int n_brick) : fam_graph(n_brick) {}


/* === WriterGraphFac ==================================================== */

/* --- constructor --- */

WriterGraphFac::WriterGraphFac(Out &p_out) : out(p_out) {}

/* --- perform --- */

bool WriterGraphFac::perform(const GraphFac &graph_fac) {
  char buff_fac[N_DIGIT4INT64+1];
  if (!out.printf("$*", to_nts(graph_fac.fac, buff_fac, sizeof(buff_fac)))) return false;
  if (!graph_fac.graph.write(out)) return false;
  if (!out.print_char('\n')) return false;
  return true;
}


/* === CompGraph4NBrick ==================================================== */

/* --- static members --- */

const Str CompGraph4NBrick::start_filename("graph4nbrick(");

/* --- init_work --- */

bool CompGraph4NBrick::init_work() {
  return true;
}

/* --- run4prepared_inited --- */

bool CompGraph4NBrick::run4prepared_inited() {
  FKT "CompGraph4NBrick::run4prepared_inited";

  SetGraphCprEquiv set_result;
  Str errtxt;
  log("Compute graphs with $ nodes...", n_brick);
  if (n_brick==1) {
    Graph graph(1);
    if (!set_result.insert(graph, errtxt)) return err(errtxt);
  } else {
    int n_brick_prev=n_brick-1;
    CompGraph4NBrick comp_prev(n_brick_prev, path_dir);
    if (!comp_prev.run()) return false;
    if (!comp_prev.is_complete()) {
      return err(Str("File ") + enquote(comp_prev.get_path4result()) + Str(" not computed"));
    }

    int n_prev = comp_prev.get_n(), i_prev;
    int i_brick, j_brick;
    log_progress_start("Verarbeite Vorgaenger-Graphen...");
    for (i_prev=0; i_prev<n_prev; ++i_prev) {
      Graph graph_prev(n_brick_prev);
      comp_prev.get(i_prev, graph_prev);

      Graph graph(n_brick);
      for (i_brick=0; i_brick<n_brick_prev; ++i_brick) {
        for (j_brick=0; j_brick<i_brick; ++j_brick) {
          graph.set_linked(i_brick, j_brick, graph_prev.is_linked(i_brick, j_brick));
        }
      }

      bool arr_linked2last[N_BRICK_MAX-1];
      set(arr_linked2last, n_brick_prev, false);
      adv(arr_linked2last, n_brick_prev);
      while (true) {

        i_brick = n_brick_prev;
        for (j_brick=0; j_brick<i_brick; ++j_brick) {
          graph.set_linked(i_brick, j_brick, arr_linked2last[j_brick]);
        }

        if (!set_result.insert(graph, errtxt)) return err(errtxt);

        if (is(arr_linked2last, n_brick_prev, true)) {
          break;
        }
        adv(arr_linked2last, n_brick_prev);
      }
      if (i_prev>0) log_progress("Processed $/$ predecessor graphs ($).", i_prev, n_prev);
    }
    log_progress_end("Processed all predecessor graphs.");
  }
  log("Computde graphs with $ nodes.", n_brick);

  // Allokiere Array
  if (n!=set_result.get_n()) errstop(fkt, "Number of graphs wrong");
  arr = new GraphCpr[n];
  if (arr==0) errstop_memoverflow(fkt);

  Storer<GraphCpr> storer(arr, n);
  log("Sort all graphs with $ nodes...", n_brick);
  if (!set_result.iterate(storer)) return false;
  qsort(arr, n, sizeof(*arr), &cmp_graph_cpr4qsort);
  log("Sorted graphs with $ nodes.", n_brick);

  return set_complete();
}

/* --- constructor --- */

CompGraph4NBrick::CompGraph4NBrick(int p_n_brick, const Str &path_dir) : Comp(path_dir), n_brick(p_n_brick), arr(0), n(get_n_graph_conn4n_brick(p_n_brick)) {
  FKT "CompGraph4NBrick::CompGraph4NBrick";
  if (!(1<=n_brick && n_brick<=N_BRICK_MAX)) errstop(fkt, "n_brick out of range");
}

/* --- get --- */

void CompGraph4NBrick::get(int i, Graph &graph) const {
  FKT "CompGraph4NBrick::get";

  if (!(is_complete() && arr!=0)) errstop(fkt, "Computation not accomplished");
  if (!(0<=i && i<n)) errstop_index(fkt);
  arr[i].get(graph);
}

/* --- get_n --- */

int CompGraph4NBrick::get_n() const {
  return n;
}

/* --- load_work --- */

bool CompGraph4NBrick::load_work(InBuffered&) {
  return true;
}

/* --- setup_lst_comp_prepare --- */

bool CompGraph4NBrick::setup_lst_comp_prepare(Lst<PtComp> &lst) const {
  lst.clear();

  if (n_brick>1) {
    PtComp pt_comp = new CompGraph4NBrick(n_brick-1, path_dir);
    lst.append(pt_comp);
  }

  return true;
}

/* --- destructor --- */

CompGraph4NBrick::~CompGraph4NBrick() {
  if (arr) delete[] arr;
}

/* --- save_work --- */

bool CompGraph4NBrick::save_work(Out&) const {
  return true;
}

/* --- load_result --- */

bool CompGraph4NBrick::load_result(InBuffered &in) {
  FKT "CompGraph4NBrick::load_result";
  int i;

  if (arr!=0) delete[] arr;
  arr = new GraphCpr[n];
  if (arr==0) errstop_memoverflow(fkt);

  for (i=0; i<n; ++i) {
    Graph graph;
    if (!read_fast(in, n_brick, graph)) return false;
    if (!graph.is_connected()) {
      return in.In::err_at("Graph ist nicht zusammenhaengend");
    }
    if (!in.read_eoln()) return false;

    arr[i] = GraphCpr(graph);

    if (i>0 && cmp(arr[i-1], arr[i])>=0) {
      return in.In::err_at("Graph kommt alphabetisch nicht nach seinem Vorgaenger");
    }
  }

  return true;
}

/* --- save_result --- */

bool CompGraph4NBrick::save_result(Out &out) const {
  // FKT "CompGraph4NBrick::save_result";

  int i;
  // if (!out.printf("n=$\n", n)) return false;
  for (i=0; i<n; ++i) {
    Graph graph(n_brick);
    arr[i].get(graph);
    if (!(graph.write_fast(out) && out.print_eoln())) {
      return false;
    }
  }

  return true;
}

/* --- read_evtl_filename4result --- */

// graph4nbrick($nbrick).dat

bool CompGraph4NBrick::read_evtl_filename4result(const Str &filename, int &n_brick) {
  In4Str in(filename);

  if (!in.read_evtl_str_given(start_filename)) return false;
  if (!in.read_evtl_card(n_brick)) return false;
  if (!in.read_evtl_str_given(c_end_filename_result)) return false;

  return in.at_end();
}

/* --- get_filename4work --- */

Str CompGraph4NBrick::get_filename4work() const {
  return start_filename+str4card(n_brick)+c_end_filename_work;
}

/* --- get_filename4result --- */

Str CompGraph4NBrick::get_filename4result() const {
  return start_filename+str4card(n_brick)+c_end_filename_result;
}

/* === CompFamGraph4Part ==================================================== */

/* --- static members --- */

const Str CompFamGraph4Part::start_filename("famgraph4part(");

/* --- constructor --- */

CompFamGraph4Part::CompFamGraph4Part(const Part &p_part, const Str &path_dir) : Comp(path_dir), part(p_part) {}

/* --- setup_lst_comp_prepare --- */

bool CompFamGraph4Part::setup_lst_comp_prepare(Lst<PtComp> &lst) const {
  lst.clear();
  return true;
}

/* --- save_work --- */

bool CompFamGraph4Part::save_work(Out &out) const {
  if (!out.printf("ntodo=$\n", n_todo)) return false;

  int i_todo;
  for (i_todo=0; i_todo<n_todo; ++i_todo) {
    if (!stack_todo[i_todo].write(out)) return false;
    if (!out.print_char('\n')) return false;
  }

  if (!save_result(out)) return false;

  return true;
}


/* --- load_work --- */

bool CompFamGraph4Part::load_work(InBuffered &in) {

  if (!in.read_str_given(c_ntodo_eq)) return false;
  if (!in.read_card(n_todo)) return false;
  if (!in.read_eoln()) return false;
  if (n_todo*sizeof(stack_todo[0])>sizeof(stack_todo)) return err("n_todo too large");

  int i_todo, n_brick = part.get_n_brick();
  for (i_todo=0; i_todo<n_todo; ++i_todo) {
    if (!read(in, n_brick, stack_todo[i_todo])) return false;
    if (!in.read_eoln()) return false;
  }

  if (!load_result(in)) return false;

  return true;
}

/* --- save_result --- */

bool CompFamGraph4Part::save_result(Out &out) const {

  int n = lst_result.get_n();
  if (!out.printf("n=$\n", n)) return false;

  int i;
  for (i=0; i<n; ++i) {
    FamGraph fam_graph = lst_result.get(i);
    if (!fam_graph.write(out)) return false;
    if (!out.print_char('\n')) return false;
  }

  return true;
}

/* --- load_result(private) --- */

bool CompFamGraph4Part::load_result(InBuffered &in) {
  int n, i;

  if (!in.read_str_given(c_n_eq)) return false;
  if (!in.read_card(n)) return false;
  if (!in.read_eoln()) return false;

  int n_brick=part.get_n_brick();
  for (i=0; i<n; ++i) {
    FamGraph fam_graph;
    if (!read(in, n_brick, fam_graph)) return false;
    if (!fam_graph.is_conform(part)) return in.In::err_at("Graph-Familie ist nicht konform zur Partition");
    if (!in.read_eoln()) return false;
    lst_result.append(fam_graph);
  }
  return true;
}

/* --- destructor --- */

CompFamGraph4Part::~CompFamGraph4Part() {}

/* --- read_evtl_filename4result --- */

// graph4part($part).dat

bool CompFamGraph4Part::read_evtl_filename4result(const Str &filename, Part &part) {
  In4Str in(filename);

  if (!in.read_evtl_str_given(start_filename)) return false;
  if (!read_evtl(in, part)) return false;
  if (!in.read_evtl_str_given(c_end_filename_result)) return false;

  return in.at_end();
}

/* --- get_filename4result --- */

Str CompFamGraph4Part::get_filename4result() const {
  return start_filename+part.to_str()+c_end_filename_result;
}

/* --- get_filename4work --- */

Str CompFamGraph4Part::get_filename4work() const {
  return start_filename+part.to_str()+c_end_filename_work;
}

/* --- init_work --- */

bool CompFamGraph4Part::init_work() {
  int n_brick = part.get_n_brick();

  int arr_i_layer4brick[N_BRICK_MAX];
  part.get_arr_i_layer4brick(arr_i_layer4brick);

  int i_brick, j_brick;
  FamGraph fam_graph(n_brick);
  for (i_brick=0; i_brick<n_brick; ++i_brick) {
    for (j_brick=0; j_brick<i_brick; ++j_brick) {
      fam_graph.set_overlap(i_brick, j_brick, arr_i_layer4brick[i_brick]==arr_i_layer4brick[j_brick] ? NOOVERLAP_BRICK : MAYOVERLAP_BRICK);
    }
  }

  stack_todo[0]=fam_graph;
  n_todo=1;

  return true;
}

/* --- get_n --- */

int CompFamGraph4Part::get_n() const {
  FKT "CompFamGraph4Part::get_n";

  if (!is_complete()) errstop(fkt, "Berechnung nicht durchgefuehrt");
  return lst_result.get_n();
}

/* --- get --- */

FamGraph CompFamGraph4Part::get(int i) const {
  FKT "CompFamGraph4Part::get";

  if (!is_complete()) errstop(fkt, "Berechnung nicht durchgefuehrt");
  return lst_result.get(i);
}

/* --- run4prepared_inited --- */

bool CompFamGraph4Part::run4prepared_inited() {
  FKT "CompFamGraph4Part::run4prepared_inited";

  int arr_i_layer4brick[N_BRICK_MAX];
  part.get_arr_i_layer4brick(arr_i_layer4brick);

  int n_brick = part.get_n_brick();
  while (n_todo>0) {

    // Pop a unconnected graph family
    FamGraph fam_graph = stack_todo[n_todo-1];
    --n_todo;

    // If surely not connected, skip
    if (fam_graph.is_not_connected_sure(arr_i_layer4brick)) continue;

    // Separate in connection components
    int arr_i_comp[N_BRICK_MAX], n_comp;
    fam_graph.get_arr_i_comp_conn_sure(arr_i_comp, n_comp);

    // If surely connected, put graph family into set
    if (n_comp==1) {
      lst_result.append(fam_graph);
      continue;
    }

    // From here on, <fam_graph> is not surely connected

    // Find a pair of bricks in neighbored layers connecting to connection components
    int i_brick, j_brick;
    bool found=false;
    for (i_brick=0, found=false; i_brick<n_brick; ++i_brick) {
      for (j_brick=0; j_brick<i_brick; ++j_brick) {
        if (
          abs(arr_i_layer4brick[i_brick]-arr_i_layer4brick[j_brick])==1 &&
          fam_graph.get_overlap(i_brick, j_brick)==MAYOVERLAP_BRICK &&
          arr_i_comp[i_brick]!=arr_i_comp[j_brick]
        ) {
          found=true;
          break;
        }
      }
      if (found) break;
    }
    if (!found) {
      return err("No connecting pair found");
    }

    // put derived graphs on todo stack
    if ((n_todo+2)*sizeof(stack_todo[0])>sizeof(stack_todo)) errstop(fkt, "Stack overflow");
    fam_graph.set_overlap(i_brick, j_brick, NOOVERLAP_BRICK); stack_todo[n_todo]=fam_graph; ++n_todo;
    fam_graph.set_overlap(i_brick, j_brick, OVERLAP_BRICK  ); stack_todo[n_todo]=fam_graph; ++n_todo;

    if (check_stopped()) return true;
  }

  return set_complete();
}


/* === SetFamGraph4Part ======================================================= */

/* --- export_non_zero --- */

void SetFamGraph4Part::export_non_zero(Lst<FamGraphFac> &lst) const {
  Appender<FamGraphFac> appender(lst);
  FilterFamGraphFacNonzero filter(appender);
  lst.clear();
  iterate_non_zero(filter);
}

/* --- destructor --- */

SetFamGraph4Part::~SetFamGraph4Part() {
  if (arr_node!=0) delete[] arr_node;
}

/* --- clear --- */

void SetFamGraph4Part::clear() {
  n_data=n=0;
  ptr_start=0;
}

/* --- get --- */

int SetFamGraph4Part::get(const FamGraph &fam_graph) const {
  return get_rek(ptr_start, fam_graph, 0);
}

/* --- add --- */

void SetFamGraph4Part::add(const FamGraph &fam_graph, int inc) {
  alter_rek(ptr_start, fam_graph, &add2int, 0, inc);
}

/* --- set --- */

void SetFamGraph4Part::set(const FamGraph &fam_graph, int val) {
  alter_rek(ptr_start, fam_graph, &set_int, 0, val);
}
/* --- constructor --- */

SetFamGraph4Part::SetFamGraph4Part(const Part &p_part, int p_n_fam_graph_max) :
  part(p_part),
  ptr_start(0),
  n_fam_graph_max(p_n_fam_graph_max),
  n_data(0),
  n(0)
{
  FKT "SetFamGraph4Part::SetFamGraph4Part";

  // Compute <n_var>, <arr_i_brick4i_var>, <arr_i_brick4j_var>
  int i_brick, j_brick, arr_i_layer4i_brick[N_BRICK_MAX], n_brick=part.get_n_brick();
  part.get_arr_i_layer4brick(arr_i_layer4i_brick);
  n_var=0;
  for (i_brick=0; i_brick<n_brick; ++i_brick) {
    for (j_brick=0; j_brick<i_brick; ++j_brick) {
      if (arr_i_layer4i_brick[j_brick]+1 == arr_i_layer4i_brick[i_brick]) {
        if (n_var*sizeof(int)>=sizeof(arr_i_brick4i_var) || n_var*sizeof(int)>=sizeof(arr_j_brick4i_var)) errstop(fkt, "n_var zu gross");
        arr_i_brick4i_var[n_var] = i_brick;
        arr_j_brick4i_var[n_var] = j_brick;
        ++n_var;
      }
    }
  }

  // Alloc <arr_data>
  n_data_max = n_fam_graph_max*(n_var+1);
  arr_node = new Node[n_data_max];
  if (arr_node==0) errstop_memoverflow(fkt);
}

/* --- iterate --- */

bool SetFamGraph4Part::iterate(Performer<FamGraphFac> &performer) const {
  FamGraphFac fam_graph_fac(part.get_n_brick());
  return iterate_rec(ptr_start, fam_graph_fac, performer, 0);
}

/* --- iterate_non_zero --- */

bool SetFamGraph4Part::iterate_non_zero(Performer<FamGraphFac> &performer) const {
  FilterFamGraphFacNonzero filter(performer);
  return iterate(filter);
}

/* --- iterate_rec --- */

bool SetFamGraph4Part::iterate_rec(Node *ptr_node, FamGraphFac &fam_graph_fac, Performer<FamGraphFac> &performer, int i_var) const {
  if (ptr_node==0) return true;

  Node &node = *ptr_node;
  if (i_var==n_var) {
    fam_graph_fac.fac = node.leaf.i;
    return performer.perform(fam_graph_fac);
  }

  Branching &br = node.branching;
  FamGraph &f = fam_graph_fac.fam_graph;
  int i_brick = arr_i_brick4i_var[i_var];
  int j_brick = arr_j_brick4i_var[i_var];
  f.set_overlap(i_brick, j_brick,    OVERLAP_BRICK); if (!iterate_rec(br.ptr_next4overlap   , fam_graph_fac, performer, i_var+1)) return false;
  f.set_overlap(i_brick, j_brick,  NOOVERLAP_BRICK); if (!iterate_rec(br.ptr_next4nooverlap , fam_graph_fac, performer, i_var+1)) return false;
  f.set_overlap(i_brick, j_brick, MAYOVERLAP_BRICK); if (!iterate_rec(br.ptr_next4mayoverlap, fam_graph_fac, performer, i_var+1)) return false;

  return true;
}

/* --- alter_rek --- */

void SetFamGraph4Part::alter_rek(Node *&ptr_node, const FamGraph &fam_graph, void (*ptr_alter)(int &var, int prm), int i_var, int prm) {
  FKT "SetFamGraph4Part::alter_rek";

  // Alloc node if not yet happended
  if (ptr_node==0) {
    if (n_data>=n_data_max) errstop(fkt, "Zu viele Eintraege");
    ptr_node=arr_node+n_data;
    ++n_data;

    // Increment n if new leaf
    if (i_var==n_var) {
      ++n;
    }

    // Initialize data element
    if (i_var<n_var) {
      Branching &branching = ptr_node->branching;
      branching.ptr_next4overlap = branching.ptr_next4nooverlap = branching.ptr_next4mayoverlap = 0;
    } else {
      ptr_node->leaf.i=0;
    }
  }

  // Handle leaf case
  if (i_var==n_var) {
    (*ptr_alter)(ptr_node->leaf.i, prm);
    return;
  }

  // From here on: no leaf

  // recursion
  Branching &branching = ptr_node->branching;
  switch (fam_graph.get_overlap(arr_i_brick4i_var[i_var], arr_j_brick4i_var[i_var])) {
    case OVERLAP_BRICK   : alter_rek(branching.ptr_next4overlap   , fam_graph, ptr_alter, i_var+1, prm); break;
    case NOOVERLAP_BRICK : alter_rek(branching.ptr_next4nooverlap , fam_graph, ptr_alter, i_var+1, prm); break;
    case MAYOVERLAP_BRICK: alter_rek(branching.ptr_next4mayoverlap, fam_graph, ptr_alter, i_var+1, prm); break;
    default: errstop(fkt, "get_overlap ungueltig");
  }
}

/* --- get_rek --- */

int SetFamGraph4Part::get_rek(Node *ptr_node, const FamGraph &fam_graph, int i_var) const {
  FKT "SetFamGraph4Part::get_rek";

  if (ptr_node==0) return 0;
  if (i_var==n_var) {
    return ptr_node->leaf.i;
  }

  // recursion
  Branching &branching = ptr_node->branching;
  switch (fam_graph.get_overlap(arr_i_brick4i_var[i_var], arr_j_brick4i_var[i_var])) {
    case OVERLAP_BRICK   : return get_rek(branching.ptr_next4overlap   , fam_graph, i_var+1);
    case NOOVERLAP_BRICK : return get_rek(branching.ptr_next4nooverlap , fam_graph, i_var+1);
    case MAYOVERLAP_BRICK: return get_rek(branching.ptr_next4mayoverlap, fam_graph, i_var+1);
    default: errstop(fkt, "get_overlap ungueltig"); return false;
  }
}


/* === CompRepFamGraph4Part =================================================== */

/* --- static members --- */

const Str CompRepFamGraph4Part::start_filename("repfamgraph4part(");

/* --- init_work --- */

bool CompRepFamGraph4Part::init_work() {
  return true;
}

/* --- get_n --- */

int CompRepFamGraph4Part::get_n() const {
  FKT "CompRepFamGraph4Part::get_n";

  if (!is_complete()) errstop(fkt, "Berechnung nicht durchgefuehrt");
  return lst_result.get_n();
}

/* --- run4prepared_inited --- */

bool CompRepFamGraph4Part::run4prepared_inited() {
  FKT "CompRepFamGraph4Part::run4prepared_inited";

  // Lst<FamGraph> lst_fam_graph;
  CompFamGraph4Part comp_fam_graph(part, path_dir);
  if (!comp_fam_graph.run()) return false;
  if (!comp_fam_graph.is_complete()) {
    return err(Str("File ") + enquote(comp_fam_graph.get_filename4result()) + Str(" not computed"));
  }

  // Put all graph families into <set_all>
  int n = comp_fam_graph.get_n();
  SetFamGraph4Part set_all(part, n);
  int i;
  for (i=0; i<n; ++i) {
    FamGraph fam_graph = comp_fam_graph.get(i);
    set_all.set(fam_graph, 1);
  }

  // Alloc and intitialize factor array
  int *arr_fac = new int[n];
  if (arr_fac==0) errstop_memoverflow(fkt);
  for (i=0; i<n; ++i) {
    arr_fac[i]=0;
  }

  // Group representatives to <lst_result>
  SetFamGraph4Part set_result_perm(part, n);
  lst_result.clear();
  for (i=0; i<n; ++i) {
    FamGraph fam_graph = comp_fam_graph.get(i);
    int i_first=set_result_perm.get(fam_graph)-1;
    if (i_first>=0) {
      ++arr_fac[i_first];
      continue;
    }

    Setter4SetFamGraph4Part setter(set_result_perm, i+1);
    FilterContained4FamGraph filter(set_all, setter);
    Permutor4FamGraph permutor(fam_graph, filter);
    if (!part.iterate_perm_conform(permutor)) {
      delete[] arr_fac;
      return false;
    }
    // i_first=set_result_perm.get(fam_graph)-1;
    // set_result_perm.set(fam_graph, 15);
    // i_first=set_result_perm.get(fam_graph)-1;

    ++arr_fac[i];
  }

  // Count number of resulting graph families
  int n_result=0;
  for (i=0; i<n; ++i) {
    if (arr_fac[i]) ++n_result;
  }

  // Setup lst_result and <arr_fac_result>
  lst_result.clear();
  for (i=0; i<n; ++i) {
    int fac=arr_fac[i];
    if (!fac) continue;

    FamGraphFac elem;
    elem.fam_graph = comp_fam_graph.get(i);
    elem.fac = arr_fac[i];
    lst_result.append(elem);
  }

  delete[] arr_fac;

  return set_complete();
}

/* --- get_filename4work --- */

Str CompRepFamGraph4Part::get_filename4work() const {
  return start_filename+part.to_str()+c_end_filename_work;
}

/* --- get_filename4result --- */

Str CompRepFamGraph4Part::get_filename4result() const {
  return start_filename+part.to_str()+c_end_filename_result;
}

/* --- constructor --- */

CompRepFamGraph4Part::CompRepFamGraph4Part(const Part &p_part, const Str &path_dir) : Comp(path_dir), part(p_part) {}


/* --- load_result --- */

bool CompRepFamGraph4Part::load_result(InBuffered &in) {
  int n, i;

  if (!in.read_str_given(c_n_eq)) return false;
  if (!in.read_card(n)) return false;
  if (!in.read_eoln()) return false;

  int n_brick=part.get_n_brick();
  for (i=0; i<n; ++i) {
    FamGraphFac elem;
    if (!in.read_card(elem.fac)) return false;
    if (!in.read_char_given('*')) return false;
    if (!read(in, n_brick, elem.fam_graph)) return false;
    if (!elem.fam_graph.is_conform(part)) return in.In::err_at("Graph-Familie ist nicht konform zur Partition");
    if (!in.read_eoln()) return false;
    lst_result.append(elem);
  }
  return true;
}

/* --- save_result --- */

bool CompRepFamGraph4Part::save_result(Out &out) const {

  int n = lst_result.get_n();
  if (!out.printf("n=$\n", n)) return false;

  int i;
  for (i=0; i<n; ++i) {
    FamGraphFac elem = lst_result.get(i);
    if (!out.printf("$*", elem.fac)) return false;
    if (!elem.fam_graph.write(out)) return false;
    if (!out.print_char('\n')) return false;
  }

  return true;
}

/* --- load_work --- */

bool CompRepFamGraph4Part::load_work(InBuffered &in) {
  return true;
}

/* --- save_work --- */

bool CompRepFamGraph4Part::save_work(Out &out) const {
  return true;
}

/* --- get --- */

FamGraphFac CompRepFamGraph4Part::get(int i) const {
  FKT "CompRepFamGraph4Part::get";

  if (!is_complete()) errstop(fkt, "Berechnung nicht durchgefuehrt");
  return lst_result.get(i);
}

/* --- read_evtl_filename4result --- */

// repfamgraph4part($part).dat

bool CompRepFamGraph4Part::read_evtl_filename4result(const Str &filename, Part &part) {
  In4Str in(filename);

  if (!in.read_evtl_str_given(start_filename)) return false;
  if (!read_evtl(in, part)) return false;
  if (!in.read_evtl_str_given(c_end_filename_result)) return false;

  return in.at_end();
}

/* --- setup_lst_comp_prepare --- */

bool CompRepFamGraph4Part::setup_lst_comp_prepare(Lst<PtComp> &lst) const {
  lst.clear();

  PtComp pt_comp = new CompFamGraph4Part(part, path_dir);
  lst.append(pt_comp);

  return true;
}

/* --- destructor --- */

CompRepFamGraph4Part::~CompRepFamGraph4Part() {}


/* === Setter4SetFamGraph4Part ========================================= */

/* --- constructor --- */

Setter4SetFamGraph4Part::Setter4SetFamGraph4Part(SetFamGraph4Part &p_target, int p_val) : target(p_target), val(p_val) {}

/* --- perform --- */

bool Setter4SetFamGraph4Part::perform(const FamGraph &fam_graph) {
  target.set(fam_graph, val);
  return true;
}

/* === FilterContained4FamGraph ========================================== */

/* --- constructor --- */

FilterContained4FamGraph::FilterContained4FamGraph(SetFamGraph4Part &p_pass, Performer<FamGraph> &p_target) : pass(p_pass), target(p_target) {}

/* --- perform --- */

bool FilterContained4FamGraph::perform(const FamGraph &fam_graph) {
  if (pass.get(fam_graph)==0) return true;
  return target.perform(fam_graph);
}


/* === FilterFamGraphFacNonzero ========================================== */

/* --- constructor --- */

FilterFamGraphFacNonzero::FilterFamGraphFacNonzero(Performer<FamGraphFac> &p_performer) : performer(p_performer) {}

/* --- perform --- */

bool FilterFamGraphFacNonzero::perform(const FamGraphFac &fam_graph_fac) {
  if (fam_graph_fac.fac!=0) {
    return performer.perform(fam_graph_fac);
  } else {
    return true;
  }
}


/* === Permutor4FamGraph ================================================= */

/* --- constructor --- */

Permutor4FamGraph::Permutor4FamGraph(const FamGraph &p_fam_graph, Performer<FamGraph> &p_target) : fam_graph(p_fam_graph), target(p_target) {}

/* --- perform --- */

bool Permutor4FamGraph::perform(const Perm &perm) {

  // Apply <perm> to <fam_graph> and get <fam_graph_perm>
  int n_brick=fam_graph.n_brick;
  FamGraph fam_graph_perm(n_brick);
  int i_brick, j_brick;
  for (i_brick=0; i_brick<n_brick; ++i_brick) {
    for (j_brick=0; j_brick<i_brick; ++j_brick) {
      fam_graph_perm.set_overlap(perm.data[i_brick], perm.data[j_brick], fam_graph.get_overlap(i_brick, j_brick));
    }
  }

  // Forward to <target>
  return target.perform(fam_graph_perm);
}


/* === AppenderRepGraph ================================================== */

/* --- constructor --- */

// AppenderRepGraph::AppenderRepGraph(const Part &p_part, SetGraph &p_set, Lst<Graph> &p_lst) : set(p_set), lst(p_lst), part(p_part) {}

/* --- perform ---

bool AppenderRepGraph::perform(const Graph &graph) {
  if (set.contains(graph)) return true;

  InserterGraphIntoSetGraph inserter(set);
  if (!iterate4equiv_to(part, graph, inserter)) return false;

  lst.append(graph);

  return true;
}*/


/* === exported functions ================================================= */

/* --- get_n_pos --- */

// Computes number of rotated positions of the graph <graph> and puts it into <n_pos>.

bool get_n_pos(const Graph &graph, Card64 &n_pos, Access2Db &access2db, bool &hit) {

  // No bricks => one position
  int n_brick=graph.n_brick;
  if (n_brick==0) {
    n_pos=Card64::one;
    return true;
  }

  // Query DB
  if (access2db.query(graph, n_pos)) {
    hit=true;
    return true;
  } else {
    hit=false;
  }

  // Narrow graph
  int arr_i_brick_pred[N_BRICK_MAX];
  Graph graph_narrow(n_brick);
  narrow(graph, graph_narrow, arr_i_brick_pred);
  // if (!get_spantree_from0(graph, arr_i_brick, arr_i_brick_pred, errtxt)) return false;

  // Get predessesor for each brick
  // int arr_i_brick_pred4brick[N_BRICK_MAX], i_i_brick, i_brick;
  // for (i_i_brick=1; i_i_brick<n_brick; ++i_i_brick) {
  //   i_brick = arr_i_brick[i_i_brick];
  //   arr_i_brick_pred4brick[i_brick] = arr_i_brick_pred[i_i_brick];
  // }

  // Compute the pahtes from brick 0 to any brick.
  // the path from brick 0 to brick i uses delta path j iff <mat_uses4brick_delta[i][i]> is <true>
  int mat_uses4brick_delta[N_BRICK_MAX][N_BRICK_MAX];
  int i_delta, i_brick_pred, i_brick;
  for (i_delta=1; i_delta<n_brick; ++i_delta) {
    mat_uses4brick_delta[0][i_delta] = false;
  }
  for (i_brick=1; i_brick<n_brick; ++i_brick) {
    i_brick_pred = arr_i_brick_pred[i_brick];
    for (i_delta=1; i_delta<n_brick; ++i_delta) {
      mat_uses4brick_delta[i_brick][i_delta] = mat_uses4brick_delta[i_brick_pred][i_delta] || i_brick==i_delta;
    }
  }

  // Set up <quad_fac4link_delta>
  // quad_fac4link_delta[i_brick][j_brick][i_delta] is  0, if the path from brick <i_brick> to <j_brick> does not use delta path <i_delta>
  // quad_fac4link_delta[i_brick][j_brick][i_delta] is  1, if the path from brick <i_brick> to <j_brick> uses delta path <i_delta> in forward direction
  // quad_fac4link_delta[i_brick][j_brick][i_delta] is -1, if the path from brick <i_brick> to <j_brick> uses delta path <i_delta> in backward direction
  int quad_fac4link_delta[N_BRICK_MAX][N_BRICK_MAX][N_BRICK_MAX], j_brick;
  for (i_brick=0; i_brick<n_brick; ++i_brick) {
    for (j_brick=0; j_brick<n_brick; ++j_brick) {
      int *arr_fac = quad_fac4link_delta[i_brick][j_brick];
      for (i_delta=1; i_delta<n_brick; ++i_delta) {
        arr_fac[i_delta] = -int(mat_uses4brick_delta[i_brick][i_delta]) + int(mat_uses4brick_delta[j_brick][i_delta]);
      }
    }
  }

  // Set up <arr_check4link>
  // if <arr_check4link[i][j]> is true, then there is a link from brick i to brick j which needs an explicit range check
  bool arr_check4link[N_BRICK_MAX][N_BRICK_MAX];
  for (i_brick=0; i_brick<n_brick; ++i_brick) {
    for (j_brick=0; j_brick<n_brick; ++j_brick) {
      arr_check4link[i_brick][j_brick] = (i_brick!=j_brick && graph_narrow.is_linked(i_brick, j_brick));
    }
  }
  for (i_brick=1; i_brick<n_brick; ++i_brick) {
    i_brick_pred = arr_i_brick_pred[i_brick];
    arr_check4link[i_brick][i_brick_pred] = arr_check4link[i_brick_pred][i_brick] = false;
  }

  // Generate function generator
  PtFunArrRotated2FunArrDelta2Dword pt_fun_fun = new FunArrRotated2FunArrDelta2Dword1(n_brick);
  bool arr_set[N_BRICK_MAX]; // if <arr_set[i]>, then <pt_fun_fun> is called with brick position i set.
  set(arr_set, n_brick, true);
  for (i_delta=n_brick-1; i_delta>=1; --i_delta) {
    i_brick_pred = arr_i_brick_pred[i_delta];

    // Apply checks for links which need to be done now
    for (i_brick=0; i_brick<n_brick; ++i_brick) {
      for (j_brick=0; j_brick<i_brick; ++j_brick) {

        // If check needs not to be applied at all or will been done elsewhere, skip
        if (!arr_check4link[i_brick][j_brick]) continue;

        // If new delta variable is not involved, skip
        if (quad_fac4link_delta[i_brick][j_brick][i_delta]==0) continue;

        // Apply check
        pt_fun_fun = new FunArrRotated2FunCheckRangeArrDelta2Dword(quad_fac4link_delta[i_brick][j_brick], i_brick, j_brick,  pt_fun_fun);

        // Mark check as done
        arr_check4link[i_brick][j_brick]=false;
      }
    }

    // loop over <i_brick> in the range predescribes by the predessesor
    pt_fun_fun = new FunArrRotated2FunSumArrDelta2Dword(i_brick_pred, i_delta, pt_fun_fun);

    // Mark <i_delta> as used
    arr_set[i_delta]=false;

    // Compute whether cache would make sense
    bool use_cache=false;
    FunArrRotated2FunArrDelta2Dword &fun_fun = *pt_fun_fun;
    for (j_brick=1; j_brick<n_brick; ++j_brick) {
      if (arr_set[j_brick] && !fun_fun.depends_on(j_brick)) {
        use_cache=true;
        break;
      }
    }

    // Put function into cache, if it is used more than once
    if (use_cache) {
      pt_fun_fun = new FunArrRotated2FunCachedArrDelta2Dword(arr_i_brick_pred, pt_fun_fun);
    }
  } // for (i_i_brick)

  // Sum up by rotating the bricks
  bool arr_rotated[N_BRICK_MAX];
  int arr_delta[N_BRICK_MAX];
  DWORD nx,ny;
  PtFunArrDelta2Dword pt_fun;
  set(arr_rotated, n_brick, false);
  if (L_BRICK==W_BRICK) {
    pt_fun = pt_fun_fun->eval('x', arr_rotated); nx=pt_fun->eval(arr_delta);
    pt_fun = pt_fun_fun->eval('y', arr_rotated); ny=pt_fun->eval(arr_delta);
    n_pos = mul(nx,ny);
  } else {
    n_pos=Card64::zero;

    while (true) {

      pt_fun = pt_fun_fun->eval('x', arr_rotated); nx=pt_fun->eval(arr_delta);
      pt_fun = pt_fun_fun->eval('y', arr_rotated); ny=pt_fun->eval(arr_delta);

      Card64 prod = mul(nx,ny);
      prod.dbl();
      n_pos += prod;

      if (is(arr_rotated, n_brick-1, true)) break;
      adv(arr_rotated, n_brick-1);
    }
  }

  // Write to database
  access2db.insert(graph, n_pos);

  return true;
}






/////////////////////
// FILE chksum.cpp //
/////////////////////

/* === Chksummer ======================================================= */

/* --- constructor(0) --- */

Chksummer::Chksummer() : chksum(0U) {}

/* --- constructor(start) --- */

Chksummer::Chksummer(unsigned int chksum_start) : chksum(chksum_start) {}

/* --- process --- */

void Chksummer::process(char c) {
  chksum = 5U*chksum + (unsigned int)(unsigned char)c;
}

/* --- get_chksum_masked --- */

int Chksummer::get_chksum_masked() const {
  return int(chksum^2304561986U);
}


/* === Chksummer4In ==================================================== */

/* --- err_at(LINE, COL) --- */

bool Chksummer4In::err_at(Str txt, int i_line, int i_col) const {
  return in.In::err_at(txt, i_line, i_col);
}

/* --- constructor --- */

Chksummer4In::Chksummer4In(InBuffered &p_in) : in(p_in), pos(Card64::zero), pos_max(Card64::zero) {
  FKT "Chksummer4In::Chksummer4In(In)";
  if (in.get_pos()!=0) errstop(fkt, "in is not at its beginning");
}

/* --- constructor(start) --- */

void Chksummer4In::set_pos(const Card64 &pos_new) {
  FKT "Chksummer4In::set_pos";
  if (pos_new>pos_max) errstop(fkt, "pos_new>pos_max");
  if (pos_new+Card64((DWORD)SIZE_BUFF_IN)<=pos_max) errstop(fkt, "pos_err too low");

  pos=pos_new;
}

/* --- constructor(start) --- */

Chksummer4In::Chksummer4In(InBuffered &p_in, unsigned int chksum) : chksummer(chksum), in(p_in) {
  pos_max=pos=in.get_pos();
}

/* --- err_at --- */

bool Chksummer4In::err_at(Str txt, Card64 pos_err) const {
  return in.In::err_at(txt,pos_err);
}

/* --- get_chksum --- */

unsigned int Chksummer4In::get_chksum() const {
  return arr_chksum[pos&((DWORD)(SIZE_BUFF_IN-1))];
}

/* --- read_chksum --- */

bool Chksummer4In::read_chksum() {
  static Str s_chksum_eq("chksum=");
  const Card64 &pos_start = get_pos();

  int chksum_computed = chksummer.get_chksum_masked();

  int chksum_stored;
  if (!in.read_str_given(s_chksum_eq)) return false;
  if (!in.read_int(chksum_stored)) return false;
  if (!in.read_eoln()) return false;

  if (chksum_stored!=chksum_computed) {
    return err_at("Checksumme falsch.", pos_start);
  }
  return true;
}

/* --- Chksummer4In++ --- */

bool Chksummer4In::operator++() {
  if (pos==pos_max) {
    chksummer.process(*in);
    if (!++in) return false;
    ++pos; ++pos_max;

    arr_chksum[pos&((DWORD)(SIZE_BUFF_IN-1))]=chksummer.get_chksum();
  } else {
    if (!++in) return false;
    ++pos;
  }

  return true;
}

/* --- *Chksummer4In --- */

char Chksummer4In::operator*() {
  return *in;
}

/* --- get_pos --- */

const Card64 &Chksummer4In::get_pos() const {
  return pos;
}

/* --- at_end --- */

bool Chksummer4In::at_end() const {
  return pos==pos_max && in.at_end();
}


/* === Checksummer4Out =================================================== */

/* --- constructor --- */

Checksummer4Out::Checksummer4Out(Out &p_out) : out(p_out) {}

/* --- write_chksum --- */

bool Checksummer4Out::write_chksum() {
  return out.printf("chksum=$\n", chksummer.get_chksum_masked());
}

/* --- print_char --- */

bool Checksummer4Out::print_char(char c) {
  if (!out.print_char(c)) return false;
  chksummer.process(c);
  return true;
}

/* --- err_write --- */

bool Checksummer4Out::err_write() {
  return out.err_write();
}


/////////////////////
// FILE cnrotfig.h //
/////////////////////

#define MY_CNROTFIG_H


///////////////////
// FILE bigint.h //
///////////////////

// From lego4




/////////////////////
// FILE cnrotfig.h //
/////////////////////

/* --- CompNFigRot4NBrick --- */

// Computes number of rotated figures consisting of <n_brick> bricks.

class CompNFigRot4NBrick : public Comp {
  const int n_brick;
  const int size_cache_max, n_max4map, size_buff_pipe;
  const bool pipe;
  Card64 res;

  // Implementation of <Comp>
  protected:
  bool init_work();
  bool run4prepared_inited();
  bool load_work  (InBuffered&);
  bool load_result(InBuffered&);
  bool save_work  (Out&) const;
  bool save_result(Out&) const;
  bool setup_lst_comp_prepare(Lst<Pt<Comp> > &lst) const;
  public:
  Str get_filename4result() const;
  Str get_filename4work() const;

  public:
  CompNFigRot4NBrick(int n_brick, const Str &path_dir, int size_cache_max, int n_max4map, bool pipe, int size_buff_pipe);
  const Card64 &get_res() const;
  
  public:
  static bool read_evtl_filename4result(const Str &filename, int &n_brick);
  static const Str start_filename;
};

/* --- AdderNPos4Part --- */

class AdderNPos4Part : public Performer<Part> {
  Card64 &sum;
  Str path_dir;
  const int size_cache_max, n_max4map, size_buff_pipe;
  const bool pipe;

  public:
  AdderNPos4Part(Card64&, const Str &path_dir, int size_cache_max, int n_max4map, bool pipe, int size_buff_pipe);
  bool perform(const Part&);
};

/* --- CompNFigRotSym24NBrick --- */

// Computes number of rotated figures consisting of <n_brick> bricks which have 2-symmetry.

class CompNFigRotSym24NBrick : public Comp {
  const int n_brick;
  Card64 res;

  // Implementation of <Comp>
  protected:
  bool init_work();
  bool run4prepared_inited();
  bool load_work  (InBuffered&);
  bool load_result(InBuffered&);
  bool save_work  (Out&) const;
  bool save_result(Out&) const;
  bool setup_lst_comp_prepare(Lst<Pt<Comp> > &lst) const;
  public:
  Str get_filename4result() const;
  Str get_filename4work() const;

  public:
  CompNFigRotSym24NBrick(int n_brick, const Str &path_dir);
  const Card64 &get_res() const;
  
  public:
  static bool read_evtl_filename4result(const Str &filename, int &n_brick);
  static const Str start_filename;
};

/* --- CompNFigRotSym44NBrick --- */

// Computes number of rotated figures consisting of <n_brick> bricks which have 2-symmetry.

class CompNFigRotSym44NBrick : public Comp {
  const int n_brick;
  Card64 res;

  // Implementation of <Comp>
  protected:
  bool init_work();
  bool run4prepared_inited();
  bool load_work  (InBuffered&);
  bool load_result(InBuffered&);
  bool save_work  (Out&) const;
  bool save_result(Out&) const;
  bool setup_lst_comp_prepare(Lst<Pt<Comp> > &lst) const;
  public:
  Str get_filename4result() const;
  Str get_filename4work() const;

  public:
  CompNFigRotSym44NBrick(int n_brick, const Str &path_dir);
  const Card64 &get_res() const;
  
  public:
  static bool read_evtl_filename4result(const Str &filename, int &n_brick);
  static const Str start_filename;
};

/* --- AdderFigRotSym24Part --- */

class AdderFigRotSym24Part : public Performer<Part> {
  Card64 &sum;
  Str path_dir;
  public:
  AdderFigRotSym24Part(Card64 &sum, const Str &path_dir);
  bool perform(const Part&);
};

/* --- AdderFigRotSym44Part --- */

class AdderFigRotSym44Part : public Performer<Part> {
  Card64 &sum;
  Str path_dir;
  public:
  AdderFigRotSym44Part(Card64 &sum, const Str &path_dir);
  bool perform(const Part&);
};


//////////////////
// FILE cnfig.h //
//////////////////

#define MY_CNFIG_H


///////////////////
// FILE bigint.h //
///////////////////

// From lego4



//////////////////
// FILE cnfig.h //
//////////////////

/* --- CompNFig4NBrick --- */

// Computes number of figures consisting of <n_brick>.

class CompNFig4NBrick : public Comp {
  const int n_brick;
  const int size_cache_max, n_max4map, size_buff_pipe;
  const bool pipe;
  Card64 res;

  // Implementation of <Comp>
  protected:
  bool init_work();
  bool run4prepared_inited();
  bool load_work  (InBuffered&);
  bool load_result(InBuffered&);
  bool save_work  (Out&) const;
  bool save_result(Out&) const;
  bool setup_lst_comp_prepare(Lst<Pt<Comp> > &lst) const;
  public:
  Str get_filename4result() const;
  Str get_filename4work() const;

  public:
  CompNFig4NBrick(int n_brick, const Str &path_dir, int size_cache_max, int n_max4map, bool pipe, int size_buff_pipe);
  const Card64 &get_res() const;
  
  public:
  static bool read_evtl_filename4result(const Str &filename, int &n_brick);
  static const Str start_filename;
};

/* --- FilterBottom14Part --- */

class FilterBottom14Part : public Performer<Part> {
  Performer<Part> &target;

  public:
  FilterBottom14Part(Performer<Part> &target);
  bool perform(const Part&);
};

/* --- CompNFig4Bottom1NBrick --- */

// Computes number of figures consisting of <n_brick> bricks, having one brick in the bottom layer.

class CompNFig4Bottom1NBrick : public Comp {
  const int n_brick;
  const int size_cache_max, n_max4map, size_buff_pipe;
  const bool pipe;
  Card64 res;

  // Implementation of <Comp>
  protected:
  bool init_work();
  bool run4prepared_inited();
  bool load_work  (InBuffered&);
  bool load_result(InBuffered&);
  bool save_work  (Out&) const;
  bool save_result(Out&) const;
  bool setup_lst_comp_prepare(Lst<Pt<Comp> > &lst) const;
  public:
  Str get_filename4result() const;
  Str get_filename4work() const;

  public:
  CompNFig4Bottom1NBrick(int n_brick, const Str &path_dir, int size_cache_max, int n_max4map, bool pipe, int size_buff_pipe);
  const Card64 &get_res() const;
  
  public:
  static bool read_evtl_filename4result(const Str &filename, int &n_brick);
  static const Str start_filename;
};



//////////////////
// FILE cnpos.h //
//////////////////

#define MY_CNPOS_H


///////////////////
// FILE bigint.h //
///////////////////

// From lego4



////////////////
// FILE lst.h //
////////////////

// From kombin/dodeka



//////////////////
// FILE cnpos.h //
//////////////////

#define SIZE_CACHE_MAX_DEFAULT 1000000000

class Str;
struct GraphCprFac;
class Graph;
class Card64;
class InBuffered;
class Out;
class FunArrPosPartial2DwordCached;
class Rnd;

// extern Card64 n0,n1;

/* --- CompNPos4Part --- */

class CompNPos4Part : public Comp {
  Int128 sum;
  int n_todo, n_done, n_total;
  GraphCprFac *arr_todo;
  bool *arr_done;
  const Part part;
  const int n_brick;
  const int size_cache_max, n_max4map, size_buff_pipe;
  const bool pipe;

  private:
  int get_i_todo(Rnd&) const;

  // Implementation of <Comp>
  protected:
  bool init_work();
  bool run4prepared_inited();
  bool load_work  (InBuffered&);
  bool load_result(InBuffered&);
  bool save_work  (Out&) const;
  bool save_result(Out&) const;
  bool setup_lst_comp_prepare(Lst<Pt<Comp> > &lst) const;
  public:
  Str get_filename4result() const;
  Str get_filename4work() const;

  public:
  CompNPos4Part(const Part&, const Str &path_dir, int size_cache_max, int p_n_max4map, bool pipe, int size_buff_pipe);
  ~CompNPos4Part();
  const Card64 get_sum() const;

  public:
  static bool read_evtl_filename4result(const Str &filename, Part&);
  static const Str start_filename;
};

/* --- AppenderSize --- */

class AppenderSize : public Performer<Pt<FunArrPosPartial2DwordCached> > {
  Lst<double> &lst;

  public:
  AppenderSize(Lst<double>&);
  bool perform(const Pt<FunArrPosPartial2DwordCached>&);
};

/* --- InfoSizeCache --- */

struct InfoSizeCache {
  double size;
  int n_occur;

  // InfoSizeCache(double size, int n_occur);
};

/* --- Dimer4FunCached --- */

class Dimer4FunCached  : public Performer<Pt<FunArrPosPartial2DwordCached> > {
  InfoSizeCache *arr_info_size;
  int n_info_size;

  public:
  Dimer4FunCached(const double *arr_size, int n_size);
  ~Dimer4FunCached();
  bool perform(const Pt<FunArrPosPartial2DwordCached>&);
};

/* --- exported functions --- */

bool get_n_pos4graph(const Graph&, Card64 &n_pos, int size_cache_max);


////////////////
// FILE str.h //
////////////////

// From c:\consql





////////////////////
// FILE cnfig.cpp //
////////////////////

/* === CompNFig4NBrick =================================================== */

/* --- static members --- */

const Str CompNFig4NBrick::start_filename("nfig4nbrick(");

/* --- read_evtl_filename4result --- */

bool CompNFig4NBrick::read_evtl_filename4result(const Str &filename, int &n_brick) {
  In4Str in(filename);

  if (!in.read_evtl_str_given(start_filename)) return false;
  if (!in.read_evtl_card(n_brick)) return false;
  if (!in.read_evtl_str_given(c_end_filename_result)) return false;

  return in.at_end();
}

/* --- load_result --- */

bool CompNFig4NBrick::load_result(InBuffered &in) {
  static const Str s_nfig("nfig=");

  if (!in.read_str_given(s_nfig)) return false;
  if (!read(in, res)) return false;
  if (!in.read_eoln()) return false;

  return true;
}

/* --- constructor --- */

CompNFig4NBrick::CompNFig4NBrick(
  int p_n_brick,
  const Str &path_dir,
  int p_size_cache_max,
  int p_n_max4map,
  bool p_pipe,
  int p_size_buff_pipe
) :
  Comp(path_dir),
  n_brick(p_n_brick),
  size_cache_max(p_size_cache_max),
  n_max4map(p_n_max4map),
  size_buff_pipe(p_size_buff_pipe),
  pipe(p_pipe)
{}

/* --- init_work --- */

bool CompNFig4NBrick::init_work() {
  return true;
}

/* --- run4prepared_inited --- */

bool CompNFig4NBrick::run4prepared_inited() {
  CompNFigRot4NBrick     comp4nosym(n_brick, path_dir, size_cache_max, n_max4map, pipe, size_buff_pipe);
  CompNFigRotSym24NBrick comp4sym2 (n_brick, path_dir);
  CompNFigRotSym44NBrick comp4sym4 (n_brick, path_dir);

  if (!comp4nosym.run()) return false;
  if (!comp4sym2 .run()) return false;
  if (!comp4sym4 .run()) return false;

  res  = comp4nosym.get_res();
  res += comp4sym2 .get_res();
  res += comp4sym4 .get_res();
  res += comp4sym4 .get_res();

  if (res.is_odd()) return err("Die Anzahl der Figuren ergibt keine ganze Zahl.");
  res.half();
  if (res.is_odd()) return err("Die Anzahl der Figuren ergibt keine ganze Zahl.");
  res.half();

  return set_complete();
}

/* --- load_work --- */

bool CompNFig4NBrick::load_work(InBuffered&) {
  return true;
}

/* --- save_work --- */

bool CompNFig4NBrick::save_work(Out&) const {
  return true;
}

/* --- save_result --- */

bool CompNFig4NBrick::save_result(Out &out) const {
  char buff[N_DIGIT4CARD64+1];

  if (!out.printf("nfig=$\n", to_nts(res, buff, sizeof(buff)))) return false;
  return true;
}

/* --- get_res --- */

const Card64& CompNFig4NBrick::get_res() const {
  FKT "CompNFig4NBrick::get_res";

  if (!is_complete()) errstop(fkt, "Berechnung nicht durchgefuehrt");

  return res;
}

/* --- setup_lst_comp_prepare --- */

bool CompNFig4NBrick::setup_lst_comp_prepare(Lst<PtComp> &lst) const {
  lst.clear();

  PtComp pt;
  pt = new CompNFigRot4NBrick    (n_brick, path_dir, size_cache_max, n_max4map, pipe, size_buff_pipe); lst.append(pt);
  pt = new CompNFigRotSym24NBrick(n_brick, path_dir                                                 ); lst.append(pt);
  pt = new CompNFigRotSym44NBrick(n_brick, path_dir                                                 ); lst.append(pt);

  return true;
}

/* --- get_filename4work --- */

Str CompNFig4NBrick::get_filename4work() const {
  return start_filename+str4card(n_brick)+c_end_filename_work;
}

/* --- get_filename4result --- */

Str CompNFig4NBrick::get_filename4result() const {
  return start_filename+str4card(n_brick)+c_end_filename_result;
}


/* === FilterBottom14Part ================================================ */


/* --- constructor --- */

FilterBottom14Part::FilterBottom14Part(Performer<Part> &p_target) : target(p_target) {}

/* --- perform --- */

bool FilterBottom14Part::perform(const Part &part) {
  if (part.get_n_layer()>=1 && part.get_n_brick4layer(0)==1) {
    return target.perform(part);
  } else {
    return true;
  }
}


/* === CompNFig4Bottom1NBrick ============================================ */

/* --- static members --- */

const Str CompNFig4Bottom1NBrick::start_filename("nfig4bottom1nbrick(");

/* --- get_res --- */

const Card64& CompNFig4Bottom1NBrick::get_res() const {
  FKT "CompNFig4Bottom1NBrick::get_res";

  if (!is_complete()) errstop(fkt, "Berechnung nicht durchgefuehrt");

  return res;
}

/* --- constructor --- */

CompNFig4Bottom1NBrick::CompNFig4Bottom1NBrick(
  int p_n_brick,
  const Str &path_dir,
  int p_size_cache_max,
  int p_n_max4map,
  bool p_pipe,
  int p_size_buff_pipe
) :
  Comp(path_dir),
  n_brick(p_n_brick),
  size_cache_max(p_size_cache_max),
  n_max4map(p_n_max4map),
  size_buff_pipe(p_size_buff_pipe),
  pipe(p_pipe)
{}

/* --- get_filename4work --- */

Str CompNFig4Bottom1NBrick::get_filename4work() const {
  return start_filename+str4card(n_brick)+c_end_filename_work;
}

/* --- get_filename4result --- */

Str CompNFig4Bottom1NBrick::get_filename4result() const {
  return start_filename+str4card(n_brick)+c_end_filename_result;
}

/* --- init_work --- */

bool CompNFig4Bottom1NBrick::init_work() {
  return true;
}

/* --- run4prepared_inited --- */

bool CompNFig4Bottom1NBrick::run4prepared_inited() {
  res=Card64::zero;
  AdderNPos4Part adder(res, path_dir, size_cache_max, n_max4map, pipe, size_buff_pipe);
  FilterBottom14Part filter(adder);
  if (!Part::iterate(n_brick, filter)) return false;

  if (W_BRICK!=L_BRICK) {
    if (res.is_odd()) return err("Die Anzahl der Figuren ergibt keine ganze Zahl.");
    res.half();
  }

  return set_complete();
}

/* --- setup_lst_comp_prepare --- */

bool CompNFig4Bottom1NBrick::setup_lst_comp_prepare(Lst<PtComp> &lst) const {

  Lst<Part> lst_part;
  Appender<Part> appender(lst_part);
  FilterBottom14Part filter(appender);
  if (!Part::iterate(n_brick, filter)) return false;

  int n=lst_part.get_n(), i;
  lst.clear();
  for (i=0; i<n; ++i) {
    Part part = lst_part.get(i);
    Part part_reverse(part);
    part_reverse.revert();
    if (part>part_reverse) continue;

    PtComp pt = new CompNPos4Part(part, path_dir, size_cache_max, n_max4map, pipe, size_buff_pipe);
    lst.append(pt);
  }

  return true;
}

/* --- load_result --- */

bool CompNFig4Bottom1NBrick::load_result(InBuffered &in) {
  static const Str s_nfig("nfig=");

  if (!in.read_str_given(s_nfig)) return false;
  if (!read(in, res)) return false;
  if (!in.read_eoln()) return false;

  return true;
}

/* --- save_result --- */

bool CompNFig4Bottom1NBrick::save_result(Out &out) const {
  char buff[N_DIGIT4CARD64+1];

  if (!out.printf("nfig=$\n", to_nts(res, buff, sizeof(buff)))) return false;
  return true;
}

/* --- save_work --- */

bool CompNFig4Bottom1NBrick::save_work(Out&) const {
  return true;
}

/* --- load_work --- */

bool CompNFig4Bottom1NBrick::load_work(InBuffered&) {
  return true;
}


////////////////////
// FILE cnplink.h //
////////////////////

#define MY_CNPLINK_H



////////////////
// FILE ptr.h //
////////////////

// From kombin/dodeka


///////////////////
// FILE bigint.h //
///////////////////

// From lego4


/////////////////////
// FILE cnplinkb.h //
/////////////////////

#define MY_CNPLINKB_H


////////////////
// FILE str.h //
////////////////

// From c:\consql


///////////////////
// FILE bigint.h //
///////////////////

// From lego4


////////////////
// FILE lst.h //
////////////////

// From kombin/dodeka



/////////////////////
// FILE cnplinkb.h //
/////////////////////

/* --- InGraphFac644LstFile --- */

class InFamGraphFac644LstFile : public Nocopy {
  Str path_dir;
  int n_brick;
  bool opened;
  int i_block, i4block, n_block;
  Card64 i,n;
  Lst<int> lst_n4block;
  Lst<Str> lst_filename4block;
  FamGraphCprFac64 *arr;

  private:
  bool check_block_empty();
  bool advance2block_next_nonempty();

  public:
  InFamGraphFac644LstFile();
  ~InFamGraphFac644LstFile();
  bool open(const Str &path_dir, const Lst<Str> &lst_filename4block, const Lst<int> &lst_n4block, Card64 start, int n_brick);
  bool at_end();
  const Card64& get_n() const;
  const Card64& get_i() const;
  bool close();
  bool err_at(const char*) const;
  bool err_at(Str) const;
  const FamGraphCprFac64& operator*();
  bool next();
};    

/* --- CompGraphFac644LstFile --- */

// Abstract class havoin a list of files as a result.
// Each file contains a list of graphs, associated with an Int64 factor

class CompGraphFac644LstFile : public Comp {

  // Abstracts
  public:
  virtual Str get_filename4block(int i_block) const = 0;
  virtual int get_i_block_start4result() const = 0;
  virtual int get_i_block_end4result  () const = 0;
  virtual int get_n4block(int i_block) const = 0;

  public:
  const int n_brick;
  CompGraphFac644LstFile(const Str &path_dir, int n_brick); 
  virtual ~CompGraphFac644LstFile();

  public:
  bool open4result(InFamGraphFac644LstFile&, const Card64 &start);
  Str get_path4block(int i_block) const;
  void append_lst_path_att4result(Lst<Str> &lst_path); 
    // Appends the paths of the attachment files to <lst_path>.
    // Applicable only if this computation is complete.

};

typedef Pt<CompGraphFac644LstFile> PtCompGraphFac644LstFile;


////////////////////
// FILE cnplink.h //
////////////////////

#define N_MAX4MAP_DEFAULT 2000000
#define N_BYTE4DATA_FAMGRAPH (N_LINK_MAX/4 + (N_LINK_MAX%4>0 ? 1 : 0))

class Str;

/* --- CompGraphNoProhibeLink4Part --- */

// Computes graph families without NOOVERLAP_BRICK links, alternative algorithm

class CompGraphNoProhibeLink4Part : public Comp {
  const Part part;
  const int n_brick, n_max4map, n_link_max, size_buff_pipe;
  GraphCprFac *arr;
  int n;
  const bool pipe;

  // Implementation of <Comp>
  protected:
  bool init_work();
  bool run4prepared_inited();
  bool load_work  (InBuffered&);
  bool load_result(InBuffered&);
  bool save_work  (Out&) const;
  bool save_result(Out&) const;
  bool setup_lst_comp_prepare(Lst<Pt<Comp> > &lst) const;
  public:
  Str get_filename4result() const;
  Str get_filename4work() const;

  public:
  CompGraphNoProhibeLink4Part(const Part&, int n_max4map, const Str &path_dir, bool pipe, int size_buff_pipe);
  ~CompGraphNoProhibeLink4Part();
  int get_n() const;
  void get_all(GraphCprFac *arr, int size) const;

  public:
  static bool read_evtl_filename4result(const Str &filename, Part&);
  static const Str start_filename;
};

/* --- CompFamGraphNooverlap4PartNLinkMax --- */

class CompFamGraphNooverlap4PartNLinkMax : public CompGraphFac644LstFile {

  private:

  /* -- Stream --- */

  // Describes a sorted portion of the data
  struct Stream {
    int i_block_splitted_start, i_block_splitted_end; // The stream contains this interval of blocks which were procuded by splitting.
    int i_block_sorted_start  , i_block_sorted_end  ; // The stream is stored in this interval of block, sorted ascendinly.
  };

  const int n_link_max;
  const int n_max4block; // Maximum number of data records per block
  const Part part;
  Lst<int> lst_n4block; // <v.get(i)> = Number of entries in block i.
  MapFamGraph2Int64 map_no_no_overlap;
  Lst<FamGraphCprFac64> lst_merge;
  int i_pair_stream_merged; // Streams <i_pair_stream_merged> and <i_pair_stream_merged+1> are merged. If -1, no streams are merged.
  int n_block_start; // Start block number of the target stream of the merged process. If -1, no streams are merged.
  int n_block_splitted; // Number ob blocks generated by splitting; -1 if splitting process is not completed.
  InFamGraphFac644LstFile in4merge1, in4merge2; // Input streams to merge.
  InFamGraphFac644LstFile in_prev; // Input stream for previos computation
  Card64 n_merged1; // Number of merged data records from <in4merge1>. Meaningful if i_pair_stream_merged>=0
  Card64 n_merged2; // Number of merged data records from <in4merge2>. Meaningful if i_pair_stream_merged>=0
  Card64 n_splitted; // Number of spitted elements from previos computation.
  int n_stream; // Number of streams; -1 if no streams where generated.
  Stream *arr_stream; // The streams. They are sorted ascendingly with respect to <i_block_splitted_start>.
  int i_block_start4result, i_block_end4result;
  Lst<int> lst_i_block4remove; // List of blocks with can be removed
  bool pipe_result;

  private:
  bool is_first() const;
  bool run4first();
  bool run4notfirst();
  bool dump4merge(const FamGraphFac64&, bool &stopped);
  // bool dump4split(const FamGraph&, const Int64 &fac, bool &stopped);
  bool dump_map2block();
  bool dump_lst2block();
  bool split(bool &stopped);
  bool merge(bool &stopped);

  // Implementation of <Comp>
  protected:
  bool init_work();
  bool run4prepared_inited();
  bool load_work  (InBuffered&);
  bool load_result(InBuffered&);
  bool save_work  (Out&) const;
  bool save_result(Out&) const;
  bool setup_lst_comp_prepare(Lst<Pt<Comp> > &lst) const;

  public:
  Str get_filename4result() const;
  Str get_filename4work() const;
  Str get_path4block(int i_block) const;
  Card64 get_n() const;
  Str get_filename4block(int i_block) const;
  int get_i_block_start4result() const;
  int get_i_block_end4result  () const;
  int get_n4block     (int i_block) const;

  public:
  CompFamGraphNooverlap4PartNLinkMax(const Part&, int n_link, int n_max4block, const Str &path_dir);
  ~CompFamGraphNooverlap4PartNLinkMax();

  public:
  static bool read_evtl_filename4result(const Str &filename, Part&, int &n_link);
  static Str get_filename4block_static(const Part&, int n_link_max, int i_block, bool pipe);
  static Str get_filename4result_static(const Part&, int n_link_max);
  static Str get_filename4work_static(const Part&, int n_link_max, bool pipe);
  static bool load_result_static(InBuffered &in, bool &pipe, int &i_block_start, int &i_block_end, Lst<int> &lst_n4block);
  static const Str start_filename;
};

/* --- CondNNoOverlapLimited ---

class CondNNoOverlapLimited : public Cond<FamGraph> {
  const int limit;

  public:
  CondNNoOverlapLimited(int limit);
  bool holds(const FamGraph&);
};*/

/* --- WriterFamGraphFac64 --- */

class WriterFamGraphFac64 : public Performer<FamGraphFac64> {
  Out &out;
  const bool fast;

  public:
  WriterFamGraphFac64(Out&, bool fast);
  bool perform(const FamGraphFac64&);
};

/* --- SplitterFamGraphNoProhibeLink --- */

class SplitterFamGraphNoProhibeLink : public Performer<FamGraphFac64> {
  const int i_brick, j_brick;
  Out &out_may_overlap, &out_overlap;

  public:
  SplitterFamGraphNoProhibeLink(int i_brick, int j_brick, Out &out_may_overlap, Out &out_overlap);
  bool perform(const FamGraphFac64&);
};

/* --- exported functions --- */


/////////////////////
// FILE cnplinkp.h //
/////////////////////

#define MY_CNPLINKP_H



////////////////
// FILE str.h //
////////////////

// From c:\consql


///////////////////
// FILE bigint.h //
///////////////////

// From lego4


////////////////
// FILE ptr.h //
////////////////

// From kombin/dodeka



/////////////////////
// FILE cnplinkp.h //
/////////////////////

#define SIZE_PIPE_BUFF_DEFAULT 0x10000

class CompFamGraphNooverlap4PartNLinkMaxNomerge;
class FileWndTxt;
class InBuffered;
class Chksummer4In;

/* --- ItemPipe --- */

struct ItemPipe {
  FamGraph fam_graph;
  Int64 fac;
  int n_occur; // Number of occurances of fam_graph in input stream
};

/* --- Instream4Pipe --- */

class Instream4Pipe : public Nocopy {

  public:
  virtual ~Instream4Pipe();
  virtual Card64 get_n() const=0;
  virtual bool at_end()=0;
  virtual const ItemPipe& operator*()=0;
  virtual bool open()=0;
  virtual bool close()=0;
  virtual bool operator++()=0;
};

typedef Pt<Instream4Pipe> PtInstream4Pipe;

/* --- Instream4File --- */

class Instream4File : public Instream4Pipe {
  bool opened;
  ItemPipe current;
  Pt<FileWndTxt> pt_file;
  Pt<InBuffered> pt_in_buffered;
  Pt<Chksummer4In> pt_in;
  int i_item;

  private:
  bool fill_current();
  bool close_streams();

  // Implementation of <Instream4Pipe>
  public:
  const Str path, filename;
  const int n_item, size_wnd, n_brick;
  Instream4File(const Str &path_dir, Str filename, int n_item, int size_wnd, int n_brick);
  ~Instream4File();
  Card64 get_n() const;
  bool at_end();
  const ItemPipe& operator*();
  bool open();
  bool close();
  bool operator++();
};

/* --- Instream4File --- */

class InstreamMerge : public Instream4Pipe {
  const PtInstream4Pipe pt_a, pt_b;
  Instream4Pipe &a, &b;
  bool opened, has_current;
  ItemPipe current;

  private:
  bool fill_current();

  // Implementation of <Instream4Pipe>
  public:
  InstreamMerge(const PtInstream4Pipe&, const PtInstream4Pipe&);
  ~InstreamMerge();
  Card64 get_n() const;
  bool at_end();
  const ItemPipe& operator*();
  virtual bool operator++();
  bool open();
  bool close();
};

/* --- CompFamGraphNooverlap4PartNLinkMaxPipe --- */

class CompFamGraphNooverlap4PartNLinkMaxPipe : public CompGraphFac644LstFile {
  const int size_buff_pipe, n_max4block, n_link_max;
  const Part part;
  Lst<int> lst_n4block; // <v.get(i)> = Number of entries in block i for <i_block_start4result>..<i_block_end4result>.
  int i_block_start4result, i_block_end4result;
  bool pipe_result;

  private:
  PtInstream4Pipe create_instream(const CompFamGraphNooverlap4PartNLinkMaxNomerge&, int i_block_from, int i_block_to);
  bool dump_lst2block(const Lst<FamGraphCprFac64>&);

  // Implementation of <Comp>
  protected:
  bool init_work();
  bool run4prepared_inited();
  bool load_work  (InBuffered&);
  bool load_result(InBuffered&);
  bool save_work  (Out&) const;
  bool save_result(Out&) const;
  bool setup_lst_comp_prepare(Lst<Pt<Comp> > &lst) const;
  public:
  Str get_filename4result() const;
  Str get_filename4work() const;

  // Implementation of <CompGraphFac644LstFile>
  public:
  Str get_filename4block(int i_block) const;
  int get_i_block_start4result() const;
  int get_i_block_end4result  () const;
  int get_n4block     (int i_block) const;

  public:
  CompFamGraphNooverlap4PartNLinkMaxPipe(const Part&, int n_link, int n_max4block, int size_buff_pipe, const Str &path_dir);
  ~CompFamGraphNooverlap4PartNLinkMaxPipe();
};

/* --- CompFamGraphNooverlap4PartNLinkMaxNomerge --- */

class CompFamGraphNooverlap4PartNLinkMaxNomerge : public CompGraphFac644LstFile {
  const int size_buff_pipe, n_link_max;
  const Part part;
  const int n_max4block; // Maximum number of data records per block
  Lst<int> lst_n4block; // <v.get(i)> = Number of entries in block i.
  Card64 n_splitted; // Number of spitted elements from previos computation.

  private:
  bool dump_map2block();
  bool is_first() const;
  bool run4first();
  bool run4notfirst();
  bool split(bool &stopped);
  MapFamGraph2Int64 map_no_no_overlap;

  // Implementation of <Comp>
  protected:
  bool init_work();
  bool run4prepared_inited();
  bool load_work  (InBuffered&);
  bool load_result(InBuffered&);
  bool save_work  (Out&) const;
  bool save_result(Out&) const;
  bool setup_lst_comp_prepare(Lst<Pt<Comp> > &lst) const;
  Str get_filename4result() const;
  Str get_filename4work() const;

  // Implementation of <CompGraphFac644LstFile>
  public:
  Str get_filename4block(int i_block) const;
  int get_i_block_start4result() const;
  int get_i_block_end4result  () const;
  int get_n4block(int i_block) const;

  public:
  CompFamGraphNooverlap4PartNLinkMaxNomerge(const Part&, int n_link_max, int n_max4block, int size_buff_pipe, const Str &path_dir);
  ~CompFamGraphNooverlap4PartNLinkMaxNomerge();
  static bool read_evtl_filename4result(const Str &filename, Part&, int &n_link);

  public:
  static const Str start_filename;
};


///////////////////
// FILE bigint.h //
///////////////////

// From lego4


////////////////
// FILE str.h //
////////////////

// From c:\consql




//////////////////////
// FILE cnplink.cpp //
//////////////////////

/* --- static fields --- */

static const Str s_dot_dat(".dat");
static const Str s_pipe("pipe");
static const Str s_pipe_dot_dat("pipe.dat");
static const Str s_i_brick_eq("ibrick=");
static const Str s_j_brick_eq("jbrick=");
static const Str s_n_result_eq("nresult=");
static const Str s_pipe_work_dot_dat("pipe_work.dat");
static const Str s_work_dot_dat("work.dat");
static const int min_overlap = min_int(OVERLAP_BRICK, NOOVERLAP_BRICK, MAYOVERLAP_BRICK);

/* --- declare static functions --- */



/* === CompGraphNoProhibeLink4Part ================================= */

/* --- static members --- */

const Str CompGraphNoProhibeLink4Part::start_filename("graph_no_prohibe_link4part(");

/* --- get_all --- */

void CompGraphNoProhibeLink4Part::get_all(GraphCprFac *arr_target, int size) const {
  FKT "CompGraphNoProhibeLink4Part::get_all";

  if (!is_complete()) errstop(fkt, "Berechnung nicht durchgefuehrt");
  if (size<n) errstop(fkt, "Zielarray zu klein");

  int i;
  for (i=0; i<n; ++i) {
    arr_target[i] = arr[i];
  }
}

/* --- get_n --- */

int CompGraphNoProhibeLink4Part::get_n() const {
  FKT "CompGraphNoProhibeLink4Part::get_n";

  if (!is_complete()) errstop(fkt, "Berechnung nicht durchgefuehrt");

  return n;
}

/* --- save_result --- */

bool CompGraphNoProhibeLink4Part::save_result(Out &out) const {

  if (!out.printf("n=$\n", n)) return false;

  int i;
  for (i=0; i<n; ++i) {
    GraphFac graph_fac(n_brick);
    graph_fac.fac = arr[i].fac;
    arr[i].graph.get(graph_fac.graph);
    if (!graph_fac.write(out)) return false;
    if (!out.print_char('\n')) return false;
  }
  return true;
}

/* --- destructor --- */

CompGraphNoProhibeLink4Part::~CompGraphNoProhibeLink4Part() {
  if (arr) delete[] arr;
}

/* --- load_result --- */

bool CompGraphNoProhibeLink4Part::load_result(InBuffered &in) {
  FKT "CompGraphNoProhibeLink4Part::load_result";

  // n = Number of items
  if (!in.read_str_given(c_n_eq)) return false;
  if (!in.read_card(n)) return false;
  if (!in.read_eoln()) return false;

  arr = new GraphCprFac[n];
  if (arr==0) errstop_memoverflow(fkt);

  int i;
  for (i=0; i<n; ++i) {
    GraphFac graph_fac;
    if (!read(in, n_brick, graph_fac)) return false;
    arr[i].graph = GraphCpr(graph_fac.graph);
    arr[i].fac = graph_fac.fac;
    if (!in.read_eoln()) return false;
  }

  return true;
}

/* --- save_work --- */

bool CompGraphNoProhibeLink4Part::save_work(Out &out) const {
  return true;
}

/* --- setup_lst_comp_prepare --- */

bool CompGraphNoProhibeLink4Part::setup_lst_comp_prepare(Lst<PtComp> &lst) const {
  lst.clear();

  PtComp pt_comp;
  if (pipe) {
    pt_comp = new CompFamGraphNooverlap4PartNLinkMaxPipe(part, 0, n_max4map, size_buff_pipe, path_dir);
  } else {
    pt_comp = new CompFamGraphNooverlap4PartNLinkMax(part, 0, n_max4map, path_dir);
  }

  lst.append(pt_comp);
  return true;
}

/* --- init_work --- */

bool CompGraphNoProhibeLink4Part::init_work() {
  return true;
}


/* --- load_work --- */

bool CompGraphNoProhibeLink4Part::load_work(InBuffered &in) {
  return true;
}

/* --- run4prepared_inited --- */

bool CompGraphNoProhibeLink4Part::run4prepared_inited() {
  FKT "CompGraphNoProhibeLink4Part::run4prepared_inited";

  if (check_stopped()) return true;

  // Load previous computation
  PtCompGraphFac644LstFile pt_comp_prev;
  if (pipe) {
    pt_comp_prev = new CompFamGraphNooverlap4PartNLinkMaxPipe(part, 0, n_max4map, size_buff_pipe, path_dir);
  } else {
    pt_comp_prev = new CompFamGraphNooverlap4PartNLinkMax(part, 0, n_max4map, path_dir);
  }

  // Run previous computation
  CompGraphFac644LstFile &comp_prev = *pt_comp_prev;
  if (!comp_prev.run()) return false;
  if (!comp_prev.is_complete()) {
    return err(Str("File ") + enquote(comp_prev.get_path4result()) + Str(" not computed"));
  }

  // Open input stream
  InFamGraphFac644LstFile in_prev;
  if (!comp_prev.open4result(in_prev, Card64::zero)) return false;

  // Put input stream into <map>
  int i;
  Str errtxt;
  MapGraph2Int64 map(n_brick);
  n = in_prev.get_n().to_int();
  log_progress_start();
  for (i=0; i<n; ++i) {

    if (i>0) log_progress("Processed $/$ data records ($).", i, n);

    const FamGraphCprFac64 &prev = *in_prev;

    // Uncommpress graph family
    FamGraph fam_graph(n_brick);
    prev.fam_graph.get(fam_graph);

    // Produce surely linked graph
    Graph graph(n_brick);
    fam_graph.graph_linked_sure(graph);

    // Compute representant graph
    Graph rep(n_brick);
    if (!get_graph_rep(graph, rep, errtxt)) return err(errtxt);

    map.add(rep, prev.fac);

    if (!in_prev.next()) return false;
  }
  log_progress_end();

  // Close input stream
  if (!in_prev.close()) return false;

  // Allocate array
  arr = new GraphCprFac[n];
  if (arr==0) errstop_memoverflow(fkt);

  // Put <map> into array
  Storer<GraphCprFac> storer(arr, n);
  Compressor4GraphFac compressor(storer);
  if (!map.iterate(compressor)) return false;

  return set_complete();
}

/* --- get_filename4work --- */

Str CompGraphNoProhibeLink4Part::get_filename4work() const {
  return start_filename+part.to_str()+c_end_filename_work;
}

/* --- get_filename4result --- */

Str CompGraphNoProhibeLink4Part::get_filename4result() const {
  return start_filename+part.to_str()+c_end_filename_result;
}


/* --- read_evtl_filename4result --- */

bool CompGraphNoProhibeLink4Part::read_evtl_filename4result(const Str &filename, Part &part) {
  In4Str in(filename);

  if (!in.read_evtl_str_given(start_filename)) return false;
  if (!read_evtl(in, part)) return false;
  if (!in.read_evtl_str_given(c_end_filename_result)) return false;

  return in.at_end();
}

/* --- constructor --- */

CompGraphNoProhibeLink4Part::CompGraphNoProhibeLink4Part(
  const Part &p_part,
  int p_n_max4map,
  const Str &path_dir,
  bool p_pipe,
  int p_size_buff_pipe
) :
  Comp(path_dir),
  part(p_part),
  n_brick(p_part.get_n_brick()),
  n_max4map(p_n_max4map),
  n_link_max(p_part.get_n_brick() * (p_part.get_n_brick()-1) / 2),
  size_buff_pipe(p_size_buff_pipe),
  arr(0),
  pipe(p_pipe)
{}


/* === CompFamGraphNooverlap4PartNLinkMax =============================== */

/* --- static fields --- */

const Str CompFamGraphNooverlap4PartNLinkMax::start_filename("fam_graph_nooverlap4part");

/* --- run4first --- */

bool CompFamGraphNooverlap4PartNLinkMax::run4first() {
  FKT "CompFamGraphNooverlap4PartNLinkMax::run4first";

  CompRepFamGraph4Part comp_rep(part, path_dir);
  if (!comp_rep.run()) return false;
  if (!comp_rep.is_complete()) {
    return err(Str("File ") + enquote(comp_rep.get_filename4result()) + Str(" not computed"));
  }

  int n = comp_rep.get_n();
  FamGraphFac64 *arr = new FamGraphFac64[n];
  if (arr==0) errstop_memoverflow(fkt);

  int i;
  for (i=0; i<n; ++i) {

    FamGraphFac rep=comp_rep.get(i);
    FamGraphFac64 &elem=arr[i];
    int sign = (rep.fac==0 ? 0 : (rep.fac>0 ? 1 : -1));
    Card64 abs_fac((DWORD)abs(rep.fac));
    elem.fam_graph = rep.fam_graph;
    elem.fac = Int64(sign, abs_fac);
  }

  qsort(arr, n, sizeof(FamGraphFac64), &cmp_fam_graph644qsort);

  Str path = get_path4block(0);
  Out4File out4file;
  if (!out4file.open(path)) {
    delete[] arr;
    return false;
  }

  Checksummer4Out out(out4file);
  if (!Comp::write_fileclause(out, get_filename4block(0))) {
    delete[] arr;
    out4file.close();
    return false;
  }
  if (!out.printf("n=$\n", n)) {
    delete[] arr;
    out4file.close();
    return false;
  }
  for (i=0; i<n; ++i) {
    if (!(arr[i].write_fast(out) && out.print_eoln())) {
      out4file.close();
      delete[] arr;
      return false;
    }
  }

  delete[] arr;

  if (!out.write_chksum()) {
    out4file.close();
    return false;
  }

  if (!out4file.close()) {
    return false;
  }

  lst_n4block.append(n);
  i_block_start4result=0;
  i_block_end4result=1;

  return set_complete();
}

/* --- merge  --- */

bool CompFamGraphNooverlap4PartNLinkMax::merge(bool &stopped) {
  FKT "CompFamGraphNooverlap4PartNLinkMax::merge";

  stopped=false;

  while (n_stream>1) {

    // Find a pair to merge, if no pair is in progress
    int i_stream;
    if (i_pair_stream_merged<0) {
      int n_block_splitted_stream_min = arr_stream[1].i_block_splitted_end-arr_stream[0].i_block_splitted_start;
      i_pair_stream_merged=0;
      for (i_stream=1; i_stream+1<n_stream; ++i_stream) {
        int n_block_splitted_stream = arr_stream[i_stream+1].i_block_splitted_end-arr_stream[i_stream].i_block_splitted_start;
        if (n_block_splitted_stream_min>n_block_splitted_stream) {
          i_pair_stream_merged=i_stream;
          n_block_splitted_stream_min=n_block_splitted_stream;
        }
      }

      // Note <n_block_start>
      n_block_start = lst_n4block.get_n();
    }

    // Set references to the streams to me merged
    Stream &stream1 = arr_stream[i_pair_stream_merged], &stream2 = arr_stream[i_pair_stream_merged+1];

    // Perform some checks
    if (!(0<=i_pair_stream_merged && i_pair_stream_merged+1<n_stream)) errstop(fkt, "i_pair_stream_merged ausserhabl des gueltigen Bereiches");
    if (stream1.i_block_splitted_end!=stream2.i_block_splitted_start) errstop(fkt, "stream1.i_block_splitted_end!=stream2.i_block_splitted_start");

    // Set filenames and file sized
    Lst<Str> lst_filename1, lst_filename2;
    Lst<int> lst_n1, lst_n2;
    int i_block;
    for (i_block=stream1.i_block_sorted_start; i_block<stream1.i_block_sorted_end; ++i_block) {
      Str filename = get_filename4block(i_block);
      int n4block  = lst_n4block.get   (i_block);
      lst_filename1.append(filename);
      lst_n1       .append(n4block);
    }
    for (i_block=stream2.i_block_sorted_start; i_block<stream2.i_block_sorted_end; ++i_block) {
      Str filename = get_filename4block(i_block);
      int n4block  = lst_n4block.get   (i_block);
      lst_filename2.append(filename);
      lst_n2       .append(n4block);
    }

    // Open input streams
    if (!in4merge1.open(path_dir, lst_filename1, lst_n1, n_merged1, n_brick)) return false;
    if (!in4merge2.open(path_dir, lst_filename2, lst_n2, n_merged2, n_brick)) return false;

    // Merge input streams
    bool ok=true;
    log("Mische gesplittete Bloecke $-$ und $-$ (von $)...", stream1.i_block_splitted_start, stream1.i_block_splitted_end-1, stream2.i_block_splitted_start, stream2.i_block_splitted_end-1, n_block_splitted);
    FamGraphCprFac64 elem_merged;
    while ((!in4merge1.at_end() || !in4merge2.at_end()) && !stopped) {
      if (!in4merge1.at_end()) {
        const FamGraphCprFac64 &elem1 = *in4merge1;
        if (!in4merge2.at_end()) {
          const FamGraphCprFac64 &elem2 = *in4merge2;
          int res_cmp = cmp(elem1.fam_graph, elem2.fam_graph);

          // Graph families equal => merge
          if (res_cmp==0) {
            elem_merged=elem1;
            elem_merged.fac+=elem2.fac;
            lst_merge.append(elem_merged);
            if (!(in4merge1.next() && in4merge2.next())) {ok=false; break;}
          }

          // <elem1> smaller => send it
          if (res_cmp<0) {
            lst_merge.append(elem1);
            if (!in4merge1.next()) {ok=false; break;}
          }

          // <elem2> smaller => send it
          if (res_cmp>0) {
            lst_merge.append(elem2);
            if (!in4merge2.next()) {ok=false; break;}
          }
        } else { // <elem1> present, but not <elem2> => send <elem1>
          lst_merge.append(elem1);
          if (!in4merge1.next()) {ok=false; break;}
        }
      } else {
        if (!in4merge2.at_end()) {
          const FamGraphCprFac64 &elem2 = *in4merge2;
          lst_merge.append(elem2);
          if (!in4merge2.next()) {ok=false; break;}
        }
      }

      // Dump list, if full
      if (lst_merge.get_n()>=n_max4block) {
        if (!dump_lst2block()) {
          return false;
        }
        stopped = stopped || check_stopped();

        // Progress information
        Card64 sum_i = in4merge1.get_i()+in4merge2.get_i();
        Card64 sum_n = in4merge1.get_n()+in4merge2.get_n();
        log_progress_imm("Processed $/$ data records of the attachments to be merged ($).", sum_i, sum_n);
      }
    } // while (!at_end)

    n_merged1 = in4merge1.get_i();
    n_merged2 = in4merge2.get_i();

    if (!in4merge1.close()) return false;
    if (!in4merge2.close()) return false;

    if (!ok) return false;

    // Dump list, if not empty
    if (lst_merge.get_n()>0) {
      if (!dump_lst2block()) {
        return false;
      }
      stopped = stopped || check_stopped();
    }

    if (stopped) return true;

    // From here on, streams are merged

    log("Gesplittete Bloecke $-$ und $-$ gemischt.", stream1.i_block_splitted_start, stream1.i_block_splitted_end-1, stream2.i_block_splitted_start, stream2.i_block_splitted_end-1);

    // Note that old stream files can be removed
    for (i_block=stream1.i_block_sorted_start; i_block<stream1.i_block_sorted_end; ++i_block) {
      lst_i_block4remove.append(i_block);
    }
    for (i_block=stream2.i_block_sorted_start; i_block<stream2.i_block_sorted_end; ++i_block) {
      lst_i_block4remove.append(i_block);
    }

    // Melt stream1 and stream2
    stream1.i_block_splitted_end = stream2.i_block_splitted_end;
    stream1.i_block_sorted_start = n_block_start;
    stream1.i_block_sorted_end   = lst_n4block.get_n();

    // Remove stream2 from array
    for (i_stream=i_pair_stream_merged+1; i_stream+1<n_stream; ++i_stream) {
      arr_stream[i_stream] = arr_stream[i_stream+1];
    }
    --n_stream;

    i_pair_stream_merged=n_block_start=-1;
    n_merged1=Card64::zero;
    n_merged2=Card64::zero;

  } // while (n_stream>1)

  return true;
}

/* --- load_result_static --- */

bool CompFamGraphNooverlap4PartNLinkMax::load_result_static(InBuffered &in, bool &pipe, int &i_block_start, int &i_block_end, Lst<int> &lst_n4block) {

  // pipe ?
  if (in.read_evtl_str_given(s_pipe)) {
    pipe=true;
    if (!in.read_eoln()) return false;
  } else {
    pipe=false;
  }

  // read number of blocks
  static const Str s_i_block_start_eq("iblockstart=");
  static const Str s_i_block_end_eq  ("iblockend="  );
  if (!(
    in.read_str_given(s_i_block_start_eq) && in.read_card(i_block_start) && in.read_eoln() &&
    in.read_str_given(s_i_block_end_eq  ) && in.read_card(i_block_end  ) && in.read_eoln()
  )) {
    return false;
  }

  // Pad <lst_n4block> with dummy values
  int i_block;
  lst_n4block.clear();
  for (i_block=0; i_block<i_block_start; ++i_block) {
    lst_n4block.append(-1);
  }

  // Read number of data records for each block
  for (i_block=i_block_start; i_block<i_block_end; ++i_block) {
    int n4block;
    if (!(in.read_card(n4block) && in.read_eoln())) return false;
    lst_n4block.append(n4block);
  }

  return true;
}


/* --- load_result --- */

bool CompFamGraphNooverlap4PartNLinkMax::load_result(InBuffered &in) {
  // FKT "CompGraphNoProhibeLink4Part::load_result";

  if (!load_result_static(in, pipe_result, i_block_start4result, i_block_end4result, lst_n4block)) return false;

  i_pair_stream_merged=n_block_start=-1;
  n_block_splitted=-1;
  n_stream=-1;
  if (arr_stream) delete[] arr_stream;
  arr_stream=0;

  return true;
}

/* --- save_result --- */

bool CompFamGraphNooverlap4PartNLinkMax::save_result(Out &out) const {

  if (!out.printf("iblockstart=$\n", i_block_start4result)) return false;
  if (!out.printf("iblockend=$\n"  , i_block_end4result  )) return false;

  // write number of data records for each block
  int i_block;
  for (i_block=i_block_start4result; i_block<i_block_end4result; ++i_block) {
    if (!out.printf("$\n", lst_n4block.get(i_block))) return false;
  }

  return true;
}


/* --- init_work --- */

bool CompFamGraphNooverlap4PartNLinkMax::init_work() {
  lst_merge.clear();
  lst_n4block.clear();
  map_no_no_overlap.clear();
  n_merged1=Card64::zero;
  n_merged2=Card64::zero;
  n_splitted=Card64::zero;
  i_pair_stream_merged=n_block_start=n_stream=n_block_splitted=-1;
  if (arr_stream) delete[] arr_stream;
  arr_stream=0;
  pipe_result=false;
  return true;
}

/* --- split --- */

bool CompFamGraphNooverlap4PartNLinkMax::split(bool &stopped) {
  FKT "CompFamGraphNooverlap4PartNLinkMax::split";

  stopped=false;

  // Run previous computation
  CompFamGraphNooverlap4PartNLinkMax comp_prev(part, n_link_max+1, n_max4block, path_dir);
  if (!comp_prev.run()) return false;
  if (!comp_prev.is_complete()) {
    return err(Str("File ") + enquote(comp_prev.get_path4result()) + Str(" not computed"));
  }

  // Open input stream
  if (!comp_prev.open4result(in_prev, n_splitted)) return false;

  // Get number of blocks of previous computation
  // int i_block_start_prev = comp_prev.get_i_block_start();
  bool ok=true;
  Str filename_prev = comp_prev.get_filename4result(), path_prev = comp_prev.get_path4result();
  log_progress_start("Split attachments of file \"$\"...", path_prev);
  while (!stopped && !in_prev.at_end()) {

    // Read data recoed
    const FamGraphCprFac64 &prev = *in_prev;

    // Umcompress
    FamGraph fam_graph_prev(n_brick);
    prev.fam_graph.get(fam_graph_prev);

    // Reduce number of no-links below the limit /(if necessary), and put result to <map_no_no_overlap>
    int n_link4overlap = fam_graph_prev.get_n_link4overlap(NOOVERLAP_BRICK);
    if (n_link4overlap<=n_link_max) { // number of no-links is sufficiently low => forward it unchanged
      map_no_no_overlap.add(fam_graph_prev, prev.fac);
    } else { // number of no-links is not sufficiently low => split it

      if (n_link4overlap>n_link_max+1) {
        ok=in_prev.err_at("Zu viele Verbindungen, die sich nicht ueberlappen duerfen");
        break;
      }

      int i_brick=0, j_brick=0;
      fam_graph_prev.get4overlap(NOOVERLAP_BRICK, i_brick, j_brick);

      // Set link to MAYOVERLAP_BRICK and feed map
      FamGraph fam_graph(fam_graph_prev);
      FamGraph rep(n_brick);
      Str errtxt;
      int n_perm;
      fam_graph.set_overlap(i_brick, j_brick, MAYOVERLAP_BRICK);
      if (!get_fam_graph_rep_fast(fam_graph, rep, n_perm, errtxt)) {ok=in_prev.err_at(errtxt); break;}
      map_no_no_overlap.add(rep, prev.fac);

      // Set link to OVERLAP_BRICK and feed map
      Int64 fac;
      fam_graph.set_overlap(i_brick, j_brick, OVERLAP_BRICK);
      if (!get_fam_graph_rep_fast(fam_graph, rep, n_perm, errtxt)) {ok=in_prev.err_at(errtxt); break;}
      fac = -prev.fac;
      map_no_no_overlap.add(rep, fac);
    }

    // Dump map, if full
    if (map_no_no_overlap.get_n()>=n_max4block) {

      if (!dump_map2block()) {
        return false;
      }

      // Query whether stopped
      stopped = stopped || check_stopped();
    }

    if (!in_prev.next()) {ok=false; break;}
    ++n_splitted;
    log_progress("Processed $/$ data records ($).", in_prev.get_i(), in_prev.get_n());
  }

  if (!in_prev.close()) return false;
  if (!ok) return false;

  // if map not empty, dump it
  if (map_no_no_overlap.get_n()>0) {
    if (!dump_map2block()) {
      return false;
    }

    // Query whether stopped
    stopped = stopped || check_stopped();
  }

  if (stopped) return true;

  int n_block = lst_n4block.get_n();
  log_progress_end("Splitted attachments of file \"$\" into $ attachmentst.", path_prev, n_block);

  // Produce stream array: one for each block
  int i_stream;
  n_stream=n_block;
  if (arr_stream) delete[] arr_stream;
  arr_stream = new Stream[n_stream];
  if (arr_stream==0) errstop_memoverflow(fkt);
  for (i_stream=0; i_stream<n_stream; ++i_stream) {
    Stream &stream = arr_stream[i_stream];
    int i_block=i_stream;
    stream.i_block_splitted_start = stream.i_block_sorted_start = i_block  ;
    stream.i_block_splitted_end   = stream.i_block_sorted_end   = i_block+1;
  }

  n_block_splitted=n_block;
  return true;
}

/* --- get_path4block --- */

Str CompFamGraphNooverlap4PartNLinkMax::get_path4block(int i_block) const {
  return get_path4filename(get_filename4block(i_block));
}

/* --- get_filename4block --- */

Str CompFamGraphNooverlap4PartNLinkMax::get_filename4block(int i_block) const {
  return get_filename4block_static(part, n_link_max, i_block, pipe_result);
}

/* --- get_filename4block_static --- */

Str CompFamGraphNooverlap4PartNLinkMax::get_filename4block_static(const Part &part, int n_link_max, int i_block, bool pipe) {
  return start_filename + embrace(part.to_str()) + c_nlinkmax + embrace(str4card(n_link_max)) + c_block + embrace(str4card(i_block)) + (pipe ? s_pipe_dot_dat : s_dot_dat);
}

/* --- dump_lst2block --- */

bool CompFamGraphNooverlap4PartNLinkMax::dump_lst2block() {
  int n=lst_merge.get_n();

  int i_block = lst_n4block.get_n();
  Str path = get_path4block(i_block);
  Out4File out_file;
  if (!out_file.open(path)) {
    return false;
  }

  Checksummer4Out out(out_file);
  log("Save list into file \"$\"...", path);

  if (!Comp::write_fileclause(out, get_filename4block(i_block))) {
    out_file.close();
    return false;
  }

  if (!out.printf("n=$\n", n)) {
    out_file.close();
    return false;
  }

  int i;
  for (i=0; i<n; ++i) {
    if (!(lst_merge.get(i).write_fast(out) && out.print_eoln())) {
      out_file.close();
      return false;
    }
  }

  lst_merge.clear();

  if (!out.write_chksum()) {
    out_file.close();
    return false;
  }

  lst_n4block.append(n);

  if (!out_file.close()) return false;

  log("List saves to file \"$\".", path);

  return true;
}

/* --- dump_map2block --- */

bool CompFamGraphNooverlap4PartNLinkMax::dump_map2block() {
  FKT "CompFamGraphNooverlap4PartNLinkMax::dump2block";

  int n=map_no_no_overlap.get_n_no_zero();

  FamGraphFac64 *arr = new FamGraphFac64[n];
  if (arr==0) errstop_memoverflow(fkt);

  Storer<FamGraphFac64> storer(arr, n);
  if (!map_no_no_overlap.iterate_no_zero(storer)) return false;
  map_no_no_overlap.clear();

  qsort(arr, n, sizeof(*arr), &cmp_fam_graph644qsort);

  int i_block = lst_n4block.get_n();
  Str path = get_path4block(i_block);
  Out4File out_file;
  if (!out_file.open(path)) {
    delete[] arr;
    return false;
  }

  Checksummer4Out out(out_file);
  log("Save map to file \"$\"...", path);

  if (!Comp::write_fileclause(out, get_filename4block(i_block))) {
    out_file.close();
    return false;
  }

  if (!out.printf("n=$\n", n)) {
    out_file.close();
    return false;
  }

  int i;
  for (i=0; i<n; ++i) {
    if (!(arr[i].write_fast(out) && out.print_eoln())) {
      out_file.close();
      delete[] arr;
      return false;
    }
  }

  if (!out.write_chksum()) {
    out_file.close();
    delete[] arr;
    return false;
  }

  lst_n4block.append(n);

  if (!out_file.close()) return false;

  log("Saved map to file \"$\".", path);
  delete[] arr;

  return true;
}

/* --- run4notfirst --- */

bool CompFamGraphNooverlap4PartNLinkMax::run4notfirst() {

  // Split into temporary files
  bool stopped=false;
  if (n_block_splitted<0) {
    if (!split(stopped)) return false;
    if (stopped) {
      return true;
    }
  }

  // Merge temporary files
  if (!merge(stopped)) return false;
  if (stopped) {
    return true;
  }

  // if (n_stream<1) errstop(fkt, "n_stream<1");

  if (n_stream>=1) {
    Stream &stream = arr_stream[0];
    i_block_start4result = stream.i_block_sorted_start;
    i_block_end4result   = stream.i_block_sorted_end  ;
  } else { // No solutions
    i_block_start4result = 0;
    i_block_end4result   = 0;
  }

  return set_complete();
}

/* --- load_work --- */

bool CompFamGraphNooverlap4PartNLinkMax::load_work(InBuffered &in) {
  FKT "CompFamGraphNooverlap4PartNLinkMax::load_work";
  if (is_first()) errstop(fkt, "Unerwarteter Aufruf");

  // <lst_n4block>
  static const Str s_n_block_eq("nblock=");
  int n, i;
  lst_n4block.clear();
  if (!(in.read_str_given(s_n_block_eq) && in.read_card(n) && in.read_eoln())) return false;
  for (i=0; i<n; ++i) {
    int n4block;
    if (!(in.read_card(n4block) && in.read_eoln())) return false;
    lst_n4block.append(n4block);
  }

  // n_splitted
  static const Str s_n_splitted_eq("nsplitted=");
  if (!(in.read_str_given(s_n_splitted_eq) && read(in, n_splitted) && in.read_eoln())) return false;

  // i_pair_stream_merged, n_merged
  static const Str s_i_pair_stream_merged_eq("ipairstreammerged="), s_n_merged1_eq("nmerged1="), s_n_merged2_eq("nmerged2="), s_n_block_start_eq("nblockstart=");
  if (in.read_evtl_str_given(s_i_pair_stream_merged_eq)) {
    if (!(in.read_card(i_pair_stream_merged) && in.read_eoln())) return false; // i_pair_stream_merged
    if (!(in.read_str_given(s_n_merged1_eq    ) && read(in, n_merged1) && in.read_eoln())) return false; // n_merged1
    if (!(in.read_str_given(s_n_merged2_eq    ) && read(in, n_merged2) && in.read_eoln())) return false; // n_merged1
    if (!(in.read_str_given(s_n_block_start_eq) && in.read_card(n_block_start) && in.read_eoln())) return false; // n_block_start
  } else {
    i_pair_stream_merged=n_block_start=-1;
    n_merged1=Card64::zero;
    n_merged2=Card64::zero;
  }

  // n_block_splitted
  static const Str s_n_block_splitted_eq("nblocksplitted=");
  if (in.read_evtl_str_given(s_n_block_splitted_eq)) {
    if (!(in.read_card(n_block_splitted) && in.read_eoln())) return false;
  } else {
    n_block_splitted=-1;
  }

  // n_stream, arr_stream
  static const Str s_n_stream_eq("nstream=");
  if (arr_stream) delete[] arr_stream;
  if (in.read_evtl_str_given(s_n_stream_eq)) {
    if (!(in.read_card(n_stream) && in.read_eoln())) return false;

    arr_stream = new Stream[n_stream];
    if (arr_stream==0) errstop_memoverflow(fkt);

    int i_stream;
    for (i_stream=0; i_stream<n_stream; ++i_stream) {
      Stream &stream = arr_stream[i_stream];
      static const Str s_middle(")->(");
      if (!(
        in.read_char_given('(') &&
        in.read_card(stream.i_block_splitted_start) &&
        in.read_char_given('-') &&
        in.read_card(stream.i_block_splitted_end) &&
        in.read_str_given(s_middle) &&
        in.read_card(stream.i_block_sorted_start) &&
        in.read_char_given('-') &&
        in.read_card(stream.i_block_sorted_end) &&
        in.read_char_given(')') &&
        in.read_eoln()
      )) return false;
    }
  } else {
    n_stream=-1;
    arr_stream=0;
  }

  map_no_no_overlap.clear();
  lst_merge.clear();

  pipe_result=false;

  return true;
}

/* --- save_work --- */

bool CompFamGraphNooverlap4PartNLinkMax::save_work(Out &out) const {
  FKT "CompFamGraphNooverlap4PartNLinkMax::save_work";

  if (is_first()) errstop(fkt, "Unerwarteter Aufruf");

  // <lst_n_block>
  int n=lst_n4block.get_n(), i;
  if (!out.printf("nblock=$\n", n)) return false;
  for (i=0; i<n; ++i) {
    if (!out.printf("$\n", lst_n4block.get(i))) return false;
  }

  // n_splitted
  if (!out.printf("nsplitted=$\n", n_splitted)) return false;

  // i_pair_stream_merged, n_merged
  if (i_pair_stream_merged>=0) {
    if (!out.printf("ipairstreammerged=$\n", i_pair_stream_merged)) return false;
    if (!out.printf("nmerged1=$\n"         , n_merged1           )) return false;
    if (!out.printf("nmerged2=$\n"         , n_merged2           )) return false;
    if (!out.printf("nblockstart=$\n"      , n_block_start       )) return false;
  }

  // n_block_splitted
  if (n_block_splitted>=0) {
    if (!out.printf("nblocksplitted=$\n", n_block_splitted)) return false;
  }

  // n_stream, arr_stream
  if (n_stream>=0) {
    if (!out.printf("nstream=$\n", n_stream)) return false;

    int i_stream;
    for (i_stream=0; i_stream<n_stream; ++i_stream) {
      Stream &stream = arr_stream[i_stream];
      if (!out.printf("($-$)->($-$)\n", stream.i_block_splitted_start, stream.i_block_splitted_end, stream.i_block_sorted_start, stream.i_block_sorted_end)) return false;
    }
  }

  return true;
}

/* --- get_n --- */

// Compute n = number of computed graph families

Card64 CompFamGraphNooverlap4PartNLinkMax::get_n() const {
  FKT "CompFamGraphNooverlap4PartNLinkMax::get_n";

  if (!is_complete()) errstop(fkt, "Berechnung nicht vollendet.");

  Card64 n=Card64::zero;
  int i_block;
  for (i_block=i_block_start4result; i_block<i_block_end4result; ++i_block) {
    n+=Card64(DWORD(lst_n4block.get(i_block)));
  }
  return n;
}

/* --- get_i_block_start4result --- */

// returns index of first result block

int CompFamGraphNooverlap4PartNLinkMax::get_i_block_start4result() const {
  FKT "CompFamGraphNooverlap4PartNLinkMax::get_i_block_start4result";

  if (!is_complete()) errstop(fkt, "Berechnung nicht vollendet.");

  return i_block_start4result;
}

/* --- get_i_block_end4result --- */

// returns index of first result block

int CompFamGraphNooverlap4PartNLinkMax::get_i_block_end4result() const {
  FKT "CompFamGraphNooverlap4PartNLinkMax::get_i_block_end4result";

  if (!is_complete()) errstop(fkt, "Berechnung nicht vollendet.");

  return i_block_end4result;
}

/* --- get_n4block --- */

// Compute n = number of computed graph families

int CompFamGraphNooverlap4PartNLinkMax::get_n4block(int i_block) const {
  FKT "CompFamGraphNooverlap4PartNLinkMax::get_n4block";

  if (!is_complete()) errstop(fkt, "Berechnung nicht vollendet.");
  if (!(i_block_start4result<=i_block && i_block<i_block_end4result)) errstop_index(fkt);

  return lst_n4block.get(i_block);
}

/* --- is_first --- */

bool CompFamGraphNooverlap4PartNLinkMax::is_first() const {
  return n_link_max>=n_brick*(n_brick-1)/2;
}

/* --- run4prepared_inited --- */

bool CompFamGraphNooverlap4PartNLinkMax::run4prepared_inited() {

  if (is_first()) {
    if (!run4first()) return false;
  } else {
    if (!run4notfirst()) return false;
  }

  if (is_complete()) {
    log("The file \"$\" contains $ graph families.", get_path4result(), get_n());
  }
  return true;
}

/* --- setup_lst_comp_prepare --- */

bool CompFamGraphNooverlap4PartNLinkMax::setup_lst_comp_prepare(Lst<PtComp> &lst) const {
  lst.clear();

  PtComp pt_comp;
  if (is_first()) {
    pt_comp = new CompRepFamGraph4Part(part, path_dir);
  } else {
    pt_comp = new CompFamGraphNooverlap4PartNLinkMax(part, n_link_max+1, n_max4block, path_dir);
  }
  lst.append(pt_comp);
  return true;
}

/* --- constructor --- */

CompFamGraphNooverlap4PartNLinkMax::CompFamGraphNooverlap4PartNLinkMax(const Part &p_part, int p_n_link_max, int p_n_max4block, const Str &path_dir) :
  CompGraphFac644LstFile(path_dir, p_part.get_n_brick()),
  n_link_max(p_n_link_max),
  n_max4block(p_n_max4block),
  part(p_part),
  i_pair_stream_merged(-1),
  n_block_start(-1),
  n_block_splitted(-1),
  n_splitted(0),
  n_stream(-1),
  arr_stream(0),
  pipe_result(false)
{ FKT "CompFamGraphNooverlap4PartNLinkMax::CompFamGraphNooverlap4PartNLinkMax";

  if (!(0<=n_link_max && n_link_max<=n_brick*(n_brick-1)/2)) errstop(fkt, "n_link ausserhalb des gueltigen Bereichs");
}

/* --- destructor --- */

CompFamGraphNooverlap4PartNLinkMax::~CompFamGraphNooverlap4PartNLinkMax() {
  if (arr_stream) delete[] arr_stream;

  int i_i_block, n_i_block = lst_i_block4remove.get_n();
  for (i_i_block=0; i_i_block<n_i_block; ++i_i_block) {
    int i_block = lst_i_block4remove.get(i_i_block);
    if (remove_file(get_path4block(i_block))) {
      log("File \"$\" deleted.", get_path4block(i_block));
    } else {
      log("File \"$\" not deleted.", get_path4block(i_block));
    }
  }
}

/* --- read_evtl_filename4result --- */

bool CompFamGraphNooverlap4PartNLinkMax::read_evtl_filename4result(const Str &filename, Part &part, int &n_link_max) {
  In4Str in(filename);
  int n_brick;

  if (!in.read_evtl_str_given(start_filename)) return false;
  if (!in.read_evtl_char_given('(')) return false;
  if (!read_evtl(in, part)) return false;
  if (!in.read_evtl_char_given(')')) return false;
  if (!in.read_evtl_str_given(c_nlinkmax)) return false;
  if (!in.read_evtl_char_given('(')) return false;
  if (!in.read_evtl_card(n_link_max)) return false;
  if (!in.read_evtl_str_given(c_end_filename_result)) return false;
  n_brick = part.get_n_brick();
  if (!(0<=n_link_max && n_link_max<=n_brick*(n_brick-1)/2)) return false;

  return in.at_end();
}

/* --- get_filename4result --- */

Str CompFamGraphNooverlap4PartNLinkMax::get_filename4result() const {
  return get_filename4result_static(part, n_link_max);
}

/* --- get_filename4result_static --- */

Str CompFamGraphNooverlap4PartNLinkMax::get_filename4result_static(const Part &part, int n_link_max) {
  return start_filename + embrace(part.to_str()) + c_nlinkmax + embrace(str4card(n_link_max)) + Str(".dat");
}

/* --- get_filename4work --- */

Str CompFamGraphNooverlap4PartNLinkMax::get_filename4work() const {
  return get_filename4work_static(part, n_link_max, false);
}

/* --- get_filename4work_static --- */

Str CompFamGraphNooverlap4PartNLinkMax::get_filename4work_static(const Part &part, int n_link_max, bool pipe) {
  return start_filename + embrace(part.to_str()) + c_nlinkmax + embrace(str4card(n_link_max)) + (pipe ? s_pipe_work_dot_dat : s_work_dot_dat);
}

/* === WriterFamGraphFac64 =============================================== */

/* --- constructor --- */

WriterFamGraphFac64::WriterFamGraphFac64(Out &p_out, bool p_fast) : out(p_out), fast(p_fast) {}

/* --- perform --- */

bool WriterFamGraphFac64::perform(const FamGraphFac64 &fam_graph_fac) {
  if (!out.printf("$*", fam_graph_fac.fac)) return false;
  if (fast) {
    if (!fam_graph_fac.fam_graph.write_fast(out)) return false;
  } else {
    if (!fam_graph_fac.fam_graph.write(out)) return false;
  }
  if (!out.print_char('/')) return false;
  return true;
}


/* === exported functions ================================================= */



/* === static functions ================================================== */



///////////////////////
// FILE cnplinkb.cpp //
///////////////////////

/* === InFamGraphFac644LstFile =========================================== */

/* --- constructor --- */

InFamGraphFac644LstFile::InFamGraphFac644LstFile() : opened(false), arr(0) {}

/* --- destructor --- */

InFamGraphFac644LstFile::~InFamGraphFac644LstFile() {
  if (arr) delete[] arr;
}

/* --- open --- */

bool InFamGraphFac644LstFile::open(const Str &p_path_dir, const Lst<Str> &p_lst_filename4block, const Lst<int> &p_lst_n4block, Card64 start, int p_n_brick)  {
  FKT "InFamGraphFac644LstFile::open";

  if (opened) errstop(fkt, "opened");

  n_brick = p_n_brick;
  if (!(0<=n_brick && n_brick<=N_BRICK_MAX)) errstop_index(fkt);

  path_dir = p_path_dir;

  n_block=p_lst_filename4block.get_n();
  if (p_lst_n4block.get_n()!=n_block) errstop(fkt, "lst_n4block.get_n()!=n_block");
  lst_filename4block.clear();
  lst_n4block .clear();
  for (i_block=0; i_block<n_block; ++i_block) {
    Str filename = p_lst_filename4block.get(i_block);
    int n4block = p_lst_n4block.get(i_block);
    lst_filename4block.append(filename);
    lst_n4block.append(n4block);
  }

  n=0;
  for (i_block=0; i_block<n_block; ++i_block) {
    n+=lst_n4block.get(i_block);
  }

  if (!(Card64::zero<=start && start<=n)) errstop(fkt, "Startposition ausserhalb des gueltigen Bereiches");

  Card64 start_block=Card64::zero;
  i_block=0;
  while (i_block<n_block && plus_not_neg(start_block,lst_n4block.get(i_block))<=start) {
    int n4block = lst_n4block.get(i_block);
    DWORD  n4block_dw = (DWORD) n4block;
    if ((int)n4block_dw!=n4block) errstop(fkt, "Conversion to DWORD failed");
    start_block+=n4block_dw;
    ++i_block;
  }

  arr=0;
  if (!advance2block_next_nonempty()) return false;

  i=start;
  i4block = (i-start_block).to_int();
  opened=true;

  return true;
}

/* --- get_i --- */

const Card64& InFamGraphFac644LstFile::get_i() const {
  FKT "InFamGraphFac644LstFile::get_i";

  if (!opened) errstop(fkt, "!opened");

  return i;
}

/* --- *InFamGraphFac644LstFile --- */

const FamGraphCprFac64 &InFamGraphFac644LstFile::operator*() {
  FKT "InFamGraphFac644LstFile::operator*";

  if (!opened) errstop(fkt, "!opened");
  if (arr==0) errstop(fkt, "at end");

  return arr[i4block];
}

/* --- err_at(NTS) --- */

bool InFamGraphFac644LstFile::err_at(const char *txt) const {
  return err_at(Str(txt));
}

/* --- err_at(Str) --- */

bool InFamGraphFac644LstFile::err_at(Str txt) const {
  FKT "InFamGraphFac644LstFile::err_at(Str)";

  if (!opened) errstop(fkt, "!opened");
  if (i_block>=n_block) return err(txt);

  return err(
    Str("File ") + enquote(path_dir + sep_path + lst_filename4block.get(i_block)) + Str(", ") +
    Str("data record ") + str4card(i4block+1) + Str(": ") +
    txt
  );
}

/* --- get_n --- */

const Card64& InFamGraphFac644LstFile::get_n() const {
  FKT "InFamGraphFac644LstFile::get_n";

  if (!opened) errstop(fkt, "!opened");
  return n;
}

/* --- at_end --- */

bool InFamGraphFac644LstFile::at_end() {
  FKT "InFamGraphFac644LstFile::at_end";

  if (!opened) errstop(fkt, "!opened");
  return arr==0;
}

/* --- next --- */

bool InFamGraphFac644LstFile::next() {
  FKT "InFamGraphFac644LstFile::next";

  if (!opened) errstop(fkt, "!opened");
  if (arr==0) errstop(fkt, "at end");

  ++i4block;
  if (i4block>=lst_n4block.get(i_block)) {
    ++i_block;
    if (!advance2block_next_nonempty()) return false;
    i4block=0;
  }

  ++i;

  return true;
}

/* --- check_block_empty --- */

bool InFamGraphFac644LstFile::check_block_empty() {

  // Open file
  In4File in4file;
  Str filename = lst_filename4block.get(i_block);
  Str path = path + sep_path + filename;
  if (!in4file.open(path)) return false;

  // Open checksummer and buffered input stream
  InBuffering in_buffered(in4file);
  Chksummer4In in(in_buffered);
  if (!Comp::read_fileclause(in, filename)) {
    in4file.close();
    return false;
  }

  // check number of data records
  int test;
  if (!(in.read_str_given(c_n_eq) && in.read_card(test) && in.read_eoln())) {
    in4file.close();
    return false;
  }
  if (test!=0) {
    in4file.close();
    return err("Blockanzahl in Blockdatei und Gesamtdatei verschieden");
  }

  // Close checksummer
  if (!in.read_chksum()) {
    in4file.close();
    return false;
  }

  // Close file
  if (!in4file.close()) return false;

  return true;
}

/* --- close --- */

bool InFamGraphFac644LstFile::close() {
  if (!opened) return true;
  if (arr) {
    delete[] arr;
    arr=0;
  }
  opened=false;
  return true;
}

/* --- advance2block_next_nonempty --- */

bool InFamGraphFac644LstFile::advance2block_next_nonempty() {
  FKT "InFamGraphFac644LstFile::advance2block_next_nonempty";

  if (arr) {
    delete[] arr;
    arr=0;
  }

  // Skip empty blocks
  while (i_block<n_block && lst_n4block.get(i_block)==0) {
    if (!check_block_empty()) return false;
    ++i_block;
  }

  // At the end ?
  if (i_block==n_block) return true;

  // Open file
  In4File in4file;
  Str filename = lst_filename4block.get(i_block);
  Str path = path_dir + sep_path + filename;
  if (!in4file.open(path)) return false;

  // Open checksummer
  InBuffering in_buffered(in4file);
  Chksummer4In in(in_buffered);
  if (!Comp::read_fileclause(in, filename)) {
    in4file.close();
    return false;
  }

  // Read number of data records
  int test, n4block = lst_n4block.get(i_block);
  if (!(in.read_str_given(c_n_eq) && in.read_card(test) && in.read_eoln())) {
    in4file.close();
    return false;
  }
  if (test!=n4block) {
    in4file.close();
    return err("Blockanzahl in Blockdatei und Gesamtdatei verschieden");
  }

  // Read data
  arr = new FamGraphCprFac64[n4block];
  if (arr==0) errstop_memoverflow(fkt);
  for (i4block=0; i4block<n4block; ++i4block) {
    if (!(read_fast(in, n_brick, arr[i4block]) && in.read_eoln())) {
      in4file.close();
      return false;
    }
  }

  // Close checksummer
  if (!in.read_chksum()) {
    in4file.close();
    return false;
  }

  // Close file
  if (!in4file.close()) return false;

  return true;
}


/* === CompGraphFac644LstFile ============================================ */

/* --- destructor --- */

CompGraphFac644LstFile::~CompGraphFac644LstFile() {}

/* --- get_path4block --- */

Str CompGraphFac644LstFile::get_path4block(int i_block) const {
  return get_path4filename(get_filename4block(i_block));
}

/* --- contructor --- */

CompGraphFac644LstFile::CompGraphFac644LstFile(const Str &path_dir, int p_n_brick) :
  Comp(path_dir),
  n_brick(p_n_brick)
{}

/* --- append_lst_path_att4result --- */

void CompGraphFac644LstFile::append_lst_path_att4result(Lst<Str> &lst_path) {
  FKT "CompGraphFac644LstFile::append_lst_path_att4result";
  if (!is_complete()) errstop(fkt, "Berechnung nicht durchgefuehrt");

  int i_end = get_i_block_end4result(), i;
  for (i=get_i_block_start4result(); i<i_end; ++i) {
    Str path = get_path4block(i);
    lst_path.append(path);
  }
}

/* --- open4result --- */

// pipe_result infueces the file names of the block files of the result file

bool CompGraphFac644LstFile::open4result(InFamGraphFac644LstFile &in, const Card64 &start) {

  // Create lists
  Lst<Str> lst_filename;
  Lst<int> lst_n;
  int i, i_end = get_i_block_end4result();
  for (i=get_i_block_start4result(); i<i_end; ++i) {
    Str filename = get_filename4block(i);
    int n = get_n4block(i);
    lst_filename.append(filename);
    lst_n.append(n);
  }

  // Open stream
  if (!in.open(path_dir, lst_filename, lst_n, start, n_brick)) return false;

  return true;
}


////////////////////
// FILE filewnd.h //
////////////////////

#define MY_FILE_WND_H


/* --- FileWndBin --- */
 
class FileWndBin : public Nocopy {
  bool opened, block_last;
  const int size_wnd;
  int i_char4block, n_char4block, pos_block_next;
  char *block;

  private:
  bool fill_block();

  public:
  const Str path;
  FileWndBin(Str path, int size_wnd);
  ~FileWndBin();
  bool close();
  bool open();
  bool operator++();
  char operator*();
  bool at_end() const;
  bool is_opened() const {
    return opened;
  }
};

/* --- FileWndTxt --- */

class FileWndTxt : public In {
  FileWndBin bin;
  Card64 pos;

  public:
  FileWndTxt(Str path, int size_wnd);
  bool open();
  bool close();

  // Inplementation of in
  bool operator++();
  char operator*();
  const Card64& get_pos() const;
  bool at_end() const;
  bool err_at(Str txt, Card64 pos) const;
  bool err_at(Str txt, int i_line, int i_col) const;
  bool is_opened() const {
    return bin.is_opened();
  }
};



///////////////////////
// FILE cnplinkp.cpp //
///////////////////////

/* --- static fields --- */

static const Str s_end_filename_nomerge_result("nomerge.dat");
static const Str s_end_filename_nomerge_work("nomerge_work.dat");
static const Str s_end_filename_pipe_work("pipe_work.dat");


/* === Instream4Pipe ===================================================== */

/* --- destructor --- */

Instream4Pipe::~Instream4Pipe() {}


/* === Instream4File ===================================================== */

/* --- at_end --- */

bool Instream4File::at_end() {
  FKT "Instream4File::at_end";

  if (!opened) errstop(fkt, "!opened");
  return i_item>=n_item;
}

/* --- *Instream4File --- */

const ItemPipe& Instream4File::operator*() {
  FKT "Instream4File::operator*";

  if (!opened) errstop(fkt, "!opened");
  if (i_item>=n_item) errstop(fkt, "Stream-Ende ueberschritten");

  return current;
}

/* --- ++Instream4File --- */

bool Instream4File::operator++() {
  FKT "Instream4File::operator++";

  if (!opened) errstop(fkt, "!opened");
  if (i_item>=n_item) errstop(fkt, "Stream-Ende ueberschritten");
  ++i_item;
  if (!fill_current()) return false;

  return true;
}


/* --- destructor --- */

Instream4File::~Instream4File() {
  close_streams();
}

/* --- constructor --- */

Instream4File::Instream4File(const Str &path_dir, Str p_filename, int p_n_item, int p_size_wnd,  int p_n_brick) :
  opened(false),
  path(path_dir + sep_path + p_filename),
  filename(p_filename),
  n_item(p_n_item),
  size_wnd(p_size_wnd),
  n_brick(p_n_brick)
{}

/* --- get_n --- */

Card64 Instream4File::get_n() const {
  FKT "Instream4File::get_n";

  if (!opened) errstop(fkt, "!opened");
  return Card64(DWORD(n_item));
}

/* --- close --- */

bool Instream4File::close() {
  if (pt_in.is_null()) return true;
  if (!pt_in->read_chksum()) return false;
  return close_streams();
}

/* --- close_streams --- */

bool Instream4File::close_streams() {
  bool ok=true;

  pt_in = Pt<Chksummer4In>();
  pt_in_buffered = Pt<InBuffered>();

  if (!pt_file.is_null()) {
    if (!pt_file->close()) ok=false;
    pt_file = Pt<FileWndTxt>();
  }

  return ok;
}

/* --- fill_current --- */

bool Instream4File::fill_current() {

  if (i_item<n_item) {
    InBuffered &in = *pt_in;
    FamGraphFac64 fam_graph_fac;

    if (!read_fast(in, n_brick, fam_graph_fac)) return false;
    if (!in.read_eoln()) return false;

    current.fam_graph = fam_graph_fac.fam_graph;
    current.fac       = fam_graph_fac.fac      ;
    current.n_occur   = 1;

  }
  return true;
}

/* --- open --- */

bool Instream4File::open() {
  FKT "Instream4File::open";

  if (!pt_file.is_null()) errstop(fkt, "Bereits geoeffnet");

  FileWndTxt *pt_file_native = new FileWndTxt(path, size_wnd);
  if (pt_file_native==0) errstop_memoverflow(fkt);
  pt_file = pt_file_native;

  FileWndTxt &file = *pt_file;
  if (!file.open()) {
    pt_file = Pt<FileWndTxt>();
    return false;
  }

  InBuffered *pt_in_buffered_native = new InBuffering(file);
  if (pt_in_buffered_native==0) errstop_memoverflow(fkt);
  pt_in_buffered = pt_in_buffered_native;

  Chksummer4In *pt_in_native = new Chksummer4In(*pt_in_buffered);
  if (pt_in_native==0) errstop_memoverflow(fkt);
  pt_in = pt_in_native;

  Chksummer4In &in = *pt_in;
  if (!Comp::read_fileclause(in, filename)) {
    close_streams();
    return false;
  }

  // n = Number of items
  int n;
  if (!(in.read_str_given(c_n_eq) && in.read_card(n) && in.read_eoln())) {close_streams(); return false;}
  if (n!=n_item) {
    close_streams();
    return err(Str("File ") + enquote(path) + Str(": Wrong number of data records."));
  }

  i_item=0;
  if (!fill_current()) {
    close_streams(); return false;
    return false;
  }

  opened=true;
  return true;
}


/* === InstreamMerge ==================================================== */

/* --- constructor --- */

InstreamMerge::InstreamMerge(const PtInstream4Pipe &p_pt_a, const PtInstream4Pipe &p_pt_b) : pt_a(p_pt_a), pt_b(p_pt_b), a(*p_pt_a), b(*p_pt_b), opened(false) {}

/* --- get_n --- */

Card64 InstreamMerge::get_n() const {
  return a.get_n() + b.get_n();
}

/* --- destructor --- */

InstreamMerge::~InstreamMerge() {
  close();
}

/* --- close --- */

bool InstreamMerge::close() {
  if (!opened) return true;
  return a.close() | b.close(); // no "||" goes here; this closes as many children as possible
}


/* --- fill_current --- */

bool InstreamMerge::fill_current() {
  if (a.at_end()) {
    if (b.at_end()) {
      has_current=false;
    } else {
      has_current=true;
      current = *b;
      if (!++b) return false;
    }
  } else {
    has_current=true;
    if (b.at_end()) {
      current = *a;
      if (!++a) return false;
    } else {
      const ItemPipe &item_a=*a, &item_b=*b;
      int cmp_item = cmp(item_a.fam_graph, item_b.fam_graph);

      if (cmp_item==0) { // Merge
        current.fam_graph = item_a.fam_graph             ;
        current.fac       = item_a.fac    +item_b.fac    ;
        current.n_occur   = item_a.n_occur+item_b.n_occur;
        if (!++a) return false;
        if (!++b) return false;
      } else if (cmp_item<0) { // Take a
        current = item_a;
        if (!++a) return false;
      } else { // Take b
        current = item_b;
        if (!++b) return false;
      }
    }
  }

  return true;
}

/* --- ++InstreamMerge --- */

bool InstreamMerge::operator++() {
  FKT "InstreamMerge::operator++";

  if (!opened) errstop(fkt, "!opened");
  if (!has_current) errstop(fkt, "Stream-Ende ueberschritten");

  if (!fill_current()) return false;
  return true;
}

/* --- open --- */

bool InstreamMerge::open() {
  FKT "InstreamMerge::open";

  if (opened) errstop(fkt, "Bereits geoeffnet");

  if (!a.open()) return false;
  if (!b.open()) {a.close(); return false;}

  if (!fill_current()) {a.close(); b.close(); return false;}
  opened=true;
  return true;
}

/* --- *InstreamMerge --- */

const ItemPipe& InstreamMerge::operator*() {
  FKT "InstreamMerge::operator*";

  if (!opened) errstop(fkt, "!opened");
  if (!has_current) errstop(fkt, "Stream-Ende ueberschritten");

  return current;
}

/* --- at_end --- */

bool InstreamMerge::at_end() {
  FKT "InstreamMerge::at_end";

  if (!opened) errstop(fkt, "!opened");
  return !has_current;
}


/* === CompFamGraphNooverlap4PartNLinkMaxNomerge ========================= */

/* --- static fields --- */

const Str CompFamGraphNooverlap4PartNLinkMaxNomerge::start_filename("fam_graph_nooverlap4part");

/* --- run4first --- */

bool CompFamGraphNooverlap4PartNLinkMaxNomerge::run4first() {
  FKT "CompFamGraphNooverlap4PartNLinkMaxNomerge::run4first";

  CompRepFamGraph4Part comp_rep(part, path_dir);
  if (!comp_rep.run()) return false;
  if (!comp_rep.is_complete()) {
    return err(Str("File ") + enquote(comp_rep.get_filename4result()) + Str(" not computed"));
  }

  int n = comp_rep.get_n();
  FamGraphFac64 *arr = new FamGraphFac64[n];
  if (arr==0) errstop_memoverflow(fkt);

  int i;
  for (i=0; i<n; ++i) {

    FamGraphFac rep=comp_rep.get(i);
    FamGraphFac64 &elem=arr[i];
    int sign = (rep.fac==0 ? 0 : (rep.fac>0 ? 1 : -1));
    Card64 abs_fac((DWORD)abs(rep.fac));
    elem.fam_graph = rep.fam_graph;
    elem.fac = Int64(sign, abs_fac);
  }

  qsort(arr, n, sizeof(FamGraphFac64), &cmp_fam_graph644qsort);

  Str path = get_path4block(0);
  Out4File out4file;
  if (!out4file.open(path)) {
    delete[] arr;
    return false;
  }

  Checksummer4Out out(out4file);
  if (!Comp::write_fileclause(out, get_filename4block(0))) {
    delete[] arr;
    out4file.close();
    return false;
  }
  if (!out.printf("n=$\n", n)) {
    delete[] arr;
    out4file.close();
    return false;
  }
  for (i=0; i<n; ++i) {
    if (!(arr[i].write_fast(out) && out.print_eoln())) {
      out4file.close();
      delete[] arr;
      return false;
    }
  }

  delete[] arr;

  if (!out.write_chksum()) {
    out4file.close();
    return false;
  }

  if (!out4file.close()) {
    return false;
  }

  lst_n4block.append(n);

  return set_complete();
}

/* --- get_n4block --- */

int CompFamGraphNooverlap4PartNLinkMaxNomerge::get_n4block(int i_block) const {
  FKT "CompFamGraphNooverlap4PartNLinkMaxNomerge::get_n4block";

  if (!is_complete()) errstop(fkt, "Berechnung nicht vollendet.");
  return lst_n4block.get(i_block);
}


/* --- get_i_block_start4result --- */

// returns index of first result block

int CompFamGraphNooverlap4PartNLinkMaxNomerge::get_i_block_start4result() const {
  FKT "CompFamGraphNooverlap4PartNLinkMaxNomerge::get_i_block_start4result";

  if (!is_complete()) errstop(fkt, "Berechnung nicht vollendet.");

  return 0;
}


/* --- get_i_block_end4result --- */

int CompFamGraphNooverlap4PartNLinkMaxNomerge::get_i_block_end4result() const {
  FKT "CompFamGraphNooverlap4PartNLinkMaxNomerge::get_i_block_end4result";

  if (!is_complete()) errstop(fkt, "Berechnung nicht vollendet.");
  return lst_n4block.get_n();
}

/* --- setup_lst_comp_prepare --- */

bool CompFamGraphNooverlap4PartNLinkMaxNomerge::setup_lst_comp_prepare(Lst<PtComp> &lst) const {
  lst.clear();

  PtComp pt_comp;
  if (is_first()) {
    pt_comp = new CompRepFamGraph4Part(part, path_dir);
  } else {
    pt_comp = new CompFamGraphNooverlap4PartNLinkMaxPipe(part, n_link_max+1, n_max4block, size_buff_pipe, path_dir);
  }
  lst.append(pt_comp);
  return true;
}

/* --- get_filename4result --- */

Str CompFamGraphNooverlap4PartNLinkMaxNomerge::get_filename4result() const {
  return start_filename + embrace(part.to_str()) + c_nlinkmax + embrace(str4card(n_link_max)) + s_end_filename_nomerge_result;
}

/* --- get_filename4result --- */

Str CompFamGraphNooverlap4PartNLinkMaxNomerge::get_filename4work() const {
  return start_filename + embrace(part.to_str()) + c_nlinkmax + embrace(str4card(n_link_max)) + s_end_filename_nomerge_work;
}

/* --- read_evtl_filename4result --- */

bool CompFamGraphNooverlap4PartNLinkMaxNomerge::read_evtl_filename4result(const Str &filename, Part &part, int &n_link_max) {
  In4Str in(filename);
  int n_brick;

  if (!in.read_evtl_str_given(start_filename)) return false;
  if (!in.read_evtl_char_given('(')) return false;
  if (!read_evtl(in, part)) return false;
  if (!in.read_evtl_char_given(')')) return false;
  if (!in.read_evtl_str_given(c_nlinkmax)) return false;
  if (!in.read_evtl_char_given('(')) return false;
  if (!in.read_evtl_card(n_link_max)) return false;
  if (!in.read_evtl_char_given(')')) return false;
  n_brick = part.get_n_brick();
  if (!(0<=n_link_max && n_link_max<=n_brick*(n_brick-1)/2)) return false;
  if (!in.read_evtl_str_given(s_end_filename_nomerge_result)) return false;

  return in.at_end();
}

/* --- destructor --- */

CompFamGraphNooverlap4PartNLinkMaxNomerge::~CompFamGraphNooverlap4PartNLinkMaxNomerge() {}

/* --- constructor --- */

CompFamGraphNooverlap4PartNLinkMaxNomerge::CompFamGraphNooverlap4PartNLinkMaxNomerge(
  const Part &p_part,
  int p_n_link_max,
  int p_n_max4block,
  int p_size_buff_pipe,
  const Str &path_dir
) :
  CompGraphFac644LstFile(path_dir, p_part.get_n_brick()),
  size_buff_pipe(p_size_buff_pipe),
  n_link_max(p_n_link_max),
  part(p_part),
  n_max4block(p_n_max4block),
  n_splitted(Card64::zero)
{ FKT "CompFamGraphNooverlap4PartNLinkMaxNomerge::CompFamGraphNooverlap4PartNLinkMaxNomerge";
  if (!(0<=n_link_max && n_link_max<=n_brick*(n_brick-1)/2)) errstop(fkt, "p_n_link_max ausserhalb des gueltigen Bereichs");
}

/* --- get_i_block_start4result --- */

// returns index of first result block

int CompFamGraphNooverlap4PartNLinkMaxPipe::get_i_block_start4result() const {
  FKT "CompFamGraphNooverlap4PartNLinkMaxPipe::get_i_block_start4result";

  if (!is_complete()) errstop(fkt, "Berechnung nicht vollendet.");

  return i_block_start4result;
}

/* --- get_i_block_end4result --- */

// returns index of first result block

int CompFamGraphNooverlap4PartNLinkMaxPipe::get_i_block_end4result() const {
  FKT "CompFamGraphNooverlap4PartNLinkMaxPipe::get_i_block_end4result";

  if (!is_complete()) errstop(fkt, "Berechnung nicht vollendet.");

  return i_block_end4result;
}

/* --- is_first --- */

bool CompFamGraphNooverlap4PartNLinkMaxNomerge::is_first() const {
  return n_link_max>=n_brick*(n_brick-1)/2;
}

/* --- save_result --- */

bool CompFamGraphNooverlap4PartNLinkMaxNomerge::save_result(Out &out) const {

  int n = lst_n4block.get_n();
  if (!out.printf("nblock=$\n", n)) return false;

  // write number of data records for each block
  int i;
  for (i=0; i<n; ++i) {
    if (!out.printf("$\n", lst_n4block.get(i))) return false;
  }

  return true;
}

/* --- load_result --- */

bool CompFamGraphNooverlap4PartNLinkMaxNomerge::load_result(InBuffered &in) {
  // FKT "CompGraphNoProhibeLink4Part::load_result";

  // read number of blocks
  static const Str s_n_block_eq("nblock=");
  int n;
  if (!(in.read_str_given(s_n_block_eq) && in.read_card(n) && in.read_eoln())) {
    return false;
  }

  // Read number of data records for each block
  int i;
  for (i=0; i<n; ++i) {
    int n4block;
    if (!(in.read_card(n4block) && in.read_eoln())) return false;
    lst_n4block.append(n4block);
  }

  return true;
}

/* --- load_work --- */

bool CompFamGraphNooverlap4PartNLinkMaxNomerge::load_work(InBuffered &in) {
  FKT "CompFamGraphNooverlap4PartNLinkMaxNomerge::load_work";
  if (is_first()) errstop(fkt, "Unerwarteter Aufruf");

  // <lst_n4block>
  static const Str s_n_block_eq("nblock=");
  int n, i;
  lst_n4block.clear();
  if (!(in.read_str_given(s_n_block_eq) && in.read_card(n) && in.read_eoln())) return false;
  for (i=0; i<n; ++i) {
    int n4block;
    if (!(in.read_card(n4block) && in.read_eoln())) return false;
    lst_n4block.append(n4block);
  }

  // n_splitted
  static const Str s_n_splitted_eq("nsplitted=");
  if (!(in.read_str_given(s_n_splitted_eq) && read(in, n_splitted) && in.read_eoln())) return false;

  map_no_no_overlap.clear();
  return true;
}

/* --- run4notfirst --- */

bool CompFamGraphNooverlap4PartNLinkMaxNomerge::run4notfirst() {

  // Split into temporary files
  bool stopped=false;
  if (!split(stopped)) return false;
  if (stopped) {
    return true;
  }

  return set_complete();
}

/* --- get_filename4block --- */

Str CompFamGraphNooverlap4PartNLinkMaxNomerge::get_filename4block(int i_block) const {
  return start_filename + embrace(part.to_str()) + c_nlinkmax + embrace(str4card(n_link_max)) + c_block + embrace(str4card(i_block)) + s_end_filename_nomerge_result;
}

/* --- destructor --- */

CompFamGraphNooverlap4PartNLinkMaxPipe::~CompFamGraphNooverlap4PartNLinkMaxPipe() {}

/* --- get_n4block --- */

int CompFamGraphNooverlap4PartNLinkMaxPipe::get_n4block(int i_block) const {
  FKT "CompFamGraphNooverlap4PartNLinkMaxPipe::get_n4block";

  if (!is_complete()) errstop(fkt, "Berechnung nicht vollendet.");
  return lst_n4block.get(i_block);
}

/* --- dump_map2block --- */

bool CompFamGraphNooverlap4PartNLinkMaxNomerge::dump_map2block() {
  FKT "CompFamGraphNooverlap4PartNLinkMaxNomerge::dump2block";

  int n=map_no_no_overlap.get_n_no_zero();

  FamGraphFac64 *arr = new FamGraphFac64[n];
  if (arr==0) errstop_memoverflow(fkt);

  Storer<FamGraphFac64> storer(arr, n);
  if (!map_no_no_overlap.iterate_no_zero(storer)) return false;
  map_no_no_overlap.clear();

  qsort(arr, n, sizeof(*arr), &cmp_fam_graph644qsort);

  int i_block = lst_n4block.get_n();
  Str path = get_path4block(i_block);
  Out4File out_file;
  if (!out_file.open(path)) {
    delete[] arr;
    return false;
  }

  Checksummer4Out out(out_file);
  log("Save map to file \"$\"...", path);

  if (!Comp::write_fileclause(out, get_filename4block(i_block))) {
    out_file.close();
    return false;
  }

  if (!out.printf("n=$\n", n)) {
    out_file.close();
    return false;
  }

  int i;
  for (i=0; i<n; ++i) {
    if (!(arr[i].write_fast(out) && out.print_eoln())) {
      out_file.close();
      delete[] arr;
      return false;
    }
  }

  if (!out.write_chksum()) {
    out_file.close();
    delete[] arr;
    return false;
  }

  lst_n4block.append(n);

  if (!out_file.close()) return false;

  log("Saved map to file \"$\".", path);
  delete[] arr;

  return true;
}

/* --- split --- */

bool CompFamGraphNooverlap4PartNLinkMaxNomerge::split(bool &stopped) {

  stopped=false;

  // Load previous computation
  CompFamGraphNooverlap4PartNLinkMaxPipe comp_prev(part, n_link_max+1, n_max4block, size_buff_pipe, path_dir);
  if (!comp_prev.run()) return false;
  if (!comp_prev.is_complete()) {
    return err(Str("File ") + enquote(comp_prev.get_path4result()) + Str(" not computed"));
  }

  // Open input stream
  InFamGraphFac644LstFile in_prev;
  if (!comp_prev.open4result(in_prev, n_splitted)) return false;

  // Get number of blocks of previous computation
  bool ok=true;
  Str filename_prev = comp_prev.get_filename4result(), path_prev = comp_prev.get_path4result();
  log_progress_start("Split attachments of file \"$\"...", path_prev);
  while (!stopped && !in_prev.at_end()) {

    // Read data recoed
    const FamGraphCprFac64 &prev = *in_prev;

    // Umcompress
    FamGraph fam_graph_prev(n_brick);
    prev.fam_graph.get(fam_graph_prev);

    // Reduce number of no-links below the limit (if necessary), and put result to <map_no_no_overlap>
    int n_link4overlap = fam_graph_prev.get_n_link4overlap(NOOVERLAP_BRICK);
    if (n_link4overlap<=n_link_max) { // number of no-links is sufficiently low => forward it unchanged
      map_no_no_overlap.add(fam_graph_prev, prev.fac);
    } else { // number of no-links is not sufficiently low => split it

      if (n_link4overlap>n_link_max+1) {
        ok=in_prev.err_at("Zu viele Verbindungen, die sich nicht ueberlappen duerfen");
        break;
      }

      int i_brick=0, j_brick=0;
      fam_graph_prev.get4overlap(NOOVERLAP_BRICK, i_brick, j_brick);

      // Set link to MAYOVERLAP_BRICK and feed map
      FamGraph fam_graph(fam_graph_prev);
      FamGraph rep(n_brick);
      Str errtxt;
      int n_perm;
      fam_graph.set_overlap(i_brick, j_brick, MAYOVERLAP_BRICK);
      if (!get_fam_graph_rep_fast(fam_graph, rep, n_perm, errtxt)) {ok=in_prev.err_at(errtxt); break;}
      map_no_no_overlap.add(rep, prev.fac);

      // Set link to OVERLAP_BRICK and feed map
      Int64 fac;
      fam_graph.set_overlap(i_brick, j_brick, OVERLAP_BRICK);
      if (!get_fam_graph_rep_fast(fam_graph, rep, n_perm, errtxt)) {ok=in_prev.err_at(errtxt); break;}
      fac = -prev.fac;
      map_no_no_overlap.add(rep, fac);
    }

    // Dump map, if full
    if (map_no_no_overlap.get_n()>=n_max4block) {

      if (!dump_map2block()) {
        return false;
      }

      // Query whether stopped
      stopped = stopped || check_stopped();
    }

    if (!in_prev.next()) {ok=false; break;}
    ++n_splitted;
    log_progress("Processed $/$ data records ($).", in_prev.get_i(), in_prev.get_n());
  }

  if (!in_prev.close()) return false;
  if (!ok) return false;

  // if map not empty, dump it
  if (map_no_no_overlap.get_n()>0) {
    if (!dump_map2block()) {
      return false;
    }

    // Query whether stopped
    stopped = stopped || check_stopped();
  }

  if (stopped) return true;

  log_progress_end("Splitted attachments of file \"$\" into $ attachments.", path_prev, lst_n4block.get_n());

  return true;
}


/* --- init_work --- */

bool CompFamGraphNooverlap4PartNLinkMaxNomerge::init_work() {
  lst_n4block.clear();
  n_splitted=Card64::zero;
  map_no_no_overlap.clear();
  return true;
}

/* --- run4prepared_inited --- */

bool CompFamGraphNooverlap4PartNLinkMaxNomerge::run4prepared_inited() {

  if (is_first()) {
    if (!run4first()) return false;
  } else {
    if (!run4notfirst()) return false;
  }

  return true;
}

/* --- save_work --- */

bool CompFamGraphNooverlap4PartNLinkMaxNomerge::save_work(Out &out) const {
  FKT "CompFamGraphNooverlap4PartNLinkMaxNomerge::save_work";

  if (is_first()) errstop(fkt, "Unerwarteter Aufruf");

  // <lst_n_block>
  int n=lst_n4block.get_n(), i;
  if (!out.printf("nblock=$\n", n)) return false;
  for (i=0; i<n; ++i) {
    if (!out.printf("$\n", lst_n4block.get(i))) return false;
  }

  // n_splitted
  if (!out.printf("nsplitted=$\n", n_splitted)) return false;

  return true;
}


/* === CompFamGraphNooverlap4PartNLinkMaxPipe ============================ */

/* --- constructor --- */

CompFamGraphNooverlap4PartNLinkMaxPipe::CompFamGraphNooverlap4PartNLinkMaxPipe(
  const Part &p_part,
  int p_n_link_max,
  int p_n_max4block,
  int p_size_buff_pipe,
  const Str &path_dir
) :
  CompGraphFac644LstFile(path_dir, p_part.get_n_brick()),
  size_buff_pipe(p_size_buff_pipe),
  n_max4block   (p_n_max4block   ),
  n_link_max    (p_n_link_max    ),
  part          (p_part          ),
  pipe_result   (true            )
{}

/* --- dump_lst2block --- */

bool CompFamGraphNooverlap4PartNLinkMaxPipe::dump_lst2block(const Lst<FamGraphCprFac64> &lst) {
  int n=lst.get_n();

  int i_block = lst_n4block.get_n();
  Str path = get_path4block(i_block);
  Out4File out_file;
  if (!out_file.open(path)) {
    return false;
  }

  Checksummer4Out out(out_file);
  log("Save liwt to file \"$\"...", path);

  if (!Comp::write_fileclause(out, get_filename4block(i_block))) {
    out_file.close();
    return false;
  }

  if (!out.printf("n=$\n", n)) {
    out_file.close();
    return false;
  }

  int i;
  for (i=0; i<n; ++i) {
    if (!(lst.get(i).write_fast(out) && out.print_eoln())) {
      out_file.close();
      return false;
    }
  }

  if (!out.write_chksum()) {
    out_file.close();
    return false;
  }

  lst_n4block.append(n);

  if (!out_file.close()) return false;

  log("Saved list to file \"$\".", path);

  return true;
}

/* --- get_filename4block --- */

Str CompFamGraphNooverlap4PartNLinkMaxPipe::get_filename4block(int i_block) const {
  return CompFamGraphNooverlap4PartNLinkMax::get_filename4block_static(part, n_link_max, i_block, pipe_result);
}

/* --- setup_lst_comp_prepare --- */

bool CompFamGraphNooverlap4PartNLinkMaxPipe::setup_lst_comp_prepare(Lst<PtComp> &lst) const {
  lst.clear();

  PtComp pt_comp = new CompFamGraphNooverlap4PartNLinkMaxNomerge(part, n_link_max, n_max4block, size_buff_pipe, path_dir);
  lst.append(pt_comp);

  return true;
}


/* --- get_filename4result --- */

Str CompFamGraphNooverlap4PartNLinkMaxPipe::get_filename4result() const {
  return CompFamGraphNooverlap4PartNLinkMax::get_filename4result_static(part, n_link_max);
}

/* --- get_filename4work --- */

Str CompFamGraphNooverlap4PartNLinkMaxPipe::get_filename4work() const {
  return CompFamGraphNooverlap4PartNLinkMax::get_filename4work_static(part, n_link_max, true);
  // return CompFamGraphNooverlap4PartNLinkMax::start_filename + embrace(part.to_str()) + c_nlinkmax + embrace(str4card(n_link_max)) + s_end_filename_pipe_work;
}

/* --- run4prepared_inited --- */

bool CompFamGraphNooverlap4PartNLinkMaxPipe::run4prepared_inited() {
  lst_n4block.clear();

  // Run previous computation
  CompFamGraphNooverlap4PartNLinkMaxNomerge comp_prev(part, n_link_max, n_max4block, size_buff_pipe, path_dir);
  if (!comp_prev.run()) return false;
  if (!comp_prev.is_complete()) {
    return err(Str("File ") + enquote(comp_prev.get_path4result()) + Str(" not computed"));
  }

  // Anything to do ?
  if (comp_prev.get_i_block_start4result()==comp_prev.get_i_block_end4result()) {
    return set_complete();
  }

  // Create merging stream
  PtInstream4Pipe pt_instream = create_instream(comp_prev, comp_prev.get_i_block_start4result(), comp_prev.get_i_block_end4result());
  Instream4Pipe &instream = *pt_instream;
  if (!instream.open()) return false;

  // Put stream to output blocks
  Lst<FamGraphCprFac64> lst_out;
  Card64 n_item = instream.get_n(), n_done=Card64::zero;
  log_progress_start("Merge file \"$\"...", comp_prev.get_path4result());
  while (!instream.at_end()) {

    // Get, compress and add element
    const ItemPipe &in = *instream;
    FamGraphCprFac64 out;
    out.fam_graph = FamGraphCpr(in.fam_graph);
    out.fac = in.fac;
    lst_out.append(out);

    n_done += DWORD(in.n_occur);

    // Progress information
    log_progress("Processed $/$ data records to be merged ($).", n_done, n_item);

    // Dump list, if full
    if (lst_out.get_n()>=n_max4block) {
      if (!dump_lst2block(lst_out)) {
        instream.close();
        return false;
      }
      lst_out.clear();
    }

    if (!++instream) {instream.close(); return false;}
  }
  if (lst_out.get_n()>0) { // Dump rest, if not empty
    if (!dump_lst2block(lst_out)) {
      instream.close();
      return false;
    }
  }

  if (!instream.close()) return false;

  if (n_item!=n_done) return err("Anzahl der Graphen nicht wie angekuendigt");

  log_progress_end("File \"$\" merged.", comp_prev.get_path4result());
  return set_complete();
}

/* --- load_work --- */

bool CompFamGraphNooverlap4PartNLinkMaxPipe::load_work(InBuffered &in) {
  FKT "CompFamGraphNooverlap4PartNLinkMaxPipe::load_work";
  errstop(fkt, "Unerwarteter Aufruf");
  return false;
}

/* --- save_work --- */

bool CompFamGraphNooverlap4PartNLinkMaxPipe::save_work(Out&) const {
  FKT "CompFamGraphNooverlap4PartNLinkMaxPipe::save_work";
  errstop(fkt, "Unerwarteter Aufruf");
  return false;
}

/* --- load_result --- */

bool CompFamGraphNooverlap4PartNLinkMaxPipe::load_result(InBuffered &in) {

  if (!CompFamGraphNooverlap4PartNLinkMax::load_result_static(in, pipe_result, i_block_start4result, i_block_end4result, lst_n4block)) return false;

  return true;
}


/* --- save_result --- */

bool CompFamGraphNooverlap4PartNLinkMaxPipe::save_result(Out &out) const {

  if (!out.printf("pipe\n")) return false;

  int n = lst_n4block.get_n();
  if (!out.printf("iblockstart=0\n"   )) return false;
  if (!out.printf("iblockend=$\n"  , n)) return false;

  // write number of data records for each block
  int i;
  for (i=0; i<n; ++i) {
    if (!out.printf("$\n", lst_n4block.get(i))) return false;
  }

  return true;
}

/* --- init_work --- */

bool CompFamGraphNooverlap4PartNLinkMaxPipe::init_work() {
  lst_n4block.clear();
  pipe_result=true;
  return true;
}

/* --- create_instream --- */

PtInstream4Pipe CompFamGraphNooverlap4PartNLinkMaxPipe::create_instream(const CompFamGraphNooverlap4PartNLinkMaxNomerge &comp_prev, int i_block_from, int i_block_to) {
  FKT "CompFamGraphNooverlap4PartNLinkMaxPipe::create_instream";
  if (i_block_to<=i_block_from) errstop(fkt, "i_block_to<=i_block_from");

  if (i_block_to==i_block_from+1) return new Instream4File(path_dir, comp_prev.get_filename4block(i_block_from), comp_prev.get_n4block(i_block_from), size_buff_pipe, n_brick);

  int i_block_mid=(i_block_from+i_block_to)>>1;
  return new InstreamMerge(
    create_instream(comp_prev, i_block_from, i_block_mid),
    create_instream(comp_prev, i_block_mid , i_block_to )
  );
}



////////////////////
// FILE mapimpl.h //
////////////////////

// Taken fron lego4


////////////////
// FILE rnd.h //
////////////////

#define MY_RND_H

class Rnd { 
  unsigned int m; // Maximum value
  unsigned int r; // Recent random number

  public:
  Rnd(unsigned int m);
  unsigned int get();
};



////////////////////
// FILE cnpos.cpp //
////////////////////

/* --- declare static functions --- */

static int cmp_info_size_with_size(const void*, const void*);


/* === Dimer4FunCached =================================================== */

/* --- construtor --- */

Dimer4FunCached::Dimer4FunCached(const double *arr_size, int n_size) {
  FKT "Dimer4FunCached::Dimer4FunCached";

  n_info_size=0;
  int i_size;
  for (i_size=0; i_size<n_size; ++i_size) {
    if (i_size==0 || arr_size[i_size]>arr_size[i_size-1]) {
      ++n_info_size;
    }
  }

  arr_info_size = new InfoSizeCache[n_info_size];
  if (arr_info_size==0) errstop_memoverflow(fkt);

  int i_info_size;
  i_size=0;
  for (i_info_size=0; i_info_size<n_info_size; ++i_info_size) {
    InfoSizeCache &info_size = arr_info_size[i_info_size];
    double size = arr_size[i_size];
    info_size.size=size;
    info_size.n_occur = 1;
    ++i_size;
    while (i_size<n_size && arr_size[i_size]==size) {
      ++i_size;
      ++info_size.n_occur;
    }
  }
}

/* --- destrutor --- */

Dimer4FunCached::~Dimer4FunCached() {
  delete[] arr_info_size;
}

/* --- perform --- */

bool Dimer4FunCached::perform(const PtFunArrPosPartial2DwordCached &pt_fun) {
  FunArrPosPartial2DwordCached &fun=*pt_fun;
  double size = fun.get_size_cache_own();

  int i_info_size = get_i_insert(arr_info_size, n_info_size, sizeof(InfoSizeCache), &size, &cmp_info_size_with_size);
  if (i_info_size>=n_info_size) { // Cache to large
    return true;
  }

  InfoSizeCache &info_size = arr_info_size[i_info_size];

  if (info_size.n_occur>0) {
    --info_size.n_occur;
    fun.dim_cache();
  }

  return true;
}


/* === AppenderSize ====================================================== */

/* --- constructor --- */

AppenderSize::AppenderSize(Lst<double> &p_lst) : lst(p_lst) {}

/* --- perform --- */

bool AppenderSize::perform(const PtFunArrPosPartial2DwordCached &pt_fun) {
  double size=pt_fun->get_size_cache_own();
  lst.append(size);
  return true;
}


/* === CompNPos4Part ===================================================== */

/* --- static members --- */

const Str CompNPos4Part::start_filename("npos4part(");

/* --- get_i_todo --- */

int CompNPos4Part::get_i_todo(Rnd &rnd) const {
  FKT "CompNPos4Part::get_i_todo";
  int i_start = rnd.get();
  int i_todo=i_start;
  while (arr_done[i_todo]) {
    ++i_todo;
    if (i_todo==n_todo) i_todo=0;
    if (i_todo==i_start) errstop(fkt, "i_todo==i_start");
  }
  return i_todo;
}

/* --- read_evtl_filename4result --- */

bool CompNPos4Part::read_evtl_filename4result(const Str &filename, Part &part) {
  In4Str in(filename);

  if (!in.read_evtl_str_given(start_filename)) return false;
  if (!read_evtl(in, part)) return false;
  if (!in.read_evtl_str_given(c_end_filename_result)) return false;

  return in.at_end();
}

/* --- run4prepared_inited --- */

bool CompNPos4Part::run4prepared_inited() {
  Card64 n_pos;
  Str errtxt;
  Access2Db access2db(path_dir, n_brick);

  log("Open database...");
  if (!access2db.open()) return false;
  log("Opened database.");

  Rnd rnd(max_int(1,n_todo));
  int n_query=0, n_hit=0;
  log_progress_start("Compute numbers of null positioned brick tupel for each graph...");
  for (n_done=0; n_done<n_todo; ++n_done) {

    // Stopped ?
    if (n_done>0 && check_stopped()) {
      log("$ out of $ database queries were hits.", n_hit, n_query);

      // Save new graphs to database
      log("Save database...");
      if (!access2db.commit()) return false;
      log("Saved database.");

      return true;
    }

    // log progress
    int n_done_total = n_done+n_total-n_todo;
    log_progress("$/$ graphs considered ($).", n_done_total, n_total);

    // Get number of positions for the current graph
    int i_todo = get_i_todo(rnd);
    const GraphCprFac &todo = arr_todo[i_todo];
    Graph graph(n_brick);
    bool hit;
    todo.graph.get(graph);
    if (!get_n_pos(graph, n_pos, access2db, hit)) {
      access2db.rollback();
      return false;
    }

    // Update arr_done
    arr_done[i_todo] = true;

    // Accumulate
    sum += mul(todo.fac, n_pos);
    n_hit+=(int)hit;
    ++n_query;
  }

  // Save new graphs to database
  log("Save database...");
  if (!access2db.commit()) return false;
  log("Saved database.");

  // Done
  log_progress_end("Accomplished computation of the number of null-positioned brick tupels for each graph.");
  log("$ out of $ database queries were hits.", n_hit, n_query);
  return set_complete();
}

/* --- constructor --- */

CompNPos4Part::CompNPos4Part(
  const Part &p_part,
  const Str &path_dir,
  int p_size_cache_max,
  int p_n_max4map,
  bool p_pipe,
  int p_size_buff_pipe
) :
  Comp(path_dir),
  arr_todo(0), arr_done(0),
  part(p_part),
  n_brick(p_part.get_n_brick()),
  size_cache_max(p_size_cache_max),
  n_max4map(p_n_max4map),
  size_buff_pipe(p_size_buff_pipe),
  pipe(p_pipe)
{}

/* --- init_work --- */

bool CompNPos4Part::init_work() {
  FKT "CompNPos4Part::init_work";

  CompGraphNoProhibeLink4Part comp_pred(part, n_max4map, path_dir, pipe, size_buff_pipe);
  if (!comp_pred.run()) return false;
  if (!comp_pred.is_complete()) {
    return err(Str("File ") + enquote(comp_pred.get_filename4result()) + Str(" not computed"));
  }

  n_total = n_todo = comp_pred.get_n();
  arr_todo = new GraphCprFac[n_todo];
  if (arr_todo==0) errstop_memoverflow(fkt);
  comp_pred.get_all(arr_todo,n_todo);

  arr_done = new bool[n_todo];
  if (arr_done==0) errstop_memoverflow(fkt);
  set(arr_done, n_todo, false);

  sum=Int128::zero;

  return true;
}

/* --- get_sum --- */

const Card64 CompNPos4Part::get_sum() const {
  FKT "CompNPos4Part::get_sum";
  if (!is_complete()) errstop(fkt, "Berechnung nicht durchgefuehrt");

  Card64 res;
  if (!sum.is_card64(res)) errstop(fkt, "Ergebnis ist kein Card64");
  return res;
}

/* --- destructor --- */

CompNPos4Part::~CompNPos4Part() {
  if (arr_todo!=0) delete[] arr_todo;
  if (arr_done!=0) delete[] arr_done;
}

/* --- get_filename4result --- */

Str CompNPos4Part::get_filename4result() const {
  return start_filename+part.to_str()+c_end_filename_result;
}

/* --- get_filename4work --- */

Str CompNPos4Part::get_filename4work() const {
  return start_filename+part.to_str()+c_end_filename_work;
}

/* --- setup_lst_comp_prepare --- */

bool CompNPos4Part::setup_lst_comp_prepare(Lst<PtComp> &lst) const {
  lst.clear();

  PtComp pt_comp = new CompGraphNoProhibeLink4Part(part, n_max4map, path_dir, pipe, size_buff_pipe);
  lst.append(pt_comp);
  return true;
}

/* --- save_work --- */

bool CompNPos4Part::save_work(Out &out) const {
  if (!out.printf("ntodo=$\n", n_todo-n_done)) return false;
  if (!out.printf("ntotal=$\n", n_total)) return false;

  int i_todo;
  for (i_todo=0; i_todo<n_todo; ++i_todo) if (!arr_done[i_todo]) {
    GraphFac graph_fac(n_brick);

    graph_fac.fac = arr_todo[i_todo].fac;
    arr_todo[i_todo].graph.get(graph_fac.graph);
    if (!graph_fac.write(out)) return false;
    if (!out.print_char('\n')) return false;
  }

  return save_result(out);
}

/* --- load_work --- */

bool CompNPos4Part::load_work(InBuffered &in) {
  FKT "CompNPos4Part::load_work";

  static const Str n_todo_eq("ntodo="), n_total_eq("ntotal=");
  if (!in.read_str_given (n_todo_eq)) return false;
  if (!in.read_card(n_todo)) return false;
  if (!in.read_eoln()) return false;
  if (!in.read_str_given (n_total_eq)) return false;
  if (!in.read_card(n_total)) return false;
  if (!in.read_eoln()) return false;

  arr_todo = new GraphCprFac[n_todo];
  if (arr_todo==0) errstop_memoverflow(fkt);
  arr_done = new bool[n_todo];
  if (arr_done==0) errstop_memoverflow(fkt);
  set(arr_done, n_todo, false);

  int i_todo;
  // int n_changed=0;
  log("Load graphs...");
  for (i_todo=0; i_todo<n_todo; ++i_todo) {

    GraphFac graph_fac(n_brick);
    if (!read(in, n_brick, graph_fac)) return false;
    if (!in.read_eoln()) return false;

    // Graph rep(n_brick);
    // Str errtxt;
    // if (!get_graph_rep(graph_fac.graph, rep, errtxt)) return err(errtxt);

    GraphCpr /* cpr_rep(rep),*/ cpr(graph_fac.graph);
    arr_todo[i_todo].graph = cpr; // cpr_rep;
    arr_todo[i_todo].fac = graph_fac.fac;
    // if (cpr_rep!=cpr) {
    //   ++n_changed;
    // }
  }

  static const Str n_sum_eq("sum=");
  if (!in.read_str_given (n_sum_eq)) return false;
  if (!read(in, sum)) return false;
  if (!in.read_eoln()) return false;

  log("$ graphs loaaded.", n_todo);

  return true;
}

/* --- load_result --- */

bool CompNPos4Part::load_result(InBuffered &in) {
  static const Str c_n_sum("sum");

  if (!in.read_str_given (c_n_sum)) return false;
  if (!in.read_char_given('=')) return false;
  if (!read(in, sum)) return false;
  if (!in.read_eoln()) return false;

  return true;
}

/* --- save_result --- */

bool CompNPos4Part::save_result(Out &out) const {
  char buff[N_DIGIT4INT128+1];

  if (!out.printf("sum=$\n", to_nts(sum, buff, sizeof(buff)))) return false;
  return true;
}


/* === exported functions ================================================ */

/* --- get_n_pos4graph --- */

bool get_n_pos4graph(const Graph &graph, Card64 &n_pos, int size_cache_max) {
  FKT "get_n_pos4graph";
  // Setup calculations
  int n_var = graph.n_brick;
  MapFunCached map_fun_cached(n_var);
  bool arr_rotated[N_BRICK_MAX];
  PtFunArrPosPartial2Dword arr_fun_cached_x[1<<(N_BRICK_MAX-1)], arr_fun_cached_y[1<<(N_BRICK_MAX-1)];
  int n_fun_cached=0;
  set(arr_rotated, n_var, false);
  while (true) {

    arr_fun_cached_x[n_fun_cached] = create_fun_n_sol4graph(0, graph, arr_rotated, 'x', map_fun_cached);
    arr_fun_cached_y[n_fun_cached] = create_fun_n_sol4graph(0, graph, arr_rotated, 'y', map_fun_cached);
    ++n_fun_cached;
    // printf("n_fun_cached=%d\n", n_fun_cached);

    if (L_BRICK==W_BRICK) break;

    if (is(arr_rotated, n_var-1, true)) break;
    adv(arr_rotated, n_var-1);
  }

  // Compute all cache sizes
  Lst<double> lst_size;
  AppenderSize appender(lst_size);
  if (!map_fun_cached.iterate_data(appender)) return false;

  // Sort all cache sizes
  int n_size = lst_size.get_n(), i_size;
  double *arr_size = new double[n_size];
  if (arr_size==0) errstop_memoverflow(fkt);
  for (i_size=0; i_size<n_size; ++i_size) arr_size[i_size] = lst_size.get(i_size);
  qsort(arr_size, n_size, sizeof(double), &cmp_dbl4qsort);

  // Compute the cache sizes to be alloced
  double sum_size_cache_alloc=0.0, size_cache_max_dbl=(double)size_cache_max;
  int n_size_alloc=0;
  while (n_size_alloc<n_size && sum_size_cache_alloc+arr_size[n_size_alloc]<=size_cache_max_dbl) {
    ++n_size_alloc;
    sum_size_cache_alloc+=arr_size[n_size_alloc];
  }

  // Alloc the caches
  Dimer4FunCached dimer(arr_size, n_size_alloc);
  if (!map_fun_cached.iterate_data(dimer)) {
    delete[] arr_size;
    return false;
  }

  // Run the computation
  int i_fun_cached;
  n_pos=Card64::zero;
  for (i_fun_cached=0; i_fun_cached<n_fun_cached; ++i_fun_cached) {

    DWORD nx_dw, ny_dw;
    int arr_koor[N_VAR_MAX];
    arr_koor[0]=0; nx_dw=arr_fun_cached_x[i_fun_cached]->eval(arr_koor);
    arr_koor[0]=0; ny_dw=arr_fun_cached_y[i_fun_cached]->eval(arr_koor);
    // printf("i_fun_cached=%d, nx=%u, ny=%u\n", i_fun_cached, nx_dw, ny_dw);

    Card64 inc = mul(nx_dw, ny_dw);
    n_pos += inc;
    if (L_BRICK!=W_BRICK) {
      n_pos += inc;
    }
  }
  delete[] arr_size;

  return true;
}

/* --- cmp_info_size4qsort --- */

static int cmp_info_size_with_size(const void *ptr_info_size, const void *ptr_size) {
  InfoSizeCache &info_size = *(InfoSizeCache*)ptr_info_size;
  double &size = *(double*)ptr_size;
  return cmp_dbl(info_size.size, size);
}



//////////////////
// FILE csym2.h //
//////////////////

#define MY_CSYM2_H



////////////////
// FILE fig.h //
////////////////

#define MY_FIG_H


////////////////
// FILE set.h //
////////////////

// From c:\kombin\lego2\footprnt


////////////////
// FILE str.h //
////////////////

// From c:\consql



////////////////
// FILE fig.h //
////////////////

class InBuffered;
class Out;
class FigRotCpr;

/* --- Pos4Fig --- */

struct Pos4Fig {
  int x,y,z;
  bool rotated;

  Pos4Fig() {}
  Pos4Fig(DWORD cpr);
  unsigned int hashind() const;
  bool write(Out&) const;
  void rot90();
  DWORD get_cpr() const;

  friend bool operator!=(const Pos4Fig&, const Pos4Fig&);
  friend int cmp(const Pos4Fig&, const Pos4Fig&);

};

/* --- FigRot --- */

class FigRot {
  Pos4Fig arr_pos_brick[N_BRICK_MAX];

  public:
  const int n_brick;
  FigRot();
  FigRot(Pos4Fig *arr_pos_brick, bool half, int n_brick);
  FigRot(const FigRotCpr&, int n_brick);
  void operator=(const FigRot&);
  unsigned int hashind() const;
  bool write(Out&) const;
  void clear();
  const Pos4Fig& get_pos_brick(int) const;
  void rot90();

  friend bool operator==(const FigRot&, const FigRot&);
  friend class FigRotCpr;
};

/* --- FigRotCpr --- */

class FigRotCpr {
  DWORD arr_pos_brick_cpr[N_BRICK_MAX];

  public:
  FigRotCpr() {}
  FigRotCpr(const FigRot&);

  friend class FigRot;
  friend class SetFigRotCpr;
};

/* --- SetFigRotCpr --- */

class SetFigRotCpr : public Set<FigRotCpr> {
  const int n_brick;

  public:
  SetFigRotCpr(int n_brick);
  bool equal(const FigRotCpr&, const FigRotCpr&) const;
  unsigned int hashind(const FigRotCpr&) const;
  void insert(const FigRot&);
  bool iterate(Performer<FigRot>&) const;

  // friend class SetFigRot;
  friend class FigRotCpr;
};

/* --- DecompressorFigRot --- */

class DecompressorFigRot : public Performer<FigRotCpr> {
  Performer<FigRot> &target;
  const int n_brick;

  public:
  DecompressorFigRot(Performer<FigRot> &target, int n_brick);
  bool perform(const FigRotCpr&);
};

/* --- WriterFig --- */

class WriterFig : public Performer<FigRot> {
  Out &out;

  public:
  WriterFig(Out&);
  bool perform(const FigRot&);
};


/* --- exported functions --- */

bool read(InBuffered&, int n_brick, FigRot &);
bool read(InBuffered&, Pos4Fig&);



//////////////////
// FILE csym2.h //
//////////////////

/* --- AlignEvenOdd --- */

struct AlignOdd {
  bool x, y;

};

/* --- CompFigRotSym24Part --- */

class CompFigRotSym24Part : public Comp {
  const Part part;
  SetFamGraph4Part *pt_set_done;
  CompFamGraph4Part *pt_comp_fam_graph;
  PtComp pt_comp_fam_graph_keeper;

  SetFigRotCpr set_found;

  private:
  bool load_result(int &pos, const Str &content, const Str &filename);
  void add_fig(const FamGraph&);
  CompFamGraph4Part& get_ref_comp_fam_graph() const;

  // Implementation of <Comp>
  protected:
  bool init_work();
  bool run4prepared_inited();
  bool load_work  (InBuffered&);
  bool load_result(InBuffered&);
  bool save_work  (Out&) const;
  bool save_result(Out&) const;
  bool setup_lst_comp_prepare(Lst<Pt<Comp> > &lst) const;
  public:
  Str get_filename4result() const;
  Str get_filename4work() const;

  public:
  CompFigRotSym24Part(const Part&, const Str &path_dir);
  ~CompFigRotSym24Part();
  int get_n_found() const;
  bool iterate(Performer<FigRot>&) const;

  public:
  static bool read_evtl_filename4result(const Str &filename, Part&);
  static const Str start_filename;
};

/* --- AdderFigRotSym4FunMirror  --- */

class AdderFigRotSym4FunMirror : public Performer<Perm> {
  const Part &part;
  SetFigRotCpr &target;
  const FamGraph &fam_graph;
  const int n_brick;
  int arr_i_layer4brick[N_BRICK_MAX];

  private:
  bool add_rek(int (*mat_dist)[N_BRICK_MAX], const Perm &fun_mirror, bool *arr_set, Pos4Fig *arr_pos_center_dbl, const AlignOdd &align_odd_stud);
  bool check_pos_new(int i_brick, int (*mat_dist)[N_BRICK_MAX], const bool *arr_set, const Pos4Fig *arr_pos_center_dbl, const AlignOdd &align_odd_stud) const;

  public:
  AdderFigRotSym4FunMirror(const Part&, const FamGraph&, SetFigRotCpr &target);
  bool perform(const Perm&);
};



//////////////////
// FILE csym4.h //
//////////////////

#define MY_CSYM4_H




/* --- CompFigRotSym44Part --- */

class CompFigRotSym44Part : public Comp {
  const Part part;
  CompFigRotSym24Part *pt_comp_sym2;
  PtComp pt_comp_sym2_keeper;
  SetFigRotCpr set_found;

  private:
  CompFigRotSym24Part& get_ref_comp_sym2() const;

  // Implementation of <Comp>
  protected:
  bool init_work();
  bool run4prepared_inited();
  bool load_work  (InBuffered&);
  bool load_result(InBuffered&);
  bool save_work  (Out&) const;
  bool save_result(Out&) const;
  bool setup_lst_comp_prepare(Lst<Pt<Comp> > &lst) const;
  public:
  Str get_filename4result() const;
  Str get_filename4work() const;

  public:
  CompFigRotSym44Part(const Part&, const Str &path_dir);
  ~CompFigRotSym44Part();
  int get_n_found() const;

  public:
  static bool read_evtl_filename4result(const Str &filename, Part&);
  static const Str start_filename;
};

/* --- Adder4Sym4 --- */

class Adder4Sym4 : public Performer<FigRot> {
  const int n;
  SetFigRotCpr &target;
  int n_done;

  public:
  Adder4Sym4(int n, SetFigRotCpr &target);
  bool perform(const FigRot&);
};

/* --- test functions --- */

void testsym4();




///////////////////////
// FILE cnrotfig.cpp //
///////////////////////

/* === CompNFigRot4NBrick ================================================ */

/* --- static members --- */

const Str CompNFigRot4NBrick::start_filename("nrotfig4nbrick(");

/* --- get_res --- */

const Card64& CompNFigRot4NBrick::get_res() const {
  FKT "CompNFigRot4NBrick::get_res";

  if (!is_complete()) errstop(fkt, "Berechnung nicht durchgefuehrt");

  return res;
}

/* --- setup_lst_comp_prepare --- */

bool CompNFigRot4NBrick::setup_lst_comp_prepare(Lst<PtComp> &lst) const {
  Lst<Part> lst_part;
  Appender<Part> appender(lst_part);

  if (!Part::iterate(n_brick, appender)) return false;

  int n=lst_part.get_n(), i;
  lst.clear();
  for (i=0; i<n; ++i) {
    Part part = lst_part.get(i);
    Part part_reverse(part);
    part_reverse.revert();
    if (part>part_reverse) continue;

    PtComp pt = new CompNPos4Part(part, path_dir, size_cache_max, n_max4map, pipe, size_buff_pipe);
    lst.append(pt);
  }

  return true;
}

/* --- load_result --- */

bool CompNFigRot4NBrick::load_result(InBuffered &in) {
  static const Str s_nrotfig("nrotfig=");

  if (!in.read_str_given(s_nrotfig)) return false;
  if (!read(in, res)) return false;
  if (!in.read_eoln()) return false;

  return true;
}

/* --- save_result --- */

bool CompNFigRot4NBrick::save_result(Out &out) const {
  char buff[N_DIGIT4CARD64+1];

  if (!out.printf("nrotfig=$\n", to_nts(res, buff, sizeof(buff)))) return false;
  return true;
}

/* --- get_filename4work --- */

Str CompNFigRot4NBrick::get_filename4work() const {
  return start_filename+str4card(n_brick)+c_end_filename_work;
}

/* --- get_filename4result --- */

Str CompNFigRot4NBrick::get_filename4result() const {
  return start_filename+str4card(n_brick)+c_end_filename_result;
}

/* --- load_work --- */

bool CompNFigRot4NBrick::load_work(InBuffered&) {
  return true;
}

/* --- save_work --- */

bool CompNFigRot4NBrick::save_work(Out&) const {
  return true;
}

/* --- read_evtl_filename4result --- */

bool CompNFigRot4NBrick::read_evtl_filename4result(const Str &filename, int &n_brick) {
  In4Str in(filename);

  if (!in.read_evtl_str_given(start_filename)) return false;
  if (!in.read_evtl_card(n_brick)) return false;
  if (!in.read_evtl_str_given(c_end_filename_result)) return false;

  return in.at_end();
}

/* --- constructor --- */

CompNFigRot4NBrick::CompNFigRot4NBrick(
  int p_n_brick,
  const Str &path_dir,
  int p_size_cache_max,
  int p_n_max4map,
  bool p_pipe,
  int p_size_buff_pipe
) :
  Comp(path_dir),
  n_brick(p_n_brick),
  size_cache_max(p_size_cache_max),
  n_max4map(p_n_max4map),
  size_buff_pipe(p_size_buff_pipe),
  pipe(p_pipe)
{}

/* --- init_work --- */

bool CompNFigRot4NBrick::init_work() {
  return true;
}

/* --- run4prepared_inited --- */

bool CompNFigRot4NBrick::run4prepared_inited() {
  res=Card64::zero;
  AdderNPos4Part adder(res, path_dir, size_cache_max, n_max4map, pipe, size_buff_pipe);
  if (!Part::iterate(n_brick, adder)) return false;
  return set_complete();
}


/* === CompNFigRotSym44NBrick ============================================ */

/* --- static members --- */

const Str CompNFigRotSym44NBrick::start_filename("nsym4rotfig4nbrick(");

/* --- get_res --- */

const Card64& CompNFigRotSym44NBrick::get_res() const {
  FKT "CompNFigRotSym44NBrick::get_res";

  if (!is_complete()) errstop(fkt, "Berechnung nicht durchgefuehrt");

  return res;
}

/* --- read_evtl_filename4result --- */

bool CompNFigRotSym44NBrick::read_evtl_filename4result(const Str &filename, int &n_brick) {
  In4Str in(filename);

  if (!in.read_evtl_str_given(start_filename)) return false;
  if (!in.read_evtl_card(n_brick)) return false;
  if (!in.read_evtl_str_given(c_end_filename_result)) return false;

  return in.at_end();
}

/* --- load_result --- */

bool CompNFigRotSym44NBrick::load_result(InBuffered &in) {
  static const Str s_nrotfig("nrotfig=");

  if (!in.read_str_given(s_nrotfig)) return false;
  if (!read(in, res)) return false;
  if (!in.read_eoln()) return false;

  return true;
}

/* --- constructor --- */

CompNFigRotSym44NBrick::CompNFigRotSym44NBrick(int p_n_brick, const Str &path_dir) : Comp(path_dir), n_brick(p_n_brick) {}

/* --- init_work --- */

bool CompNFigRotSym44NBrick::init_work() {
  return true;
}

/* --- run4prepared_inited --- */

bool CompNFigRotSym44NBrick::run4prepared_inited() {
  res=Card64::zero;
  AdderFigRotSym44Part adder(res, path_dir);
  if (!Part::iterate(n_brick, adder)) return false;
  return set_complete();
}

/* --- load_work --- */

bool CompNFigRotSym44NBrick::load_work(InBuffered&) {
  return true;
}

/* --- save_work --- */

bool CompNFigRotSym44NBrick::save_work(Out&) const {
  return true;
}

/* --- save_result --- */

bool CompNFigRotSym44NBrick::save_result(Out &out) const {
  char buff[N_DIGIT4CARD64+1];

  if (!out.printf("nrotfig=$\n", to_nts(res, buff, sizeof(buff)))) return false;
  return true;
}

/* --- setup_lst_comp_prepare --- */

bool CompNFigRotSym44NBrick::setup_lst_comp_prepare(Lst<PtComp> &lst) const {
  Lst<Part> lst_part;
  Appender<Part> appender(lst_part);

  if (!Part::iterate(n_brick, appender)) return false;

  int n=lst_part.get_n(), i;
  lst.clear();
  for (i=0; i<n; ++i) {
    Part part = lst_part.get(i);
    Part part_reverse(part), part_comp;
    part_reverse.revert();
    if (part_reverse<part) {
      part_comp=part_reverse;
    } else {
      part_comp=part;
    }
    PtComp pt = new CompFigRotSym44Part(part_comp, path_dir);
    lst.append(pt);
  }

  return true;
}

/* --- get_filename4work --- */

Str CompNFigRotSym44NBrick::get_filename4work() const {
  return start_filename+str4card(n_brick)+c_end_filename_work;
}

/* --- get_filename4result --- */

Str CompNFigRotSym44NBrick::get_filename4result() const {
  return start_filename+str4card(n_brick)+c_end_filename_result;
}


/* === CompNFigRotSym24NBrick ============================================ */

/* --- static members --- */

const Str CompNFigRotSym24NBrick::start_filename("nsym2rotfig4nbrick(");

/* --- get_res --- */

const Card64& CompNFigRotSym24NBrick::get_res() const {
  FKT "CompNFigRotSym24NBrick::get_res";

  if (!is_complete()) errstop(fkt, "Berechnung nicht durchgefuehrt");

  return res;
}

/* --- constructor --- */

CompNFigRotSym24NBrick::CompNFigRotSym24NBrick(int p_n_brick, const Str &path_dir) : Comp(path_dir), n_brick(p_n_brick) {}

/* --- read_evtl_filename4result --- */

bool CompNFigRotSym24NBrick::read_evtl_filename4result(const Str &filename, int &n_brick) {
  In4Str in(filename);

  if (!in.read_evtl_str_given(start_filename)) return false;
  if (!in.read_evtl_card(n_brick)) return false;
  if (!in.read_evtl_str_given(c_end_filename_result)) return false;

  return in.at_end();
}

/* --- save_work --- */

bool CompNFigRotSym24NBrick::save_work(Out&) const {
  return true;
}

/* --- setup_lst_comp_prepare --- */

bool CompNFigRotSym24NBrick::setup_lst_comp_prepare(Lst<PtComp> &lst) const {
  Lst<Part> lst_part;
  Appender<Part> appender(lst_part);

  if (!Part::iterate(n_brick, appender)) return false;

  int n=lst_part.get_n(), i;
  lst.clear();
  for (i=0; i<n; ++i) {
    Part part = lst_part.get(i);
    Part part_reverse(part), part_comp;
    part_reverse.revert();
    if (part_reverse<part) {
      part_comp=part_reverse;
    } else {
      part_comp=part;
    }
    PtComp pt = new CompFigRotSym24Part(part_comp, path_dir);
    lst.append(pt);
  }

  return true;
}

/* --- save_result --- */

bool CompNFigRotSym24NBrick::save_result(Out &out) const {
  char buff[N_DIGIT4CARD64+1];

  if (!out.printf("nrotfig=$\n", to_nts(res, buff, sizeof(buff)))) return false;
  return true;
}

/* --- load_result --- */

bool CompNFigRotSym24NBrick::load_result(InBuffered &in) {
  static const Str s_nrotfig("nrotfig=");

  if (!in.read_str_given(s_nrotfig)) return false;
  if (!read(in, res)) return false;
  if (!in.read_eoln()) return false;

  return true;
}

/* --- get_filename4work --- */

Str CompNFigRotSym24NBrick::get_filename4work() const {
  return start_filename+str4card(n_brick)+c_end_filename_work;
}

/* --- get_filename4result --- */

Str CompNFigRotSym24NBrick::get_filename4result() const {
  return start_filename+str4card(n_brick)+c_end_filename_result;
}

/* --- init_work --- */

bool CompNFigRotSym24NBrick::init_work() {
  return true;
}

/* --- run4prepared_inited --- */

bool CompNFigRotSym24NBrick::run4prepared_inited() {
  res=Card64::zero;
  AdderFigRotSym24Part adder(res, path_dir);
  if (!Part::iterate(n_brick, adder)) return false;
  return set_complete();
}

/* --- load_work --- */

bool CompNFigRotSym24NBrick::load_work(InBuffered&) {
  return true;
}


/* === AdderFigRotSym24Part ================================================== */

/* --- constructor --- */

AdderFigRotSym24Part::AdderFigRotSym24Part(Card64 &p_sum, const Str &p_path_dir) : sum(p_sum), path_dir(p_path_dir) {}

/* --- perform --- */

bool AdderFigRotSym24Part::perform(const Part &part) {
  Part part_reverse(part), part_comp;

  part_reverse.revert();
  if (part>part_reverse) {
    part_comp=part_reverse;
  } else {
    part_comp=part;
  }

  CompFigRotSym24Part comp(part_comp, path_dir);
  if (!comp.run()) return false;
  if (!comp.is_complete()) return err(Str("File \"") + comp.get_filename4result() + Str("\" not computed"));

  sum+=Card64((DWORD)comp.get_n_found());

  return true;
}


/* === AdderFigRotSym44Part ================================================== */

/* --- constructor --- */

AdderFigRotSym44Part::AdderFigRotSym44Part(Card64 &p_sum, const Str &p_path_dir) : sum(p_sum), path_dir(p_path_dir) {}

/* --- perform --- */

bool AdderFigRotSym44Part::perform(const Part &part) {

  Part part_reverse(part), part_comp;
  part_reverse.revert();
  if (part_reverse<part) {
    part_comp=part_reverse;
  } else {
    part_comp=part;
  }

  CompFigRotSym44Part comp(part_comp, path_dir);
  if (!comp.run()) return false;
  if (!comp.is_complete()) return err(Str("File \"") + comp.get_filename4result() + Str("\" not computed"));

  sum+=Card64((DWORD)comp.get_n_found());

  return true;
}


/* === AdderNPos4Part ==================================================== */

/* --- constructor --- */

AdderNPos4Part::AdderNPos4Part(
  Card64 &p_sum,
  const Str &p_path_dir,
  int p_size_cache_max,
  int p_n_max4map,
  bool p_pipe,
  int p_size_buff_pipe
) :
  sum(p_sum),
  path_dir(p_path_dir),
  size_cache_max(p_size_cache_max),
  n_max4map(p_n_max4map),
  size_buff_pipe(p_size_buff_pipe),
  pipe(p_pipe)
{}

/* --- perform --- */

bool AdderNPos4Part::perform(const Part &part) {
  FKT "AdderNPos4Part::perform";

  Part part_reverse(part), part_comp;
  part_reverse.revert();
  if (part_reverse<part) {
    part_comp=part_reverse;
  } else {
    part_comp=part;
  }

  CompNPos4Part comp(part_comp, path_dir, size_cache_max, n_max4map, pipe, size_buff_pipe);
  if (!comp.run()) return false;
  if (!comp.is_complete()) errstop(fkt, "Berechnung nicht durchgefuehrt");

  const Card64 &x = comp.get_sum();
  // int sign = x.get_sign();
  // if (sign==0) return true;

  Card64 fak_part((DWORD) part.get_n_perm()), rem, quot;
  divmod(x, fak_part, quot, rem);
  if (!rem.is_zero()) return err("Division durch part! geht nicht ohne Rest auf");

  sum+=quot;

  return true;
}



////////////////
// FILE str.h //
////////////////

// From c:\consql




///////////////////
// FILE comp.cpp //
///////////////////

/* === Comp ============================================================== */


/* --- read_fileclause --- */

bool Comp::read_fileclause(InBuffered &in, Str filename) {
  static Str s_file_eq("file=");

  if (!in.read_str_given(s_file_eq)) return false;
  if (!in.read_str_given(filename)) return false;
  if (!in.read_eoln()) return false;

  return true;
}

/* --- write_fileclause --- */

bool Comp::write_fileclause(Out &out, Str filename) {
  return out.printf("file=$\n", filename);
}

/* --- destructor --- */

Comp::~Comp() {}

/* --- set_complete --- */

bool Comp::set_complete() {
  complete=true;
  return true;
}

/* --- check_stopped --- */

bool Comp::check_stopped() {
  if (n_step_max>=0) --n_step_max;
  if (!signalled_stop && n_step_max!=0) return false;
  log("The computation of the file \"$\" will be interrupted.", get_filename4result());
  return true;
}

/* --- constructor --- */

Comp::Comp(const Str &p_path_dir) : complete(false), prepared(false), inited(false), path_dir(p_path_dir) {}

/* --- prepare --- */

bool Comp::is_result_computed() const {
  return exists_file(get_path4result());
}

/* --- prepare --- */

bool Comp::prepare(bool &stopped) {
  Str path_result = get_path4result();

  log("Make sure that all files required for the computation of the file \"$\" are present...", path_result);
  Lst<PtComp> lst_ptr_comp;
  if (!setup_lst_comp_prepare(lst_ptr_comp)) return false;

  int n_comp = lst_ptr_comp.get_n();
  stopped=false;
  if (n_comp==0) return true;

  // Copy required computations into an array
  // This is done to better delete the computation after it is done.
  PtComp *arr_pt_comp = new PtComp[n_comp];
  int i_comp;
  for (i_comp=0; i_comp<n_comp; ++i_comp) {
    arr_pt_comp[i_comp] = lst_ptr_comp.get(i_comp);
  }
  lst_ptr_comp.clear();

  // Perform computations
  bool ok=true;
  for (i_comp=0; i_comp<n_comp; ++i_comp) {
    PtComp &pt_comp = arr_pt_comp[i_comp];
    Comp &comp = *pt_comp;

    // Already computed?
    if (comp.is_result_computed()) {
      log("The file \"$\" which is required for computing the file \"$\" already exists.", comp.get_path4result(), path_result);
    } else {

      log("The file \"$\" which is required for computing the file \"$\" does not yet exist. So it will be computed now.", comp.get_path4result(), path_result);

      // Run computation
      if (!comp.run()) {ok=false; break;}

      // stopped ?
      if (!comp.is_complete()) {
        stopped=true;
        break;
      }
    }
    // Release memory
    pt_comp=PtComp();
  }

  // Release memory
  delete[] arr_pt_comp;

  if (ok && !stopped) log("All files required for the computation of the file \"$\" are present now.", path_result);

  return ok;
}

/* --- add_fileclause --- */

bool Comp::add_fileclause() {
  Str path_result = get_path4result();
  bool ok;

  if (!inited) {

    if (!exists_file(path_result)) return err(Str("File ") + enquote(path_result) + Str(" not computed"));

    In4File in4file;
    if (!in4file.open(path_result)) return false;

    InBuffering in_buffered(in4file);
    Chksummer4In in(in_buffered);
    log("Load results from file \"$\"...", path_result);
    ok=load_result(in) && in.read_chksum();

    if (!in4file.close()) return false;
    if (!ok) return false;

    log("Loaded results from file \"$\".", path_result);
    complete=true;
  }

  if (!complete) return err(Str("Computation of file ") + enquote(path_result) + Str(" not entirely done"));

  log("Save results to file \"$\"...", path_result);

  Out4File out;
  if (!out.open(path_result)) return false;

  Checksummer4Out chksummer(out);
  ok = write_fileclause(chksummer, get_filename4result()) && save_result(chksummer) && chksummer.write_chksum();
  if (!out.close()) return false;
  if (!ok) return false;

  log("Results saved to file \"$\".", path_result);
  return true;
}

/* --- open_file_result4inner --- */

bool Comp::open_file_result4inner(In4File &f, unsigned int &chksum) const {

  if (!f.open(get_path4result())) return false;

  InBuffering in_buffered(f);
  Chksummer4In in(in_buffered);
  if (!read_fileclause(in, get_filename4result())) return false;

  chksum = in.get_chksum();

  return true;
}

/* --- close_file_result4inner --- */

bool Comp::close_file_result4inner(In4File &f, unsigned int chksum) const {
  InBuffering in_buffered(f);
  Chksummer4In chksummer(in_buffered,chksum);
  if (!chksummer.read_chksum()) return false;
  if (!f.close()) return false;
  return true;
}

/* --- run --- */

bool Comp::run() {

  // Computation done?
  if (complete) return true;

  Str path_result = get_path4result();
  bool ok;
  if (exists_file(path_result)) {
    log("Load results from file \"$\"...", path_result);

    In4File in4file;
    if (!in4file.open(path_result)) return false;

    InBuffering in_buffered(in4file);
    Chksummer4In in(in_buffered);
    ok = read_fileclause(in, get_filename4result()) && load_result(in) && in.read_chksum();
    if (!in4file.close()) return false;
    if (!ok) return false;

    log("Loaded results from file \"$\".", path_result);
    return set_complete();
  }

  // Prepare computation
  if (!prepared) {
    bool stopped;
    if (!prepare(stopped)) return false;
    if (stopped) return true;
    prepared=true;
  }

  // Computation partially done => load
  Str path_work = get_path4work();
  if (!inited) {
    if (exists_file(path_work)) {
      log("Load interrupted computation from file \"$\"...", path_work);

      In4File in4file;
      if (!in4file.open(path_work)) return false;

      InBuffering in_buffered(in4file);
      Chksummer4In in(in_buffered);
      ok = read_fileclause(in, get_filename4work()) && load_work(in) && in.read_chksum();
      if (!in4file.close()) return false;
      if (!ok) return false;

      log("Loaded interrupted computation from file \"$\".", path_work);
      log("Continue computation of the file \"$\"...", path_result);
    } else {
      if (!init_work()) return false;
      log("Compute file \"$\"...", path_result);
    }
    inited=true;
  }

  // Run/continue computation
  if (!run4prepared_inited()) return false;
  if (complete) {
    log("File \"$\" computed.", path_result);
  } else {
    log("Computation of file \"$\" interrupted.", path_result);
  }

  // Save results
  Out4File out;
  if (complete) {
    log("Save results to file \"$\"...", path_result);

    if (!out.open(path_result)) return false;

    Checksummer4Out chksummer(out);
    ok = write_fileclause(chksummer, get_filename4result()) && save_result(chksummer) && chksummer.write_chksum();
    if (!out.close()) return false;
    if (!ok) return false;

    log("Saved result to file \"$\".", path_result);
  } else {
    log("Save interrupted computation to file \"$\"...", path_work);

    if (!out.open(path_work)) return false;

    Checksummer4Out chksummer(out);
    ok = write_fileclause(chksummer, get_filename4work()) && save_work(chksummer) && chksummer.write_chksum();
    if (!out.close()) return false;
    if (!ok) return false;

    log("Saved interrupted computation to file \"$\".", path_work);
  }

  // Remove working file, if computation done
  if (complete) {
    if (exists_file(path_work)) {
      if (!remove_file(path_work)) return false;
      log("Removed file \"$\".", path_work);
    }
  }

  return true;
}

/* --- get_path4result --- */

Str Comp::get_path4result() const {
  return get_path4filename(get_filename4result());
}

/* --- get_path4work --- */

Str Comp::get_path4work() const {
  return get_path4filename(get_filename4work());
}

/* --- get_path4filename --- */

Str Comp::get_path4filename(Str filename) const {
  return path_dir + sep_path + filename;
}


////////////////////
// FILE setimpl.h //
////////////////////

// From c:\kombin\lego2\footprnt


///////////////////
// FILE mirror.h //
///////////////////

#define MY_MIRROR_H


////////////////
// FILE set.h //
////////////////

// From c:\kombin\lego2\footprnt



///////////////////
// FILE mirror.h //
///////////////////

class Part;
struct Perm;
class FamGraph;
class SetPerm;
struct Pos4Fig;

/* --- exported functions --- */

void get_fun_mirror(const Part&, const FamGraph&, SetPerm&);
Pos4Fig mirror4center(const Pos4Fig&);




////////////////////
// FILE csym2.cpp //
////////////////////

/* === CompFigRotSym24Part =============================================== */

/* --- static members --- */

const Str CompFigRotSym24Part::start_filename("sym2rotfig4part(");

/* --- constructor --- */

CompFigRotSym24Part::CompFigRotSym24Part(const Part &p_part, const Str &path_dir) : Comp(path_dir), part(p_part), pt_set_done(0), pt_comp_fam_graph(0), set_found(p_part.get_n_brick()) {}

/* --- setup_lst_comp_prepare --- */

bool CompFigRotSym24Part::setup_lst_comp_prepare(Lst<PtComp> &lst) const {
  lst.clear();

  get_ref_comp_fam_graph();
  lst.append(pt_comp_fam_graph_keeper);

  return true;
}

/* --- save_result --- */

bool CompFigRotSym24Part::save_result(Out &out) const {

  int n = set_found.get_n();
  if (!out.printf("n=$\n", n)) return false;

  WriterFig writer(out);
  if (!set_found.iterate(writer)) return false;

  return true;
}

/* --- load_result(private) --- */

bool CompFigRotSym24Part::load_result(InBuffered &in) {
  static const Str s_n("n=");
  int n;

  if (!in.read_str_given(s_n)) return false;
  if (!in.read_card(n)) return false;
  if (!in.read_eoln()) return false;

  int i;
  set_found.clear();
  for (i=0; i<n; ++i) {
    FigRot fig;
    if (!read(in, part.get_n_brick(), fig)) return false;
    if (!in.read_eoln()) return false;
    set_found.insert(fig);
  }

  return true;
}

/* --- save_work --- */

bool CompFigRotSym24Part::save_work(Out &out) const {

  SetFamGraph4Part &set_done = *pt_set_done;
  if (!out.printf("ndone=$\n", set_done.get_n())) return false;

  WriterFamGraph writer(out);
  TransformerFamGraphFac2FamGraph transformer(writer);
  if (!set_done.iterate(transformer)) return false;

  if (!save_result(out)) return false;

  return true;
}

/* --- load_work --- */

bool CompFigRotSym24Part::load_work(InBuffered &in) {
  FKT "CompFigRotSym24Part::load_work";
  int n_done;

  if (!in.read_str_given(c_ndone_eq)) return false;
  if (!in.read_card(n_done)) return false;
  if (!in.read_eoln()) return false;

  if (pt_set_done==0) {

    CompFamGraph4Part &comp_fam_graph = get_ref_comp_fam_graph();
    if (!comp_fam_graph.run()) return false;
    int n_fam_graph = comp_fam_graph.get_n();
    pt_set_done = new SetFamGraph4Part(part, n_fam_graph);
    if (pt_set_done==0) errstop_memoverflow(fkt);
  }

  int i_done, n_brick = part.get_n_brick();
  SetFamGraph4Part &set_done = *pt_set_done;
  for (i_done=0; i_done<n_done; ++i_done) {
    FamGraph done(n_brick);
    if (!read(in, n_brick, done)) return false;
    if (!in.read_eoln()) return false;
    set_done.add(done,1);
  }

  if (!load_result(in)) return false;

  return true;
}

/* --- get_filename4result --- */

Str CompFigRotSym24Part::get_filename4result() const {
  return start_filename+part.to_str()+c_end_filename_result;
}

/* --- get_filename4work --- */

Str CompFigRotSym24Part::get_filename4work() const {
  return start_filename+part.to_str()+c_end_filename_work;
}

/* --- iterate --- */

bool CompFigRotSym24Part::iterate(Performer<FigRot> &performer) const {
  FKT "CompFigRotSym24Part::iterate";

  if (!is_complete()) errstop(fkt, "Berechnung nicht durchgefuehrt");

  return set_found.iterate(performer);
}

/* --- get_n_found --- */

int CompFigRotSym24Part::get_n_found() const {
  FKT "CompFigRotSym24Part::get_n_found";

  if (!is_complete()) errstop(fkt, "Berechnung nicht durchgefuehrt");

  return set_found.get_n();
}

/* --- get_ref_comp_fam_graph --- */

CompFamGraph4Part& CompFigRotSym24Part::get_ref_comp_fam_graph() const {
  FKT "CompFigRotSym24Part::get_ref_comp_fam_graph";

  if (pt_comp_fam_graph==0) {
    *const_cast<CompFamGraph4Part**>(&pt_comp_fam_graph) = new CompFamGraph4Part(part, path_dir);
    if (pt_comp_fam_graph==0) errstop_memoverflow(fkt);
    *const_cast<PtComp*> (&pt_comp_fam_graph_keeper) = PtComp(pt_comp_fam_graph);
  }
  return *pt_comp_fam_graph;
}

/* --- run4prepared_inited --- */

bool CompFigRotSym24Part::run4prepared_inited() {

  CompFamGraph4Part &comp_fam_graph = get_ref_comp_fam_graph();
  if (!comp_fam_graph.run()) return false;
  if (!comp_fam_graph.is_complete()) {
    return err(Str("File ") + enquote(comp_fam_graph.get_filename4result()) + Str(" not computed"));
  }

  int n_fam_graph = comp_fam_graph.get_n(), i_fam_graph;
  SetFamGraph4Part &set_done = *pt_set_done;
  log_progress_start();
  for (i_fam_graph=0; i_fam_graph<n_fam_graph; ++i_fam_graph) {
    FamGraph fam_graph = comp_fam_graph.get(i_fam_graph);

    if (set_done.get(fam_graph)!=0) continue;

    log_progress("Considered $/$ graph families ($).", i_fam_graph, n_fam_graph);

    add_fig(fam_graph);
    set_done.add(fam_graph,1);

    // Stopped ?
    if (check_stopped()) return true;
  }
  log_progress_end();

  return set_complete();
}

/* --- add_fig --- */

void CompFigRotSym24Part::add_fig(const FamGraph &fam_graph) {
  FKT "CompFigRotSym24Part::add_fig";

  SetPerm set_fun_mirror(part.get_n_brick());
  get_fun_mirror(part, fam_graph, set_fun_mirror);

  AdderFigRotSym4FunMirror adder(part, fam_graph, set_found);
  if (!set_fun_mirror.iterate(adder)) errstop(fkt, "iterate failed");
}

/* --- destructor --- */

CompFigRotSym24Part::~CompFigRotSym24Part() {
  if (pt_set_done!=0) delete pt_set_done;
}

/* --- read_evtl_filename4result --- */

bool CompFigRotSym24Part::read_evtl_filename4result(const Str &filename, Part &part) {
  In4Str in(filename);

  if (!in.read_evtl_str_given(start_filename)) return false;
  if (!read_evtl(in, part)) return false;
  if (!in.read_evtl_str_given(c_end_filename_result)) return false;

  return in.at_end();
}

/* --- init_work --- */

bool CompFigRotSym24Part::init_work() {
  FKT "CompFigRotSym24Part::init_work";

  CompFamGraph4Part &comp_fam_graph = get_ref_comp_fam_graph();
  if (!comp_fam_graph.run()) return false;
  int n_fam_graph = comp_fam_graph.get_n();
  pt_set_done = new SetFamGraph4Part(part, n_fam_graph);
  if (pt_set_done==0) errstop_memoverflow(fkt);

  set_found.clear();

  return true;
}

/* === AdderFigRotSym4FunMirror ========================================== */

/* --- constructor --- */

AdderFigRotSym4FunMirror::AdderFigRotSym4FunMirror(
  const Part         &p_part     ,
  const FamGraph     &p_fam_graph,
        SetFigRotCpr &p_target
) :
  part      (p_part              ),
  target    (p_target            ),
  fam_graph (p_fam_graph         ),
  n_brick   (p_part.get_n_brick())
{
  part.get_arr_i_layer4brick(arr_i_layer4brick);
}

/* --- perform --- */

bool AdderFigRotSym4FunMirror::perform(const Perm &fun_mirror) {

  // Get graph of sure connections from <fam_graph> and <fun_mirror>
  Graph graph_sure(n_brick);
  int i_brick, j_brick;
  for (i_brick=0; i_brick<n_brick; ++i_brick) {
    for (j_brick=0; j_brick<i_brick; ++j_brick) {
      int i_brick_mirror = fun_mirror.data[i_brick];
      int j_brick_mirror = fun_mirror.data[j_brick];
      if (
        fam_graph.get_overlap(i_brick       , j_brick       )==OVERLAP_BRICK ||
        fam_graph.get_overlap(i_brick_mirror, j_brick_mirror)==OVERLAP_BRICK
      ) {
        graph_sure.set_linked(i_brick       , j_brick       , true);
        graph_sure.set_linked(i_brick_mirror, j_brick_mirror, true);
      }
    }
  }

  // Get distance matrix from <graph_sure>
  int mat_dist[N_BRICK_MAX][N_BRICK_MAX];
  for (i_brick=0; i_brick<n_brick; ++i_brick) { // ... compute distance from brick <i_brick> to any other brick

    // Initialise distances from brick <i_brick>
    for (j_brick=0; j_brick<n_brick; ++j_brick) {
      mat_dist[i_brick][j_brick] = N_BRICK_MAX;
    }
    mat_dist[i_brick][i_brick]=0;

    // Shorten distances
    bool shortened;
    do {
      shortened=false;
      for (j_brick=0; j_brick<n_brick; ++j_brick) {
        int dist2k_via_j = mat_dist[i_brick][j_brick]+1, k_brick;
        for (k_brick=0; k_brick<n_brick; ++k_brick) if (k_brick!=i_brick && k_brick!=j_brick) {
          if (graph_sure.is_linked(j_brick, k_brick)) {
            int &dist2k = mat_dist[i_brick][k_brick];
            if (dist2k>dist2k_via_j) {
              dist2k=dist2k_via_j;
              shortened=true;
            }
          }
        }
      }
    } while (shortened);
  }

  // Start recursion
  bool arr_set[N_BRICK_MAX];
  Pos4Fig arr_pos[N_BRICK_MAX];
  AlignOdd align_odd_stud;
  align_odd_stud.x = false; align_odd_stud.y = false; set(arr_set, n_brick, false); if (!add_rek(mat_dist, fun_mirror, arr_set, arr_pos, align_odd_stud)) return false;
  align_odd_stud.x = false; align_odd_stud.y = true ; set(arr_set, n_brick, false); if (!add_rek(mat_dist, fun_mirror, arr_set, arr_pos, align_odd_stud)) return false;
  align_odd_stud.x = true ; align_odd_stud.y = false; set(arr_set, n_brick, false); if (!add_rek(mat_dist, fun_mirror, arr_set, arr_pos, align_odd_stud)) return false;
  align_odd_stud.x = true ; align_odd_stud.y = true ; set(arr_set, n_brick, false); if (!add_rek(mat_dist, fun_mirror, arr_set, arr_pos, align_odd_stud)) return false;
  return true;
}

/* --- check_pos_new --- */

// Checks whether the new position <i_brick>
// - is close enough to all other positions
// - does not overlap with any other position

bool AdderFigRotSym4FunMirror::check_pos_new(
  int i_brick,
  int (*mat_dist)[N_BRICK_MAX], // Distance matrix = number of bricks to get from one brick to another
  const bool *arr_set, // Indicates which brick is set; refers to <arr_pos_center_dbl>
  const Pos4Fig *arr_pos_center_dbl, // Position of the center of the brick relative to the center of the building, times two.
  const AlignOdd &align_odd_stud
) const {

  // Correct aligned
  {
    const Pos4Fig &pos_center_dbl = arr_pos_center_dbl[i_brick];
    bool odd_x_stud = (pos_center_dbl.x&1)!=(DIM_BRICK_X4ROTATED(pos_center_dbl.rotated)&1);
    bool odd_y_stud = (pos_center_dbl.y&1)!=(DIM_BRICK_Y4ROTATED(pos_center_dbl.rotated)&1);
    if (!(odd_x_stud==align_odd_stud.x && odd_y_stud==align_odd_stud.y)) return false;
  }

  int j_brick;
  for (j_brick=0; j_brick<n_brick; ++j_brick) {
    if (i_brick==j_brick) continue;
    if (!arr_set[j_brick]) continue;

    // Maximum distance exceeded
    int dist = mat_dist[i_brick][j_brick]; // The maximum distance in bricks
    const Pos4Fig &a = arr_pos_center_dbl[i_brick];
    const Pos4Fig &b = arr_pos_center_dbl[j_brick];
    int dx_dbl_max4connected = DIM_BRICK_X4ROTATED(a.rotated) + DIM_BRICK_X4ROTATED(b.rotated) - 2;
    int dy_dbl_max4connected = DIM_BRICK_Y4ROTATED(a.rotated) + DIM_BRICK_Y4ROTATED(b.rotated) - 2;
    int dx_dbl_max = 2*(dist-1)*(L_BRICK-1) + dx_dbl_max4connected; // The maximum x distance of a brick center to the buildings center, in half units, in one direction.
    int dy_dbl_max = 2*(dist-1)*(L_BRICK-1) + dy_dbl_max4connected; // The maximum y distance of a brick center to the buildings center, in half units, in one direction.
    int dx_dbl = abs(a.x-b.x);
    int dy_dbl = abs(a.y-b.y);
    if (dx_dbl>dx_dbl_max || dy_dbl>dy_dbl_max) {
      return false;
    }
    int sum_d_dbl = dx_dbl_max4connected + dy_dbl_max4connected + 2*(dist-1)*(L_BRICK+W_BRICK-2); // The maximum sum of x- and y-distance of a brick center to the buildings center, in half units.
    if (dx_dbl+dy_dbl>sum_d_dbl) {
      return false;
    }

    // Overlap ?
    if (a.z==b.z && dx_dbl<=dx_dbl_max4connected && dy_dbl<=dy_dbl_max4connected) {
      return false;
    }
  }

  return true;
}

/* --- add_rek --- */

bool AdderFigRotSym4FunMirror::add_rek(
  int (*mat_dist)[N_BRICK_MAX], // Distance matrix = number of bricks to get from one brick to another
  const Perm &fun_mirror,
  bool *arr_set, // Indicates which brick is set; refers to <arr_pos_center_dbl>
  Pos4Fig *arr_pos_center_dbl, // Position of the center of the brick relative to the center of the building, times two.
  const AlignOdd &align_odd_stud
) {

  // All positions set => add to target
  int i_brick;
  if (is(arr_set, n_brick, true)) {

    // Shift building such that the center of the building is the center of the 1st brick
    Pos4Fig arr_pos_dbl[N_BRICK_MAX];
    if (n_brick>0) {
      int x_center0_dbl = arr_pos_center_dbl[0].x;
      int y_center0_dbl = arr_pos_center_dbl[0].y;
      for (i_brick=0; i_brick<n_brick; ++i_brick) {
        Pos4Fig &pos_dbl = arr_pos_dbl[i_brick];
        const Pos4Fig &pos_center_dbl = arr_pos_center_dbl[i_brick];

        pos_dbl = pos_center_dbl;

        // Move pos relative to the center of the 1st brick
        pos_dbl.x-=x_center0_dbl;
        pos_dbl.y-=y_center0_dbl;

        // Move <pos> from the center to the left lower egde of the bricj
        pos_dbl.x-=DIM_BRICK_X4ROTATED(pos_dbl.rotated);
        pos_dbl.y-=DIM_BRICK_Y4ROTATED(pos_dbl.rotated);


        // Convert from half to full units
        // if (pos.x&1) errstop(fkt, "pos.x is odd");
        // if (pos.y&1) errstop(fkt, "pos.y is odd");
        // pos.x>>=1;
        // pos.y>>=1;
      }
    }

    FigRot fig(arr_pos_dbl, true, n_brick);
    target.insert(fig);
    return true;
  }

  // If there is an unset positions whose mirror position is set, set it, and recur
  for (i_brick=0; i_brick<n_brick; ++i_brick) {
    bool &set = arr_set[i_brick];
    if (set) continue;

    int i_brick_mirror = fun_mirror.data[i_brick];
    if (!arr_set[i_brick_mirror]) continue;

    arr_pos_center_dbl[i_brick] = mirror4center(arr_pos_center_dbl[i_brick_mirror]);
    set=true;
    if (check_pos_new(i_brick, mat_dist, arr_set, arr_pos_center_dbl, align_odd_stud)) {
      if (!add_rek(mat_dist, fun_mirror, arr_set, arr_pos_center_dbl, align_odd_stud)) return false;
    }
    set=false;
    return true;
  }

  // If there is an unset fix point of mirror function, set it to the center, and recur
  int i_rotated;
  for (i_brick=0; i_brick<n_brick; ++i_brick) {
    if (fun_mirror.data[i_brick]!=i_brick) continue;

    bool &set = arr_set[i_brick];
    if (set) continue;

    // From here on: <i_brick> is unset fix point

    // Set coordinates of fix point
    Pos4Fig &pos = arr_pos_center_dbl[i_brick];
    pos.x=pos.y=0;
    pos.z = arr_i_layer4brick[i_brick];

    // Rotate fix point, and recur
    set=true;
    FOR_ALL_ROTATED(pos.rotated, i_rotated) {
      if (check_pos_new(i_brick, mat_dist, arr_set, arr_pos_center_dbl, align_odd_stud)) {
        if (!add_rek(mat_dist, fun_mirror, arr_set, arr_pos_center_dbl, align_odd_stud)) return false;
      }
    }
    set=false;

    return true;
  }

  // If there is an unset brick which is neighboured to a set brick, set it and recur
  int i_brick_new, i_brick_old;
  for (i_brick_new=0; i_brick_new<n_brick; ++i_brick_new) {

    bool &set_new = arr_set[i_brick_new];
    if (set_new) continue;

    for (i_brick_old=0; i_brick_old<n_brick; ++i_brick_old) {
      if (mat_dist[i_brick_new][i_brick_old]!=1) continue;
      if (!arr_set[i_brick_old]) continue;

      // From here on: <i_brick_new> is neighboured to <i_brick_old>, <i_brick_new> is not set, while <i_brick_old> is.

      // Iterate over all possible positions, check them, and recur
      const Pos4Fig &pos_old = arr_pos_center_dbl[i_brick_old];
      Pos4Fig &pos_new = arr_pos_center_dbl[i_brick_new];
      set_new=true;
      pos_new.z = arr_i_layer4brick[i_brick_new];
      FOR_ALL_ROTATED(pos_new.rotated, i_rotated) {
        int dx_dbl_max4connected = DIM_BRICK_X4ROTATED(pos_old.rotated) + DIM_BRICK_X4ROTATED(pos_new.rotated) - 2;
        int dy_dbl_max4connected = DIM_BRICK_Y4ROTATED(pos_old.rotated) + DIM_BRICK_Y4ROTATED(pos_new.rotated) - 2;
        int dist = mat_dist[i_brick_new][i_brick_old];
        int dx_dbl_max = 2*(dist-1)*(L_BRICK-1) + dx_dbl_max4connected; // The maximum x distance of a brick center to the buildings center, in half units, in one direction.
        int dy_dbl_max = 2*(dist-1)*(L_BRICK-1) + dy_dbl_max4connected; // The maximum y distance of a brick center to the buildings center, in half units, in one direction.
        int x_min_dbl = pos_old.x-dx_dbl_max, x_max_dbl = pos_old.x+dx_dbl_max;
        int y_min_dbl = pos_old.y-dy_dbl_max, y_max_dbl = pos_old.y+dy_dbl_max;

        for (pos_new.x=x_min_dbl; pos_new.x<=x_max_dbl; ++pos_new.x) {
          for (pos_new.y=y_min_dbl; pos_new.y<=y_max_dbl; ++pos_new.y) {
            if (check_pos_new(i_brick_new, mat_dist, arr_set, arr_pos_center_dbl, align_odd_stud)) {
              if (!add_rek(mat_dist, fun_mirror, arr_set, arr_pos_center_dbl, align_odd_stud)) return false;
            }
          }
        }
      }
      set_new=false;
      return true;
    }
  }

  // If there are two unset bricks which are mirrors of each other, set them and recur
  int i_brick_plus;
  for (i_brick_plus=0; i_brick_plus<n_brick; ++i_brick_plus) {
    bool &set_plus = arr_set[i_brick_plus];
    if (set_plus) continue;

    int i_brick_minus = fun_mirror.data[i_brick_plus];
    if (i_brick_minus>=i_brick_plus) continue;

    bool &set_minus = arr_set[i_brick_minus];
    if (set_minus) continue;

    // From here on: <i_brick> and <i_brick_mirror> are two unset bricks which are mirrors of each other
    // Moreover, i_brick<i_brick_mirror

    int dist = mat_dist[i_brick_plus][i_brick_minus]; // The maximum distance in bricks
    int d_dbl     = 2*dist*(L_BRICK-1); // The maximum distance of a brick center to the building center, in half units, in one direction.
    int sum_d_dbl = 2*dist*(L_BRICK+W_BRICK-2); // The maximum sum of x- and y-distance of a brick center to the building center, in half units.

    Pos4Fig &pos_plus_dbl  = arr_pos_center_dbl[i_brick_plus ];
    Pos4Fig &pos_minus_dbl = arr_pos_center_dbl[i_brick_minus];
    pos_plus_dbl .z = arr_i_layer4brick[i_brick_plus ];
    pos_minus_dbl.z = arr_i_layer4brick[i_brick_minus];
    FOR_ALL_ROTATED(pos_plus_dbl.rotated, i_rotated) {
      for (pos_plus_dbl.x=-d_dbl; pos_plus_dbl.x<=d_dbl; ++pos_plus_dbl.x) {

        for (pos_plus_dbl.y=-d_dbl; pos_plus_dbl.y<=d_dbl; ++pos_plus_dbl.y) {
          if (pos_plus_dbl.x+pos_plus_dbl.y>sum_d_dbl) continue;

          pos_minus_dbl = mirror4center(pos_plus_dbl);
          if (cmp(pos_minus_dbl, pos_plus_dbl)>=0) continue;

          set_minus=false;
          set_plus=false;
          if (!check_pos_new(i_brick_plus, mat_dist, arr_set, arr_pos_center_dbl, align_odd_stud)) continue;
          set_plus=true;
          if (!check_pos_new(i_brick_minus, mat_dist, arr_set, arr_pos_center_dbl, align_odd_stud)) continue;
          set_minus=true;

          if (!add_rek(mat_dist, fun_mirror, arr_set, arr_pos_center_dbl, align_odd_stud)) return false;
        }
      }
    }

    set_plus=set_minus=false;

    return true;
  }

  return err("Graph-Familie nicht sicher zusammenhaengend");
}

////////////////////
// FILE setimpl.h //
////////////////////

// From c:\kombin\lego2\footprnt




////////////////////
// FILE csym4.cpp //
////////////////////

/* --- declare static functions --- */

static void set_pos(Pos4Fig&, int x, int y, int z, bool rotated);


/* === CompFigRotSym24Part =============================================== */

/* --- static members --- */

const Str CompFigRotSym44Part::start_filename("sym4rotfig4part(");

/* --- constructor --- */

CompFigRotSym44Part::CompFigRotSym44Part(const Part &p_part, const Str &path_dir) : Comp(path_dir), part(p_part), pt_comp_sym2(0), set_found(p_part.get_n_brick()) {}

/* --- setup_lst_comp_prepare --- */

bool CompFigRotSym44Part::setup_lst_comp_prepare(Lst<PtComp> &lst) const {
  lst.clear();

  get_ref_comp_sym2();
  lst.append(pt_comp_sym2_keeper);

  return true;
}

/* --- save_result --- */

bool CompFigRotSym44Part::save_result(Out &out) const {

  int n = set_found.get_n();
  if (!out.printf("n=$\n", n)) return false;

  WriterFig writer(out);
  if (!set_found.iterate(writer)) return false;

  return true;
}

/* --- load_result --- */

bool CompFigRotSym44Part::load_result(InBuffered &in) {
  static const Str s_n("n=");

  int n;
  if (!in.read_str_given(s_n)) return false;
  if (!in.read_card(n)) return false;
  if (!in.read_eoln()) return false;

  int i;
  set_found.clear();
  for (i=0; i<n; ++i) {
    FigRot fig;
    if (!read(in, part.get_n_brick(), fig)) return false;
    if (!in.read_eoln()) return false;
    set_found.insert(fig);
  }

  return true;
}

/* --- save_work --- */

bool CompFigRotSym44Part::save_work(Out&) const {
  return true;
}


/* --- load_work --- */

bool CompFigRotSym44Part::load_work(InBuffered&) {
  return true;
}

/* --- get_filename4result --- */

Str CompFigRotSym44Part::get_filename4result() const {
  return start_filename+part.to_str()+c_end_filename_result;
}

/* --- get_filename4work --- */

Str CompFigRotSym44Part::get_filename4work() const {
  return start_filename+part.to_str()+c_end_filename_work;
}

/* --- get_n_found --- */

int CompFigRotSym44Part::get_n_found() const {
  FKT "CompFigRotSym44Part::get_n_found";

  if (!is_complete()) errstop(fkt, "Berechnung nicht durchgefuehrt");

  return set_found.get_n();
}

/* --- get_ref_comp_fam_graph --- */

CompFigRotSym24Part& CompFigRotSym44Part::get_ref_comp_sym2() const {
  FKT "CompFigRotSym44Part::get_ref_comp_sym2";

  if (pt_comp_sym2==0) {
    *const_cast<CompFigRotSym24Part**>(&pt_comp_sym2) = new CompFigRotSym24Part(part, path_dir);
    if (pt_comp_sym2==0) errstop_memoverflow(fkt);
    *const_cast<PtComp*> (&pt_comp_sym2_keeper) = PtComp(pt_comp_sym2);
  }
  return *pt_comp_sym2;
}

/* --- run4prepared_inited --- */

bool CompFigRotSym44Part::run4prepared_inited() {

  CompFigRotSym24Part &comp_sym2 = get_ref_comp_sym2();
  if (!comp_sym2.run()) return false;
  if (!comp_sym2.is_complete()) {
    return err(Str("File ") + enquote(comp_sym2.get_filename4result()) + Str(" not computed"));
  }

  Adder4Sym4 adder(comp_sym2.get_n_found(), set_found);
  log_progress_start();
  if (!comp_sym2.iterate(adder)) return false;
  log_progress_end();

  return set_complete();
}

/* --- destructor --- */

CompFigRotSym44Part::~CompFigRotSym44Part() {}

/* --- read_evtl_filename4result --- */

bool CompFigRotSym44Part::read_evtl_filename4result(const Str &filename, Part &part) {
  In4Str in(filename);

  if (!in.read_evtl_str_given(start_filename)) return false;
  if (!read_evtl(in, part)) return false;
  if (!in.read_evtl_str_given(c_end_filename_result)) return false;

  return in.at_end();
}

/* --- init_work --- */

bool CompFigRotSym44Part::init_work() {
  return true;
}


/* === Adder4Sym4 ======================================================== */

/* --- constructor --- */

Adder4Sym4::Adder4Sym4(int p_n, SetFigRotCpr &p_target) : n(p_n), target(p_target), n_done(0) {}

/* --- perform --- */

bool Adder4Sym4::perform(const FigRot &fig) {
  log_progress("Considered $/$ buildings with 2 symmetry ($).", n_done, n);

  // Get barycenter
  const int n_brick=fig.n_brick;
  int x_center_dbl=0, y_center_dbl=0, i_brick;
  if (n_brick==0) return true; // Strange case
  for (i_brick=0; i_brick<n_brick; ++i_brick) {
    const Pos4Fig &pos= fig.get_pos_brick(i_brick);
    x_center_dbl+=(pos.x<<1) + DIM_BRICK_X4ROTATED(pos.rotated);
    y_center_dbl+=(pos.y<<1) + DIM_BRICK_Y4ROTATED(pos.rotated);
  }
  if (x_center_dbl%n_brick>0 || y_center_dbl%n_brick>0) {
    return true;
  }
  x_center_dbl/=n_brick; y_center_dbl/=n_brick;
  if ((x_center_dbl&1) != (y_center_dbl&1)) {
    return true;
  }

  // Rotate building
  FigRot fig_rotated(fig);
  fig_rotated.rot90();

  if (fig_rotated==fig) {
    target.insert(fig);
  }

  ++n_done;
  return true;
}


/* === test functions ==================================================== */

/* --- testsym4 --- */

void testsym4() {
  Pos4Fig arr_pos_brick[8];
  set_pos(arr_pos_brick[0], 0,0,0,true );
  set_pos(arr_pos_brick[1], 2,0,0,false);
  set_pos(arr_pos_brick[2], 3,2,0,true );
  set_pos(arr_pos_brick[3], 0,3,0,false);
  set_pos(arr_pos_brick[4], 0,0,1,false);
  set_pos(arr_pos_brick[5], 3,0,1,true );
  set_pos(arr_pos_brick[6], 2,3,1,false);
  set_pos(arr_pos_brick[7], 0,2,1,true );

  FigRot fig_rot(arr_pos_brick, false, 8);

  SetFigRotCpr target(8);
  Adder4Sym4 adder(1, target);
  if (!adder.perform(fig_rot)) {pl("testsym4: adder.perform failed"); return;}
  if (target.get_n()!=1) {pl("testsym4 failed: target.get_n()!=1"); return;}
  pl("testsym4 passed");
}


/* === static functions ================================================== */

/* --- set_pos --- */

static void set_pos(Pos4Fig &pos, int x, int y, int z, bool rotated) {
  pos.x=x;
  pos.y=y;
  pos.z=z;
  pos.rotated=rotated;
}

////////////////
// FILE str.h //
////////////////

// From c:\consql






///////////////////
// FILE elem.cpp //
///////////////////

/* === exported functions ================================================ */

/* --- get_i_insert --- */

// Finds the insertion index, i.e. the smalled index i such that: arr[i]>=key or i>=n_elem.
// assumes arr is sorted ascendingly.
// size_elem is the size of each element, arr[i] is stored at offset position i*n_size_elem from arr.
// *ptr_cmp_elem_key always is called with an array element as first argument, and ptr_key as the second argument.
// The type of key might be different from the type pof the elements of the array.

int get_i_insert(const void *arr, int n_elem, int size_elem, const void *ptr_key, int (*ptr_cmp_elem_key)(const void*, const void*)) {
  if (n_elem==0) return 0;

  int i_mid = n_elem>>1;
  byte *ptr_mid = ((byte*)arr)+(size_elem*i_mid);
  if ((*ptr_cmp_elem_key)(ptr_mid, ptr_key)>=0) { // arr[i_mid]>=elem => insertion index is at most mid
    return get_i_insert(arr, i_mid, size_elem, ptr_key, ptr_cmp_elem_key);
  } else { // arr[mid]<elem => insertion index is at least i_mid+1
    int i_mid1=i_mid+1;
    return i_mid1+get_i_insert(ptr_mid+size_elem, n_elem-i_mid1, size_elem, ptr_key, ptr_cmp_elem_key);
  }
}

/* --- swap(INT) --- */

void swap(int &a, int &b) {
  int tmp=a;
  a=b;
  b=tmp;
}

/* --- swap(BOOL) --- */

void swap(bool &a, bool &b) {
  bool tmp=a;
  a=b;
  b=tmp;
}

/* --- set --- */

void set(bool *arr, int n, bool val) {
  int i;
  for (i=0; i<n; ++i) arr[i]=val;
}

/* --- get_n4val --- */

int get_n4val(const bool *arr, int n, bool val) {
  int i, n4val=0;
  for (i=0; i<n; ++i) if (arr[i]==val) ++n4val;
  return true;
}

/* --- cmp_arr_int --- */

int cmp_arr_int(const int *a, const int *b, int n) {
  int i;

  for (i=0; i<n; ++i) {
    if (*a<*b) return -1;
    if (*a>*b) return +1;
    ++a;
    ++b;
  }

  return 0;
}

/* --- swap_arr_int --- */

void swap_arr_int(int *a, int *b, int n) {
  int tmp,i;

  for (i=0; i<n; ++i) {
    tmp=*a;
    *a=*b;
    *b=tmp;
    ++a;
    ++b;
  }
}

/* --- get_i_first4val --- */

int get_i_first4val(const bool *arr, int n, bool val) {
  FKT "get_i_first4val";
  int i;

  for (i=0; i<n; ++i) if (arr[i]==val) return i;
  errstop(fkt, "No element has the desired value");
  return -1;
}

/* --- inverse --- */

void inverse(const bool *arr, int n, bool *arr_inverse) {
  int i;
  for (i=0; i<n; ++i) arr_inverse[i]=!arr[i];
}


/* --- is --- */

bool is(const bool *arr, int n, bool val) {
  int i;
  for (i=0; i<n; ++i) if (arr[i]!=val) return false;
  return true;
}

/* --- cmp_dword --- */

int cmp_dword(DWORD a,DWORD b) {
  if (a<b) return -1;
  if (a>b) return +1;
  return 0;
}

/* --- adv --- */

void adv(bool *arr, int n) {
  int i;

  for (i=0; i<n; ++i) {
    bool &elem = arr[i];
    if (elem) {
      elem=false;
    } else {
      elem=true;
      return;
    }
  }
}

/* --- fac --- */

int fac(int n) {
  FKT "fac";
  if (n<0) errstop(fkt, "n<0");
  if (n==0) return 1;
  return n*fac(n-1);
}

/* --- pl(Str) --- */

// Prints a line

void pl(Str s) {
  s.print(stdout);
  putchar('\n');
}

/* --- pl --- */

// Prints a line

void pl(const char *line) {
  printf("%s\n", line);
}

/* --- pl(int) --- */

// Prints a line

void pl(const char *fmt, int prm) {
  printf(fmt, prm);
  putchar('\n');
}

/* --- pl(int,int) --- */

// Prints a line

void pl(const char *fmt, int prm1, int prm2) {
  printf(fmt, prm1,prm2);
  putchar('\n');
}

/* --- max_int --- */

int max_int(int a, int b) {
  return a>b ? a : b;
}

/* --- set_int --- */

void set_int(int &var, int val) {
  var=val;
}

/* --- add2int --- */

void add2int(int &var, int inc) {
  var+=inc;
}

/* --- min_int(2) --- */

int min_int(int a, int b) {
  return a<b ? a : b;
}

/* --- min_int(3) --- */

int min_int(int a, int b, int c) {
  return min_int(a, min_int(b,c));
}

/* --- cmp_int --- */

int cmp_int(int a, int b) {
  if (a<b) return -1;
  if (a>b) return +1;
  return 0;
}

/* --- cmp_dbl --- */

int cmp_dbl(double a, double b) {
  if (a<b) return -1;
  if (a>b) return +1;
  return 0;
}

/* --- cmp_dbl4qsort --- */

int cmp_dbl4qsort(const void *pt_a, const void *pt_b) {
  return cmp_dbl(*(double*)pt_a, *(double*)pt_b);
}

////////////////
// FILE str.h //
////////////////

// From c:\consql




//////////////////
// FILE err.cpp //
//////////////////

/* --- exported fields --- */

bool expect_errstop=false;

/* --- statoc  fields --- */

static bool errs=false;


/* === exported functions ================================================ */

/* --- err_test_fkt --- */

bool err_test_fkt(const char *fkt_test, const char *fkt_tested, int i_call, const Str &errtxt) {
  printf("Testfunktion %s: %d. Aufruf der getesteten Funktion %s mit folgendem Fehlertext fehlgeschlagen: ", fkt_test, i_call+1, fkt_tested);
  errtxt.print(stdout);
  putchar('\n');
  return false;
}

/* --- got_errstop --- */

bool got_errstop() {
  if (errs) {
    errs=false;
    return true;
  } else {
    return false;
  }
}

/* --- err_check_failed --- */

bool err_check_failed(const char *fkt_test, int i_check) {
  printf("Pruefung %d der Testfunktion %s fehlgeschlagen.\n", i_check, fkt_test);
  return false;
}

/* --- errstop_index --- */

void errstop_index(const char *fkt) {
  errstop(fkt, "Index ausserhalb des gueltigen Bereiches");
}

/* --- err(Str) --- */

bool err(Str txt) {
  log(txt);
  return false;
}

/* --- err(NTS) --- */

bool err(const char *txt) {
  // printf("%s\n", txt);
  log(txt);
  return false;
}

/* --- errstop(Str) --- */

void errstop(const char *fkt, const Str &txt) {
  printf("Error stop in function %s: ", fkt);
  txt.print(stdout);
  printf(".\n");
  if (expect_errstop) {
    expect_errstop=false;
    errs=true;
  } else {
    exit(1);
  }
}


/* --- errstop --- */

void errstop(const char *fkt, const char *txt) {
  err("Error stop in function %s: %s.", fkt, txt);
  if (expect_errstop) {
    expect_errstop=false;
    errs=true;
  } else {
    exit(1);
  }
}

/* --- err(NTS,NTS) --- */

bool err(const char *txt, const char *prm1, const char *prm2) {
  char txt_expanded[1024];
  sprintf(txt_expanded, txt, prm1, prm2);
  return err(txt_expanded);
}

/* --- err(int) --- */

bool err(const char *txt, int prm) {
  char txt_expanded[1024];
  sprintf(txt_expanded, txt, prm);
  return err(txt_expanded);
}

/* --- err(int, unsigned) --- */

bool err(const char *txt, int prm1, unsigned int prm2) {
  char txt_expanded[1024];
  sprintf(txt_expanded, txt, prm1, prm2);
  return err(txt_expanded);
}

/* --- err_silent(NTS) --- */

bool err_silent(Str &out, const char *txt) {
  out=txt;
  return false;
}

/* --- err_silent(Str) --- */

bool err_silent(Str &out, Str txt) {
  out=txt;
  return false;
}

/* --- errstop_memoverflow --- */

void errstop_memoverflow(const char *fkt) {
  errstop(fkt, "Speicherueberlauf");
}


////////////////////
// FILE setimpl.h //
////////////////////

// From c:\kombin\lego2\footprnt




//////////////////
// FILE fig.cpp //
//////////////////

/* --- declare static functions -- */

static int cmp_pos4fig4qsort(const void*, const void*);
static void normalize_arr(const Pos4Fig *arr_in, Pos4Fig *arr_out, int n_brick);
static void shift_2_0_arr(Pos4Fig *arr, int n);
static void sort_arr     (Pos4Fig *arr, int n);


/* === Pos4Fig =========================================================== */

/* --- get_cpr --- */

DWORD Pos4Fig::get_cpr() const {
  FKT "Pos4Fig::get_cpr";

  if (!(-128<=x && x<128)) errstop(fkt, "x ausserhalb des gueltigen Bereiches");
  if (!(-128<=y && y<128)) errstop(fkt, "y ausserhalb des gueltigen Bereiches");
  if (!(-128<=z && z<128)) errstop(fkt, "z ausserhalb des gueltigen Bereiches");

  DWORD x_dw = DWORD(x+128);
  DWORD y_dw = DWORD(y+128);
  DWORD z_dw = DWORD(z+128);
  DWORD rotated_dw = DWORD(int(rotated));

  return x_dw | (y_dw<<8) | (z_dw<<16) | (rotated_dw<<24);
}

/* --- constructor(cpr) --- */

Pos4Fig::Pos4Fig(DWORD cpr) {
  FKT "Pos4Fig::Pos4Fig(DWORD)";

  DWORD x_dw       =  cpr      & DWORD(255);
  DWORD y_dw       = (cpr>> 8) & DWORD(255);
  DWORD z_dw       = (cpr>>16) & DWORD(255);
  DWORD rotated_dw = (cpr>>24) & DWORD(255);

  x = int(x_dw)-128;
  y = int(y_dw)-128;
  z = int(z_dw)-128;

  switch (int(rotated_dw)) {
    case 0: rotated=false; break;
    case 1: rotated=true ; break;
    default: errstop(fkt, "Invalid cpr");
  }
}

/* --- rot90 --- */

// Rotates the center of this position about PI/2 around the z axis

void Pos4Fig::rot90() {
  FKT "Pos4Fig::rot90";
  int x_center_dbl = (x<<1) + DIM_BRICK_X4ROTATED(rotated);
  int y_center_dbl = (y<<1) + DIM_BRICK_Y4ROTATED(rotated);

  int x_center_rot_dbl =-y_center_dbl;
  int y_center_rot_dbl = x_center_dbl;
  if (L_BRICK!=W_BRICK) rotated=!rotated;

  int x_rot_dbl=x_center_rot_dbl - DIM_BRICK_X4ROTATED(rotated);
  int y_rot_dbl=y_center_rot_dbl - DIM_BRICK_Y4ROTATED(rotated);

  if (x_rot_dbl&1 || y_rot_dbl&1) errstop(fkt, "x_rot_dbl&1 || y_rot_dbl&1");
  x = x_rot_dbl>>1;
  y = y_rot_dbl>>1;
}

/* --- cmp --- */

int cmp(const Pos4Fig &a, const Pos4Fig &b) {
  int res;

  if ((res=cmp_int(a.z, b.z))) return res;
  if ((res=cmp_int(a.y, b.y))) return res;
  if ((res=cmp_int(a.x, b.x))) return res;
  return cmp_rotated(a.rotated, b.rotated);
}

/* --- Pos4Fig!=Pos4Fig --- */

bool operator!=(const Pos4Fig &a, const Pos4Fig &b) {
  return (
    a.x != b.x ||
    a.y != b.y ||
    a.z != b.z ||
    (a.rotated != b.rotated && L_BRICK!=W_BRICK)
  );
}

/* --- hashind --- */

unsigned int Pos4Fig::hashind() const {
  return int(rotated && W_BRICK!=L_BRICK) | (x+17*y+177*z)<<1;
}

/* --- write --- */

bool Pos4Fig::write(Out &out) const {

  if (!out.printf(
    "$*$@($ $ $)",
    DIM_BRICK_X4ROTATED(rotated),
    DIM_BRICK_Y4ROTATED(rotated),
    x,y,z
  )) {
    return false;
  }

  return true;
}


/* === FigRot ============================================================ */

/* --- default constructor --- */

FigRot::FigRot() : n_brick(0) {}

/* --- constructor(cpr) --- */

FigRot::FigRot(const FigRotCpr &cpr, int p_n_brick)  : n_brick(p_n_brick) {
  FKT "FigRot::FigRot(FigRotCpr, int)";

  if (!(0<=n_brick && n_brick<=N_BRICK_MAX)) errstop_index(fkt);

  Pos4Fig l_arr_pos_brick[N_BRICK_MAX];
  int i_brick;
  for (i_brick=0; i_brick<n_brick; ++i_brick) {
    l_arr_pos_brick[i_brick] = Pos4Fig(cpr.arr_pos_brick_cpr[i_brick]);
  }

  normalize_arr(l_arr_pos_brick, arr_pos_brick, n_brick);
}

/* --- rot90 --- */

// Rotates this building about 90 degrees around the z-axis and normalizes coordinates

void FigRot::rot90() {
  int i_brick;

  for (i_brick=0; i_brick<n_brick; ++i_brick) arr_pos_brick[i_brick].rot90();
  shift_2_0_arr(arr_pos_brick, n_brick);
  sort_arr(arr_pos_brick, n_brick);
}

/* --- constructor --- */

FigRot::FigRot(Pos4Fig *p_arr_pos_brick, bool half, int p_n_brick) : n_brick(p_n_brick) {
  FKT "FigRot::FigRot(Pos4Fig*, int)";

  if (!(0<=n_brick && n_brick<=N_BRICK_MAX)) errstop_index(fkt);
  normalize_arr(p_arr_pos_brick, arr_pos_brick, n_brick);
  if (half) {
    int i_brick;
    for (i_brick=0; i_brick<n_brick; ++i_brick) {
      Pos4Fig &pos=arr_pos_brick[i_brick];
      if (pos.x&1) errstop(fkt, "pos.x odd"); 
      pos.x>>=1;
      if (pos.y&1) errstop(fkt, "pos.y odd"); 
      pos.y>>=1;
    }
  }
}

/* --- FigRot=FigRot --- */

void FigRot::operator=(const FigRot &fig_rot) {
  *const_cast<int*>(&n_brick) = fig_rot.n_brick;
  memcpy(arr_pos_brick, fig_rot.arr_pos_brick, n_brick*sizeof(Pos4Fig));
}

/* --- clear --- */

void FigRot::clear() {
  *const_cast<int*>(&n_brick) = 0;
}

/* --- write --- */

bool FigRot::write(Out &out) const {
  int i_brick;

  for (i_brick=0; i_brick<n_brick; ++i_brick) {
    if (i_brick>0) {
      if (!out.print_char(' ')) return false;
    }
    if (!arr_pos_brick[i_brick].write(out)) return false;
  }

  return true;
}

/* --- get_pos_brick --- */

const Pos4Fig& FigRot::get_pos_brick(int i_brick) const {
  FKT "FigRot::get_pos_brick";
  if (!(0<=i_brick && i_brick<n_brick)) errstop_index(fkt);
  return arr_pos_brick[i_brick];
}

/* --- hashind --- */

unsigned int FigRot::hashind() const {
  unsigned int res=0U;
  int i_brick;

  for (i_brick=0; i_brick<n_brick; ++i_brick) res = 61U*res + arr_pos_brick[i_brick].hashind();
  return res;
}

/* --- FigRot==FigRot --- */

bool operator==(const FigRot &a, const FigRot &b) {

  int n_brick = a.n_brick;
  if (n_brick!=b.n_brick) return false;

  int i_brick;
  for (i_brick=0; i_brick<n_brick; ++i_brick) {
    if (a.arr_pos_brick[i_brick]!=b.arr_pos_brick[i_brick]) return false;
  }
  return true;
}


/* === FigRotCpr ========================================================= */

FigRotCpr::FigRotCpr(const FigRot &fig) {
  int n_brick = fig.n_brick, i_brick;

  for (i_brick=0; i_brick<n_brick; ++i_brick) {
    arr_pos_brick_cpr[i_brick] = fig.arr_pos_brick[i_brick].get_cpr();
  }
}


/* === SetFigRotCpr ====================================================== */

/* --- constructor --- */

SetFigRotCpr::SetFigRotCpr(int p_n_brick) : n_brick(p_n_brick) {}

/* --- iterate --- */

bool SetFigRotCpr::iterate(Performer<FigRot> &performer) const {
  DecompressorFigRot decompressor(performer, n_brick);
  return Set<FigRotCpr>::iterate(decompressor);
}

/* --- insert --- */

void SetFigRotCpr::insert(const FigRot &fig_rot) {
  FigRotCpr cpr(fig_rot);
  Set<FigRotCpr>::insert(cpr);
}

/* --- equal --- */

bool SetFigRotCpr::equal(const FigRotCpr &a, const FigRotCpr &b) const {
  return memcmp(a.arr_pos_brick_cpr, b.arr_pos_brick_cpr, 4*n_brick)==0;
}

/* --- equal --- */

unsigned int SetFigRotCpr::hashind(const FigRotCpr &fig_rot) const {
  DWORD res=DWORD(0);
  int i_brick;
  for (i_brick=0; i_brick<n_brick; ++i_brick) {
    res=DWORD(17)*res + fig_rot.arr_pos_brick_cpr[i_brick];
  }
  return (unsigned int)res;
}


/* === DecompressorFigRot ================================================ */

/* --- constructor --- */

DecompressorFigRot::DecompressorFigRot(Performer<FigRot> &p_target, int p_n_brick) : target(p_target), n_brick(p_n_brick) {}

/* --- perform --- */

bool DecompressorFigRot::perform(const FigRotCpr &cpr) {
  FigRot fig(cpr, n_brick);
  return target.perform(fig);
}


/* === WriterFig ========================================================= */

/* --- constructor --- */

WriterFig::WriterFig(Out &p_out) : out(p_out) {}

/* --- perform --- */

bool WriterFig::perform(const FigRot &fig_rot) {
  if (!fig_rot.write(out)) return false;
  if (!out.print_char('\n')) return false;
  return true;
}


/* === exported functions ================================================ */

/* --- read(FigRot) --- */

bool read(InBuffered &in, int n_brick, FigRot &p_fig) {
  FKT "read(InBuffered, int, FigRot)";

  if (!(0<=n_brick && n_brick<=N_BRICK_MAX)) errstop_index(fkt);

  int i_brick;
  Pos4Fig arr_pos_brick[N_BRICK_MAX];
  for (i_brick=0; i_brick<n_brick; ++i_brick) {
    if (i_brick>0) {
      if (!in.read_char_given(' ')) return false;
    }

    if (!read(in, arr_pos_brick[i_brick])) return false;
  }

  p_fig=FigRot(arr_pos_brick, false, n_brick);
  return true;
}

/* --- read(Pos4Fig) --- */

bool read(InBuffered &in, Pos4Fig &pos4fig) {

  int dx,dy;
  const Card64 &pos_start=in.get_pos();
  if (!in.read_card      (dx )) return false;
  if (!in.read_char_given('*')) return false;
  if (!in.read_card      (dy )) return false;
  if (dx==L_BRICK && dy==W_BRICK) {
    pos4fig.rotated=false;
  } else if (dx==W_BRICK && dy==L_BRICK) {
    pos4fig.rotated=true;
  } else {
    return in.err_at("Ungueltige Ausdehnungsangabe", pos_start);
  }

  if (!in.read_char_given('@')) return false;
  if (!in.read_char_given('(')) return false;
  if (!in.read_int(pos4fig.x)) return false;
  if (!in.read_char_given(' ')) return false;
  if (!in.read_int(pos4fig.y)) return false;
  if (!in.read_char_given(' ')) return false;
  if (!in.read_int(pos4fig.z)) return false;
  if (!in.read_char_given(')')) return false;

  return true;
}


/* === static functions ================================================== */

/* --- normalize_arr --- */

static void normalize_arr(const Pos4Fig *arr_in, Pos4Fig *arr_out, int n_brick) {
  FKT "normalize_arr";

  int n_byte;
  if (!(0<=n_brick && n_brick<=N_BRICK_MAX)) errstop_index(fkt);
  n_byte = n_brick*sizeof(Pos4Fig);
  memcpy(arr_out, arr_in, n_byte);
  shift_2_0_arr(arr_out, n_brick);
  sort_arr(arr_out, n_brick);
}

/* --- cmp_pos4fig4qsort --- */

static int cmp_pos4fig4qsort(const void *ptr_a, const void *ptr_b) {
  return cmp(*(Pos4Fig*)ptr_a, *(Pos4Fig*)ptr_b);
}

/* --- shift_2_0_arr --- */

static void shift_2_0_arr(Pos4Fig *arr, int n) {
  if (n==0) return;

  int x_min=arr[0].x;
  int y_min=arr[0].y;
  int z_min=arr[0].z;
  int i;
  for (i=1; i<n; ++i) {
    const Pos4Fig &pos = arr[i];
    x_min = min_int(x_min, pos.x);
    y_min = min_int(y_min, pos.y);
    z_min = min_int(z_min, pos.z);
  }

  for (i=0; i<n; ++i) {
    Pos4Fig &pos = arr[i];
    pos.x-=x_min;
    pos.y-=y_min;
    pos.z-=z_min;
  }
}

/* --- sort_arr --- */

static void sort_arr(Pos4Fig *arr, int n) {
  qsort(arr, n, sizeof(Pos4Fig), &cmp_pos4fig4qsort);
}


////////////////
// FILE str.h //
////////////////

// From c:\consql



///////////////////////
// FILE fileutil.cpp //
///////////////////////

/* --- exported fields --- */

const Str sep_path("\\");


/* === exported functions ================================================= */

/* --- open_file_txt_write --- */

bool open_file_txt_write(Str filename, FILE *&f) {
  if (!open_file(filename, "wt", f)) return err(Str("Cannot open file ") + enquote(filename) + Str(" for write"));
  return true;
}

/* --- exists_file --- */

bool exists_file(Str filename) {
  char buff_fix[256], *buff;
  int l_filename=filename.get_l();

  buff = (l_filename>=(int)sizeof(buff_fix) ? new char[l_filename+1U] : buff_fix);
  filename.dump_nts(buff);
  
  FILE *f=fopen(buff, "rt");  
  bool exists;
  if (f==0) {
    exists=false;
  } else {
    exists=true;
    fclose(f);
  }
  
  if (buff!=buff_fix) delete[] buff;
  return exists;
}

/* --- remove_file --- */

bool remove_file(Str filename) {
  char buff_fix[256], *buff;
  int l_filename=filename.get_l();
  bool ok;

  buff = (l_filename>=(int)sizeof(buff_fix) ? new char[l_filename+1] : buff_fix);
  filename.dump_nts(buff);
  ok = (_unlink(buff)==0);
  if (buff!=buff_fix) delete[] buff;
  return ok;
}

/* --- open_file --- */

bool open_file(const Str &filename, const char *mode, FILE* &f) {
  char buff_fix[256], *buff;
  int l_filename=filename.get_l();

  buff = (l_filename>=(int)sizeof(buff_fix) ? new char[l_filename+1] : buff_fix);
  filename.dump_nts(buff);
  f=fopen(buff, mode);
  if (buff!=buff_fix) delete[] buff;
  if (f==0) return false;
  return true;
}




//////////////////////
// FILE filewnd.cpp //
//////////////////////

/* === FileWndBin ======================================================== */

/* --- constructor --- */

FileWndBin::FileWndBin(Str p_path, int p_size_wnd) : opened(false), size_wnd(p_size_wnd), path(p_path) {
  FKT "FileWndBin::FileWndBin";

  if (size_wnd<=0) errstop(fkt, "size_wnd<=0");
  block = new char[size_wnd];
  if (block==0) errstop_memoverflow(fkt);
}

/* --- close --- */

bool FileWndBin::close() {
  opened=false;
  return true;
}

/* --- at_end --- */

bool  FileWndBin::at_end() const {
  FKT "FileWndBin::at_end()";

  if (!opened) errstop(fkt, "!opened");
  return i_char4block==n_char4block;
}

/* --- ++InstreamFileBin --- */

bool FileWndBin::operator++() {
  FKT "FileWndBin::operator++()";

  if (!opened) errstop(fkt, "!opened");
  ++i_char4block;
  if (i_char4block<n_char4block) return true;
  if (block_last) return true;
  if (!fill_block()) return false;
  return true;
}

/* --- fill_block --- */

bool FileWndBin::fill_block() {

  FILE *f;
  if (!open_file(path, "rb", f)) return false;

  if (fseek(f, pos_block_next, SEEK_SET)) {
    fclose(f);
    return err("Cannot position within file \"%s\"");
  }

  int c=0;
  n_char4block=0;
  while (n_char4block<size_wnd && (c=getc(f))!=EOF) {
    block[n_char4block] = (char)(unsigned char)(unsigned int)c;
    ++n_char4block;
  }

  fclose(f);

  pos_block_next+=n_char4block;
  block_last = (c==EOF);
  i_char4block=0;
  return true;
}

/* --- *FileWndBin --- */

char FileWndBin::operator*() {
  FKT "FileWndBin::operator*()";

  if (!opened) errstop(fkt, "!opened");
  if (i_char4block==n_char4block) errstop(fkt, "Exceeded end of file");
  return block[i_char4block];
}


/* --- open --- */

bool FileWndBin::open() {
  FKT "FileWndBin::open";

  if (opened) errstop(fkt, "Beretis geoeffnet");

  pos_block_next=0;
  if (!fill_block()) return false;

  opened=true;
  return true;
}

/* --- destructor --- */

FileWndBin::~FileWndBin() {
  close();
  delete[] block;
}


/* === FileWndTxt ======================================================== */

/* --- constructor --- */

FileWndTxt::FileWndTxt(Str path, int size_wnd) : bin(path, size_wnd), pos(Card64::zero) {}

/* --- *FileWndTxt --- */

char FileWndTxt::operator*() {
  FKT "FileWndTxt::operator*";

  if (!is_opened()) errstop(fkt, "FileWndTxt nicht geoeffnet");

  if (*bin=='\r') {
    return '\n';
  } else {
    if (bin.at_end()) {
      errstop(fkt, "Exceeded end of file");
    }
    return *bin;
  }
}

/* --- get_pos --- */

const Card64& FileWndTxt::get_pos() const {
  return pos;
}

/* --- at_end --- */

bool FileWndTxt::at_end() const {
  return bin.at_end();
}

/* --- ++FileWndTxt --- */

bool FileWndTxt::operator++() {
  if (*bin=='\r') {
    if (!++bin) return false;
    if (!bin.at_end() && *bin=='\n') { // CR+LF => Nothing
      if (!++bin) return false;
    }
  } else {
    if (!++bin) return false;
  }

  ++pos;
  return true;
}

/* --- close --- */

bool FileWndTxt::close() {
  return bin.close();
}

/* --- err_at(pos) --- */

bool FileWndTxt::err_at(Str msg, Card64 pos) const {
  char buff[N_DIGIT4CARD64+1];
  Str txt;

  txt+="Error in file ";
  txt+=enquote(bin.path);
  txt+=", character ";
  txt+=to_nts(pos, buff, sizeof(buff));
  txt+=": ";
  txt+=msg;
  return err(txt);
}

/* --- open --- */

bool FileWndTxt::open() {
  if (!bin.open()) return false;
  return true;
}

/* --- err_at(LINE, COL) --- */

bool FileWndTxt::err_at(Str msg, int i_line, int i_col) const {
  Str txt;
  txt+="Error in file ";
  txt+=enquote(bin.path);
  txt+=", line ";
  txt+=str4card(i_line+1);
  txt+=", character ";
  txt+=str4card(i_col+1);
  txt+=": ";
  txt+=msg;
  return err(txt);
}

////////////////////
// FILE mapimpl.h //
////////////////////

// Taken fron lego4


//////////////////
// FILE fun.cpp //
//////////////////

// #include "cnpos.h"

/* --- static functions --- */

static int get_i_prm_first(const FunArrPosPartial2Dword&);
static int get_n_prm      (const FunArrPosPartial2Dword&);
static PtFunArrPosPartial2Dword create_fun_n_sol4graph_rek(const Graph&, const bool *arr_rotated, const int *arr_status_var, char dir, MapFunCached &map_fun_cached, bool with_cache);
static void get_arr_comp_conn(const Graph&, const int *arr_status_var, int *arr, int &n);
static void set_comp_conn4brick(const Graph&, const int *arr_status_var, int *arr, int i_brick, int i_conn_comp);
static int get_extend_max(char dir, int status_var, bool rotated);


/* === ArrStatusVarRotated =============================================== */

/* --- default constructor --- */

ArrStatusVarRotated::ArrStatusVarRotated() {}

/* --- constructor --- */

ArrStatusVarRotated::ArrStatusVarRotated(const int *p_arr_status_var, const bool *arr_rotated, int n_var, char dir) {
  FKT "ArrStatusVarRotated::ArrStatusVarRotated(int*, bool*, int, char)";
  if (!(0<=n_var && n_var<=N_VAR_MAX)) errstop(fkt, "n_var out of range");

  memcpy(arr_status_var, p_arr_status_var, sizeof(int)*n_var);

  int i_var;
  for (i_var=0; i_var<n_var; ++i_var) {
    bool rotated = arr_rotated[i_var];
    arr_extend[i_var] = (dir=='x' ? DIM_BRICK_X4ROTATED(rotated) : DIM_BRICK_Y4ROTATED(rotated));
  }
}


/* === MapFunCached ====================================================== */

/* --- constructor --- */

MapFunCached::MapFunCached(int p_n_var) : n_var(p_n_var) {}

/* --- equal --- */

bool MapFunCached::equal(const ArrStatusVarRotated &a, const ArrStatusVarRotated &b) const {
  int i_var;

  for (i_var=0; i_var<n_var; ++i_var) {
    int status=a.arr_status_var[i_var];
    if (status!=b.arr_status_var[i_var]) return false;
    if (status!=STATUS_VAR_UNUSED && a.arr_extend[i_var]!=b.arr_extend[i_var]) return false;
  }

  return true;
}

/* --- hashind --- */

unsigned int MapFunCached::hashind(const ArrStatusVarRotated &a) const {
  int i_var, status;
  unsigned int res=0U;

  for (i_var=0; i_var<n_var; ++i_var) {
    status = a.arr_status_var[i_var];
    res=3U*res+status;
    if (status!=STATUS_VAR_UNUSED) {
      res=11U*res+a.arr_extend[i_var];
    }
  }

  return res;
}


/* === FunArrPosPartial2Dword ============================================ */

/* --- constructor --- */

FunArrPosPartial2Dword::FunArrPosPartial2Dword(int p_n_var) : n_var(p_n_var) {}

/* --- get_size_cache --- */

double FunArrPosPartial2Dword::get_size_cache() const {
  Lst<double> lst;
  int i,n;
  double sum=0.0;

  append_lst_size_cache(lst);
  n=lst.get_n();
  for (i=0; i<n; ++i) sum+=lst.get(i);
  return sum;
}

/* --- destructor --- */

FunArrPosPartial2Dword::~FunArrPosPartial2Dword() {}

/* === FunArrPosPartial2DwordProd ======================================== */

/* --- constructor --- */

FunArrPosPartial2DwordProd::FunArrPosPartial2DwordProd(
  const PtFunArrPosPartial2Dword &p_pt_fun_a,
  const PtFunArrPosPartial2Dword &p_pt_fun_b
) :
  FunArrPosPartial2Dword(p_pt_fun_a->n_var),
  pt_fun_a(p_pt_fun_a),
  pt_fun_b(p_pt_fun_b),
  fun_a(*p_pt_fun_a),
  fun_b(*p_pt_fun_b)
{ FKT "FunArrPosPartial2DwordProd::FunArrPosPartial2DwordProd";

  int i_var;
  for (i_var=0; i_var<n_var; ++i_var) {
    int &status = arr_status_var[i_var];
    int status_a = fun_a.get_status_var(i_var);
    int status_b = fun_b.get_status_var(i_var);
    if (status_a==status_b) {
       status=status_a;
    } else if (status_a==STATUS_VAR_UNUSED) {
       status=status_b;
    } else if (status_b==STATUS_VAR_UNUSED) {
       status=status_a;
    } else {
      errstop(fkt, "Variablen-Status der Faktoren inkompatibel");
    }
  }
}

/* --- get_status_var --- */

int FunArrPosPartial2DwordProd::get_status_var(int i_var) const {
  return fun_a.get_status_var(i_var);
}

/* --- eval --- */

DWORD FunArrPosPartial2DwordProd::eval(int *arr_koor) const {
  return fun_a.eval(arr_koor) * fun_b.eval(arr_koor);
}

/* --- append_lst_size_cache --- */

void FunArrPosPartial2DwordProd::append_lst_size_cache(Lst<double> &lst) const {
  fun_a.append_lst_size_cache(lst);
  fun_b.append_lst_size_cache(lst);
}


/* === FunArrPosPartial2DwordAddPrm ====================================== */

/* --- eval --- */

DWORD FunArrPosPartial2DwordAddPrm::eval(int *arr_koor) const {
  return fun.eval(arr_koor);
}

/* --- append_lst_size_cache --- */

void FunArrPosPartial2DwordAddPrm::append_lst_size_cache(Lst<double> &lst) const {
  fun.append_lst_size_cache(lst);
}

/* --- get_status_var --- */

int FunArrPosPartial2DwordAddPrm::get_status_var(int i_var) const {
  FKT "FunArrPosPartial2DwordAddPrm::get_status_var";
  if (!(0<=i_var && i_var<n_var)) errstop_index(fkt);
  return arr_status_var[i_var];
}

/* --- constructor --- */

// Some unused variables of <*p_pt_fun> get parameters,
// If <p_arr_status_var[i]> is <STATUS_VAR_PRM>, then the <i>-th variable becomes a parameter.

FunArrPosPartial2DwordAddPrm::FunArrPosPartial2DwordAddPrm(const int *p_arr_status_var, const PtFunArrPosPartial2Dword &p_pt_fun) :
  FunArrPosPartial2Dword(p_pt_fun->n_var),
  pt_fun(p_pt_fun),
  fun(*p_pt_fun)
{ FKT "FunArrPosPartial2DwordAddPrm::FunArrPosPartial2DwordAddPrm";
  FunArrPosPartial2Dword &fun=*pt_fun;
  int i_var;

  for (i_var=0; i_var<n_var; ++i_var) {
    int &status_var = arr_status_var[i_var], status_p = p_arr_status_var[i_var], status_fun=fun.get_status_var(i_var);
    if (status_p==STATUS_VAR_PRM) {
      if (status_fun==STATUS_VAR_FREE) {
        errstop(fkt, "Kann freie Variablen nicht als Parameter umdeklarieren");
      }
      status_var = status_p;
    } else {
      status_var = status_fun;
    }
  }
}


/* === FunArrPosPartial2DwordCached ====================================== */

/* --- dim_cache --- */

void FunArrPosPartial2DwordCached::dim_cache() {
  FKT "FunArrPosPartial2DwordCached::dim_cache_rek";

  // fun.dim_cache_rek(arr_size, arr_used, n_size);

  if (!pt_cache.is_null()) return;

  // Squeeze => No cache needed
  int i_var;
  for (i_var=0; i_var<n_var; ++i_var) {
    if (fun.get_status_var(i_var)==STATUS_VAR_PRM && arr_lb[i_var]>arr_ub[i_var]) return;
  }

  bool arr_is_prm[N_BRICK_MAX];
  for (i_var=0; i_var<n_var; ++i_var) {
    arr_is_prm[i_var] = fun.get_status_var(i_var)==STATUS_VAR_PRM;
  }

  CacheDword4Bound *pt_cache_native = new CacheDword4Bound(arr_lb, arr_ub, arr_is_prm, n_var);
  if (pt_cache_native==0) errstop_memoverflow(fkt);
  pt_cache=pt_cache_native;
  pt_cache_native->set_all(~DWORD(0));
}

/* --- get_status_var --- */

int FunArrPosPartial2DwordCached::get_status_var(int i_var) const {
  return fun.get_status_var(i_var);
}

/* --- eval --- */

DWORD FunArrPosPartial2DwordCached::eval(int *arr_koor) const {

  // Out of bounds => 0
  int i_var, koor_first=arr_koor[i_prm_first];
  for (i_var=0; i_var<n_var; ++i_var) {
    if (arr_is_prm4var[i_var]) {
      int koor = arr_koor[i_var]-koor_first;
      if (!(arr_lb[i_var]<=koor && koor<=arr_ub[i_var])) {
        return DWORD(0);
      }
    }
  }

  // No cache ?
  if (pt_cache.is_null()) {
    return fun.eval(arr_koor);
  }

  // Cache query
  DWORD &ref = pt_cache->get_ref(arr_koor);
  if (~ref) {
    return ref;
  }

  // Compute and return result
  ref = fun.eval(arr_koor);
  return ref;
}

/* --- set_ub_rek --- */

void FunArrPosPartial2DwordCached::set_ub_rek(int i_var, int p_ub, bool *arr_set, const Graph &graph, const bool *arr_rotated) {

  bool &set=arr_set[i_var];
  int &ub = arr_ub[i_var];
  if (set && ub<=p_ub) return;

  set=true;
  ub=p_ub;

  bool rotated = arr_rotated[i_var];
  int status_var = fun.get_status_var(i_var);
  int j_var, ub_linked = p_ub + get_extend_max(dir, status_var, rotated) - 1; // (dir=='x' ? DIM_BRICK_X4ROTATED(rotated) : DIM_BRICK_Y4ROTATED(rotated))-1;
  for (j_var=0; j_var<n_var; ++j_var) if (i_var!=j_var && graph.is_linked(i_var, j_var)) {
    set_ub_rek(j_var, ub_linked, arr_set, graph, arr_rotated);
  }
}

/* --- set_lb_rek --- */

void FunArrPosPartial2DwordCached::set_lb_rek(int i_var, int p_lb, bool *arr_set, const Graph &graph, const bool *arr_rotated) {

  bool &set=arr_set[i_var];
  int &lb = arr_lb[i_var];
  if (set && lb>=p_lb) return;

  set=true;
  lb=p_lb;

  int j_var;
  for (j_var=0; j_var<n_var; ++j_var) if (i_var!=j_var && graph.is_linked(i_var, j_var)) {
    // bool rotated = arr_rotated[j_var];
    int lb_linked = p_lb - get_extend_max(dir, fun.get_status_var(j_var), arr_rotated[j_var]) + 1; // (dir=='x' ? DIM_BRICK_X4ROTATED(rotated) : DIM_BRICK_Y4ROTATED(rotated)) + 1;
    set_lb_rek(j_var, lb_linked, arr_set, graph, arr_rotated);
  }
}

/* --- constructor --- */

FunArrPosPartial2DwordCached::FunArrPosPartial2DwordCached(
  const Graph &graph,
  const bool *arr_rotated,
  const PtFunArrPosPartial2Dword &p_pt_fun,
  char p_dir
) :
  FunArrPosPartial2Dword(graph.n_brick),
  pt_fun(p_pt_fun),
  fun(*p_pt_fun),
  n_prm      (get_n_prm      (*p_pt_fun)),
  i_prm_first(get_i_prm_first(*p_pt_fun)),
  dir(p_dir)
{

  // Compute <arr_ub>, <arr_lb>
  bool arr_set[N_BRICK_MAX];
  set(arr_set, n_var, false); set_ub_rek(i_prm_first, 0, arr_set, graph, arr_rotated);
  set(arr_set, n_var, false); set_lb_rek(i_prm_first, 0, arr_set, graph, arr_rotated);

  // Compute cache size
  int i_var;
  for (i_var=0; i_var<n_var; ++i_var) arr_is_prm4var[i_var] = fun.get_status_var(i_var)==STATUS_VAR_PRM;
  size_cache = CacheDword4Bound::get_size(arr_lb, arr_ub, arr_is_prm4var, n_var);

  /*
  printf("size_cache(");
  for (i_var=0; i_var<n_var; ++i_var) {
    if (i_var) printf(", ");
    if (arr_is_prm4var[i_var]) {
      printf("%d..%d", arr_lb[i_var], arr_ub[i_var]);
    } else {
      printf("*");
    }
  }
  printf(")=%e\n", size_cache);*/
}

/* --- append_lst_size_cache --- */

void FunArrPosPartial2DwordCached::append_lst_size_cache(Lst<double> &lst) const {
  fun.append_lst_size_cache(lst);
  lst.append(size_cache);
}



/* === FunArrPosPartial2DwordSumOverVar ==================================== */

/* --- constructor --- */

FunArrPosPartial2DwordSumOverVar::FunArrPosPartial2DwordSumOverVar(int p_i_var, const PtFunArrPosPartial2Dword &p_pt_fun, const Graph &graph, const bool *arr_rotated, char dir) :
  FunArrPosPartial2Dword(p_pt_fun->n_var),
  i_var(p_i_var),
  pt_fun(p_pt_fun),
  fun(*p_pt_fun)
{ FKT "FunArrPosPartial2DwordSumOverVar::FunArrPosPartial2DwordSumOverVar";

  if (!(0<=i_var && i_var<n_var)) errstop_index(fkt);

  int j_var;
  bool rotated_i = arr_rotated[i_var];
  n_prm=0;
  for (j_var=0; j_var<n_var; ++j_var) {
    if (get_status_var(j_var)==STATUS_VAR_PRM && i_var!=j_var && graph.is_linked(i_var, j_var)) {
      bool rotated_j = arr_rotated[j_var];
      arr_lb_shift4prm[n_prm] =  1-(dir=='x' ? DIM_BRICK_X4ROTATED(rotated_i) : DIM_BRICK_Y4ROTATED(rotated_i));
      arr_ub_shift4prm[n_prm] = -1+(dir=='x' ? DIM_BRICK_X4ROTATED(rotated_j) : DIM_BRICK_Y4ROTATED(rotated_j));
      arr_i_var4prm[n_prm]=j_var;
      ++n_prm;
    }
  }
}

/* --- eval --- */

DWORD FunArrPosPartial2DwordSumOverVar::eval(int *arr_var) const {
  FKT "FunArrPosPartial2DwordSumOverVar::eval";

  int i_prm, lb,ub=0;
  bool set_b=false;
  for (i_prm=0; i_prm<n_prm; ++i_prm) {
    int i_var4prm = arr_i_var4prm[i_prm];
    int prm = arr_var[i_var4prm];
    int lb_prm = prm+arr_lb_shift4prm[i_prm];
    int ub_prm = prm+arr_ub_shift4prm[i_prm];

    if (set_b) {
      lb=max_int(lb, lb_prm);
      ub=min_int(ub, ub_prm);
    } else {
      lb=lb_prm;
      ub=ub_prm;
      set_b=true;
    }
  }

  if (!set_b) errstop(fkt, "!set_b");

  int &var=arr_var[i_var];
  DWORD sum=DWORD(0);
  for (var=lb; var<=ub; ++var) {
    sum+=fun.eval(arr_var);
  }

  return sum;
}

/* --- append_lst_size_cache --- */

void FunArrPosPartial2DwordSumOverVar::append_lst_size_cache(Lst<double> &lst) const {
  fun.append_lst_size_cache(lst);
}

/* --- get_status_var --- */

int FunArrPosPartial2DwordSumOverVar::get_status_var(int p_i_var) const {
  return p_i_var==i_var ? STATUS_VAR_FREE : fun.get_status_var(p_i_var);
}


/* === FunArrPosPartial2Dword1 ============================================= */

/* --- constructor --- */

FunArrPosPartial2Dword1::FunArrPosPartial2Dword1(const int *p_arr_status_var, int n_var) : FunArrPosPartial2Dword(n_var) {
  memcpy(arr_status_var, p_arr_status_var, sizeof(int)*n_var);
}

/* --- append_lst_size_cache --- */

void FunArrPosPartial2Dword1::append_lst_size_cache(Lst<double> &lst) const {}

/* --- eval --- */

DWORD FunArrPosPartial2Dword1::eval(int *arr_koor) const {
  return DWORD(1);
}

/* --- get_status_var --- */

FunArrPosPartial2Dword1::get_status_var(int i_var) const {
  FKT "FunArrPosPartial2Dword1::get_status_var";

  if (!(0<=i_var && i_var<n_var)) errstop_index(fkt);
  return arr_status_var[i_var];
}


/* === FunCachedArrDelta2Dword =========================================== */

/* --- destructor --- */

FunCachedArrDelta2Dword::~FunCachedArrDelta2Dword() {
  delete[] data_cache;
}

/* --- constructor --- */

FunCachedArrDelta2Dword::FunCachedArrDelta2Dword(
  const int *p_arr_i_delta4depend_on, const int *p_arr_lb4depend_on, const int *arr_ub4depend_on, int p_n_depend_on,
  PtFunArrDelta2Dword p_pt_cached
) :
  pt_cached(p_pt_cached),
  cached(*p_pt_cached),
  n_depend_on(p_n_depend_on)
{
  FKT "FunCachedArrDelta2Dword::FunCachedArrDelta2Dword";

  // Copy <arr_lb4depend_on> and <arr_i_delta4depend_on>
  int n_byte = sizeof(int)*n_depend_on;
  memcpy(arr_lb4depend_on     , p_arr_lb4depend_on     , n_byte);
  memcpy(arr_i_delta4depend_on, p_arr_i_delta4depend_on, n_byte);

  // Set up <arr_l>
  int i_depend_on;
  for (i_depend_on=0; i_depend_on<n_depend_on; ++i_depend_on) {
    arr_l[i_depend_on] = 1+arr_ub4depend_on[i_depend_on]-p_arr_lb4depend_on[i_depend_on];
  }

  // Compute numer ob elements in the cache
  int size=1;
  for (i_depend_on=0; i_depend_on<n_depend_on; ++i_depend_on) {
    int l = 1+arr_ub4depend_on[i_depend_on]-p_arr_lb4depend_on[i_depend_on];
    int size_bak=size;

    size*=l;
    if (size<0 || size/l!=size_bak) errstop(fkt, "Cache-Dimensionen zu gross");
  }

  // Allocate cache
  data_cache = new DWORD[size];
  if (data_cache==0) errstop_memoverflow(fkt);

  // Initialize cache
  int i;
  for (i=0; i<size; ++i) data_cache[i]=~DWORD(0);
}

/* --- eval --- */

DWORD FunCachedArrDelta2Dword::eval(int *arr_delta) const {
  FKT "FunCachedArrDelta2Dword::eval";

  int fac=1, i_elem=0, i_depend_on;
  for (i_depend_on=0; i_depend_on<n_depend_on; ++i_depend_on) {
    int delta0 = arr_delta[arr_i_delta4depend_on[i_depend_on]] - arr_lb4depend_on[i_depend_on];
    int l = arr_l[i_depend_on];

    if (!(0<=delta0 && delta0<l)) errstop_index(fkt);
    i_elem+=delta0*fac;

    fac*=l;
  }

  DWORD &elem = data_cache[i_elem];
  if (~elem) return elem; // elem is set

  DWORD res = cached.eval(arr_delta);
  elem = res;

  return res;
}


/* === FunArrRotated2FunCachedArrDelta2Dword ============================= */

/* --- constructor --- */

FunArrRotated2FunCachedArrDelta2Dword::FunArrRotated2FunCachedArrDelta2Dword(int p_arr_i_brick_pred[N_BRICK_MAX], const PtFunArrRotated2FunArrDelta2Dword &p_pt_cached) :
  FunArrRotated2FunArrDelta2Dword(p_pt_cached->n_delta),
  pt_cached(p_pt_cached)
{
  memcpy(arr_i_brick_pred, p_arr_i_brick_pred, sizeof(int)*n_delta);
}

/* --- depends_on --- */

bool FunArrRotated2FunCachedArrDelta2Dword::depends_on(int i_delta) const {
  return pt_cached->depends_on(i_delta);
}

/* --- eval --- */

PtFunArrDelta2Dword FunArrRotated2FunCachedArrDelta2Dword::eval(char dir, const bool *arr_rotated) const {
  FKT "FunArrRotated2FunCachedArrDelta2Dword::eval";
  FunArrRotated2FunArrDelta2Dword &cached=*pt_cached;
  int n_depend_on=0, arr_i_delta4depend_on[N_BRICK_MAX], arr_lb4depend_on[N_BRICK_MAX], arr_ub4depend_on[N_BRICK_MAX], i_delta;

  for (i_delta=1; i_delta<n_delta; ++i_delta) {
    if (cached.depends_on(i_delta)) {

      arr_i_delta4depend_on[n_depend_on] = i_delta;

      int i_brick = i_delta;
      int i_brick_pred = arr_i_brick_pred[i_brick];
      int &lb = arr_lb4depend_on[n_depend_on];
      int &ub = arr_ub4depend_on[n_depend_on];
      switch (dir) {
        case 'x':
        lb = -(DIM_BRICK_X4ROTATED(arr_rotated[i_brick     ])-1);
        ub =  (DIM_BRICK_X4ROTATED(arr_rotated[i_brick_pred])-1);
        break;

        case 'y':
        lb = -(DIM_BRICK_Y4ROTATED(arr_rotated[i_brick     ])-1);
        ub =  (DIM_BRICK_Y4ROTATED(arr_rotated[i_brick_pred])-1);
        break;

        default: errstop(fkt, "Ungueltiges dir");
      }

      ++n_depend_on;
    }
  }

  return new FunCachedArrDelta2Dword(arr_i_delta4depend_on, arr_lb4depend_on, arr_ub4depend_on, n_depend_on, cached.eval(dir, arr_rotated));
}


/* === FunArrRotated2FunArrDelta2Dword =================================== */

/* --- contructor --- */

FunArrRotated2FunArrDelta2Dword::FunArrRotated2FunArrDelta2Dword(int p_n_delta) : n_delta(p_n_delta) {}

/* --- destructor --- */

FunArrRotated2FunArrDelta2Dword::~FunArrRotated2FunArrDelta2Dword() {}


/* === FunArrDelta2Dword1 ================================================ */

/* --- eval --- */

DWORD FunArrDelta2Dword1::eval(int *arr_delta) const {
  return DWORD(1);
}


/* === FunArrRotated2FunArrDelta2Dword1 ================================== */

/* --- constructor --- */

FunArrRotated2FunArrDelta2Dword1::FunArrRotated2FunArrDelta2Dword1(int n_delta) : FunArrRotated2FunArrDelta2Dword(n_delta) {}

/* --- eval --- */

PtFunArrDelta2Dword FunArrRotated2FunArrDelta2Dword1::eval(char dir, const bool *arr_rotated) const {
  return new FunArrDelta2Dword1();
}

/* --- depends_on --- */

bool FunArrRotated2FunArrDelta2Dword1::depends_on(int i_brick) const {
  return false;
}


/* === FunSumArrDelta2Dword ============================================== */

/* --- constructor --- */

FunSumArrDelta2Dword::FunSumArrDelta2Dword(int p_i_delta, int p_lb, int p_ub, const PtFunArrDelta2Dword &p_pt_summed) :
  ub       ( p_ub       ),
  lb       ( p_lb       ),
  i_delta  ( p_i_delta  ),
  pt_summed( p_pt_summed),
  summed   (*p_pt_summed)
{}

/* --- eval --- */

DWORD FunSumArrDelta2Dword::eval(int *arr_delta) const {
  int &delta = arr_delta[i_delta];
  DWORD sum=DWORD(0);

  for (delta=lb; delta<=ub; ++delta) {
    sum+=summed.eval(arr_delta);
  }

  return sum;
}


/* === FunArrDelta2Dword ================================================= */

/* --- destructor --- */

FunArrDelta2Dword::~FunArrDelta2Dword() {}


/* === FunArrRotated2FunSumArrDelta2Dword ================================ */

/* --- constructor --- */

FunArrRotated2FunSumArrDelta2Dword::FunArrRotated2FunSumArrDelta2Dword(int p_i_brick_pred, int p_i_brick, const PtFunArrRotated2FunArrDelta2Dword &p_pt_summed) :
  FunArrRotated2FunArrDelta2Dword(p_pt_summed->n_delta),
  i_brick_pred(p_i_brick_pred),
  i_brick     (p_i_brick     ),
  pt_summed   (p_pt_summed   )
{}

/* --- depends_on --- */

bool FunArrRotated2FunSumArrDelta2Dword::depends_on(int i_delta) const {
  return i_delta!=i_brick && pt_summed->depends_on(i_delta);
}

/* --- eval --- */

PtFunArrDelta2Dword FunArrRotated2FunSumArrDelta2Dword::eval(char dir, const bool *arr_rotated) const {
  FKT "FunArrRotated2FunSumArrDelta2Dword::eval";
  int lb=0,ub=0;

  switch (dir) {
    case 'x':
    lb = -(DIM_BRICK_X4ROTATED(arr_rotated[i_brick     ])-1);
    ub =  (DIM_BRICK_X4ROTATED(arr_rotated[i_brick_pred])-1);
    break;

    case 'y':
    lb = -(DIM_BRICK_Y4ROTATED(arr_rotated[i_brick     ])-1);
    ub =  (DIM_BRICK_Y4ROTATED(arr_rotated[i_brick_pred])-1);
    break;

    default: errstop(fkt, "Ungueltiges dir");
  }

  return new FunSumArrDelta2Dword(i_brick, lb, ub, pt_summed->eval(dir, arr_rotated));
}

/* === FunCheckRangeArrDelta2Dword ======================================= */

/* --- constructor --- */

FunCheckRangeArrDelta2Dword::FunCheckRangeArrDelta2Dword(
  const int *p_arr_i_delta, const int *p_arr_fac4i_delta, int p_n_i_delta,
  int p_lb, int p_ub,
  const PtFunArrDelta2Dword &p_pt_checked
) :
  n_i_delta ( p_n_i_delta ),
  ub        ( p_ub        ),
  lb        ( p_lb        ),
  pt_checked( p_pt_checked),
  checked   (*p_pt_checked)
{ FKT "FunCheckRangeArrDelta2Dword::FunCheckRangeArrDelta2Dword";

  if (!(0<=n_i_delta && n_i_delta<N_BRICK_MAX)) errstop_index(fkt);
  memcpy(arr_i_delta    , p_arr_i_delta    , n_i_delta*sizeof(int));
  memcpy(arr_fac4i_delta, p_arr_fac4i_delta, n_i_delta*sizeof(int));
}

/* --- eval --- */

DWORD FunCheckRangeArrDelta2Dword::eval(int *arr_delta) const {

  int sum=0, i_i_delta;
  for (i_i_delta=0; i_i_delta<n_i_delta; ++i_i_delta) {
    sum += arr_fac4i_delta[i_i_delta] * arr_delta[arr_i_delta[i_i_delta]];
  }

  if (lb<=sum && sum<=ub) {
    return checked.eval(arr_delta);
  } else {
    return DWORD(0);
  }
}


/* === FunArrRotated2FunCheckRangeArrDelta2Dword ========================= */

/* --- constructor --- */

FunArrRotated2FunCheckRangeArrDelta2Dword::FunArrRotated2FunCheckRangeArrDelta2Dword(
  const int *p_arr_fac4delta,
  int p_i_brick_pred, int p_i_brick,
  PtFunArrRotated2FunArrDelta2Dword p_pt_checked
) :
  FunArrRotated2FunArrDelta2Dword(p_pt_checked->n_delta),
  i_brick_pred(p_i_brick_pred),
  i_brick     (p_i_brick     ),
  pt_checked  (p_pt_checked  )
{
  memcpy(arr_fac4delta, p_arr_fac4delta, sizeof(int)*n_delta);

  int i_delta;
  n_i_delta=0;
  for (i_delta=1; i_delta<n_delta; ++i_delta) {
    int fac = arr_fac4delta[i_delta];
    if (fac) {
      arr_i_delta    [n_i_delta] = i_delta;
      arr_fac4i_delta[n_i_delta] = fac    ;
      ++n_i_delta;
    }
  }
}

/* --- depends_on --- */

bool FunArrRotated2FunCheckRangeArrDelta2Dword::depends_on(int i_delta) const {
  FKT "FunArrRotated2FunCheckRangeArrDelta2Dword::depends_on";

  if (!(0<=i_delta && i_delta<n_delta)) errstop_index(fkt);
  return arr_fac4delta[i_delta]!=0 || pt_checked->depends_on(i_delta);
}

/* --- eval --- */

PtFunArrDelta2Dword FunArrRotated2FunCheckRangeArrDelta2Dword::eval(char dir, const bool *arr_rotated) const {
  FKT "FunArrRotated2FunCheckRangeArrDelta2Dword::eval";
  int lb=0,ub=0;

  switch (dir) {
    case 'x':
    lb = -(DIM_BRICK_X4ROTATED(arr_rotated[i_brick     ])-1);
    ub =  (DIM_BRICK_X4ROTATED(arr_rotated[i_brick_pred])-1);
    break;

    case 'y':
    lb = -(DIM_BRICK_Y4ROTATED(arr_rotated[i_brick     ])-1);
    ub =  (DIM_BRICK_Y4ROTATED(arr_rotated[i_brick_pred])-1);
    break;

    default: errstop(fkt, "Ungueltiges dir");
  }

  return new FunCheckRangeArrDelta2Dword(arr_i_delta, arr_fac4i_delta, n_i_delta, lb, ub, pt_checked->eval(dir, arr_rotated));
}


/* === exported functions ================================================ */

/* --- create_fun_n_sol4graph --- */

PtFunArrPosPartial2Dword create_fun_n_sol4graph(int i_brick_start, const Graph &graph, const bool *arr_rotated, char dir, MapFunCached &map_fun_cached) {

  int n_var=graph.n_brick, arr_status_var[N_BRICK_MAX], i_var;
  arr_status_var[0] = STATUS_VAR_PRM;
  for (i_var=1; i_var<n_var; ++i_var) {
    arr_status_var[i_var] = STATUS_VAR_FREE;
  }

  return create_fun_n_sol4graph_rek(graph, arr_rotated, arr_status_var, dir, map_fun_cached, false);
}


/* === static functions ================================================== */

/* --- get_i_prm_first --- */

static int get_i_prm_first(const FunArrPosPartial2Dword &fun) {
  FKT "get_i_prm_first";
  int n_var=fun.n_var, i_var;

  for (i_var=0; i_var<n_var; ++i_var) {
    if (fun.get_status_var(i_var)==STATUS_VAR_PRM) {
      return i_var;
    }
  }

  errstop(fkt, "Keine Parameter");
  return 0;
}

/* --- get_n_prm --- */

static int get_n_prm(const FunArrPosPartial2Dword &fun) {
  int n_var=fun.n_var, i_var, n_prm=0;

  for (i_var=0; i_var<n_var; ++i_var) {
    if (fun.get_status_var(i_var)==STATUS_VAR_PRM) {
      ++n_prm;
    }
  }

  return n_prm;
}

/* --- create_fun_n_sol4graph_rek --- */

static PtFunArrPosPartial2Dword create_fun_n_sol4graph_rek(const Graph &graph, const bool *arr_rotated, const int *arr_status_var, char dir, MapFunCached &map_fun_cached, bool with_cache) {
  FKT "create_fun_n_sol4graph_rek";

  // Query the map
  PtFunArrPosPartial2Dword pt_fun;
  int n_var = graph.n_brick;
  ArrStatusVarRotated key(arr_status_var, arr_rotated, n_var, dir);
  if (with_cache) {
    PtFunArrPosPartial2DwordCached pt_fun_cached;
    if (map_fun_cached.query(key, pt_fun_cached)) {
      convert(pt_fun_cached, pt_fun);

      // char data[2*N_VAR_MAX+2];
      // int i_var;
      // for (i_var=0; i_var<n_var; ++i_var) data[i_var] = char(key.arr_status_var[i_var]+int('0'));
      // data[n_var]=' ';
      // for (i_var=0; i_var<n_var; ++i_var) data[n_var+1+i_var] = char(key.arr_extend[i_var]+int('0'));
      // data[2*n_var+1]='\0';
      // printf("Cache hit: %s\n", data);

      return pt_fun;
    }
  }

  int n_comp_conn, arr_i_comp_conn4i_brick[N_BRICK_MAX];
  get_arr_comp_conn(graph, arr_status_var, arr_i_comp_conn4i_brick, n_comp_conn);

  if (n_comp_conn==0) return new FunArrPosPartial2Dword1(arr_status_var, n_var);

  int i_comp_conn, i_var;
  for (i_comp_conn=0; i_comp_conn<n_comp_conn; ++i_comp_conn) {

    // Compute the variable status for the i_comp_conn-th connected component
    int arr_status_var4comp_conn[N_BRICK_MAX];
    for (i_var=0; i_var<n_var; ++i_var) {
      int &status_var4comp_conn = arr_status_var4comp_conn[i_var];
      switch (arr_status_var[i_var]) {
        case STATUS_VAR_UNUSED: status_var4comp_conn=STATUS_VAR_UNUSED; break;
        case STATUS_VAR_PRM: status_var4comp_conn=STATUS_VAR_UNUSED; break;
        case STATUS_VAR_FREE: {

          status_var4comp_conn=STATUS_VAR_UNUSED;

          // Wrong component => variable is not used
          if (arr_i_comp_conn4i_brick[i_var]!=i_comp_conn) break;

          status_var4comp_conn=STATUS_VAR_FREE;

          // If neighbored to a current parameter, it will become a parameter
          int j_var;
          for (j_var=0; j_var<n_var; ++j_var) if (j_var!=i_var) {
            if (arr_status_var[j_var]==STATUS_VAR_PRM && graph.is_linked(i_var, j_var)) {
              status_var4comp_conn=STATUS_VAR_PRM;
              break;
            }
          }
          break;
        }
        default: errstop(fkt, "Ungueltiger Variablenstatus");
      } // switch
    } // for (i_var)

    // Compute solution counter for i_comp_conn-th component
    PtFunArrPosPartial2Dword pt_fun4comp_conn = create_fun_n_sol4graph_rek(graph, arr_rotated, arr_status_var4comp_conn, dir, map_fun_cached, true);

    // Extend parameters
    pt_fun4comp_conn = new FunArrPosPartial2DwordAddPrm(arr_status_var, pt_fun4comp_conn);

    // Wrap <pt_fun4comp_conn> into functions with sum up over the parameter of the connected component
    PtFunArrPosPartial2Dword pt_fun_sum = pt_fun4comp_conn;
    for (i_var=0; i_var<n_var; ++i_var) {
      if (arr_status_var4comp_conn[i_var]==STATUS_VAR_PRM) {
        pt_fun_sum = new FunArrPosPartial2DwordSumOverVar(i_var, pt_fun_sum, graph, arr_rotated, dir);
      }
    }

    // Multiply
    if (i_comp_conn==0) {
      pt_fun = pt_fun_sum;
    } else {
      pt_fun = new FunArrPosPartial2DwordProd(pt_fun, pt_fun_sum);
    }
  } // for (i_comp_conn)


  // Wrap computation into a cache
  if (with_cache) {
    PtFunArrPosPartial2DwordCached pt_fun_cached = new FunArrPosPartial2DwordCached(graph, arr_rotated, pt_fun, dir);

    // Insert into map
    map_fun_cached.insert(key, pt_fun_cached);

    // char data[2*N_VAR_MAX+2];
    // int i_var;
    // for (i_var=0; i_var<n_var; ++i_var) data[i_var] = char(key.arr_status_var[i_var]+int('0'));
    // data[n_var]=' ';
    // for (i_var=0; i_var<n_var; ++i_var) data[n_var+1+i_var] = char(key.arr_extend[i_var]+int('0'));
    // data[2*n_var+1]='\0';
    // printf("Cache insert: %s\n", data);

    // Convert
    convert(pt_fun_cached, pt_fun);
  }

  return pt_fun;
}

/* --- get_arr_comp_conn --- */

static void get_arr_comp_conn(const Graph &graph, const int *arr_status_var, int *arr, int &n) {
  int n_brick=graph.n_brick, i_brick;

  for (i_brick=0; i_brick<n_brick; ++i_brick) arr[i_brick]=-1;
  n=0;

  for (i_brick=0; i_brick<n_brick; ++i_brick) {
    if (arr_status_var[i_brick]==STATUS_VAR_FREE && arr[i_brick]<0) {
      set_comp_conn4brick(graph, arr_status_var, arr, i_brick, n);
      ++n;
    }
  }
}

/* --- get_extend_max --- */

static int get_extend_max(char dir, int status_var, bool rotated) {
  if (status_var==STATUS_VAR_UNUSED) return L_BRICK;
  return dir=='x' ? DIM_BRICK_X4ROTATED(rotated) : DIM_BRICK_Y4ROTATED(rotated);
}

/* --- set_comp_conn4brick --- */

static void set_comp_conn4brick(const Graph &graph, const int *arr_status_var, int *arr, int i_brick, int i_conn_comp) {
  int &start = arr[i_brick];

  if (start>=0) return;

  start=i_conn_comp;

  int n_brick=graph.n_brick, j_brick;
  for (j_brick=0; j_brick<n_brick; ++j_brick) {
    if (i_brick!=j_brick && arr_status_var[j_brick]==STATUS_VAR_FREE && graph.is_linked(i_brick, j_brick)) {
      set_comp_conn4brick(graph, arr_status_var, arr, j_brick, i_conn_comp);
    }
  }
}


////////////////
// FILE str.h //
////////////////

// From c:\consql


////////////////////
// FILE setimpl.h //
////////////////////

// From c:\kombin\lego2\footprnt


////////////////////
// FILE mapimpl.h //
////////////////////

// Taken fron lego4



////////////////////
// FILE graph.cpp //
////////////////////

/* --- static fields --- */

// <arr_n_graph_conn4n_brick[i]> = Number of symmetric connected graphs with i bricks.
// Refer to https://oeis.org/A001349
static const int arr_n_graph_conn4n_brick[N_BRICK_MAX+1] = {1, 1, 1, 2, 6, 21, 112, 853, 11117, 261080, 11716571};
static void get_mat_perm_least(int (*a)[N_BRICK_MAX], int *perm, bool *arr_used, int i, int n, int a_perm_least[N_BRICK_MAX][N_BRICK_MAX], bool &found);
static bool iterate_connected_rek(const int *arr_i_brick4link, const *arr_j_brick4link, int n_link, int n_link_set, Graph&, Performer<Graph>&);
static void setup_arr_desc_neighbourhood(Neighbourhood arr_desc[N_BRICK_MAX], int mat[N_BRICK_MAX][N_BRICK_MAX], int n_brick);
static void setup_grp(Neighbourhood arr_desc[N_BRICK_MAX], int n_brick, int arr_i_brick_start4grp[N_BRICK_MAX], int &n_grp);
static void apply_perm(int in[N_BRICK_MAX][N_BRICK_MAX], const int perm[N_BRICK_MAX], int n_brick, int out[N_BRICK_MAX][N_BRICK_MAX]);
static void comp_graph_min_rek(
  int n_brick,
  int arr_n_overlap_left4row[N_BRICK_MAX], int arr_n_nooverlap_left4row[N_BRICK_MAX], int arr_n_mayoverlap_left4row[N_BRICK_MAX],
  int arr_n_overlap_left4col[N_BRICK_MAX], int arr_n_nooverlap_left4col[N_BRICK_MAX], int arr_n_mayoverlap_left4col[N_BRICK_MAX],
  const int arr_i_brick4link[N_BRICK_MAX], const int arr_j_brick4link[N_BRICK_MAX], int n_link_set, int n_link,
  bool &found, int mat[N_BRICK_MAX][N_BRICK_MAX]
);
static void narrow_rek(
  bool mat[N_BRICK_MAX][N_BRICK_MAX], int n_brick,
  bool arr_used[N_BRICK_MAX], int perm_used[N_BRICK_MAX], int n_used,
  int width_used, // max_(used nodes u) (Number of links from u to some successor)
  int n_link_used2ununsed, // Number of links from used to unused nodes
  int arr_n_neighbour2unused[N_BRICK_MAX], int arr_n_neighbour2used[N_BRICK_MAX],
  int lb, int ub, // Lower and opper bound of widht
  bool &found, // output: was a permutation foudn such that the width of the permutated graph is not above <ub>?
  int perm_min[N_BRICK_MAX], // output: node i of input graph gets node <perm[i]> of output graph
  int &width_min
);
static int cmp4arr4grp(const Neighbourhood&, const Neighbourhood&);
static int cmp_desc_neighbourhood4arr4grp_qsort(const void*, const void*);


/* === Graph ============================================================= */

const char *fkt_graph_is_linked="Graph::is_linked";

/* --- default constructor --- */

Graph::Graph() : n_brick(0) {}

/* --- constructor --- */

Graph::Graph(int p_n_brick) : n_brick(p_n_brick) {
  clear(p_n_brick);
}

/* --- write_fast --- */

// Corresponds to <read_fast_silent>

bool Graph::write_fast(Out &out) const {
  int i_brick, j_brick;

  for (i_brick=0; i_brick<n_brick; ++i_brick) {
    for (j_brick=0; j_brick<i_brick; ++j_brick) {
      if (!out.print_char(is_linked(i_brick, j_brick) ? '1' : '0')) return false;
    }
  }

  return true;
}


/* --- clear --- */

void Graph::clear(int p_n_brick) {
  FKT "Graph::clear()";
  if (!(0<=p_n_brick && p_n_brick<=N_BRICK_MAX)) errstop_index(fkt);

  *const_cast<int*>(&n_brick) = p_n_brick;

  int i_brick, j_brick;
  for (i_brick=0; i_brick<n_brick; ++i_brick) {
    for (j_brick=0; j_brick<n_brick; ++j_brick) {
      data[i_brick][j_brick]=false;
    }
  }
}

/* --- Graph=Graph --- */

void Graph::operator=(const Graph &v) {
  int i_brick, j_brick;

  *const_cast<int*>(&n_brick) = v.n_brick;
  for (i_brick=0; i_brick<n_brick; ++i_brick) {
    for (j_brick=0; j_brick<n_brick; ++j_brick) {
      data[i_brick][j_brick]=v.data[i_brick][j_brick];
    }
  }
}

/* --- is_conform --- */

bool Graph::is_conform(const Part &part) const {
  if (part.get_n_brick()!=n_brick) return false;

  int arr_i_layer4brick[N_BRICK_MAX];
  part.get_arr_i_layer4brick(arr_i_layer4brick);

  int i_brick, j_brick;
  for (i_brick=0; i_brick<n_brick; ++i_brick) {
    for (j_brick=0; j_brick<i_brick; ++j_brick) {
      if (data[j_brick][i_brick]) {
        if (abs(arr_i_layer4brick[i_brick]-arr_i_layer4brick[j_brick])!=1) return false;
      }
    }
  }

  return true;
}

/* --- set_linked --- */

void Graph::set_linked(int i_brick, int j_brick, bool linked) {
  FKT "Graph::set_linked";
  Str errtxt;
  if (!set_linked_silent(i_brick, j_brick, linked, errtxt)) errstop(fkt, errtxt);
}

/* --- set_linked_silent --- */

bool Graph::set_linked_silent(int i_brick, int j_brick, bool linked, Str &errtxt) {

  if (!(0<=i_brick && i_brick<n_brick && 0<=j_brick && j_brick<n_brick)) return err_silent(errtxt, "Indices ausserhalb des gueltigen Bereiches");
  if (i_brick==j_brick)  return err_silent(errtxt, "i_brick==j_brick");
  data[i_brick][j_brick] = data[j_brick][i_brick] = linked;
  return true;
}

/* --- write --- */

// Corresponds to <read>

bool Graph::write(Out &out) const {

  int i_brick, j_brick;
  bool first=true;
  if (!out.print_char('(')) return false;
  for (i_brick=0; i_brick<n_brick; ++i_brick) {
    for (j_brick=0; j_brick<i_brick; ++j_brick) {
      if (data[i_brick][j_brick]) {
        if (!first) {
          if (!out.print_char(' ')) return false;
        }
        if (!out.printf("$-$", i_brick, j_brick)) return false;
        first=false;
      }
    }
  }
  if (!out.print_char(')')) return false;

  return true;
}

/* --- get4i --- */

void Graph::get4i(Card64 i, Graph &graph) {
  // FKT "Graph::get4i";

  // if (!(0<=n_brick && n_brick<=N_BRICK_MAX)) errstop_memoverflow(fkt);
  // *const_cast<int*>(&graph.n_brick) = n_brick;

  Card64 mask=Card64::one;
  int i_brick, j_brick, n_brick=graph.n_brick;
  for (i_brick=0; i_brick<n_brick; ++i_brick) {
    graph.data[i_brick][i_brick]=false;
    for (j_brick=0; j_brick<i_brick; ++j_brick) {
      if (!(i&mask).is_zero()) {
        graph.data[i_brick][j_brick] = graph.data[j_brick][i_brick] = true;
      } else {
        graph.data[i_brick][j_brick] = graph.data[j_brick][i_brick] = false;
      }
      mask.dbl();
    }
  }
}

/* --- get_i --- */

Card64 Graph::get_i() const {
  // FKT "Graph::get_i";
  int i_brick, j_brick;
  Card64 res=Card64::zero, mask=Card64::one;;

  for (i_brick=0; i_brick<n_brick; ++i_brick) {
    for (j_brick=0; j_brick<i_brick; ++j_brick) {
      if (data[i_brick][j_brick]) {
        res|=mask;
      }
      mask.dbl();
    }
  }

  return res;
}

/* --- is_connected --- */

bool Graph::is_connected() const {
  bool arr_connected2first[N_BRICK_MAX];

  int i_brick;
  for (i_brick=0; i_brick<n_brick; ++i_brick) {
    arr_connected2first[i_brick]=false;
  }

  set_connected_to(arr_connected2first, 0);

  for (i_brick=1; i_brick<n_brick; ++i_brick) {
    if (!arr_connected2first[i_brick]) return false;
  }

  return true;
}

/* --- set_connected_to --- */

void Graph::set_connected_to(bool *arr_connected_to, int i_brick_from) const {
  bool &connected_from = arr_connected_to[i_brick_from];
  if (connected_from) return;
  connected_from=true;

  int i_brick_to;
  for (i_brick_to=0; i_brick_to<n_brick; ++i_brick_to) if (i_brick_to!=i_brick_from) {
    if (data[i_brick_to][i_brick_from]) {
      set_connected_to(arr_connected_to, i_brick_to);
    }
  }
}


/* === TransformerFamGraphInt64_2_Pair ================================== */

/* --- constructor --- */

TransformerFamGraphInt64_2_Pair::TransformerFamGraphInt64_2_Pair(Performer<FamGraphFac64> &p_target) : target(p_target) {}

/* --- perform --- */

bool TransformerFamGraphInt64_2_Pair::perform(const FamGraph &fam_graph, Int64 &fac) {
  FamGraphFac64 pair;
  pair.fam_graph = fam_graph;
  pair.fac = fac;
  return target.perform(pair);
}


/* === TransformerFamGraphFac642GraphFac ================================= */

/* --- constructor --- */

TransformerFamGraphFac642GraphFac::TransformerFamGraphFac642GraphFac(Performer<GraphFac> &p_target) : target(p_target) {}

/* --- perform --- */

bool TransformerFamGraphFac642GraphFac::perform(const FamGraphFac64 &in) {
  GraphFac out(in.fam_graph.n_brick);
  in.fam_graph.graph_linked_sure(out.graph);
  out.fac=in.fac;
  return target.perform(out);
}


/* === GraphFac ========================================================== */

/* --- constructor(n_brick) --- */

GraphFac::GraphFac(int n_brick) : graph(n_brick) {}

/* --- default constructor --- */

GraphFac::GraphFac() {}

/* --- write --- */

bool GraphFac::write(Out &out) const {
  char buff[N_DIGIT4INT64+1];
  if (!out.printf("$*", to_nts(fac, buff, sizeof(buff)))) return false;
  return graph.write(out);
}


/* === FamGraphCprFac64 ================================================== */

/* --- default constructor --- */

FamGraphCprFac64::FamGraphCprFac64() {}

/* --- constructor(n_brick) --- */

FamGraphCprFac64::FamGraphCprFac64(int n_brick) : fam_graph(n_brick) {}

/* --- write_fast --- */

bool FamGraphCprFac64::write_fast(Out &out) const {
  FamGraph ucpr(fam_graph.get_n_brick());
  fam_graph.get(ucpr);

  char buff[N_DIGIT4INT64+1];
  if (!out.printf("$*", to_nts(fac, buff, sizeof(buff)))) return false;
  return ucpr.write_fast(out);
}


/* === FamGraphFac64 ===================================================== */

/* --- constructor(n_brick) --- */

FamGraphFac64::FamGraphFac64(int n_brick) : fam_graph(n_brick) {}

/* --- default constructor --- */

FamGraphFac64::FamGraphFac64() {}

/* --- write --- */

bool FamGraphFac64::write(Out &out) const {
  char buff[N_DIGIT4INT64+1];
  if (!out.printf("$*", to_nts(fac, buff, sizeof(buff)))) return false;
  return fam_graph.write(out);
}

/* --- write_fast --- */

bool FamGraphFac64::write_fast(Out &out) const {
  char buff[N_DIGIT4INT64+1];
  if (!out.printf("$*", to_nts(fac, buff, sizeof(buff)))) return false;
  return fam_graph.write_fast(out);
}


/* === FamGraph ========================================================== */

/* --- default constructor --- */

FamGraph::FamGraph() : n_brick(0) {}

/* --- constructor --- */

FamGraph::FamGraph(int p_n_brick) : n_brick(p_n_brick) {
  FKT "FamGraph::FamGraph(int)";

  if (!(0<=p_n_brick && p_n_brick<=N_BRICK_MAX)) errstop_index(fkt);

  clear();
}

/* --- is_connected_sure --- */

bool FamGraph::is_connected_sure() const {
  bool arr_connected2first[N_BRICK_MAX];

  int i_brick;
  for (i_brick=0; i_brick<n_brick; ++i_brick) {
    arr_connected2first[i_brick]=false;
  }

  set_connected_to_sure(arr_connected2first, 0);

  for (i_brick=1; i_brick<n_brick; ++i_brick) {
    if (!arr_connected2first[i_brick]) return false;
  }

  return true;
}

/* --- is_nor_connected_sure --- */

bool FamGraph::is_not_connected_sure(const int *arr_i_layer4brick) const {
  bool arr_connected2first[N_BRICK_MAX];

  int i_brick;
  for (i_brick=0; i_brick<n_brick; ++i_brick) {
    arr_connected2first[i_brick]=false;
  }

  set_connected_to_maybe(arr_connected2first, 0, arr_i_layer4brick);

  for (i_brick=1; i_brick<n_brick; ++i_brick) {
    if (!arr_connected2first[i_brick]) return true;
  }

  return false;
}

/* --- set_overlap_silent --- */

bool FamGraph::set_overlap_silent(int i_brick, int j_brick, int overlap, Str &errtxt) {

  if (!(0<=i_brick && i_brick<n_brick && 0<=j_brick && j_brick<n_brick)) return err_silent(errtxt, "Indices ausserhalb des gueltigen Bereiches");
  if (i_brick==j_brick)  return err_silent(errtxt, "i_brick==j_brick");

  switch (overlap) {
    case OVERLAP_BRICK: case NOOVERLAP_BRICK: case MAYOVERLAP_BRICK: break;
    default: return err_silent(errtxt, "Ungueltiger Wert fuer overlap");
  }

  data[i_brick][j_brick] = data[j_brick][i_brick] = overlap;
  return true;
}

/* --- clear --- */

void FamGraph::clear() {
  int i_brick, j_brick;

  for (i_brick=0; i_brick<n_brick; ++i_brick) {
    for (j_brick=0; j_brick<n_brick; ++j_brick) {
      data[i_brick][j_brick]=MAYOVERLAP_BRICK;
    }
  }
}

/* --- write --- */

// Corresponds to <read_silent>

bool FamGraph::write(Out &out) const {
  FKT "FamGraph::write";
  int i_brick, j_brick;
  bool first=true;

  if (!out.print_char('(')) return false;

  for (i_brick=0; i_brick<n_brick; ++i_brick) {
    for (j_brick=0; j_brick<i_brick; ++j_brick) {
      int elem=data[i_brick][j_brick];
      if (elem==MAYOVERLAP_BRICK) continue;

      if (!first) {
        if (!out.print_char(' ')) return false;
      }

      char c='\0';
      switch (elem) {
        case OVERLAP_BRICK  : c='-'; break;
        case NOOVERLAP_BRICK: c='|'; break;
        default: errstop(fkt, "Ungueltiges elem");
      }

      if (!out.printf("$$$", i_brick, c, j_brick)) return false;
      first=false;
    }
  }

  if (!out.print_char(')')) return false;

  return true;
}

/* --- swap_row --- */

void FamGraph::swap_row(int i_brick, int j_brick) {
  FKT "FamGraph::swap_row";
  if (i_brick<j_brick) {
    swap_row(j_brick, i_brick);
    return;
  }
  if (!(0<=j_brick && i_brick<n_brick)) errstop_index(fkt);
  // if (!(0<=j_brick && j_brick<n_brick)) errstop_index(fkt);
  if (i_brick==j_brick) return;

  // Swap rows
  int row_tmp[N_BRICK_MAX], n_byte = sizeof(int)*n_brick;
  int *row_i = data[i_brick];
  int *row_j = data[j_brick];
  memcpy(row_tmp, row_i, n_byte);
  memcpy(row_i, row_j, n_byte);
  memcpy(row_j, row_tmp, n_byte);

  int k_brick;
  for (k_brick=0; k_brick<n_brick; ++k_brick) {
    swap(data[k_brick][i_brick], data[k_brick][j_brick]);
  }
}

/* --- write_fast --- */

// Corresponds to <read_fast_silent>

bool FamGraph::write_fast(Out &out) const {
  int i_brick, j_brick;

  for (i_brick=0; i_brick<n_brick; ++i_brick) {
    for (j_brick=0; j_brick<i_brick; ++j_brick) {
      if (!out.print_char(char(data[i_brick][j_brick] + int('0')))) return false;
    }
  }

  return true;
}

/* --- FamGraph=FamGraph --- */

void FamGraph::operator=(const FamGraph &v) {
  int i_brick, n_byte4row = sizeof(int)*v.n_brick;

  *const_cast<int*>(&n_brick) = v.n_brick;
  for (i_brick=0; i_brick<n_brick; ++i_brick) {
    const int *row_v = v.data[i_brick];
          int *row   =   data[i_brick];
    memcpy(row, row_v, n_byte4row);
  }
}

/* --- get_n_link4overlap --- */

int FamGraph::get_n_link4overlap(int overlap) const {
  int n_link=0, i_brick, j_brick;

  for (i_brick=0; i_brick<n_brick; ++i_brick) {
    for (j_brick=0; j_brick<i_brick; ++j_brick) {
      if (data[i_brick][j_brick]==overlap) {
        ++n_link;
      }
    }
  }

  return n_link;
}

/* --- get4overlap --- */

void FamGraph::get4overlap(int val, int &i_brick, int &j_brick) const {
  FKT "FamGraph::get4overlap";

  if (!query4overlap(val, i_brick, j_brick)) errstop(fkt, "no such value");
}

/* --- query4overlap --- */

bool FamGraph::query4overlap(int val, int &p_i_brick, int &p_j_brick) const {
  int i_brick, j_brick;

  for (i_brick=0; i_brick<n_brick; ++i_brick) {
    for (j_brick=0; j_brick<i_brick; ++j_brick) {
      if (data[i_brick][j_brick]==val) {
        p_i_brick=i_brick;
        p_j_brick=j_brick;
        return true;
      }
    }
  }

  return false;
}

/* --- graph_linked_sure --- */

void FamGraph::graph_linked_sure(Graph &graph) const {
  FKT "FamGraph::graph_linked_sure";

  if (n_brick!=graph.n_brick) errstop(fkt, "n_brick!=graph.n_brick");

  int i_brick, j_brick;
  for (i_brick=0; i_brick<n_brick; ++i_brick) {
    for (j_brick=0; j_brick<n_brick; ++j_brick) {
      graph.data[i_brick][j_brick] = (data[i_brick][j_brick]==OVERLAP_BRICK);
    }
  }
}

/* --- hashind --- */

unsigned int FamGraph::hashind() const {
  int i_brick, j_brick;
  unsigned int res=0U;

  for (i_brick=0; i_brick<n_brick; ++i_brick) {
    const int *elem = data[i_brick];
    for (j_brick=n_brick; j_brick; --j_brick, ++elem) {
      res = 5U*res + (unsigned int)(*elem);
    }
  }

  return res;
}

/* --- set_overlap --- */

void FamGraph::set_overlap(int i_brick, int j_brick, int overlap) {
  FKT "FamGraph::set_overlap";
  Str errtxt;
  if (!set_overlap_silent(i_brick, j_brick, overlap, errtxt)) errstop(fkt, errtxt);
}

/* --- set_connected_to_sure --- */

void FamGraph::set_connected_to_sure(bool *arr_connected_to, int i_brick_from) const {

  bool &connected_to = arr_connected_to[i_brick_from];
  if (connected_to) return;

  connected_to=true;
  int i_brick_to;
  for (i_brick_to=0; i_brick_to<n_brick; ++i_brick_to) if (i_brick_from!=i_brick_to) {
    if (data[i_brick_from][i_brick_to]==OVERLAP_BRICK) {
      set_connected_to_sure(arr_connected_to, i_brick_to);
    }
  }
}

/* --- set_connected_to_maybe --- */

void FamGraph::set_connected_to_maybe(bool *arr_connected_to, int i_brick_from, const int *arr_i_layer4brick) const {

  bool &connected_to = arr_connected_to[i_brick_from];
  if (connected_to) return;

  connected_to=true;
  int i_brick_to;
  for (i_brick_to=0; i_brick_to<n_brick; ++i_brick_to) if (i_brick_from!=i_brick_to) {
    if (
      data[i_brick_from][i_brick_to]!=NOOVERLAP_BRICK &&
      abs(arr_i_layer4brick[i_brick_to]-arr_i_layer4brick[i_brick_from])==1
    ) { // Then bricks can be connected
      set_connected_to_maybe(arr_connected_to, i_brick_to, arr_i_layer4brick);
    }
  }
}

/* --- get_arr_i_comp_conn_sure --- */

// Find all connection components

void FamGraph::get_arr_i_comp_conn_sure(int *arr_i_comp, int &n_comp) const {

  // Initialise <arr_i_brick_left>
  bool arr_i_brick_left[N_BRICK_MAX]; // Brick non in any connection component
  int i_brick;
  for (i_brick=0; i_brick<n_brick; ++i_brick) arr_i_brick_left[i_brick]=true;

  n_comp=0;
  while (true) {

    // No brick left => done
    int i_brick_left;
    for (i_brick=0, i_brick_left=-1; i_brick_left<0 && i_brick<n_brick; ++i_brick) {
      if (arr_i_brick_left[i_brick]) {
        i_brick_left=i_brick;
      }
    }
    if (i_brick_left<0) break;

    // Find bricks surely reachable from brick <i_brick_left>
    bool arr_reachable[N_BRICK_MAX];
    for (i_brick=0; i_brick<n_brick; ++i_brick) arr_reachable[i_brick]=false;
    set_connected_to_sure(arr_reachable, i_brick_left);

    // Move reachable bricks in connection component <n_comp>
    for (i_brick=0; i_brick<n_brick; ++i_brick) {
      if (arr_reachable[i_brick]) {
        arr_i_brick_left[i_brick]=false;
        arr_i_comp[i_brick]=n_comp;
      }
    }

    ++n_comp;
  }
}

/* --- get_overlap --- */

int FamGraph::get_overlap(int i_brick, int j_brick) const {
  FKT "FamGraph::get_overlap";

  if (!(0<=i_brick && i_brick<n_brick && 0<=j_brick && j_brick<n_brick)) errstop_index(fkt);

  return data[i_brick][j_brick];
}

/* --- is_conform --- */

bool FamGraph::is_conform(const Part &part) const {
  if (part.get_n_brick()!=n_brick) return false;

  int arr_i_layer4brick[N_BRICK_MAX];
  part.get_arr_i_layer4brick(arr_i_layer4brick);

  int i_brick, j_brick;
  for (i_brick=0; i_brick<n_brick; ++i_brick) {
    for (j_brick=0; j_brick<i_brick; ++j_brick) {
      if (arr_i_layer4brick[i_brick]==arr_i_layer4brick[j_brick] && data[j_brick][i_brick]!=NOOVERLAP_BRICK) return false;
    }
  }

  return true;
}


/* === SetGraphCprEquiv ================================================== */

/* --- insert --- */

bool SetGraphCprEquiv::insert(const Graph &graph, Str &errtxt) {
  Graph rep(graph.n_brick);
  if (!get_graph_rep(graph, rep, errtxt)) return false;

  GraphCpr cpr(rep);
  inner.insert(cpr);
  return true;
}


/* === TransformerPairFamGraphInt64_2_GraphFac =========================== */

/* --- constructor --- */

TransformerPairFamGraphInt64_2_GraphFac::TransformerPairFamGraphInt64_2_GraphFac(Performer<GraphFac> &p_target) : target(p_target) {}

/* --- perform --- */

bool TransformerPairFamGraphInt64_2_GraphFac::perform(const FamGraph &fam_graph, Int64 &i64) {
  GraphFac graph_fac(fam_graph.n_brick);
  fam_graph.graph_linked_sure(graph_fac.graph);
  graph_fac.fac = i64;
  return target.perform(graph_fac);
}


/* === TransformerCard642Graph =========================================== */

/* --- constructor --- */

TransformerCard642Graph::TransformerCard642Graph(int p_n_brick, Performer<Graph> &p_target) : n_brick(p_n_brick), target(p_target) {}

/* --- perform --- */

bool TransformerCard642Graph::perform(const Card64 &i) {
  Graph graph(n_brick);
  Graph::get4i(i, graph);
  return target.perform(graph);
}


/* === TransformerFamGraphFac2FamGraph =================================== */

/* --- constructor --- */

TransformerFamGraphFac2FamGraph::TransformerFamGraphFac2FamGraph(Performer<FamGraph> &p_target) : target(p_target) {}

/* --- perform --- */

bool TransformerFamGraphFac2FamGraph::perform(const FamGraphFac &a) {
  return target.perform(a.fam_graph);
}


/* === WriterPairFamGraphInt64 =========================================== */

/* --- constructor --- */

WriterPairFamGraphInt64::WriterPairFamGraphInt64(Out &p_out, bool p_fast) : out(p_out), fast(p_fast) {}

/* --- perform --- */

bool WriterPairFamGraphInt64::perform(const FamGraph &fam_graph, Int64 &i64) {
  char buff[N_DIGIT4INT64+1];

  if (!out.printf("$*", to_nts(i64, buff, sizeof(buff)))) return false;
  if (fast) {
    if (!fam_graph.write_fast(out)) return false;
  } else {
    if (!fam_graph.write(out)) return false;
  }
  if (!out.print_char('\n')) return false;
  return true;
}


/* === WriterPairGraphCprCard64 ========================================== */

/* --- constructor --- */

WriterPairGraphCprCard64::WriterPairGraphCprCard64(Out &p_out) : out(p_out) {}

/* --- perform --- */

bool WriterPairGraphCprCard64::perform(const GraphCpr &cpr, Card64 &c64) {

  Graph graph(cpr.get_n_brick());
  cpr.get(graph);
  if (!graph.write(out)) return false;

  char buff[N_DIGIT4INT64+1];
  if (!out.printf(": $\n", to_nts(c64, buff, sizeof(buff)))) return false;

  return true;
}


/* === WriterFamGraph ==================================================== */

/* --- constructor --- */

WriterFamGraph::WriterFamGraph(Out &p_out) : out(p_out) {}

/* --- perform --- */

bool WriterFamGraph::perform(const FamGraph &fam_graph) {
  if (!fam_graph.write(out)) return false;
  if (!out.print_char('\n')) return false;
  return true;
}

/* === PrinterGraph ====================================================== */

/* --- perform --- */

bool PrinterGraph::perform(const Graph &graph) {
  if (!graph.write(Stdout::instance)) return false;
  if (!Stdout::instance.print_char('\n')) return false;
  return true;
}


/* === MapGraph2Int64::Item ============================================== */

/* --- constructor --- */

MapGraph2Int64::Item::Item() : used(false) {}


/* === MapGraphCpr2Card64 ================================================ */

/* --- equal --- */

bool MapGraphCpr2Card64::equal(const GraphCpr &a, const GraphCpr &b) const {
  return a==b;
}

/* --- hashind --- */

unsigned int MapGraphCpr2Card64::hashind(const GraphCpr &graph) const {
  return graph.hashind();
}


/* === MapGraph2Card64 =================================================== */

/* --- iterate --- */

bool MapGraph2Card64::iterate(Performer4Pair<GraphCpr, Card64> &performer) const {
  return map4cpr.iterate(performer);
}

/* --- clear --- */

void MapGraph2Card64::clear() {
  map4cpr.clear();
}

/* --- contains --- */

bool MapGraph2Card64::contains(const Graph &graph) const {
  Card64 dummy;
  GraphCpr cpr(graph);
  return map4cpr.query(cpr, dummy);
}

/* --- query(Graph) --- */

bool MapGraph2Card64::query(const Graph &graph, Card64 &val) const {
  GraphCpr cpr(graph);
  return query(cpr, val);
}

/* --- query(GraphCpr) --- */

bool MapGraph2Card64::query(const GraphCpr &cpr, Card64 &val) const {
  return map4cpr.query(cpr, val);
}

/* --- insert(Graph) --- */

void MapGraph2Card64::insert(const Graph &graph, const Card64 &val) {
  GraphCpr cpr(graph);
  insert(cpr,val);
}

/* --- insert(GraphCpr) --- */

void MapGraph2Card64::insert(const GraphCpr &cpr, const Card64 &val) {
  Card64 dummy;

  if (!map4cpr.query(cpr, dummy)) {
    map4cpr.insert(cpr, val);
  }
}

/* === MapGraph ========================================================== */

/* --- constructor --- */

MapGraph2Int64::MapGraph2Int64(int p_n_brick) : n_brick(p_n_brick), n(0) {
  FKT "MapGraph2Int64::MapGraph2Int64";

  if (!(0<=n_brick && n_brick<=N_BRICK_MAX)) errstop_index(fkt);

  int n_graph_conn;
  n_graph_conn = arr_n_graph_conn4n_brick[n_brick];
  size=5*n_graph_conn/4;

  arr = new Item[size];
  if (arr==0) errstop_memoverflow(fkt);
}

/* --- destructor --- */

MapGraph2Int64::~MapGraph2Int64() {
  delete[] arr;
}

/* --- clear --- */

void MapGraph2Int64::clear() {
  int i;
  for (i=0; i<size; ++i) arr[i].used=false;
}

/* --- iterate --- */

bool MapGraph2Int64::iterate(Performer<GraphFac> &performer) const {
  int i;

  for (i=0; i<size; ++i) {
    Item &item = arr[i];
    if (item.used) {
      GraphFac graph_fac(n_brick);
      graph_fac.fac=item.fac;
      Graph::get4i(item.i_graph, graph_fac.graph);
      if (!performer.perform(graph_fac)) return false;
    }
  }

  return true;
}

/* --- add --- */

void MapGraph2Int64::add(const Graph &graph, const Int64 &fac) {
  FKT "MapGraph2Int64::add";

  Card64 i_graph = graph.get_i();
  unsigned int hashind = i_graph.hashind();
  int i_start = int(hashind%((unsigned int)size)), i=i_start;

  do {
    Item &item = arr[i];
    if (!item.used) {
      item.used=true;
      item.i_graph=i_graph;
      item.fac=fac;
      ++n;
      return;
    }

    if (item.i_graph==i_graph) {
      item.fac+=fac;
      return;
    }

    ++i;
    if (i==size) i=0;
  } while (i!=i_start);

  errstop(fkt, "Hashtabelle voll");
}


/* === FamGraphCpr ======================================================= */

/* --- constructor --- */

FamGraphCpr::FamGraphCpr(const FamGraph &fam_graph) {
  FKT "FamGraphCpr::FamGraphCpr(FamGraph)";
  int i_brick, j_brick, i_byte, n_brick=fam_graph.n_brick;
  unsigned int u,p;

  data[N_BYTE4FAMGRAPH_CPR]=(byte)(unsigned int)n_brick;
  i_byte=0;
  p=1U;
  for (i_brick=0; i_brick<n_brick; ++i_brick) {
    for (j_brick=0; j_brick<i_brick; ++j_brick) {

      // Enough links in byte ?
      if (p==243U) {
        p=1U;
        ++i_byte;
      }

      byte &b = data[i_byte];

      // Init byte, it it is its first link
      if (p==1U) b=0;

      u = (unsigned int) b;

      // Add link
      switch (fam_graph.get_overlap(i_brick, j_brick)) {
        case MAYOVERLAP_BRICK: u+=p;
        case NOOVERLAP_BRICK : u+=p;
        case OVERLAP_BRICK   : break;
        default: errstop(fkt, "ungueltifer overlap");
      }

      // Advance to next link
      p*=3U;

      // Store byte
      b = (unsigned char)u;
    }
  }

  int n_byte_used = i_byte+(p>1U);
  if (get_n_byte_used()!=n_byte_used) errstop(fkt, "n_byte_used falsch");
}

/* --- get --- */

void FamGraphCpr::get(FamGraph &fam_graph) const {
  int i_brick, j_brick, i_byte, i_link4byte;
  int n_brick = (int)(unsigned int) data[N_BYTE4FAMGRAPH_CPR];
  unsigned int u=0L;

  i_byte=i_link4byte=0;
  for (i_brick=0; i_brick<n_brick; ++i_brick) {
    for (j_brick=0; j_brick<i_brick; ++j_brick) {

      // Enough links in byte ?
      if (i_link4byte==5) {
        i_link4byte=0;
        ++i_byte;
      }

      // get byte, it it is its first link
      if (i_link4byte==0) u = (unsigned int) data[i_byte];

      // Get link
      switch (u%3U) {
        case 2U: fam_graph.set_overlap(i_brick, j_brick, MAYOVERLAP_BRICK); break;
        case 1U: fam_graph.set_overlap(i_brick, j_brick, NOOVERLAP_BRICK ); break;
        case 0U: fam_graph.set_overlap(i_brick, j_brick, OVERLAP_BRICK   ); break;
      }
      u/=3U;
      ++i_link4byte;
    }
  }
}

/* --- hashind --- */

unsigned int FamGraphCpr::hashind() const {
  int i_byte, n_byte_used=get_n_byte_used();
  unsigned int res=0U;

  for (i_byte=0; i_byte<n_byte_used; ++i_byte) res=177U*res+(unsigned int)data[i_byte];

  return res;
}

/* --- FamGraphCpr==FamGraphCpr --- */

bool operator==(const FamGraphCpr &a, const FamGraphCpr &b) {
  FKT "operator==(FamGraphCpr, FamGraphCpr)";
  int n_byte_used=a.get_n_byte_used();
  if (n_byte_used!=b.get_n_byte_used()) errstop(fkt, "a.n_byte_used!=b.n_byte_used");
  return memcmp(a.data, b.data, n_byte_used)==0;
}

/* --- default constructor --- */

FamGraphCpr::FamGraphCpr() {
  memset(data, 0, sizeof(data));
}

/* --- get_n_brick --- */

int FamGraphCpr::get_n_brick() const {
  return (int)(unsigned int)data[N_BYTE4FAMGRAPH_CPR];
}

/* --- default constructor --- */

int FamGraphCpr::get_n_byte_used() const {
  int n_brick = (int)(unsigned int)data[N_BYTE4FAMGRAPH_CPR];
  int n_pair_brick = n_brick*(n_brick-1)/2;
  return (n_pair_brick/5)+(n_pair_brick%5 ? 1 : 0);
}


/* === SelectorMatLeast ================================================== */

/* --- constructor --- */

SelectorMatLeast::SelectorMatLeast(int p_n_brick, int p_mat[N_BRICK_MAX][N_BRICK_MAX]) : n_brick(p_n_brick), set_perm(false) {
  FKT "SelectorMatLeast::SelectorMatLeast";
  int n_byte4row = sizeof(int)*n_brick, i_brick;

  if (!(0<=n_brick && n_brick<=N_BRICK_MAX)) errstop_index(fkt);

  for (i_brick=0; i_brick<n_brick; ++i_brick) {
    memcpy(mat[i_brick], p_mat[i_brick], n_byte4row);
  }
}

/* --- perform --- */

bool SelectorMatLeast::perform(const Perm &p_perm) {

  int mat_test[N_BRICK_MAX][N_BRICK_MAX];
  apply_perm(mat, p_perm.data, n_brick, mat_test);

  int i_brick;
  bool copy;
  if (set_perm) {
    int cmp=0;
    int j_brick;

    for (i_brick=0; !cmp && i_brick<n_brick; ++i_brick) {
      for (j_brick=0; !cmp && j_brick<i_brick; ++j_brick) {
        cmp = cmp_int(mat_test[i_brick][j_brick], mat_perm[i_brick][j_brick]);
      }
    }

    copy=(cmp<0);
  } else {
    copy=true;
  }

  if (copy) {
    int n_byte4row = sizeof(int)*n_brick, i_brick;
    for (i_brick=0; i_brick<n_brick; ++i_brick) {
      memcpy(mat_perm[i_brick], mat_test[i_brick], n_byte4row);
    }
    memcpy(perm, p_perm.data, n_byte4row);
  }

  set_perm=true;

  return true;
}


/* === GraphCpr ========================================================== */

/* --- get_n_brick --- */

int GraphCpr::get_n_brick() const {
  return (int)(unsigned int)data[N_BYTE4GRAPH_CPR];
}

/* --- hashind --- */

unsigned int GraphCpr::hashind() const {
  int i_byte;
  unsigned int res=0U;

  for (i_byte=0; i_byte<N_BYTE4GRAPH_CPR; ++i_byte) res=177U*res+(unsigned int)data[i_byte];
  return res;
}

/* --- constructor --- */

GraphCpr::GraphCpr(const Graph &graph) {
  int i_brick, j_brick, i_byte, i_bit, n_brick=graph.n_brick;

  memset(data, 0, sizeof(data));

  data[N_BYTE4GRAPH_CPR]=(byte)(unsigned int)n_brick;
  i_byte=i_bit=0;
  for (i_brick=0; i_brick<n_brick; ++i_brick) {
    for (j_brick=0; j_brick<i_brick; ++j_brick) {

      byte &b = data[i_byte];

      // Add link
      if (graph.is_linked(i_brick, j_brick)) {
        b|=(byte)(unsigned int)(1<<i_bit);
      }

      // Advance to next link
      ++i_bit;
      if (i_bit==8) {
        i_bit=0;
        ++i_byte;
      }

    }
  }
}

/* --- default constructor --- */

GraphCpr::GraphCpr() {
  memset(data, 0, sizeof(data));
}

/* --- cmp(GraphCpr) --- */

int cmp(const GraphCpr &a, const GraphCpr &b) {
  return memcmp(a.data, b.data, sizeof(a.data));
}

/* --- get --- */

void GraphCpr::get(Graph &graph) const {
  int i_brick, j_brick, i_byte, i_bit, b;
  int n_brick = (int)(unsigned int) data[N_BYTE4GRAPH_CPR];

  i_byte=i_bit=0;
  for (i_brick=0; i_brick<n_brick; ++i_brick) {
    for (j_brick=0; j_brick<i_brick; ++j_brick) {

      b = (int)(unsigned int) data[i_byte];
      graph.set_linked(i_brick, j_brick, (b & (1<<i_bit))!=0);

      ++i_bit;
      if (i_bit==8) {
        i_bit=0;
        ++i_byte;
      }
    }
  }
}


/* === GraphCprFac ======================================================= */

/* --- default constructor --- */

GraphCprFac::GraphCprFac() {}

/* --- constructor(uncompressed) --- */

GraphCprFac::GraphCprFac(const GraphFac &x) : graph(x.graph), fac(x.fac) {}


/* === Compressor4GraphFac =============================================== */

/* --- constructor --- */

Compressor4GraphFac::Compressor4GraphFac(Performer<GraphCprFac> &p_target) : target(p_target) {}

/* --- perform --- */

bool Compressor4GraphFac::perform(const GraphFac &x) {
  GraphCprFac cpr(x);
  return target.perform(cpr);
}


/* === MapFamGraph2Int64 ================================================= */

/* --- constructor --- */

MapFamGraph2Int64::MapFamGraph2Int64() : n(0), size_arr_hash(0), n_item_page_first(0), ptr_page_first(0), arr_hash(0), locked(false) {}

/* --- get_n_no_zero --- */

int MapFamGraph2Int64::get_n_no_zero() const {
  FKT "MapFamGraph2Int64::get_n_no_zero";
  Counter4Pair<FamGraph, Int64> counter;

  if (!iterate_no_zero(counter)) errstop(fkt, "iterate_no_zero fehlgeschlagen");
  return counter.n;
}

/* --- add --- */

void MapFamGraph2Int64::add(const FamGraph &key, const Int64 &val) {
  static const char *fkt="MapFamGraph2Int64::add";

  if (val.is_zero()) return;

  // Seek element; if found, add it
  int i;
  FamGraphCpr key_cpr(key);
  unsigned int hashind = key_cpr.hashind();
  if (size_arr_hash>0) {
    i = int(hashind%(unsigned int)size_arr_hash);
    Item *ptr_item = arr_hash[i];
    while (ptr_item!=0) {
      if (key_cpr==ptr_item->key) {
        ptr_item->val+=val;
        return;
      }
      ptr_item=ptr_item->ptr_next;
    }
  }

  if (locked) errstop(fkt, "Map gegen einfuegende Schreibzugriffe gesperrt");

  // Resize hash array, if necessary
  if (4*n>=3*size_arr_hash) {
    int size_arr_hash_old = size_arr_hash;
    Item **arr_hash_old = arr_hash;

    int i_new;
    size_arr_hash = 5*n/3+11;
    arr_hash = new Item*[size_arr_hash];
    if (arr_hash==0) errstop(fkt, "Memory overflow");
    for (i_new=0; i_new<size_arr_hash; ++i_new) arr_hash[i_new]=0;

    int i_old;
    for (i_old=0; i_old<size_arr_hash_old; ++i_old) {
      Item *ptr_item = arr_hash_old[i_old];
      while (ptr_item!=0) {
        Item &item = *ptr_item;
        Item *ptr_item_next = item.ptr_next;

        int i_new = int(item.key.hashind()%(unsigned int)size_arr_hash);
        item.ptr_next = arr_hash[i_new];
        arr_hash[i_new] = ptr_item;
        ptr_item = ptr_item_next;
      }
    }

    if (arr_hash_old!=0) delete[] arr_hash_old;
  }

  // Get new page, if necessary
  if (ptr_page_first==0 || n_item_page_first==N_ELEM4PAGE_SET) {
    Page *ptr_page_new = new Page();
    ptr_page_new->ptr_next = ptr_page_first;
    ptr_page_first = ptr_page_new;
    n_item_page_first=0;
  }

  // Alloc item
  Item &item_new = ptr_page_first->data[n_item_page_first];
  ++n_item_page_first;
  ++n;

  // Put data into item
  item_new.key = key_cpr;
  item_new.val = val    ;

  // link element into hash table
  i = int(hashind%(unsigned int)size_arr_hash);
  item_new.ptr_next = arr_hash[i];
  arr_hash[i] = &item_new;
}

/* --- iterate_no_zero(Performer) --- */

bool MapFamGraph2Int64::iterate_no_zero(Performer<FamGraphFac64> &performer) const {
  TransformerFamGraphInt64_2_Pair transformer(performer);
  return iterate_no_zero_intern(transformer);
}

/* --- iterate_no_zero(Performer4Pair) --- */

bool MapFamGraph2Int64::iterate_no_zero(Performer4Pair<FamGraph, Int64> &performer) const {
  bool &r_locked = *const_cast<bool*>(&locked);
  r_locked=true;
  bool ok = iterate_no_zero_intern(performer);
  r_locked=false;
  return ok;
}

/* --- iterate_no_zero_intern --- */

bool MapFamGraph2Int64::iterate_no_zero_intern(Performer4Pair<FamGraph, Int64> &performer) const {

  if (ptr_page_first==0) return true;

  // First page
  int i;
  Item *data_page = ptr_page_first->data;
  for (i=0; i<n_item_page_first; ++i) {
    Item &item = data_page[i];
    if (!item.val.is_zero()) {
      FamGraph fam_graph(item.key.get_n_brick());
      item.key.get(fam_graph);
      if (!performer.perform(fam_graph, item.val)) return false;
    }
  }

  // Subsequent pages
  Page *ptr_page = ptr_page_first->ptr_next;
  while (ptr_page!=0) {
    Item *data_page = ptr_page->data;
    for (i=0; i<N_ELEM4PAGE_SET; ++i) {
      Item &item = data_page[i];
      if (!item.val.is_zero()) {
        FamGraph fam_graph(item.key.get_n_brick());
        item.key.get(fam_graph);
        if (!performer.perform(fam_graph, item.val)) return false;
      }
    }
    ptr_page = ptr_page->ptr_next;
  }

  return true;
}

/* --- clear --- */

void MapFamGraph2Int64::clear() {
  FKT "MapFamGraph2Int64::clear";

  if (locked) errstop(fkt, "Map wird iteriert");

  if (arr_hash!=0) {
    delete[] arr_hash;
    arr_hash=0;
  }


  Page *ptr_page=ptr_page_first;
  while (ptr_page!=0) {
    Page *ptr_page_next = ptr_page->ptr_next;
    delete ptr_page;
    ptr_page = ptr_page_next;
  }
  ptr_page_first=0;

  n=size_arr_hash=n_item_page_first=0;
}

/* --- destructor --- */

MapFamGraph2Int64::~MapFamGraph2Int64() {
  clear();
}


/* === exported functions ================================================ */

/* --- get_n_graph_conn4n_brick --- */

int get_n_graph_conn4n_brick(int n_brick) {
  FKT "get_n_graph_conn4n_brick";
  if (!(0<=n_brick && n_brick*sizeof(*arr_n_graph_conn4n_brick)<=sizeof(arr_n_graph_conn4n_brick))) errstop_index(fkt);
  return arr_n_graph_conn4n_brick[n_brick];
}

/* --- cmp_graph_cpr4qsort --- */

int cmp_graph_cpr4qsort(const void *ptr_a, const void *ptr_b) {
  return cmp(*(GraphCpr*) ptr_a, *(GraphCpr*) ptr_b);
}

/* --- cmp(FamGraphCpr) --- */

int cmp(const FamGraphCpr &a_cpr, const FamGraphCpr &b_cpr) {
  int n_brick = a_cpr.get_n_brick();
  FamGraph a(n_brick), b(n_brick);
  a_cpr.get(a);
  b_cpr.get(b);
  return cmp(a,b);
}

/* --- comp_mat_rep --- */

bool comp_mat_rep(int mat[N_BRICK_MAX][N_BRICK_MAX], int n_brick, int mat_rep[N_BRICK_MAX][N_BRICK_MAX], int perm[N_BRICK_MAX], int &n_perm, Str &errtxt) {
  FKT "comp_mat_rep";

  // Put all brick in one group and set origin brick index
  int i_brick;
  Neighbourhood arr_desc[N_BRICK_MAX];
  for (i_brick=0; i_brick<n_brick; ++i_brick) {
    Neighbourhood &desc = arr_desc[i_brick];
    desc.i_brick_origin = i_brick;
    desc.i_grp  =      0;
  }

  int arr_i_brick_start4grp[N_BRICK_MAX], n_grp_old, n_grp=1;
  do {
    setup_arr_desc_neighbourhood(arr_desc, mat, n_brick);
    n_grp_old=n_grp;
    setup_grp(arr_desc, n_brick, arr_i_brick_start4grp, n_grp);
  } while (n_grp_old<n_grp);

  // Sort matrix by groups
  int perm4grp[N_BRICK_MAX];
  for (i_brick=0; i_brick<n_brick; ++i_brick) {
    perm4grp[arr_desc[i_brick].i_brick_origin] = i_brick;
  }
  apply_perm(mat, perm4grp, n_brick, mat_rep);

  // Within each group, apply one sweep of sorting
  // int i_grp, j_brick;
  // n_perm=1;
  // for (i_grp=0; i_grp<n_grp; ++i_grp) {
  //   int i_brick_start = arr_i_brick_start4grp[i_grp];
  //   int i_brick_end = i_grp+1==n_grp ? n_brick : arr_i_brick_start4grp[i_grp+1];
  //
  //   for (i_brick=i_brick_start; i_brick<i_brick_end; ++i_brick) {
  //     for (j_brick=i_brick+1; j_brick<i_brick_end; ++j_brick) {
  //       if (cmp_arr_int(mat_rep[i_brick], mat_rep[j_brick], i_brick)>0) {
  //         swap_arr_int(mat_rep[i_brick], mat_rep[j_brick], n_brick);
  //         swap_col(mat_rep, i_brick, j_brick, n_brick);
  //       }
  //     }
  //   }
  //   n_perm*=fac(i_brick_end-i_brick_start);
  // }


  if (n_grp<n_brick) {

    Part part;
    int i_grp;
    for (i_grp=0; i_grp<n_grp; ++i_grp) {
      int i_brick_start = arr_i_brick_start4grp[i_grp];
      int i_brick_end = i_grp+1==n_grp ? n_brick : arr_i_brick_start4grp[i_grp+1];
      int n4grp = i_brick_end-i_brick_start;
      if (!part.add_layer_silent(n4grp, errtxt)) return false;
    }

    SelectorMatLeast selector(n_brick, mat_rep);
    CounterPassing<Perm> counter(selector);
    if (!part.iterate_perm_conform(counter)) errstop(fkt, "!part.iterate_perm_conform");
    if (!selector.set_perm) errstop(fkt, "!selector.found");

    int j_brick;
    for (i_brick=0; i_brick<n_brick; ++i_brick) {
      for (j_brick=0; j_brick<n_brick; ++j_brick) {
        mat_rep[i_brick][j_brick] = selector.mat_perm[i_brick][j_brick];
      }
      perm[i_brick] = selector.perm[perm4grp[i_brick]];
    }

    n_perm=counter.n;
  } else {
    memcpy(perm, perm4grp, n_brick*sizeof(int));
  }
  return true;
}

/* --- cmp(Neighbourhood4Grp) --- */

int cmp(const Neighbourhood4Grp &a, const Neighbourhood4Grp &b) {
  int res;
  res = cmp_int(a.n_overlap   , b.n_overlap   ); if (res) return res;
  res = cmp_int(a.n_nooverlap , b.n_nooverlap ); if (res) return res;
  res = cmp_int(a.n_mayoverlap, b.n_mayoverlap);
  return res;
}

/* --- read(FamGraph) --- */

bool read(In &in, int n_brick, FamGraph &fam_graph) {
  Str errtxt;

  if (!read_silent(in, n_brick, fam_graph, errtxt)) return in.In::err_at(errtxt);
  return true;
}

/* --- read_fast(FamGraph) --- */

bool read_fast(In &in, int n_brick, FamGraph &fam_graph) {
  Str errtxt;

  if (!read_fast_silent(in, n_brick, fam_graph, errtxt)) return in.In::err_at(errtxt);
  return true;
}

/* --- read_fast(Graph) --- */

bool read_fast(In &in, int n_brick, Graph &graph) {
  Str errtxt;

  if (!read_fast_silent(in, n_brick, graph, errtxt)) return in.In::err_at(errtxt);
  return true;
}

/* --- read(Graph) --- */

bool read(In &in, int n_brick, Graph &graph) {
  Str errtxt;

  if (!read_silent(in, n_brick, graph, errtxt)) return in.In::err_at(errtxt);
  return true;
}

/* --- read_silent(Graph) --- */

bool read_silent(In &in, int n_brick, Graph &p_graph, Str &errtxt) {
  Graph l_graph(n_brick);

  if (!in.read_char_given_silent('(', errtxt)) return false;

  bool first=true;
  while (!in.read_evtl_char_given(')')) {
    int i_brick, j_brick;
    if (!first && !in.read_char_given_silent(' ', errtxt)) return false;
    if (!in.read_card_silent(i_brick, errtxt)) return false;
    if (!in.read_char_given_silent('-', errtxt)) return false;
    if (!in.read_card_silent(j_brick, errtxt)) return false;
    if (!l_graph.set_linked_silent(i_brick, j_brick, true, errtxt)) return false;
    first=false;
  }

  p_graph=l_graph;
  return true;
}


/* --- read_silent --- */

bool read_silent(In &in, int n_brick, FamGraph &p_fam_graph, Str &errtxt) {
  FamGraph l_fam_graph(n_brick);

  if (!in.read_char_given_silent('(', errtxt)) return false;

  bool first=true;
  while (!in.read_evtl_char_given(')')) {
    int i_brick, j_brick, overlap;

    if (!first && !in.read_char_given_silent(' ', errtxt)) return false;

    if (!in.read_card_silent(i_brick, errtxt)) return false;

    if (in.read_evtl_char_given('-')) {
      overlap=OVERLAP_BRICK;
    } else if (in.read_evtl_char_given('|')) {
      overlap=NOOVERLAP_BRICK;
    } else {
      return err_silent(errtxt, "\'-\' oder \'|\' erwartet");
    }

    if (!in.read_card_silent(j_brick, errtxt)) return false;

    if (!l_fam_graph.set_overlap_silent(i_brick, j_brick, overlap, errtxt)) return false;

    first=false;
  }

  p_fam_graph=l_fam_graph;
  return true;
}

/* --- read_fast_silent(FamGraph) --- */

bool read_fast_silent(In &in, int n_brick, FamGraph &p_fam_graph, Str &errtxt) {
  FamGraph l_fam_graph(n_brick);
  int i_brick, j_brick;

  for (i_brick=0; i_brick<n_brick; ++i_brick) {
    for (j_brick=0; j_brick<i_brick; ++j_brick) {
      if (in.at_end()) return in.In::err_at("Unexpected end of file");

      char c = *in;
      int overlap = int(c)-int('0');
      if (!l_fam_graph.set_overlap_silent(i_brick, j_brick, overlap, errtxt)) return false;

      if (!++in) return false;
    }
  }

  p_fam_graph=l_fam_graph;
  return true;
}

/* --- read_fast_silent(Graph) --- */

bool read_fast_silent(In &in, int n_brick, Graph &p_graph, Str &errtxt) {
  Graph l_graph(n_brick);
  int i_brick, j_brick;

  for (i_brick=0; i_brick<n_brick; ++i_brick) {
    for (j_brick=0; j_brick<i_brick; ++j_brick) {
      if (in.at_end()) return in.In::err_at("Unexpected end of file");

      switch (*in) {
        case '0': break;
        case '1': l_graph.set_linked(i_brick, j_brick, true); break;
        default: return in.In::err_at("\'0\' oder \'1\' erwartet");
      }

      if (!++in) return false;
    }
  }

  p_graph=l_graph;
  return true;
}

/* --- get_fam_graph_rep_fast --- */

// Sets the represenative graph famliy of all the graphs family which is equivalent to <fam_graph>.
// The "represenative graph" of a set of graph famlies a the lexical less or equal one with respect
// to the brick pair order (1,0), (2,0), (2,1), (3,0), (3,1), (3,2)...
// A connected brick pair comes after an unconnected one.

bool get_fam_graph_rep_fast(const FamGraph &fam_graph, FamGraph &rep, int &n_perm, Str &errtxt) {
  int mat[N_BRICK_MAX][N_BRICK_MAX];
  int i_brick, j_brick, n_brick=fam_graph.n_brick;

  for (i_brick=0; i_brick<n_brick; ++i_brick) {
    for (j_brick=0; j_brick<i_brick; ++j_brick) {
      mat[i_brick][j_brick] = mat[j_brick][i_brick] = fam_graph.get_overlap(i_brick, j_brick);
    }
  }

  int mat_rep[N_BRICK_MAX][N_BRICK_MAX], perm[N_BRICK_MAX];
  if (!comp_mat_rep(mat, n_brick, mat_rep, perm, n_perm, errtxt)) return false;

  for (i_brick=0; i_brick<n_brick; ++i_brick) {
    for (j_brick=0; j_brick<i_brick; ++j_brick) {
      rep.set_overlap(i_brick, j_brick, mat_rep[i_brick][j_brick]);
    }
  }

  return true;
}

/* --- narrow(Grapg) --- */

void narrow(const Graph &graph_in, Graph &graph_out, int *arr_i_brick_pred_out) {
  FKT "narrow";
  int n_brick = graph_in.n_brick, i_brick, j_brick;

  // Export <graph_in> to matrix
  bool mat_in[N_BRICK_MAX][N_BRICK_MAX];
  for (i_brick=0; i_brick<n_brick; ++i_brick) {
    for (j_brick=0; j_brick<i_brick; ++j_brick) {
      mat_in[i_brick][j_brick] = mat_in[j_brick][i_brick] = graph_in.is_linked(i_brick, j_brick);
    }
  }

  // Compute number of neighbours
  int arr_n_neighbour[N_BRICK_MAX];
  for (i_brick=0; i_brick<n_brick; ++i_brick) {
    int sum=0;
    for (j_brick=0; j_brick<n_brick; ++j_brick) if (i_brick!=j_brick) {
      sum+=int(mat_in[i_brick][j_brick]);
    }
    arr_n_neighbour[i_brick]=sum;
  }

  // Compute mimimum of number of neihbours
  int min_n_neighbour = N_BRICK_MAX;
  for (i_brick=0; i_brick<n_brick; ++i_brick) {
    int n_neighbour = arr_n_neighbour[i_brick];
    if (min_n_neighbour>n_neighbour) min_n_neighbour=n_neighbour;
  }

  // Initialise info about use status
  bool arr_used[N_BRICK_MAX];
  int n_used=0;
  set(arr_used, n_brick, false);

  // Initialise arrays of number of used/unused neighbours
  int arr_n_neighbour2used[N_BRICK_MAX], arr_n_neighbour2unused[N_BRICK_MAX];
  for (i_brick=0; i_brick<n_brick; ++i_brick) {
    arr_n_neighbour2unused[i_brick] = arr_n_neighbour[i_brick];
    arr_n_neighbour2used  [i_brick] =                        0;
  }

  // Start recursion
  int perm_used[N_BRICK_MAX], perm_min[N_BRICK_MAX];
  int width_min, width_used=0, n_link_used2ununsed=0, lb=min_n_neighbour, ub=N_BRICK_MAX; // node i of input graph gets node <perm[i]> of output graph
  bool found;
  narrow_rek(
    mat_in, n_brick,
    arr_used, perm_used, n_used,
    width_used,
    n_link_used2ununsed,
    arr_n_neighbour2unused, arr_n_neighbour2used,
    lb, ub,
    found, perm_min, width_min
  );
  if (!found) errstop(fkt, "Kein Graph gefunden");

  // set output matrix
  for (i_brick=0; i_brick<n_brick; ++i_brick) {
    int perm_min_i = perm_min[i_brick];

    // Copy matrix row
    bool *row_in=mat_in[i_brick];
    for (j_brick=0; j_brick<i_brick; ++j_brick) {
      graph_out.set_linked(perm_min_i, perm_min[j_brick], row_in[j_brick]);
    }

  }

  // Set <arr_i_brick_pred_out>
  int i_brick_pred;
  for (i_brick=1; i_brick<n_brick; ++i_brick) {
    found=false;
    for (i_brick_pred=0; i_brick_pred<i_brick; ++i_brick_pred) {
      if (graph_out.is_linked(i_brick, i_brick_pred)) {
        arr_i_brick_pred_out[i_brick] = i_brick_pred;
        found=true;
        break;
      }
    }
    if (!found) errstop(fkt, "!found");
  }
}

/* --- get_graph_rep --- */

// Sets the represenative graph of all the graphs which are equivalent to <graph>.
// The "represenative graph" of a set of graphs is the lexical least one with respect
// to the brick pair order (1,0), (2,0), (2,1), (3,0), (3,1), (3,2)...
// A connected brick pair comes after an unconnected one.

bool get_graph_rep(const Graph &graph, Graph &graph_rep, Str &errtxt) {

  int n=graph.n_brick,i,j;
  FamGraph fam_graph(n);
  for (i=0; i<n; ++i) {
    for (j=0; j<i; ++j) {
      fam_graph.set_overlap(i,j, graph.is_linked(i,j) ? OVERLAP_BRICK : NOOVERLAP_BRICK);
    }
  }

  FamGraph fam_graph_rep(n);
  int n_perm;
  if (!get_fam_graph_rep_fast(fam_graph, fam_graph_rep, n_perm, errtxt)) return false;

  fam_graph_rep.graph_linked_sure(graph_rep);
  return true;
}

/* --- read(GraphFac) --- */

bool read(In &in, int n_brick, GraphFac &x) {
  if (!read(in, x.fac)) return false;
  if (!in.read_char_given('*')) return false;
  if (!read(in, n_brick, x.graph)) return false;
  return true;
}

/* --- read(FamGraphFac64) --- */

bool read(In &in, int n_brick, FamGraphFac64 &x) {
  if (!read(in, x.fac)) return false;
  if (!in.read_char_given('*')) return false;
  if (!read(in, n_brick, x.fam_graph)) return false;
  return true;
}

/* --- read_fast(FamGraphFac64) --- */

bool read_fast(In &in, int n_brick, FamGraphFac64 &x) {
  if (!read(in, x.fac)) return false;
  if (!in.read_char_given('*')) return false;
  if (!read_fast(in, n_brick, x.fam_graph)) return false;
  return true;
}

/* --- read_fast(FamGraphCprFac64) --- */

bool read_fast(In &in, int n_brick, FamGraphCprFac64 &cpr) {

  if (!read(in, cpr.fac)) return false;
  if (!in.read_char_given('*')) return false;

  FamGraph fam_graph;
  if (!read_fast(in, n_brick, fam_graph)) return false;

  cpr.fam_graph = FamGraphCpr(fam_graph);

  return true;
}

/* --- read(FamGraphFac) --- */

bool read(In &in, int n_brick, FamGraphFac &x) {
  if (!in.read_card(x.fac)) return false;
  if (!in.read_char_given('*')) return false;
  if (!read(in, n_brick, x.fam_graph)) return false;
  return true;
}

/* --- compatible --- */

bool compatible(int a, int b) {
  return a==MAYOVERLAP_BRICK || b==MAYOVERLAP_BRICK || a==b;
}

/* --- cmp_fam_graph644qsort --- */

int cmp_fam_graph644qsort(const void *ptr_a, const void *ptr_b) {
  return cmp(((FamGraphFac64*)ptr_a)->fam_graph, ((FamGraphFac64*)ptr_b)->fam_graph);
}

/* --- cmp --- */

int cmp(const FamGraph &a, const FamGraph &b) {
  FKT "cmp(FamGraph, FamGraph)";

  int n_brick=a.n_brick;
  if (n_brick!=b.n_brick) errstop(fkt, "n_brick of operands differ");

  int i_brick, res;
  for (i_brick=1; i_brick<n_brick; ++i_brick) {
    const int *row_a = a.data[i_brick];
    const int *row_b = b.data[i_brick];

    res=memcmp(row_a, row_b, i_brick*sizeof(int));
    if (res) return res;
  }

  return 0;
}

/* --- iterate_connected --- */

bool iterate_connected(int n_brick, Performer<Graph> &performer) {
  Graph graph(n_brick);
  int arr_i_brick4link[N_LINK_MAX], arr_j_brick4link[N_LINK_MAX], i_link, i_brick, j_brick;

  i_link=0;
  for (i_brick=0; i_brick<n_brick; ++i_brick) {
    for (j_brick=0; j_brick<i_brick; ++j_brick) {
      arr_i_brick4link[i_link] = i_brick;
      arr_j_brick4link[i_link] = j_brick;
      ++i_link;
    }
  }

  return iterate_connected_rek(arr_i_brick4link, arr_j_brick4link, n_brick*(n_brick-1)/2, 0, graph, performer);
}

/* --- iterate4part ---

bool iterate4part(const Part &part, Performer<Graph> &performer) {

  int arr_i_brick4link[N_BRICK_MAX*N_BRICK_MAX], arr_j_brick4link[N_BRICK_MAX*N_BRICK_MAX], n_link=0;
  int i_layer, j_layer, i_brick_l4layer=0, i_brick_l=0, n_layer=part.get_n_layer();
  for (i_layer=0, j_layer=1; j_layer<n_layer; ++i_layer, ++j_layer) {
    int i_brick_u  = i_brick_l+part.get_n_brick4layer(i_layer);
    int j_brick_l = i_brick_u;
    int j_brick_u = i_brick_u+part.get_n_brick4layer(j_layer);
    int i_brick, j_brick;
    for (i_brick=i_brick_l; i_brick<i_brick_u; ++i_brick) {
      for (j_brick=j_brick_l; j_brick<j_brick_u; ++j_brick) {
        arr_i_brick4link[n_link] = i_brick;
        arr_j_brick4link[n_link] = j_brick;
        ++n_link;
      }
    }

    i_brick_l=i_brick_u;
  }

  Graph graph(part.get_n_brick());
  return iterate4part_rek(arr_i_brick4link, arr_j_brick4link, n_link, 0, graph, performer);
}*/

/* --- iterate4equiv_to ---

bool iterate4equiv_to(const Part &part, const Graph &graph, Performer<Graph> &performer) {

  // Empty partition => empty graph
  int n_layer = part.get_n_layer();
  if (n_layer==0) {
    Graph graph_empty(0);
    return performer.perform(graph_empty);
  }


  int arr_i_brick_first4layer[N_BRICK_MAX+1], perm[N_BRICK_MAX], arr_i_layer4brick[N_BRICK_MAX];
  int i_layer, i_brick;
  arr_i_brick_first4layer[0]=0;
  for (i_layer=0; i_layer<n_layer; ++i_layer) {
    int &i_brick_l = arr_i_brick_first4layer[i_layer  ];
    int &i_brick_u = arr_i_brick_first4layer[i_layer+1];
    i_brick_u = i_brick_l + part.get_n_brick4layer(i_layer);

    for (i_brick=i_brick_l; i_brick<i_brick_u; ++i_brick) {
      arr_i_layer4brick[i_brick] = i_layer;
    }
  }

  // Set first brick to lexically first position
  perm[0]=0;

  // Set <arr_i_brick_used> which tells what bricks are used
  bool arr_i_brick_used[N_BRICK_MAX];
  int n_brick=part.get_n_brick();
  arr_i_brick_used[0]=true;
  for (i_brick=1; i_brick<n_brick; ++i_brick) {
    arr_i_brick_used[i_brick]=false;
  }

  // Start recursion
  return iterate4equiv_to4brick(arr_i_brick_first4layer, arr_i_layer4brick, n_brick, 1, perm, arr_i_brick_used, graph, performer);
}*/


/* === static functions ================================================== */

/* --- cmp4arr4grp --- */

int cmp4arr4grp(const Neighbourhood &a, const Neighbourhood &b) {
  int n_grp = a.n_grp, i_grp, res;
  for (i_grp=0; i_grp<n_grp; ++i_grp) {
    res = cmp(a.arr4grp[i_grp], b.arr4grp[i_grp]);
    if (res) return res;
  }
  return 0;
}

/* --- get_mat_perm_least --- */

static void get_mat_perm_least(int (*a)[N_BRICK_MAX], int *perm, bool *arr_used, int n_used, int n, int (*a_perm_least)[N_BRICK_MAX], bool &found) {
  FKT "get_mat_perm_least";
  int i,j;

  // All matrix element set ?
  if (n_used==n) {

    for (i=0; i<n; ++i) for (j=0; j<n; ++j) a_perm_least[i][j]=a[perm[i]][perm[j]];
    found=true;
    return;
  }

  // Compute lexical least permutated row
  int &next=perm[n_used], row_next_least[N_BRICK_MAX];
  bool arr_least_set=false;
  for (next=0; next<n; ++next) if (!arr_used[next]) {

    // Compute permutated row
    int *a_next = a[next], row_next[N_BRICK_MAX];
    for (j=0; j<n_used; ++j) row_next[j]=a_next[perm[j]];

    // Found less row ?
    int cmp;
    if (arr_least_set) {
      cmp=0;
      for (j=0; !cmp && j<n_used; ++j) {
        cmp = cmp_int(row_next[j], row_next_least[j]);
      }
    }

    if (!arr_least_set || cmp<0) {
      for (j=0; j<n_used; ++j) row_next_least[j]=row_next[j];
      arr_least_set=true;
    }
  }

  if (!arr_least_set) errstop(fkt, "!arr_least_set");

  // Recursion
  for (next=0; next<n; ++next) {
    bool &used = arr_used[next];

    if (used) continue;

    int *a_next = a[next];
    bool feasable=true;
    for (j=0; j<n_used; ++j) {
      if (a_next[perm[j]]!=row_next_least[j]) {
        feasable=false;
        break;
      }
    }
    if (!feasable) continue;

    // Is there a chance to get lexical before <a_perm_least> ?
    if (found) {
      bool chance=false;
      for (i=0; i<=n_used; ++i) {
        for (j=0; j<i; ++j) {
          int cmp=cmp_int(a_perm_least[i][j], a[perm[i]][perm[j]]);
          if (cmp<0) {
            feasable=false; // No change
            break;
          }
          if (cmp>0) { // There is a change
            chance=true;
            break;
          }
        }
        if (chance || !feasable) break;
      }
    }
    if (!feasable) continue;

    // Recursion
    used=true;
    get_mat_perm_least(a, perm, arr_used, n_used+1, n, a_perm_least, found);
    used=false;
  }
}

/* --- iterate_connected_rek --- */

static bool iterate_connected_rek(const int *arr_i_brick4link, const *arr_j_brick4link, int n_link, int n_link_set, Graph &graph, Performer<Graph> &performer) {

  if (n_link==n_link_set) {
    if (graph.is_connected()) {
      return performer.perform(graph);
    } else {
      return true;
    }
  }

  int i_brick = arr_i_brick4link[n_link_set];
  int j_brick = arr_j_brick4link[n_link_set];
  graph.set_linked(i_brick, j_brick, false); if (!iterate_connected_rek(arr_i_brick4link, arr_j_brick4link, n_link, n_link_set+1, graph, performer)) return false;
  graph.set_linked(i_brick, j_brick, true ); if (!iterate_connected_rek(arr_i_brick4link, arr_j_brick4link, n_link, n_link_set+1, graph, performer)) return false;
  return true;
}

/* --- comp_perm_rek --- */

static void comp_perm_rek(int a[N_BRICK_MAX][N_BRICK_MAX], int b[N_BRICK_MAX][N_BRICK_MAX], int n_brick, bool arr_used[N_BRICK_MAX], int n_set, bool &found, int perm[N_BRICK_MAX]) {

  if (n_set==n_brick) {
    found=true;
    return;
  }


  int i_brick=n_set, i_brick_perm;
  for (i_brick_perm=0; i_brick_perm<n_brick; ++i_brick_perm) {
    bool &used=arr_used[i_brick_perm];
    if (used) continue;

    bool ok=true;
    int j_brick;
    for (j_brick=0; j_brick<i_brick; ++j_brick) {
      if (a[i_brick][j_brick]!=b[i_brick_perm][perm[j_brick]]) {
        ok=false;
        break;
      }
    }
    if (!ok) continue;

    used=true;
    perm[i_brick] = i_brick_perm;
    comp_perm_rek(a,b,n_brick, arr_used, n_set+1, found, perm);
    used=false;

    if (found) return;
  }

  found=false;
}

/* --- setup_grp --- */

// computes the group numbers from the neighbourhood

static void setup_grp(Neighbourhood arr_desc[N_BRICK_MAX], int n_brick, int arr_i_brick_start4grp[N_BRICK_MAX], int &n_grp) {

  // Sort by neighbourhood properties
  qsort(arr_desc, n_brick, sizeof(arr_desc[0]), &cmp_desc_neighbourhood4arr4grp_qsort);

  // Renumber groups
  int i_brick;
  if (n_brick>0) {
    arr_desc[0].i_grp=0;
    arr_i_brick_start4grp[0] = 0;
  }
  for (i_brick=1; i_brick<n_brick; ++i_brick) {
    Neighbourhood &current = arr_desc[i_brick], &prev = arr_desc[i_brick-1];
    if (cmp4arr4grp(current, prev)==0) {
      current.i_grp = prev.i_grp;
    } else {
      current.i_grp = prev.i_grp+1;
      arr_i_brick_start4grp[current.i_grp] = i_brick;
    }
  }

  // set n_grp
  if (n_brick==0) {
    n_grp=0;
  } else {
    n_grp = arr_desc[n_brick-1].i_grp+1;
  }
}

/* --- cmp_desc_neighbourhood4arr4grp_qsort --- */

static int cmp_desc_neighbourhood4arr4grp_qsort(const void *ptr_a, const void *ptr_b) {
  return cmp4arr4grp(*(const Neighbourhood*)ptr_a, *(const Neighbourhood*)ptr_b);
}

/* --- setup_arr_desc_neighbourhood --- */

static void setup_arr_desc_neighbourhood(Neighbourhood arr_desc[N_BRICK_MAX], int mat_origin[N_BRICK_MAX][N_BRICK_MAX], int n_brick) {

  // Initialize arr_desc[*].arr4grp
  int n_grp = (n_brick==0 ? 0 : arr_desc[n_brick-1].i_grp+1), i_brick, i_grp;
  for (i_brick=0; i_brick<n_brick; ++i_brick) {
    Neighbourhood &desc = arr_desc[i_brick];
    desc.n_grp=n_grp;
    for (i_grp=0; i_grp<n_grp; ++i_grp) {
      Neighbourhood4Grp &desc4grp = desc.arr4grp[i_grp];
      desc4grp.n_overlap = desc4grp.n_nooverlap = desc4grp.n_mayoverlap = 0;
    }
  }

  // Count neighbours
  int i_brick_neighbour;
  for (i_brick=0; i_brick<n_brick; ++i_brick) {
    Neighbourhood &desc = arr_desc[i_brick];
    for (i_brick_neighbour=0; i_brick_neighbour<n_brick; ++i_brick_neighbour) if (i_brick!=i_brick_neighbour) {
      Neighbourhood &desc_neighbour = arr_desc[i_brick_neighbour];
      Neighbourhood4Grp &desc4grp = desc.arr4grp[desc_neighbour.i_grp];
      switch (mat_origin[desc.i_brick_origin][desc_neighbour.i_brick_origin]) {
        case OVERLAP_BRICK   : ++desc4grp.n_overlap   ; break;
        case NOOVERLAP_BRICK : ++desc4grp.n_nooverlap ; break;
        case MAYOVERLAP_BRICK: ++desc4grp.n_mayoverlap; break;
      }
    }
  }
}

/* --- apply_perm --- */

static void apply_perm(int in[N_BRICK_MAX][N_BRICK_MAX], const int perm[N_BRICK_MAX], int n_brick, int out[N_BRICK_MAX][N_BRICK_MAX]) {
  int i_brick, j_brick;
  for (i_brick=0; i_brick<n_brick; ++i_brick) {
    for (j_brick=0; j_brick<i_brick; ++j_brick) {
      int i_brick_perm = perm[i_brick];
      int j_brick_perm = perm[j_brick];
      out[i_brick_perm][j_brick_perm] = in[i_brick][j_brick];
      out[j_brick_perm][i_brick_perm] = in[j_brick][i_brick];
    }
  }
}

/* --- comp_graph_min_rek --- */

static void comp_graph_min_rek(
  int n_brick,
  int arr_n_overlap_left4row[N_BRICK_MAX], int arr_n_nooverlap_left4row[N_BRICK_MAX], int arr_n_mayoverlap_left4row[N_BRICK_MAX],
  int arr_n_overlap_left4col[N_BRICK_MAX], int arr_n_nooverlap_left4col[N_BRICK_MAX], int arr_n_mayoverlap_left4col[N_BRICK_MAX],
  const int arr_i_brick4link[N_BRICK_MAX], const int arr_j_brick4link[N_BRICK_MAX], int n_link_set, int n_link,
  bool &found, int mat_overlap[N_BRICK_MAX][N_BRICK_MAX]
) {

  if (n_link_set==n_link) {
    found=true;
    return;
  }

  int i_brick_next = arr_i_brick4link[n_link_set];
  int j_brick_next = arr_j_brick4link[n_link_set];
  int &overlap       = mat_overlap[i_brick_next][j_brick_next];
  int &overlap_trans = mat_overlap[j_brick_next][i_brick_next];

  // Overlap ?
  { int &n_overlap_left4row = arr_n_overlap_left4row[i_brick_next], &n_overlap_left4row_trans = arr_n_overlap_left4row[j_brick_next];
    int &n_overlap_left4col = arr_n_overlap_left4col[j_brick_next], &n_overlap_left4col_trans = arr_n_overlap_left4col[i_brick_next];
    if (n_overlap_left4row>0 && n_overlap_left4col>0) {
      --n_overlap_left4row; --n_overlap_left4row_trans;
      --n_overlap_left4col; --n_overlap_left4col_trans;
      overlap = overlap_trans = OVERLAP_BRICK;
      comp_graph_min_rek(
        n_brick,
        arr_n_overlap_left4row, arr_n_nooverlap_left4row, arr_n_mayoverlap_left4row,
        arr_n_overlap_left4col, arr_n_nooverlap_left4col, arr_n_mayoverlap_left4col,
        arr_i_brick4link, arr_j_brick4link, n_link_set+1, n_link,
        found, mat_overlap
      );
      ++n_overlap_left4row; ++n_overlap_left4row_trans;
      ++n_overlap_left4col; ++n_overlap_left4col_trans;
      if (found) return;
    }
  }

  // No Overlap ?
  { int &n_nooverlap_left4row = arr_n_nooverlap_left4row[i_brick_next], &n_nooverlap_left4row_trans = arr_n_nooverlap_left4row[j_brick_next];
    int &n_nooverlap_left4col = arr_n_nooverlap_left4col[j_brick_next], &n_nooverlap_left4col_trans = arr_n_nooverlap_left4col[i_brick_next];
    if (n_nooverlap_left4row>0 && n_nooverlap_left4col>0) {
      --n_nooverlap_left4row; --n_nooverlap_left4row_trans;
      --n_nooverlap_left4col; --n_nooverlap_left4col_trans;
      overlap = overlap_trans = NOOVERLAP_BRICK;
      comp_graph_min_rek(
        n_brick,
        arr_n_overlap_left4row, arr_n_nooverlap_left4row, arr_n_mayoverlap_left4row,
        arr_n_overlap_left4col, arr_n_nooverlap_left4col, arr_n_mayoverlap_left4col,
        arr_i_brick4link, arr_j_brick4link, n_link_set+1, n_link,
        found, mat_overlap
      );
      ++n_nooverlap_left4row; ++n_nooverlap_left4row_trans;
      ++n_nooverlap_left4col; ++n_nooverlap_left4col_trans;
      if (found) return;
    }
  }

  // May Overlap ?
  { int &n_mayoverlap_left4row = arr_n_mayoverlap_left4row[i_brick_next], &n_mayoverlap_left4row_trans = arr_n_mayoverlap_left4row[j_brick_next];
    int &n_mayoverlap_left4col = arr_n_mayoverlap_left4col[j_brick_next], &n_mayoverlap_left4col_trans = arr_n_mayoverlap_left4col[i_brick_next];
    if (n_mayoverlap_left4row>0 && n_mayoverlap_left4col>0) {
      --n_mayoverlap_left4row; --n_mayoverlap_left4row_trans;
      --n_mayoverlap_left4col; --n_mayoverlap_left4col_trans;
      overlap = overlap_trans = MAYOVERLAP_BRICK;
      comp_graph_min_rek(
        n_brick,
        arr_n_overlap_left4row, arr_n_nooverlap_left4row, arr_n_mayoverlap_left4row,
        arr_n_overlap_left4col, arr_n_nooverlap_left4col, arr_n_mayoverlap_left4col,
        arr_i_brick4link, arr_j_brick4link, n_link_set+1, n_link,
        found, mat_overlap
      );
      ++n_mayoverlap_left4row; ++n_mayoverlap_left4row_trans;
      ++n_mayoverlap_left4col; ++n_mayoverlap_left4col_trans;
      if (found) return;
    }
  }

  found=false;
}

/* --- narrow_rek --- */

static void narrow_rek(
  bool mat[N_BRICK_MAX][N_BRICK_MAX], int n_brick,
  bool arr_used[N_BRICK_MAX], int perm_used[N_BRICK_MAX], int n_used,
  int width_used, // max_(used nodes u) (Number of links from u to some successor)
  int n_link_used2unused, // Number of links from used to unused nodes
  int arr_n_neighbour2unused[N_BRICK_MAX], int arr_n_neighbour2used[N_BRICK_MAX],
  int lb, int ub, // Lower and opper bound of widht
  bool &found, // output: was a permutation foudn such that the width of the permutated graph is not above <ub>?
  int perm_min[N_BRICK_MAX], // output: node i of input graph gets node <perm[i]> of output graph
  int &width_min
) {
  int n_byte_copy=sizeof(int)*n_brick;

  found=false;

  // All nodes set?
  if (n_used==n_brick) {
    if (width_used<=ub) {
      found=true;
      memcpy(perm_min, perm_used, n_byte_copy);
      width_min=width_used;
    }
    return;
  }

  // upper bound already exceeded => give up
  if (width_used>ub) return;

  // Recursion loop
  int i_brick_next, i_brick;
  for (i_brick_next=0; i_brick_next<n_brick; ++i_brick_next) {
    bool &used = arr_used[i_brick_next];
    if (used) continue;

    if (n_used>0 && arr_n_neighbour2used[i_brick_next]==0) continue;


    used=true;
    perm_used[i_brick_next] = n_used;

    // Update <arr_n_neighbour2unused> and <arr_n_neighbour2used>
    for (i_brick=0; i_brick<n_brick; ++i_brick) {
      if (i_brick!=i_brick_next && mat[i_brick][i_brick_next]) {
        --arr_n_neighbour2unused[i_brick];
        ++arr_n_neighbour2used  [i_brick];
      }
    }

    int n_link_used2unused_rek=0;
    for (i_brick=0; i_brick<n_brick; ++i_brick) {
      if (arr_used[i_brick] && arr_n_neighbour2unused[i_brick]>0) {
        ++n_link_used2unused_rek;
      }
    }

    int width_used_rek = max_int(width_used, n_link_used2unused_rek);

    // Recursion
    bool found_rek;
    narrow_rek(
      mat, n_brick,
      arr_used, perm_used, n_used+1,
      width_used_rek, n_link_used2unused_rek,
      arr_n_neighbour2unused, arr_n_neighbour2used,
      lb, ub,
      found_rek, perm_min,
      width_min
    );

    // Restore changed fields
    for (i_brick=0; i_brick<n_brick; ++i_brick) {
      if (i_brick!=i_brick_next && mat[i_brick][i_brick_next]) {
        ++arr_n_neighbour2unused[i_brick];
        --arr_n_neighbour2used  [i_brick];
      }
    }
    used=false;

    // Solution found ?
    if (found_rek) {
      found=true;
      if (width_min<=lb) { // Stop search, because result cannot be improved anymode
        break;
      }
      ub=width_min-1; // Query for better solutions only
    }
  }
}


////////////////
// FILE str.h //
////////////////

// From c:\consql


///////////////////
// FILE bigint.h //
///////////////////

// From lego4



//////////////////
// FILE log.cpp //
//////////////////

/* --- declare static functions --- */

static void print_time(FILE*);

/* --- static fields --- */

static int time_log_last=0;
static Logger logger;


/* === Logger ============================================================ */

/* --- open --- */

void Logger::open() {
  if (opened) return;

  f = fopen(NAME_LOGFILE, "at");
  opened=true;
  if (f) print_time(f);
}

/* --- close --- */

void Logger::close() {
  if (!opened) return;
  if (f) {
    putc('\n',f);
    fclose(f);
  }
  opened=false;
  putchar('\n');
}

/* --- constructor --- */

Logger::Logger() : opened(false) {}

/* --- err_write --- */

bool Logger::err_write() {
  return false; // No comment is given when logging failed
}

/* --- err_write --- */

bool Logger::print_char(char c) {
  putchar(c);
  if (f) putc(c,f);
  return true;
}


/* === exported functions ================================================ */

/* --- log_progress_start(MSG) --- */

void log_progress_start(const char *msg) {
  time_log_last = time(NULL);
  log(msg);
}

/* --- log_progress_start(MSG, Str) --- */

void log_progress_start(const char *msg, Str prm) {
  time_log_last = time(NULL);
  log(msg, prm);
}

/* --- log_progress_start --- */

void log_progress_start() {
  time_log_last = time(NULL);
}

/* --- log_progress_end --- */

void log_progress_end() {}

/* --- log_progress_end(MSG) --- */

void log_progress_end(const char *msg) {
  log(msg);
}

/* --- log_progress_end(MSG, Str, int) --- */

void log_progress_end(const char *msg, Str prm1, int prm2) {
  log(msg, prm1, prm2);
}

/* --- log_progress_end(MSG, Str) --- */

void log_progress_end(const char *msg, Str prm) {
  log(msg, prm);
}

/* --- log_progress_end(MSG, int) --- */

void log_progress_end(const char *msg, int prm) {
  log(msg, prm);
}

/* --- log_progress(Card64, Card64) --- */

void log_progress(const char *txt, const Card64 &prm1, const Card64 &prm2) {
  time_t tc = time(NULL);
  if (time_log_last+logperiod>tc) return;
  time_log_last = tc;

  if (prm2.is_zero()) return;

  double percent = 100.0*prm1.to_dbl()/prm2.to_dbl();
  char buff_percent[20];
  sprintf(buff_percent, "%10.5f%%", percent);

  char txt1[1024];
  sprintf(txt1, "Progress: %s", txt);

  log(txt1, prm1, prm2, buff_percent);
}

/* --- log_progress_imm(Card64, Card64) --- */

void log_progress_imm(const char *txt, const Card64 &prm1, const Card64 &prm2) {
  if (prm2.is_zero()) return;

  double percent = 100.0*prm1.to_dbl()/prm2.to_dbl();
  char buff_percent[20];
  sprintf(buff_percent, "%10.5f%%", percent);

  char txt1[1024];
  sprintf(txt1, "Progress: %s", txt);

  log(txt1, prm1, prm2, buff_percent);
}

/* --- log_progress(int, int) --- */

void log_progress(const char *txt, int prm1, int prm2) {
  time_t tc = time(NULL);
  if (time_log_last+logperiod>tc) return;
  time_log_last = tc;

  if (prm2<=0) return;

  double percent = 100.0*double(prm1)/double(prm2);
  char buff_percent[20];
  sprintf(buff_percent, "%10.5f%%", percent);

  char txt1[1024];
  sprintf(txt1, "Progress: %s", txt);

  log(txt1, prm1, prm2, buff_percent);
}

/* --- log_progress(Str, NTS) --- */

void log_progress(const char *txt, Str prm1, const char *prm2) {
  time_t tc = time(NULL);
  if (time_log_last+logperiod>tc) return;
  time_log_last = tc;

  char txt1[1024];
  sprintf(txt1, "Progress: %s", txt);

  log(txt1, prm1, prm2);
}

/* --- log(Str, Card64) --- */

void log(const char *txt, Str prm1, Card64 prm2) {
  logger.open();
  logger.printf(txt, prm1, prm2);
  logger.close();
}

/* --- log(Str, Str, Str, int) --- */

void log(char const *txt, Str prm1, Str prm2, Str prm3, int prm4) {
  logger.open();
  logger.printf(txt, prm1, prm2, prm3, prm4);
  logger.close();
}

/* --- log(Str, Str, int) --- */

void log(char const *txt, Str prm1, Str prm2, int prm3) {
  logger.open();
  logger.printf(txt, prm1, prm2, prm3);
  logger.close();
}

/* --- log(Str, Str, Str) --- */

void log(char const *txt, Str prm1, Str prm2, Str prm3) {
  logger.open();
  logger.printf(txt, prm1, prm2, prm3);
  logger.close();
}

/* --- log(Str) --- */

void log(Str txt) {
  logger.open();
  logger.print(txt);
  logger.close();
}

/* --- log(int, int, NTS) --- */

void log(const char *txt, int prm1, int prm2, const char *prm3) {
  logger.open();
  logger.printf(txt, prm1, prm2, prm3);
  logger.close();
}

/* --- log(Card64, Card64, NTS) --- */

void log(const char *txt, const Card64 &prm1, const Card64 &prm2, const char *prm3) {
  logger.open();
  logger.printf(txt, prm1, prm2, prm3);
  logger.close();
}

/* --- log(NTS, int) --- */

void log(const char *txt, const char *prm1, int prm2) {
  logger.open();
  logger.printf(txt, prm1, prm2);
  logger.close();
}

/* --- log(NTS, int) --- */

void log(const char *txt, int prm1, int prm2, int prm3, int prm4) {
  logger.open();
  logger.printf(txt, prm1, prm2, prm3, prm4);
  logger.close();
}

/* --- log(NTS) --- */

void log(const char *txt, const char *prm) {
  logger.open();
  logger.printf(txt, prm);
  logger.close();
}

/* --- log(Str, int) --- */

void log(const char *txt, Str prm1, int prm2) {
  logger.open();
  logger.printf(txt, prm1, prm2);
  logger.close();
}

/* --- log(int, int) --- */

void log(const char *txt, int prm1, int prm2) {
  logger.open();
  logger.printf(txt, prm1, prm2);
  logger.close();
}

/* --- log(int) --- */

void log(const char *txt, int prm) {
  logger.open();
  logger.printf(txt, prm);
  logger.close();
}

/* --- log(NTS) --- */

void log(const char *txt) {
  log(Str(txt));
}

/* --- log(Str, Str) --- */

void log(const char *txt, Str prm1, Str prm2) {
  logger.open();
  logger.printf(txt, prm1, prm2);
  logger.close();
}

/* --- log(Str, Str, Str, Str) --- */

void log(const char *txt, Str prm1, Str prm2, Str prm3, Str prm4) {
  logger.open();
  logger.printf(txt, prm1, prm2, prm3, prm4);
  logger.close();
}

/* --- log(Str, Str, Str, Str, int) --- */

void log(const char *txt, Str prm1, Str prm2, Str prm3, Str prm4, int prm5) {
  logger.open();
  logger.printf(txt, prm1, prm2, prm3, prm4, prm5);
  logger.close();
}

/* --- log(int, int, int, int, int) --- */

void log(const char *txt, int prm1, int prm2, int prm3, int prm4, int prm5) {
  logger.open();
  logger.printf(txt, prm1, prm2, prm3, prm4, prm5);
  logger.close();
}

/* --- log(Str) --- */

void log(const char *txt, Str prm) {
  logger.open();
  logger.printf(txt, prm);
  logger.close();
}


/* === static functions ================================================== */

/* --- print_time(FILE) --- */

void print_time(FILE *f) {
  time_t tc = time(NULL);
  struct tm *ptr_tmc = localtime(&tc);
  struct tm &tmc = *ptr_tmc;
  fprintf(
    f,
    "%04d-%02d-%02d %02d:%02d:%02d: ",
    tmc.tm_year + 1900,
    tmc.tm_mon  + 1   ,
    tmc.tm_mday       ,
    tmc.tm_hour       ,
    tmc.tm_min        ,
    tmc.tm_sec
  );
}



////////////////
// FILE str.h //
////////////////

// From c:\consql


///////////////////
// FILE bigint.h //
///////////////////

// From lego4


////////////////////
// FILE setimpl.h //
////////////////////

// From c:\kombin\lego2\footprnt


////////////////////
// FILE mapimpl.h //
////////////////////

// Taken fron lego4




///////////////////
// FILE main.cpp //
///////////////////

/* --- declare static functions --- */

static int print_usage4exit();
static void print_usage();
static void handler4sigint(int);
static void help_fam_graph4part();
static void help_part();
static void help_famgraph();
static void help_export_db();
static void help_import_db();
static void help_rep_fam_graph4part();
static void help_n_pos4part();
static void help_fig_sym44part();
static void help_fig_sym24part();
static void help_mirrorfun();
static void help_n_fig4n_brick();
static void help_graph4n_brick();
static void help_graph_no_prohibe_link4part();
static void help_fam_graph_nooverlap4part();
static void help_n_fig_rot4n_brick();
static void help_n_fig_rot_sym24n_brick();
static void help_n_fig_rot_sym44n_brick();
static void help_n_fig4n_brick();
static void log_start(int n_arg, char **arr_arg);
static int log_end(bool ok, bool complete, int n_arg, char **arr_arg);
static void help();
static void help_make();
static void help_delete();
static bool print_fun_mirror(const Part&, const FamGraph&);
static bool get_logperiod(char **arr_arg, int n_arg, int &i_arg);
static bool get_opt_bottom1(char **arr_arg, int n_arg, int &i_arg, bool &bottom1);
static bool get_size_cache_max(char **arr_arg, int n_arg, int &i_arg, int &size_cache_max);
static bool get_n_max4map(char **arr_arg, int n_arg, int &i_arg, int &n_max4map);
static bool get_opt_pipe(char **arr_arg, int n_arg, int &i_arg, bool &pipe, int &size_buff);
static Str concat_arg(int n_arg, char **arr_arg);
static bool make_fam_graph4part(const Part&, const Str &path_dir, bool &complete);
static bool make_rep_fam_graph4part(const Part&, const Str &path_dir, bool &complete);
static bool make_graph_no_prohibe_link4part(const Part&, const Str &path_dir, int n_max4map, bool &complete, bool pipe, int size_buff_pipe);
static bool check_fam_graph_nooverlap4part_nlink_max(const Str &path_dir, const Str &filename, int n_brick);
static bool check_fam_graph_nooverlap4part_nlink_max(FILE*, const Str &path, int n_brick);
static bool make_fam_graph_nooverlap4part_nlink_max(const Part&, int n_link_max, int n_max4map, bool pippe, int size_buff_pipe, const Str &path_dir, bool &complete);
static bool make_fam_graph_nooverlap4part_nlink_max_nomerge(const Part &part, int n_link, int n_max4map, int size_buff_pipe, const Str &path_dir, bool &complete);
static bool make_n_fig_rot4n_brick     (int n_brick, const Str &path_dir, bool &complete, int size_cache_max, int n_max4map, bool pipe, int size_buff_pipe);
static bool make_graph4n_brick         (int n_brick, const Str &path_dir, bool &complete);
static bool make_n_fig_rot_sym24n_brick(int n_brick, const Str &path_dir, bool &complete);
static bool make_n_fig_rot_sym44n_brick(int n_brick, const Str &path_dir, bool &complete);
static bool make_n_fig4n_brick         (int n_brick, const Str &path_dir, bool &complete, int size_cache_max, int n_max4map, bool pipe, int size_buff_pipe);
static bool make_fig_sym24part(const Part&, const Str &path_dir, bool &complete);
static bool make_fig_sym44part(const Part&, const Str &path_dir, bool &complete);
static bool make_n_fig4part(const Part&, const Str &path_dir, int size_cache_max, int n_max4map, bool pipe, int size_buff_pipe, bool &complete);
static bool delete_fam_graph_nooverlap4part_nlink_max(const Part&, int n_link_max, const Str &path_dir);
static bool delete_fam_graph_nooverlap4part_nlink_max_nomerge(const Part&, int n_link_max, const Str &path_dir);
static bool print_part_needed(int n_brick);
static bool print_progress(int n_brick, const Str &path);
static bool print_perm4part(const Part&);
static bool print_rep(const Graph&);
static bool import_db(int n_brick, const Str &path_dir, const Str &path_in);
static bool import_db(int n_brick, Access2Db&, CompGraph4NBrick&, In&);
static bool export_db(int n_brick, const Str &path_dir, const Str &path_exclude, const Str &path_out);
static bool export_db(int n_brick, Access2Db&, bool *arr_exclude, CompGraph4NBrick&, Out&);
static bool export_bmp_db(int n_brick, const Str &path_dir, const Str &path);
static bool export_bmp_db(int n_brick, Access2Db&, CompGraph4NBrick&, Out&);
static bool print_n_fig4n_brick(int n_brick, const Str &path_dir, bool &complete, bool bottom1, int size_cache_max, int n_max4map, bool pipe, int size_buff_pipe);
static bool print1_n_pos4graph(const Graph&, int size_cache_max);
static bool read_evtl_fam_graph_nooverlap_part_n_link_i_block(const Str &filename, Part&, int &n_link_max, int &i_block);
static bool check_seq_famgraph_fac64(const Str &path_dir, const Str &filename, int n_brick);
static bool check_seq_famgraph_fac64(FILE*, const Str &path, int n_brick);
static bool flush_hex(int hex, int &n_hex4line, Out&);
static bool read_bmp4graph(int n_brick, const Str &path, bool *&arr);

/* --- global fields --- */

bool signalled_stop=false;
int n_step_max;
int logperiod=LOGPERIOD_DEFAULT;

/* --- main --- */

int main(int n_arg, char **arr_arg) {
  FKT "main";

  if (!(L_BRICK>=W_BRICK && W_BRICK>0)) errstop(fkt, "!(L_BRICK>=W_BRICK && W_BRICK>0)");
  if (sizeof(DWORD)!=4) errstop(fkt, "sizeof(DWORD)!=4");

  // Get command
  char *cmd;
  if (n_arg<2) {
    pl("To few command line arguments.");
    return print_usage4exit();
  }
  cmd = arr_arg[1];

  // -test $subject
  if (strcmp(cmd, "-test")==0) {

    char *subject;
    if (n_arg<3) {
      pl("Too few arguments");
      return 1;
    }
    subject = arr_arg[2];

    if (strcmp(subject, "i128")==0) {
      test128();
      return 0;
    }

    if (strcmp(subject, "c64")==0) {
      testc64();
      return 0;
    }

    if (strcmp(subject, "i64")==0) {
      testi64();
      return 0;
    }

    if (strcmp(subject, "sym4")==0) {
      testsym4();
      return 0;
    }

    if (strcmp(subject, "zyk5")==0) {
      unsigned int x=1U, n_mul=0U;
      do {
        x*=5U;
        ++n_mul;
        if (n_mul%10000U==0U) printf("%08x\n", n_mul);
      } while (x!=1U);
      printf("%08x Multiplications\n", n_mul);

      return 0;
    }

    pl("Invalid test suite after \"-test\"");
    return 1;
  } // -test

  // -addfileclause $filename $dir (undocumented feature)
  bool ok;
  if (strcmp(cmd, "-addfileclause")==0) {

    // $filename $dir
    Str filename, path_dir;
    if (n_arg!=4) return err("Wrong number of arguments");
    filename=arr_arg[2];
    path_dir=arr_arg[3];

    // -addfileclause repfamgraph4part($part).dat $dir
    Part part;
    if (CompRepFamGraph4Part::read_evtl_filename4result(filename, part)) {
      CompRepFamGraph4Part comp(part, path_dir);
      if (!comp.add_fileclause()) return 1;
      log("Inserted filename into file \"$\".", filename);
      return 0;
    }

    // -addfileclause famgraph4part($part).dat $dir
    if (CompFamGraph4Part::read_evtl_filename4result(filename, part)) {
      CompFamGraph4Part comp(part, path_dir);
      if (!comp.add_fileclause()) return 1;
      log("Inserted filename into file \"$\".", filename);
      return 0;
    }

    // -addfileclause graph_no_prohibe_link4part($part).dat $dir
    if (CompGraphNoProhibeLink4Part::read_evtl_filename4result(filename, part)) {
      CompGraphNoProhibeLink4Part comp(part, 100, path_dir, false, 0);
      if (!comp.add_fileclause()) return 1;
      log("Inserted filename into file \"$\".", filename);
      return 0;
    }

    // -addfileclause nfig4nbrick($nbrick).dat $dir
    int n_brick;
    if (CompNFig4NBrick::read_evtl_filename4result(filename, n_brick)) {
      CompNFig4NBrick comp(n_brick, path_dir, 100, 10, false, 0);
      if (!comp.add_fileclause()) return 1;
      log("Inserted filename into file \"$\".", filename);
      return 0;
    }

    pl("Invalid filename after -addfileclause");
    return 1;
  }

  // -check $filename $dir
  if (strcmp(cmd, "-check")==0) {

    if (n_arg!=4) return print_usage4exit();

    Str filename=arr_arg[2];
    Str path_dir=arr_arg[3];

    // -check fam_graph_nooverlap4part($part)nlinkmax($nlink).dat $dir
    int n_link_max;
    Part part;
    if (CompFamGraphNooverlap4PartNLinkMax::read_evtl_filename4result(filename, part, n_link_max)) {
      log_start(n_arg, arr_arg);
      ok=check_fam_graph_nooverlap4part_nlink_max(path_dir, filename, part.get_n_brick());
      return log_end(ok,true, n_arg, arr_arg);
    }

    // -check fam_graph_nooverlap4part($part)nlink($nlink)block($iblock).dat $dir
    int i_block;
    if (read_evtl_fam_graph_nooverlap_part_n_link_i_block(filename, part, n_link_max, i_block)) {
      log_start(n_arg, arr_arg);
      ok=check_seq_famgraph_fac64(path_dir, filename, part.get_n_brick());
      return log_end(ok,true, n_arg, arr_arg);
    }

    pl(Str("Invalid filename after \"-check\": ") + filename);
    return print_usage4exit();
  } // -check

  // -make [-logperiod $nsec] [-cachesize $size] [-mapsize $size] [-pipe] [-buffsize $size] [-nstepmax $nstepmax] $filename $dir
  bool complete=false;
  if (strcmp(cmd, "-make")==0) {

    // [-logperiod $nsec]
    int i_arg=2;
    if (!get_logperiod(arr_arg, n_arg, i_arg)) return print_usage4exit();

    // [-cachesize $size]
    int size_cache_max;
    if (!get_size_cache_max(arr_arg, n_arg, i_arg, size_cache_max)) return print_usage4exit();

    // [-mapsize $size]
    int n_max4map;
    if (!get_n_max4map(arr_arg, n_arg, i_arg, n_max4map)) return print_usage4exit();

    // [-pipe] [-buffsize $size]
    bool pipe;
    int size_buff_pipe;
    if (!get_opt_pipe(arr_arg, n_arg, i_arg, pipe, size_buff_pipe)) return print_usage4exit();

    // [-nstepmax $nstepmax]
    n_step_max=-1;
    if (i_arg<n_arg && strcmp(arr_arg[i_arg], "-nstepmax")==0) {

      ++i_arg;
      if (i_arg>=n_arg) {
        pl("Number after -nstepmax is missing.");
        return print_usage4exit();
      }

      In4Str in_arg(arr_arg[i_arg]);
      if (!in_arg.read_evtl_card(n_step_max) || !in_arg.at_end()) {
        pl("Number after -nstepmax is invalid.");
        return print_usage4exit();
      }
      ++i_arg;
    }

    // $filename $dir
    Str filename, path_dir;
    if (i_arg+2>n_arg) return print_usage4exit();
    filename=arr_arg[i_arg  ];
    path_dir=arr_arg[i_arg+1];

    // -make famgraph4part($part).dat $dir
    Part part;
    if (CompFamGraph4Part::read_evtl_filename4result(filename, part)) {
      log_start(n_arg, arr_arg);
      ok=make_fam_graph4part(part, path_dir, complete);
      return log_end(ok,complete, n_arg, arr_arg);
    }

    // -make repfamgraph4part($part).dat $dir
    if (CompRepFamGraph4Part::read_evtl_filename4result(filename, part)) {
      log_start(n_arg, arr_arg);
      ok=make_rep_fam_graph4part(part, path_dir, complete);
      return log_end(ok,complete, n_arg, arr_arg);
    }

    // -make npos4part($part).dat $dir
    if (CompNPos4Part::read_evtl_filename4result(filename, part)) {

      log_start(n_arg, arr_arg);
      ok=make_n_fig4part(part, path_dir, size_cache_max, n_max4map, pipe, size_buff_pipe, complete);
      return log_end(ok,complete, n_arg, arr_arg);
    }

    // -make graph_no_prohibe_link4part($part).dat $dir
    if (CompGraphNoProhibeLink4Part::read_evtl_filename4result(filename, part)) {
      log_start(n_arg, arr_arg);
      ok=make_graph_no_prohibe_link4part(part, path_dir, n_max4map, complete, pipe, size_buff_pipe);
      return log_end(ok,complete, n_arg, arr_arg);
    }

    // -make fam_graph_nooverlap4part($part)nlinkmax($nlink).dat $dir
    int n_link_max;
    if (CompFamGraphNooverlap4PartNLinkMax::read_evtl_filename4result(filename, part, n_link_max)) {
      log_start(n_arg, arr_arg);
      ok=make_fam_graph_nooverlap4part_nlink_max(part, n_link_max, n_max4map, pipe, size_buff_pipe, path_dir, complete);
      return log_end(ok,complete, n_arg, arr_arg);
    }

    // -make fam_graph_nooverlap4part($part)nlinkmax($nlink)nomerge.dat $dir
    if (CompFamGraphNooverlap4PartNLinkMaxNomerge::read_evtl_filename4result(filename, part, n_link_max)) {
      log_start(n_arg, arr_arg);
      ok=make_fam_graph_nooverlap4part_nlink_max_nomerge(part, n_link_max, n_max4map, size_buff_pipe, path_dir, complete);
      return log_end(ok,complete, n_arg, arr_arg);
    }

    // -make nrotfig4nbrick($nbrick).dat $dir
    int n_brick;
    if (CompNFigRot4NBrick::read_evtl_filename4result(filename, n_brick)) {
      log_start(n_arg, arr_arg);
      ok=make_n_fig_rot4n_brick(n_brick, path_dir, complete, size_cache_max, n_max4map, pipe, size_buff_pipe);
      return log_end(ok,complete, n_arg, arr_arg);
    }

    // -make graph4nbrick($nbrick).dat $dir
    if (CompGraph4NBrick::read_evtl_filename4result(filename, n_brick)) {
      log_start(n_arg, arr_arg);
      ok=make_graph4n_brick(n_brick, path_dir, complete);
      return log_end(ok,complete, n_arg, arr_arg);
    }

    // -make nsym2rotfig4nbrick($nbrick).dat $dir
    if (CompNFigRotSym24NBrick::read_evtl_filename4result(filename, n_brick)) {
      log_start(n_arg, arr_arg);
      ok=make_n_fig_rot_sym24n_brick(n_brick, path_dir, complete);
      return log_end(ok,complete, n_arg, arr_arg);
    }

    // -make nsym4rotfig4nbrick($nbrick).dat $dir
    if (CompNFigRotSym44NBrick::read_evtl_filename4result(filename, n_brick)) {
      log_start(n_arg, arr_arg);
      ok=make_n_fig_rot_sym44n_brick(n_brick, path_dir, complete);
      return log_end(ok,complete, n_arg, arr_arg);
    }

    // -make sym2rotfig4part($part).dat $dir
    if (CompFigRotSym24Part::read_evtl_filename4result(filename, part)) {
      log_start(n_arg, arr_arg);
      ok=make_fig_sym24part(part, path_dir, complete);
      return log_end(ok,complete, n_arg, arr_arg);
    }

    // -make sym4rotfig4part($part).dat $dir
    if (CompFigRotSym44Part::read_evtl_filename4result(filename, part)) {
      log_start(n_arg, arr_arg);
      ok=make_fig_sym44part(part, path_dir, complete);
      return log_end(ok,complete, n_arg, arr_arg);
    }

    // -make nfig4nbrick($nbrick).dat $dir
    if (CompNFig4NBrick::read_evtl_filename4result(filename, n_brick)) {
      log_start(n_arg, arr_arg);
      ok=make_n_fig4n_brick(n_brick, path_dir, complete, size_cache_max, n_max4map, pipe, size_buff_pipe);
      return log_end(ok,complete, n_arg, arr_arg);
    }

    pl(Str("Invalid filename after \"-make\": ") + filename);
    return print_usage4exit();
  } // -make

  // -delete $filename $dir
  if (strcmp(cmd, "-delete")==0) {

    // $filename $dir
    Str filename, path_dir;
    if (n_arg!=4) return print_usage4exit();
    filename=arr_arg[2];
    path_dir=arr_arg[3];

    // $filename = fam_graph_nooverlap4part($part)nlinkmax($nlink).dat
    int n_link_max;
    Part part;
    if (CompFamGraphNooverlap4PartNLinkMax::read_evtl_filename4result(filename, part, n_link_max)) {
      log_start(n_arg, arr_arg);
      ok=delete_fam_graph_nooverlap4part_nlink_max(part, n_link_max, path_dir);
      return log_end(ok,true, n_arg, arr_arg);
    }

    // $filename = fam_graph_nooverlap4part($part)nlinkmax($nlink)nomerge.dat
    if (CompFamGraphNooverlap4PartNLinkMaxNomerge::read_evtl_filename4result(filename, part, n_link_max)) {
      log_start(n_arg, arr_arg);
      ok=delete_fam_graph_nooverlap4part_nlink_max_nomerge(part, n_link_max, path_dir);
      return log_end(ok,true, n_arg, arr_arg);
    }

    pl(Str("Invalid file name after \"-delete\": ") + filename);
    return print_usage4exit();
  } // -delete


  // -make1 [-logperiod $nsec] [-nstepmax $nstepmax] $filename $dir
  if (strcmp(cmd, "-make1")==0) {

    // [-logperiod $nsec]
    int i_arg=2;
    if (!get_logperiod(arr_arg, n_arg, i_arg)) return print_usage4exit();

    // [-nstepmax $nstepmax]
    n_step_max=-1;
    if (i_arg<n_arg && strcmp(arr_arg[i_arg], "-nstepmax")==0) {

      ++i_arg;
      if (i_arg>=n_arg) {
        pl("Number after -nstepmax is missing.");
        return print_usage4exit();
      }

      In4Str in_arg(arr_arg[i_arg]);
      if (!in_arg.read_evtl_card(n_step_max) || !in_arg.at_end()) {
        pl("Invalid number after -nstepmax");
        return print_usage4exit();
      }
      ++i_arg;
    }

    // $filename $dir
    Str filename, path_dir;
    if (i_arg+2>n_arg) return print_usage4exit();
    filename=arr_arg[i_arg  ];
    path_dir=arr_arg[i_arg+1];

    pl(Str("Invalid filename after \"-make1\": ") + filename);
    return print_usage4exit();
  } // -make

  // -export
  char *subject;
  int n_brick;
  if (strcmp(cmd, "-export")==0) {

    if (n_arg<3) return print_usage4exit();
    subject=arr_arg[2];

    // -export db $nbrick $dir $exclude $out
    if (strcmp(subject, "db")==0) {
      if (n_arg!=7) {
        pl("Wrong number of arguments");
        return print_usage4exit();
      }

      // $nbrick
      In4Str in4n_brick(arr_arg[3]);
      if (!in4n_brick.read_card(n_brick)) return false;
      if (!(1<=n_brick && n_brick<=N_BRICK_MAX)) {
        pl("$nbrick out of range");
        return print_usage4exit();
      }

      // $dir $exclude $out
      Str path_dir, path_exclude, path_out;
      path_dir     = arr_arg[4];
      path_exclude = arr_arg[5];
      path_out     = arr_arg[6];

      log_start(n_arg, arr_arg);
      ok=export_db(n_brick, path_dir, path_exclude, path_out);
      return log_end(ok,true, n_arg, arr_arg);
    }

    // -export dbbmp $nbrick $dir $filename");
    if (strcmp(subject, "dbbmp")==0) {
      if (n_arg!=6) {
        pl("Wrong number of arguments");
        return print_usage4exit();
      }

      // nbrick
      In4Str in4n_brick(arr_arg[3]);
      if (!in4n_brick.read_card(n_brick)) return false;
      if (!(1<=n_brick && n_brick<=N_BRICK_MAX)) {
        pl("$nbrick out of range");
        return print_usage4exit();
      }

      // $dir $filename
      Str filename, path_dir;
      path_dir=arr_arg[4];
      filename=arr_arg[5];

      log_start(n_arg, arr_arg);
      ok=export_bmp_db(n_brick, path_dir, filename);
      return log_end(ok,true, n_arg, arr_arg);
    }

    pl("Invalid argument after -export");
    return print_usage4exit();
  } // -export

  // -import
  if (strcmp(cmd, "-import")==0) {

    if (n_arg<3) return print_usage4exit();
    subject=arr_arg[2];

    // -import db $nbrick $dir $in
    if (strcmp(subject, "db")==0) {
      if (n_arg!=6) {
        pl("Wrong number of arguments");
        return print_usage4exit();
      }

      // $nbrick
      In4Str in4n_brick(arr_arg[3]);
      if (!in4n_brick.read_card(n_brick)) return false;
      if (!(1<=n_brick && n_brick<=N_BRICK_MAX)) {
        pl("$nbrick out of range");
        return print_usage4exit();
      }

      // $dir $in
      Str path_dir, path_in;
      path_dir= arr_arg[4];
      path_in = arr_arg[5];

      log_start(n_arg, arr_arg);
      ok=import_db(n_brick, path_dir, path_in);
      return log_end(ok,true, n_arg, arr_arg);
    }

    pl("Invalid argument after  -export");
    return print_usage4exit();
  } // -import

  // -print
  Str errtxt;
  if (strcmp(cmd, "-print")==0) {

    int i_arg=2;
    if (i_arg>=n_arg) return print_usage4exit();
    subject=arr_arg[i_arg];
    ++i_arg;

    // -print partneeded $nbrick (undocumented feature)
    if (strcmp(subject, "partneeded")==0) {
      if (n_arg!=4) return err("Wrong number of arguments");

      In4Str in4n_brick(arr_arg[3]);

      if (!in4n_brick.read_card(n_brick)) return false;
      if (!(1<=n_brick && n_brick<=N_BRICK_MAX)) {
        pl("$nbrick out of range");
        return print_usage4exit();
      }

      log_start(n_arg, arr_arg);
      ok=print_part_needed(n_brick);
      return log_end(ok,true, n_arg, arr_arg);
    }

    // -print progress $nbrick $dir (undocumented feature)
    if (strcmp(subject, "progress")==0) {
      if (n_arg!=5) return err("Wrong number of arguments");

      In4Str in4n_brick(arr_arg[3]);
      Str path(arr_arg[4]);

      int n_brick;
      if (!in4n_brick.read_card(n_brick)) return false;
      if (!(1<=n_brick && n_brick<=N_BRICK_MAX)) {
        pl("$nbrick out of range");
        return print_usage4exit();
      }

      log_start(n_arg, arr_arg);
      ok=print_progress(n_brick, path);
      return log_end(ok,true, n_arg, arr_arg);
    }

    // -print chksum $file (undocumented feature)
    if (strcmp(subject, "chksum")==0) {
      if (n_arg!=4) return err("Wrong number of arguments");
      Str path(arr_arg[3]);

      In4File in4file;
      if (!in4file.open(path)) return 1;

      InBuffering in_buffered(in4file);
      Chksummer4In chksummer4in(in_buffered);
      while (!chksummer4in.at_end()) ++chksummer4in;
      pl("chksum=%d", chksummer4in.get_chksum_masked());
      if (!in4file.close()) return 1;

      return 0;
    }

    // -print mirrorfun $part $famgraph
    if (strcmp("mirrorfun", subject)==0) {
      if (i_arg+2!=n_arg) return print_usage4exit();

      In4Str in_part(arr_arg[i_arg]);
      Part part;
      if (!read_silent(in_part, part, errtxt)) {
        pl(Str("Invalid partition: ") + errtxt);
        return print_usage4exit();
      }

      FamGraph fam_graph;
      In4Str in_fam_graph(arr_arg[i_arg+1]);
      if (!read_silent(in_fam_graph, part.get_n_brick(), fam_graph, errtxt)) {
        pl(Str("Invalid graph family: ") + errtxt);
        return print_usage4exit();
      }

      if (!fam_graph.is_conform(part)) {
        pl("The given graph family does not comply to the artition.");
        return print_usage4exit();
      }

      log_start(n_arg, arr_arg);
      ok=print_fun_mirror(part, fam_graph);
      return log_end(ok,true, n_arg, arr_arg);
    }

    // -print nfig4nbrick [-bottom1] [-logperiod $nsec] [-cachesize $size] [-mapsize $size] [-pipe] [-buffsize $size] $nbrick $dir");
    if (strcmp("nfig4nbrick", subject)==0) {

      // [-bottom1]
      bool bottom1;
      if (!get_opt_bottom1(arr_arg, n_arg, i_arg, bottom1)) return print_usage4exit();

      // [-logperiod $nsec]
      if (!get_logperiod(arr_arg, n_arg, i_arg)) return print_usage4exit();

      // [-cachesize $size]
      int size_cache_max;
      if (!get_size_cache_max(arr_arg, n_arg, i_arg, size_cache_max)) return print_usage4exit();

      // [-mapsize $size]
      int n_max4map;
      if (!get_n_max4map(arr_arg, n_arg, i_arg, n_max4map)) return print_usage4exit();

      // [-pipe] [-buffsize $size]
      bool pipe;
      int size_buff_pipe;
      if (!get_opt_pipe(arr_arg, n_arg, i_arg, pipe, size_buff_pipe)) return print_usage4exit();

      Str path_dir;
      if (i_arg+2!=n_arg) return print_usage4exit();
      path_dir = arr_arg[i_arg+1];

      In4Str in_n_brick(arr_arg[i_arg]);
      int n_brick;
      if (!in_n_brick.read_card_silent(n_brick, errtxt)) {
        pl(Str("Invalid partition: ") + errtxt);
        return print_usage4exit();
      }
      if (!(1<=n_brick && n_brick<=N_BRICK_MAX)) {
        pl("$nbrick out of range");
        return print_usage4exit();
      }

      bool complete=false;
      log_start(n_arg, arr_arg);
      ok=print_n_fig4n_brick(n_brick, path_dir, complete, bottom1, size_cache_max, n_max4map, pipe, size_buff_pipe);
      return log_end(ok,complete, n_arg, arr_arg);
    }

    // perm4part $part (undocumented feature)
    if (strcmp("perm4part", subject)==0) {
      if (i_arg+2!=n_arg) return print_usage4exit();

      Part part;
      In4Str in_part(arr_arg[i_arg]);
      if (!read_silent(in_part, part, errtxt)) {
        pl(Str("Error in the given partition: ") + errtxt);
        return print_usage4exit();
      }

      if (!print_perm4part(part)) return 1;
      return 0;
    }

    pl("Invalid argument after -print");
    return print_usage4exit();
  } // -print

  // -print1
  if (strcmp(cmd, "-print1")==0) {

    // get subject
    char *subject;
    int i_arg=2;
    if (i_arg>=n_arg) return print_usage4exit();
    subject=arr_arg[i_arg];
    ++i_arg;

    // -print1 npos4graph [-cachesize $size] $nbrick $graph (undocumented feature)
    if (strcmp("npos4graph", subject)==0) {

      // [-cachesize $size]
      int size_cache_max;
      if (!get_size_cache_max(arr_arg, n_arg, i_arg, size_cache_max)) return print_usage4exit();

      // $nbrick
      In4Str in_n_brick(arr_arg[i_arg]);
      int n_brick;
      if (!in_n_brick.read_card_silent(n_brick, errtxt)) {
        pl(Str("Invalid number of  bricks: ") + errtxt);
        return print_usage4exit();
      }
      if (!(1<=n_brick && n_brick<=N_BRICK_MAX)) {
        pl("$nbrick out of range");
        return print_usage4exit();
      }
      ++i_arg;

      // $graph
      Graph graph(n_brick);
      In4Str in_graph(arr_arg[i_arg]);
      if (!read_silent(in_graph, n_brick, graph, errtxt)) {
        pl(Str("Invalid graph: ") + errtxt);
        return print_usage4exit();
      }
      if (!graph.is_connected()) {
        pl("Graph not connected.");
        return print_usage4exit();
      }
      ++i_arg;

      log_start(n_arg, arr_arg);
      ok=print1_n_pos4graph(graph, size_cache_max);
      return log_end(ok,true, n_arg, arr_arg);
    } // -print npos4graph

    pl("Invalid argument after -print");
    return print_usage4exit();
  } // -print1

  // -repgraph $nbrick [$graph] (undocumented feature)
  if (strcmp(cmd, "-repgraph")==0) {

    if (!(4<=n_arg && n_arg<=4)) return print_usage4exit();

    In4Str in_n_brick(arr_arg[2]);
    int n_brick;
    if (!in_n_brick.read_card_silent(n_brick, errtxt)) {
      pl(Str("Invalid partition: ") + errtxt);
      return print_usage4exit();
    }
    if (!(0<=n_brick && n_brick<=N_BRICK_MAX)) {
      pl("$nbrick out of range");
      return print_usage4exit();
    }

    if (n_arg==4) {
      In4Str in_graph(arr_arg[3]);
      Graph graph;
      if (!read_silent(in_graph, n_brick, graph, errtxt)) {
        pl(Str("Invalid graph: ") + errtxt);
        return print_usage4exit();
      }

      log_start(n_arg, arr_arg);
      ok=print_rep(graph);
      return log_end(ok,true, n_arg, arr_arg);
    }
  }

  // -help
  if (strcmp(cmd, "-help")==0) {

    if (n_arg==2) {
      help();
      return 0;
    }

    char *topic;
    if (n_arg!=3) return print_usage4exit();
    topic=arr_arg[2];

    // -help make
    if (strcmp(topic, "make")==0) {
      help_make();
      return 0;
    }

    // -help delete
    if (strcmp(topic, "delete")==0) {
      help_delete();
      return 0;
    }

    // -help exportdb
    if (strcmp(topic, "exportdb")==0) {
      help_export_db();
      return 0;
    }

    // -help importdb
    if (strcmp(topic, "importdb")==0) {
      help_import_db();
      return 0;
    }

    // -help part
    if (strcmp(topic, "part")==0) {
      help_part();
      return 0;
    }

    // -help famgraph
    if (strcmp(topic, "famgraph")==0) {
      help_famgraph();
      return 0;
    }

    // -help famgraph4part
    if (strcmp(topic, "famgraph4part")==0) {
      help_fam_graph4part();
      return 0;
    }

    // -help repfamgraph4part
    if (strcmp(topic, "repfamgraph4part")==0) {
      help_rep_fam_graph4part();
      return 0;
    }

    // -help fam_graph_nooverlap4part
    if (strcmp(topic, "fam_graph_nooverlap4part")==0) {
      help_fam_graph_nooverlap4part();
      return 0;
    }

    // -help npos4part
    if (strcmp(topic, "npos4part")==0) {
      help_n_pos4part();
      return 0;
    }

    // -help graph_no_prohibe_link4part
    if (strcmp(topic, "graph_no_prohibe_link4part")==0) {
      help_graph_no_prohibe_link4part();
      return 0;
    }

    // -help nrotfig4nbrick
    if (strcmp(topic, "nrotfig4nbrick")==0) {
      help_n_fig_rot4n_brick();
      return 0;
    }

    // -help sym4rotfig4part
    if (strcmp(topic, "sym4rotfig4part")==0) {
      help_fig_sym44part();
      return 0;
    }

    // -help sym2rotfig4part
    if (strcmp(topic, "sym2rotfig4part")==0) {
      help_fig_sym24part();
      return 0;
    }

    // -help nsym2rotfig4nbrick
    if (strcmp(topic, "nsym2rotfig4nbrick")==0) {
      help_n_fig_rot_sym24n_brick();
      return 0;
    }

    // -help nsym4rotfig4nbrick
    if (strcmp(topic, "nsym4rotfig4nbrick")==0) {
      help_n_fig_rot_sym44n_brick();
      return 0;
    }

    // -help nfig4nbrick
    if (strcmp(topic, "nfig4nbrick")==0) {
      help_n_fig4n_brick();
      return 0;
    }

    // -help graph4nbrick
    if (strcmp(topic, "graph4nbrick")==0) {
      help_graph4n_brick();
      return 0;
    }

    // -help mirrorfun
    if (strcmp(topic, "mirrorfun")==0) {
      help_mirrorfun();
      return 0;
    }

    pl("Invalid help topic");
    return print_usage4exit();
  } // -help

  pl("Invalid 1st command line argument.");
  return print_usage4exit();
} // main


/* === PrinterPerm ======================================================= */

/* --- perform --- */

bool PrinterPerm::perform(const Perm &perm) {
  int i;

  for (i=0; i<perm.n; ++i) {
    if (i>0) putchar(' ');
    printf("%d", perm.data[i]+1);
  }

  putchar('\n');
  return true;
}


/* === LoggerPerm ======================================================== */

/* --- perform --- */

bool LoggerPerm::perform(const Perm &perm) {
  int i;
  Str line;

  for (i=0; i<perm.n; ++i) {
    if (i>0) line+=' ';
    line+=str4card(i);
    line+='='; line+='>';
    line+=str4card(perm.data[i]);
  }

  log(line);
  return true;
}


/* === static functions ================================================== */

/* --- print_fun_mirror --- */

static bool print_fun_mirror(const Part &part, const FamGraph &fam_graph) {
  SetPerm set(part.get_n_brick());
  get_fun_mirror(part, fam_graph, set);

  LoggerPerm logger;
  if (!set.iterate(logger)) return false;
  return true;
}

/* --- print_part_needed --- */

// -print partneeded $nbrick

static bool print_part_needed(int n_brick) {
  Lst<Part> lst_part;
  Appender<Part> appender(lst_part);

  if (!Part::iterate(n_brick, appender)) return false;

  int n=lst_part.get_n(), i;
  log("Required partitons for %d bricks: ", n_brick);
  for (i=0; i<n; ++i) {
    Part part = lst_part.get(i);
    Part part_reverse(part);
    part_reverse.revert();
    if (part>part_reverse) continue;

    log(part.to_str());
  }

  return true;
}

/* --- print_progress --- */

// -print progress $nbrick $dir

static bool print_progress(int n_brick, const Str &path) {
  Lst<Part> lst_part;
  Appender<Part> appender(lst_part);

  if (!Part::iterate(n_brick, appender)) return false;

  log("Computation status of the files for $ bricks:", n_brick);

  // npos4part($part).dat
  int n=lst_part.get_n(), i;
  Str filename, status;
  log("Progress: ");
  for (i=0; i<n; ++i) {
    Part part = lst_part.get(i);
    Part part_reverse(part);
    part_reverse.revert();
    if (part>part_reverse) continue;

    CompNPos4Part comp(part, path, SIZE_CACHE_MAX_DEFAULT, N_MAX4MAP_DEFAULT, false, 0);
    filename = comp.get_filename4result();
    if (comp.is_result_computed()) {
      status=Str("+ ");
    } else {
      status=Str("- ");
    }
    log(status + filename);
  }

  // sym2rotfig4part($part).dat
  log("Progress: ");
  for (i=0; i<n; ++i) {
    Part part = lst_part.get(i);
    Part part_reverse(part);
    part_reverse.revert();
    if (part>part_reverse) continue;

    CompFigRotSym24Part comp(part, path);
    filename = comp.get_filename4result();
    if (comp.is_result_computed()) {
      status=Str("+ ");
    } else {
      status=Str("- ");
    }

    log(status + filename);
  }


  return true;
}

/* --- get_size_cache_max --- */

// [-bottom1]

static bool get_opt_bottom1(char **arr_arg, int n_arg, int &i_arg, bool &bottom1) {
  bottom1=false;
  if (i_arg>=n_arg) return true;
  if (strcmp(arr_arg[i_arg], "-bottom1")!=0) return true;
  bottom1=true;
  ++i_arg;
  return true;
}


/* --- get_size_cache_max --- */

// [-cachesize $size]

static bool get_size_cache_max(char **arr_arg, int n_arg, int &i_arg, int &size) {

  size = SIZE_CACHE_MAX_DEFAULT;

  if (i_arg>=n_arg) return true;
  if (strcmp(arr_arg[i_arg], "-cachesize")!=0) return  true;
  ++i_arg;
  if (i_arg>=n_arg) return err("Missing argument after \"-cachesize\"");

  In4Str in(arr_arg[i_arg]);
  Str errtxt;
  if (!in.read_card_silent(size, errtxt) || !in.at_end()) {
    return err(Str("Invalid argument after \"-cachesize\": ") + errtxt);
  }
  ++i_arg;

  return true;
}

/* --- get_n_max4map --- */

// [-mapsize $size]

static bool get_n_max4map(char **arr_arg, int n_arg, int &i_arg, int &size) {

  size = N_MAX4MAP_DEFAULT;

  if (i_arg>=n_arg) return true;
  if (strcmp(arr_arg[i_arg], "-mapsize")!=0) return  true;
  ++i_arg;
  if (i_arg>=n_arg) return err("Missing argument after \"-mapsize\"");

  In4Str in(arr_arg[i_arg]);
  Str errtxt;
  if (!in.read_card_silent(size, errtxt) || !in.at_end()) {
    return err(Str("Invalid argument after \"-mapsize\": ") + errtxt);
  }
  ++i_arg;

  return true;
}

/* --- get_opt_pipe --- */

// [-pipe] [-buffsize $size]

static bool get_opt_pipe(char **arr_arg, int n_arg, int &i_arg, bool &pipe, int &size_buff) {

  pipe = false;
  if (i_arg<n_arg && strcmp(arr_arg[i_arg], "-pipe")==0) {
    pipe=true;
    ++i_arg;
  }

  size_buff = SIZE_PIPE_BUFF_DEFAULT;
  if (i_arg<n_arg && strcmp(arr_arg[i_arg], "-buffsize")==0) {
    ++i_arg;
    if (i_arg>=n_arg) return err("Missing argument after \"-mapsize\"");

    In4Str in(arr_arg[i_arg]);
    Str errtxt;
    if (!in.read_card_silent(size_buff, errtxt) || !in.at_end()) {
      return err(Str("Invalid argument after \"-buffsize\": ") + errtxt);
    }
    ++i_arg;
  }

  return true;
}

/* --- get_logperiod --- */

// [-logperiod $nsec]

static bool get_logperiod(char **arr_arg, int n_arg, int &i_arg) {
  if (i_arg>=n_arg) return true;
  if (strcmp(arr_arg[i_arg], "-logperiod")!=0) return  true;
  ++i_arg;
  if (i_arg>=n_arg) return err("Missing argument after \"-logperiod\"");

  In4Str in(arr_arg[i_arg]);
  Str errtxt;
  if (!in.read_card_silent(logperiod, errtxt) || !in.at_end()) {
    return err(Str("Invalid argument after \"-logperiod\": ") + errtxt);
  }
  ++i_arg;

  return true;
}

/* --- print1_n_pos4graph --- */

static bool print1_n_pos4graph(const Graph &graph, int size_cache_max) {

  Card64 n_pos;
  if (!get_n_pos4graph(graph, n_pos, size_cache_max)) return false;

  char buff[N_DIGIT4CARD64+1];
  log("npos=$.", to_nts(n_pos, buff, sizeof(buff)));
  return true;
}


/* --- print_rep(Graph) --- */

static bool print_rep(const Graph &graph) {
  Graph rep(graph.n_brick);
  Str errtxt;

  if (!get_graph_rep(graph, rep, errtxt)) return err(errtxt);
  if (!rep.write(Stdout::instance)) return false;
  if (!Stdout::instance.print_char('\n')) return false;
  return true;
}

/* --- import_db(path) --- */

static bool import_db(int n_brick, const Str &path_dir, const Str &path_in) {

  // Open database
  Access2Db db(path_dir, n_brick);
  if (!db.open()) {
    return false;
  }

  // Open import file
  In4File in4file;
  if (!in4file.open(path_in)) {
    db.rollback();
    return false;
  }

  // Open graph computation
  CompGraph4NBrick comp_graph(n_brick, path_dir);
  if (!comp_graph.is_result_computed()) {
    db.rollback(); in4file.close();
    return err(Str("File ") + enquote(comp_graph.get_path4result()) + Str(" not computed"));
  }
  if (!comp_graph.run()) {
    db.rollback();
    in4file.close();
    return false;
  }

  // Open checksummer
  InBuffering in_buffered(in4file);
  Chksummer4In chksummer(in_buffered);
  if (!Comp::read_fileclause(chksummer, db.get_filename())) {
    db.rollback();
    in4file.close();
    return false;
  }

  // Import database
  bool ok = import_db(n_brick, db, comp_graph, chksummer);

  if (ok) {
    if (!db.commit()) ok=false;
  } else {
    db.rollback();
  }

  if (ok && !chksummer.read_chksum()) ok=false;
  if (!in4file.close ()) ok=false;
  return ok;
}

/* --- export_db(path) --- */

static bool export_db(int n_brick, const Str &path_dir, const Str &path_exclude, const Str &path_out) {

  // Read bitmap of excluded graphs
  In4File in_exclude;
  bool *arr_exclude=0;
  if (!in_exclude.open(path_exclude)) return false;
  if (!read_bmp4graph(n_brick, path_exclude, arr_exclude)) {
    in_exclude.close();
    return false;
  }
  in_exclude.close();

  // Open database
  Access2Db db(path_dir, n_brick);
  if (!db.open()) {
    delete[] arr_exclude;
    return false;
  }

  // Open file
  Out4File out4file;
  if (!out4file.open(path_out)) {
    db.rollback();
    delete[] arr_exclude;
    return false;
  }

  // Open graph computation
  CompGraph4NBrick comp_graph(n_brick, path_dir);
  if (!comp_graph.is_result_computed()) {
    db.rollback(); out4file.close(); in_exclude.close();
    return err(Str("File ") + enquote(comp_graph.get_path4result()) + Str(" not computed"));
  }
  if (!comp_graph.run()) {
    db.rollback();
    out4file.close();
    delete[] arr_exclude;
    return false;
  }

  // Open checksummer
  Checksummer4Out out(out4file);
  if (!Comp::write_fileclause(out, db.get_filename())) {
    db.rollback();
    out4file.close();
    delete[] arr_exclude;
    return false;
  }

  // Export database
  bool ok = export_db(n_brick, db, arr_exclude, comp_graph, out);

  if (!out.write_chksum()) {
    ok=false;
  }

  db.rollback();
  if (!out4file.close()) ok=false;
  delete[] arr_exclude;

  return ok;
}

/* --- import_db(In) --- */

static bool import_db(int n_brick, Access2Db &db, CompGraph4NBrick &comp_graph, In &in) {

  log("Import graphs...");

  // Get number of graphs to be imported
  int n;
  if (!in.read_str_given(c_n_eq)) return false;
  if (!in.read_card(n)) return false;
  if (!in.read_eoln()) return false;

  int i, n_confirmed=0, n_inserted=0;
  for (i=0; i<n; ++i) {

    Graph graph;
    Card64 val;
    if (!read(in, n_brick, graph)) return false;
    if (!in.read_char_given(':')) return false;
    if (!in.read_char_given(' ')) return false;
    if (!read(in, val)) return false;

    Card64 val_db;
    if (db.query(graph, val_db)) {
      if (val_db!=val) return in.In::err_at("Some values in the database and in the imported file differ");
      ++n_confirmed;
    } else {
      db.insert(graph, val);
      ++n_inserted;
    }

    if (!in.read_eoln()) return false;
  }

  log("$ graphs imported, $ graphs confirmedd.", n_inserted, n_confirmed);
  return true;
}

/* --- export_db(Out) --- */

static bool export_db(int n_brick, Access2Db &db, bool *arr_exclude, CompGraph4NBrick &comp_graph, Out &out) {

  log_progress_start("Count graphs which need to be exported...");
  int n_export=0, i_graph, n_graph = comp_graph.get_n();
  Card64 n_sol;
  Graph graph(n_brick);
  for (i_graph=0; i_graph<n_graph; ++i_graph) {
    comp_graph.get(i_graph, graph);
    if (db.query(graph, n_sol) && !arr_exclude[i_graph]) {
      ++n_export;
    }
  }
  log_progress_end("$ need to be exported.", n_export);

  // Write number of graphs to be exported
  if (!out.printf("n=$\n", n_export)) return false;

  char buff_n_sol[N_DIGIT4CARD64+1];
  log_progress_start("Export graphs...");
  for (i_graph=0; i_graph<n_graph; ++i_graph) {
    comp_graph.get(i_graph, graph);
    if (db.query(graph, n_sol) && !arr_exclude[i_graph]) {
      if (!graph.write(out)) return false;
      if (!out.printf(": $\n", to_nts(n_sol, buff_n_sol, sizeof(buff_n_sol)))) return false;
    }
  }
  log_progress_end("Graphs exported.");

  return true;
}

/* --- export_bmp_db(path) --- */

static bool export_bmp_db(int n_brick, const Str &path_dir, const Str &path) {
  Access2Db db(path_dir, n_brick);
  if (!db.open()) return false;

  Out4File out;
  if (!out.open(path)) {db.rollback(); return false;}

  CompGraph4NBrick comp_graph(n_brick, path_dir);
  if (!comp_graph.is_result_computed()) {
    db.rollback(); out.close();
    return err(Str("File ") + enquote(comp_graph.get_path4result()) + Str(" not computed"));
  }
  if (!comp_graph.run()) {db.rollback(); out.close(); return false;}

  bool ok = export_bmp_db(n_brick, db, comp_graph, out);

  db.rollback(); out.close();
  return ok;
}

/* --- export_bmp_db(Out) --- */

static bool export_bmp_db(int n_brick, Access2Db &db, CompGraph4NBrick &comp_graph, Out &out) {
  int n = comp_graph.get_n(), i, n_bit4hex=0, n_hex4line=0, hex=0, n_bit=0;

  log_progress_start("Write bitmap of all computed graphs...");
  for (i=0; i<n; ++i) {

    // Get bit whether graph <i> is computed
    Graph graph(n_brick);
    bool bit;
    Card64 val; // Dummy
    comp_graph.get(i, graph);
    bit = db.query(graph, val);
    n_bit+=bit;

    // If hex digit is complete, flush it
    if (n_bit4hex==4) {
      if (!flush_hex(hex, n_hex4line, out)) return false;
      hex=0;
      n_bit4hex=0;
    }

    // Put bit <found> to output stream
    if (bit) hex|=1<<n_bit4hex;
    ++n_bit4hex;
  }

  // Flush <hex>
  if (n_bit4hex) {
    if (!flush_hex(hex, n_hex4line, out)) return false;
  }

  // Terminate line
  if (n_hex4line) {
    if (!out.print_eoln()) return false;
  }

  db.rollback();
  log_progress_end("Exported bitmap of all computated graphs.");
  log("$ bits are sete", n_bit);
  return true;
}

/* --- flush_hex --- */

bool flush_hex(int hex, int &n_hex4line, Out &out) {

  // If line is full, open a new one
  if (n_hex4line==N_HEX4LINE_DB) {
    if (!out.print_eoln()) return false;
    n_hex4line=0;
  }

  // flush hexdigit
  if (!out.print_char("0123456789abcdef"[hex])) return false;
  ++n_hex4line;
  return true;
}

/* --- print_n_fig4n_brick --- */

static bool print_n_fig4n_brick(int n_brick, const Str &path_dir, bool &complete, bool bottom1, int size_cache_max, int n_max4map, bool pipe, int size_buff_pipe) {
  char buff[N_DIGIT4CARD64+1];

  if (bottom1) {
    CompNFig4Bottom1NBrick comp(n_brick, path_dir, size_cache_max, n_max4map, pipe, size_buff_pipe);
    signal(SIGINT , &handler4sigint);
    if (!comp.run()) return false;
    complete=comp.is_complete();

    if (complete) {
      log("There are $ contiguous LEGO buildings with $ bricks with one brick in its bottom layer.", to_nts(comp.get_res(), buff, sizeof(buff)), n_brick);
    }
  } else {
    CompNFig4NBrick comp(n_brick, path_dir, size_cache_max, n_max4map, pipe, size_buff_pipe);
    signal(SIGINT , &handler4sigint);
    if (!comp.run()) return false;
    complete=comp.is_complete();

    if (complete) {
      log("There are $ contiguous LEGO buildings with $ bricks.", to_nts(comp.get_res(), buff, sizeof(buff)), n_brick);
    }
  }

  return true;
}

/* --- print_perm4part --- */

static bool print_perm4part(const Part &part) {
  PrinterPerm printer;
  return part.iterate_perm_conform(printer);
}

/* --- make_fam_graph_nooverlap4part_nlink_max --- */

static bool make_fam_graph_nooverlap4part_nlink_max(const Part &part, int n_link, int n_max4map, bool pipe, int size_buff_pipe, const Str &path_dir, bool &complete) {
  signal(SIGINT, &handler4sigint);

  if (pipe) {
    CompFamGraphNooverlap4PartNLinkMaxPipe comp(part, n_link, n_max4map, size_buff_pipe, path_dir);
    if (comp.is_result_computed()) {complete=true; return true;}
    if (!comp.run()) return false;
    complete = comp.is_complete();
  } else {
    CompFamGraphNooverlap4PartNLinkMax comp(part, n_link, n_max4map,  path_dir);
    if (comp.is_result_computed()) {complete=true; return true;}
    if (!comp.run()) return false;
    complete = comp.is_complete();
  }

  return true;
}

/* --- make_fam_graph_nooverlap4part_nlink_max_nomerge --- */

static bool make_fam_graph_nooverlap4part_nlink_max_nomerge(const Part &part, int n_link, int n_max4map, int size_buff_pipe, const Str &path_dir, bool &complete) {
  CompFamGraphNooverlap4PartNLinkMaxNomerge comp(part, n_link, n_max4map, size_buff_pipe, path_dir);

  if (comp.is_result_computed()) {complete=true; return true;}

  signal(SIGINT , &handler4sigint);
  if (!comp.run()) return false;
  complete = comp.is_complete();
  return true;
}

/* --- make_fam_graph4part --- */

static bool make_fam_graph4part(const Part &part, const Str &path_dir, bool &complete) {
  CompFamGraph4Part comp(part, path_dir);

  if (comp.is_result_computed()) {complete=true; return true;}

  signal(SIGINT , &handler4sigint);
  if (!comp.run()) return false;
  complete = comp.is_complete();
  return true;
}

/* --- make_n_fig4part --- */

static bool make_n_fig4part(const Part &part, const Str &path_dir, int size_cache_max, int n_max4map, bool pipe, int size_buff_pipe, bool &complete) {
  CompNPos4Part comp(part, path_dir, size_cache_max, n_max4map, pipe, size_buff_pipe);

  if (comp.is_result_computed()) {complete=true; return true;}

  signal(SIGINT , &handler4sigint);
  if (!comp.run()) return false;
  complete = comp.is_complete();
  return true;
}

/* --- make_rep_fam_graph4part --- */

static bool make_rep_fam_graph4part(const Part &part, const Str &path_dir, bool &complete) {
  CompRepFamGraph4Part comp(part, path_dir);

  if (comp.is_result_computed()) {complete=true; return true;}

  signal(SIGINT , &handler4sigint);
  if (!comp.run()) return false;
  complete = comp.is_complete();
  return true;
}

/* --- make_fig_sym24part --- */

static bool make_fig_sym24part(const Part &part, const Str &path_dir, bool &complete) {
  CompFigRotSym24Part comp(part, path_dir);

  if (comp.is_result_computed()) {complete=true; return true;}

  signal(SIGINT , &handler4sigint);
  if (!comp.run()) return false;
  complete = comp.is_complete();
  return true;
}

/* --- make_graph_no_prohibe_link4part --- */

static bool make_graph_no_prohibe_link4part(const Part &part, const Str &path_dir, int n_max4map, bool &complete, bool pipe, int size_buff_pipe) {
  CompGraphNoProhibeLink4Part comp(part, n_max4map, path_dir, pipe, size_buff_pipe);

  if (comp.is_result_computed()) {complete=true; return true;}

  signal(SIGINT , &handler4sigint);
  if (!comp.run()) return false;
  complete = comp.is_complete();
  return true;
}

/* --- delete_fam_graph_nooverlap4part_nlink_max --- */

static bool delete_fam_graph_nooverlap4part_nlink_max(const Part &part, int n_link, const Str &path_dir) {

  // Load computation
  Pt<CompFamGraphNooverlap4PartNLinkMax> pt_comp = new CompFamGraphNooverlap4PartNLinkMax(part, n_link, 1000, path_dir);
  CompFamGraphNooverlap4PartNLinkMax &comp = *pt_comp;
  if (!comp.is_result_computed()) return err(Str("File ") + enquote(comp.get_path4result()) + Str(" does not exist."));
  if (!comp.run()) return false;

  // Get path of files to be deleted
  Lst<Str> lst_path;
  lst_path.append(comp.get_path4result());
  comp.append_lst_path_att4result(lst_path);

  // Delete computation object: No files must be deleted for an existing computation object.
  pt_comp = Pt<CompFamGraphNooverlap4PartNLinkMax>();

  // Delete files
  int n_path = lst_path.get_n(), i_path;
  for (i_path=0; i_path<n_path; ++i_path) {
    Str path = lst_path.get(i_path);
    if (remove_file(path)) {
      log("File \"$\" deleted.", path);
    } else {
      log("File \"$\" not deleted.", path);
    }
  }

  return true;
}

/* --- delete_fam_graph_nooverlap4part_nlink_max_nomerge --- */

static bool delete_fam_graph_nooverlap4part_nlink_max_nomerge(const Part &part, int n_link, const Str &path_dir) {

  // Load computation
  Pt<CompFamGraphNooverlap4PartNLinkMaxNomerge> pt_comp = new CompFamGraphNooverlap4PartNLinkMaxNomerge(part, n_link, 1000, 1000, path_dir);
  CompFamGraphNooverlap4PartNLinkMaxNomerge &comp = *pt_comp;
  if (!comp.is_result_computed()) return err(Str("File ") + enquote(comp.get_path4result()) + Str(" does not exist."));
  if (!comp.run()) return false;

  // Get path of files to be deleted
  Lst<Str> lst_path;
  lst_path.append(comp.get_path4result());
  comp.append_lst_path_att4result(lst_path);

  // Delete computation object: No files must be deleted for an existing computation object.
  pt_comp = Pt<CompFamGraphNooverlap4PartNLinkMaxNomerge>();

  // Delete files
  int n_path = lst_path.get_n(), i_path;
  for (i_path=0; i_path<n_path; ++i_path) {
    Str path = lst_path.get(i_path);
    if (remove_file(path)) {
      log("File \"$\" deleted.", path);
    } else {
      log("File \"$\" not deleted.", path);
    }
  }

  return true;
}

/* --- make_n_fig_rot4n_brick --- */

static bool make_n_fig_rot4n_brick(int n_brick, const Str &path_dir, bool &complete, int size_cache_max, int n_max4map, bool pipe, int size_buff_pipe) {
  CompNFigRot4NBrick comp(n_brick, path_dir, size_cache_max, n_max4map, pipe, size_buff_pipe);

  if (comp.is_result_computed()) {complete=true; return true;}

  signal(SIGINT , &handler4sigint);
  if (!comp.run()) return false;
  complete = comp.is_complete();
  return true;
}

/* --- make_fig_sym44part --- */

static bool make_fig_sym44part(const Part &part, const Str &path_dir, bool &complete) {
  CompFigRotSym44Part comp(part, path_dir);

  if (comp.is_result_computed()) {complete=true; return true;}

  signal(SIGINT , &handler4sigint);
  if (!comp.run()) return false;
  complete = comp.is_complete();
  return true;
}

/* --- make_n_fig_rot_sym44n_brick --- */

static bool make_n_fig_rot_sym44n_brick(int n_brick, const Str &path_dir, bool &complete) {
  CompNFigRotSym44NBrick comp(n_brick, path_dir);

  if (comp.is_result_computed()) {complete=true; return true;}

  signal(SIGINT , &handler4sigint);
  if (!comp.run()) return false;
  complete = comp.is_complete();
  return true;
}

/* --- make_n_fig4n_brick --- */

static bool make_n_fig4n_brick(int n_brick, const Str &path_dir, bool &complete, int size_cache_max, int n_max4map, bool pipe, int size_buff_pipe) {
  CompNFig4NBrick comp(n_brick, path_dir, size_cache_max, n_max4map, pipe, size_buff_pipe);

  if (comp.is_result_computed()) {complete=true; return true;}

  signal(SIGINT , &handler4sigint);
  if (!comp.run()) return false;
  complete = comp.is_complete();
  return true;
}

/* --- make_graph4n_brick --- */

static bool make_graph4n_brick(int n_brick, const Str &path_dir, bool &complete) {
  CompGraph4NBrick comp(n_brick, path_dir);

  if (comp.is_result_computed()) {complete=true; return true;}

  signal(SIGINT , &handler4sigint);
  if (!comp.run()) return false;
  complete = comp.is_complete();
  return true;
}

/* --- make_n_fig_rot_sym24n_brick --- */

static bool make_n_fig_rot_sym24n_brick(int n_brick, const Str &path_dir, bool &complete) {
  CompNFigRotSym24NBrick comp(n_brick, path_dir);

  if (comp.is_result_computed()) {complete=true; return true;}

  signal(SIGINT , &handler4sigint);
  if (!comp.run()) return false;
  complete = comp.is_complete();
  return true;
}

/* --- print_usage4exit --- */

static int print_usage4exit() {
  print_usage();
  return 1;
}

/* --- log_start --- */

// Logs that the program has started

static void log_start(int n_arg, char **arr_arg) {

  // Log
  Str args=concat_arg(n_arg, arr_arg);
  log("*** Start: $ ***", args);
}

/* --- handler4sigint --- */

static void handler4sigint(int) {
  signal(SIGINT , SIG_IGN);
  signalled_stop=true;
}

/* --- log_end --- */

static int log_end(bool ok, bool complete, int n_arg, char **arr_arg) {
  Str args = concat_arg(n_arg, arr_arg);

  if (ok) {
    if (complete) {
      log("*** Computation succeeded: $ ***", args);
    } else {
      log("*** Computation paused: $ ***", args);
    }
  } else {
    log("*** Computation failed: $ ***", args);
  }

  return ok ? 0 : 1;
}

/* --- concat_arg --- */

static Str concat_arg(int n, char **arr) {
  Str res;
  int i;

  for (i=0; i<n; ++i) {
    Str arg = arr[i];
    bool contains_spc = (arg.get_pos_first(' ')>=0);
    if (contains_spc) res+='\"';
    res+=arg;
    if (contains_spc) res+='\"';
    if (i+1<n) {
      res+=' ';
    }
  }

  return res;
}

/* --- print_usage --- */

static void print_usage() {
  pl("This program can be alternatively called with the following command line arguments:");
  pl("1) -make [-logperiod $nsec] [-cachesize $cachesize] [-mapsize $mapsize] [-pipe] [-buffsize $pipebuffsize] [-nstepmax $nstepmax] $filename $dir");
  pl("   generated the file $filename.");
  pl("   For further information call with the arguments \"-help make\"");
  pl("2) -delete $filename $dir");
  pl("   Deletes the file $filename.");
  pl("   For further information call with the arguments \"-help delete\"");
  pl("3) -print mirrorfun $part $famgraph");
  pl("   Prints all mirror functions of partition $part");
  pl("   which comply to the graph family $famgraph.");
  pl("   For further information call with the arguments \"-help mirrorfun\".");
  pl("4) -print nfig4nbrick [-logperiod $nsec] [-cachesize $size] [-mapsize $size] [-pipe] [-buffsize $size] $nbrick $dir");
  pl("   Prints the number of contiguous LEGO buildings with $nbrick bricks.");
  pl("   For further information call with the arguments \"-help nfig4nbrick\".");
  pl("5) -export dbbmp $nbrick $dir $filename");
  pl("   Export a bitmap of the database for $nbrick brick which is stored in the directory $dir.");
  pl("   The export is written to file $filename.");
  pl("6) -export db $nbrick $dir $exclude $out");
  pl("   Exports graphs from the database in directory $dir.");
  pl("   For further information call with the arguments \"-help exportdb\".");
  pl("7) -import db $nbrick $dir $in");
  pl("    Imports graphs into the database stored in directory $dir.");
  pl("    For further information call with the arguments \"-help importdb\".");
  pl("8) -help $topic");
  pl("    Displays help to the given topic.");
}

/* --- help_mirrorfun --- */

static void help_mirrorfun() {
  pl("The call with the arguments");
  pl("  -print mirrorfun $part $famgraph");
  pl("prints all mirror functions of the partition $part");
  pl("and which are compliant to the graph family $famgraph.");
  pl("The syntax of $part is displayed by calling this programm with the arguments \"-help part\".");
  pl("The syntax of $famgraph is displayed by calling this program with the arguments \"-help famgraph\" angezeigt.");
}

/* --- help_n_fig4n_brick --- */

static void help_n_fig4n_brick() {
  pl("The call with the arguments");
  pl("  -print nfig4nbrick [-logperiod $nsec] [-cachesize $size] [-mapsize $size] [-pipe] [-buffsize $size] $nbrick $dir");
  pl("prints the number of LEGO buildings with $nbrick bricks,");
  pl("where $nbrick is the number of bricks, 1<=$nbrick<=%d.", N_BRICK_MAX);
  pl("The programm uses intermediate files in the directory $dir which have already been computed");
  pl("and saves intermediate files in this directory so they can be used later.");
  pl("If the specification \"-logperiod $nsec\" is supplied, the progress is logged each $nsec seconds,");
  pl("where  $nsec is an unsigned integer.");
  pl("If the specification \"-logperiod $nsec\" is not supplied, the process is logged each %d seconds.", LOGPERIOD_DEFAULT);
  pl("If the specification \"-cachesize $size\" is supplied, the cache size is limited to $cachesize byte,");
  pl("where $cachesize is an unsigned integer.");
  pl("If the specification \"-cachesize $size\" is not supplied, the cache size is limited to %d bytes.", SIZE_CACHE_MAX_DEFAULT);
  pl("If the specification \"-mapsize $size\"  is supplied, the map size is limited to $size bytes.");
  pl("If the specification \"-mapsize $size\" is not supplied, the map size is limited to %d bytes.", N_MAX4MAP_DEFAULT);
  pl("If the option \"-pipe\"  is supplied, merging of the attachments is done by using internal pipes.");
  pl("If the specification \"-buffsize $size\"  is supplied, the buffer size for ungemerged input files is set to $size.");
  pl("If the specification \"-buffsize $size\" is not supplied, the buffer size is %d byte.", SIZE_PIPE_BUFF_DEFAULT);
  pl("Here $nsec and $size are unsigned integers.");
}

/* --- help_export_db --- */

static void help_export_db() {
  pl("The call with the arguments");
  pl("  -export db $nbrick $dir $exclude $out");
  pl("exports the graphs of the database.");
  pl("$out is the path of the file the graphs are exported to.");
  pl("$dir is the path of the directory where the database is located.");
  pl("$nbrick is the number of graph nodes, 1<=$nbrick<=%d.", N_BRICK_MAX);
  pl("$exclude is the path of a bitmat file  which has been produced with \"-export dbbmp\".");
  pl("Graphs contains in $exclude are not exported.");
}

/* --- help_import_db --- */

static void help_import_db() {
  pl("The call with the arguments");
  pl("  -import db $nbrick $dir $in");
  pl("imports graphs into the database.");
  pl("$in is the path of the file which contains the graphs to be imported.");
  pl("This file has been produced by calling this programm with the arguments \"-export db $nbrick $dir $exclude $out\"");
  pl("(For further information call this programm with the arguments \"-help exportdb\").");
  pl("$dir is the path of the directory where the database is located.");
  pl("$nbrick is the number of graph nodes, 1<=$nbrick<=%d.", N_BRICK_MAX);
}

/* --- help_delete --- */

static void help_delete() {
  pl("The call with the arguments");
  pl("  -delete $filename $dir");
  pl("deletes the file $filename and its attachments from directory $dir,");
  pl("where $filename fits to one of the following pattern:");
  pl("- fam_graph_nooverlap4part($part)nlinkmax($nlink).dat");
  pl("- fam_graph_nooverlap4part($part)nlinkmax($nlink)nomerge.dat");
  pl("The syntax of $part is displayed by calling this programm with the arguments \"-help part\".");
  pl("The condition 0<=$nlink<$nbrick*($nbrick-1) must hold, where $nbrick is the sum of the partition $part");
  pl("(refer to \"-help part\")");
  pl("The attachments are files whose names fits to the pattern");
  pl("  fam_graph_nooverlap4part($part)nlinkmax($nlink)block($i).dat");
  pl("or");
  pl("  fam_graph_nooverlap4part($part)nlinkmax($nlink)block($i)nomerge.dat");
  pl("resp. In all attachments, $part and $nlink have the same settings than than above.");
  pl("$i is a sequence of digits.");
}

/* --- help_make --- */

static void help_make() {
  pl("The call with the arguments");
  pl("  -make [-logperiod $nsec] [-cachesize $size] [-mapsize $size] [-pipe] [-buffsize $size] [-nstepmax $nstepmax] $filename $dir");
  pl("creates a file with the name $filename in the directory $dir,");
  pl("if it does not exist.");
  pl("From the file name one can infer its content as follows.");
  pl("$filename has one of the following pattern:");
  pl("- famgraph4part($part).dat");
  pl("  Calling this program with the arguments \"-help famgraph4part\" displays a description of the content of those files.");
  pl("- repfamgraph4part($part).dat");
  pl("  Calling this program with the arguments \"-help repfamgraph4part\" displays a description of the content of those files.");
  pl("- graph_no_prohibe_link4part($part).dat");
  pl("  Calling this program with the arguments \"-help graph_no_prohibe_link4part\" displays a description of the content of those files.");
  pl("- fam_graph_nooverlap4part($part)nlinkmax($nlink).dat");
  pl("  Calling this program with the arguments \"-help fam_graph_nooverlap4part\" displays a description of the content of those files.");
  pl("- fam_graph_nooverlap4part($part)nlinkmax($nlink)nomerge.dat");
  pl("  Calling this program with the arguments \"-help fam_graph_nooverlap4part\" displays a description of the content of those files.");
  pl("- npos4part($part).dat");
  pl("  Calling this program with the arguments \"-help npos4part\" displays a description of the content of those files.");
  pl("- nrotfig4nbrick($nbrick).dat");
  pl("  Calling this program with the arguments \"-help nrotfig4nbrick\" displays a description of the content of those files.");
  pl("- nsym2rotfig4nbrick($nbrick).dat");
  pl("  Calling this program with the arguments \"-help nsym2rotfig4nbrick\" displays a description of the content of those files.");
  pl("- nsym4rotfig4nbrick($nbrick).dat");
  pl("  Calling this program with the arguments \"-help nsym4rotfig4nbrick\" displays a description of the content of those files.");
  pl("- sym2rotfig4part($part).dat");
  pl("  Calling this program with the arguments \"-help sym2rotfig4part\" displays a description of the content of those files.");
  pl("- sym4rotfig4part($part).dat");
  pl("  Calling this program with the arguments \"-help sym4rotfig4part\" displays a description of the content of those files.");
  pl("- nfig4nbrick($nbrick).dat");
  pl("  Calling this program with the arguments \"-help nfig4nbrick\" displays a description of the content of those files.");
  pl("- graph4nbrick($nbrick).dat");
  pl("  Calling this program with the arguments \"-help graph4nbrick\" displays a description of the content of those files.");
  pl("If the specification \"-logperiod $nsec\"  is supplied, the progress is logged each $nsec seconds.");
  pl("If the specification \"-logperiod $nsec\" is not supplied, he progress is logged each %d seconds.", LOGPERIOD_DEFAULT);
  pl("If the specification \"-cachesize $size\" is supplied, the cache size is limited to $cachesize byte,");
  pl("If the specification \"-cachesize $size\" is not supplied, the cache size is limited to %d bytes.", SIZE_CACHE_MAX_DEFAULT);
  pl("If the specification \"-mapsize $size\"  is supplied, the map size is limited to $size bytes.");
  pl("If the specification \"-mapsize $size\" is not supplied, the map size is limited to %d bytes.", N_MAX4MAP_DEFAULT);
  pl("If the option \"-pipe\"  is supplied, the attachments are merged with internal pipes.");
  pl("If the specification \"-buffsize $size\"  is supplied, the buffer size for ungemerged input files is set to $size.");
  pl("If the specification \"-buffsize $size\" is not supplied, the buffer size is %d byte.", SIZE_PIPE_BUFF_DEFAULT);
  pl("Here $nsec, $cachesize and $size are unsigned integers.");
  
}

/* --- help_fig_sym24part --- */

static void help_fig_sym24part() {
  pl("Files whose name fit to the pattern");
  pl("  sym2rotfig4part($part).dat");
  pl("contain all buildings with 2-symmetry which comply to the partition $part.");
  pl("The syntax of $part is displayed by calling this program with the arguments \"-help part\".");
}

/* --- help_fig_sym44part --- */

static void help_fig_sym44part() {
  pl("Files whose name fit to the pattern");
  pl("  sym4rotfig4part($part).dat");
  pl("contain all buildings with 4-symmetry which comply to the partition $part.");
  pl("The syntax of $part is displayed by calling this program with the arguments \"-help part\".");
}

/* --- help_graph_no_prohibe_link4part --- */

static void help_graph_no_prohibe_link4part() {
  pl("Files whose name fit to the pattern");
  pl("  graph_no_prohibe_link4part($part).dat");
  pl("contains all graph families which comply to the partition $part.");
  pl("Each of these graph families has no link prohibition.");
  pl("Each of these graph families is provided with a factor.");
  pl("If one knows the number of brick positionings for each graph family,");
  pl("and multiplies these numbers with the appropriate factor,");
  pl("and sums up that products,");
  pl("one gets the number of brick positionings which comply to $part.");
  pl("The syntax of $part is displayed by calling this program with the arguments \"-help part\" angezeigt.");
}

/* --- help_fam_graph_nooverlap4part --- */

static void help_fam_graph_nooverlap4part() {
  pl("Files whose name fit to the pattern");
  pl("  fam_graph_nooverlap4part($part)nlinkmax($nlink).dat");
  pl("or");
  pl("  fam_graph_nooverlap4part($part)nlinkmax($nlink)nomerge.dat");
  pl("contain (together with their attachment) graph families which comply with the partition $part.");
  pl("Each of these graph families has at most $nlink link prohibitions.");
  pl("Each of these graph families is provided with a factor.");
  pl("In fam_graph_nooverlap4part($part)nlinkmax($nlink).dat each graph family occurs at most once.");
  pl("In fam_graph_nooverlap4part($part)nlinkmax($nlink)nomerge.dat some graph families may occurs multiple times.");
  pl("The syntax of $part is displayed by calling this program with the arguments \"-help part\" angezeigt.");
  pl("The condition 0<=$nlink<$nbrick*($nbrick-1) must be true, where $nbrick is the sum of the partition $part");
  pl("(refer to \"-help part\")");
}

/* --- help_n_fig_rot4n_brick --- */

static void help_n_fig_rot4n_brick() {
  pl("Files whose name fit to the pattern");
  pl("  nrotfig4nbrick($nbrick).dat");
  pl("contain the number of rotated LEGO buildings with $nbrick bricks.");
  pl("$nbrick is an unsigned integer, 1<=$nbrick<=%d.", N_BRICK_MAX);
}

/* --- help_graph4n_brick --- */

static void help_graph4n_brick() {
  pl("Files whose name fit to the pattern");
  pl("  graph4nbrick($nbrick).dat");
  pl("contain all connected undirected graphs with $nbrick nodes");
  pl("in lexicographical order.");
  pl("$nbrick is an unsigned integer, 1<=$nbrick<=%d.", N_BRICK_MAX);
}

/* --- help_n_fig_rot_sym24n_brick --- */

static void help_n_fig_rot_sym24n_brick() {
  pl("Files whose name fit to the pattern");
  pl("  nsym2rotfig4nbrick($nbrick).dat");
  pl("contains the number of rotated LEGO buildings with $nbrick bricks having 2 symetry.");
  pl("$nbrick is an unsigned integer, 1<=$nbrick<=%d.", N_BRICK_MAX);
}

/* --- help_n_fig_rot_sym44n_brick --- */

static void help_n_fig_rot_sym44n_brick() {
  pl("Files whose name fit to the pattern");
  pl("  nsym4rotfig4nbrick($nbrick).dat");
  pl("contains the number of rotated LEGO buildings with $nbrick bricks having 4 symetry.");
  pl("$nbrick is an unsigned integer, 1<=$nbrick<=%d.", N_BRICK_MAX);
}

/* --- help_fam_graph4part --- */

static void help_fam_graph4part() {
  pl("Files whose name fit to the pattern");
  pl("  famgraph4part($part).dat");
  pl("contain graph families which comply to $part.");
  pl("The set of graph families in famgraph4part($part).dat cover without intersection");
  pl("the set of graphs which comply with the partition $part.");
  pl("The syntax of $part is displayed by calling this program with the arguments \"-help part\" angezeigt.");
}

/* --- help_part --- */

static void help_part() {
  pl("A partition $part has the pattern $nbrick=$n_1+...+$n_$nlayer.");
  pl("$nbrick and $nlayer are unsigned integers fulfilling");
  pl("1<=$nbrick<=%d, 1<=$nlayer<=%d,", N_BRICK_MAX, N_BRICK_MAX);
  pl("$n_1,..,$n_$nlayer are positive integers,");
  pl("and $nbrick=$n_1 + ... + $n_$nlayer.");
  pl("$nlayer is the number of layers of the LEGO building.");
  pl("$n_$i is the number of the $i-th layer from below.");
}

/* --- help_famgraph --- */

static void help_famgraph() {
  pl("A graph family $famgraph has the pattern($i_1*$j_1 ... $i_$l*j_$l,");
  pl("where");
  pl("- i_1,...,$i_$l, j_1,...,$j_$l are node (or brick) numbers");
  pl("  with 0<=$i_$k<%d, 0<=$j_$k<%d for $k=1,...,$l.", N_BRICK_MAX, N_BRICK_MAX);
  pl("- each \"*\" stands for the operator \"|\" or the operator \"-\".");
  pl("If the operator \"|\" is between $i_$k and $j_$k,");
  pl("then brick $i_$k and $j_$k must not overlap (if viewed from above).");
  pl("If the operator \"-\" is between $i_$k and $j_$k,");
  pl("then brick $i_$k and $j_$k must overlap (if viewed from above).");
}

/* --- help_n_pos4part --- */

static void help_n_pos4part() {
  pl("Files whose name fit to the pattern");
  pl("  npos4part($part).dat");
  pl("contain the number ofnull-positioned brick tuped which comply to the partition $part.");
  pl("The syntax of $part is displayed by calling this program with the arguments \"-help part\" angezeigt.");
}

/* --- help_rep_fam_graph4part --- */

static void help_rep_fam_graph4part() {
  pl("Files whose name fit to the pattern");
  pl("  repfamgraph4part($part).dat");
  pl("contain graph families which comply to the partition $part.");
  pl("The set of graph families which are equivalent to any graph family of the file repfamgraph4part($part).dat");
  pl("cover (without intersection) the set of connected graphs which comply to $part");
  pl("Two graph families are called equivalent if they are equal up to the enumeration of their nodes.");
  pl("The syntax of $part is displayed by calling this program with the arguments \"-help part\" angezeigt.");
}

/* --- help --- */

static void help() {
  pl("This program computes the number of ways, counted up to symmetry,");
  pl("to build a contiguous building with $nbrick LEGO bricks of size %dx%d.", L_BRICK, W_BRICK);
  pl("This program saved intermediate and final results in several files, which are stored in a given directory.");
  pl("The program is interrupted if STRG-C is pressed.");
  pl("If the program has been interrupted, the results already computed are stored in working files.");
  pl("If one restarts the program, the computation is continues.");
  pl("Sometimes it takes minutes, sometimes up to ours until a program stops after pressing STRG-C");
  print_usage();
}

/* --- check_fam_graph_nooverlap4part_nlink_max(filename) --- */

static bool check_fam_graph_nooverlap4part_nlink_max(const Str &path_dir, const Str &filename, int n_brick) {

  Str path = path_dir + sep_path + filename;
  FILE *f;
  if (!open_file(path, "rt", f)) return false;

  bool ok = check_fam_graph_nooverlap4part_nlink_max(f,path,n_brick);
  fclose(f);
  if (ok) pl("File ok");
  return ok;
}

/* --- check_seq_famgraph_fac64(FILE) --- */

static bool check_seq_famgraph_fac64(FILE *f, const Str &path_file, int n_brick) {
  int c;
  int n_link = n_brick*(n_brick-1)/2, i_line=0;
  unsigned int pos=0U;

  while ((++pos, c=getc(f))!=EOF) {

    if (c=='-') {
      ++pos;
      c=getc(f);
    }

    while ('0'<=c && c<='9') {
      ++pos;
      c=getc(f);
    }

    if (c!='*') {
      return err("Error 1 in line $, character $", i_line+1, pos);
    }

    int i_link;
    for (i_link=0; i_link<n_link; ++i_link) {
      if (++pos, c=getc(f), !('1'<=c && c<='3')) {
        return err("Error 2 in line %d, character %u", i_line+1, pos);
      }
    }

    ++pos;
    if (getc(f)!='\n') return err("Error 3 in line %d, character %u", i_line+1, pos);
    ++i_line;
  }

  return true;
}

/* --- check_fam_graph_nooverlap4part_nlink_max(FILE) --- */

static bool check_fam_graph_nooverlap4part_nlink_max(FILE *f, const Str &path_file, int n_brick) {
  int c;

  // file=filename
  if (!(
    getc(f)=='f' &&
    getc(f)=='i' &&
    getc(f)=='l' &&
    getc(f)=='e' &&
    getc(f)=='='
  )) return false;
  while ((c=getc(f))!='\n') {
    if (c==EOF) return err("Error in Line 1");
  }

  // n=$n
  int n=0;
  if (!(getc(f)=='n' && getc(f)=='=')) return err("Error in line 2");
  while (c=getc(f), '0'<=c && c<='9') {
    n=10*n+(int(c)-int('0'));
  }
  if (c!='\n') return err("Error in line 2");

  int i, n_link = n_brick*(n_brick-1)/2;
  for (i=0; i<n; ++i) {

    c=getc(f);
    if (c=='-') {
      c=getc(f);
    }

    while ('0'<=c && c<='9') {
      c=getc(f);
    }

    if (c!='*') {
      return err("Error in line %d", 3+i);
    }

    int i_link;
    for (i_link=0; i_link<n_link; ++i_link) {
      if (c=getc(f), !('1'<=c && c<='3')) {
        return err("Error in line %d", 3+i);
      }
    }

    if (getc(f)!='\n') return err("Error in line %d", 3+i);
  }

  if (!(
    getc(f)=='c' &&
    getc(f)=='h' &&
    getc(f)=='k' &&
    getc(f)=='s' &&
    getc(f)=='u' &&
    getc(f)=='m' &&
    getc(f)=='='
  )) return false;
  while ((c=getc(f))!='\n') {
    if (c==EOF) return err("Error in line %d", 3+n);
  }

  if (getc(f)!=EOF) return err("DExpected end of line in line $", 3+n);
  return true;
}

/* --- read_bmp4graph --- */

static bool read_bmp4graph(int n_brick, const Str &path, bool *&arr) {
  FKT "read_bmp4graph";

  In4File in;
  if (!in.open(path)) return false;

  int n = get_n_graph_conn4n_brick(n_brick);
  arr = new bool[n];
  if (arr==0) errstop_memoverflow(fkt);

  int i, hex=-1, i_bit4hex, i_hex4line=0;
  char c;
  log("Read bitmap from file \"$\"...", path);
  for (i=0; i<n; ++i) {

    // Read new hexdigit, if no hexdigit present
    if (hex<0) {

      // Read end of line, if at end of line
      if (i_hex4line==N_HEX4LINE_DB) {
        if (!in.read_eoln()) return false;
        i_hex4line=0;
      }

      // Read character
      if (in.at_end()) return in.In::err_at("Expected hex digit");
      c=*in;
      if ('0'<=c && c<='9') {
        hex = int(c)-int('0');
      } else if ('a'<=c && c<='f') {
        hex = int(c)-int('a')+10;
      } else {
        return in.In::err_at("Expected hex digit");
      }
      ++in;
      ++i_hex4line;
      i_bit4hex=0;
    }

    // Retrieve exclude bit
    arr[i] = (hex & (1<<i_bit4hex))>0;

    // Advance to next bit
    ++i_bit4hex;
    if (i_bit4hex==4) {
      hex=-1; // Mark hexdigit as invalid
    }
  }

  log("Bitmap readed.");
  return true;
}

/* --- read_evtl_fam_graph_nooverlap_part_n_link_i_block --- */

// fam_graph_nooverlap4part($part)nlink($nlink)block($iblock).dat

static bool read_evtl_fam_graph_nooverlap_part_n_link_i_block(const Str &filename, Part &part, int &n_link, int &i_block) {
  static const Str s_start("fam_graph_nooverlap4part"), s_nlink("nlink"), s_end(".dat");
  In4Str in(filename);

  if (!in.read_evtl_str_given(s_start)) return false;
  if (!in.read_evtl_char_given('(')) return false;
  if (!read_evtl(in, part)) return false;
  if (!in.read_evtl_char_given(')')) return false;

  if (!in.read_evtl_str_given(s_nlink)) return false;
  if (!in.read_evtl_char_given('(')) return false;
  if (!in.read_evtl_card(n_link)) return false;
  if (!in.read_evtl_char_given(')')) return false;

  if (!in.read_evtl_str_given(c_block)) return false;
  if (!in.read_evtl_char_given('(')) return false;
  if (!in.read_evtl_card(i_block)) return false;
  if (!in.read_evtl_char_given(')')) return false;

  if (!in.read_evtl_str_given(s_end)) return false;

  return in.at_end();
}

static bool check_seq_famgraph_fac64(const Str &path_dir, const Str &filename, int n_brick) {

  Str path = path_dir + sep_path + filename;
  FILE *f;
  if (!open_file(path, "rt", f)) return false;

  bool ok = check_seq_famgraph_fac64(f,path,n_brick);
  fclose(f);
  if (ok) pl("File ok");
  return ok;
}



///////////////////
// FILE mdim.cpp //
///////////////////

/* === MDim ============================================================== */

/* --- set_all --- */

void MDim::set_all(int val) {
  if (arr==0) return;

  int i_elem;
  for (i_elem=0; i_elem<n_elem; ++i_elem) {
    arr[i_elem] = val;
  }
}

/* --- get_ref --- */

int &MDim::get_ref(int *arr_var) {
  FKT "MDim::get_ref";

  // if (p_n_var!=n_dim) errstop(fkt, "Falsche Anzahl von Dimensionen");

  int i_elem=0, i_var, var0 = arr_var[arr_i_var[0]];
  for (i_var=1; i_var<n_var; ++i_var) {

    int l=arr_l[i_var];
    i_elem*=l;

    int i_rel = arr_var[arr_i_var[i_var]]-var0-arr_lb[i_var];
    if (!(0<=i_rel && i_rel<l)) errstop_index(fkt);
    i_elem+=i_rel;
  }

  if (!(0<=i_elem && i_elem<n_elem)) errstop_index(fkt);
  return arr[i_elem];
}

/* --- destructor --- */

MDim::~MDim() {
  if (arr) delete[] arr;
}

/* --- contructor --- */

MDim::MDim(const int *p_arr_lb, const int *arr_ub, const int *p_arr_i_var, int p_n_var) : n_var(p_n_var) {
  FKT "MDim::MDim";

  if (!(1<=n_var && n_var<=N_BRICK_MAX)) errstop(fkt, "n_var ausserhalb des gueltigen Bereichs");

  memcpy(arr_lb   , p_arr_lb   , n_var*sizeof(int));
  memcpy(arr_i_var, p_arr_i_var, n_var*sizeof(int));
  if (!(arr_lb[0]==0 && arr_ub[0]==1)) errstop(fkt, "Grenzen der ersten Variable ungueltig");

  int i_var;
  n_elem=1;
  for (i_var=1; i_var<n_var; ++i_var) {
    int l = arr_ub[i_var] - arr_lb[i_var];

    if (l<0) errstop(fkt, "Mind. eine Dimension hat eine negative Zahl von Elementen");
    arr_l[i_var] = l;

    int n_elem_bak=n_elem;
    n_elem*=l;
    if (n_elem<0 || (l>0 && n_elem/l!=n_elem_bak)) errstop(fkt, "Zu viele Elemente");
  }

  if (n_elem==0) {
    arr=0;
  } else {
    arr = new int[n_elem];
    if (arr==0) errstop_memoverflow(fkt);
  }
}


/* === CacheDword4Bound ================================================== */

/* --- constructor --- */

CacheDword4Bound::CacheDword4Bound(const int *p_arr_lb, const int *p_arr_ub, const bool *arr_is_prm, int n_var) {
  FKT "CacheDword4Bound::CacheDword4Bound";

  if (!(0<=n_var && n_var<=N_VAR_MAX)) errstop(fkt, "n_var ausserhalb des gueltigen Bereichs");

  int i_var;
  n_dim=0;
  for (i_var=0; i_var<n_var; ++i_var) {
    if (arr_is_prm[i_var]) {
      arr_i_var[n_dim] =          i_var ;
      arr_lb   [n_dim] = p_arr_lb[i_var];
      ++n_dim;
    }
  }

  if (n_dim==0) errstop(fkt, "n_dim=0");

  int i_dim;
  n_elem=1;
  for (i_dim=0; i_dim<n_dim; ++i_dim) {
    int i_var = arr_i_var[i_dim];
    int l = p_arr_ub[i_var] - p_arr_lb[i_var] + 1;

    if (l<=0) errstop(fkt, "Mind. eine Dimension hat eine nicht positive Zahl von Elementen");
    arr_l[i_dim] = l;

    int n_elem_bak=n_elem;
    n_elem*=l;
    if (n_elem<0 || (l>0 && n_elem/l!=n_elem_bak)) errstop(fkt, "Zu viele Elemente");
  }

  if (n_elem==0) {
    arr=0;
  } else {
    arr = new DWORD[n_elem];
    if (arr==0) errstop_memoverflow(fkt);
  }
}

/* --- destructor --- */

CacheDword4Bound::~CacheDword4Bound() {
  if (arr) {
    delete[] arr;
  }
}

/* --- set_all --- */

void CacheDword4Bound::set_all(DWORD val) {
  if (arr==0) return;

  int i_elem;
  for (i_elem=0; i_elem<n_elem; ++i_elem) {
    arr[i_elem] = val;
  }
}

/* --- get_ref --- */

DWORD &CacheDword4Bound::get_ref(const int *arr_var) {
  FKT "CacheDword4Bound::get_ref";

  int i_elem=0, i_dim, var0=arr_var[arr_i_var[0]];
  for (i_dim=1; i_dim<n_dim; ++i_dim) {

    int l=arr_l[i_dim];
    i_elem*=l;

    int i_rel = arr_var[arr_i_var[i_dim]]-arr_lb[i_dim]-var0;
    if (!(0<=i_rel && i_rel<l)) errstop_index(fkt);
    i_elem+=i_rel;
  }

  if (!(0<=i_elem && i_elem<n_elem)) errstop_index(fkt);
  return arr[i_elem];
}

/* --- get_size --- */

double CacheDword4Bound::get_size(const int *arr_lb, const int *arr_ub, const bool *arr_is_prm, int n_var) {
  int i_var;
  double res=4.0; // = size of a DWORD, in byte

  for (i_var=0; i_var<n_var; ++i_var) {
    if (arr_is_prm[i_var]) {
      res*=(double)(arr_ub[i_var]-arr_lb[i_var]+1);
    }
  }

  return res;
}





/////////////////////
// FILE mirror.cpp //
/////////////////////

/* === exported functions ================================================ */

/* --- mirror4center --- */

Pos4Fig mirror4center(const Pos4Fig &pos) {
  Pos4Fig res;
  res.x = -pos.x;
  res.y = -pos.y;
  res.z =  pos.z;
  res.rotated = pos.rotated;
  return res;
}

/* --- get_fun_mirror --- */

void get_fun_mirror(const Part &part, const FamGraph &fam_graph, SetPerm &target) {

  int arr_sum_brick4layer[N_BRICK_MAX+1], i_layer, n_layer=part.get_n_layer();
  arr_sum_brick4layer[0]=0;
  for (i_layer=0; i_layer<n_layer; ++i_layer) {
    arr_sum_brick4layer[i_layer+1] = arr_sum_brick4layer[i_layer] + part.get_n_brick4layer(i_layer);
  }
  
  int data[N_BRICK_MAX], i_brick;
  for (i_layer=0; i_layer<n_layer; ++i_layer) {
    int l = arr_sum_brick4layer[i_layer  ];
    int u = arr_sum_brick4layer[i_layer+1];
    int s=l+u-1;
    for (i_brick=l; i_brick<u; ++i_brick) {
      data[i_brick] = s-i_brick;
    }
  }

  target.clear();

  int j_brick, n_brick=part.get_n_brick();
  for (i_brick=0; i_brick<n_brick; ++i_brick) {
    for (j_brick=0; j_brick<i_brick; ++j_brick) {
      if (!compatible(
        fam_graph.get_overlap(     i_brick ,      j_brick ),
        fam_graph.get_overlap(data[i_brick], data[j_brick])
      )) return;
    }
  }

  Perm fun_mirror(n_brick, data);
  target.insert(fun_mirror);
}





////////////////
// FILE str.h //
////////////////

// From c:\consql



///////////////////
// FILE part.cpp //
///////////////////

/* --- declare static functions --- */

// static bool iterate(int n_brick, Part&, Performer<Part>&);


/* === Part ============================================================== */

/* --- iterate_perm_conform_rek --- */

bool Part::iterate_perm_conform_rek(int n_brick_set, bool *arr_used, const int *arr_i_layer4brick, int *arr_i_brick, Performer<Perm> &performer) const {
  if (n_brick_set==n_brick) {
    Perm perm(n_brick, arr_i_brick);
    return performer.perform(perm);
  }

  int &i_brick_next = arr_i_brick[n_brick_set];
  int i_layer = arr_i_layer4brick[n_brick_set];
  for (i_brick_next=0; i_brick_next<n_brick; ++i_brick_next) if (i_layer==arr_i_layer4brick[i_brick_next]) {

    bool &used =arr_used[i_brick_next];
    if (used) continue;
    used=true;

    if (!iterate_perm_conform_rek(n_brick_set+1, arr_used, arr_i_layer4brick, arr_i_brick, performer)) return false;

    used=false;
  }

  return true;
}

/* --- cmp --- */

int cmp(const Part &a, const Part &b) {
  FKT "cmp(Part, Part)";
  int n_layer=a.n_layer;
  if (n_layer!=b.n_layer) errstop(fkt, "Partitionen koennen nicht verglichen werden");

  int i_layer;
  for (i_layer=0; i_layer<n_layer; ++i_layer) {
    int res=cmp_int(a.arr_n_brick4layer[i_layer], b.arr_n_brick4layer[i_layer]);
    if (res) return res;
  }
  return 0;
}

/* --- revert --- */

void Part::revert() {
  int i_layer, j_layer;

  for (i_layer=0, j_layer=n_layer-1; j_layer>i_layer; ++i_layer, --j_layer) {
    swap(arr_n_brick4layer[i_layer], arr_n_brick4layer[j_layer]);
  }
}

/* --- iterate_perm_conform --- */

bool Part::iterate_perm_conform(Performer<Perm> &performer) const {

  int arr_i_layer4brick[N_BRICK_MAX];
  get_arr_i_layer4brick(arr_i_layer4brick);

  bool arr_used[N_BRICK_MAX];
  set(arr_used, n_brick, false);

  int arr_i_brick[N_BRICK_MAX];
  return iterate_perm_conform_rek(0, arr_used, arr_i_layer4brick, arr_i_brick, performer);
}

/* --- to_str --- */

int Part::get_n_brick4layer(int i_layer) const {
  FKT "Part::get_n_brick4layer";

  if (!(0<=i_layer && i_layer<n_layer)) errstop_index(fkt);

  return arr_n_brick4layer[i_layer];
}

/* --- to_str --- */

Str Part::to_str() const {
  Str res = str4card(n_brick);
  res+='=';

  int i_layer;
  for (i_layer=0; i_layer<n_layer; ++i_layer) {
    if (i_layer) res+='+';
    res+=str4card(arr_n_brick4layer[i_layer]);
  }

  return res;
}

/* --- get_n_perm --- */

// Computes the number of brick permutations preserving the z-values.

int Part::get_n_perm() const {
  int i_layer, res=1;

  for (i_layer=0; i_layer<n_layer; ++i_layer) res*=fac(arr_n_brick4layer[i_layer]);
  return res;
}

/* --- get_n_link --- */

// Computes the number of possible links from one layer to another

int Part::get_n_link() const {
  int i_layer, i_layer1, res=0;

  for (i_layer=0, i_layer1=1; i_layer1<n_layer; ++i_layer1, ++i_layer) {
    res+=arr_n_brick4layer[i_layer]*arr_n_brick4layer[i_layer1];
  }

  return res;
}

/* --- get_arr_i_layer4brick --- */

// Computes z-values.

void Part::get_arr_i_layer4brick(int *arr_i_layer) const {
  int i_brick, i_layer;

  for (i_brick=i_layer=0; i_layer<n_layer; ++i_layer) {
    int n_brick4layer = arr_n_brick4layer[i_layer], i_brick4layer;
    for (i_brick4layer=0; i_brick4layer<n_brick4layer; ++i_brick4layer, ++i_brick) {
      arr_i_layer[i_brick]=i_layer;
    }
  }
}

/* --- get_arr_ij_brick4link --- */

void Part::get_arr_ij_brick4link(int *arr_i_brick4i_link, int *arr_j_brick4i_link, int &n_link) const {

  int arr_i_layer[N_BRICK_MAX];
  get_arr_i_layer4brick(arr_i_layer);

  int i_brick, j_brick;
  n_link=0;
  for (i_brick=0; i_brick<n_brick; ++i_brick) {
    for (j_brick=0; j_brick<i_brick; ++j_brick) {
      if (arr_i_layer[i_brick] == arr_i_layer[j_brick]+1) {
        arr_i_brick4i_link[n_link]=i_brick;
        arr_j_brick4i_link[n_link]=j_brick;
        ++n_link;
      }
    }
  }
}

/* --- iterate --- */

bool Part::iterate(int n_brick, Performer<Part> &performer) {
  Part part;
  return iterate_rek(n_brick, part, performer);
}

/* --- iterate_rek --- */

bool Part::iterate_rek(int n_brick, Part &part, Performer<Part> &performer) {
  FKT "iterate(int, Part, Performer<Part>)";

  if (n_brick==part.n_brick) {
    return performer.perform(part);
  }

  if (part.n_layer>=N_BRICK_MAX) errstop(fkt, "part.n_layer to large");

  int &n_tile4layer = part.arr_n_brick4layer[part.n_layer];
  bool ok;
  for (n_tile4layer=1; part.n_brick+n_tile4layer<=n_brick; ++n_tile4layer) {
    ++part.n_layer; part.n_brick += n_tile4layer;
    ok = iterate_rek(n_brick, part, performer);
    --part.n_layer; part.n_brick -= n_tile4layer;
    if (!ok) return false;
  }

  return true;
}

/* --- default constructor --- */

Part::Part() : n_brick(0), n_layer(0) {}

/* --- add_layer_silent --- */

bool Part::add_layer_silent(int n_brick4layer, Str &errtxt) {
  if (!(0<n_brick4layer && n_brick4layer<=N_BRICK_MAX)) return err_silent(errtxt, "n_brick4layer ausserhalb desgueltigen Bereiches");
  if (n_brick+n_brick4layer > N_BRICK_MAX) return err_silent(errtxt, "Zu viele Legosteine");
  n_brick+=n_brick4layer ;
  arr_n_brick4layer[n_layer]=n_brick4layer;
  ++n_layer;
  return true;
}


/* === exported functions ================================================== */

/* --- read_silent --- */

bool read_silent(In &in, Part &p_part, Str &errtxt) {
  Part l_part;
  l_part.clear();

  int n_brick, n_brick4layer;

  if (!in.read_card_silent(n_brick,  errtxt)) return false;
  if (!in.read_char_given_silent('=', errtxt)) return false;
  if (!in.read_card_silent(n_brick4layer, errtxt)) return false;
  if (!l_part.add_layer_silent(n_brick4layer, errtxt)) return false;
  while (in.read_evtl_char_given('+')) {
    if (!in.read_card_silent(n_brick4layer, errtxt)) return false;
    if (!l_part.add_layer_silent(n_brick4layer, errtxt)) return false;
  }
  if (n_brick!=l_part.get_n_brick()) return err_silent(errtxt, "Anzahl Legosteine ungleich Summe der Anzahlen der Legosteine in den Schichten");

  p_part=l_part;
  return true;
}

/* --- read_evtl --- */

bool read_evtl(In &in, Part &part) {
  Str errtxt;

  return read_silent(in, part, errtxt);
}


////////////////////
// FILE setimpl.h //
////////////////////

// From c:\kombin\lego2\footprnt



///////////////////
// FILE perm.cpp //
///////////////////

/* --- declare static functions --- */

static void set_perm4i(int *data, int n, int i_perm);
static int get_i_perm(int *data, int n);


/* === Perm ============================================================== */

/* --- get_i --- */

int Perm::get_i() const {
  FKT "Perm::get_i";

  int data_tmp[N_BRICK_MAX];
  memcpy(data_tmp, data, n*sizeof(int));

  if (n>N_BRICK_MAX) errstop(fkt, "n>N_BRICK_MAX");

  return get_i_perm(data_tmp,n);
}

/* --- set_i --- */

void Perm::set_i(int i_perm) {
  set_perm4i(data,n,i_perm);
}

/* --- constructor --- */

Perm::Perm(int p_n, int *p_data) : n(p_n), data(p_data) {}

/* --- iterate --- */

bool Perm::iterate(int n, Performer<Perm> &performer) {
  FKT "Perm::iterate(int, Performer<Perm>)";
  int arr_fix[N_BRICK_MAX], *arr;
  bool arr_used_fix[N_BRICK_MAX], *arr_used;

  if (n>N_BRICK_MAX) {
    arr = new int[n];
    if (arr==0) errstop_memoverflow(fkt);

    arr_used = new bool[n];
    if (arr_used==0) errstop_memoverflow(fkt);
  } else {
    arr = arr_fix;
    arr_used = arr_used_fix;
  }

  int i;
  for (i=0; i<n; ++i) arr_used[i]=false;

  Perm perm(n, arr);
  bool ok;
  ok =  iterate_rek(perm, 0, arr_used, performer);

  if (n>N_BRICK_MAX) {
    delete[] arr;
    delete[] arr_used;
  }

  return ok;
}

/* --- iterate_rek --- */

bool Perm::iterate_rek(Perm &perm, int i, bool *arr_used, Performer<Perm> &performer) {
  int n=perm.n;

  if (i==n) return performer.perform(perm);

  int &elem = perm.data[i];
  for (elem=0; elem<n; ++elem) {
    bool &used = arr_used[elem];
    if (!used) {
      used=true;
      if (!iterate_rek(perm, i+1, arr_used, performer)) return false;
      used=false;
    }
  }

  return true;
}

/* --- hashind --- */

unsigned int Perm::hashind() const {
  unsigned int res=0U;
  int i;

  for (i=0; i<n; ++i) res=5U*res+(unsigned int) data[i];
  return res;
}

/* --- Perm==Perm --- */

bool operator==(const Perm &a, const Perm &b) {

  int n=a.n;
  if (n!=b.n) return false;

  int i;
  for (i=0; i<n; ++i) if (a.data[i]!=b.data[i]) return false;
  return true;
}


/* === SetPerm =========================================================== */

/* --- clear --- */

void SetPerm::clear() {
  inner.clear();
}

/* --- constructor --- */

SetPerm::SetPerm(int p_n) : n(p_n) {
  FKT "SetPerm::SetPerm";

  if (!(0<=n && n<=N_BRICK_MAX)) errstop_index(fkt);
}

/* --- insert --- */

void SetPerm::insert(const Perm &perm) {
  FKT "SetPerm::insert";
  if (perm.n!=n) errstop(fkt, "perm.n!=n");

  int i = perm.get_i();
  inner.insert(i);
}

/* --- iterate --- */

bool SetPerm::iterate(Performer<Perm> &performer) const {
  TransformerInt2Perm transformer(n, performer);
  return inner.iterate(transformer);
}


/* === TransformerInt2Perm =============================================== */

/* --- perform --- */

bool TransformerInt2Perm::perform(const int &i_perm) {
  int data[N_BRICK_MAX];
  Perm perm(n,data);
  perm.set_i(i_perm);
  return inner.perform(perm);
}

/* --- constructor --- */

TransformerInt2Perm::TransformerInt2Perm(int p_n, Performer<Perm> &p_inner) : inner(p_inner), n(p_n) {}


/* === static functions ================================================== */

/* --- get_i_perm --- */

static int get_i_perm(int *data, int n) {
  if (n==0) return 0;

  int i_last = n-1;
  int last=data[i_last];

  int i;
  for (i=0; i<i_last; ++i) {
    int &val=data[i];
    if (val>=last) --val;
  }

  return get_i_perm(data,n-1)*n+last;
}

/* --- set_perm4i --- */

static void set_perm4i(int *data, int n, int i_perm) {
  FKT "set_perm4i";

  if (n==0) {
    if (i_perm!=0) errstop(fkt, "n==0 && i_perm!=0");
    return;
  }

  if (n<0) errstop(fkt, "n<0");

  set_perm4i(data, n-1, i_perm/n);

  int i_last = n-1;
  int last = i_perm%n;
  data[i_last]=last;

  int i;
  for (i=0; i<i_last; ++i) {
    int &val=data[i];
    if (val>=last) ++val;
  }
}

////////////////
// FILE str.h //
////////////////

// From c:\consql




///////////////////
// FILE read.cpp //
///////////////////

/* === In ================================================================ */

/* --- destructor --- */

In::~In() {}

/* --- err_at(Str) --- */

bool In::err_at(Str txt) const {
  return err_at(txt, get_pos());
}

/* --- read_unsigned --- */

bool In::read_unsigned(double &x) {
  Str errtxt;
  if (read_unsigned_silent(x, errtxt)) {
    return true;
  } else {
    return err_at(errtxt);
  }
}

/* --- read_card --- */

bool In::read_card(int &n) {
  Str errtxt;
  if (read_card_silent(n, errtxt)) {
    return true;
  } else {
    return err_at(errtxt);
  }
}

/* --- read_str_given_silent --- */

bool In::read_str_given_silent(const Str &given, Str &errtxt) {
  int l=given.get_l(), i;

  for (i=0; i<l; ++i) {
    if (!read_evtl_char_given(given.get(i))) {
      return err_silent(errtxt, Str("\"") + given + Str("\" erwartet"));;
    }
  }

  return true;
}

/* --- read_str_given --- */

bool In::read_str_given(const Str &given) {
  Str errtxt;
  if (read_str_given_silent(given, errtxt)) {
    return true;
  } else {
    return err_at(errtxt);
  }
}

/* --- read_evtl_char_given --- */

bool In::read_evtl_char_given(char given) {
  In &me=*this;

  if (at_end()) return false;
  if (*me!=given) return false;
  if (!++me) return false;
  return true;
}

/* --- read_eoln_silent --- */

bool In::read_eoln_silent(Str &errtxt) {
  if (!read_evtl_char_given('\n')) {
    return err_silent(errtxt, "Zeilenende erwartet");
  }
  return true;
}

/* --- read_evtl_card --- */

bool In::read_evtl_card(int &n) {
  In &me=*this;

  char c;
  if (!(!at_end() && (c=*me, '0'<=c && c<='9'))) return false;
  n=(int)c-(int)'0';
  if (!++me) return false;

  while (!at_end() && (c=*me, '0'<=c && c<='9')) {
    n=10*n+(int)c-(int)'0';
    if (!++me) return false;
  }

  return true;
}

/* --- read_char_given --- */

bool In::read_char_given(char given) {
  Str errtxt;
  if (read_char_given_silent(given, errtxt)) {
    return true;
  } else {
    return err_at(errtxt);
  }
}

bool In::err_at(Str,int,int)const {
  return false;
}

bool In::err_at(Str txt, Card64 pos) const {return false;}


/* --- read_unsigned_silent --- */

bool In::read_unsigned_silent(double &x, Str &errtxt) {
  char c;
  In &me=*this;

  if (!(!at_end() && (c=*me, '0'<=c && c<='9'))) return err_silent(errtxt, "Fliesskommazahl erwartet");
  x=(double)c-(double)'0';
  if (!++me) return false;

  while (!at_end() && (c=*me, '0'<=c && c<='9')) {
    x=10.0*x+(double)c-(double)'0';
    if (!++me) return false;
  }

  int exp;
  if (read_evtl_char_given('>')) {
    if (!read_char_given_silent('>', errtxt)) return false;
    if (!read_card_silent(exp,errtxt)) return false;

    for (;exp;--exp) x/=2.0;
  } else if (read_evtl_char_given('<')) {
    if (!read_char_given_silent('<', errtxt)) return false;
    if (!read_card_silent(exp,errtxt)) return false;

    for (;exp;--exp) x*=2.0;
  }

  return true;
}


/* --- read_card_silent --- */

bool In::read_card_silent(int &n, Str &errtxt) {
  char c;
  In &me=*this;

  if (!(!at_end() && (c=*me, '0'<=c && c<='9'))) return err_silent(errtxt, "Vorzeichenlose ganze Zahl erwartet");
  n=(int)c-(int)'0';
  if (!++me) return false;

  while (!at_end() && (c=*me, '0'<=c && c<='9')) {
    n=10*n+(int)c-(int)'0';
    if (!++me) return false;
  }

  return true;
}

/* --- read_char_given_silent --- */

bool In::read_char_given_silent(char given, Str &errtxt) {
  if (!read_evtl_char_given(given)) {
    return err_silent(errtxt, Str("Zeichen \'") + Str(&given,1) + Str("\' erwartet"));
  }
  return true;
}

/* --- read_int --- */

bool In::read_int(int &n) {
  if (read_evtl_char_given('+')) return read_card(n);
  if (read_evtl_char_given('-')) {
    if (!read_card(n)) return false;
    n=-n;
    return true;
  }
  return read_card(n);
}

/* --- read_eoln --- */

bool In::read_eoln() {
  Str errtxt;
  if (read_eoln_silent(errtxt)) {
    return true;
  } else {
    return err_at(errtxt);
  }
}

/* --- err_at(NTS) --- */

bool In::err_at(const char *txt) const {
  Str txt_s(txt);
  return err_at(txt_s);
}



/* === InBuffered ======================================================== */

/* --- destructor --- */

InBuffered::~InBuffered() {}

/* --- err_at(NTS, pos) --- */

bool InBuffered::err_at(const char *txt, const Card64 &pos) const {
  Str txt_s(txt);
  return In::err_at(txt_s, pos);
}

/* --- read_evtl_str_given --- */

bool InBuffered::read_evtl_str_given(const Str &given) {
  const Card64 pos_start = get_pos();
  int l=given.get_l(), i;

  for (i=0; i<l; ++i) {
    if (!read_evtl_char_given(given.get(i))) {
      set_pos(pos_start);
      return false;
    }
  }

  return true;
}


/* === InBuffering ========================================================= */

/* --- constructor --- */

InBuffering::InBuffering(In &p_in) : in(p_in), pos(in.get_pos()), pos_max(in.get_pos()), i_line(0), i_col(0) {
  int i4buff = pos&((DWORD)(SIZE_BUFF_IN-1));
  if (in.at_end()) {
    arr_at_end[i4buff] = true;
  } else {
    arr_at_end[i4buff] = false;
    buff      [i4buff] = *in;
    arr_i_line[i4buff] = 0;
    arr_i_col [i4buff] = 0;
  }
}

/* --- err_at --- */

bool InBuffering::err_at(Str msg, Card64 pos_err) const {
  return in.err_at(msg, get_i_line(pos_err), get_i_col(pos_err));
}

/* --- ++InBuffering --- */

bool InBuffering::operator++() {
  if (pos==pos_max) {
    if (!++in) return false;
    ++pos; ++pos_max;

    int i4buff = pos&((DWORD)(SIZE_BUFF_IN-1));
    if (in.at_end()) {
      arr_at_end[i4buff]=true;
    } else {

      char c=*in;
      if (c=='\n') {
        ++i_line;
        i_col=0;
      } else {
        ++i_col;
      }

      arr_at_end[i4buff] = false;
      buff      [i4buff] = c     ;
      arr_i_line[i4buff] = i_line;
      arr_i_col [i4buff] = i_col ;
    }
  } else {
    ++pos;
  }

  return true;
}

/* --- *InBuffering --- */

char InBuffering::operator*() {
  FKT "InBuffering::operator*";
  int i4buff = pos&((DWORD)(SIZE_BUFF_IN-1));
  if (arr_at_end[i4buff]) errstop(fkt, "Reached end of file");
  return buff[i4buff];
}

/* --- get_i_line --- */

int InBuffering::get_i_line(Card64 pos_err) const {
  FKT "InBuffering::get_i_line";

  if (pos_err>pos_max) errstop(fkt, "pos_err>pos_max");
  if (pos_err+Card64((DWORD)SIZE_BUFF_IN)<=pos_max) errstop(fkt, "pos_err too low");

  int i4buff = pos_err&((DWORD)(SIZE_BUFF_IN-1));
  return arr_i_line[i4buff];
}

/* --- get_i_col --- */

int InBuffering::get_i_col(Card64 pos_err) const {
  FKT "InBuffering::get_i_col";

  if (pos_err>pos_max) errstop(fkt, "pos_err>pos_max");
  if (pos_err+Card64((DWORD)SIZE_BUFF_IN)<=pos_max) errstop(fkt, "pos_err too low");

  int i4buff = pos_err&((DWORD)(SIZE_BUFF_IN-1));
  return arr_i_col[i4buff];
}

/* --- set_pos --- */

void InBuffering::set_pos(const Card64 &pos_new) {
  FKT "InBuffering::set_pos";
  if (pos_new>pos_max) errstop(fkt, "pos_new>pos_max");
  if (pos_new+Card64((DWORD)SIZE_BUFF_IN)<=pos_max) errstop(fkt, "pos_err too low");

  pos=pos_new;
}

/* --- at_end --- */

bool InBuffering::at_end() const {
  int i4buff = pos&((DWORD)(SIZE_BUFF_IN-1));
  return arr_at_end[i4buff];
}

/*`--- err_at(LINE, COL) --- */

bool InBuffering::err_at(Str msg, int i_line, int i_col) const {
  return in.err_at(msg, i_line, i_col);
}

/* --- get_pos --- */

const Card64& InBuffering::get_pos() const {
  return pos;
}


/* === In4File ============================================================= */

/* --- constructor --- */

In4File::In4File() : f(0) {}

/* --- set_pos ---

void In4File::set_pos(const Card64 &pos_new) {
  FKT "In::set_pos";

  if (f==0) errstop(fkt, "not opened");
  if (pos_new>=n_advanced) errstop(fkt, "pos_new too large");
  if (pos_new<0) errstop(fkt, "pos_new<0");
  if (pos_new+Card64((DWORD)SIZE_BUFF_IN)<n_advanced) errstop(fkt, "pos_new too low");

  pos=pos_new;

  int i4buff = pos&((DWORD)(SIZE_BUFF_IN-1));
  i_line = buff_i_line[i4buff];
  i_col  = buff_i_col [i4buff];
  c      = buff_c     [i4buff];
}*/

/* --- ++In4File --- */

bool In4File::operator++() {
  FKT "In4File::operator++";

  if (f==0) errstop(fkt, "File not opened");
  ++pos;
  if (c==EOF) errstop(fkt, "Exceeded end of file");
  c=getc(f);

  return true;
}

/* --- err_at(pos) --- */

bool In4File::err_at(Str msg, Card64 pos) const {
  char buff[N_DIGIT4CARD64+1];
  Str txt;

  txt+="Error in file ";
  txt+=enquote(path);
  txt+=", character ";
  txt+=to_nts(pos, buff, sizeof(buff));
  txt+=": ";
  txt+=msg;
  return err(txt);
}

/* --- err_at(LINE, COL) --- */

bool In4File::err_at(Str msg, int i_line, int i_col) const {
  Str txt;
  txt+="Error in file ";
  txt+=enquote(path);
  txt+="line ";
  txt+=str4card(i_line+1);
  txt+=", character ";
  txt+=str4card(i_col+1);
  txt+=": ";
  txt+=msg;
  return err(txt);
}

/* --- get_pos --- */

const Card64 &In4File::get_pos() const {
  return pos;
}

/* --- open --- */

bool In4File::open(Str p_path) {
  FKT "In4File::open";
  if (f!=0) errstop(fkt, "Bereits geoeffnet");
  if (!open_file(p_path, "rt", f)) return err(Str("Cannot open file ") + enquote(p_path) + Str(" for read."));
  c=getc(f);
  pos=Card64::zero;
  path=p_path;
  return true;
}

/* --- at_end --- */

bool In4File::at_end() const {
  FKT "In4File::at_end";
  if (f==0) errstop(fkt, "File not opened");
  return c==EOF;
}

/* --- *In4File --- */

char In4File::operator*() {
  FKT "In4File::operator*";
  if (f==0) errstop(fkt, "File not opened");
  if (c==EOF) errstop(fkt, "Reached end of file");
  return (char)c;
}

/* --- close --- */

bool In4File::close() {
  if (f==0) return true;
  fclose(f);
  f=0;
  return true;
}


/* === In4Str ============================================================ */

/* --- constructor(Str) --- */

In4Str::In4Str(const Str &p_data) : data(p_data), pos(Card64::zero), l(DWORD(p_data.get_l())) {}

/* --- constructor(NTS) --- */

In4Str::In4Str(const char *nts) : data(nts), pos(Card64::zero) {
  l=Card64(DWORD(data.get_l()));
}

/* --- In4Str --- */

void In4Str::set_pos(const Card64 &pos_new) {
  FKT "In4Str::set_pos";
  if (pos_new>=l) errstop_index(fkt);
  pos=pos_new;
}

/* --- err_at --- */

bool In4Str::err_at(Str txt, Card64 pos_err) const {
  return err(txt);
}

/* --- err_at(LINE,COL) --- */

bool In4Str::err_at(Str txt, int i_line, int i_col) const {
  return err(txt);
}

/* --- ++In4Str --- */

bool In4Str::operator++() {
  FKT "In4Str::operator++";
  if (pos>=l) errstop(fkt, "Stringende erreicht");
  ++pos;
  return true;
}

/* --- at_end --- */

bool In4Str::at_end() const {
  return l==pos;
}

/* --- get_pos --- */

const Card64& In4Str::get_pos() const {
  return pos;
}

/* --- *In4Str --- */

char In4Str::operator*() {
  FKT "In4Str::operator*";
  if (pos>=l) errstop(fkt, "Stringende erreicht");
  return data.get(pos.to_int());
}




//////////////////
// FILE rnd.cpp //
//////////////////

/* === Rnd =============================================================== */

/* --- constructor --- */

Rnd::Rnd(unsigned int p_m) : m(p_m) {
  FKT "Rnd::Rnd";
  if (m==0U) errstop(fkt, "m=0");
  r = (unsigned int) time(NULL);
}

/* --- get --- */

unsigned int Rnd::get() {
  r=1009U*r+1U; // This iteration produces a cyclus of 2^32
  return r%m;
}

////////////////
// FILE set.h //
////////////////

// From c:\kombin\lego2\footprnt




//////////////////
// FILE set.cpp //
//////////////////

/* === SetInt ============================================================ */

/* --- hashind --- */

unsigned int SetInt::hashind(const int &n) const {
  return (unsigned int)n;
}

/* --- equal --- */

bool SetInt::equal(const int &a, const int &b) const {
  return a==b;
}

////////////////
// FILE str.h //
////////////////

// From c:\consql




//////////////////
// FILE str.cpp //
//////////////////

/* === Str::Data ========================================================= */

/* --- Constructor --- */

Str::Data::Data(int p_size) : size(p_size), n_ref(1) {
  FKT "Str::Data::Data";

  if (p_size<=0) errstop(fkt, "size<=0");

  s = new char[size];
}

/* --- Destructor --- */

Str::Data::~Data() {
  delete[] s;
}


/* === Str =============================================================== */

/* --- get_pos_first --- */

int Str::get_pos_first(char c) const {
  if (ptr==0) return -1;

  char *s = ptr->s+start;
  int i;
  for (i=0; i<l; ++i) {
    if (s[i]==c) return i;
  }

  return -1;
}

/* --- print --- */

bool Str::print(FILE *f) const {
  if (ptr==0) return true;

  char *s = ptr->s+start;
  int i;
  for (i=0; i<l; ++i) {
    if (putc(s[i], f)<0) return false;
  }
  return true;
}

/* --- constructor(FIX) --- */

Str::Str(const char *buff, int p_l) : l(p_l), start(0) {
  if (l) {
    ptr = new Data(l);
    memcpy(ptr->s, buff, l);
  } else {
    ptr = 0;
  }
}

/* --- dump_nts --- */

void Str::dump_nts(char *buff) const {
  if (ptr==0) return;
  memcpy(buff, ptr->s+start, l);
  buff[l] = '\0';
}

/* --- get --- */

char Str::get(int i) const {
  FKT "Str::get";

  if (!(0<=i && i<l)) errstop_index(fkt);
  return ptr->s[start+i];
}


/* --- assign NTS --- */

void Str::operator=(const char *nts) {

  // Detach from current data
  if (ptr && --(ptr->n_ref)==0) delete ptr;

  l = strlen(nts);
  if (l) {
    ptr = new Data(l);
    memcpy(ptr->s, nts, l);
  } else {
    ptr=0;
  }
  start=0;
}

/* --- Destructor --- */

Str::~Str() {
  if (ptr && --(ptr->n_ref)==0) delete ptr;
}

/* --- default constructor --- */

Str::Str() : ptr(0), l(0), start(0) {}

/* --- copy constructor --- */

Str::Str(const Str &v) : ptr(v.ptr), l(v.l), start(v.start)  {
  if (ptr) ++(ptr->n_ref);
}

/* --- assign --- */

void Str::operator=(const Str &v) {

  // Attach to new data
  if (v.ptr) ++(v.ptr->n_ref);

  // Detach from current data
  if (ptr && --(ptr->n_ref)==0) delete ptr;

  // Copy
  ptr   = v.ptr  ;
  start = v.start;
  l     = v.l    ;
}

/* --- constructor(Seg) --- */

Str::Str(const Str &s, int p_start, int p_end)  {
  FKT "Str::Str(const Str&, int, int)";

  if (!(0<=p_start && p_start<=p_end && p_end<=s.l)) {
    errstop(fkt, "Invalid p_start/p_end");
  }

  l = p_end-p_start;

  if (l) {
    ptr = s.ptr;
    start = s.start+p_start;
    ++(ptr->n_ref);
  } else {
    ptr=0;
    start=0;
  }
}

/* --- +=(char) --- */

void Str::operator+=(char c) {

  // Make sure <ptr> is not zero
  if (ptr==0) {
    ptr = new Data(10);
    start=0;
  }

  // Make sure <ptr> is referenced only once
  if (ptr->n_ref>1) {
    Data *ptr_old = ptr;
    int start_old=start;

    // Detach from old data
    --(ptr->n_ref);

    // Alloc new data
    ptr = new Data(max_int(10,l+1));

    // Copy to new data
    memcpy(ptr->s, ptr_old->s+start_old, l);

    start=0;
  }

  // Make sure buffer is large enough
  int size = ptr->size;
  if (size<=start+l) {
    Data *ptr_old = ptr;
    int start_old=start;

    // Alloc new data
    ptr = new Data(3*size/2+10);

    // Copy to new data
    memcpy(ptr->s, ptr_old->s+start_old, l);

    // Delete old data
    delete ptr_old;

    start=0;
  }

  // Append c
  ptr->s[start+l] = c;
  ++l;
}

/* --- constructor(NTS) --- */

Str::Str(const char *nts) : l(strlen(nts)), start(0) {
  if (l) {
    ptr = new Data(l);
    memcpy(ptr->s, nts, l);
  } else {
    ptr = 0;
  }
}

/* --- Str+=NTS --- */

void Str::operator+=(const char *nts) {
  char c;
  while ((c=*nts)) {
    *this += c;
    ++nts;
  }
}


/* --- Str+=Str --- */

void Str::operator+=(Str str) {
  if (str.l==0) return;

  if (l==0) {

    // Copy
    ptr   = str.ptr  ;
    start = str.start;
    l     = str.l    ;

    // Attach to new data
    ++(ptr->n_ref);

    return;
  }

  // Make sure <ptr> is referenced only once
  int l_new = l+str.l;
  if (ptr->n_ref>1) {
    Data *ptr_old = ptr;
    int start_old=start;

    // Detach from old data
    --(ptr->n_ref);

    // Alloc new data
    ptr = new Data(max_int(10,l_new));

    // Copy to new data
    memcpy(ptr->s, ptr_old->s+start_old, l);

    start=0;
  }

  // Make sure buffer is large enough
  int size = ptr->size;
  if (size<start+l_new) {
    Data *ptr_old = ptr;
    int start_old=start;

    // Alloc new data
    ptr = new Data(max_int(3*size/2+10, l_new));

    // Copy to new data
    memcpy(ptr->s, ptr_old->s+start_old, l);

    // Delete old data
    delete ptr_old;

    start=0;
  }

  // Append str
  memcpy(ptr->s+start+l, str.ptr->s+str.start, str.l);
  l=l_new;
}

/* --- enquote -- -*/

Str enquote(Str s) {
  Str res;
  res+='\"';
  res+=s;
  res+='\"';
  return res;
}

/* --- embrace -- -*/

Str embrace(Str s) {
  Str res;
  res+='(';
  res+=s;
  res+=')';
  return res;
}

/* --- Str+Str --- */

Str operator+(Str a, Str b) {
  a+=b;
  return a;
}

/* --- str4card --- */

Str str4card(int n) {
  FKT "str4card";
  if (n<0) errstop(fkt, "n<0");
  if (n>=10) {
    Str res=str4card(n/10);
    res+=(char)(unsigned char)(unsigned int)(n%10+int('0'));
    return res;
  } else {
    char c = (char)(unsigned char)(unsigned int)(n+int('0'));
    return Str(&c,1);
  }
}

/* --- operator== --- */

bool operator==(Str a, Str b) {
  if (a.l!=b.l) return false;

  int l=a.l;
  if (l==0) return true;
  return memcmp(a.ptr->s+a.start, b.ptr->s+b.start, l)==0;
}

///////////////////
// FILE bigint.h //
///////////////////

// From lego4




////////////////////
// FILE write.cpp //
////////////////////

/* === Out =============================================================== */

bool Out::print_udbl(double x) {
  FKT "Out::print_udbl";

  if (x<0.0) errstop(fkt, "x<0");
  if (x==0.0) return print_char('0');

  // From here on, x>0

  // Force x into range 1..2
  int exp=0;
  while (x<1.0) {
    x*=2.0; --exp;
  }
  while (x>=2.0) {
    x/=2.0; ++exp;
  }

  // Produce mantissa
  Card64 mant(DWORD(0));
  while (true) {
    if (x>=1.0) {
      ++mant;
      x-=1.0;
    }
    if (x==0.0) break;
    x*=2.0;
    mant.dbl();
    --exp;
  }

  // Write mantissa
  char buff[N_DIGIT4CARD64+1];
  if (!print_nts(to_nts(mant, buff, sizeof(buff)))) return false;

  // write exponent
  if (exp) {
    if (!print_nts(exp>0 ? "<<" : ">>")) return false;
    if (!print_uint((unsigned int)(abs(exp)))) return false;
  }

  return true;
}

/* --- printf(int, int, NTS) --- */

bool Out::printf(const char *txt, int prm1, int prm2, const char *prm3) {
  int pos=0;
  if (!print2dollar(txt, pos)) return false;
  if (!print_int(prm1)) return false;
  if (!print2dollar(txt, pos)) return false;
  if (!print_int(prm2)) return false;
  if (!print2dollar(txt, pos)) return false;
  if (!print_nts(prm3)) return false;
  if (!print2end(txt, pos)) return false;
  return true;
}

/* --- printf(NTS) --- */

bool Out::printf(const char *txt, const char *prm) {
  int pos=0;
  if (!print2dollar(txt, pos)) return false;
  if (!print_nts(prm)) return false;
  if (!print2end(txt, pos)) return false;
  return true;
}

/* --- printf(Card64, Card64, NTS) --- */

bool Out::printf(const char *txt, const Card64 &prm1, const Card64 &prm2, const char *prm3) {
  int pos=0;
  char buff[N_DIGIT4CARD64+1];

  if (!print2dollar(txt, pos)) return false;
  if (!print_nts(to_nts(prm1, buff, sizeof(buff)))) return false;
  if (!print2dollar(txt, pos)) return false;
  if (!print_nts(to_nts(prm2, buff, sizeof(buff)))) return false;
  if (!print2dollar(txt, pos)) return false;
  if (!print_nts(prm3)) return false;
  if (!print2end(txt, pos)) return false;
  return true;
}

/* --- printf(Int64) --- */

bool Out::printf(const char *txt, const Int64 &prm) {
  int pos=0;
  char buff[N_DIGIT4INT64+1];

  if (!print2dollar(txt, pos)) return false;
  if (!print_nts(to_nts(prm, buff, sizeof(buff)))) return false;
  if (!print2end(txt, pos)) return false;
  return true;
}

/* --- printf(Str, Str, Str) --- */

bool Out::printf(const char *txt, Str prm1, Str prm2, Str prm3) {
  int pos=0;
  if (!print2dollar(txt, pos)) return false;
  if (!print(prm1)) return false;
  if (!print2dollar(txt, pos)) return false;
  if (!print(prm2)) return false;
  if (!print2dollar(txt, pos)) return false;
  if (!print(prm3)) return false;
  if (!print2end(txt, pos)) return false;
  return true;
}

/* --- printf(Str, Str, Str, int) --- */

bool Out::printf(const char *txt, Str prm1, Str prm2, Str prm3, int prm4) {
  int pos=0;
  if (!print2dollar(txt, pos)) return false;
  if (!print(prm1)) return false;
  if (!print2dollar(txt, pos)) return false;
  if (!print(prm2)) return false;
  if (!print2dollar(txt, pos)) return false;
  if (!print(prm3)) return false;
  if (!print2dollar(txt, pos)) return false;
  if (!print_int(prm4)) return false;
  if (!print2end(txt, pos)) return false;
  return true;
}

/* --- printf(Str, Str, int) --- */

bool Out::printf(const char *txt, Str prm1, Str prm2, int prm3) {
  int pos=0;
  if (!print2dollar(txt, pos)) return false;
  if (!print(prm1)) return false;
  if (!print2dollar(txt, pos)) return false;
  if (!print(prm2)) return false;
  if (!print2dollar(txt, pos)) return false;
  if (!print_int(prm3)) return false;
  if (!print2end(txt, pos)) return false;
  return true;
}

/* --- printf(Str, Str, Str, int) --- */

bool Out::printf(const char *txt, Str prm1, Str prm2, Str prm3, Str prm4, int prm5) {
  int pos=0;
  if (!print2dollar(txt, pos)) return false;
  if (!print(prm1)) return false;
  if (!print2dollar(txt, pos)) return false;
  if (!print(prm2)) return false;
  if (!print2dollar(txt, pos)) return false;
  if (!print(prm3)) return false;
  if (!print2dollar(txt, pos)) return false;
  if (!print(prm4)) return false;
  if (!print2dollar(txt, pos)) return false;
  if (!print_int(prm5)) return false;
  if (!print2end(txt, pos)) return false;
  return true;
}

/* --- printf(Str, Str, Str, Str) --- */

bool Out::printf(const char *txt, Str prm1, Str prm2, Str prm3, Str prm4) {
  int pos=0;
  if (!print2dollar(txt, pos)) return false;
  if (!print(prm1)) return false;
  if (!print2dollar(txt, pos)) return false;
  if (!print(prm2)) return false;
  if (!print2dollar(txt, pos)) return false;
  if (!print(prm3)) return false;
  if (!print2dollar(txt, pos)) return false;
  if (!print(prm4)) return false;
  if (!print2end(txt, pos)) return false;
  return true;
}

/* --- printf(Str, Str) --- */

bool Out::printf(const char *txt, Str prm1, Str prm2) {
  int pos=0;
  if (!print2dollar(txt, pos)) return false;
  if (!print(prm1)) return false;
  if (!print2dollar(txt, pos)) return false;
  if (!print(prm2)) return false;
  if (!print2end(txt, pos)) return false;
  return true;
}

/* --- printf(Str, int) --- */

bool Out::printf(const char *txt, Str prm1, int prm2) {
  int pos=0;
  if (!print2dollar(txt, pos)) return false;
  if (!print(prm1)) return false;
  if (!print2dollar(txt, pos)) return false;
  if (!print_int(prm2)) return false;
  if (!print2end(txt, pos)) return false;
  return true;
}


/* --- printf(Str) --- */

bool Out::printf(const char *txt, Str prm) {
  int pos=0;
  if (!print2dollar(txt, pos)) return false;
  if (!print(prm)) return false;
  if (!print2end(txt, pos)) return false;
  return true;
}

/* --- printf(int) --- */

bool Out::printf(const char *txt, int prm) {
  int pos=0;
  if (!print2dollar(txt, pos)) return false;
  if (!print_int(prm)) return false;
  if (!print2end(txt, pos)) return false;
  return true;
}

/* --- printf(int, char, int) --- */

bool Out::printf(const char *txt, int prm1, char prm2, int prm3) {
  int pos=0;
  if (!print2dollar(txt, pos)) return false;
  if (!print_int(prm1)) return false;
  if (!print2dollar(txt, pos)) return false;
  if (!print_char(prm2)) return false;
  if (!print2dollar(txt, pos)) return false;
  if (!print_int(prm3)) return false;
  if (!print2end(txt, pos)) return false;
  return true;
}

/* --- printf(int, int) --- */

bool Out::printf(const char *txt, int prm1, int prm2) {
  int pos=0;
  if (!print2dollar(txt, pos)) return false;
  if (!print_int(prm1)) return false;
  if (!print2dollar(txt, pos)) return false;
  if (!print_int(prm2)) return false;
  if (!print2end(txt, pos)) return false;
  return true;
}

/* --- printf(Str, Card64) --- */

bool Out::printf(const char *txt, Str prm1, const Card64 &prm2) {
  int pos=0;
  char buff[N_DIGIT4CARD64+1];

  if (!print2dollar(txt, pos)) return false;
  if (!print(prm1)) return false;
  if (!print2dollar(txt, pos)) return false;
  if (!print_nts(to_nts(prm2, buff, sizeof(buff)))) return false;
  if (!print2end(txt, pos)) return false;
  return true;
}

/* --- printf(int,int,int,int,int) --- */

bool Out::printf(const char *txt, int prm1, int prm2, int prm3, int prm4, int prm5) {
  int pos=0;
  if (!print2dollar(txt, pos)) return false;
  if (!print_int(prm1)) return false;
  if (!print2dollar(txt, pos)) return false;
  if (!print_int(prm2)) return false;
  if (!print2dollar(txt, pos)) return false;
  if (!print_int(prm3)) return false;
  if (!print2dollar(txt, pos)) return false;
  if (!print_int(prm4)) return false;
  if (!print2dollar(txt, pos)) return false;
  if (!print_int(prm5)) return false;
  if (!print2end(txt, pos)) return false;
  return true;
}

/* --- printf(int,int,int,int) --- */

bool Out::printf(const char *txt, int prm1, int prm2, int prm3, int prm4) {
  int pos=0;
  if (!print2dollar(txt, pos)) return false;
  if (!print_int(prm1)) return false;
  if (!print2dollar(txt, pos)) return false;
  if (!print_int(prm2)) return false;
  if (!print2dollar(txt, pos)) return false;
  if (!print_int(prm3)) return false;
  if (!print2dollar(txt, pos)) return false;
  if (!print_int(prm4)) return false;
  if (!print2end(txt, pos)) return false;
  return true;
}

/* --- print_eoln -- */

bool Out::print_eoln() {
  return print_char('\n');
}

/* --- print(Str) --- */

bool Out::print(Str s) {
  int l=s.get_l(), i;

  for (i=0; i<l; ++i) {
    if (!print_char(s.get(i))) return false;
  }
  return true;
}

/* --- printf(void) --- */

bool Out::printf(const char *txt) {
  int pos=0;
  if (!print2end(txt, pos)) return false;
  return true;
}

/* --- print2end --- */

bool Out::print2end(const char *txt, int &pos) {
  FKT "Out::print2end";

  char c;

  while (true) {
    c=txt[pos];
    if (c=='\0') break;
    if (c=='$') errstop(fkt, "Unerwartetes Formatkennzeichen");
    if (!print_char(c)) return err_write();
    ++pos;
  }

  return true;
}

/* --- print_uint --- */

bool Out::print_uint(unsigned int n) {
  if (n>=10U && !print_uint(n/10U)) return false;
  if (!print_char(char((unsigned int)'0' + n%10U))) return false;
  return true;
}

/* --- print_int --- */

bool Out::print_int(int n) {
  if (n<0) {
    if (!print_char('-')) return false;
    if (!print_uint((unsigned int)(-n))) return false;
  } else {
    if (!print_uint((unsigned int)n)) return false;
  }
  return true;
}

/* --- print_nts --- */

bool Out::print_nts(const char *txt) {
  while (*txt) {
    if (!print_char(*txt)) return false;
    ++txt;
  }
  return true;
}

/* --- print2dollar --- */

bool Out::print2dollar(const char *txt, int &pos) {
  FKT "Out::print2dollar";
  char c;

  while (true) {
    c=txt[pos];
    ++pos;
    if (c=='\0') errstop(fkt, "Unerwartetes Ende des Formatstrings");
    if (c=='$') break;
    if (!print_char(c)) return false;
  }

  return true;
}


/* === Stdout ============================================================ */

/* --- static fields --- */

Stdout Stdout::instance;

/* --- print_char --- */

bool Stdout::print_char(char c) {
  return putchar(c)>=0;
}

/* --- err_write --- */

bool Stdout::err_write() {
  return err("Fehler beim Schreiben in die Standardausgabe.");
}


/* === Out4File ========================================================== */

/* --- print_char --- */

bool Out4File::print_char(char c) {
  FKT "Out4File::print_char";
  if (f==0) errstop(fkt, "not opened");
  if (c=='\n') {
    return putc('\r', f)>=0 && putc('\n',f)>=0;
  } else {
    return putc(c,f)>=0;
  }
}

/* --- constructor --- */

Out4File::Out4File() : f(0) {}

/* --- destructor --- */

Out4File::~Out4File() {
  if (f!=0) close();
}

/* --- open --- */

bool Out4File::open(Str p_path) {
  FKT "Out4File::open";
  if (f!=0) errstop(fkt, "Bereits geoeffnet");
  if (!open_file(p_path, "wb", f)) return err(Str("Cannot open file ") + enquote(p_path) + Str(" for write"));
  path=p_path;
  return true;
}

/* --- err_write --- */

bool Out4File::err_write() {
  FKT "Out4File::err_write";

  if (f==0) errstop(fkt, "Nicht geoeffnet");

  printf("Error on writing to file ");
  enquote(path).print(stdout);
  putchar('.');

  return false;
}

/* --- close --- */

bool Out4File::close() {
  if (f==0) return true;
  fclose(f);
  f=0;
  return true;
}





////////////////
// FILE str.h //
////////////////

// From c:\consql



////////////////////
// FILE const.cpp //
////////////////////

/* --- exported fields --- */

const Str 
  c_end_filename_result(").dat"     ),
  c_nlinkmax           ("nlinkmax"  ),
  c_n_eq               ("n="        ),
  c_ntodo_eq           ("ntodo="    ),
  c_ndone_eq           ("ndone="    ),
  c_block              ("block"     ),
  c_end_filename_work  (")_work.dat");