set ns [new Simulator]
set trf [open 3.tr w]
$ns trace-all $trf
set namf [open 3.nam w]
$ns namtrace-all $namf
set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
set n4 [$ns node]
set n5 [$ns node]
$ns duplex-link $n0 $n2 100KB 10ms DropTail
$ns duplex-link $n1 $n2 100KB 10ms DropTail
$ns duplex-link $n2 $n3 100KB 10ms DropTail
$ns duplex-link $n3 $n4 100KB 10ms DropTail
$ns duplex-link $n4 $n5 100KB 10ms DropTail
set ping0 [new Agent/Ping]
$ns attach-agent $n0 $ping0
set ping2 [new Agent/Ping]
$ns attach-agent $n2 $ping2
$ns connect $ping0 $ping2
$ns color 1 red
$ns color 2 green
$ping0 set class_ 1
$ping2 set class_ 2
Agent/Ping instproc recv {from rtt} {
 $self instvar node_
 puts "The node [$node_ id] received a reply from $from with RTT = $rtt"
}
proc finish {} {
 global ns trf namf
 $ns flush-trace
 close $trf
 close $namf
 exec nam 3.nam &
 exit 0
}
$ns at 0.2 "$ping0 send"
$ns at 0.4 "$ping0 send"
$ns at 0.6 "$ping0 send"
$ns at 0.8 "$ping0 send"
$ns at 1.0 "finish"
$ns run