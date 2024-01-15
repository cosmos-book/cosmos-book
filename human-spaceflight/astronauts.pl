#!/usr/bin/perl
##########################
# Astronaut MD/YAML parser
##########################

use Time::Local;
use lib './';


my %colours = (
	'black'=>"\033[0;30m",
	'red'=>"\033[0;31m",
	'green'=>"\033[0;32m",
	'yellow'=>"\033[0;33m",
	'blue'=>"\033[0;34m",
	'magenta'=>"\033[0;35m",
	'cyan'=>"\033[0;36m",
	'white'=>"\033[0;37m",
	'none'=>"\033[0m"
);



# Find directory of this script
$pathdir = $0;
$pathdir =~ s/(\/?)[^\/]*$/$1/;
$datadir = $pathdir."data/";
$procdir = $datadir."processed/";
$url = "https://github.com/cosmos-book/cosmos-book.github.io/tree/master/human-spaceflight/data/";

# Require the time and date sub-routines
require($pathdir.'timeanddate.pl');

# Define some values
$speed_light = 299792458;   # The speed of light in a vacuum
$speed_leo = 8050;          # Low Earth Orbit speed in m/s
$speed_moon = 11082.5;      # Speed to the Moon for Apollo missions 39,897 km/h
$epsilon_leo = (1 - ($speed_leo*$speed_leo)/($speed_light*$speed_light));
$epsilon_moon = (1 - ($speed_moon*$speed_moon)/($speed_light*$speed_light));
$gamma_leo = 1/sqrt($epsilon_leo);
$gamma_moon = 1/sqrt($epsilon_moon);

