import std.stdio, std.string, std.array, std.conv, std.datetime, core.memory;
import move;
import bitboard;
import square;
import squares;
import flips;
import position;
import search;
import hash;
import game;
import masks;

void main (char[][] args) {
    Position p = new Position();
    Tree t;
    
    
    
    InitializeRandomHash();
    InitializeHashTables();
    hash_maska=(1<<log_hash)-1;
     
    p.startBoard();
    t = new Tree(p);

    getCommand(t);
}
    
    