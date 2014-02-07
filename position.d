import std.stdio, std.string, std.array, std.math, std.conv;
import core.bitop;
import move;
import bitboard;
import squares;
import square;
import flips;
import rays;

class Position {
    enum white = 0;
    enum black = 1;
    Move move_list[128][64];
    int num_moves[64];
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
    
    this() {
        for (int i=0; i<64; i++) {
            num_moves[i] = 0;
            for (int j=0; j<128; j++)
                move_list[j][i] = new Move();
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
    }
    
    void dropStone(int side, string sq_name) {
        int sq_num = 0;
        int i,j;
        ulong one = 1;
  
        i = (sq_name[0] - 'a') * 8;
        j = (sq_name[1] - '1');
        sq_num = i + j;

        if (side == black)
            black_stones = set(black_stones,(one<<sq_num));
        else
            white_stones = set(white_stones,(one<<sq_num));
    }

    void startBoard() {
        dropStone(black,"d4");
        dropStone(black,"e5");
        dropStone(white,"d5");
        dropStone(white,"e4");
    }
    
    void makeMove(Move move) {
        ulong stones_to_change;
  
        stones_to_change = (move.mask | move.flips);
        if (side_to_move == black) {
            black_stones |= stones_to_change;
            white_stones ^= move.flips;
        }
        else {
            white_stones |= stones_to_change;
            black_stones ^= move.flips;
        }
        side_to_move ^= 1;
        position_index += 1;
    }

    void unmakeMove(Move move) {
        ulong stones_to_change;
  
        stones_to_change = (move.mask | move.flips);
        if (side_to_move == black) {
            black_stones |= move.flips;
            white_stones ^= stones_to_change;
        }
        else {
            white_stones |= move.flips;
            black_stones ^= stones_to_change;
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
                move_index += 1;
            }
        }
        num_moves[position_index] = move_index;
        sortMoves();
    }
    
    void generateMoves() {
        ulong gen = 0;
        ulong one = 1;
        ulong m;
        ulong some_flips;
        int s = 0;
        int move_index = 0;
        ulong astones, tstones;
        
        num_moves[position_index] = 0;
        if (side_to_move == black) { 
            astones = black_stones;
            tstones = white_stones;
        }    
        else {
	    astones = white_stones;
	    tstones = black_stones;
	}
        gen = s_test.genAdjMask(tstones);
        gen ^= astones;
        while (gen) {
            s = bsf(gen);
            m = (one << s);
            gen &= (gen - 1);
            some_flips = getFlips(m, astones, tstones);
            if (some_flips){
//                move_list[position_index][move_index].sq_num = s;
//                move_list[position_index][move_index].sq_name = sqs.square_list[s].sq_name;
                move_list[position_index][move_index].mask = m;
                move_list[position_index][move_index].flips = some_flips;
                move_index += 1;
            }
        }
        num_moves[position_index] = move_index;
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
//        for (int m=0; m<num_moves[position_index]; m++)
//            move_list[position_index][m].printMove();
        writeln();
    }       
 
    void printPosition() {
        writeln("POSITION");
        writeln("\nposition index = ", position_index);
        writeln("legal moves = ", num_moves[position_index]);
        if (side_to_move == black) 
            writeln("Black to move");
        else
            writeln("White to move");
        writeln("Black Stones");
        DisplayBitBoard(black_stones);
        writeln("White Stones");
        DisplayBitBoard(white_stones);
        writeln();
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
//        DisplayBitBoard(black_stones); 
        black_pot_count = PopCnt(potential);
//        writeln("black pop count = ",black_pot_count);
        potential = s_test.genAdjMask(black_stones);
        potential ^= white_stones;
        white_pot_count = PopCnt(potential);
        
//        writeln("bpc - wpc = ",(black_pot_count - white_pot_count));
//        writeln("bpc + wpc = ",(black_pot_count + white_pot_count));
//        writeln("value => ",((black_pot_count - white_pot_count)/(black_pot_count + white_pot_count)));
        value = (black_pot_count - white_pot_count)/(black_pot_count + white_pot_count);
        value = value * pot_modifier;
//        writeln("pot value = ",value);
        score += lround(value); 
        
//        black_stone_count = PopCnt(black_stones);
//        white_stone_count = PopCnt(white_stones);
//        value = (black_stone_count - white_stone_count)/(black_stone_count + white_stone_count);
//        value = value * mat_modifier;
//        score += lround(value);
        

        if (ctm == white) { 
            score = -score;
        }   
//        writeln("evaluated score = ",score);
        return score;
    }

    int eog_evaluate(int ctm) {
        float black_pot_count;
        float white_pot_count;
        float black_stone_count;
        float white_stone_count;
        int pot_modifier = 0;
        int mat_modifier = 64;
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
        
        black_stone_count = PopCnt(black_stones);
        white_stone_count = PopCnt(white_stones);
        value = (black_stone_count - white_stone_count)/(black_stone_count + white_stone_count);
        value = value * mat_modifier;
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