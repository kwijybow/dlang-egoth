import std.stdio;
import bitboard;

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


ulong getFlips (ulong m, ulong astones, ulong tstones) {
            ulong flips;
            ulong flood;
            ulong gen;
            ulong pro;
            int r;
            
            flips = gen = 0;
            for (int dir8=0; dir8<8; dir8++) {
                flood = 0;
                gen = m;
                pro = tstones & avoidWrap[dir8];
                r = shift[dir8];
                while (gen) {
                    flood |= gen;
                    if (r > 0) 
                        gen = ((gen << r) & pro);
                    else 
                        gen = ((gen >> -r) & pro);
                }
                if (r > 0) {
		    if ((flood << r) & (astones & avoidWrap[dir8])) 
		        flips |= flood ^ m;
		}
		else {
		    if ((flood >> -r) & (astones & avoidWrap[dir8])) 
		        flips |= flood ^ m;		    
		}       
            }
            return flips;
}