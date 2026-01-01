set ns [new Simulator]
set trf [open 2.tr w]
$ns trace-all $trf
set namf [open 2.nam w]
$ns namtrace-all $namf
set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
$n0 label "TCP Source"
$n1 label "UDP Source"
$n2 label "Router "
$n3 label "Destination"
$ns duplex-link $n0 $n2 10Mb 10ms DropTail
$ns duplex-link $n1 $n2 10Kb 100ms DropTail
$ns duplex-link $n2 $n3 10Kb 100ms DropTail
set tcp [new Agent/TCP]
$ns attach-agent $n0 $tcp
set sink [new Agent/TCPSink]
$ns attach-agent $n3 $sink
set ftp [new Application/FTP]
$ftp attach-agent $tcp
set udp [new Agent/UDP]
$ns attach-agent $n1 $udp
set null [new Agent/Null]
$ns attach-agent $n3 $null
set cbr [new Application/Traffic/CBR]
$cbr attach-agent $udp
$ns connect $tcp $sink
$ns connect $udp $null
$ftp set packetSize_ 200
$ftp set interval_ 0.001
$cbr set packetSize_ 300
$cbr set interval_ 0.001
$ns color 1 "red"
$ns color 2 "green"
$tcp set class_ 1
$udp set class_ 2
proc finish {} {
 global ns trf namf
 $ns flush-trace
 exec nam 2.nam &
 close $namf
 close $trf
 exit 0
}
$ns at 0.1 "$cbr start"
$ns at 0.3 "$ftp start"
$ns at 5.0 "$ftp stop"
$ns at 5.0 "$cbr stop"
$ns at 7.0 "finish"
$ns run