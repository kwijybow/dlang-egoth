import std.stdio, std.string, std.array, std.datetime, std.conv;
import position;
import move;
import squares;
import square;
import rays;
import hash;
import bitboard;

class Tree {
    Position pos;
    ulong leaves_searched;
    ulong nodes_searched;
    int   alpha;
    int   beta;
    int   best_score;
    int   ctm;
    Move  best_move;
    StopWatch timer;
    double runtime;
    double time_for_game = 300.0;
    double game_time_used = 0.0;
    int moves_left = 60;
    enum neginf = -128;
    enum posinf = 128;
    enum badsquare = 64;
    enum passmove = 99;
    
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
        pos.hashkey = search_position.hashkey;
        pos.eog = false;
        leaves_searched = 0;
        nodes_searched = 0;
        alpha = neginf;
        beta = posinf;
        best_score = 0;
        best_move = new Move;
        runtime = 0.0;
        moves_left = PopCnt(~(search_position.white_stones | search_position.black_stones));
    }
}

int iterate (ref Tree t) {
    ulong nodes = 0;
    int score;
    bool keepgoing = true;
    double search_time;
    double target_time;
    int n = 1;
    StopWatch timer;
    double runtime;
    int max_depth = 32;
    
    transposition_id=(transposition_id+1)&7;
    if (!transposition_id) transposition_id++;
    t.moves_left = PopCnt(~(t.pos.white_stones | t.pos.black_stones));
    search_time = 0.0;
    target_time = (t.time_for_game - t.game_time_used)/((to!float(t.moves_left))*1.5);
    writefln("target time = %8.2f",target_time);
     
     
    while (keepgoing) {
        t.nodes_searched = 0;
        t.leaves_searched = 0;
        writef("pvsSearch(%2d)", n);
        timer.start();
        score = pvsSearch(t,-128,128,n,t.pos.side_to_move,false);
        nodes = t.nodes_searched;
        t.pos.sortMoves();
        timer.stop();
        writef(" move %4s",t.pos.move_list[t.pos.position_index][0].sq_name);
        runtime = (timer.peek().msecs/1000.0);
        search_time += runtime;
        writefln("%5d score %12d nodes in %8.2f seconds for %12.0f nodes/sec",t.pos.move_list[t.pos.position_index][0].score, nodes, runtime, (nodes/runtime));
        timer.reset();
        keepgoing = (search_time < target_time);
        n++;
        if (n > max_depth) keepgoing = false;
    }    
    return score;
}

int pvsSearch (ref Tree tree, int alpha, int beta, int depth, int ctm, bool passed) {
    int score;
    int orig_alpha = alpha;
    int best_move = 99;
    int testalpha,testbeta;

/*    
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
*/    
    
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
    else {
        for (int m=0; m<tree.pos.num_moves[tree.pos.position_index]; m++) {
            if (m != 0) {
                tree.pos.makeMove(tree.pos.move_list[tree.pos.position_index][m]);
                score = -pvsSearch(tree, (-alpha - 1), -alpha, (depth-1), (ctm^1), false);
                if ((alpha < score) && (score < beta))  
                    score = -pvsSearch(tree, -beta, -alpha, (depth-1), (ctm^1), false);
                tree.pos.unmakeMove(tree.pos.move_list[tree.pos.position_index-1][m]);
                tree.pos.move_list[tree.pos.position_index][m].score = score;
            }        
            else {
                tree.pos.makeMove(tree.pos.move_list[tree.pos.position_index][m]);
                score = -pvsSearch(tree, -beta, -alpha, (depth-1), (ctm^1), false);
                tree.pos.unmakeMove(tree.pos.move_list[tree.pos.position_index-1][m]);
                tree.pos.move_list[tree.pos.position_index][m].score = score;
            }
            if (score > alpha)
                alpha = score;
                best_move = tree.pos.move_list[tree.pos.position_index][m].sq_num;
            if (alpha >= beta) {
                best_move = tree.pos.move_list[tree.pos.position_index][m].sq_num;
                tree.pos.killer2[tree.pos.position_index] = tree.pos.killer1[tree.pos.position_index];
                tree.pos.killer1[tree.pos.position_index] = tree.pos.move_list[tree.pos.position_index][m].sq_num;
//                hashStore(tree.pos,ctm,1,score,tree.pos.position_index,depth,best_move);
                break;
            }    
        }
    }
    if ((alpha == orig_alpha) && (best_move < 64)) {
//        hashStore(tree.pos,ctm,3,alpha,tree.pos.position_index,depth,best_move);
    }    
    else if (best_move < 64) {
//        hashStore(tree.pos,ctm,2,alpha,tree.pos.position_index,depth,best_move);
    }    
    return alpha;
}