%countrycode = ('ABW'=>'Aruba','AFG'=>'Afghanistan','AGO'=>'Angola','AIA'=>'Anguilla','ALA'=>'&Aring;land Islands','ALB'=>'Albania','AND'=>'Andorra','ARE'=>'United Arab Emirates','ARG'=>'Argentina','ARM'=>'Armenia','ASM'=>'American Samoa','ATA'=>'Antarctica','ATF'=>'French Southern Territories','ATG'=>'Antigua and Barbuda','AUS'=>'Australia','AUT'=>'Austria','AZE'=>'Azerbaijan','BDI'=>'Burundi','BEL'=>'Belgium','BEN'=>'Benin','BES'=>'Bonaire, Sint Eustatius and Saba','BFA'=>'Burkina Faso','BGD'=>'Bangladesh','BGR'=>'Bulgaria','BHR'=>'Bahrain','BHS'=>'Bahamas','BIH'=>'Bosnia and Herzegovina','BLM'=>'Saint Barthélemy','BLR'=>'Belarus','BLZ'=>'Belize','BMU'=>'Bermuda','BOL'=>'Bolivia, Plurinational State of','BRA'=>'Brazil','BRB'=>'Barbados','BRN'=>'Brunei Darussalam','BTN'=>'Bhutan','BVT'=>'Bouvet Island','BWA'=>'Botswana','CAF'=>'Central African Republic','CAN'=>'Canada','CCK'=>'Cocos (Keeling) Islands','CHE'=>'Switzerland','CHL'=>'Chile','CHN'=>'China','CIV'=>'Côte d\'Ivoire','CMR'=>'Cameroon','COD'=>'Congo, the Democratic Republic of the','COG'=>'Congo','COK'=>'Cook Islands','COL'=>'Colombia','COM'=>'Comoros','CPV'=>'Cabo Verde','CRI'=>'Costa Rica','CUB'=>'Cuba','CUW'=>'Curaçao','CXR'=>'Christmas Island','CYM'=>'Cayman Islands','CYP'=>'Cyprus','CZE'=>'Czech Republic','DEU'=>'Germany','DJI'=>'Djibouti','DMA'=>'Dominica','DNK'=>'Denmark','DOM'=>'Dominican Republic','DZA'=>'Algeria','ECU'=>'Ecuador','EGY'=>'Egypt','ERI'=>'Eritrea','ESH'=>'Western Sahara','ESP'=>'Spain','EST'=>'Estonia','ETH'=>'Ethiopia','FIN'=>'Finland','FJI'=>'Fiji','FLK'=>'Falkland Islands (Malvinas)','FRA'=>'France','FRO'=>'Faroe Islands','FSM'=>'Micronesia, Federated States of','GAB'=>'Gabon','GBR'=>'United Kingdom','GEO'=>'Georgia','GGY'=>'Guernsey','GHA'=>'Ghana',	'GIB'=>'Gibraltar','GIN'=>'Guinea','GLP'=>'Guadeloupe','GMB'=>'Gambia','GNB'=>'Guinea-Bissau','GNQ'=>'Equatorial Guinea','GRC'=>'Greece','GRD'=>'Grenada','GRL'=>'Greenland','GTM'=>'Guatemala','GUF'=>'French Guiana','GUM'=>'Guam','GUY'=>'Guyana','HKG'=>'Hong Kong','HMD'=>'Heard Island and McDonald Islands','HND'=>'Honduras','HRV'=>'Croatia','HTI'=>'Haiti','HUN'=>'Hungary','IDN'=>'Indonesia','IMN'=>'Isle of Man','IND'=>'India','IOT'=>'British Indian Ocean Territory','IRL'=>'Ireland','IRN'=>'Iran, Islamic Republic of','IRQ'=>'Iraq','ISL'=>'Iceland','ISR'=>'Israel','ITA'=>'Italy','JAM'=>'Jamaica','JEY'=>'Jersey','JOR'=>'Jordan','JPN'=>'Japan','KAZ'=>'Kazakhstan','KEN'=>'Kenya','KGZ'=>'Kyrgyzstan','KHM'=>'Cambodia','KIR'=>'Kiribati','KNA'=>'Saint Kitts and Nevis','KOR'=>'Korea, Republic of','KWT'=>'Kuwait','LAO'=>'Lao People\'s Democratic Republic','LBN'=>'Lebanon','LBR'=>'Liberia','LBY'=>'Libya','LCA'=>'Saint Lucia','LIE'=>'Liechtenstein','LKA'=>'Sri Lanka','LSO'=>'Lesotho','LTU'=>'Lithuania','LUX'=>'Luxembourg','LVA'=>'Latvia','MAC'=>'Macao','MAF'=>'Saint Martin (French part)','MAR'=>'Morocco','MCO'=>'Monaco','MDA'=>'Moldova, Republic of','MDG'=>'Madagascar','MDV'=>'Maldives','MEX'=>'Mexico','MHL'=>'Marshall Islands','MKD'=>'Macedonia, the former Yugoslav Republic of','MLI'=>'Mali','MLT'=>'Malta','MMR'=>'Myanmar','MNE'=>'Montenegro','MNG'=>'Mongolia','MNP'=>'Northern Mariana Islands','MOZ'=>'Mozambique','MRT'=>'Mauritania','MSR'=>'Montserrat','MTQ'=>'Martinique','MUS'=>'Mauritius','MWI'=>'Malawi','MYS'=>'Malaysia','MYT'=>'Mayotte','NAM'=>'Namibia','NCL'=>'New Caledonia','NER'=>'Niger','NFK'=>'Norfolk Island','NGA'=>'Nigeria','NIC'=>'Nicaragua','NIU'=>'Niue',	'NLD'=>'Netherlands','NOR'=>'Norway','NPL'=>'Nepal','NRU'=>'Nauru','NZL'=>'New Zealand','OMN'=>'Oman','PAK'=>'Pakistan','PAN'=>'Panama','PCN'=>'Pitcairn','PER'=>'Peru','PHL'=>'Philippines','PLW'=>'Palau','PNG'=>'Papua New Guinea','POL'=>'Poland','PRI'=>'Puerto Rico','PRK'=>'Korea, Democratic People\'s Republic of','PRT'=>'Portugal','PRY'=>'Paraguay','PSE'=>'Palestine, State of','PYF'=>'French Polynesia','QAT'=>'Qatar','REU'=>'Réunion','ROU'=>'Romania','RUS'=>'Russian Federation','RWA'=>'Rwanda','SAU'=>'Saudi Arabia','SDN'=>'Sudan','SEN'=>'Senegal','SGP'=>'Singapore','SGS'=>'South Georgia and the South Sandwich Islands','SHN'=>'Saint Helena, Ascension and Tristan da Cunha','SJM'=>'Svalbard and Jan Mayen','SLB'=>'Solomon Islands','SLE'=>'Sierra Leone','SLV'=>'El Salvador','SMR'=>'San Marino','SOM'=>'Somalia','SPM'=>'Saint Pierre and Miquelon','SRB'=>'Serbia','SSD'=>'South Sudan','STP'=>'Sao Tome and Principe','SUR'=>'Suriname','SVK'=>'Slovakia','SVN'=>'Slovenia','SWE'=>'Sweden','SWZ'=>'Swaziland','SXM'=>'Sint Maarten (Dutch part)','SYC'=>'Seychelles','SYR'=>'Syrian Arab Republic','TCA'=>'Turks and Caicos Islands','TCD'=>'Chad','TGO'=>'Togo','THA'=>'Thailand','TJK'=>'Tajikistan','TKL'=>'Tokelau','TKM'=>'Turkmenistan','TLS'=>'Timor-Leste','TON'=>'Tonga','TTO'=>'Trinidad and Tobago','TUN'=>'Tunisia','TUR'=>'Turkey','TUV'=>'Tuvalu','TWN'=>'Taiwan, Province of China','TZA'=>'Tanzania, United Republic of','UGA'=>'Uganda','UKR'=>'Ukraine','UMI'=>'United States Minor Outlying Islands','URY'=>'Uruguay','USA'=>'United States','UZB'=>'Uzbekistan','VAT'=>'Holy See (Vatican City State)','VCT'=>'Saint Vincent and the Grenadines','VEN'=>'Venezuela, Bolivarian Republic of','VGB'=>'Virgin Islands, British','VIR'=>'Virgin Islands, U.S.','VNM'=>'Viet Nam','VUT'=>'Vanuatu','WLF'=>'Wallis and Futuna','WSM'=>'Samoa','YEM'=>'Yemen','ZAF'=>'South Africa','ZMB'=>'Zambia','ZWE'=>'Zimbabwe','URS'=>'Soviet Union','GDR'=>'East Germany','TCH'=>'Czechoslovakia');


