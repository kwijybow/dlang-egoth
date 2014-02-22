import std.stdio, std.string, std.array, std.datetime, std.conv, std.math, std.algorithm;
import position;
import move;
import squares;
import square;
import rays;
import hash;
import bitboard;
import masks;

struct PVline {
    int cmove;
    int argmove[64];
}

class Tree {
    Position pos;
    ulong leaves_searched;
    ulong nodes_searched;
    StopWatch timer;
    double runtime;
    enum neginf = -64;
    enum posinf = 64;
    enum badsquare = 64;
    enum passmove = 99;
    bool eog;
    int  ctm;
    int expected_move;
    int best_move;
    int maxdepth;
    PVline pv;
    
    this(Position search_position) {
        pos = new Position;
        for (int i=0; i<64; i++) {
            pos.num_moves[i] = search_position.num_moves[i];
            pv.argmove[i] = badsquare;
            for (int j=0; j<128; j++)
                pos.move_list[j][i] = search_position.move_list[j][i];
        }
        for (int i=0; i<128; i++) {
            pos.killer1[i] = 64;
            pos.killer2[i] = 64;
            pos.hashmove[i] = 64;
        }
        pos.position_index = search_position.position_index;
        pos.passed = search_position.passed;
        pos.black_stones = search_position.black_stones;
        pos.white_stones = search_position.white_stones;
        pos.side_to_move = search_position.side_to_move;
        ctm = search_position.side_to_move;
        pos.sqs = new Squares();
        pos.s_test = new Square();
        pos.ray_list = new Rays();
        pos.mask_test = new Masks();
        pos.hashkey = search_position.hashkey;
        eog = false;
        leaves_searched = 0;
        nodes_searched = 0;
        runtime = 0.0;
        expected_move = 64;
        best_move = passmove;
        maxdepth = PopCnt(~(pos.black_stones | pos.white_stones));
        pv.cmove = 0;
    }
}

int searchRoot(ref Tree t) {
    int score;
    int bound;
    
    /* look for the exact best score */
    /* start to look for a win or a draw or a loss */
    score = Scout(t, -1, +1);
    if (score > 0) {
        /* if a win look for a score between [+2 +8] */
	bound = score + 8;
	score = Scout(t, score, bound);
	if (score >= bound) {
	    /* failed -> look for a score between [+8, +64] */
	    score = Scout(t, score, 64);
	}
    } else if (score < 0) {
        /* if a loss look for a score between [-8 -2] */
	bound = score - 8;
	score = Scout(t, bound, score);
	if (score <= bound) {
	    /* failed -> look for a score between [-64, -8] */
	    score = Scout(t, -64, score);
	}
    }
    return score;
}

