---
title: Basic profiling walkthrough
layout: main
---

In this walkthrough, we are going to set up a virtual development machine on GCP, install some profiling support, and see what we can see about the performance of a few toy codes.

Before we get started, you should set up a Linux VM on GCP.  I recommend an `e2-micro` instance with the stock Debian 10 (Buster) OS and a 10 GB drive.
This doesn't include a lot of amenities, so you will probably want to grab a few packages before we begin: compilers, profilers, and tools.  Here is how I set things up

      sudo apt-get install build-essential
      sudo apt-get install llvm
      sudo apt-get install clang
      sudo apt-get install git
      sudo apt-get install google-perftools
      sudo apt-get install valgrind

## Performance counters and virtual despair

If you have access to a physical machine with no virtualization, and you are able to get root access, you can use *performance counters* to tell things like how many cache misses you suffered, how many misalignment penalties, and so forth.  There are a few libraries that make use of these performance counters, including the Linux [perf](https://perf.wiki.kernel.org/index.php/Tutorial) system and [likwid](https://hpc.fau.de/research/tools/likwid/) (Like I Know What I'm Doing).  There are also some very nice commercial packages like the Intel Parallel Studio (big chunks are available gratis in educational settings).

Unfortunately, the virtualization on the Google Compute Engine is set up not to share the hardware performance counters.  I believe this is because it is considered a security risk; nonetheless, it's annoying for fine-grain profiling work.

You should feel free to install these tools on your own systems, but we are going to assume they are off-limits for the rest of this walkthrough.

## [Google PerfTools](https://gperftools.github.io/gperftools/cpuprofile.html)

The Google PerfTools package (previously known as gperftools) is a simple sampling profiler.  It works pretty well, but you have to know how to use it.  To run the profiler, you have to run the code with the profiling library.  This generates a profiling output file that you can look at with the viewer tool.

Using our centroid demo as an example, we the following line to collect the profiling information

      CPUPROFILE=/tmp/profile \
        LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libprofiler.so.0 \
        ./centroid.x

Yes, it's a bit of a mouthful.  The `LD_PRELOAD` variable tells the linker that we want to include the profiling library, and `CPUPROFILE` is the name of the file that we want to write data into.  We don't need to do anything at compile time to make this work; it is all at run time.

Once we have run the profile, we have to take a look at the output.  We will do this with the profile viewer

      google-pprof ./centroid.x /tmp/profile

Details of viewer subcommands are listed).
You will typically want to compile with debugging symbols (`-g`)
in order to get the most insight possible out of this exercise.

## An old favorite: [`gprof`](https://en.wikipedia.org/wiki/Gprof)

An alternate way to collect profiling information is by compiling your code with the `-pg` flag in GCC.  Once this is done, any run will produce a data file called `gmon.out`, which you can then view with the `gprof` profiler.

      gprof ./centroid.x

This shows a summary of the time spent in various functions.  Note that if you use the default GCC version and stay with optimization level O2, some of the functions (particularly `centroid1` and `centroid3`) are likely to be inlined on your behalf.  This is a fine optimization, but it's awful for understanding a profile.

It's good to know about gprof, but we will find that we are somewhat limited in our ability to use it this semester, as it is not thread-safe.

## [Cachegrind](https://www.valgrind.org/docs/manual/cg-manual.html)

The `valgrind` program is really a suite of different tools that dynamically instrument a code and run it in partial simulation in order to figure out things about it.  Maybe the most well-known of the `valgrind` tools is the memory checker, but you can also try using `cachegrind` to reason about potential cache issues in your code.  However, `cachegrind` works by emulating a CPU and associated caches, and this is excruciatingly slow.  It's fine for timing short things that will be run a number of times, but it would kill us on a long run.

## [LLVM Machine Code Analyzer](https://llvm.org/docs/CommandGuide/llvm-mca.html)

If we want to dig a bit deeper, the LLVM Machine Code Analyzer (`llvm-mca`) can help us understand where the code that we've written actually is able to make good use of machine resources.  The `llvm-mca` program runs a static analysis on the assembly code coming out from our favorite compiler (GCC or CLang) and tells us where we are going to have bad latencies and low throughputs.

Unfortunatey, this is pretty indecipherable stuff, at least at first!  If you decide to play around with this at all, you will probably want to look at only a small segment of your code.

## Above and beyond

The tools described above all tell us some variant of how long we are spending in one part of the code or another, potentially along with some auxiliary information about cache misses or empty pipeline cycles.  This is notably not the same as knowing what changes will actually help us achieve good performance!  One of the cooler pieces of profiling work that I've seen in the past few years addresses exactly that.  The [coz profiler](https://github.com/plasma-umass/coz) out of UMass Amherst runs a "what if" experiment for each line of code of interest, asking "what would happen if this line took some percentage less time?"  This helps us figure out which part of our code is most likely to really matter to the program performance.

Because coz is a Debian package, we only need one line to install it and start playing around:

      sudo apt-get install coz-profiler

The [paper](http://arxiv.org/pdf/1608.03676v1.pdf) is worth reading, by the way.  Or, if you don't want to read the paper, the [talk video](http://www.youtube.com/watch?v=jE0V-p1odPg&t=0m28s) is also pretty good.
