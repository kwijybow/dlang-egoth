import std.stdio, std.string, std.array, std.datetime, std.conv;
import position;
import bitboard;


struct hash_entry {
  ulong word1;
  ulong word2;
  ulong word3;
  ulong word4;
  
  this (ulong word) {
      word1 = word;
      word2 = 0;
      word3 = 0;
      word4 = 0;
  }
};

static uint hash_table_size = 524288;
hash_entry[] trans_ref_wa;
hash_entry[] trans_ref_ba;
static ulong w_stone_random[64];
static ulong b_stone_random[64];
static byte transposition_id;
static int hash_maska;
static int log_hash = 19;
static ulong allOnes = 18446744073709551615UL;
static uint allones = 4294967295;


/*

A 32 bit random number generator. An implementation in C of the algorithm given by
Knuth, the art of computer programming, vol. 2, pp. 26-27. We use e=32, so
we have to evaluate y(n) = y(n - 24) + y(n - 55) mod 2^32, which is implicitly
done by unsigned arithmetic.

*/

ulong Random32()
{
  /*
  random numbers from Mathematica 2.0.
  SeedRandom = 1;
  Table[Random[Integer, {0, 2^32 - 1}]
  */
  static ulong x[55] = [
    1410651636UL, 3012776752UL, 3497475623UL, 2892145026UL, 1571949714UL,
    3253082284UL, 3489895018UL, 387949491UL, 2597396737UL, 1981903553UL,
    3160251843UL, 129444464UL, 1851443344UL, 4156445905UL, 224604922UL,
    1455067070UL, 3953493484UL, 1460937157UL, 2528362617UL, 317430674UL,
    3229354360UL, 117491133UL, 832845075UL, 1961600170UL, 1321557429UL,
    747750121UL, 545747446UL, 810476036UL, 503334515UL, 4088144633UL,
    2824216555UL, 3738252341UL, 3493754131UL, 3672533954UL, 29494241UL,
    1180928407UL, 4213624418UL, 33062851UL, 3221315737UL, 1145213552UL,
    2957984897UL, 4078668503UL, 2262661702UL, 65478801UL, 2527208841UL,
    1960622036UL, 315685891UL, 1196037864UL, 804614524UL, 1421733266UL,
    2017105031UL, 3882325900UL, 810735053UL, 384606609UL, 2393861397UL ];
  static int init = 1;
  static ulong y[55];
  static int j, k;
  ulong ul;

  if (init)
  {
    int i;

    init = 0;
    for (i = 0; i < 55; i++) y[i] = x[i];
    j = 24 - 1;
    k = 55 - 1;
  }

  ul = (y[k] += y[j]);
  if (--j < 0) j = 55 - 1;
  if (--k < 0) k = 55 - 1;

  return (ul);
}

ulong Random64()
{
  ulong result;
  ulong r1, r2;

  r1=Random32();
  r2=Random32();
  result = r2 << 32;
  result = result | r1;
  return (result);
}

void InitializeRandomHash()
{
  int i;
  for (i=0;i<64;i++) {
    w_stone_random[i]=Random64();
    b_stone_random[i]=Random64();
  }
}

void InitializeHashTables()
{
  int i, next;
  ulong word1 = 0;
  
  word1 = to!ulong(32)<<34;
  word1 |= to!ulong(7)<<61;
  transposition_id=0;
  trans_ref_ba.length = hash_table_size;
  trans_ref_wa.length = hash_table_size;
  for (i=0;i<hash_table_size;i++) {
    trans_ref_wa[i] = hash_entry(word1);
    trans_ref_ba[i] = hash_entry(word1);
  }
}


void hashStore (ref Position sp, int ctm, int type, int value, int ply, int depth, int move)
{
    ulong word1, word2, index;
    uint draft, age, word1l, word1r;
    
    
    word1l = ((to!int(transposition_id))<<29);
    word1l |= move<<16;
    word1l |= (((depth<<2)+type)&65535);
    word1r=value;
    word1=((to!ulong(word1l))<<32) | (word1r);
    word2=sp.hashkey;
    index = sp.hashkey & hash_maska;
//    writeln(index);
    if (ctm == 1) {
//        draft = trans_ref_ba[index].word1>>34;
//        age = trans_ref_ba[index].word1>>61;
//        age=age && (age!=transposition_id);
//        if (age || (depth>=draft)) {
//            writeln("got here");
            trans_ref_ba[index].word1 = word1;
            trans_ref_ba[index].word2 = word2;
            trans_ref_ba[index].word3 = sp.black_stones;
            trans_ref_ba[index].word4 = sp.white_stones;
//        }
    }
    else {
//        draft = trans_ref_wa[index].word1>>34;
//        age = trans_ref_wa[index].word1>>61;
//        age=age && (age!=transposition_id);
//        if (age || (depth>=draft)) {
//            writeln("got here");
            trans_ref_wa[index].word1 = word1;
            trans_ref_wa[index].word2 = word2;
            trans_ref_wa[index].word3 = sp.black_stones;
            trans_ref_wa[index].word4 = sp.white_stones;
//        }
    }
//    writeln("storing move,value,type,ply,depth,index ",move,",", value,",",type,",",ply,",",depth,",",index);
//    writeln("word1",word1);
}

int hashProbe (ref Position sp, int ctm, ref int alpha, ref int beta, int ply, int depth, ref int move)
{
    ulong word1, word2, word3, word4, index;
    uint type, draft, word1l, word1r;
    int val;
    

    index = sp.hashkey & hash_maska;
    if (ctm == 1) {
        word1 = trans_ref_ba[index].word1;
        word2 = trans_ref_ba[index].word2;
        word3 = trans_ref_ba[index].word3;
        word4 = trans_ref_ba[index].word4;
    } 
    else {
        word1 = trans_ref_wa[index].word1;
        word2 = trans_ref_wa[index].word2;
        word3 = trans_ref_wa[index].word3;
        word4 = trans_ref_wa[index].word4;
    }    
    if (word2 == sp.hashkey) {
      if ((sp.black_stones == word3) && (sp.white_stones == word4)) {
//        DisplayBitBoard(word1);
//        writeln;
        word1l = word1>>32;
//        DisplayBitBoard(to!ulong(word1l));
//        writeln;
//        DisplayBitBoard(word1);
//        writeln;
        word1r = word1 & allones;
//        DisplayBitBoard(to!ulong(word1r));
//        writeln;
        val = word1r;
        move = (word1l>>16)&255;
//        DisplayBitBoard(to!ulong(move));
//        writeln;
//        draft = (word1l&65535)>>2;
        type = (word1l) & 03;
//        writeln("retrieving move,value,type,ply,depth,draft,index ",move,",", val,",",type,",",ply,",",depth,",",draft,",",index);
//        writeln("word1 ",word1);
        
//        if (depth>draft) return(sp.worthless);

        switch (type) {
        case sp.exact:
            alpha=val;
            return(sp.exact);
        case sp.upper:
            if (val <= alpha) {
               alpha=val;
               return(sp.upper);
            }
            return(sp.worthless);
        case sp.lower:
            if (val >= beta) {
                beta=val;
                return(sp.lower);
            }
            return(sp.worthless);
        default:
            break;
        }

      }  
    }
    return(sp.worthless);
}
    
