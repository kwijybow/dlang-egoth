import std.stdio, std.string, std.array, std.datetime, std.conv, std.math, std.algorithm;
import position;
import move;
import squares;
import square;
import rays;
import hash;
import bitboard;
import masks;

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
    
    this(Position search_position) {
        pos = new Position;
        for (int i=0; i<64; i++) {
            pos.num_moves[i] = search_position.num_moves[i];
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
    }
}

/*
int iterate (ref Tree t) {
    ulong nodes = 0;
    int score;
    bool keepgoing = true;
    double search_time;
    double target_time;
    int n = 2;
    StopWatch timer;
    double runtime;
    int max_depth = 64;
    
    transposition_id=(transposition_id+1)&7;
    if (!transposition_id) transposition_id++;
    t.moves_left = PopCnt(~(t.pos.white_stones | t.pos.black_stones));
    max_depth = t.moves_left + 2;
    t.alpha = t.neginf;
    t.beta = t.posinf;
    
    while ((n < max_depth) && (!t.eog)) {
        t.nodes_searched = 0;
        t.leaves_searched = 0;
        writef("ply(%2d)", n);
        timer.start();
        score = pvsSearch(t,t.alpha,t.beta,n,t.pos.side_to_move,t.pos.passed);
//        t.beta = score;
//        t.alpha = score - 1;
        nodes = t.nodes_searched;
        t.pos.sortMoves();
        timer.stop();
        writef(" move %4s",t.pos.move_list[t.pos.position_index][0].sq_name);
        runtime = (timer.peek().msecs/1000.0);
        search_time += runtime;
        writefln("%8d score %12d nodes in %8.2f seconds for %12.0f nodes/sec",score, nodes, runtime, (nodes/runtime));
        timer.reset();
        n++;
    }    
    return score;
}

int pvsSearch (ref Tree tree, int alpha, int beta, int depth, int ctm, bool passed) {
    int score;
    int orig_alpha = alpha;
    int best_move = 99;
    int testalpha,testbeta;
    bool q_yes = false;

    
    switch (hashProbe(tree.pos,ctm,alpha,beta,tree.pos.position_index,depth,tree.pos.hashmove[tree.pos.position_index])) {
        case 3:
            return(alpha);
        case 1:
            return(beta);
        case 2:
            return(alpha);
	default:
	    break;
    }
    
    tree.nodes_searched++;
    if (depth == 0) {
        tree.leaves_searched++;
        return (tree.pos.evaluate(ctm));
    }
    tree.pos.generateRayMoves();
    if (tree.pos.num_moves[tree.pos.position_index] == 0) {
        if (passed) {
            tree.leaves_searched++;
            return tree.pos.eog_evaluate(ctm);
        }
        tree.pos.makePass();
        score = -pvsSearch(tree, -beta, -alpha, depth-1, (ctm^1), true);
        tree.pos.unmakePass();
        tree.pos.move_list[tree.pos.position_index][0].sq_num = tree.passmove;
        tree.pos.move_list[tree.pos.position_index][0].score = score;
    }
//    if (depth == 0) {
//        tree.leaves_searched++;
//        return (tree.pos.evaluate(ctm));
//    }
    else {
        for (int m=0; m<tree.pos.num_moves[tree.pos.position_index]; m++) {
            if (m != 0) {
                tree.pos.makeMove(tree.pos.move_list[tree.pos.position_index][m]);
                if (tree.pos.move_list[tree.pos.position_index][m].mask && tree.pos.mask_test.quiesce) {
                    depth += 1;
                    q_yes = true;
                }
                score = -pvsSearch(tree, (-alpha - 1), -alpha, (depth-1), (ctm^1), false);
                if ((alpha < score) && (score < beta))  
                    score = -pvsSearch(tree, -beta, -alpha, (depth-1), (ctm^1), false);
                tree.pos.unmakeMove(tree.pos.move_list[tree.pos.position_index-1][m]);
                tree.pos.move_list[tree.pos.position_index][m].score = score;
                if (q_yes) {
                    q_yes = false;
                    depth -= 1;
                }
            }        
            else {
                tree.pos.makeMove(tree.pos.move_list[tree.pos.position_index][m]);
                if (tree.pos.move_list[tree.pos.position_index][m].mask && tree.pos.mask_test.quiesce) {
                    depth += 1;
                    q_yes = true;
                }                
                score = -pvsSearch(tree, -beta, -alpha, (depth-1), (ctm^1), false);
                tree.pos.unmakeMove(tree.pos.move_list[tree.pos.position_index-1][m]);
                tree.pos.move_list[tree.pos.position_index][m].score = score;
                if (q_yes) {
                    q_yes = false;
                    depth -= 1;
                }
            }
            if (score > alpha) {
                alpha = score;
                best_move = tree.pos.move_list[tree.pos.position_index][m].sq_num;
                tree.pos.move_list[tree.pos.position_index][m].score = score;
            }
            if (alpha >= beta) {
                best_move = tree.pos.move_list[tree.pos.position_index][m].sq_num;
                tree.pos.killer2[tree.pos.position_index] = tree.pos.killer1[tree.pos.position_index];
                tree.pos.killer1[tree.pos.position_index] = tree.pos.move_list[tree.pos.position_index][m].sq_num;
                tree.pos.move_list[tree.pos.position_index][m].score = score;
                hashStore(tree.pos,ctm,1,score,tree.pos.position_index,depth,best_move);
                break;
            }    
        }
    }
    if ((alpha == orig_alpha) && (best_move < 64)) {
        hashStore(tree.pos,ctm,3,alpha,tree.pos.position_index,depth,best_move);
    }    
    else if (best_move < 64) {
        hashStore(tree.pos,ctm,2,alpha,tree.pos.position_index,depth,best_move);
    }    
    return alpha;
}
*/

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
     
