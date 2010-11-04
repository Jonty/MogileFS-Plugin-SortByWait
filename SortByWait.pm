package MogileFS::Plugin::SortByWait;

use strict;
use warnings;

our $VERSION = '0.01';
$VERSION = eval $VERSION;

sub load {
    MogileFS::register_global_hook( 'cmd_get_paths_order_devices', sub {
        my $devs = shift;
        my $sorted_devs = shift;

        # Find the highest value
        my $maxtime = 0;
        foreach my $dev (@$devs) {
            my $await = $dev->observed_await;
            my $svctm = $dev->observed_svctm;

            if (defined($await) && $await =~ /\d+(\.\d+)?/ && defined($svctm) && $svctm =~ /\d+(\.\d+)?/) {
                my $time = $await + $svctm;
                if ($time > $maxtime) {
                    $maxtime = $time;
                }
            }
        }

        my @devices_with_weights;
        my $percentbit = 100 / ($maxtime + 1 * 1.5); # We don't want anything to be 0
        foreach my $dev (@$devs) {
            my $await = $dev->observed_await;
            my $svctm = $dev->observed_svctm;

            my $sum;
            if (defined($await) && $await =~ /\d+(\.\d+)?/ && defined($svctm) && $svctm =~ /\d+(\.\d+)?/) {
                $sum = $await + $svctm;
            } else {
                $sum = $maxtime;
            }

            my $weight = 100 - ($sum * $percentbit);

            push @devices_with_weights, [$dev, int($weight)];
        }

        @$sorted_devs = MogileFS::Util::weighted_list(@devices_with_weights);
        return 1;
    });

    return 1;
}

sub unload {
    MogileFS::unregister_global_hook( 'cmd_get_paths_order_devices' );
    return 1;
}

1;
