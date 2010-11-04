SortByWait
==========
A MogileFS plugin that uses the newly added support for gathering await and
svctime from MogileFS nodes when returning the devices in a get_paths call.

Sorts devices by the combined await+svctime, rather than disk utilisation.

Our use case
------------
At Last.fm we have a large MogileFS cluster, mostly made up of machines with
hard disks, but some with SSD's. 

In this environment iostat utilisation is useless on SSD based machines, often
reporting 100% usage when the disk is nowhere near capacity. We want to serve
the files from the machines responding the fastest at any given time, so
ordering devices based on await and svctime makes more sense.

Use of this plugin completely changes the load pattern on our MogileFS cluster,
with each SSD node handling 4x the traffic of the HD nodes, whereas before they
handled approximately the same amount.

Configuration
-------------
Add "plugins = SortByWait" to your mogilefsd.conf