int Scout (ref Tree t, int alpha, int beta)
{
     int i;
     int b = t.neginf;
     int s = t.neginf;
     int test;
     int orig_alpha=alpha;
     int num_moves;
     int last_legal_count = 1;
     int best_move = t.passmove;
     
     
     switch (hashProbe(t.pos,t.pos.side_to_move,alpha,beta,t.pos.position_index,(t.maxdepth - t.pos.position_index),t.best_move)) {
         case t.pos.exact:
//             t.pos.hashmove[t.pos.position_index] = t.best_move;
             return(alpha);
         case t.pos.lower:
             return(beta);
         case t.pos.upper:
             return(alpha);
         default:
             break;
     }     
   
     t.nodes_searched++;
     t.pos.generateRayMoves();
     if (t.pos.num_moves[t.pos.position_index] == 0) {
        if (t.pos.position_index > 0) 
            last_legal_count = t.pos.num_moves[t.pos.position_index - 1];
        else
            last_legal_count = 1;
        if (last_legal_count == 0) {
           b = t.pos.eog_evaluate(t.pos.side_to_move);
           t.pos.move_list[t.pos.position_index][0].sq_num = t.passmove;
           t.pos.move_list[t.pos.position_index][0].score = b;
           t.best_move = t.passmove;
           t.leaves_searched++;
           hashStore(t.pos,t.pos.side_to_move,t.pos.exact,b,t.pos.position_index,(t.maxdepth - t.pos.position_index),t.best_move);
           return b;
        } else {
           t.pos.makePass();
           b = -Scout(t, -beta, -alpha);
           t.pos.unmakePass();
           t.pos.move_list[t.pos.position_index][0].score = b;
           t.best_move = t.passmove;
           return b;
        }
     }
     t.pos.makeMove(t.pos.move_list[t.pos.position_index][0]);
     b = -Scout(t,-beta,-alpha);
     t.pos.unmakeMove(t.pos.move_list[t.pos.position_index-1][0]);
     t.pos.move_list[t.pos.position_index][0].score = b;
     t.best_move = t.pos.move_list[t.pos.position_index][0].sq_num;
     if (b > alpha) {
         alpha = b;
         if (b >= beta) {
             t.pos.killer4[t.pos.position_index] = t.pos.killer3[t.pos.position_index];
             t.pos.killer3[t.pos.position_index] = t.pos.killer2[t.pos.position_index];
             t.pos.killer2[t.pos.position_index] = t.pos.killer1[t.pos.position_index];
             t.pos.killer1[t.pos.position_index] = t.pos.move_list[t.pos.position_index][0].sq_num;
             hashStore(t.pos,t.pos.side_to_move,t.pos.lower,b,t.pos.position_index,(t.maxdepth - t.pos.position_index),t.pos.move_list[t.pos.position_index][0].sq_num);
             return b;
         }
     }
     i=1;
     while (i<t.pos.num_moves[t.pos.position_index]) {
         t.pos.makeMove(t.pos.move_list[t.pos.position_index][i]);
         test = -Scout(t, -alpha-1, -alpha);
         if ((test > alpha) && (test < beta))
             s = -Scout(t, -beta, -test);
         t.pos.unmakeMove(t.pos.move_list[t.pos.position_index-1][i]);
         s = max(s, test);
         b = max(s, b);
         t.pos.move_list[t.pos.position_index][i].score = b;
         t.best_move = t.pos.move_list[t.pos.position_index][i].sq_num;
         if (b > alpha) {
             alpha = b;
             if (b >= beta) {
                 t.pos.killer4[t.pos.position_index] = t.pos.killer3[t.pos.position_index];
                 t.pos.killer3[t.pos.position_index] = t.pos.killer2[t.pos.position_index];             
                 t.pos.killer2[t.pos.position_index] = t.pos.killer1[t.pos.position_index];
                 t.pos.killer1[t.pos.position_index] = t.pos.move_list[t.pos.position_index][i].sq_num;
                 hashStore(t.pos,t.pos.side_to_move,t.pos.lower,b,t.pos.position_index,(t.maxdepth - t.pos.position_index),t.pos.move_list[t.pos.position_index][i].sq_num);
                 return b;
             }
         }
         i++;
     }
     if (alpha == orig_alpha) 
         hashStore(t.pos,t.pos.side_to_move,t.pos.upper,b,t.pos.position_index,(t.maxdepth - t.pos.position_index),t.best_move);
     else {
         hashStore(t.pos,t.pos.side_to_move,t.pos.exact,b,t.pos.position_index,(t.maxdepth - t.pos.position_index),t.best_move);
         t.pos.hashmove[t.pos.position_index] = t.best_move;
     }
     return b;
}


int MTDf(ref Tree t, int f)
{
    int g=f;
    int lower_bound=t.neginf;
    int upper_bound=t.posinf;
    int beta;
    

    do {
        if (g==lower_bound)
            beta=g+1;
        else
            beta=g;
        g=Scout(t,beta-1,beta);
        if (g<beta) 
            upper_bound=g;
        else 
            lower_bound=g;
    } while (!(lower_bound>=upper_bound));
    return g;
}
