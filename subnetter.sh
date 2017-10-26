#!/bin/bash
 
# ==============================================================================
#        TOPIC -  SUBNETTING / 24 (CIDR - Classless Inter Domain Routing)
# ==============================================================================
 


# ==============================================================================
#				   QUESTION
# ==============================================================================

# ??? BASH SCRIPT  to subdivide ONLY GIVEN CIDR/24  
# ??? into predefined number of smaller subnets (CIDR/25-29)


# CONDITION : 3 IPs (NETWORK,GATEWAY,BROADCAST) for each subnet should be 
#	          reserved. Hence MINIMUM NO. OF IPs / SUBNET = 4 ;
#
# NOTE :  Hence CIDR / 30-32 are not possible. 
#	      Because MINIMUM NO. OF IPs / SUBNET for
#         CIDR/30 = 4 , CIDR/31 = 2 , CIDR/32 =1 ;

# ---------------------------------END------------------------------------------


           	
# ==============================================================================
# 			        EXAMPLE 
# ==============================================================================  
# INPUT             :  ./subnetter.sh 192.168.0.0/24 3

# EXPECTED OUTPUT   :  subnet=192.168.0.0/25    network=192.168.0.0  
#                      gateway=192.168.0.1      broadcast=192.168.127  hosts=125
#
#                      subnet=192.168.0.128/26  network=192.168.0.128  
#                      gateway=192.168.0.129    broadcast=192.168.191  hosts=61
#
#		               subnet=192.168.0.192/26  network=192.168.0.0  
#                      gateway=192.168.0.1      broadcast=192.168.127  hosts=61

# ----------------------------------END------------------------------------------


# ==============================================================================
#          MODULE 1.0 - PARAMETERS STORING , VARIABLE DECLARATION & CHECKING  
# ==============================================================================

# INPUT variables

PARAM_1="$1"; # The first parameter   (i.e) 192.168.0.0/24
PARAM_2="$2"; # The second parameter  (i.e) 3

# OUTPUT variables

SUBNET="";
NETWORK="";
GATEWAY="";
BROADCAST="";
HOSTS="";


# Check whether the user gave exactly two parameters

