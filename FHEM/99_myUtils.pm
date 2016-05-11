##############################################
# $Id: myUtilsTemplate.pm 7570 2015-01-14 18:31:44Z rudolfkoenig $
#
# Save this file as 99_myUtils.pm, and create your own functions in the new
# file. They are then available in every Perl expression.

package main;

use strict;
use warnings;
use POSIX;

sub
myUtils_Initialize($$)
{
  my ($hash) = @_;
}

# Enter you functions below _this_ line.
use HTML::Entities;

sub
wrapLine($$)
{
  my ($string, $maxLength) = @_;
  $string = decode_entities($string);
	my @stringParts = split(/ /, $string);
  my $actRowLength = 0;
  my $resultString = '';
  while (scalar(@stringParts) > 0) {
  	my $tempString = shift @stringParts;
    if ($actRowLength > 0)
    {
    	if (($actRowLength + length($tempString)) > $maxLength)
      {
      	$actRowLength = 0;
        $resultString .= '<br>';
      }
    }
    $resultString .= $tempString;
    $actRowLength += length($tempString);
    if (scalar(@stringParts) > 0)
    {
	    $resultString .= ' ';
  	  $actRowLength += 1;
    }
  }
  if ($resultString eq '')
  {
  	return ' ';
  }
  else
  {
	  return $resultString;
  }
}

###################################################
###     Spritpreisübersicht - Farbsortierung    ###
###################################################

sub Werte($$) {
  my ($name, $wert) = @_;
# Log(3,"$name $wert");
  if ($name eq "Diesel") {
    return 'style="color:red"' if($wert >= 1.39); 
    return 'style="color:blue"' if(($wert >= 1.11) && ($wert < 1.39));
    return 'style="color:green;;font-weight:bold"' if($wert <= 1.10);
  }elsif ($name eq "SuperE10") {
    return 'style="color:crimson"' if($wert >= 1.70); 
    return 'style="color:yellow"' if(($wert >= 1.55) && ($wert < 1.70));
    return 'style="color:lightgreen;;font-weight:bold"' if($wert < 1.55);
  }elsif ($name eq "SuperE5") {
    return 'style="color:red"' if($wert >= 1.55); 
    return 'style="color:blue"' if(($wert >= 1.25) && ($wert < 1.55));
    return 'style="color:green;;font-weight:bold"' if($wert <= 1.25);
  }  
}


######## Get OMDB Rating ############
use XML::Simple;
use LWP::Simple;

sub
OMDBRating
{ 
 my $filmname = shift;
 my $contents = get("http://www.omdbapi.com/?t=$filmname&y=&plot=short&r=xml");
 my $p1 = new XML::Simple;
 my $data = $p1->XMLin($contents);
 return "$filmname ($data->{movie}->{imdbRating})";
}

# setzt einen gpio am ESPEasy Kontroller
sub esppinstate
{
my $espdev = $_[0];
my $gpio = $_[1];
my $event = $_[2];
my $ret = "";
$ret .=  system("wget -q -O /dev/null 'http://$espdev/control?cmd=GPIO,$gpio,$event'");
$ret =~ s,[r
]*,,g;
Log 1, "esp $espdev returned: $ret";
}

1;
