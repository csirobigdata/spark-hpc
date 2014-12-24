SPARK-HPC Installation 
-------------------

### <a name="depend"></a>Dependencies

Spark-HPC requires the following software and environment variables to be setup
on the system:

* Spark 1.0.x
    - `SPARK_HOME` environment variable must be set to the Spark installation
      directory
    - The `bin` directory of the Spark installation must be added to the `PATH`
      environment variable
* MPI
    - The `mpirun` script/program must be visible via the `PATH`
      ENVironment variable. If your MPI distribution use a different name to
      `mpirun`, please set up an alias or symbolic link named `mpirun`.

### <a name="setup"></a> Setup

1. Copy the Spark-HPC project directory to the desired location.
2. Set the `SPARKHPC_HOME` and `SPARKHPC_ROOT` environment variables to the
   base location used above.
3. Add `${SPARKHPC_HOME}/bin` to the system `PATH`.

### <a name="site_conf"></a> Site Wide Runtime Config

Site wide runtime configuration options can be set by system administrators in
the `set-env.sh` script in the `SPARKHPC_HOME` directory. Please see comments in
this script for a description of the available environment variables.

Values in this file are overwritten by values in the [User Config](#user_conf)
file. On some sites, usage policies or conventions dictate that certain
`SPARKHPC_*`  variables be tightly controlled to avoid a user
adversely affecting other users on the system.

The following variables will cannot be overriden:

- `SPARKHPC_LOCAL_DIR`- the dir to use for SPARK tmp dirs (can be local to executor nodes)
- `SPARKHPC_FLUSH_DIR` - the dir to use for SPARKHPC temp dir (needs to to be shared between cluster nodes)

### <a name="user_conf"></a> User Config

User configuration of `SPARKHPC_*`,  and any other environment
variables specific to your applications can be set in a
`~/.spark-hpc/set-env.sh` file.

Note that it is not advisable to overwrite some site wide configuration
settings (see [Site Wide Config](#site_conf)). Options for forcing overwrite
are outlined in `spark-hpc.sh --help`.

