set ns [new Simulator]
set trf [open 1.tr w]
$ns trace-all $trf
set namf [open 1.nam w]
$ns namtrace-all $namf
set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
$n0 label "source node"
$n1 label "Intermediate node"
$n2 label "destination node"
$ns duplex-link $n0 $n1 100Kb 100ms DropTail
$ns duplex-link $n1 $n2 5Mb 200ms DropTail
$ns queue-limit $n0 $n1 10
set tcp [new Agent/TCP]
$tcp set fid_ 1
$ns color 1 Blue
$ns attach-agent $n0 $tcp
set sink [new Agent/TCPSink]
$sink set fid_ 2
$ns color 2 Red
$ns attach-agent $n2 $sink
$ns connect $tcp $sink
set ftp [new Application/FTP]
$ftp attach-agent $tcp
$ftp set packetSize_ 500
$ftp set interval_ 0.001
proc finish {} {
 global ns trf namf
 $ns flush-trace
 close $trf
 close $namf
 exec nam 1.nam &
 exit 0
}
$ns at 0.1 "$ftp start"
$ns at 10.0 "finish"
$ns run