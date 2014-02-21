import std.string, std.stdio;
import bitboard;


class Masks {
    ulong edge;
    ulong corner;
    ulong xsquare;
    ulong xsquare2;
    ulong quiesce;
    ulong allones;
    ulong b = 1;
    int row, col;
        
    this() {
      corner = 0;
      xsquare = 0;
      xsquare2 = 0;
      quiesce = 0;
      edge = 0;
      allones = 0;
      for (int i=0; i<64; i++) {
          allones |= (b << i);
          row = i/8;
          col = i%8;
          if (i==0 || i==7 || i==56 || i==63)
               corner |= (b<<i);
          if (i== 1 || i== 6 || i== 8 || i== 9 || i==14 || i==15 ||
              i==48 || i==49 || i==54 || i==55 || i==57 || i==62)
               xsquare |= (b<<i);
          if (row == 0 || row == 7 || col == 0 || col == 7)
               edge |= (b<<i);
      }

      quiesce = (xsquare & corner & edge);
      xsquare2 = xsquare ^ edge;
    
    }

}