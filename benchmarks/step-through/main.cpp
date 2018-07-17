#include <vector>
#include <algorithm>

int main() {
  std::vector<int> v = {1,23,4,5,5,6,6,7,89,234,523,4523,45,623};
  for (int i = 0; i < 1000; ++i) {
    v[i %v.size()] = v[(i + 80) % v.size()];
  }
  return v.size();
}