//     switch (hashProbe(t.pos,t.pos.side_to_move,alpha,beta,t.pos.position_index,0,t.pos.hashmove[t.pos.position_index])) {
//         case t.pos.exact:
//             return(alpha);
//         case t.pos.lower:
//             return(beta);
//         case t.pos.upper:
//             return(alpha);
//         default:
//             break;
//     }     
   
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
           t.leaves_searched++;
           return b;
        } else {
           t.pos.makePass();
           b = -Scout(t, -beta, -alpha);
           t.pos.unmakePass();
           t.pos.move_list[t.pos.position_index][0].score = b;
           return b;
        }
     }
     t.pos.makeMove(t.pos.move_list[t.pos.position_index][0]);
     b = -Scout(t,-beta,-alpha);
     t.pos.unmakeMove(t.pos.move_list[t.pos.position_index-1][0]);
     t.pos.move_list[t.pos.position_index][0].score = b;
     best_move = t.pos.move_list[t.pos.position_index][0].sq_num;
     if (b > alpha) {
         alpha = b;
         if (b >= beta) {
             t.pos.killer2[t.pos.position_index] = t.pos.killer1[t.pos.position_index];
             t.pos.killer1[t.pos.position_index] = t.pos.move_list[t.pos.position_index][0].sq_num;
//             hashStore(t.pos,t.pos.side_to_move,t.pos.lower,b,t.pos.position_index,0,t.pos.move_list[t.pos.position_index][0].sq_num);
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
         best_move = t.pos.move_list[t.pos.position_index][i].sq_num;
         if (b > alpha) {
             alpha = b;
             if (b >= beta) {
                 t.pos.killer2[t.pos.position_index] = t.pos.killer1[t.pos.position_index];
                 t.pos.killer1[t.pos.position_index] = t.pos.move_list[t.pos.position_index][i].sq_num;
//                 hashStore(t.pos,t.pos.side_to_move,t.pos.lower,b,t.pos.position_index,0,t.pos.move_list[t.pos.position_index][i].sq_num);
                 return b;
             }
         }
         i++;
     }
//     if (alpha == orig_alpha) 
//         hashStore(t.pos,t.pos.side_to_move,t.pos.upper,b,t.pos.position_index,0,best_move);
//     else
//         hashStore(t.pos,t.pos.side_to_move,t.pos.exact,b,t.pos.position_index,0,best_move);
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
