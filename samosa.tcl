#! /bin/env tclsh

# Shreyans
puts "\n~~~~~~~~~~ Welcome to Chat-n-Snack Group ~~~~~~~~~~\n"

set loginId "void"
set loginPwd "void"
set loginType "user"
set adminChoice "n"

set infile [open "name_email.txt" r+]

proc getLoginPassword {} {
    global loginId loginPwd
    puts -nonewline "Login: "
    flush stdout
    set loginId [gets stdin]
    exec stty -echo
    puts -nonewline "Password: "
    flush stdout
    set loginPwd [gets stdin]
    exec stty echo 
}

set loginChances 0

if {$argc == 0} {
    global adminChoice
    puts "Do you want to login as Admin?\nEnter 'y' for Admin login or any key to continue as User"
set adminChoice [gets stdin]
}
if {$adminChoice == "y"} {
    global loginType loginChances loginId loginPwd
    while {$loginChances < 3} {
        getLoginPassword
        if {$loginId == "admin" && $loginPwd == "admin"} {
            puts "\nINFO: Login Successful. You are logged in as Admin\n"
            set loginType "admin"
            break
        }  else {
            puts "\nERROR: Login-Password mismatch. Please verify and re-enter login and password\n"
        }
        incr loginChances
        puts "WARNING: You are left with [expr 3 - $loginChances] attempts..\n"
    }
} else {
    puts "\nINFO: You are logged in as User\n"
}

if {$loginChances == 3} {
    puts "~~~~~ ERROR: Maximum number of login attempts exceeded.\nPlease contact your admin before re-trying. ~~~~~\n"
    exit
}

proc nextMessage {} {
    global loginType
    puts "~~ Select commands from following options ~~"
    puts "Enter '1' to get a list of all members of this group"
    puts "Enter '2' to find if a particular member already exist in this group"
    puts "Enter '3' to get next week's SNACKer"
    if {$loginType == "admin" } { puts "Enter '4' to add new members to this group" }
    if {$loginType == "admin" } { puts "Enter '5' to modify a member's SNACK-schedule status" }
    puts "Enter 'exit' to close this application"
    puts "Enter 'options' to view this command list again\n"
}

nextMessage

proc lineCount {file} {
    set fId [open $file r]
    while {[gets $fId line] > -1} {incr i}
    close $fId
    return $i
}

proc wednesdayList {arg} {
    global members loginType
    set infile [open "name_email.txt" r+]
    set content [read $infile]
    set currentStatus "Soon to get SNACKS"
    switch $arg {
        "1" {
            set memberCount [lineCount "name_email.txt"]
            puts "\nINFO: Currently there $memberCount members in this group. Here's the list ~~~~ "
            set data [split $content "\n"]
            foreach line $data {
                puts \t[lrange $line 0 2]
            }
        }

        "2" {
            puts "Enter First name for look-up"
            puts -nonewline ">> "
            flush stdout
            set searchMemberFirstName [gets stdin]
            puts "Enter Last name for look-up"
            puts -nonewline ">> "
            flush stdout
            set searchMemberLastName [gets stdin]

            set data [split $content "\n"]
            foreach line $data {
                if {$searchMemberFirstName == [lindex $line 0] && $searchMemberLastName == [lindex $line 1]} {
                    puts "\nINFO: $searchMemberFirstName $searchMemberLastName is already present in this group.\n"
                    return
                }
            }
            puts "INFO: $searchMemberFirstName $searchMemberLastName is not present in this group"
            if {$loginType != "admin"} { return }
            puts "INFO: Would you like to add $searchMemberFirstName $searchMemberLastName to this group?\nEnter y or n\n"
            puts ">> "
            flush stdout
            set response [gets stdin]
            if {$response == "y"} {
                wednesdayList "4"
            }  elseif {$response == "n"} {
                   ;#puts "Enter next valid command or Exit. Forgot commands? Enter Menu to get the list again\n"
            } else {
                   puts "ERROR: You entered wrong option. Re-enter the main menu option\n"
            }
        }

        "3" {
            set data [split $content "\n"]

            set systemTime [clock seconds]
       
            foreach line $data {
                if {[lindex $line 3] == 0} {
                    puts "INFO: [lindex $line 0] [lindex $line 1] will next get snacks for all of us\n"
                    break 
                }
            }

            #When everyone is done and has status 1. Toggle everyone's status to 0 using following command:
            # [In Vi editor] :%s/1/0/g
            # i.e. Find each occurrence of '1' (in all lines), and replace it with '0'
      
        }

        "4" {
            if {$loginType != "admin"} { wednesdayList "default"; return }
            set data [split $content "\n"]
            
	    puts "\nEnter new member's email id"
            puts -nonewline ">> "
            flush stdout
	    set emailId [gets stdin]

	    if { ![regexp {.+@alcatel-lucent.+} $emailId] } {
               puts "ERROR: Invalid email address entered. Please enter a valid Alcatel-Lucent email address."
            } else {
                puts "INFO: Valid email address entered."

                #set data [split $content "\n"]
                foreach line $data {
                    if {$emailId == [lindex $line 2]} {
                        puts "WARNING: $emailId already present in this group.\n"
			return 
                    }
		}


                regexp -- {([A-z]+)\.([A-z]+)\@alcatel-lucent\.com} $emailId foo char number
                set firstName   $char
                set lastName $number
                set Name [list $firstName $lastName $emailId 0]
                set newEntry [join $Name]
                puts $infile $newEntry
                flush $infile
                
		puts "INFO: New member successfully added to this group\n"    
                set memberCount [lineCount "name_email.txt"]

                puts "INFO: Do you want to view the complete list?\nINFO: Enter y or n"
                puts -nonewline ">> "
                flush stdout
                set response [gets stdin]
                if {$response == "y"} {
                    wednesdayList "1"
                }
            }
        }

        "5" {
            if {$loginType != "admin"} { wednesdayList "default"; return }
            puts "\nINFO: Functionality coming soon...\nINFO: Sorry for the inconvenience.\nINFO: For more info, please send an email to Admin - Shreyans.Mulkutkar@alcatel-lucent.com\n"
        }
 
        "options" {
            nextMessage
        }

        default {
            puts "\n~~~ ERROR: Invalid command ~~~\n"
        }
    } 
}

puts -nonewline ">> "
flush stdout
set arg [gets stdin]

while {$arg != "exit"} {
    wednesdayList $arg
    puts "~~ Enter next valid command or 'exit'.\nForgot commands? Enter 'options' to get the list again ~~\n"
    puts -nonewline ">> "
    flush stdout
    set arg [gets stdin]
}
