#! /bin/env tclsh

proc lineCount {file} {
    set fId [open $file r]
    while {[gets $fId line] > -1} {incr i}
    close $fId
    return $i
}

while {1} {
    set systemTime [clock seconds]
    set weekday [clock format $systemTime -format {%A}]
    set currentTime [clock format $systemTime -format %H:%M:%S]

    after 500
    if {$weekday == "Monday" && $currentTime == "14:45:00" || $weekday == "Wednesday" && $currentTime == "14:05:00" || $weekday == "Tuesday" && $currentTime == "10:45:00" || $weekday == "Thursday" && $currentTime == "10:45:00"} {
        set infile [open "name_email.txt" r+]
        #set logfile [open "log_file.txt" r+]
        set content [read $infile]
        set data [split $content "\n"]
        set memberCount [lineCount "name_email.txt"]
        set day "Tomorrow"
        set emailSubject " "
        set alwaysInclude "Shreyans.Mulkutkar@alcatel-lucent.com"

        foreach line $data {
            if {[lindex $line 3] == 0} {

               if {$weekday == "Tuesday" || $weekday == "Thursday"} {
                   set emailSubject "REMINDER "
                   set day "Today" 
               }             

                exec echo "$day, [lindex $line 0] [lindex $line 1] will get snacks for the group. If you cannot make it or have any other concerns, PLEASE REPLY TO EVERYONE CCed in this mail.\n\nNote: Currently there are $memberCount members in this group.\n\nIn the past, we have got snacks from:\n-- Rajjot Sweet & Snacks, 1234 S Wolfe Rd, Sunnyvale, CA 94086. Phone: 408-730-5510. Website: www.yelp.com/biz/rajjot-sweet-and-snacks-sunnyvale\n-- Madras Cafe , Contact - Yousuf 408-991-4950 and tell you are calling from Surendran (Suri's) office\n-- Satkar Indian Cuisine, 1252 W El Camino Real, Sunnyvale, CA 94087. Phone: 650-390-0776. Website: www.satkarindiancuisine.com\n-- India Chaat Cuisine, 1082 E El Camino Real, Sunnyvale, CA 94087. Phone: 408-246-6000.\n-- Mrs. Kinnari near Lawrence Expy and Benton St. They operate from home. Contact one day in advance for placing orders. For more info call 408-530-9260. \n\nThanks. Have a great week ahead!\n\nRegards,\nSamosa-Group" | sendmail.sh -f Shreyans.Mulkutkar@alcatel-lucent.com -s "$emailSubject ALU/MountainView ~~ SAMOSA group" "[lindex $line 2],$alwaysInclude"
               
                break
            }

        }       
        after 6100
        close $infile
        #close $logfile
    }

    if {$weekday == "Tuesday" && $currentTime == "16:10:00" || $weekday == "Thursday" && $currentTime == "16:10:10"} {
        set infile [open "name_email.txt" r+]
        #set logfile [open "log_file.txt" w]
        set content [read $infile]
        set data [split $content "\n"]

        set i 0
        foreach line $data {
            incr i
            if {[lindex $line 3] == 0} {
                exec sed -i "$i s/0/1/g" name_email.txt
                flush $infile
                break
            }
        }
        after 6100
        close $infile
        #close $logfile
    }

    #if {$changeStatusTracker == [expr {[lineCount "name_email.txt"]+1}]} {
    #    exec sed -i " s/1/0/g" name_email.txt
    #    flush $infile
    #    puts "Restarting Everyone's turn"
    #}
   
    #close $infile
    #close $logfile
}

