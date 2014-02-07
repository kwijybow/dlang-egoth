import std.stdio, std.string, std.array;
import core.bitop;
import move;
import bitboard;
import squares;
import square;
import flips;
import intervening;

class Position {
    enum white = 0;
    enum black = 1;
    Move move_list[128][64];
    int num_moves[64];
    int position_index;
    bool passed;
    ulong black_stones;
    ulong white_stones;
    ulong potential_moves;
    int side_to_move;
    Squares sqs;
    Square s_test = new Square();
    Intervening r; 
    
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
        r = new Intervening();
    }
    
    void genPotentialMoves() {
        ulong gen, astones, tstones;
	ulong potential = 0;
	int s = 0;
	ulong one = 1;
	
	if (side_to_move == black) {
	  tstones = white_stones;
	  astones = black_stones;
	}
	else {
	  tstones = black_stones;
	  astones = white_stones;
	}
	
        gen = tstones;
        potential = s_test.genAdjMask(gen);
        potential ^= astones;
        
/*
        while (gen) {
            s = bsf(gen); //b.LSB(gen);
            potential |= sqs.adj_mask(s);
            gen ^= (one << s);
	}
	
        potential ^= (tstones | astones);
*/
        potential_moves = potential;
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
    
    void generateMoves() {
        ulong gen = 0;
        ulong gen2 = 0;
        ulong one = 1;
        ulong m, m2;
        ulong some_flips = 0;
        int from = 0;
        int to = 0;
        int move_index = 0;
        ulong astones, tstones;

        num_moves[position_index] = 0;
        genPotentialMoves();
        gen = potential_moves;
        if (side_to_move == black) {
            astones = black_stones;
            tstones = white_stones;
        }
        else {
            astones = white_stones;
            tstones = black_stones;
        }
        while (gen) {
            from = bsf(gen);  //b.LSB(gen);
            m = (one << from);
            gen ^= m;
            gen2 = sqs.square_list[from].att_mask & astones;
            some_flips = 0;
            while (gen2) {
                to = bsf(gen2);
//                m2 = (one << to); 
//                gen2 ^= m2;
                  gen2 &= (gen2 - 1);
                  some_flips |= r.getRays(from, to, tstones);
            }
            if (some_flips){
//                move_list[position_index][move_index].sq_num = from;
//                move_list[position_index][move_index].sq_name = sqs.square_list[from].sq_name;
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
            writeln(move_list[position_index][m].sq_name, " ");;
        writeln();
        for (int m=0; m<num_moves[position_index]; m++)
            move_list[position_index][m].printMove();
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
        generateMoves();
//        printMoveList();
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
}