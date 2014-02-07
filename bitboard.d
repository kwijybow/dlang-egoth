import std.stdio, std.string, std.array, std.conv;
import core.bitop;

void DisplayBitBoard(ulong board) {
  int i, j, x;

  for (i = 56; i >= 0; i -= 8) {
    x = (board >> i) & 255;
    for (j = 1; j < 256; j = j << 1)
      if (x & j)
        writef("X ");
      else
        writef("- ");
    writef("\n");
  }
}

ulong set(ulong bitboard, ulong mask) {
    return bitboard | mask;
}

ulong unset(ulong bitboard, ulong mask) {
    return bitboard ^ mask;
}

/*
int PopCnt(ulong a) {
  int c = 0;
  
  while (a) {
    c++;
    a &= a - 1;
  }
  return (c);
}
*/

int PopCnt(ulong a) {
    uint x,y;
    
    x = to!uint((a) & 0xffffffff);
    y = to!uint((a>>32) & 0xffffffff);
    
    return (popcnt(x) + popcnt(y));
}

/*
class Bits {
   ushort lsb[65536];
   ushort msb[65536];
   ushort i,j;
  
  this() {
      foreach (i; 0 .. 65536) {
          msb[i] = 0;
          lsb[i] = 0;
      }
      msb[0] = 64;
      lsb[0] = 16;
      foreach (i; 1 .. 65536) {
        lsb[i] = 16;
        foreach (j; 0 .. 16) {
          if (i & (1 << j)) {
            msb[i] = cast(short)j;
            if (lsb[i] == 16)
              lsb[i] = cast(short)j;
          }
        } 
      }
  }
*/
/*  
  int MSB(ulong arg1) {
    if (arg1 >> 48)
      return (msb[arg1 >> 48] + 48);
    if ((arg1 >> 32) & 65535)
      return (msb[(arg1 >> 32) & 65535] + 32);
    if ((arg1 >> 16) & 65535)
      return (msb[(arg1 >> 16) & 65535] + 16);
    return (msb[arg1 & 65535]);
  }
*/
/*  
  int LSB(ulong arg1) {
    if (arg1 & 65535)  
      return (lsb[arg1 & 65535]);
    if ((arg1 >> 16) & 65535)
      return (lsb[(arg1 >> 16) & 65535] + 16);
    if ((arg1 >> 32) & 65535)
      return (lsb[(arg1 >> 32) & 65535] + 32);
    return (lsb[arg1 >> 48] + 48);
  }
*/



int MSB(ulong arg1) {
    return (bsr(arg1));
}

int LSB(ulong arg1) {
    return (bsf(arg1));
}
//}
