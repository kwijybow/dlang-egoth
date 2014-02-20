import std.string, std.stdio;
import bitboard;


class Square {
        int sq_num;
        string sq_name;
        ulong mask;
        ulong adj_mask;
        ulong att_mask;
        int see_value;
        int stone;
        int row;
        int col;
/*        
    int see[64] = [
       120,-20,20, 5, 5,20,-20,120, 
       -20,-40,-5,-5,-5,-5,-40,-20, 
        20, -5,15, 3, 3,15, -5, 20, 
         5, -5, 3, 3, 3, 3, -5,  5, 
         5, -5, 3, 3, 3, 3, -5,  5, 
        20, -5,15, 3, 3,15, -5, 20, 
       -20,-40,-5,-5,-5,-5,-40,-20, 
       120,-20,20, 5, 5,20,-20,120  
    ];
*/
    int see[64] = [
500,   -86, 96,  26,  26, 96,   -86, 500,
-86, -1219, -6,   0,   0, -6, -1219, -86,
 96,    -6, 52,  15,  15, 52,    -6,  96,
 26,     0, 15, -17, -17, 15,     0,  26,
 26,     0, 15, -17, -17, 15,     0,  26,
 96,    -6, 52,  15,  15, 52,    -6,  96,
-86, -1219, -6,   0,   0, -6, -1219, -86,
500,   -86, 96,  26,  26, 96,   -86, 500
    ];
    
    
    
    ulong genAdjMask(ulong amask) {
        ulong orig;
        ulong notH = 0xFEFEFEFEFEFEFEFE;
        ulong notA = 0x7F7F7F7F7F7F7F7F;
        orig = amask;
        amask |= (amask << 1) & notH;
        amask |= (amask << 8);
        amask |= (amask >> 1) & notA;
        amask |= (amask >> 8);
        amask ^= orig;
        return (amask);
    }
    
    ulong getAttacks (ulong m, ulong tstones) {
            ulong flood;
            ulong gen;
            ulong pro;
  
            flood = gen = 0;
            gen = m;
            pro = tstones & 0xfefefefefefefe00;
            while (gen) { 
                flood |= gen;
                gen = ((gen << 9) & pro);
            };
            
            gen = m;
            pro = tstones & 0xfefefefefefefefe;
            while (gen) {
                flood |= gen;
                gen = ((gen << 1) & pro);
            };
                        
            gen = m;
            pro = tstones & 0x00fefefefefefefe;
            while (gen) {
                flood |= gen;
                gen = ((gen >> 7) & pro);
            };

            gen = m;
            pro = tstones & 0x00ffffffffffffff;
            while (gen) {
                flood |= gen;
                gen = ((gen >> 8) & pro);
            };
            
            gen = m;
            pro = tstones & 0x007f7f7f7f7f7f7f;
            while (gen) {
                flood |= gen;
                gen = ((gen >> 9) & pro);
            };

            gen = m;
            pro = tstones & 0x7f7f7f7f7f7f7f7f;
            while (gen)  {
                flood |= gen;
                gen = ((gen >> 1) & pro);
            };

            gen = m;
            pro = tstones & 0x7f7f7f7f7f7f7f00;
            while (gen) {
                flood |= gen;
                gen = ((gen << 7) & pro);
            };

            gen = m;
            pro = tstones & 0xffffffffffffff00;
            while (gen) {
                flood |= gen;
                gen = ((gen << 8) & pro);
            }
            flood ^= m;
            return flood;
    }
    
    ulong genAttMask(ulong mask) {
        ulong tstones;
        
        att_mask = 0;
        tstones = ~mask;
        att_mask = getAttacks(mask, tstones);
        return att_mask;
    }
        
    this() {
        sq_num = 0;
        sq_name = "";
        mask = 0;
        adj_mask = 0;
        att_mask = 0;
        see_value = 0;
        row = 0;
        col = 0;
        stone = 0;
    }

    this(int num, string name) {
        sq_num = num;
        sq_name = name;
        mask = 1;
        mask = (mask<<num);
        adj_mask = genAdjMask(mask);
        att_mask = genAttMask(mask);
        see_value = see[num];
        row = num/8;
        col = num%8;
        stone = 0;
    }
    
    void printSquare() {
        writeln("Square");
        writeln("square as follows");
        writeln("sq_num ", sq_num, " name ", sq_name);
        writeln("row ", row, "col ", col);
        writeln("see value", see_value);
        writeln("mask");
        DisplayBitBoard(mask);
        writeln("adj_mask");
        DisplayBitBoard(adj_mask);
        writeln("att_mask");
        DisplayBitBoard(att_mask);
        writeln();
    }
}