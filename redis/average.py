
from glob import glob
import pandas as pd 

#work_type = ["a", "b", "c" , "d", "e", "f"]
work_type = [i for i in range(1,11)]
for wo in work_type:
    print("Averaging result from benchmarking workload {} . . . . . . ".format(wo))
    f_list = glob("./{}/*Run[0-9].txt".format(wo))
    f_list.sort()
    result = pd.read_csv(f_list[0], header=None)
    for f in f_list[1:]:
        data = pd.read_csv(f, header=None)
        result[2] =result[2] + data[2]
    result[2] = result[2]/len(f_list)
    result.to_csv("./{}/result.txt".format(wo), index=False)
    print("Saving result to ./{}/result.txt\n\n".format(wo))
