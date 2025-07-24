#include <iostream>
#include <fstream>
#include <string>
#include <cmath>

int main() {
    std::ifstream meminfo("/proc/meminfo");
    std::string label;
    long total = 0, free = 0, buffers = 0, cached = 0;

    while (meminfo >> label) {
        long value;
        std::string unit;
        meminfo >> value >> unit;

        if (label == "MemTotal:") total = value;
        else if (label == "MemFree:") free = value;
        else if (label == "Buffers:") buffers = value;
        else if (label == "Cached:") cached = value;

        if (total && free && buffers && cached) break;
    }

    long used = total - (free + buffers + cached);
    double usagePercent = std::ceil((double)used / total * 100.0);

    std::cout << static_cast<int>(usagePercent) << std::endl;

    return 0;
}
