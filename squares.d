import std.string, std.stdio, std.array;
import square;


class Squares {
    Square[uint] square_list;
    Square[string] squares_by_name;
    int sq_num = 0;
    string sq_name;

    this() {
      foreach(row; ["8","7","6","5","4","3","2","1"]) {
        foreach(col; ["a","b","c","d","e","f","g","h"]) {
            sq_name = col ~ row;
            square_list[sq_num] = new Square(sq_num,sq_name);
            squares_by_name[sq_name] = new Square(sq_num, sq_name);
            sq_num += 1;
        }
      }
    }
    
    ulong adj_mask(int s) {
        return square_list[s].adj_mask;
    }
    
    string name(int s) {
        return square_list[s].sq_name;
    }
    
    int num(int s) {
        return square_list[s].sq_num;
    }
    
    int see_value(int s) {
        return square_list[s].see_value;
    }
    
    int row(int s) {
        return square_list[s].row;
    }
    
    int col(int s) {
        return square_list[s].col;
    }
    
    int stone(int s) {
        return square_list[s].stone;
    }
    
    int stone(string name) {
        return squares_by_name[name].stone;
    }


}