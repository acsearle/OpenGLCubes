#include <fstream>
#include <iterator>
#include <string>

#include "source.h"

using namespace std;

string load(string name) {
    ifstream f{name};
    return string{istreambuf_iterator<char>{f}, istreambuf_iterator<char>{}};
}
