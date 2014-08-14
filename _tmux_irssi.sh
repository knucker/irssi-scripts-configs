#!/bin/bash
#..--~~--..--~~--..--~~--..--~~--..--~~--..--~~--..--~~--..--~~--..--~~--..--~~--.
#                                  TMUX AND IRSSI
#..--~~--..--~~--..--~~--..--~~--..--~~--..--~~--..--~~--..--~~--..--~~--..--~~--.
#
# knucker <www.knucker [at] gmail [dot] com> - Thu Aug 14 12:00:00 BRT 2014
#
# Use me to get your tmux session restored after a reboot or reattach daily.
# Just type tmuxgo every morning and hit ^bd at the end of the day. Login
# remotely and do the same.
#
# Attaches to an existing session named $SESSION or will create one if missing.
# The created session will be pre-populated with a number of windows. 
#
# For example, window 0 running IRC, window 1 running email, window 2 logged
# into a router used daily.
#
#..--~~--..--~~--..--~~--..--~~--..--~~--..--~~--..--~~--..--~~--..--~~--..--~~--.

declare SESSION
declare IRCNAME
declare SIRC
declare TMUX

SESSION=${USER} # The name of the session
IRCNAME=${1}	# The name of the IRC client
SIRC="IRC"

function tmuxfoo(){
	test -z ${IRCNAME} && IRCNAME='irssi'
	test -z $(which ${IRCNAME}) && echo 'The irc client was not found.' && exit 1
	TMUX=$(which tmux)
	test -z ${TMUX} && echo 'The tmux was not found.' && exit 1

	# If has a session already created
	${TMUX} has-session -t ${SESSION} 2>/dev/null
	if [ $? -eq 0 ]; then
		echo "The ${SESSION} session already exists."
		echo -n "Attaching..."
		sleep 1
		${TMUX} -2 attach -d -t ${SESSION}
		exit 0;
	fi
	
	# create a new session and force detach
	${TMUX} -2 new-session -d -s ${SESSION}
	
	${TMUX} set-window-option -t ${SESSION} -g automatic-rename off
	${TMUX} new-window -t ${SESSION}:0 -k -n ${SIRC} $IRCNAME
	${TMUX} set-window-option -t ${SESSION}:0 automatic-rename off
	${TMUX} rename-window -t $SESSION:0 $IRCNAME
	
	# keep window open and use respawn-window to restart
	# tmux set-window-option -t $SESSION:0 remain-on-exit on
	
	# all done. select starting window and get to work
	${TMUX} select-window -t ${SESSION}
	${TMUX} -2 attach -d -t ${SESSION}
	
	exit 0
}

[ "${BASH_SOURCE}" == "$0" ] && tmuxfoo