if [[ $# -ne 2 ]] ; then       
    # $#  --> No of arguments ; ne --> not equal to
    printf " Give exactly TWO parameters. No more , no less \n ";
    exit 1;
fi;

# ----------------------------MODULE END----------------------------------------


# ==============================================================================
#               MODULE 2.0 - PARAMETER1 SEPARATION
# ==============================================================================

# Separate parameter1 into ----> IP PART and SLASH NOTATION PART
# Internal Field Separator (IFS) - Using IFS we are going to separate the string
# 192.168.0.0/24 -----> 192.168.0.0 (IP PART)  and 24 ( SLASH NOTATION PART )

OLD_IFS=$IFS;  # Store the old IFS default one (i.e.,) "SPACE"
IFS='/';       # New IFS

read -ra ADDR <<< "${PARAM_1}";  # ADDR = { 192.168.0.0 , 24 }

PRIME_NETWORK="${ADDR[0]}"; # 192.168.0.0
PRIME_MASK="${ADDR[1]}";    # 24

# echo $PRIME_NETWORK;
# echo $PRIME_MASK;

# ----------------------------MODULE END----------------------------------------


# ============================================================================== 
#               MODULE 2.1 - OCTET SEPARATION 
# ==============================================================================

IFS='.';
read -ra ADDR <<< "$PRIME_NETWORK";   # ADDR = { 192 , 168 , 0 , 0 }

P_OCTET1="${ADDR[0]}";  # 192
P_OCTET2="${ADDR[1]}";  # 168
P_OCTET3="${ADDR[2]}";  # 0
P_OCTET4="${ADDR[3]}";  # 0

#Code for another way to get octet value is given in next line in comment below
# P_OCTET1 = `echo "$PRIME_NETWORK" | awk -F\. '{print $1}'`;

IFS=$OLD_IFS   # Reset to old default value (i.e) "SPACE"

# ----------------------------MODULE END----------------------------------------

# ==============================================================================
#            MODULE 3.0 - 4th OCTET MANIPULATION AND LIMITS 
# ==============================================================================
# This program only works if there is change in 4th octet (i.e)/24 ( wont work for
# anyother octets)

# Check whether we are working in 4th octet or not
if [[ `echo "32-$PRIME_MASK" | bc` -lt 9 ]];then  # bc - calculator , 32 -24 = 8      
    echo;   
    #echo "Working in 4th OCTET ";
else
    echo "Not 4th OCTET . Slash notation should be greater than 24 ";
    exit 1;
fi;

# These all below values are calculated WITH RESPECT TO 4TH OCTET ONLY

SLASH_VALUE=`echo "(32-$PRIME_MASK)" | bc`; # 32-24 = 8 ; Value shouldn't be <= 2.
CURRENT_SUBNETS=`echo "2^(8-$SLASH_VALUE)" | bc`; # 2^(8-8) = 1 Subnet.
IPS_PER_SUBNET=`echo "256/2^(8-$SLASH_VALUE)" | bc`; # 256 IP's per Subnet.

#echo "Current Slash Value ( w.r.t 4th octet) = ${SLASH_VALUE}"; # 8
#echo "Current No of Subnets ( CLASS C ) = ${CURRENT_SUBNETS}";  # 1
#echo "Current No of IP's / Subnet = ${IPS_PER_SUBNET}";         # 256

# ----------------------------MODULE END----------------------------------------



# ============================================================================== 
#                        MODULE 3.1 - MAIN LOGIC 
# ==============================================================================

REQUIRED_SUBNETS=$2;
MIN_IPS=4;               
# Since every subnet should have 3 IP addresses reserved.
# So a subnet should contain atleast 4 IP addresses.
# NETWORK IP , GATEWAY IP , BROADCAST IP and atleast 1 HOST IP. So min = 4


MAX_IPS=$IPS_PER_SUBNET;  # Maximum number of ip's per subnet. (i.e ) 256
MAX_SUBNETS=`echo "$MAX_IPS/4" | bc `; # Maximum possible no of subnets 

# echo "${MAX_SUBNETS}" ;    # 256/4 = 64 

#  Check whether Subnet division possible or not. 
#  A subnet should not contain less than 4 IPs.

if [[ ${MAX_SUBNETS} -lt ${PARAM_2} ]]; then
    printf "\n Subnet Division not possible ";
    exit 1;
fi;


# ----------------------------MODULE END----------------------------------------



# ==============================================================================
#           MODULE 3.1.1 - [ CASE 1 ] WHEN PARAMETER2 = 0 
# ==============================================================================

# This test case was written to test if suppose the user purposefully given 
# second argument as 0 which means we dont have to do subnet at all.
# 
# --------------------------------------------------------------------------------
# EXAMPLE :

# INPUT             :  ./subnetter.sh 192.168.0.0/24 0

# EXPECTED OUTPUT   :  subnet=192.168.0.0/24    network=192.168.0.0  
#                      gateway=192.168.0.1      broadcast=192.168.255  hosts=253 
# --------------------------------------------------------------------------------

if [[ ${PARAM_2} -eq 0 ]]; then

t=0;  # A temporary variable
SUBNET=$(echo "${P_OCTET1}.${P_OCTET2}.${P_OCTET3}.${P_OCTET4}/$PRIME_MASK");
NETWORK=$(echo "${P_OCTET1}.${P_OCTET2}.${P_OCTET3}.${P_OCTET4}");

t=`echo "${P_OCTET4}+1" | bc `;
GATEWAY=$(echo "${P_OCTET1}.${P_OCTET2}.${P_OCTET3}.${t}");

t=`echo "${P_OCTET4}+${MAX_IPS}-1" | bc `;
BROADCAST=$(echo "${P_OCTET1}.${P_OCTET2}.${P_OCTET3}.${t}");
HOSTS=$(echo "`echo "${MAX_IPS}-3" | bc`");


echo "Subnet=$SUBNET  
Network=$NETWORK  
Gateway=$GATEWAY  
Broadcast=$BROADCAST  
Hosts=$HOSTS
";

fi;

# ----------------------------MODULE END----------------------------------------

   
# ==============================================================================
#           MODULE 3.1.2 - [ CASE 2 ] WHEN PARAMETER2 >= 1
# ==============================================================================

# --------------------------------------------------------------------------------
# EXAMPLE :

# INPUT             :  ./subnetter.sh 192.168.0.0/24 3

# EXPECTED OUTPUT   :  subnet=192.168.0.0/25    network=192.168.0.0  
#                      gateway=192.168.0.1      broadcast=192.168.127  hosts=125 
						
# 					   subnet=192.168.0.128/26    network=192.168.0.128  
#                      gateway=192.168.0.129      broadcast=192.168.191  hosts=61

# 					   subnet=192.168.0.192/26    network=192.168.0.192  
#                      gateway=192.168.0.193      broadcast=192.168.255  hosts=61

# --------------------------------------------------------------------------------

REMAINDER=${PARAM_2};    # REMAINDER VARIABLE is to keep track of still how many 
SUM=0;					 # subnets are yet to be created . Other varibles are all
j=0;					 # just temporary usage variables.
COUNT=0;
FLAG=0;
SUM1=0;
TEMP1=${P_OCTET4};


# !!!!!!!!!!!! !!!!! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
# THIS IS THE MAIN FUNCTION OF THIS PROGRAM WHICH CALCULATE AND PRINTS THE VALUES 
function POW_OF_2 {

SUM1=`echo "${SUM1}+$1" | bc ` ;
a=`echo "$PRIME_MASK+${SUM1}" | bc `;
IPS_PER_SUBNET=`echo "2^(32-$a)" | bc`;
b=$IPS_PER_SUBNET;
LIMIT=0;


# If flag=1 , Subnetting is over
#If flag=0 , further subnetting is there

if [[ FLAG -eq 1 ]]; then
	LIMIT=`echo "2^$1" | bc`;
else
	LIMIT=`echo "(2^$1)-1" | bc`
fi

# Main Calculations

for (( m=1; m<=${LIMIT}; m++ )) ; do

q=`echo "${TEMP1}+(${m}-1)*${b}" | bc `;
SUBNET=$(echo "${P_OCTET1}.${P_OCTET2}.${P_OCTET3}.${q}/$a");
NETWORK=$(echo "${P_OCTET1}.${P_OCTET2}.${P_OCTET3}.${q}");

q=`echo "${q}+1" | bc `;
GATEWAY=$(echo "${P_OCTET1}.${P_OCTET2}.${P_OCTET3}.${q}");

q=`echo "${q}+${b}-2" | bc `;
BROADCAST=$(echo "${P_OCTET1}.${P_OCTET2}.${P_OCTET3}.${q}");

HOSTS=$(echo "${b}-3" | bc);     

echo "Subnet=$SUBNET  
Network=$NETWORK  
Gateway=$GATEWAY  
Broadcast=$BROADCAST  
Hosts=$HOSTS
";

done;

TEMP1=`echo "${q}+1" | bc `;
#echo "HI NEXT ${TEMP1}";

}
# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
# A  FUNCTION  FOR  CALCULATING  THE  NEAREST POWER OF  2
# For 7 --> 4 ; 9 --> 8 ; 3 --> 2 ; 18 --> 16 ; 15 --> 8 

function FLOOR_POW_OF_2 {

	TEMP=${1};
	SUM=0;j=0;
	
	until [[ ${SUM} -ge ${TEMP} ]]; do
		SUM=`echo "2^${j}" | bc `;  # 0,1,2,4,8,16,32,.....
		COUNT=`echo "${j}-1" | bc `;
		j=`echo "${j}+1" | bc `;    # 0,1,2,3,4,5,.........
	done
		#echo "HI ${COUNT}"


		if [[ ${SUM} -eq ${TEMP} ]]; then
			FLAG=1;
			COUNT=`echo "${COUNT}+1" | bc`;
			POW_OF_2 ${COUNT};
			REMAINDER=0; 
		else
			FLAG=0;
			POW_OF_2 ${COUNT}; 
			REMAINDER=`echo "(${TEMP}-${SUM}/2)+1" | bc`;
			# Power of 2 extraction.  
		fi

}


# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

while [[ ${REMAINDER} -ne 0 ]]; do
	FLOOR_POW_OF_2 ${REMAINDER};
done;

# ---------------------------------------------------------------------------
