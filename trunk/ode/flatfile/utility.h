#ifndef UTILITY_H
#define UTIlITY_H

#include <vector>
//#include <string>

using namespace std;

vector<string> tokenize(const string str, const string delimiter = "\t");
/// retokenize a bunch of tokens, split them up further
vector<string> tokenize(const vector<string> tokens, const string delimiter= "\t");

//template <class T>
bool match(const string name, const vector<string> tokens,
        vector<float>& params, const bool verbose, const unsigned paramNum);
//bool match(const string name, const vector<string> tokens, string& x,
//        const bool verbose = false, const unsigned paramNum =2);


#endif
