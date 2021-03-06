#!/usr/bin/perl
# 
# gpx2android.pl
# Use/modify/sell/whatever without permission of author allowed
#
use strict; use warnings;
no strict 'refs';
use Net::Telnet ();

# use module
use FileHandle; # not needed, fixes: http://markmail.org/message/6y7p472vrztfvo37
use XML::Simple;
use Data::Dumper;
use Date::Parse;
use Time::HiRes qw ( sleep usleep );
#~ use Geo::Formatter;

# Change host/port if u like
my $host = "localhost";
my $port =  5554;

################################################################
# Example gpx file from www.openstreetmap.org                  #
# http://www.openstreetmap.org/user/Kyle%20Gordon/traces/45097 #
################################################################
my $example = <<EOF
<?xml version="1.0" standalone="yes"?>
<gpx version="1.0" creator="OSMtracker" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="http://www.topografix.com/GPX/1/0" schemaLocation="http://www.topografix.com/GPX/1/0 http://www.topografix.com/GPX/1/0/gpx.xsd">
  <trk>
    <trkseg>
      <trkpt lat="55.85885000" lon="-4.27475200">
        <ele>63.5</ele>
        <time>2007-10-16T15:36.01Z</time>
      </trkpt>
      <trkpt lat="55.85889000" lon="-4.27473200">
        <ele>56.8</ele>
        <time>2007-10-16T15:36.07Z</time>
      </trkpt>
      <trkpt lat="55.85891000" lon="-4.27467500">
        <ele>57.4</ele>
        <time>2007-10-16T15:37.01Z</time>
      </trkpt>
      <trkpt lat="55.85899000" lon="-4.27463300">
        <ele>57.5</ele>
        <time>2007-10-16T15:37.04Z</time>
      </trkpt>
      <trkpt lat="55.85909000" lon="-4.27460200">
        <ele>58.4</ele>
        <time>2007-10-16T15:37.06Z</time>
      </trkpt>
      <trkpt lat="55.85923000" lon="-4.27458000">
        <ele>58.0</ele>
        <time>2007-10-16T15:37.08Z</time>
      </trkpt>
      <trkpt lat="55.85939000" lon="-4.27456700">
        <ele>58.7</ele>
        <time>2007-10-16T15:37.10Z</time>
      </trkpt>
      <trkpt lat="55.85954000" lon="-4.27457000">
        <ele>58.8</ele>
        <time>2007-10-16T15:37.12Z</time>
      </trkpt>
      <trkpt lat="55.85968000" lon="-4.27458000">
        <ele>59.0</ele>
        <time>2007-10-16T15:37.14Z</time>
      </trkpt>
      <trkpt lat="55.85980000" lon="-4.27459500">
        <ele>59.6</ele>
        <time>2007-10-16T15:37.16Z</time>
      </trkpt>
      <trkpt lat="55.85987000" lon="-4.27463000">
        <ele>60.7</ele>
        <time>2007-10-16T15:37.18Z</time>
      </trkpt>
      <trkpt lat="55.85985000" lon="-4.27470200">
        <ele>62.1</ele>
        <time>2007-10-16T15:37.20Z</time>
      </trkpt>
      <trkpt lat="55.85979000" lon="-4.27474700">
        <ele>62.6</ele>
        <time>2007-10-16T15:37.22Z</time>
      </trkpt>
      <trkpt lat="55.85990000" lon="-4.27461800">
        <ele>62.7</ele>
        <time>2007-10-16T15:37.24Z</time>
      </trkpt>
      <trkpt lat="55.86022000" lon="-4.27415500">
        <ele>62.6</ele>
        <time>2007-10-16T15:37.26Z</time>
      </trkpt>
      <trkpt lat="55.86021000" lon="-4.27391800">
        <ele>62.3</ele>
        <time>2007-10-16T15:37.28Z</time>
      </trkpt>
      <trkpt lat="55.86020000" lon="-4.27366700">
        <ele>62.2</ele>
        <time>2007-10-16T15:37.33Z</time>
      </trkpt>
      <trkpt lat="55.86001000" lon="-4.27292800">
        <ele>62.2</ele>
        <time>2007-10-16T15:37.36Z</time>
      </trkpt>
      <trkpt lat="55.85994000" lon="-4.27282500">
        <ele>62.2</ele>
        <time>2007-10-16T15:37.38Z</time>
      </trkpt>
      <trkpt lat="55.85983000" lon="-4.27280700">
        <ele>63.4</ele>
        <time>2007-10-16T15:37.40Z</time>
      </trkpt>
      <trkpt lat="55.85967000" lon="-4.27284700">
        <ele>63.4</ele>
        <time>2007-10-16T15:37.42Z</time>
      </trkpt>
      <trkpt lat="55.85952000" lon="-4.27287800">
        <ele>63.4</ele>
        <time>2007-10-16T15:37.44Z</time>
      </trkpt>
      <trkpt lat="55.85939000" lon="-4.27290000">
        <ele>63.2</ele>
        <time>2007-10-16T15:37.46Z</time>
      </trkpt>
      <trkpt lat="55.85928000" lon="-4.27289300">
        <ele>60.6</ele>
        <time>2007-10-16T15:37.48Z</time>
      </trkpt>
      <trkpt lat="55.85918000" lon="-4.27284000">
        <ele>60.3</ele>
        <time>2007-10-16T15:37.50Z</time>
      </trkpt>
      <trkpt lat="55.85912000" lon="-4.27287700">
        <ele>63.0</ele>
        <time>2007-10-16T15:37.52Z</time>
      </trkpt>
      <trkpt lat="55.85910000" lon="-4.27295800">
        <ele>64.1</ele>
        <time>2007-10-16T15:37.54Z</time>
      </trkpt>
      <trkpt lat="55.85910000" lon="-4.27297400">
        <ele>65.2</ele>
        <time>2007-10-16T15:37.56Z</time>
      </trkpt>
      <trkpt lat="55.85910000" lon="-4.27292500">
        <ele>66.3</ele>
        <time>2007-10-16T15:37.58Z</time>
      </trkpt>
      <trkpt lat="55.85910000" lon="-4.27291000">
        <ele>66.4</ele>
        <time>2007-10-16T15:38.00Z</time>
      </trkpt>
      <trkpt lat="55.85985000" lon="-4.27286300">
        <ele>87.4</ele>
        <time>2007-10-16T15:38.10Z</time>
      </trkpt>
      <trkpt lat="55.85995000" lon="-4.27298200">
        <ele>76.2</ele>
        <time>2007-10-16T15:38.12Z</time>
      </trkpt>
      <trkpt lat="55.86005000" lon="-4.27322000">
        <ele>76.7</ele>
        <time>2007-10-16T15:38.14Z</time>
      </trkpt>
      <trkpt lat="55.86010000" lon="-4.27354800">
        <ele>78.8</ele>
        <time>2007-10-16T15:38.16Z</time>
      </trkpt>
      <trkpt lat="55.86011000" lon="-4.27390300">
        <ele>77.9</ele>
        <time>2007-10-16T15:38.18Z</time>
      </trkpt>
      <trkpt lat="55.86010000" lon="-4.27419700">
        <ele>76.7</ele>
        <time>2007-10-16T15:38.20Z</time>
      </trkpt>
      <trkpt lat="55.86009000" lon="-4.27437800">
        <ele>73.0</ele>
        <time>2007-10-16T15:38.22Z</time>
      </trkpt>
      <trkpt lat="55.86008000" lon="-4.27454900">
        <ele>74.6</ele>
        <time>2007-10-16T15:38.24Z</time>
      </trkpt>
      <trkpt lat="55.86010000" lon="-4.27484300">
        <ele>76.8</ele>
        <time>2007-10-16T15:38.26Z</time>
      </trkpt>
      <trkpt lat="55.86012000" lon="-4.27521300">
        <ele>77.4</ele>
        <time>2007-10-16T15:38.28Z</time>
      </trkpt>
      <trkpt lat="55.86010000" lon="-4.27574300">
        <ele>74.9</ele>
        <time>2007-10-16T15:38.30Z</time>
      </trkpt>
      <trkpt lat="55.86009000" lon="-4.27605200">
        <ele>74.2</ele>
        <time>2007-10-16T15:38.32Z</time>
      </trkpt>
      <trkpt lat="55.86008000" lon="-4.27630200">
        <ele>74.9</ele>
        <time>2007-10-16T15:38.34Z</time>
      </trkpt>
      <trkpt lat="55.86001000" lon="-4.27647500">
        <ele>74.2</ele>
        <time>2007-10-16T15:38.36Z</time>
      </trkpt>
      <trkpt lat="55.85986000" lon="-4.27649800">
        <ele>47.6</ele>
        <time>2007-10-16T15:38.38Z</time>
      </trkpt>
      <trkpt lat="55.85955000" lon="-4.27656200">
        <ele>52.5</ele>
        <time>2007-10-16T15:38.40Z</time>
      </trkpt>
      <trkpt lat="55.85929000" lon="-4.27656500">
        <ele>54.7</ele>
        <time>2007-10-16T15:38.42Z</time>
      </trkpt>
      <trkpt lat="55.85899000" lon="-4.27658800">
        <ele>58.8</ele>
        <time>2007-10-16T15:38.44Z</time>
      </trkpt>
      <trkpt lat="55.85868000" lon="-4.27660200">
        <ele>59.1</ele>
        <time>2007-10-16T15:38.46Z</time>
      </trkpt>
      <trkpt lat="55.85817000" lon="-4.27660700">
        <ele>63.7</ele>
        <time>2007-10-16T15:38.50Z</time>
      </trkpt>
      <trkpt lat="55.85783000" lon="-4.27668700">
        <ele>57.5</ele>
        <time>2007-10-16T15:38.52Z</time>
      </trkpt>
      <trkpt lat="55.85764000" lon="-4.27669800">
        <ele>55.2</ele>
        <time>2007-10-16T15:38.54Z</time>
      </trkpt>
      <trkpt lat="55.85747000" lon="-4.27670800">
        <ele>54.9</ele>
        <time>2007-10-16T15:38.56Z</time>
      </trkpt>
      <trkpt lat="55.85735000" lon="-4.27669200">
        <ele>54.9</ele>
        <time>2007-10-16T15:38.58Z</time>
      </trkpt>
      <trkpt lat="55.85728000" lon="-4.27669000">
        <ele>54.8</ele>
        <time>2007-10-16T15:39.00Z</time>
      </trkpt>
      <trkpt lat="55.85725000" lon="-4.27671700">
        <ele>56.9</ele>
        <time>2007-10-16T15:39.02Z</time>
      </trkpt>
      <trkpt lat="55.85723000" lon="-4.27671700">
        <ele>57.0</ele>
        <time>2007-10-16T15:39.04Z</time>
      </trkpt>
      <trkpt lat="55.85721000" lon="-4.27684200">
        <ele>61.7</ele>
        <time>2007-10-16T15:39.06Z</time>
      </trkpt>
      <trkpt lat="55.85717000" lon="-4.27713300">
        <ele>64.8</ele>
        <time>2007-10-16T15:39.08Z</time>
      </trkpt>
      <trkpt lat="55.85719000" lon="-4.27747800">
        <ele>66.1</ele>
        <time>2007-10-16T15:39.10Z</time>
      </trkpt>
      <trkpt lat="55.85723000" lon="-4.27784200">
        <ele>67.4</ele>
        <time>2007-10-16T15:39.12Z</time>
      </trkpt>
      <trkpt lat="55.85727000" lon="-4.27817500">
        <ele>64.8</ele>
        <time>2007-10-16T15:39.14Z</time>
      </trkpt>
      <trkpt lat="55.85731000" lon="-4.27848500">
        <ele>63.7</ele>
        <time>2007-10-16T15:39.16Z</time>
      </trkpt>
      <trkpt lat="55.85734000" lon="-4.27867500">
        <ele>65.1</ele>
        <time>2007-10-16T15:39.18Z</time>
      </trkpt>
      <trkpt lat="55.85736000" lon="-4.27874200">
        <ele>65.2</ele>
        <time>2007-10-16T15:39.20Z</time>
      </trkpt>
      <trkpt lat="55.85736000" lon="-4.27882300">
        <ele>64.6</ele>
        <time>2007-10-16T15:39.22Z</time>
      </trkpt>
      <trkpt lat="55.85738000" lon="-4.27894500">
        <ele>64.0</ele>
        <time>2007-10-16T15:39.24Z</time>
      </trkpt>
      <trkpt lat="55.85741000" lon="-4.27913500">
        <ele>63.8</ele>
        <time>2007-10-16T15:39.26Z</time>
      </trkpt>
      <trkpt lat="55.85745000" lon="-4.27933300">
        <ele>64.0</ele>
        <time>2007-10-16T15:39.28Z</time>
      </trkpt>
      <trkpt lat="55.85750000" lon="-4.27957800">
        <ele>65.0</ele>
        <time>2007-10-16T15:39.30Z</time>
      </trkpt>
      <trkpt lat="55.85755000" lon="-4.27991300">
        <ele>64.1</ele>
        <time>2007-10-16T15:39.32Z</time>
      </trkpt>
      <trkpt lat="55.85759000" lon="-4.28023800">
        <ele>63.4</ele>
        <time>2007-10-16T15:39.34Z</time>
      </trkpt>
      <trkpt lat="55.85764000" lon="-4.28053700">
        <ele>63.3</ele>
        <time>2007-10-16T15:39.36Z</time>
      </trkpt>
      <trkpt lat="55.85770000" lon="-4.28085900">
        <ele>63.4</ele>
        <time>2007-10-16T15:39.38Z</time>
      </trkpt>
      <trkpt lat="55.85775000" lon="-4.28115200">
        <ele>62.9</ele>
        <time>2007-10-16T15:39.40Z</time>
      </trkpt>
      <trkpt lat="55.85778000" lon="-4.28141800">
        <ele>62.6</ele>
        <time>2007-10-16T15:39.42Z</time>
      </trkpt>
      <trkpt lat="55.85781000" lon="-4.28160800">
        <ele>64.3</ele>
        <time>2007-10-16T15:39.44Z</time>
      </trkpt>
      <trkpt lat="55.85780000" lon="-4.28174400">
        <ele>67.0</ele>
        <time>2007-10-16T15:39.46Z</time>
      </trkpt>
      <trkpt lat="55.85761000" lon="-4.28195000">
        <ele>63.8</ele>
        <time>2007-10-16T15:39.48Z</time>
      </trkpt>
      <trkpt lat="55.85742000" lon="-4.28222500">
        <ele>64.1</ele>
        <time>2007-10-16T15:39.50Z</time>
      </trkpt>
      <trkpt lat="55.85727000" lon="-4.28254200">
        <ele>66.3</ele>
        <time>2007-10-16T15:39.52Z</time>
      </trkpt>
      <trkpt lat="55.85713000" lon="-4.28287000">
        <ele>67.4</ele>
        <time>2007-10-16T15:39.54Z</time>
      </trkpt>
      <trkpt lat="55.85693000" lon="-4.28330700">
        <ele>66.6</ele>
        <time>2007-10-16T15:39.56Z</time>
      </trkpt>
      <trkpt lat="55.85672000" lon="-4.28380500">
        <ele>66.4</ele>
        <time>2007-10-16T15:40.02Z</time>
      </trkpt>
      <trkpt lat="55.85628000" lon="-4.28474000">
        <ele>65.5</ele>
        <time>2007-10-16T15:40.11Z</time>
      </trkpt>
      <trkpt lat="55.85636000" lon="-4.28657000">
        <ele>64.6</ele>
        <time>2007-10-16T15:40.14Z</time>
      </trkpt>
      <trkpt lat="55.85639000" lon="-4.28670300">
        <ele>65.2</ele>
        <time>2007-10-16T15:40.16Z</time>
      </trkpt>
      <trkpt lat="55.85640000" lon="-4.28678000">
        <ele>66.4</ele>
        <time>2007-10-16T15:40.18Z</time>
      </trkpt>
      <trkpt lat="55.85640000" lon="-4.28681000">
        <ele>66.5</ele>
        <time>2007-10-16T15:40.20Z</time>
      </trkpt>
      <trkpt lat="55.85641000" lon="-4.28684700">
        <ele>65.1</ele>
        <time>2007-10-16T15:40.50Z</time>
      </trkpt>
      <trkpt lat="55.85645000" lon="-4.28706300">
        <ele>67.4</ele>
        <time>2007-10-16T15:40.52Z</time>
      </trkpt>
      <trkpt lat="55.85650000" lon="-4.28732800">
        <ele>69.1</ele>
        <time>2007-10-16T15:40.54Z</time>
      </trkpt>
      <trkpt lat="55.85657000" lon="-4.28770400">
        <ele>70.6</ele>
        <time>2007-10-16T15:40.56Z</time>
      </trkpt>
      <trkpt lat="55.85660000" lon="-4.28788900">
        <ele>70.6</ele>
        <time>2007-10-16T15:40.58Z</time>
      </trkpt>
      <trkpt lat="55.85669000" lon="-4.28852200">
        <ele>71.7</ele>
        <time>2007-10-16T15:41.00Z</time>
      </trkpt>
      <trkpt lat="55.85675000" lon="-4.28896800">
        <ele>69.5</ele>
        <time>2007-10-16T15:41.02Z</time>
      </trkpt>
      <trkpt lat="55.85679000" lon="-4.28942300">
        <ele>67.8</ele>
        <time>2007-10-16T15:41.04Z</time>
      </trkpt>
      <trkpt lat="55.85682000" lon="-4.28987500">
        <ele>68.8</ele>
        <time>2007-10-16T15:41.13Z</time>
      </trkpt>
      <trkpt lat="55.85668000" lon="-4.29153500">
        <ele>70.1</ele>
        <time>2007-10-16T15:41.14Z</time>
      </trkpt>
      <trkpt lat="55.85659000" lon="-4.29187500">
        <ele>68.5</ele>
        <time>2007-10-16T15:41.16Z</time>
      </trkpt>
      <trkpt lat="55.85649000" lon="-4.29217800">
        <ele>66.1</ele>
        <time>2007-10-16T15:41.18Z</time>
      </trkpt>
      <trkpt lat="55.85639000" lon="-4.29243700">
        <ele>66.0</ele>
        <time>2007-10-16T15:41.20Z</time>
      </trkpt>
      <trkpt lat="55.85623000" lon="-4.29272700">
        <ele>61.7</ele>
        <time>2007-10-16T15:41.22Z</time>
      </trkpt>
      <trkpt lat="55.85612000" lon="-4.29304500">
        <ele>60.5</ele>
        <time>2007-10-16T15:41.24Z</time>
      </trkpt>
      <trkpt lat="55.85605000" lon="-4.29333700">
        <ele>63.9</ele>
        <time>2007-10-16T15:41.26Z</time>
      </trkpt>
      <trkpt lat="55.85590000" lon="-4.29368400">
        <ele>61.7</ele>
        <time>2007-10-16T15:41.28Z</time>
      </trkpt>
      <trkpt lat="55.85572000" lon="-4.29408700">
        <ele>60.0</ele>
        <time>2007-10-16T15:41.30Z</time>
      </trkpt>
      <trkpt lat="55.85555000" lon="-4.29450000">
        <ele>61.3</ele>
        <time>2007-10-16T15:41.32Z</time>
      </trkpt>
      <trkpt lat="55.85541000" lon="-4.29490700">
        <ele>62.9</ele>
        <time>2007-10-16T15:41.34Z</time>
      </trkpt>
      <trkpt lat="55.85531000" lon="-4.29530500">
        <ele>66.3</ele>
        <time>2007-10-16T15:41.36Z</time>
      </trkpt>
      <trkpt lat="55.85524000" lon="-4.29568000">
        <ele>63.0</ele>
        <time>2007-10-16T15:41.42Z</time>
      </trkpt>
      <trkpt lat="55.85522000" lon="-4.29583300">
        <ele>65.2</ele>
        <time>2007-10-16T15:41.42Z</time>
      </trkpt>
      <trkpt lat="55.85519000" lon="-4.29674300">
        <ele>70.5</ele>
        <time>2007-10-16T15:41.44Z</time>
      </trkpt>
      <trkpt lat="55.85520000" lon="-4.29719500">
        <ele>68.0</ele>
        <time>2007-10-16T15:41.46Z</time>
      </trkpt>
      <trkpt lat="55.85522000" lon="-4.29743500">
        <ele>67.9</ele>
        <time>2007-10-16T15:41.48Z</time>
      </trkpt>
      <trkpt lat="55.85534000" lon="-4.29816500">
        <ele>67.2</ele>
        <time>2007-10-16T15:41.50Z</time>
      </trkpt>
      <trkpt lat="55.85543000" lon="-4.29862700">
        <ele>67.3</ele>
        <time>2007-10-16T15:41.52Z</time>
      </trkpt>
      <trkpt lat="55.85553000" lon="-4.29907500">
        <ele>70.2</ele>
        <time>2007-10-16T15:41.54Z</time>
      </trkpt>
      <trkpt lat="55.85562000" lon="-4.29942700">
        <ele>69.7</ele>
        <time>2007-10-16T15:41.56Z</time>
      </trkpt>
      <trkpt lat="55.85571000" lon="-4.29968200">
        <ele>70.4</ele>
        <time>2007-10-16T15:41.58Z</time>
      </trkpt>
      <trkpt lat="55.85573000" lon="-4.29987000">
        <ele>69.8</ele>
        <time>2007-10-16T15:42.00Z</time>
      </trkpt>
      <trkpt lat="55.85566000" lon="-4.29998400">
        <ele>74.8</ele>
        <time>2007-10-16T15:42.02Z</time>
      </trkpt>
      <trkpt lat="55.85532000" lon="-4.30009700">
        <ele>80.3</ele>
        <time>2007-10-16T15:42.04Z</time>
      </trkpt>
      <trkpt lat="55.85506000" lon="-4.30019800">
        <ele>82.1</ele>
        <time>2007-10-16T15:42.06Z</time>
      </trkpt>
      <trkpt lat="55.85479000" lon="-4.30029300">
        <ele>82.1</ele>
        <time>2007-10-16T15:42.08Z</time>
      </trkpt>
      <trkpt lat="55.85452000" lon="-4.30039500">
        <ele>80.7</ele>
        <time>2007-10-16T15:42.10Z</time>
      </trkpt>
      <trkpt lat="55.85425000" lon="-4.30048000">
        <ele>80.1</ele>
        <time>2007-10-16T15:42.12Z</time>
      </trkpt>
      <trkpt lat="55.85395000" lon="-4.30058000">
        <ele>73.1</ele>
        <time>2007-10-16T15:42.14Z</time>
      </trkpt>
      <trkpt lat="55.85368000" lon="-4.30068200">
        <ele>71.4</ele>
        <time>2007-10-16T15:42.16Z</time>
      </trkpt>
      <trkpt lat="55.85344000" lon="-4.30078200">
        <ele>69.7</ele>
        <time>2007-10-16T15:42.18Z</time>
      </trkpt>
      <trkpt lat="55.85321000" lon="-4.30085800">
        <ele>69.6</ele>
        <time>2007-10-16T15:42.20Z</time>
      </trkpt>
      <trkpt lat="55.85302000" lon="-4.30090200">
        <ele>64.1</ele>
        <time>2007-10-16T15:42.22Z</time>
      </trkpt>
      <trkpt lat="55.85292000" lon="-4.30093800">
        <ele>60.5</ele>
        <time>2007-10-16T15:42.24Z</time>
      </trkpt>
      <trkpt lat="55.85286000" lon="-4.30102200">
        <ele>59.5</ele>
        <time>2007-10-16T15:42.26Z</time>
      </trkpt>
      <trkpt lat="55.85287000" lon="-4.30128500">
        <ele>61.4</ele>
        <time>2007-10-16T15:42.28Z</time>
      </trkpt>
      <trkpt lat="55.85295000" lon="-4.30164100">
        <ele>61.8</ele>
        <time>2007-10-16T15:42.30Z</time>
      </trkpt>
      <trkpt lat="55.85305000" lon="-4.30206000">
        <ele>63.6</ele>
        <time>2007-10-16T15:42.32Z</time>
      </trkpt>
      <trkpt lat="55.85315000" lon="-4.30252500">
        <ele>63.1</ele>
        <time>2007-10-16T15:42.34Z</time>
      </trkpt>
      <trkpt lat="55.85325000" lon="-4.30300800">
        <ele>63.7</ele>
        <time>2007-10-16T15:42.36Z</time>
      </trkpt>
      <trkpt lat="55.85335000" lon="-4.30349500">
        <ele>64.0</ele>
        <time>2007-10-16T15:42.38Z</time>
      </trkpt>
      <trkpt lat="55.85344000" lon="-4.30395800">
        <ele>64.6</ele>
        <time>2007-10-16T15:42.40Z</time>
      </trkpt>
      <trkpt lat="55.85352000" lon="-4.30438300">
        <ele>65.1</ele>
        <time>2007-10-16T15:42.42Z</time>
      </trkpt>
      <trkpt lat="55.85359000" lon="-4.30472000">
        <ele>68.2</ele>
        <time>2007-10-16T15:42.44Z</time>
      </trkpt>
      <trkpt lat="55.85363000" lon="-4.30488000">
        <ele>69.6</ele>
        <time>2007-10-16T15:42.46Z</time>
      </trkpt>
      <trkpt lat="55.85361000" lon="-4.30489500">
        <ele>67.0</ele>
        <time>2007-10-16T15:42.48Z</time>
      </trkpt>
      <trkpt lat="55.85359000" lon="-4.30498000">
        <ele>69.3</ele>
        <time>2007-10-16T15:42.50Z</time>
      </trkpt>
      <trkpt lat="55.85352000" lon="-4.30508000">
        <ele>71.0</ele>
        <time>2007-10-16T15:42.52Z</time>
      </trkpt>
      <trkpt lat="55.85339000" lon="-4.30518500">
        <ele>74.8</ele>
        <time>2007-10-16T15:42.54Z</time>
      </trkpt>
      <trkpt lat="55.85319000" lon="-4.30542000">
        <ele>77.1</ele>
        <time>2007-10-16T15:42.56Z</time>
      </trkpt>
      <trkpt lat="55.85299000" lon="-4.30561000">
        <ele>72.1</ele>
        <time>2007-10-16T15:42.58Z</time>
      </trkpt>
      <trkpt lat="55.85280000" lon="-4.30576500">
        <ele>70.5</ele>
        <time>2007-10-16T15:43.00Z</time>
      </trkpt>
      <trkpt lat="55.85263000" lon="-4.30588500">
        <ele>68.5</ele>
        <time>2007-10-16T15:43.02Z</time>
      </trkpt>
      <trkpt lat="55.85250000" lon="-4.30596200">
        <ele>68.6</ele>
        <time>2007-10-16T15:43.04Z</time>
      </trkpt>
      <trkpt lat="55.85240000" lon="-4.30603200">
        <ele>68.5</ele>
        <time>2007-10-16T15:43.06Z</time>
      </trkpt>
      <trkpt lat="55.85236000" lon="-4.30608300">
        <ele>68.2</ele>
        <time>2007-10-16T15:43.08Z</time>
      </trkpt>
      <trkpt lat="55.85236000" lon="-4.30609500">
        <ele>67.5</ele>
        <time>2007-10-16T15:43.10Z</time>
      </trkpt>
      <trkpt lat="55.85234000" lon="-4.30610200">
        <ele>67.4</ele>
        <time>2007-10-16T15:43.12Z</time>
      </trkpt>
      <trkpt lat="55.85233000" lon="-4.30611300">
        <ele>67.3</ele>
        <time>2007-10-16T15:43.14Z</time>
      </trkpt>
      <trkpt lat="55.85231000" lon="-4.30611300">
        <ele>67.7</ele>
        <time>2007-10-16T15:43.16Z</time>
      </trkpt>
      <trkpt lat="55.85227000" lon="-4.30610800">
        <ele>68.3</ele>
        <time>2007-10-16T15:43.18Z</time>
      </trkpt>
      <trkpt lat="55.85218000" lon="-4.30614500">
        <ele>67.8</ele>
        <time>2007-10-16T15:43.20Z</time>
      </trkpt>
      <trkpt lat="55.85195000" lon="-4.30632000">
        <ele>65.1</ele>
        <time>2007-10-16T15:43.22Z</time>
      </trkpt>
      <trkpt lat="55.85180000" lon="-4.30652200">
        <ele>64.2</ele>
        <time>2007-10-16T15:43.24Z</time>
      </trkpt>
      <trkpt lat="55.85178000" lon="-4.30665700">
        <ele>63.8</ele>
        <time>2007-10-16T15:43.31Z</time>
      </trkpt>
      <trkpt lat="55.85184000" lon="-4.30698300">
        <ele>77.8</ele>
        <time>2007-10-16T15:43.32Z</time>
      </trkpt>
      <trkpt lat="55.85210000" lon="-4.30835300">
        <ele>80.4</ele>
        <time>2007-10-16T15:43.34Z</time>
      </trkpt>
      <trkpt lat="55.85218000" lon="-4.30881000">
        <ele>78.2</ele>
        <time>2007-10-16T15:43.36Z</time>
      </trkpt>
      <trkpt lat="55.85221000" lon="-4.30904200">
        <ele>79.5</ele>
        <time>2007-10-16T15:43.38Z</time>
      </trkpt>
      <trkpt lat="55.85232000" lon="-4.30969700">
        <ele>78.4</ele>
        <time>2007-10-16T15:43.40Z</time>
      </trkpt>
      <trkpt lat="55.85239000" lon="-4.31012700">
        <ele>76.7</ele>
        <time>2007-10-16T15:43.42Z</time>
      </trkpt>
      <trkpt lat="55.85246000" lon="-4.31052800">
        <ele>76.5</ele>
        <time>2007-10-16T15:43.44Z</time>
      </trkpt>
      <trkpt lat="55.85251000" lon="-4.31089500">
        <ele>76.3</ele>
        <time>2007-10-16T15:43.46Z</time>
      </trkpt>
      <trkpt lat="55.85257000" lon="-4.31119500">
        <ele>77.0</ele>
        <time>2007-10-16T15:43.48Z</time>
      </trkpt>
      <trkpt lat="55.85261000" lon="-4.31141700">
        <ele>79.2</ele>
        <time>2007-10-16T15:43.50Z</time>
      </trkpt>
      <trkpt lat="55.85263000" lon="-4.31156500">
        <ele>79.8</ele>
        <time>2007-10-16T15:43.52Z</time>
      </trkpt>
      <trkpt lat="55.85265000" lon="-4.31164300">
        <ele>77.2</ele>
        <time>2007-10-16T15:43.54Z</time>
      </trkpt>
      <trkpt lat="55.85265000" lon="-4.31167300">
        <ele>77.3</ele>
        <time>2007-10-16T15:43.56Z</time>
      </trkpt>
      <trkpt lat="55.85266000" lon="-4.31170500">
        <ele>77.3</ele>
        <time>2007-10-16T15:44.12Z</time>
      </trkpt>
      <trkpt lat="55.85268000" lon="-4.31178200">
        <ele>76.6</ele>
        <time>2007-10-16T15:44.14Z</time>
      </trkpt>
      <trkpt lat="55.85270000" lon="-4.31182000">
        <ele>75.2</ele>
        <time>2007-10-16T15:44.16Z</time>
      </trkpt>
      <trkpt lat="55.85271000" lon="-4.31187200">
        <ele>74.1</ele>
        <time>2007-10-16T15:44.18Z</time>
      </trkpt>
      <trkpt lat="55.85273000" lon="-4.31192400">
        <ele>72.9</ele>
        <time>2007-10-16T15:44.20Z</time>
      </trkpt>
      <trkpt lat="55.85274000" lon="-4.31197800">
        <ele>74.0</ele>
        <time>2007-10-16T15:44.22Z</time>
      </trkpt>
      <trkpt lat="55.85275000" lon="-4.31202800">
        <ele>75.3</ele>
        <time>2007-10-16T15:44.24Z</time>
      </trkpt>
      <trkpt lat="55.85275000" lon="-4.31208500">
        <ele>74.1</ele>
        <time>2007-10-16T15:44.26Z</time>
      </trkpt>
      <trkpt lat="55.85276000" lon="-4.31212800">
        <ele>74.7</ele>
        <time>2007-10-16T15:44.28Z</time>
      </trkpt>
      <trkpt lat="55.85273000" lon="-4.31216700">
        <ele>74.7</ele>
        <time>2007-10-16T15:44.52Z</time>
      </trkpt>
      <trkpt lat="55.85273000" lon="-4.31219000">
        <ele>74.7</ele>
        <time>2007-10-16T15:44.54Z</time>
      </trkpt>
      <trkpt lat="55.85273000" lon="-4.31222500">
        <ele>73.4</ele>
        <time>2007-10-16T15:44.58Z</time>
      </trkpt>
      <trkpt lat="55.85268000" lon="-4.31233500">
        <ele>75.1</ele>
        <time>2007-10-16T15:45.00Z</time>
      </trkpt>
      <trkpt lat="55.85253000" lon="-4.31244900">
        <ele>72.7</ele>
        <time>2007-10-16T15:45.02Z</time>
      </trkpt>
      <trkpt lat="55.85233000" lon="-4.31239800">
        <ele>71.8</ele>
        <time>2007-10-16T15:45.04Z</time>
      </trkpt>
      <trkpt lat="55.85212000" lon="-4.31234200">
        <ele>71.4</ele>
        <time>2007-10-16T15:45.06Z</time>
      </trkpt>
      <trkpt lat="55.85191000" lon="-4.31226300">
        <ele>70.3</ele>
        <time>2007-10-16T15:45.08Z</time>
      </trkpt>
      <trkpt lat="55.85170000" lon="-4.31211900">
        <ele>72.4</ele>
        <time>2007-10-16T15:45.10Z</time>
      </trkpt>
      <trkpt lat="55.85148000" lon="-4.31201800">
        <ele>74.2</ele>
        <time>2007-10-16T15:45.12Z</time>
      </trkpt>
      <trkpt lat="55.85128000" lon="-4.31191500">
        <ele>74.8</ele>
        <time>2007-10-16T15:45.14Z</time>
      </trkpt>
      <trkpt lat="55.85109000" lon="-4.31181000">
        <ele>73.6</ele>
        <time>2007-10-16T15:45.16Z</time>
      </trkpt>
      <trkpt lat="55.85091000" lon="-4.31170200">
        <ele>74.2</ele>
        <time>2007-10-16T15:45.18Z</time>
      </trkpt>
      <trkpt lat="55.85073000" lon="-4.31158700">
        <ele>74.6</ele>
        <time>2007-10-16T15:45.20Z</time>
      </trkpt>
      <trkpt lat="55.85058000" lon="-4.31149100">
        <ele>76.9</ele>
        <time>2007-10-16T15:45.29Z</time>
      </trkpt>
      <trkpt lat="55.85027000" lon="-4.31134200">
        <ele>81.3</ele>
        <time>2007-10-16T15:45.30Z</time>
      </trkpt>
      <trkpt lat="55.85027000" lon="-4.31140300">
        <ele>71.6</ele>
        <time>2007-10-16T15:45.40Z</time>
      </trkpt>
      <trkpt lat="55.85025000" lon="-4.31136800">
        <ele>74.8</ele>
        <time>2007-10-16T15:45.58Z</time>
      </trkpt>
      <trkpt lat="55.85017000" lon="-4.31129600">
        <ele>78.7</ele>
        <time>2007-10-16T15:46.00Z</time>
      </trkpt>
      <trkpt lat="55.85007000" lon="-4.31121000">
        <ele>80.3</ele>
        <time>2007-10-16T15:46.02Z</time>
      </trkpt>
      <trkpt lat="55.84996000" lon="-4.31110200">
        <ele>81.4</ele>
        <time>2007-10-16T15:46.04Z</time>
      </trkpt>
      <trkpt lat="55.84983000" lon="-4.31098000">
        <ele>76.8</ele>
        <time>2007-10-16T15:46.06Z</time>
      </trkpt>
      <trkpt lat="55.84970000" lon="-4.31083300">
        <ele>74.5</ele>
        <time>2007-10-16T15:46.08Z</time>
      </trkpt>
      <trkpt lat="55.84953000" lon="-4.31064300">
        <ele>75.4</ele>
        <time>2007-10-16T15:46.10Z</time>
      </trkpt>
      <trkpt lat="55.84933000" lon="-4.31044300">
        <ele>76.1</ele>
        <time>2007-10-16T15:46.12Z</time>
      </trkpt>
      <trkpt lat="55.84917000" lon="-4.31025300">
        <ele>75.3</ele>
        <time>2007-10-16T15:46.14Z</time>
      </trkpt>
      <trkpt lat="55.84900000" lon="-4.31007100">
        <ele>76.5</ele>
        <time>2007-10-16T15:46.16Z</time>
      </trkpt>
      <trkpt lat="55.84885000" lon="-4.30990600">
        <ele>76.5</ele>
        <time>2007-10-16T15:46.18Z</time>
      </trkpt>
      <trkpt lat="55.84869000" lon="-4.30976300">
        <ele>73.9</ele>
        <time>2007-10-16T15:46.20Z</time>
      </trkpt>
      <trkpt lat="55.84850000" lon="-4.30961300">
        <ele>75.6</ele>
        <time>2007-10-16T15:46.22Z</time>
      </trkpt>
      <trkpt lat="55.84829000" lon="-4.30948500">
        <ele>77.3</ele>
        <time>2007-10-16T15:46.24Z</time>
      </trkpt>
      <trkpt lat="55.84806000" lon="-4.30941300">
        <ele>78.3</ele>
        <time>2007-10-16T15:46.26Z</time>
      </trkpt>
      <trkpt lat="55.84783000" lon="-4.30942300">
        <ele>79.4</ele>
        <time>2007-10-16T15:46.28Z</time>
      </trkpt>
      <trkpt lat="55.84762000" lon="-4.30954200">
        <ele>78.1</ele>
        <time>2007-10-16T15:46.30Z</time>
      </trkpt>
      <trkpt lat="55.84745000" lon="-4.30971000">
        <ele>79.3</ele>
        <time>2007-10-16T15:46.32Z</time>
      </trkpt>
      <trkpt lat="55.84728000" lon="-4.30985300">
        <ele>78.8</ele>
        <time>2007-10-16T15:46.34Z</time>
      </trkpt>
      <trkpt lat="55.84711000" lon="-4.31000700">
        <ele>78.5</ele>
        <time>2007-10-16T15:46.36Z</time>
      </trkpt>
      <trkpt lat="55.84696000" lon="-4.31013700">
        <ele>78.8</ele>
        <time>2007-10-16T15:46.38Z</time>
      </trkpt>
      <trkpt lat="55.84680000" lon="-4.31017800">
        <ele>79.0</ele>
        <time>2007-10-16T15:46.40Z</time>
      </trkpt>
      <trkpt lat="55.84663000" lon="-4.31015500">
        <ele>80.9</ele>
        <time>2007-10-16T15:46.42Z</time>
      </trkpt>
      <trkpt lat="55.84646000" lon="-4.31012300">
        <ele>83.0</ele>
        <time>2007-10-16T15:46.44Z</time>
      </trkpt>
      <trkpt lat="55.84631000" lon="-4.31009300">
        <ele>82.6</ele>
        <time>2007-10-16T15:46.46Z</time>
      </trkpt>
      <trkpt lat="55.84618000" lon="-4.31007300">
        <ele>83.2</ele>
        <time>2007-10-16T15:46.48Z</time>
      </trkpt>
      <trkpt lat="55.84606000" lon="-4.31002800">
        <ele>84.1</ele>
        <time>2007-10-16T15:46.50Z</time>
      </trkpt>
      <trkpt lat="55.84596000" lon="-4.30997700">
        <ele>87.9</ele>
        <time>2007-10-16T15:46.52Z</time>
      </trkpt>
      <trkpt lat="55.84588000" lon="-4.30995300">
        <ele>87.9</ele>
        <time>2007-10-16T15:46.54Z</time>
      </trkpt>
      <trkpt lat="55.84582000" lon="-4.30995200">
        <ele>88.0</ele>
        <time>2007-10-16T15:46.56Z</time>
      </trkpt>
      <trkpt lat="55.84575000" lon="-4.30992500">
        <ele>88.7</ele>
        <time>2007-10-16T15:46.58Z</time>
      </trkpt>
      <trkpt lat="55.84568000" lon="-4.30989200">
        <ele>90.1</ele>
        <time>2007-10-16T15:47.00Z</time>
      </trkpt>
      <trkpt lat="55.84558000" lon="-4.30986800">
        <ele>92.0</ele>
        <time>2007-10-16T15:47.02Z</time>
      </trkpt>
      <trkpt lat="55.84546000" lon="-4.30984700">
        <ele>94.1</ele>
        <time>2007-10-16T15:47.04Z</time>
      </trkpt>
      <trkpt lat="55.84527000" lon="-4.30979700">
        <ele>95.5</ele>
        <time>2007-10-16T15:47.06Z</time>
      </trkpt>
      <trkpt lat="55.84511000" lon="-4.30974700">
        <ele>96.1</ele>
        <time>2007-10-16T15:47.08Z</time>
      </trkpt>
      <trkpt lat="55.84494000" lon="-4.30968000">
        <ele>96.3</ele>
        <time>2007-10-16T15:47.10Z</time>
      </trkpt>
      <trkpt lat="55.84485000" lon="-4.30964500">
        <ele>96.7</ele>
        <time>2007-10-16T15:47.12Z</time>
      </trkpt>
      <trkpt lat="55.84457000" lon="-4.30954600">
        <ele>94.6</ele>
        <time>2007-10-16T15:47.14Z</time>
      </trkpt>
      <trkpt lat="55.84448000" lon="-4.30950000">
        <ele>92.7</ele>
        <time>2007-10-16T15:47.24Z</time>
      </trkpt>
      <trkpt lat="55.84332000" lon="-4.30884600">
        <ele>85.1</ele>
        <time>2007-10-16T15:47.26Z</time>
      </trkpt>
      <trkpt lat="55.84310000" lon="-4.30876500">
        <ele>80.7</ele>
        <time>2007-10-16T15:47.28Z</time>
      </trkpt>
      <trkpt lat="55.84292000" lon="-4.30880500">
        <ele>81.6</ele>
        <time>2007-10-16T15:47.30Z</time>
      </trkpt>
      <trkpt lat="55.84278000" lon="-4.30883000">
        <ele>81.7</ele>
        <time>2007-10-16T15:47.32Z</time>
      </trkpt>
      <trkpt lat="55.84268000" lon="-4.30884600">
        <ele>81.9</ele>
        <time>2007-10-16T15:47.34Z</time>
      </trkpt>
      <trkpt lat="55.84262000" lon="-4.30887000">
        <ele>79.9</ele>
        <time>2007-10-16T15:47.36Z</time>
      </trkpt>
      <trkpt lat="55.84260000" lon="-4.30889700">
        <ele>79.3</ele>
        <time>2007-10-16T15:47.38Z</time>
      </trkpt>
      <trkpt lat="55.84261000" lon="-4.30889300">
        <ele>78.3</ele>
        <time>2007-10-16T15:47.40Z</time>
      </trkpt>
      <trkpt lat="55.84258000" lon="-4.30890200">
        <ele>79.8</ele>
        <time>2007-10-16T15:47.43Z</time>
      </trkpt>
      <trkpt lat="55.84255000" lon="-4.30891000">
        <ele>81.3</ele>
        <time>2007-10-16T15:47.44Z</time>
      </trkpt>
      <trkpt lat="55.84250000" lon="-4.30891500">
        <ele>82.3</ele>
        <time>2007-10-16T15:47.47Z</time>
      </trkpt>
      <trkpt lat="55.84247000" lon="-4.30892300">
        <ele>83.4</ele>
        <time>2007-10-16T15:47.48Z</time>
      </trkpt>
      <trkpt lat="55.84245000" lon="-4.30892800">
        <ele>85.0</ele>
        <time>2007-10-16T15:47.57Z</time>
      </trkpt>
      <trkpt lat="55.84238000" lon="-4.30894700">
        <ele>80.6</ele>
        <time>2007-10-16T15:47.59Z</time>
      </trkpt>
      <trkpt lat="55.84234000" lon="-4.30895500">
        <ele>80.1</ele>
        <time>2007-10-16T15:48.01Z</time>
      </trkpt>
      <trkpt lat="55.84232000" lon="-4.30896500">
        <ele>80.7</ele>
        <time>2007-10-16T15:48.03Z</time>
      </trkpt>
      <trkpt lat="55.84231000" lon="-4.30896700">
        <ele>80.8</ele>
        <time>2007-10-16T15:48.05Z</time>
      </trkpt>
      <trkpt lat="55.84230000" lon="-4.30895200">
        <ele>78.2</ele>
        <time>2007-10-16T15:48.09Z</time>
      </trkpt>
      <trkpt lat="55.84226000" lon="-4.30895000">
        <ele>76.9</ele>
        <time>2007-10-16T15:48.11Z</time>
      </trkpt>
      <trkpt lat="55.84224000" lon="-4.30896200">
        <ele>80.3</ele>
        <time>2007-10-16T15:48.13Z</time>
      </trkpt>
      <trkpt lat="55.84222000" lon="-4.30896700">
        <ele>83.3</ele>
        <time>2007-10-16T15:48.15Z</time>
      </trkpt>
      <trkpt lat="55.84221000" lon="-4.30896000">
        <ele>84.6</ele>
        <time>2007-10-16T15:48.17Z</time>
      </trkpt>
      <trkpt lat="55.84219000" lon="-4.30896200">
        <ele>84.7</ele>
        <time>2007-10-16T15:48.19Z</time>
      </trkpt>
      <trkpt lat="55.84217000" lon="-4.30896800">
        <ele>87.0</ele>
        <time>2007-10-16T15:48.43Z</time>
      </trkpt>
      <trkpt lat="55.84201000" lon="-4.30898300">
        <ele>89.3</ele>
        <time>2007-10-16T15:48.45Z</time>
      </trkpt>
      <trkpt lat="55.84189000" lon="-4.30896300">
        <ele>87.5</ele>
        <time>2007-10-16T15:48.47Z</time>
      </trkpt>
      <trkpt lat="55.84177000" lon="-4.30890300">
        <ele>84.8</ele>
        <time>2007-10-16T15:48.49Z</time>
      </trkpt>
      <trkpt lat="55.84168000" lon="-4.30889500">
        <ele>83.4</ele>
        <time>2007-10-16T15:48.51Z</time>
      </trkpt>
      <trkpt lat="55.84166000" lon="-4.30888500">
        <ele>83.1</ele>
        <time>2007-10-16T15:48.53Z</time>
      </trkpt>
      <trkpt lat="55.84164000" lon="-4.30888800">
        <ele>82.9</ele>
        <time>2007-10-16T15:48.55Z</time>
      </trkpt>
      <trkpt lat="55.84159000" lon="-4.30889000">
        <ele>82.1</ele>
        <time>2007-10-16T15:49.23Z</time>
      </trkpt>
      <trkpt lat="55.84148000" lon="-4.30883500">
        <ele>82.7</ele>
        <time>2007-10-16T15:49.25Z</time>
      </trkpt>
      <trkpt lat="55.84137000" lon="-4.30876700">
        <ele>81.4</ele>
        <time>2007-10-16T15:49.27Z</time>
      </trkpt>
      <trkpt lat="55.84124000" lon="-4.30869300">
        <ele>79.6</ele>
        <time>2007-10-16T15:49.29Z</time>
      </trkpt>
      <trkpt lat="55.84109000" lon="-4.30862000">
        <ele>79.8</ele>
        <time>2007-10-16T15:49.31Z</time>
      </trkpt>
      <trkpt lat="55.84093000" lon="-4.30856700">
        <ele>80.8</ele>
        <time>2007-10-16T15:49.33Z</time>
      </trkpt>
      <trkpt lat="55.84076000" lon="-4.30853500">
        <ele>82.8</ele>
        <time>2007-10-16T15:49.35Z</time>
      </trkpt>
      <trkpt lat="55.84061000" lon="-4.30853700">
        <ele>80.8</ele>
        <time>2007-10-16T15:49.37Z</time>
      </trkpt>
      <trkpt lat="55.84047000" lon="-4.30857700">
        <ele>79.2</ele>
        <time>2007-10-16T15:49.39Z</time>
      </trkpt>
      <trkpt lat="55.84034000" lon="-4.30860900">
        <ele>77.8</ele>
        <time>2007-10-16T15:49.41Z</time>
      </trkpt>
      <trkpt lat="55.84023000" lon="-4.30863500">
        <ele>77.0</ele>
        <time>2007-10-16T15:49.43Z</time>
      </trkpt>
      <trkpt lat="55.84010000" lon="-4.30868800">
        <ele>74.8</ele>
        <time>2007-10-16T15:49.45Z</time>
      </trkpt>
      <trkpt lat="55.83997000" lon="-4.30871700">
        <ele>72.3</ele>
        <time>2007-10-16T15:49.47Z</time>
      </trkpt>
      <trkpt lat="55.83985000" lon="-4.30871800">
        <ele>72.8</ele>
        <time>2007-10-16T15:49.49Z</time>
      </trkpt>
      <trkpt lat="55.83974000" lon="-4.30869300">
        <ele>77.2</ele>
        <time>2007-10-16T15:49.51Z</time>
      </trkpt>
      <trkpt lat="55.83962000" lon="-4.30862000">
        <ele>78.1</ele>
        <time>2007-10-16T15:49.53Z</time>
      </trkpt>
      <trkpt lat="55.83953000" lon="-4.30847700">
        <ele>75.5</ele>
        <time>2007-10-16T15:49.55Z</time>
      </trkpt>
      <trkpt lat="55.83948000" lon="-4.30824200">
        <ele>74.4</ele>
        <time>2007-10-16T15:49.57Z</time>
      </trkpt>
      <trkpt lat="55.83950000" lon="-4.30795500">
        <ele>75.8</ele>
        <time>2007-10-16T15:49.59Z</time>
      </trkpt>
      <trkpt lat="55.83957000" lon="-4.30770700">
        <ele>73.9</ele>
        <time>2007-10-16T15:50.01Z</time>
      </trkpt>
      <trkpt lat="55.83969000" lon="-4.30753300">
        <ele>73.7</ele>
        <time>2007-10-16T15:50.03Z</time>
      </trkpt>
      <trkpt lat="55.83985000" lon="-4.30747300">
        <ele>72.6</ele>
        <time>2007-10-16T15:50.05Z</time>
      </trkpt>
      <trkpt lat="55.84002000" lon="-4.30754700">
        <ele>73.7</ele>
        <time>2007-10-16T15:50.07Z</time>
      </trkpt>
      <trkpt lat="55.84016000" lon="-4.30773700">
        <ele>72.4</ele>
        <time>2007-10-16T15:50.09Z</time>
      </trkpt>
      <trkpt lat="55.84026000" lon="-4.30799200">
        <ele>74.1</ele>
        <time>2007-10-16T15:50.11Z</time>
      </trkpt>
      <trkpt lat="55.84028000" lon="-4.30826300">
        <ele>77.0</ele>
        <time>2007-10-16T15:50.13Z</time>
      </trkpt>
      <trkpt lat="55.84021000" lon="-4.30855000">
        <ele>80.8</ele>
        <time>2007-10-16T15:50.15Z</time>
      </trkpt>
      <trkpt lat="55.83998000" lon="-4.30959700">
        <ele>77.5</ele>
        <time>2007-10-16T15:50.21Z</time>
      </trkpt>
      <trkpt lat="55.83989000" lon="-4.30994700">
        <ele>81.0</ele>
        <time>2007-10-16T15:50.23Z</time>
      </trkpt>
      <trkpt lat="55.83982000" lon="-4.31029000">
        <ele>78.0</ele>
        <time>2007-10-16T15:50.25Z</time>
      </trkpt>
      <trkpt lat="55.83976000" lon="-4.31069200">
        <ele>79.2</ele>
        <time>2007-10-16T15:50.27Z</time>
      </trkpt>
      <trkpt lat="55.83971000" lon="-4.31104300">
        <ele>79.0</ele>
        <time>2007-10-16T15:50.29Z</time>
      </trkpt>
      <trkpt lat="55.83966000" lon="-4.31138800">
        <ele>77.2</ele>
        <time>2007-10-16T15:50.31Z</time>
      </trkpt>
      <trkpt lat="55.83961000" lon="-4.31176000">
        <ele>76.6</ele>
        <time>2007-10-16T15:50.33Z</time>
      </trkpt>
      <trkpt lat="55.83957000" lon="-4.31215300">
        <ele>75.6</ele>
        <time>2007-10-16T15:50.35Z</time>
      </trkpt>
      <trkpt lat="55.83952000" lon="-4.31255500">
        <ele>75.6</ele>
        <time>2007-10-16T15:50.37Z</time>
      </trkpt>
      <trkpt lat="55.83947000" lon="-4.31302800">
        <ele>76.4</ele>
        <time>2007-10-16T15:50.39Z</time>
      </trkpt>
      <trkpt lat="55.83943000" lon="-4.31347200">
        <ele>83.1</ele>
        <time>2007-10-16T15:50.41Z</time>
      </trkpt>
      <trkpt lat="55.83936000" lon="-4.31395000">
        <ele>88.0</ele>
        <time>2007-10-16T15:50.43Z</time>
      </trkpt>
      <trkpt lat="55.83929000" lon="-4.31444200">
        <ele>89.7</ele>
        <time>2007-10-16T15:50.45Z</time>
      </trkpt>
      <trkpt lat="55.83919000" lon="-4.31490900">
        <ele>89.9</ele>
        <time>2007-10-16T15:50.47Z</time>
      </trkpt>
      <trkpt lat="55.83909000" lon="-4.31535700">
        <ele>86.5</ele>
        <time>2007-10-16T15:50.49Z</time>
      </trkpt>
      <trkpt lat="55.83897000" lon="-4.31576300">
        <ele>84.1</ele>
        <time>2007-10-16T15:50.51Z</time>
      </trkpt>
      <trkpt lat="55.83884000" lon="-4.31617800">
        <ele>86.1</ele>
        <time>2007-10-16T15:50.53Z</time>
      </trkpt>
      <trkpt lat="55.83869000" lon="-4.31658600">
        <ele>91.3</ele>
        <time>2007-10-16T15:50.55Z</time>
      </trkpt>
      <trkpt lat="55.83854000" lon="-4.31702200">
        <ele>92.7</ele>
        <time>2007-10-16T15:50.57Z</time>
      </trkpt>
      <trkpt lat="55.83836000" lon="-4.31744800">
        <ele>95.2</ele>
        <time>2007-10-16T15:50.59Z</time>
      </trkpt>
      <trkpt lat="55.83821000" lon="-4.31775700">
        <ele>91.2</ele>
        <time>2007-10-16T15:51.06Z</time>
      </trkpt>
      <trkpt lat="55.83735000" lon="-4.31931700">
        <ele>78.0</ele>
        <time>2007-10-16T15:51.07Z</time>
      </trkpt>
      <trkpt lat="55.83709000" lon="-4.31972500">
        <ele>77.6</ele>
        <time>2007-10-16T15:51.09Z</time>
      </trkpt>
      <trkpt lat="55.83682000" lon="-4.32014000">
        <ele>77.5</ele>
        <time>2007-10-16T15:51.11Z</time>
      </trkpt>
      <trkpt lat="55.83656000" lon="-4.32053900">
        <ele>76.3</ele>
        <time>2007-10-16T15:51.13Z</time>
      </trkpt>
      <trkpt lat="55.83630000" lon="-4.32099200">
        <ele>75.5</ele>
        <time>2007-10-16T15:51.15Z</time>
      </trkpt>
      <trkpt lat="55.83604000" lon="-4.32148000">
        <ele>74.4</ele>
        <time>2007-10-16T15:51.17Z</time>
      </trkpt>
      <trkpt lat="55.83581000" lon="-4.32199200">
        <ele>74.1</ele>
        <time>2007-10-16T15:51.19Z</time>
      </trkpt>
      <trkpt lat="55.83560000" lon="-4.32251200">
        <ele>70.1</ele>
        <time>2007-10-16T15:51.21Z</time>
      </trkpt>
      <trkpt lat="55.83541000" lon="-4.32303000">
        <ele>68.8</ele>
        <time>2007-10-16T15:51.23Z</time>
      </trkpt>
      <trkpt lat="55.83522000" lon="-4.32359000">
        <ele>70.0</ele>
        <time>2007-10-16T15:51.25Z</time>
      </trkpt>
      <trkpt lat="55.83506000" lon="-4.32416200">
        <ele>72.6</ele>
        <time>2007-10-16T15:51.27Z</time>
      </trkpt>
      <trkpt lat="55.83490000" lon="-4.32475000">
        <ele>75.2</ele>
        <time>2007-10-16T15:51.29Z</time>
      </trkpt>
      <trkpt lat="55.83475000" lon="-4.32536600">
        <ele>77.7</ele>
        <time>2007-10-16T15:51.31Z</time>
      </trkpt>
      <trkpt lat="55.83459000" lon="-4.32593800">
        <ele>76.7</ele>
        <time>2007-10-16T15:51.33Z</time>
      </trkpt>
      <trkpt lat="55.83444000" lon="-4.32647800">
        <ele>75.0</ele>
        <time>2007-10-16T15:51.35Z</time>
      </trkpt>
      <trkpt lat="55.83429000" lon="-4.32705300">
        <ele>76.3</ele>
        <time>2007-10-16T15:51.37Z</time>
      </trkpt>
      <trkpt lat="55.83413000" lon="-4.32762000">
        <ele>74.4</ele>
        <time>2007-10-16T15:51.39Z</time>
      </trkpt>
      <trkpt lat="55.83394000" lon="-4.32819000">
        <ele>76.0</ele>
        <time>2007-10-16T15:51.41Z</time>
      </trkpt>
      <trkpt lat="55.83373000" lon="-4.32874700">
        <ele>75.0</ele>
        <time>2007-10-16T15:51.48Z</time>
      </trkpt>
      <trkpt lat="55.83295000" lon="-4.33023500">
        <ele>78.3</ele>
        <time>2007-10-16T15:51.49Z</time>
      </trkpt>
      <trkpt lat="55.83265000" lon="-4.33064700">
        <ele>81.9</ele>
        <time>2007-10-16T15:51.51Z</time>
      </trkpt>
      <trkpt lat="55.83233000" lon="-4.33101300">
        <ele>84.0</ele>
        <time>2007-10-16T15:51.53Z</time>
      </trkpt>
      <trkpt lat="55.83199000" lon="-4.33131600">
        <ele>84.1</ele>
        <time>2007-10-16T15:52.14Z</time>
      </trkpt>
      <trkpt lat="55.82785000" lon="-4.33285500">
        <ele>78.3</ele>
        <time>2007-10-16T15:52.17Z</time>
      </trkpt>
      <trkpt lat="55.82749000" lon="-4.33295800">
        <ele>76.5</ele>
        <time>2007-10-16T15:52.19Z</time>
      </trkpt>
      <trkpt lat="55.82712000" lon="-4.33303700">
        <ele>76.9</ele>
        <time>2007-10-16T15:52.21Z</time>
      </trkpt>
      <trkpt lat="55.82676000" lon="-4.33313800">
        <ele>79.3</ele>
        <time>2007-10-16T15:52.23Z</time>
      </trkpt>
      <trkpt lat="55.82640000" lon="-4.33325500">
        <ele>79.7</ele>
        <time>2007-10-16T15:52.25Z</time>
      </trkpt>
      <trkpt lat="55.82602000" lon="-4.33334700">
        <ele>79.1</ele>
        <time>2007-10-16T15:52.27Z</time>
      </trkpt>
      <trkpt lat="55.82582000" lon="-4.33341200">
        <ele>78.9</ele>
        <time>2007-10-16T15:52.39Z</time>
      </trkpt>
      <trkpt lat="55.82362000" lon="-4.33513000">
        <ele>74.7</ele>
        <time>2007-10-16T15:52.41Z</time>
      </trkpt>
      <trkpt lat="55.82331000" lon="-4.33549500">
        <ele>77.5</ele>
        <time>2007-10-16T15:52.43Z</time>
      </trkpt>
      <trkpt lat="55.82270000" lon="-4.33627800">
        <ele>75.9</ele>
        <time>2007-10-16T15:52.47Z</time>
      </trkpt>
      <trkpt lat="55.82240000" lon="-4.33662000">
        <ele>78.4</ele>
        <time>2007-10-16T15:52.49Z</time>
      </trkpt>
      <trkpt lat="55.82209000" lon="-4.33694800">
        <ele>78.6</ele>
        <time>2007-10-16T15:52.51Z</time>
      </trkpt>
      <trkpt lat="55.82175000" lon="-4.33725000">
        <ele>80.2</ele>
        <time>2007-10-16T15:52.53Z</time>
      </trkpt>
      <trkpt lat="55.82141000" lon="-4.33754700">
        <ele>82.1</ele>
        <time>2007-10-16T15:52.55Z</time>
      </trkpt>
      <trkpt lat="55.82104000" lon="-4.33775300">
        <ele>80.9</ele>
        <time>2007-10-16T15:52.57Z</time>
      </trkpt>
      <trkpt lat="55.82067000" lon="-4.33792500">
        <ele>80.5</ele>
        <time>2007-10-16T15:52.59Z</time>
      </trkpt>
      <trkpt lat="55.82030000" lon="-4.33803700">
        <ele>81.5</ele>
        <time>2007-10-16T15:53.01Z</time>
      </trkpt>
      <trkpt lat="55.81993000" lon="-4.33806700">
        <ele>83.0</ele>
        <time>2007-10-16T15:53.03Z</time>
      </trkpt>
      <trkpt lat="55.81974000" lon="-4.33805500">
        <ele>84.6</ele>
        <time>2007-10-16T15:53.08Z</time>
      </trkpt>
      <trkpt lat="55.81878000" lon="-4.33787200">
        <ele>83.8</ele>
        <time>2007-10-16T15:53.09Z</time>
      </trkpt>
      <trkpt lat="55.81839000" lon="-4.33768700">
        <ele>83.1</ele>
        <time>2007-10-16T15:53.11Z</time>
      </trkpt>
      <trkpt lat="55.81801000" lon="-4.33744500">
        <ele>84.8</ele>
        <time>2007-10-16T15:53.13Z</time>
      </trkpt>
      <trkpt lat="55.81767000" lon="-4.33715800">
        <ele>86.3</ele>
        <time>2007-10-16T15:53.15Z</time>
      </trkpt>
      <trkpt lat="55.81738000" lon="-4.33688500">
        <ele>85.7</ele>
        <time>2007-10-16T15:53.17Z</time>
      </trkpt>
      <trkpt lat="55.81713000" lon="-4.33662300">
        <ele>83.3</ele>
        <time>2007-10-16T15:53.19Z</time>
      </trkpt>
      <trkpt lat="55.81692000" lon="-4.33634900">
        <ele>83.6</ele>
        <time>2007-10-16T15:53.21Z</time>
      </trkpt>
      <trkpt lat="55.81671000" lon="-4.33607300">
        <ele>84.7</ele>
        <time>2007-10-16T15:53.23Z</time>
      </trkpt>
      <trkpt lat="55.81651000" lon="-4.33580400">
        <ele>88.6</ele>
        <time>2007-10-16T15:53.25Z</time>
      </trkpt>
      <trkpt lat="55.81629000" lon="-4.33551000">
        <ele>90.2</ele>
        <time>2007-10-16T15:53.27Z</time>
      </trkpt>
      <trkpt lat="55.81607000" lon="-4.33520000">
        <ele>92.5</ele>
        <time>2007-10-16T15:53.29Z</time>
      </trkpt>
      <trkpt lat="55.81584000" lon="-4.33490300">
        <ele>93.6</ele>
        <time>2007-10-16T15:53.31Z</time>
      </trkpt>
      <trkpt lat="55.81559000" lon="-4.33459500">
        <ele>95.6</ele>
        <time>2007-10-16T15:53.33Z</time>
      </trkpt>
      <trkpt lat="55.81533000" lon="-4.33428500">
        <ele>97.8</ele>
        <time>2007-10-16T15:53.35Z</time>
      </trkpt>
      <trkpt lat="55.81504000" lon="-4.33399800">
        <ele>97.1</ele>
        <time>2007-10-16T15:53.37Z</time>
      </trkpt>
      <trkpt lat="55.81476000" lon="-4.33375500">
        <ele>98.7</ele>
        <time>2007-10-16T15:53.39Z</time>
      </trkpt>
      <trkpt lat="55.81447000" lon="-4.33354700">
        <ele>97.5</ele>
        <time>2007-10-16T15:53.41Z</time>
      </trkpt>
      <trkpt lat="55.81418000" lon="-4.33333700">
        <ele>97.2</ele>
        <time>2007-10-16T15:53.43Z</time>
      </trkpt>
      <trkpt lat="55.81389000" lon="-4.33314800">
        <ele>97.9</ele>
        <time>2007-10-16T15:53.45Z</time>
      </trkpt>
      <trkpt lat="55.81361000" lon="-4.33298700">
        <ele>99.2</ele>
        <time>2007-10-16T15:53.54Z</time>
      </trkpt>
      <trkpt lat="55.81260000" lon="-4.33260500">
        <ele>105.6</ele>
        <time>2007-10-16T15:53.55Z</time>
      </trkpt>
      <trkpt lat="55.81210000" lon="-4.33259200">
        <ele>101.8</ele>
        <time>2007-10-16T15:53.57Z</time>
      </trkpt>
      <trkpt lat="55.81180000" lon="-4.33257700">
        <ele>99.2</ele>
        <time>2007-10-16T15:53.59Z</time>
      </trkpt>
      <trkpt lat="55.81148000" lon="-4.33257500">
        <ele>99.7</ele>
        <time>2007-10-16T15:54.01Z</time>
      </trkpt>
      <trkpt lat="55.81115000" lon="-4.33263700">
        <ele>96.1</ele>
        <time>2007-10-16T15:54.03Z</time>
      </trkpt>
      <trkpt lat="55.81082000" lon="-4.33269700">
        <ele>92.5</ele>
        <time>2007-10-16T15:54.05Z</time>
      </trkpt>
      <trkpt lat="55.81050000" lon="-4.33281900">
        <ele>92.3</ele>
        <time>2007-10-16T15:54.07Z</time>
      </trkpt>
      <trkpt lat="55.81017000" lon="-4.33293000">
        <ele>94.2</ele>
        <time>2007-10-16T15:54.09Z</time>
      </trkpt>
      <trkpt lat="55.80984000" lon="-4.33308500">
        <ele>95.3</ele>
        <time>2007-10-16T15:54.11Z</time>
      </trkpt>
      <trkpt lat="55.80950000" lon="-4.33328200">
        <ele>95.6</ele>
        <time>2007-10-16T15:54.13Z</time>
      </trkpt>
      <trkpt lat="55.80917000" lon="-4.33351500">
        <ele>96.6</ele>
        <time>2007-10-16T15:54.15Z</time>
      </trkpt>
      <trkpt lat="55.80883000" lon="-4.33378300">
        <ele>96.3</ele>
        <time>2007-10-16T15:54.17Z</time>
      </trkpt>
      <trkpt lat="55.80833000" lon="-4.33423200">
        <ele>95.6</ele>
        <time>2007-10-16T15:54.19Z</time>
      </trkpt>
      <trkpt lat="55.80799000" lon="-4.33456000">
        <ele>93.5</ele>
        <time>2007-10-16T15:54.21Z</time>
      </trkpt>
      <trkpt lat="55.80764000" lon="-4.33488200">
        <ele>96.9</ele>
        <time>2007-10-16T15:54.23Z</time>
      </trkpt>
      <trkpt lat="55.80746000" lon="-4.33503700">
        <ele>97.7</ele>
        <time>2007-10-16T15:54.25Z</time>
      </trkpt>
      <trkpt lat="55.80728000" lon="-4.33518600">
        <ele>100.7</ele>
        <time>2007-10-16T15:54.28Z</time>
      </trkpt>
      <trkpt lat="55.80651000" lon="-4.33578000">
        <ele>105.4</ele>
        <time>2007-10-16T15:54.29Z</time>
      </trkpt>
      <trkpt lat="55.80610000" lon="-4.33601000">
        <ele>105.4</ele>
        <time>2007-10-16T15:54.31Z</time>
      </trkpt>
      <trkpt lat="55.80546000" lon="-4.33630700">
        <ele>104.7</ele>
        <time>2007-10-16T15:54.36Z</time>
      </trkpt>
      <trkpt lat="55.80500000" lon="-4.33642800">
        <ele>101.1</ele>
        <time>2007-10-16T15:54.38Z</time>
      </trkpt>
      <trkpt lat="55.80455000" lon="-4.33652400">
        <ele>98.8</ele>
        <time>2007-10-16T15:54.40Z</time>
      </trkpt>
      <trkpt lat="55.80410000" lon="-4.33653300">
        <ele>99.1</ele>
        <time>2007-10-16T15:54.42Z</time>
      </trkpt>
      <trkpt lat="55.80365000" lon="-4.33650700">
        <ele>99.3</ele>
        <time>2007-10-16T15:54.44Z</time>
      </trkpt>
      <trkpt lat="55.80317000" lon="-4.33643300">
        <ele>101.6</ele>
        <time>2007-10-16T15:54.46Z</time>
      </trkpt>
      <trkpt lat="55.80271000" lon="-4.33635300">
        <ele>100.1</ele>
        <time>2007-10-16T15:54.48Z</time>
      </trkpt>
      <trkpt lat="55.80223000" lon="-4.33626200">
        <ele>100.6</ele>
        <time>2007-10-16T15:54.50Z</time>
      </trkpt>
      <trkpt lat="55.80178000" lon="-4.33616000">
        <ele>97.7</ele>
        <time>2007-10-16T15:54.52Z</time>
      </trkpt>
      <trkpt lat="55.80129000" lon="-4.33602200">
        <ele>99.2</ele>
        <time>2007-10-16T15:54.54Z</time>
      </trkpt>
      <trkpt lat="55.80106000" lon="-4.33596000">
        <ele>100.4</ele>
        <time>2007-10-16T15:54.58Z</time>
      </trkpt>
      <trkpt lat="55.79988000" lon="-4.33574500">
        <ele>98.7</ele>
        <time>2007-10-16T15:55.00Z</time>
      </trkpt>
      <trkpt lat="55.79939000" lon="-4.33573200">
        <ele>99.0</ele>
        <time>2007-10-16T15:55.02Z</time>
      </trkpt>
      <trkpt lat="55.79890000" lon="-4.33582700">
        <ele>99.0</ele>
        <time>2007-10-16T15:55.04Z</time>
      </trkpt>
      <trkpt lat="55.79842000" lon="-4.33595700">
        <ele>100.9</ele>
        <time>2007-10-16T15:55.06Z</time>
      </trkpt>
      <trkpt lat="55.79796000" lon="-4.33618500">
        <ele>104.4</ele>
        <time>2007-10-16T15:55.08Z</time>
      </trkpt>
      <trkpt lat="55.79730000" lon="-4.33658500">
        <ele>107.7</ele>
        <time>2007-10-16T15:55.10Z</time>
      </trkpt>
      <trkpt lat="55.79687000" lon="-4.33688500">
        <ele>110.0</ele>
        <time>2007-10-16T15:55.12Z</time>
      </trkpt>
      <trkpt lat="55.79667000" lon="-4.33705300">
        <ele>111.6</ele>
        <time>2007-10-16T15:55.14Z</time>
      </trkpt>
      <trkpt lat="55.79628000" lon="-4.33743500">
        <ele>115.0</ele>
        <time>2007-10-16T15:55.16Z</time>
      </trkpt>
      <trkpt lat="55.79590000" lon="-4.33788500">
        <ele>118.1</ele>
        <time>2007-10-16T15:55.18Z</time>
      </trkpt>
      <trkpt lat="55.79556000" lon="-4.33834600">
        <ele>123.2</ele>
        <time>2007-10-16T15:55.20Z</time>
      </trkpt>
      <trkpt lat="55.79523000" lon="-4.33881200">
        <ele>124.3</ele>
        <time>2007-10-16T15:55.22Z</time>
      </trkpt>
      <trkpt lat="55.79507000" lon="-4.33903000">
        <ele>124.8</ele>
        <time>2007-10-16T15:55.42Z</time>
      </trkpt>
      <trkpt lat="55.79232000" lon="-4.34296000">
        <ele>150.0</ele>
        <time>2007-10-16T15:55.47Z</time>
      </trkpt>
      <trkpt lat="55.79222000" lon="-4.34311000">
        <ele>150.9</ele>
        <time>2007-10-16T15:55.48Z</time>
      </trkpt>
      <trkpt lat="55.79181000" lon="-4.34369000">
        <ele>151.4</ele>
        <time>2007-10-16T15:55.50Z</time>
      </trkpt>
      <trkpt lat="55.79151000" lon="-4.34413700">
        <ele>150.0</ele>
        <time>2007-10-16T15:55.52Z</time>
      </trkpt>
      <trkpt lat="55.79132000" lon="-4.34442700">
        <ele>150.6</ele>
        <time>2007-10-16T15:55.54Z</time>
      </trkpt>
      <trkpt lat="55.79111000" lon="-4.34470700">
        <ele>152.9</ele>
        <time>2007-10-16T15:55.56Z</time>
      </trkpt>
      <trkpt lat="55.79090000" lon="-4.34500300">
        <ele>155.4</ele>
        <time>2007-10-16T15:55.58Z</time>
      </trkpt>
      <trkpt lat="55.79068000" lon="-4.34529500">
        <ele>156.2</ele>
        <time>2007-10-16T15:56.00Z</time>
      </trkpt>
      <trkpt lat="55.79044000" lon="-4.34556500">
        <ele>159.2</ele>
        <time>2007-10-16T15:56.02Z</time>
      </trkpt>
      <trkpt lat="55.79020000" lon="-4.34584300">
        <ele>162.7</ele>
        <time>2007-10-16T15:56.04Z</time>
      </trkpt>
      <trkpt lat="55.78994000" lon="-4.34614500">
        <ele>162.2</ele>
        <time>2007-10-16T15:56.06Z</time>
      </trkpt>
      <trkpt lat="55.78981000" lon="-4.34629000">
        <ele>163.0</ele>
        <time>2007-10-16T15:56.08Z</time>
      </trkpt>
      <trkpt lat="55.78953000" lon="-4.34658500">
        <ele>162.2</ele>
        <time>2007-10-16T15:56.10Z</time>
      </trkpt>
      <trkpt lat="55.78922000" lon="-4.34688000">
        <ele>160.5</ele>
        <time>2007-10-16T15:56.12Z</time>
      </trkpt>
      <trkpt lat="55.78892000" lon="-4.34718200">
        <ele>157.0</ele>
        <time>2007-10-16T15:56.17Z</time>
      </trkpt>
      <trkpt lat="55.78799000" lon="-4.34797800">
        <ele>159.2</ele>
        <time>2007-10-16T15:56.20Z</time>
      </trkpt>
      <trkpt lat="55.78766000" lon="-4.34823000">
        <ele>159.5</ele>
        <time>2007-10-16T15:56.22Z</time>
      </trkpt>
      <trkpt lat="55.78728000" lon="-4.34846500">
        <ele>162.1</ele>
        <time>2007-10-16T15:56.24Z</time>
      </trkpt>
      <trkpt lat="55.78675000" lon="-4.34875300">
        <ele>156.8</ele>
        <time>2007-10-16T15:56.26Z</time>
      </trkpt>
      <trkpt lat="55.78659000" lon="-4.34885500">
        <ele>155.6</ele>
        <time>2007-10-16T15:56.28Z</time>
      </trkpt>
      <trkpt lat="55.78609000" lon="-4.34915400">
        <ele>159.6</ele>
        <time>2007-10-16T15:56.30Z</time>
      </trkpt>
      <trkpt lat="55.78577000" lon="-4.34932200">
        <ele>158.4</ele>
        <time>2007-10-16T15:56.32Z</time>
      </trkpt>
      <trkpt lat="55.78545000" lon="-4.34946500">
        <ele>157.2</ele>
        <time>2007-10-16T15:56.34Z</time>
      </trkpt>
      <trkpt lat="55.78514000" lon="-4.34962300">
        <ele>160.9</ele>
        <time>2007-10-16T15:56.36Z</time>
      </trkpt>
      <trkpt lat="55.78484000" lon="-4.34978800">
        <ele>165.1</ele>
        <time>2007-10-16T15:56.38Z</time>
      </trkpt>
      <trkpt lat="55.78453000" lon="-4.34996500">
        <ele>165.6</ele>
        <time>2007-10-16T15:56.40Z</time>
      </trkpt>
      <trkpt lat="55.78429000" lon="-4.35008000">
        <ele>163.4</ele>
        <time>2007-10-16T15:56.42Z</time>
      </trkpt>
      <trkpt lat="55.78407000" lon="-4.35001200">
        <ele>160.2</ele>
        <time>2007-10-16T15:56.44Z</time>
      </trkpt>
      <trkpt lat="55.78388000" lon="-4.34975700">
        <ele>157.8</ele>
        <time>2007-10-16T15:56.46Z</time>
      </trkpt>
      <trkpt lat="55.78381000" lon="-4.34956500">
        <ele>157.1</ele>
        <time>2007-10-16T15:56.48Z</time>
      </trkpt>
      <trkpt lat="55.78374000" lon="-4.34909700">
        <ele>157.8</ele>
        <time>2007-10-16T15:56.50Z</time>
      </trkpt>
      <trkpt lat="55.78374000" lon="-4.34862000">
        <ele>159.8</ele>
        <time>2007-10-16T15:56.52Z</time>
      </trkpt>
      <trkpt lat="55.78378000" lon="-4.34812500">
        <ele>164.1</ele>
        <time>2007-10-16T15:56.54Z</time>
      </trkpt>
      <trkpt lat="55.78381000" lon="-4.34770200">
        <ele>166.7</ele>
        <time>2007-10-16T15:56.56Z</time>
      </trkpt>
      <trkpt lat="55.78381000" lon="-4.34730500">
        <ele>165.8</ele>
        <time>2007-10-16T15:56.58Z</time>
      </trkpt>
      <trkpt lat="55.78383000" lon="-4.34693000">
        <ele>165.7</ele>
        <time>2007-10-16T15:57.00Z</time>
      </trkpt>
      <trkpt lat="55.78384000" lon="-4.34658300">
        <ele>167.2</ele>
        <time>2007-10-16T15:57.02Z</time>
      </trkpt>
      <trkpt lat="55.78383000" lon="-4.34628800">
        <ele>166.6</ele>
        <time>2007-10-16T15:57.04Z</time>
      </trkpt>
      <trkpt lat="55.78381000" lon="-4.34602300">
        <ele>167.6</ele>
        <time>2007-10-16T15:57.06Z</time>
      </trkpt>
      <trkpt lat="55.78378000" lon="-4.34578200">
        <ele>167.2</ele>
        <time>2007-10-16T15:57.08Z</time>
      </trkpt>
      <trkpt lat="55.78374000" lon="-4.34557800">
        <ele>167.3</ele>
        <time>2007-10-16T15:57.10Z</time>
      </trkpt>
      <trkpt lat="55.78370000" lon="-4.34541300">
        <ele>169.2</ele>
        <time>2007-10-16T15:57.12Z</time>
      </trkpt>
      <trkpt lat="55.78365000" lon="-4.34521200">
        <ele>170.6</ele>
        <time>2007-10-16T15:57.14Z</time>
      </trkpt>
      <trkpt lat="55.78361000" lon="-4.34499000">
        <ele>171.0</ele>
        <time>2007-10-16T15:57.16Z</time>
      </trkpt>
      <trkpt lat="55.78360000" lon="-4.34486800">
        <ele>169.3</ele>
        <time>2007-10-16T15:57.18Z</time>
      </trkpt>
      <trkpt lat="55.78347000" lon="-4.34466500">
        <ele>168.0</ele>
        <time>2007-10-16T15:57.20Z</time>
      </trkpt>
      <trkpt lat="55.78339000" lon="-4.34471300">
        <ele>173.9</ele>
        <time>2007-10-16T15:57.22Z</time>
      </trkpt>
      <trkpt lat="55.78325000" lon="-4.34501800">
        <ele>173.5</ele>
        <time>2007-10-16T15:57.24Z</time>
      </trkpt>
      <trkpt lat="55.78293000" lon="-4.34559000">
        <ele>182.1</ele>
        <time>2007-10-16T15:57.26Z</time>
      </trkpt>
      <trkpt lat="55.78278000" lon="-4.34584800">
        <ele>181.6</ele>
        <time>2007-10-16T15:57.28Z</time>
      </trkpt>
      <trkpt lat="55.78264000" lon="-4.34612300">
        <ele>176.3</ele>
        <time>2007-10-16T15:57.53Z</time>
      </trkpt>
      <trkpt lat="55.78064000" lon="-4.35239800">
        <ele>186.2</ele>
        <time>2007-10-16T15:58.12Z</time>
      </trkpt>
      <trkpt lat="55.77813000" lon="-4.35563000">
        <ele>182.3</ele>
        <time>2007-10-16T15:58.16Z</time>
      </trkpt>
      <trkpt lat="55.77778000" lon="-4.35557200">
        <ele>186.1</ele>
        <time>2007-10-16T15:58.18Z</time>
      </trkpt>
      <trkpt lat="55.77742000" lon="-4.35538800">
        <ele>185.3</ele>
        <time>2007-10-16T15:58.20Z</time>
      </trkpt>
      <trkpt lat="55.77733000" lon="-4.35527500">
        <ele>182.6</ele>
        <time>2007-10-16T15:58.22Z</time>
      </trkpt>
      <trkpt lat="55.77724000" lon="-4.35511800">
        <ele>182.4</ele>
        <time>2007-10-16T15:58.24Z</time>
      </trkpt>
      <trkpt lat="55.77714000" lon="-4.35486000">
        <ele>185.7</ele>
        <time>2007-10-16T15:58.26Z</time>
      </trkpt>
      <trkpt lat="55.77710000" lon="-4.35469000">
        <ele>186.3</ele>
        <time>2007-10-16T15:58.28Z</time>
      </trkpt>
      <trkpt lat="55.77709000" lon="-4.35410000">
        <ele>180.6</ele>
        <time>2007-10-16T15:58.30Z</time>
      </trkpt>
      <trkpt lat="55.77712000" lon="-4.35362500">
        <ele>180.8</ele>
        <time>2007-10-16T15:58.32Z</time>
      </trkpt>
      <trkpt lat="55.77714000" lon="-4.35319700">
        <ele>182.2</ele>
        <time>2007-10-16T15:58.34Z</time>
      </trkpt>
      <trkpt lat="55.77716000" lon="-4.35277500">
        <ele>183.9</ele>
        <time>2007-10-16T15:58.36Z</time>
      </trkpt>
      <trkpt lat="55.77716000" lon="-4.35255800">
        <ele>182.7</ele>
        <time>2007-10-16T15:58.38Z</time>
      </trkpt>
      <trkpt lat="55.77716000" lon="-4.35193700">
        <ele>180.5</ele>
        <time>2007-10-16T15:58.40Z</time>
      </trkpt>
      <trkpt lat="55.77710000" lon="-4.35153200">
        <ele>178.7</ele>
        <time>2007-10-16T15:58.42Z</time>
      </trkpt>
      <trkpt lat="55.77702000" lon="-4.35112200">
        <ele>179.2</ele>
        <time>2007-10-16T15:58.44Z</time>
      </trkpt>
      <trkpt lat="55.77692000" lon="-4.35071700">
        <ele>180.4</ele>
        <time>2007-10-16T15:58.46Z</time>
      </trkpt>
      <trkpt lat="55.77680000" lon="-4.35034200">
        <ele>179.2</ele>
        <time>2007-10-16T15:58.48Z</time>
      </trkpt>
      <trkpt lat="55.77668000" lon="-4.34996700">
        <ele>180.9</ele>
        <time>2007-10-16T15:58.50Z</time>
      </trkpt>
      <trkpt lat="55.77656000" lon="-4.34963000">
        <ele>180.8</ele>
        <time>2007-10-16T15:58.59Z</time>
      </trkpt>
      <trkpt lat="55.77595000" lon="-4.34774200">
        <ele>173.6</ele>
        <time>2007-10-16T15:59.02Z</time>
      </trkpt>
      <trkpt lat="55.77579000" lon="-4.34727000">
        <ele>172.6</ele>
        <time>2007-10-16T15:59.04Z</time>
      </trkpt>
      <trkpt lat="55.77565000" lon="-4.34680500">
        <ele>171.7</ele>
        <time>2007-10-16T15:59.06Z</time>
      </trkpt>
      <trkpt lat="55.77550000" lon="-4.34633700">
        <ele>170.5</ele>
        <time>2007-10-16T15:59.08Z</time>
      </trkpt>
      <trkpt lat="55.77525000" lon="-4.34566000">
        <ele>168.2</ele>
        <time>2007-10-16T15:59.10Z</time>
      </trkpt>
      <trkpt lat="55.77507000" lon="-4.34524700">
        <ele>167.0</ele>
        <time>2007-10-16T15:59.12Z</time>
      </trkpt>
      <trkpt lat="55.77487000" lon="-4.34483700">
        <ele>169.5</ele>
        <time>2007-10-16T15:59.14Z</time>
      </trkpt>
      <trkpt lat="55.77466000" lon="-4.34448000">
        <ele>171.3</ele>
        <time>2007-10-16T15:59.16Z</time>
      </trkpt>
      <trkpt lat="55.77444000" lon="-4.34412500">
        <ele>172.2</ele>
        <time>2007-10-16T15:59.18Z</time>
      </trkpt>
      <trkpt lat="55.77423000" lon="-4.34376500">
        <ele>177.4</ele>
        <time>2007-10-16T15:59.20Z</time>
      </trkpt>
      <trkpt lat="55.77405000" lon="-4.34340500">
        <ele>183.7</ele>
        <time>2007-10-16T15:59.22Z</time>
      </trkpt>
      <trkpt lat="55.77393000" lon="-4.34295300">
        <ele>184.2</ele>
        <time>2007-10-16T15:59.24Z</time>
      </trkpt>
      <trkpt lat="55.77383000" lon="-4.34251200">
        <ele>182.7</ele>
        <time>2007-10-16T15:59.26Z</time>
      </trkpt>
      <trkpt lat="55.77377000" lon="-4.34206000">
        <ele>183.0</ele>
        <time>2007-10-16T15:59.28Z</time>
      </trkpt>
      <trkpt lat="55.77376000" lon="-4.34174500">
        <ele>188.4</ele>
        <time>2007-10-16T15:59.30Z</time>
      </trkpt>
      <trkpt lat="55.77376000" lon="-4.34161500">
        <ele>191.1</ele>
        <time>2007-10-16T15:59.32Z</time>
      </trkpt>
      <trkpt lat="55.77381000" lon="-4.34144200">
        <ele>193.5</ele>
        <time>2007-10-16T15:59.34Z</time>
      </trkpt>
      <trkpt lat="55.77389000" lon="-4.34133100">
        <ele>193.3</ele>
        <time>2007-10-16T15:59.36Z</time>
      </trkpt>
      <trkpt lat="55.77399000" lon="-4.34125700">
        <ele>196.2</ele>
        <time>2007-10-16T15:59.38Z</time>
      </trkpt>
      <trkpt lat="55.77404000" lon="-4.34109500">
        <ele>197.9</ele>
        <time>2007-10-16T15:59.40Z</time>
      </trkpt>
      <trkpt lat="55.77406000" lon="-4.34087300">
        <ele>198.6</ele>
        <time>2007-10-16T15:59.42Z</time>
      </trkpt>
      <trkpt lat="55.77404000" lon="-4.34048300">
        <ele>199.5</ele>
        <time>2007-10-16T15:59.44Z</time>
      </trkpt>
      <trkpt lat="55.77405000" lon="-4.34028700">
        <ele>192.9</ele>
        <time>2007-10-16T15:59.46Z</time>
      </trkpt>
      <trkpt lat="55.77408000" lon="-4.34019700">
        <ele>192.6</ele>
        <time>2007-10-16T15:59.48Z</time>
      </trkpt>
      <trkpt lat="55.77415000" lon="-4.33994500">
        <ele>191.8</ele>
        <time>2007-10-16T15:59.50Z</time>
      </trkpt>
      <trkpt lat="55.77423000" lon="-4.33984500">
        <ele>190.3</ele>
        <time>2007-10-16T15:59.52Z</time>
      </trkpt>
      <trkpt lat="55.77431000" lon="-4.33972700">
        <ele>192.5</ele>
        <time>2007-10-16T15:59.54Z</time>
      </trkpt>
      <trkpt lat="55.77441000" lon="-4.33962200">
        <ele>194.5</ele>
        <time>2007-10-16T15:59.56Z</time>
      </trkpt>
      <trkpt lat="55.77448000" lon="-4.33957500">
        <ele>195.6</ele>
        <time>2007-10-16T16:00.11Z</time>
      </trkpt>
      <trkpt lat="55.77475000" lon="-4.33948700">
        <ele>197.9</ele>
        <time>2007-10-16T16:00.14Z</time>
      </trkpt>
    </trkseg>
  </trk>
