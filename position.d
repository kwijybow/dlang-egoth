import std.stdio, std.string, std.array, std.math, std.conv;
import core.bitop;
import move;
import bitboard;
import squares;
import square;
import flips;
import rays;
import hash;
import masks;

class Position {
    enum white = 0;
    enum black = 1;
    Move move_list[128][64];
    int num_moves[128];
    int position_index;
    bool passed;
    ulong black_stones;
    ulong white_stones;
    int side_to_move;
    Squares sqs;
    Square s_test;
    Rays ray_list;
    ulong hashkey;
    Move spare_move;
    int killer1[128];
    int killer2[128];
    int hashmove[128];
    enum hashmove_bonus = 1024;
    enum killer1_bonus = 528;
    enum killer2_bonus = 256;
    Masks mask_test;
    
    this() {
        for (int i=0; i<64; i++) {
            num_moves[i] = 0;
            for (int j=0; j<128; j++)
                move_list[j][i] = new Move();
        }
        for (int i=0; i<128; i++) {
            killer1[i] = 64;
            killer2[i] = 64;
            hashmove[i] = 64;
        }        
        position_index = 0;
        passed = false;
        black_stones = 0;
        white_stones = 0;
        side_to_move = black;
        sqs = new Squares();
        s_test = new Square();
        ray_list = new Rays();
        hashkey = 0;
        spare_move = new Move();
        mask_test = new Masks();
    }
    
    void dropStone(int side, string sq_name) {
        int sq_num = 0;
        int i,j;
        ulong one = 1;
  
        i = (sq_name[0] - 'a') * 8;
        j = (sq_name[1] - '1');
        sq_num = i + j;

        if (side == black) {
            black_stones = set(black_stones,(one<<sq_num));
            hashkey ^= b_stone_random[sq_num];
        }
        else {
            white_stones = set(white_stones,(one<<sq_num));
            hashkey ^= w_stone_random[sq_num];
        }
    }

    void startBoard() {
        dropStone(black,"d4");
        dropStone(black,"e5");
        dropStone(white,"d5");
        dropStone(white,"e4");
    }
    
    void makeMove(Move move) {
        ulong stones_to_change;
        ulong tmpflips;
        int sq_num;
  
        stones_to_change = (move.mask | move.flips);
        if (side_to_move == black) {
            black_stones |= stones_to_change;
            white_stones ^= move.flips;
            hashkey ^= b_stone_random[move.sq_num];
            tmpflips = move.flips;
            while (tmpflips) {
                sq_num = bsf(tmpflips);
                tmpflips &= tmpflips - 1;
                hashkey ^= b_stone_random[sq_num];
                hashkey ^= w_stone_random[sq_num];
            }            
        }
        else {
            white_stones |= stones_to_change;
            black_stones ^= move.flips;
            hashkey ^= w_stone_random[move.sq_num];
            tmpflips= move.flips;
            while (tmpflips) {
                sq_num = bsf(tmpflips);
                tmpflips &= tmpflips - 1;
                hashkey ^= w_stone_random[sq_num];
                hashkey ^= b_stone_random[sq_num];
            }
        }
        side_to_move ^= 1;
        position_index += 1;
    }

    void unmakeMove(Move move) {
        ulong stones_to_change;
        ulong tmpflips;
        int sq_num;
  
        stones_to_change = (move.mask | move.flips);
        if (side_to_move == black) {
            black_stones |= move.flips;
            white_stones ^= stones_to_change;
            hashkey ^= w_stone_random[move.sq_num];
            tmpflips = move.flips;
            while (tmpflips) {
                sq_num = bsf(tmpflips);
                tmpflips &= tmpflips - 1;
                hashkey ^= w_stone_random[sq_num];
                hashkey ^= b_stone_random[sq_num];
            } 
        }
        else {
            white_stones |= move.flips;
            black_stones ^= stones_to_change;
            hashkey ^= b_stone_random[move.sq_num];
            tmpflips = move.flips;
            while (tmpflips) {
                sq_num = bsf(tmpflips);
                tmpflips &= tmpflips - 1;
                hashkey ^= b_stone_random[sq_num];
                hashkey ^= w_stone_random[sq_num];
            }
        }
        side_to_move ^= 1;
        position_index -= 1;
    }
    
    void makePass() {
        side_to_move ^= 1;
        position_index += 1;
    }  
    
    void unmakePass() {
        side_to_move ^= 1;
        position_index -= 1;
    }
    
