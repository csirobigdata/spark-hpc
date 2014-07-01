#!/usr/bin/python

import argparse

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('-cp', '--classpath')
    parser.add_argument('-n', '--nodes', help="number of nodes (default = 1) ", default="1")
    parser.add_argument('-c', '--cores-per-node', help="number of cores pre node", default="1")
    parser.add_argument('-m', '--mem-per-node', help="memory per node in GB", default="1")
    parser.add_argument('-w', '--wall-time', help="walltime", default="10:00")
    parser.add_argument('-d','--debug', dest='debug', action='store_true', help="turn on loging debug info")
    parser.add_argument('mainClass', help="the main class to run")
    args = parser.parse_args()
    print(args)
    jobname = args.mainClass.split(".")[-1]
    vmem = int(args.nodes) * int(args.mem_per_node)
    cmd ="qsub -N %s -l nodes=%s:ppn=%s -l vmem=%sGB -l walltime=%s-j oe ./run-class.sh %s %s" % (jobname, args.nodes, args.cores_per_node,vmem, args.wall_time, args.classpath, args.mainClass) 
    print(cmd)


#PBS -N spark_spark_shell
#PBS -l nodes=1:ppn=4,vmem=4GB
#PBS -l walltime=10:00
#PBS -j oe

