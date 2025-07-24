#include <iostream>
#include <fstream>
#include <string>
#include <thread>
#include <chrono>
#include <sstream>

using namespace std;

void parseCPUStats(const string& line, unsigned long long& idleTime, unsigned long long& totalTime) {
    istringstream iss(line);
    string cpu;
    unsigned long long user, nice, system, idle, iowait, irq, softirq, steal;
    iss >> cpu >> user >> nice >> system >> idle >> iowait >> irq >> softirq >> steal;
    
    idleTime = idle + iowait;
    totalTime = user + nice + system + idle + iowait + irq + softirq + steal;
}

float getCPUUsage() {
    ifstream statFile;
    string line;

    unsigned long long idle1, total1;
    unsigned long long idle2, total2;

    statFile.open("/proc/stat");
    getline(statFile, line);
    statFile.close();
    parseCPUStats(line, idle1, total1);

    this_thread::sleep_for(chrono::milliseconds(30));

    statFile.open("/proc/stat");
    getline(statFile, line);
    statFile.close();
    parseCPUStats(line, idle2, total2);

    unsigned long long deltaIdle = idle2 - idle1;
    unsigned long long deltaTotal = total2 - total1;

    float usage = 100.0f * (deltaTotal - deltaIdle) / deltaTotal;
    return usage;
}

int main() {
    float cpuUsage = getCPUUsage();
    cout << static_cast<int>(cpuUsage + 0.5f) << endl;
    return 0;
}