</gpx>
EOF
;

# Don't buffer output
$| = 1;

# Try to connect to emulator
my $emu;
eval{
    # Connect
    $emu = new Net::Telnet (Timeout => 3);
    $emu->open(Host => $host, Port => $port);

    ## Wait for initial promt
    $emu->waitfor('/OK$/');
    $emu->getline;
}; if($@) {
    eval {$emu->close};
    die "Could not connect to emulator on $host:$port\n";
}

# create xml-simple object
my $xml = new XML::Simple;

# read XML file if ARGV[0] specified or use exapmple
my $in = $ARGV[0] ? $ARGV[0] : $example;
my $data = $xml->XMLin($in);

# Loop all trackpoints
my $time_last;
my $exit = 1;

my @track = @{$data->{trk}->{trkseg}->{trkpt}};
do {
    
    for my $tp (@track) {

        # Older gpx files from OSMtracker seem to have time stored as hh:mm.ss (notice the dot)
        # which cannot be converted with str2time
        $tp->{time} =~ s/\./:/;

        # Convert String to time value
        my $time = str2time($tp->{time});
        #~ print "$tp->{time} # $time\n";
        if (defined($ARGV[1]) && defined($ARGV[2]) && $ARGV[1] eq '-t') {
            $exit = 0;
            sleep($ARGV[2]);
			print "\n";
        } else {
            # Sleep for diff between this and the last file
            if(!$time_last) {
                $time_last = $time
            } else {
                my $sleept;
             
                for (1..$time - $time_last) {
                    print ".";
                    sleep(1);
                }
                
                print "\n";
                $time_last = $time;
            }
        }

        # Send command to emulator
        #~ my $cmd = "geo fix $tp->{lon} $tp->{lat} $tp->{ele}";
        my $str = gpx_trkpt_to_nmea_gga($tp->{time},
                                        $tp->{lat},
                                        $tp->{lon},
                                        $tp->{ele});
        
        my $cmd = "geo nmea $str";

        eval {
            # Send command to emulator
            $emu->print($cmd);
        
            # Check if command was sucessful
            my $result = $emu->getline;
            if($result =~ /OK$/) { } else { die "setting location failed! Result: $result"; }

        }; if($@) {
            die $@ if ($@ =~ /^setting/);
            die("Connection to emulator on $host:$port lost");   
        }

        print scalar localtime(), " - $cmd";
    }

    @track = reverse @track;

} until ($exit);

