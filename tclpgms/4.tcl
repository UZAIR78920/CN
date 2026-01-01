# Simulator
set ns [new Simulator]
set ntrace [open 4.tr w]
$ns trace-all $ntrace
set namfile [open 4.nam w]
$ns namtrace-all $namfile
# coloring
$ns color 1 "Blue"
$ns color 2 "Red"
# create nodes
for {set i 0} {$i < 6} {incr i} {
 set n($i) [$ns node]
}
# duplex links
$ns duplex-link $n(0) $n(2) 2Mb 10ms DropTail
$ns duplex-link $n(1) $n(2) 2Mb 10ms DropTail
# Simplex links
$ns simplex-link $n(2) $n(3) 0.3Mb 100ms DropTail
$ns simplex-link $n(3) $n(2) 0.3Mb 100ms DropTail
# LAN setup
set lan [$ns newLan "$n(3) $n(4) $n(5)" 0.5Mb 40ms LL Queue/DropTail MAC/802_3 Channel]
# Placements
$ns duplex-link-op $n(0) $n(2) orient right-down
$ns duplex-link-op $n(1) $n(2) orient right-up
$ns simplex-link-op $n(2) $n(3) orient right
# setting Queue size
$ns queue-limit $n(2) $n(3) 10
$ns simplex-link-op $n(2) $n(3) queuePos 0.5
# setup TCP-agent
set tcp [new Agent/TCP]
$tcp set fid_ 1
$tcp set packetSize_ 552
$ns attach-agent $n(0) $tcp
set sink [new Agent/TCPSink]
$ns attach-agent $n(4) $sink
$ns connect $tcp $sink
# ftp application for tcp
set ftp [new Application/FTP]
$ftp attach-agent $tcp
# set up UDP agent
set udp [new Agent/UDP]
$udp set fid_ 2
$ns attach-agent $n(1) $udp
set null [new Agent/Null]
$ns attach-agent $n(5) $null
$ns connect $udp $null
# cbr Application for udp
set cbr [new Application/Traffic/CBR]
$cbr set packetSize_ 1000
$cbr set interval_ 0.01
$cbr attach-agent $udp
proc finish {} {
 global ns ntrace namfile
 $ns flush-trace
 close $ntrace
 close $namfile
 exec nam 4.nam &

 # TCP throughput calculation
 set tcpsize [exec grep "^r " 4.tr | grep "tcp" | cut -d " " -f 6 | tail -n 1]
 set numTcp [exec grep "^r" 4.tr | grep -c "tcp"]
 set tcpTime 23.0
 puts "the throughput of ftp"
 puts "[expr ($numTcp * $tcpsize) / $tcpTime] bytes per second"

 # UDP throughput calculation
 set udpsize [exec grep "^r " 4.tr | grep "cbr" | cut -d " " -f 6 | tail -n 1]
 set numudp [exec grep "^r" 4.tr | grep -c "cbr"]
 set udpTime 24.0
 puts "the throughput of cbr"
 puts "[expr ($numudp * $udpsize) / $udpTime] bytes per second"
}
# events
$ns at 0.1 "$cbr start"
$ns at 1.0 "$ftp start"
$ns at 24.0 "$ftp stop"
$ns at 24.5 "$cbr stop"
$ns at 25.0 "finish"
$ns run