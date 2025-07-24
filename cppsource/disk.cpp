#include <iostream>
#include <sys/statvfs.h>
#include <cmath>

int getDiskUsagePercent(const std::string& path) {
    struct statvfs stat;

    if (statvfs(path.c_str(), &stat) != 0) {
        perror("statvfs failed");
        return -1;
    }

    unsigned long long total = stat.f_blocks * stat.f_frsize;
    unsigned long long available = stat.f_bavail * stat.f_frsize;
    unsigned long long used = total - available;

    if (total == 0) return -1;

    double usage = (static_cast<double>(used) / total) * 100;
    return static_cast<int>(std::ceil(usage));
}

int main() {
    int usagePercent = getDiskUsagePercent("/");

    if (usagePercent >= 0) {
        std::cout << usagePercent << std::endl;
    } else {
        return 1;
    }

    return 0;
}
