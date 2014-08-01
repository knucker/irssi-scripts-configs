##
## Put This in ~/.irssi/scriptsi/autorun/:
## Execute into irssi:
##	/load perl
##	/script load _notify.pl
##
## Requisites:
##	pkg: dunst (recommended: dunstify)
##		 libnotify
##	hilight <nick>
######
##	by Knucker
##

use strict;
use Irssi;
use vars qw($VERSION %IRSSI);
use HTML::Entities;

$VERSION = "0.2";
%IRSSI = (
	authors     => 'Knucker Blind',
	contact     => 'www.knucker [at] gmail.com',
	name        => '_notify.pl',
	description => 'Use libnotify to alert user to hilighted and private messages',
	license     => 'GNU General Public License',
	url         => '',
);

##
my $PATH_TO = "$ENV{HOME}/.irssi/";

Irssi::settings_add_str('notify', 'private_icon',"$PATH_TO/chat-private-notify.png");
Irssi::settings_add_str('notify', 'user_icon', "$PATH_TO/chat-user-notify.png");
Irssi::settings_add_str('notify', 'notify_time', '5000');

sub sanitize {
	my ($text) = @_;
	encode_entities($text,'\'<>&');
	my $apos = "&#39;";
	my $aposenc = "\&apos;";
	$text =~ s/$apos/$aposenc/g;
	$text =~ s/"/\\"/g;
	$text =~ s/\$/\\\$/g;
	$text =~ s/`/\\"/g;
	return $text;
}

sub notify {
	my ($server, $summary, $message, $who) = @_;
	$who = $who . '_icon';

	# Clean whitespaces on the beginning and the end of the message
	$message =~ s/^[ ]+|[ ]+$//gi;
	$message =~ s/[ ]+/ /gi;

	# Make the message entity-safe
	$message = sanitize( $message );
	$summary = sanitize( $summary );

	# my $notify = "dunstify";
	my $notify = "notify-send";
	my $appname = "irssi";
	my $cmd = "EXEC - " . $notify .
	" -a " . $appname .
	" -i " . Irssi::settings_get_str( $who ) .
	" '" . $summary . "'".
	" '" . $message . "'";
	$server->command($cmd);

	my $cmd_pin = "EXEC - mplayer $PATH_TO/pin_dropping.mp3 &> /dev/null";
	$server->command($cmd_pin);
}

sub user_notify {
	my ($dest, $text, $stripped) = @_;
	my $server = $dest->{server};

	return if (!$server || !($dest->{level} & MSGLEVEL_HILIGHT));

	print( "Text: " . $text );
	print( "Stripped: " . $stripped );

	# Get Nick who is sent the message
	my $nick = $stripped;
	my $msg = $stripped;

	$nick =~ s/^\<([^\>]+)\>.+/\1/;
	$msg =~ s/^\<[^\>]+\>//;

	# Clean whitespaces on the beginning and the end of the nick and message
	$nick =~ s/^[ ]+|[ ]+$//gi;

	notify($server, "In ".$dest->{target}." message from ".$nick, $msg, 'user'); # $stripped);
}

sub private_notify {
	my ($server, $msg, $nick, $address) = @_;
	return if (!$server);

	# Clean whitespaces on the beginning and the end of the nick and message
	$nick =~ s/^[ ]+|[ ]+$//gi;

	notify($server, "Private message from ".$nick, $msg, 'private');
}

Irssi::signal_add('print text', 'user_notify');
Irssi::signal_add('message private', 'private_notify');