    void generateRayMoves() {
        ulong one = 1;
        ulong some_flips;
        int fromsq = 0;
        int tosq = 0;
        int move_index = 0;
        ulong astones, tstones;
        ulong potential, completer;
        ulong a_ray, test_ray;
        
        num_moves[position_index] = 0;
        if (side_to_move == black) { 
            astones = black_stones;
            tstones = white_stones;
        }    
        else {
	    astones = white_stones;
	    tstones = black_stones;
	}
        potential = s_test.genAdjMask(tstones);
        potential ^= astones;
        while (potential) {
            some_flips = 0;
            fromsq = bsf(potential);
            potential &= (potential - 1);
            completer = sqs.square_list[fromsq].att_mask & astones;
            while (completer) {             
                tosq = bsf(completer);
                completer &= completer - 1;
                a_ray = ray_list.rays[fromsq][tosq];
                test_ray = a_ray & tstones;
                if ((a_ray ^ test_ray) == 0) {
                    some_flips |= a_ray;
                }
            }
            if (some_flips){
                move_list[position_index][move_index].sq_num = fromsq;
                move_list[position_index][move_index].sq_name = sqs.name(fromsq);
                move_list[position_index][move_index].mask = (one << fromsq);
                move_list[position_index][move_index].flips = some_flips;
                move_list[position_index][move_index].score = sqs.see_value(fromsq);
                if (fromsq == killer1[position_index])
                    move_list[position_index][move_index].score += killer1_bonus;
                else 
                    if (fromsq == killer2[position_index])
                        move_list[position_index][move_index].score += killer2_bonus;
                if (fromsq == hashmove[position_index])
                    move_list[position_index][move_index].score += hashmove_bonus;
                move_index += 1;
            }
        }
        num_moves[position_index] = move_index;
        sortMoves();
        for (int a=0; a < num_moves[position_index]; a++) {
            move_list[position_index][a].score = 0;
        }
    }
    
    
    void printMoveList() {
        writeln("MOVE LIST");
        writeln("position index = ", position_index );
        writeln("legal moves = ", num_moves[position_index]);
        if (side_to_move == black) 
            writeln("Black to move");
        else
            writeln("White to move");
        for (int m=0; m<num_moves[position_index]; m++)
            writeln(move_list[position_index][m].sq_name, " score ",move_list[position_index][m].score);
        writeln();
    }       

    void updateBoard() {
        enum e_stone = 0;
        enum l_stone = 1;
        enum b_stone = 2;
        enum w_stone = 4;
        
        ulong temp;
        
        generateRayMoves();
        
        for (int i=0; i<64; i++)
            sqs.square_list[i].stone = e_stone;

        temp = black_stones;
        while (temp) {
            sqs.square_list[bsf(temp)].stone = b_stone;
            temp &= temp - 1;
        }
        temp = white_stones;
        while (temp) {
            sqs.square_list[bsf(temp)].stone = w_stone;
            temp &= temp - 1;
        }
        for (int m=0; m<num_moves[position_index]; m++) {
            sqs.square_list[move_list[position_index][m].sq_num].stone = l_stone;
        }
        for (int i=0; i<64; i++)
            sqs.squares_by_name[sqs.square_list[i].sq_name].stone = sqs.square_list[i].stone;
    }

    void printPosition () {
        int i,j;
        enum e_stone = 0;
        enum l_stone = 1;
        enum b_stone = 2;
        enum w_stone = 4;
        string name;
        
        updateBoard();

        writefln("    a   b   c   d   e   f   g   h     ");
        writefln("  +---+---+---+---+---+---+---+---+   ");
        foreach(row; ["1","2","3","4","5","6","7","8"]) {
            writef("%s ", row);
            foreach(col; ["a","b","c","d","e","f","g","h"]) {
                name = col ~ row;
                switch (sqs.stone(name)) {
                    case e_stone:
                        write("|   ");
                        break;
                    case l_stone:
                        write("| * ");
                        break;
                    case b_stone:
                        write("| B ");
                        break;
                    case w_stone:
                        write("| W ");
                        break;
                    default:
                        break;
                    }
                }
            writefln("| %s ", row);
            writefln("  +---+---+---+---+---+---+---+---+   ");    
        }
        writefln("    a   b   c   d   e   f   g   h    ");
        writef("         ");
        if (side_to_move == black)
            write("Black");
        else
            write("White");
        writefln("'s turn to move         ");
        writef("         ");
        writefln("  white - black                ");
        writef("       ");
        writefln("  %5d - %5d                ",PopCnt(white_stones),PopCnt(black_stones));
    }


    ulong perft(int depth, bool passed) {
        int nodes = 0;
        generateRayMoves();
        if (depth == 1) {
            return (num_moves[position_index]);
        }
        if (num_moves[position_index] == 0) {
            if (passed)  
                return 0;
            makePass();
            nodes += perft((depth - 1), true);
            unmakePass();
        }  
        else {
            for (int m=0; m<num_moves[position_index]; m++) {
                makeMove(move_list[position_index][m]);
                nodes += perft((depth - 1), false);
                unmakeMove(move_list[position_index-1][m]);
            }
        }
        return nodes;
    }
    
    int eog_evaluate(int ctm) {
        int score = 0;

        score = PopCnt(black_stones) - PopCnt(white_stones);

        if (ctm == white) { 
            score = -score;
        }    
        return score;
    }
    
    int evaluate(int ctm) {
        float black_pot_count;
        float white_pot_count;
        float black_stone_count;
        float white_stone_count;
        int pot_modifier = 64; //56;
        int mat_modifier = 8;
        ulong potential;
        ulong material;
        
        float value;
        int score = 0;
        
        potential = s_test.genAdjMask(white_stones);
        potential ^= black_stones;
        black_pot_count = PopCnt(potential);
        potential = s_test.genAdjMask(black_stones);
        potential ^= white_stones;
        white_pot_count = PopCnt(potential);
        
        value = (black_pot_count - white_pot_count)/(black_pot_count + white_pot_count);
        value = value * pot_modifier;
        score += lround(value); 

        if (ctm == white) { 
            score = -score;
        }   
        return score;
    }
    
    void sortMoves() {
        int a, b;

        for (a=1; a < num_moves[position_index]; a++) {
            for (b=num_moves[position_index]- 1; b>=a; b--) {
                if (move_list[position_index][b-1].score < move_list[position_index][b].score) {
                    spare_move = move_list[position_index][b-1];
                    move_list[position_index][b-1] = move_list[position_index][b];
                    move_list[position_index][b] = spare_move;
                }
            }
        }
    }
}