print "\nDone!\n";

# Cleanup
$emu->close;
undef $xml;
exit(0);


sub gpx_trkpt_to_nmea_gga {
 #~ http://www.gpsinformation.org/dale/nmea.htm#GGA
 #~ GGA - essential fix data which provide 3D location and accuracy data.

 #~ $GPGGA,123519,4807.038,N,01131.000,E,1,08,0.9,545.4,M,46.9,M,,*47

#~ Where:
     #~ GGA          Global Positioning System Fix Data
     #~ 123519       Fix taken at 12:35:19 UTC
     #~ 4807.038,N   Latitude 48 deg 07.038' N
     #~ 01131.000,E  Longitude 11 deg 31.000' E
     #~ 1            Fix quality: 0 = invalid
                               #~ 1 = GPS fix (SPS)
                               #~ 2 = DGPS fix
                               #~ 3 = PPS fix
                               #~ 4 = Real Time Kinematic
                               #~ 5 = Float RTK
                               #~ 6 = estimated (dead reckoning) (2.3 feature)
                               #~ 7 = Manual input mode
                               #~ 8 = Simulation mode
     #~ 08           Number of satellites being tracked
     #~ 0.9          Horizontal dilution of position
     #~ 545.4,M      Altitude, Meters, above mean sea level
     #~ 46.9,M       Height of geoid (mean sea level) above WGS84
                      #~ ellipsoid
     #~ (empty field) time in seconds since last DGPS update
     #~ (empty field) DGPS station ID number
     #~ *47          the checksum data, always begins with *

    my $time = shift;
    my $lat = shift;
    my $lon = shift;
    my $alt = shift;


    my ($s, $m, $h) = (localtime(str2time($time)))[0..2];
    my $tv = sprintf("%02d%02d%02d", $h, $m, $s);


    my $str = "\$GPGGA,";
    $str .= "$tv,";
    $str .= format_lat_lon($lat, $lon, 8) . ",";
    $str .= "1,";
    $str .= "8,";
    $str .= "0.9,";
    $str .= $alt.",M,";
    $str .= $alt.",M,";
    $str .= ",";
    $str .= "*47";

    return $str;
 
}

sub format_lat_lon {
    my $lat = shift;
    my $lon = shift;
    my $prec = shift;
    
    my $sign_lat = '+';
    $sign_lat = $1 if($lat =~ s/^(\+|-)//);
    my $ori_lat = $sign_lat eq '+' ? "N" : "S";

    my $sign_lon = '+';
    $sign_lon = $1 if($lon =~ s/^(\+|-)//);
    my $ori_lon = $sign_lon eq '+' ? "E" : "W";


    my $deg_lat = int($lat);
    my $min_lat = ($lat - int($lat)) * 60;
    my $dec_lat = sprintf("%.${prec}f", $min_lat - int($min_lat));
    
    my $deg_lon = int($lon);
    my $min_lon = ($lon - int($lon)) * 60;
    my $dec_lon = sprintf("%.${prec}f", $min_lon - int($min_lon));


    my $result;
    $result  = sprintf("%02d%02d", $deg_lat, $min_lat) . "." . (split(/\./, $dec_lat))[1];
    $result .= ",$ori_lat";
    
    $result .=",";

    $result .= sprintf("%03d%02d", $deg_lon, $min_lon) . "." . (split(/\./, $dec_lon))[1];
    $result .= ",$ori_lon";
    
    return $result;
}