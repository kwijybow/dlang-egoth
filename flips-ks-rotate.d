
ulong avoidWrap[8] = [ 0xfefefefefefefe00, 
                       0xfefefefefefefefe, 
                       0x00fefefefefefefe, 
                       0x00ffffffffffffff, 
                       0x007f7f7f7f7f7f7f, 
                       0x7f7f7f7f7f7f7f7f, 
                       0x7f7f7f7f7f7f7f00, 
                       0xffffffffffffff00 ];

int shift[8] = [ 9, 1,-7,-8,-9,-1, 7, 8 ];

ulong rotateLeft (ulong x, int s) {return (x << s) | (x >> (64-s));}

ulong generateFlips(ulong m, ulong astones, ulong pro, int dir8) {
    ulong flips = 0; 
    ulong gen = 0;
    gen |= m;
    int r = shift[dir8];
    pro &= avoidWrap[dir8];
    gen |= pro & rotateLeft(gen, r);
    pro &=       rotateLeft(pro, r);
    gen |= pro & rotateLeft(gen, 2*r);
    pro &=       rotateLeft(pro, 2*r);
    gen |= pro & rotateLeft(gen, 4*r);
    gen ^= m;
    flips = gen;
    gen = rotateLeft(gen, r) & (astones & avoidWrap[dir8]);
    if (gen == 0) 
       flips = 0;
    return flips;
}

ulong getFlips(ulong m,ulong  astones,ulong tstones) {
    ulong flips = 0;
    for (int dir8=0; dir8<8; dir8++) {
        flips |= generateFlips(m, astones, tstones, dir8);
    }
    return flips;
}