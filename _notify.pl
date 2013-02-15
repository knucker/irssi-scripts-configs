##
## Put This in ~/.irssi/scriptsi/autorun/:
## Execute into irssi:
##	/load perl
##	/script load _notify.pl
##
## Requisites:
##	pkg: notification_daemon
##	hilight <nick>
######
##	by Knucker
##

use strict;
use Irssi;
use vars qw($VERSION %IRSSI);
use HTML::Entities;

$VERSION = "0.1";
%IRSSI = (
	authors     => 'Knucker Blind',
	contact     => 'www.knucker@gmail.com',
	name        => '_notify.pl',
	description => 'Use libnotify to alert user to hilighted and private messages',
	license     => 'GNU General Public License',
	url         => '',
);

## User need to modify this field with the FULL directory:
my $PATH_TO = '/home/knucker/.irssi/'

Irssi::settings_add_str('notify', 'private_icon', "$PATH_TO/chat-private-notify.png"); # Path to some image
Irssi::settings_add_str('notify', 'user_icon', "$PATH_TO/chat-user-notify.png"); # Path to some image
Irssi::settings_add_str('notify', 'notify_time', '5000');

sub notify {
	my ($server, $summary, $message) = @_;
	# Make the message entity-safe
	$message =~ s/\\/\|/g;
	my $cmd = "EXEC - notify-send" .
	" -i " . Irssi::settings_get_str('private_icon') .
	" -t " . Irssi::settings_get_str('notify_time') .
	" '" . $summary . "'" .
	" '" . $message . "'";
	$server->command($cmd);
	my $cmd_pin = "EXEC - mplayer $PATH_TO/pin_dropping.mp3 2&> /dev/null"; # Path to some sound
	$server->command($cmd_pin);
}

sub notifyUser {
	my ($server, $summary, $message) = @_;
	# Make the message entity-safe
	$message =~ s/\\/\|/g;
	my $cmd = "EXEC - notify-send" .
	" -i " . Irssi::settings_get_str('user_icon') .
	" -t " . Irssi::settings_get_str('notify_time') .
	" '" . $summary . "'" .
	" '" . $message . "'";
	$server->command($cmd);
	my $cmd_pin = "EXEC - mplayer $PATH_TO/pin_dropping.mp3 2&> /dev/null"; # Path to some sound
	$server->command($cmd_pin);
}

sub user_notify {
	my ($dest, $text, $stripped) = @_;
	my $server = $dest->{server};
	return if (!$server || !($dest->{level} & MSGLEVEL_HILIGHT));
	# Get Nick who is sent the message
	my $index = index($stripped, '│'); # The simbol to be stripped depends of the theme
	my $nick = substr $stripped, 0, $index;
	my $msg = substr $stripped, $index+3;
	$msg = encode_entities($msg);
	# Clean whitespaces on the beginning and the end of the nick and message
	$nick =~ s/^[ ]+|[ ]+$//gi;
	$msg  =~ s/^[ ]+|[ ]+$//gi;

	notifyUser($server, "In ".$dest->{target}." message from ".$nick, $msg ); # $stripped);
}


sub private_notify {
	my ($server, $msg, $nick, $address) = @_;
	return if (!$server);
	$msg = encode_entities($msg);
	notify($server, "Private message from ".$nick, $msg);
}

Irssi::signal_add('print text', 'user_notify');
Irssi::signal_add('message private', 'private_notify');
