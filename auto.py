import os
import time
def compare():
    Sorted = open("output.txt", "r")
    Facit = open("ftest.txt", "r")
    return (Sorted.read() == Facit.read())
#1 Alla samma
#2 Stigande backar
#3 Saknad front
#4 Stigande
#5 Fallande backar
#6 Saknad mitt
#7 Fallande
#8 Orgel
#9 Slumpvis
passed = 0
failed = 0
x = time.time()
os.system("./sort1 < test.txt > output.txt")
if (compare()):
    passed = passed + 1
else:
    print ("sort1 failed.")
    failed = failed + 1
print("Sort1 time: %f\n"%(time.time()-x))
x = time.time()
os.system("./sort2 < test.txt > output.txt")
if (compare()):
    passed = passed + 1
else:
    print ("sort2 failed.")
    failed = failed + 1
print("Sort2 time: %f\n"%(time.time()-x))
x = time.time()
os.system("./sort3 < test.txt > output.txt")
if (compare()):
    passed = passed + 1
else:
    print ("sort3 failed.")
    failed = failed + 1
print("Sort3 time: %f\n"%(time.time()-x))
x = time.time()
os.system("./sort4 < test.txt > output.txt")
if (compare()):
    passed = passed + 1
else:
    print ("sort4 failed.")
    failed = failed + 1
print("Sort4 time: %f\n"%(time.time()-x))
x = time.time()
os.system("./sort5 < test.txt > output.txt")
if (compare()):
    passed = passed + 1
else:
    print ("sort5 failed.")
    failed = failed + 1
print("Sort5 time: %f\n"%(time.time()-x))
x = time.time()
os.system("./sort6 < test.txt > output.txt")
if (compare()):
    passed = passed + 1
else:
    print ("sort6 failed.")
    failed = failed + 1
print("Sort6 time: %f\n"%(time.time()-x))

print("Passed: %d\n"%passed)
print("Failed: %d\n"%failed)
