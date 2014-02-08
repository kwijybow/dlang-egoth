import std.stdio, std.string, std.array, std.datetime, std.conv;


struct hash_entry {
  ulong word1;
  ulong word2;
};

static uint hash_table_size = 65535;
static hash_entry trans_ref_wa[65536];
static hash_entry trans_ref_ba[65536];
static ulong w_stone_random[64];
static ulong b_stone_random[64];
byte transposition_id;


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
  int i;
  transposition_id=0;
  for (i=0;i<hash_table_size;i++)
    trans_ref_wa[i].word1 = to!ulong(32)<<34;
    trans_ref_wa[i].word1 |= to!ulong(7)<<61;
    trans_ref_wa[i].word2 = 0;
    trans_ref_ba[i].word1 = to!ulong(32)<<34;
    trans_ref_ba[i].word1 |= to!ulong(7)<<61;
    trans_ref_ba[i].word2 = 0;
}

/*
void HashStore (game_position *sp, int ctm, int type, float value, int ply, int depth, int move)
{
    register HASH_ENTRY *htablea;
    register BITBOARD word1, word2;
    register int draft, age, word1l, word1r;

    word1l = ((int) transposition_id<<29);
    word1l |= move<<16;
    word1l |= (((depth<<2)+type)&65535);
    word1r=value;
    word1=value + ((BITBOARD) word1l<<32);
    word2=sp->hashkey;

    htablea=((ctm) ? trans_ref_wa:trans_ref_ba)+(((int) sp->hashkey) & hash_maska);
    draft=((int) (htablea->word1>>34));
    age=htablea->word1>>61;
    age=age && (age!=transposition_id);
    if (age || (depth>=draft)) {
        htablea->word1 = word1;
        htablea->word2 = word2;
    }
}

int HashProbe (game_position *sp, int ctm, float *alpha, float *beta, int ply, int depth, int *move)
{
    register BITBOARD word1, word2;
    register HASH_ENTRY *htable;
    register int type, draft, word1l, word1r;
    register float val;

    htable=((ctm)?trans_ref_wa:trans_ref_ba)+(((int) sp->hashkey) & hash_maska);
        word1 = htable->word1;
        word2 = htable->word2;

    if (word2 == sp->hashkey) {
        word1l = word1>>32;
        word1r = word1 & all_ones;
        val = word1r;
        *move = (word1l>>16)&255;
        draft = (word1l&65535)>>2;
        type = (word1l) & 03;
        if (depth>draft) return(WORTHLESS);
       

        switch (type) {
        case EXACT:
            *alpha=val;
            return(EXACT);
        case UPPER:
            if (val <= *alpha) {
               *alpha=val;
               return(UPPER);
            }
            return(WORTHLESS);
        case LOWER:
            if (val >= *beta) {
                *beta=val;
                return(LOWER);
            }
            return(WORTHLESS);
        }
    }
    return(WORTHLESS);
}
*/     
