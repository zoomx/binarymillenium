/** 
 * copied from tacticalspace misc.cpp/misc.hpp 
*/


#include <string>
#include <vector>
#include <iostream>

#include <stdio.h>
#include <stdlib.h>

#include "utility.h"

using namespace std;

vector<string> tokenize(const string str, const string delimiter)
{
    vector<string> tokens;

    // Skip delimiters at beginning.
    string::size_type lastPos = str.find_first_not_of(delimiter, 0);
    // Find first "non-delimiter".
    string::size_type pos     = str.find_first_of(delimiter, lastPos);

    while (string::npos != pos || string::npos != lastPos)
    {
        // Found a token, add it to the vector.
        tokens.push_back(str.substr(lastPos, pos - lastPos));
        // Skip delimiters.  Note the "not_of"
        lastPos = str.find_first_not_of(delimiter, pos);
        // Find next "non-delimiter"
        pos = str.find_first_of(delimiter, lastPos);
    }


    return tokens;
}

vector<string> tokenize(const vector<string> tokens, const string delimiter)
{
    vector<string> newTokens;

    for (unsigned i = 0; i < tokens.size(); i++) {
        vector<string> subTokens = tokenize(tokens[i], delimiter);
        for (unsigned j = 0; j < subTokens.size(); j++) {
            newTokens.push_back(subTokens[j]);
        }

    }

    return newTokens;
}

//template <class T>
bool match(const string name, const vector<string> tokens,
        vector<float>& params,const  bool verbose,const  unsigned paramNum)
{
    if (tokens[0] == name) {
        if (tokens.size() != paramNum) {
            cerr << "matched '" << name << "' but wrong parameter number: "
                << tokens.size() << " \n";
            return false;
        }

        for (unsigned int i = 1; i < paramNum; i++) { 
            params.push_back(atof(tokens[i].c_str()));
        }

        //if (verbose) cout  << "matched '" << name << "' with " << x << "\n";
        return true;
    }

    if (verbose) cout  << "couldn't match '" << name << "\n";
    return false;
}

bool match(const string name, const vector<string> tokens,
        string& x, const bool verbose, const unsigned paramNum)
{
    if (tokens[0] == name) {
        if (tokens.size() != paramNum) {
            cerr << "matched '" << name << "' but not correct parameter number: "
                << tokens.size() << " \n";
            return false;
        }

        x = (tokens[1]);

        if (verbose) cout  << "matched '" << name << "' with " << x << "\n";
        return true;
    }

    return false;

}

