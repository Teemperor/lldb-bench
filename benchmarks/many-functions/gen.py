#!/usr/bin/env python

import sys

print("#include <array>")
namespaces = 10

for i in range(0, namespaces):
  print("namespace someothername" + str(i) + " {")

func_name = sys.argv[1] + "veryLongFunctionNameToMakeTheBenchmarkBigger"
func_list = []
for i in range(0, 10000):
  func_list.append(func_name + str(i))
  print("std::array<int, " + str(i) + ">*" + func_name + str(i) + "() {")
  if i != 0:
    print("  " + func_name + str(i - 1) + "();")
  print("  return nullptr;")
  print("}")

for i in range(0, namespaces):
  print("}")

print ("int " + sys.argv[1] + "() {")

namespace_spec = ""
for i in range(0, namespaces):
  namespace_spec += "someothername" + str(i) + "::"

for func in func_list:
  print("{")
  print("  auto f = " + namespace_spec + func + "();")
  print("  if (f->size() == 0) return 4;")
  print("}")

print("  return 1;\n}")