# Find all the astronaut Markdown files
@files = ();
# Open astronaut directory
opendir($dh,$datadir);
while(my $file = readdir $dh) {
	if($file =~ /^.*_.*.md$/i){
		push(@files,$file);
	}
}
closedir($dh);

@output = "";
@li = "";
%byyear = "";
%allmissions = "";
$reflist = "";
$json = "";
$geojson = "";
$longesteva = 0;
$totaleva = 0;
$totaltime = 0;
$totaltrips = 0;

# Loop over the files
foreach $file (sort(@files)){

	# Open the file
	open(FILE,"$datadir$file");
	@lines = <FILE>;
	close(FILE);

	# Reset variables
	$name = "";
	$dob = "";
	$type = "";
	$quals = "";
	$refs = "";
	$category = "";
	$timeinspace = 0;
	$timedilation = 0;
	$distance = 0;
	$eva = 0;
	$evas = 0;
	$country = "";
	$gender = "";
	$twitter = "";
	$missions = "";
	$inspace = 0;
	$inmission = 0;
	$inrefs = 0;
	$inquals = 0;
	$ineva = 0;
	$incountry = 0;
	$inbirthplace = 0;
	$age = 0;
	$reset = 0;
	$launch = "";
	$firstlaunch = "";
	$longesttrip = 0;
	$launches = 0;
	$land = "";
	$lat = 0;
	$lon = 0;
	$mname = "";
	$reset = 0;
	$json_mission = "";
	$json_missionname = "";
	$bpname = "";

	# Pre-check for country
	foreach $line (@lines){
		$line =~ s/[\n\r]//g;
		if($line =~ /^country:\t(.*)/){ $country = $1; }
		if($incountry){
			if($line =~ / -[\t\s]*(.*)/){
				if($country){ $country .= ";"; }
				$country .= $1;
			}
		}
		# Which section of the yaml are we in?
		if($line =~ /^qualifications:/){ $inmission = 0; $inrefs = 0; $inquals = 1; $ineva = 0; $incountry = 0; $inbirthplace = 0; }
		if($line =~ /^references:/){ $inmission = 0; $inrefs = 1; $inquals = 0; $ineva = 0; $incountry = 0; $inbirthplace = 0; }
		if($line =~ /^missions:/){ $inmission = 1; $inrefs = 0; $inquals = 0; $ineva = 0; $incountry = 0; $inbirthplace = 0; }
		if($line =~ /^evas:/){ $ineva = 1; $inmission = 0; $inrefs = 0; $inquals = 0; $incountry = 0; $inbirthplace = 0; }
		if($line =~ /^country:/){ $ineva = 0; $inmission = 0; $inrefs = 0; $inquals = 0; $incountry = 1; $inbirthplace = 0; }
		if($line =~ /^gender:/){ $ineva = 0; $inmission = 0; $inrefs = 0; $inquals = 0; $incountry = 0; $inbirthplace = 0; }
		if($line =~ /^twitter:/){ $ineva = 0; $inmission = 0; $inrefs = 0; $inquals = 0; $incountry = 0; $inbirthplace = 0; }
		if($line =~ /^country:/){ $ineva = 0; $inmission = 0; $inrefs = 0; $inquals = 0; $incountry = 1; $inbirthplace = 0; }
		if($line =~ /^birthplace:/){ $ineva = 0; $inmission = 0; $inrefs = 0; $inquals = 0; $incountry = 0; $inbirthplace = 1; }
	}

	foreach $line (@lines){
		$line =~ s/[\n\r]//g;	# Remove newline characters
		# Find the values for various properties
		if($line =~ /^name:\t(.*)/){ $name = $1; $name =~ s/\s*$//; }
		if($line =~ /^category:\t(.*)/){ $category = $1; }
		if($line =~ /^gender:\t(.*)/){ $gender = $1; }
	}
	
	foreach $line (@lines){

		$line =~ s/[\n\r]//g;	# Remove newline characters

		# Find the values for various properties
		if($line =~ /^name:\t(.*)/){ $name = $1; $name =~ s/\s*$//; }
		if($line =~ /^dob:\t(.*)/){ $dob = $1; }
		#if($line =~ /^country:\t(.*)/){ $country = $1; }
		if($line =~ /^category:\t(.*)/){ $category = $1; }
		if($line =~ /^gender:\t(.*)/){ $gender = $1; }
		if($line =~ /^twitter:\t(.*)/){ $twitter = $1; }

		if($inmission){

			# Get the current time
			($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = gmtime();

			# Build an ISO 8601 date string for the current time
			$now = sprintf("%04d",$year+1900)."-".sprintf("%02d",$mon+1)."-".sprintf("%02d",$mday)."T".sprintf("%02d",$hour).":".sprintf("%02d",$min)."Z";

			# We need to allow for an astronaut launching on one mission and landing on another.
			# If there is just a launch date we'll assume the next line is the landing date.
			if($line =~ /name:[\t\s]*([^\n\r]*)/){
				$mname = $1;
				if($missions){ $missions .= ";"; }
				$missions .= "$mname";
				if($json_missionname){ $json_missionname .= ";"; }
				$json_missionname .= "$mname";
				if(!$allmissions{$mname}{'name'}){ $allmissions{$mname}{'name'} = $mname; }
			}elsif($line =~ /time_start:[\t\s]*([^\n\r]*)/){
				$t1 = $1;
				$land = "";
				if($t1){
					$launch = $t1;
					$launches++;
					if(!$firstlaunch){
						$firstlaunch = $launch;
						$age = int(duration(fixDate($dob)."T00:00Z",$launch)/(365.25*86400));
						if($age < 17){ 
							warning("<green>$name<none> seems to be <yellow>$age<none> years old at first launch\n");
						}
					}
					if($allmissions{$mname}{'launch'} eq ""){ $allmissions{$mname}{'launch'} = $launch; }
					if($allmissions{$mname}{'launch'} ne "" && $launch ne $allmissions{$mname}{'launch'}){ warning("LAUNCH: $mname\t$launch != $allmissions{$mname}{'launch'}\n"); }
				}else{
					#print "$name has no start time for $mname (may need checking)\n";
				}
			}elsif($line =~ /time_end:[\t\s]*([^\n\r]*)/){
				$t2 = $1;
				if($t2){
					$land = $t2;
					if($allmissions{$mname}{'land'} eq ""){ $allmissions{$mname}{'land'} = $land; }
					if($allmissions{$mname}{'land'} ne "" && $land ne $allmissions{$mname}{'land'}){ warning("LANDING: $mname\t$land != $allmissions{$mname}{'land'}\n"); }
				}else{
					#print "$name has no end time for $mname (may need checking)\n";
				}
			}else{
				if(!$land && $launch){
					if(duration($launch,$now) < 400*86400){
						msg("<cyan>IN SPACE:<none> <green>$name<none> (launched <yellow>$launch<none>)\n");
						$inspace = 1;
						$land = $now;
					}
				}
			}
			
			# If we have both a launch time and a landing time, we 
			# calculate how long they've spent in space, their distance
			# travelled etc.
			if($launch && $land){

				$json_mission .= "{\"names\":\"$json_missionname\",\"a\":\"$launch\",\"b\":\"".($inspace==1 ? "": $land)."\"},";
				$json_missionname = "";
				$launchstr = $launch;
				$launchstr =~ s/T.*$//g;
				$landstr = ($inspace==1 ? "": $land);
				$yearstr = $landstr;
				$yearstr =~ s/T.*$//g;
				if($country eq ""){ print "Can't find country for $name\n"; }
				@countries = split(/;/,$country);
				$n = @countries;
				$countrystr = '';
				for($n = 0; $n < @countries; $n++){
					if($countrystr){ $countrystr .= "/"; }
					$countrystr .= '<span class="country '.$countries[$n].'">'.$countrycode{$countries[$n]}.'</span>';
				}
				#push(@li,'<li><span class="d"><time datetime="'.$launch.'">'.$launchstr.'</time>-<time datetime="'.$land.'">'.$landstr.'</time></span>/<span class="name">'.$name.'</span>/'.$countrystr.'/<time datetime="'.$dob.'" class="dob">'.$dob.'</time><span class="human '.$category.'"></span></li>');
				# We temporarily put the category at the end for the purposes of sorting
				push(@li,'<li><a href="'.$url.$file.'" class="padder"><time datetime="'.$launch.'">'.$launchstr.'</time><span class="divider">-</span><time datetime="'.$landstr.'">'.$yearstr.'</time><span class="divider">/</span><span class="name">'.$name.'</span><span class="human '.$category.'"></span></a></li>');

				$durn = duration($launch,$land);
				$totaltime += $durn;
				$totaltrips++;

				if($durn > $longesttrip){ $longesttrip = $durn; }
				$timeinspace += $durn;	# Add the duration
				$timedilation += $durn*(($mname =~ /Apollo/ ? $gamma_moon : $gamma_leo)-1);

				# For Apollo missions we'll set the distance as that to the Moon and back (380,000 km each way)
				$distance += ($mname =~ /Apollo/ ? 760000000 : $speed_leo*$durn);

				# Work out the years the astronaut is in space
				$launch =~ /^([0-9]{4})/;
				$y = $1;
				addToYear($y,$gender,$category,$name,$country,$firstlaunch);

				$land =~ /^([0-9]{4})/;
				if($1 ne $y){
					$y2 = $1;
					$added = 0;
					
					# Loop over the years of the mission
					for($ytemp = $y+1 ; $ytemp <= $y2; $ytemp++){
						addToYear($ytemp,$gender,$category,$name,$country,$firstlaunch);
						$added++;
					}
					if($added > 2){ warning("TOO MANY YEARS FOR <green>$name<none>\n"); }
				}

				$launch = "";
			}
		}

		# Get the length of the extra-vehicular activity
		if($ineva){
    		if($line =~ /duration:[\s\t]*([0-9dhms]*)/){
				$eva_dur = $1;
    			$e = extractTime($eva_dur);
				#msg("<green>$name<none> has EVA duration set as <yellow>$e<none> ($eva_start) rather than start/end times\n");
				if($e > $longesteva){ msg("EVA = $e ($1 $name ; $evas)\n"); $longesteva = $e; }
				$eva += $e;
				$totaleva += $e;
				$evas++;
    		}elsif($line =~ /time_start:[\s\t]*([0-9\-\:TZ]*)/){
    			$eva_start = $1;
    			$eva_end = "";
				$eva_dur = "";
    		}elsif($line =~ /time_end:[\s\t]*([0-9\-\:TZ]*)/){
    			$eva_end = $1;
    			if($eva_start){
					$e = duration($eva_start,$eva_end);
					if($e < 0){ error("<green>$name<none> duration is <yellow>$e<none> ($eva_start)\n"); }
					if($e > $longesteva){ msg("New longest EVA duration = $e ($eva_start $name ; $evas)\n"); $longesteva = $e; }
					$eva += $e;
					$totaleva += $e;
					$evas++;
					$eva_start = "";
					$eva_end = "";
					$eva_dur = "";
				}
    		}
		}
		# Build a reference list
		if($inrefs){
			if($line =~ / -[\t\s]*(.*)/){
				$refs = $1;
				$reflist .= "* **$name**: $refs\n";
			}
		}
		if($inquals){
			if($line =~ / -[\t\s]*(.*)/){
				if($quals){ $quals .= ";"; }
				$quals .= "$1";
			}
		}
		# Get the length of the extra-vehicular activity
		if($inbirthplace){
			if($line =~ /name\:[\t\s]*(.*)/){ $bpname = $1; }
			if($line =~ /latitude\:[\t\s]*(.*)/){ $lat = $1; }
			if($line =~ /longitude\:[\t\s]*(.*)/){ $lon = $1; }
		}
		#if($incountry){
		#	if($line =~ / -[\t\s]*(.*)/){
		#		if($country){ $country .= ";"; }
		#		$country .= $1;
		#	}
		#}
		
		$name =~ s/\"/\'/g;	# Fix nickname quoting
		
		$wasineva = $ineva;

		# Which section of the yaml are we in?
		if($line =~ /^qualifications:/){ $inmission = 0; $inrefs = 0; $inquals = 1; $ineva = 0; $incountry = 0; $inbirthplace = 0; }
		if($line =~ /^references:/){ $inmission = 0; $inrefs = 1; $inquals = 0; $ineva = 0; $incountry = 0; $inbirthplace = 0; }
		if($line =~ /^birthplace:/){ $inmission = 0; $inrefs = 0; $inquals = 0; $ineva = 0; $incountry = 0; $inbirthplace = 1; }
		if($line =~ /^missions:/){ $inmission = 1; $inrefs = 0; $inquals = 0; $ineva = 0; $incountry = 0; $inbirthplace = 0; }
		if($line =~ /^evas:/){ $ineva = 1; $inmission = 0; $inrefs = 0; $inquals = 0; $incountry = 0; $inbirthplace = 0; $eva_start = ""; $eva_end = ""; }
		if($line =~ /^country:/){ $ineva = 0; $inmission = 0; $inrefs = 0; $inquals = 0; $incountry = 1; $inbirthplace = 0; }
		if($line =~ /^gender:/){ $ineva = 0; $inmission = 0; $inrefs = 0; $inquals = 0; $incountry = 0; $inbirthplace = 0; }
		if($line =~ /^twitter:/){ $ineva = 0; $inmission = 0; $inrefs = 0; $inquals = 0; $incountry = 0; $inbirthplace = 0; }

		if($wasineva && !$ineva && $eva_start ne "" && ($eva_end eq "" && $eva_dur eq "")){
			error("No end of EVA for <green>$name<none>.\n");				
		}

	}
	
	$json_mission =~ s/\,$//;

	# If the person has spent time in space we build some JSON for them
	if($timeinspace){

		# Add geojson marker
		$colour = "#000000";
		if($category =~ /astronaut/){ $colour = "#00a2d3"; }
		if($category =~ /cosmonaut/){ $colour = "#f04031"; }
		if($category =~ /taikonaut/){ $colour = "#ffcb06"; }
		if($category =~ /international/){ $colour = "#67c18d"; }
		if($category =~ /tourist/ || $category =~ /commercial/){ $colour = "#7c52a1"; }
		if($geojson){ $geojson .= ","; }
		$tname = $name;
		$tname =~ s/\"/\\\"/g;
		$geojson .= "{\n\t\"type\": \"Feature\",\n\t\"geometry\": {\n\t\t\"type\": \"Point\",\n\t\t\"coordinates\": [$lon, $lat]\n\t},\n\t\"properties\": {\n\t\t\"title\": \"$tname\",\n\t\t\"date\": \"$dob\",\n\t\t\"birthplace\": \"$bpname\",\n\t\t\"data\": \"$url$file\",\n\t\t\"marker-size\": \"medium\",\n\t\t\"marker-color\": \"$colour\",\n\t\t\"marker-symbol\": \"circle\"\n\t}\n}";

		# Add astronaut to JSON
		$json .= "\"$name\":{\"category\":\"$category\",\"gender\":\"$gender\",\"dob\":\"$dob\",\"country\":\"$country\",\"eva\":$eva,\"file\":\"$file\",\"missions\":[$json_mission]".($twitter ne "" ? ",\"twitter\":\"$twitter\"" : "").",\"birthplace\":{\"lat\":$lat,\"lon\":$lon}},\n";
		if($lat == 0 && $lon == 0){
			warning("BIRTH PLACE: <green>$name<none> has no coordinates\n");
		}
	}
	# Print a warning that no gender (Male/Female/Other) is set
	if($gender ne "Male" && $gender ne "Female" && $gender ne "Other"){ warning("<green>$name<none> is without a gender (Male/Female/Other)\n"); }

	# If anyone doesn't have a country but is defined as "astronauts" we'll set their country to the USA
	if(!$country && $category eq "astronauts"){ $country = "USA"; }

	# Store some tsv data for them
	push(@output,"$name\t$country\t$gender\t$dob\t".sprintf("%.2f",$timeinspace/86400)."\t$timeinspace\t$eva\t$launches\t$evas\t$firstlaunch\t".sprintf("%.6f",$timedilation)."\t$age\t$quals\t$missions\t".sprintf("%.2f",$longesttrip/86400)."\t".sprintf("%d",$distance/1000)."\t".formatTime($eva)."\t".$category."\t".$file."\t".($inspace ? $now : "")."\t".$twitter);

}

if($geojson){
	# Change indentation
	$geojson =~ s/\n/\n\t\t/g;
	$geojson = "{\n\t\"type\": \"FeatureCollection\",\n\t\"features\": [\n\t\t$geojson\n\t]\n}\n";
	open(FILE,">",$procdir."birthplaces.geojson");
	print FILE "$geojson";
	close(FILE);
}

$html = "{\n";
foreach $my (sort{ $allmissions{$a}{'launch'} <=> $allmissions{$b}{'launch'} } keys(%allmissions)){
	if($my && $allmissions{$my}{'launch'}){
		$html .= "\t\"$my\": { \"launch\":\"$allmissions{$my}{'launch'}\",\"land\":\"$allmissions{$my}{'land'}\" },\n";
	}
}
$html =~ s/\,\n$/\n/g;
$html .= "}\n";
open(FILE,">",$procdir."missions.json");
print FILE "$html";
close(FILE);

$json =~ s/\,$//;
$json = "{$json}\n";
open(FILE,">",$procdir."astronauts.json");
print FILE "$json";
close(FILE);

open(FILE,">",$procdir."astronauts.tsv");
print FILE "Name\tCountry\tGender\tDate of Birth\tTime in Space (days)\tTime in Space (s)\tEVA Time (s)\tNumber of Launches\tNumber of EVAs\tFirst Launch\tTime dilation (s)\tAge at first launch (yr)\tQualifications\tMissions\tLongest single trip (days)\tTotal distance covered (km)\tEVA (hh:mm)\tType\tFilename\tIn space as of\tTwitter";
$i = 0;
foreach $out (@output){
	if($i > 0){ print FILE "\n"; }
	print FILE "$out";
	$i++;
}
close(FILE);

open(FILE,'who.html');
@lines = <FILE>;
close(FILE);
open(FILE,'>','who.html');
$inmain = 0;
$indent = "";
foreach $line (@lines){

	if($line =~ /<\!-- End Timeline -->/){ $inmain = 0; }
	if($inmain==0){ print FILE $line; }
	if($line =~ /^([\s]*)<\!-- Start Timeline -->/){
		$inmain = 1;
		$indent = $1; 
		print FILE $indent."<ol class=\"timeline\">\n";
		@li = reverse(sort(@li));
		for($i = 0; $i < @li; $i++){
			$li[$i] =~ s/(<li)(>.*)<span( class="human[^\"]*")><\/span>/$1$3$2/g;
			# Only add those currently in space as raw HTML
			if($li[$i] =~ /<span class="divider">-<\/span><time datetime=""><\/time>/){
				print FILE $indent."\t".$li[$i]."\n";
			}
		}
		print FILE $indent."</ol>\n";
	}
}
close(FILE);


msg("Save output to process directory: <cyan>$procdir<none>\n");
open(FILE,">",$procdir."references.md");
print FILE "# References\n";
print FILE $reflist;
close(FILE);



open(FILE,">",$procdir."astronauts_by_year.tsv");
#print FILE "Year\tNumber of astronauts in space\tNumber of male astronauts\tNumber of female astronauts\n";
foreach $y (sort(keys(%byyear))){
	if($y){
		print FILE "$y\t$byyear{$y}{'total'}\t$byyear{$y}{'Male'}{'total'}\t$byyear{$y}{'Female'}{'total'}\n";
	}
}
close(FILE);

open(HTML,"yearly.html");
@lines = <HTML>;
close(HTML);


open(HTML,'>','yearly.html');
%firsts;
$inmain = 0;
$indent = "";
foreach $line (@lines){

	if($line =~ /<\!-- End Timeline -->/){ $inmain = 0; }
	if($inmain==0){ print HTML $line; }
	if($line =~ /^([\s]*)<\!-- Start Timeline -->/){
		$inmain = 1;
		$indent = $1; 
		print HTML $indent."<table>\n";
		print HTML $indent."\t<tr><td class=\"female\">Female astronauts</td><td class=\"year\">Year</td><td class=\"male\">Male astronauts</td></tr>\n";
		foreach $y (sort(keys(%byyear))){
			if($y){
				@{$byyear{$y}{'Male'}{'cls'}} = sort(@{$byyear{$y}{'Male'}{'cls'}});
				print HTML $indent."\t<tr><td class=\"female\"><span class=\"number\">$byyear{$y}{'Female'}{'total'}</span> ";
				for($i = 0; $i < $byyear{$y}{'Female'}{'total'}; $i++){
					($firstlaunch,$cls,$nme,$country) = split(/\=\=/,$byyear{$y}{'Female'}{'cls'}[$i]);
					$str = "human $cls";
					(@cs) = split(/;/,$country);
					for($c = 0; $c < @cs; $c++){
						#$str .= " country-$cs[$c]";
						if(!$firsts{$cs[$c].'-female'}){ $str .= " first"; }
						$firsts{$cs[$c].'-female'} = 1;
					}
					print HTML "<span class=\"$str\" title=\"$nme\">&nbsp;</span>";
				}
				print HTML "</td><td class=\"year\"><span class=\"number\">$y</span></td><td class=\"male\">";
				for($i = 0; $i < $byyear{$y}{'Male'}{'total'}; $i++){
					($firstlaunch,$cls,$nme,$country) = split(/\=\=/,$byyear{$y}{'Male'}{'cls'}[$i]);
					$str = "human $cls";
					(@cs) = split(/;/,$country);
					for($c = 0; $c < @cs; $c++){
						#$str .= " country-$cs[$c]";
						if(!$firsts{$cs[$c].'-male'}){ $str .= " first"; }
						$firsts{$cs[$c].'-male'} = 1;
					}
					print HTML "<span class=\"$str\" title=\"$nme\">&nbsp;</span>";
				}
				print HTML "<span class=\"number\">$byyear{$y}{'Male'}{'total'}</span> </td></tr>\n";
			}
		}
		print HTML "</table>";


#		@li = reverse(sort(@li));
#		for($i = 0; $i < @li; $i++){
#			$li[$i] =~ s/(<li)(>.*)<span( class="human[^\"]*")><\/span>/$1$3$2/g;
#			# Only add those currently in space as raw HTML
#			if($li[$i] =~ /<span class="divider">-<\/span><time datetime=""><\/time>/){
#				print FILE $indent."\t".$li[$i]."\n";
#			}
#		}
#		print HTML $indent."</ol>\n";
	}
}
close(HTML);



msg("Longest EVA: <yellow>".formatLongTime($longesteva)."<none>\n");
msg("Total EVA: <yellow>".formatLongTime($totaleva)."<none>\n");
msg("Total time in space: <yellow>".formatLongTime($totaltime)."<none>\n");
msg("Total trips: <yellow>$totaltrips\n");





#######################

sub msg {
	my $str = $_[0];
	my $dest = $_[1]||STDOUT;
	foreach my $c (keys(%colours)){ $str =~ s/\< ?$c ?\>/$colours{$c}/g; }
	print $dest $str;
}

sub error {
	my $str = $_[0];
	$str =~ s/(^[\t\s]*)/$1<red>ERROR:<none> /;
	foreach my $c (keys(%colours)){ $str =~ s/\< ?$c ?\>/$colours{$c}/g; }
	msg($str,STDERR);
}

sub warning {
	my $str = $_[0];
	$str =~ s/(^[\t\s]*)/$1$colours{'yellow'}WARNING:$colours{'none'} /;
	foreach my $c (keys(%colours)){ $str =~ s/\< ?$c ?\>/$colours{$c}/g; }
	print STDERR $str;
}

sub fixDate {
	my $d = $_[0];
	$d =~ s/\?\?/01/g;
	if(length($d)==4){
		$d .= "-01-01";	# We don't know the month or day so set them to the start of the year
	}
	if(length($d)==7){
		$d .= "-01";	# We don't know the day so set it to the start of the month
	}
	return $d;
}



sub addToYear {
	local $y = $_[0];
	local $gender = $_[1];
	local $category = $_[2];
	local $name = $_[3];
	local $country = $_[4];
	local $firstlaunch = $_[5];
	
	if(!$byyear{$y}){ $byyear{$y} = { 'total' => 0 }; }
	if(!$byyear{$y}{$gender}){ $byyear{$y}{$gender} = { 'total' => 0, 'cls' => () }; }

	$byyear{$y}{'total'}++;
	$byyear{$y}{$gender}{'total'}++;
	if($country eq "RUS"){ $country = "URS"; }
	push(@{$byyear{$y}{$gender}{'cls'}},$firstlaunch."==".$category."==".$name."==".$country);

	return;
}
