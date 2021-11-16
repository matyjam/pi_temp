#!/bin/bash
# Script: pi_temp.sh
# Purpose: Display the ARM CPU and GPU  temperature of Raspberry Pi 2/3/4 and volage, current of LiFePo4wered battery module
# Author: Maiusz Matyja under GPL v3.x+
# -------------------------------------------------------

OPTIND=1        # reset getopts

lp=false

while getopts "hl" opt
do
    case "$opt" in
        h)
           echo "Usage: $0 [OPTIONS]"
           echo "Option		Meaning"
           echo "-h		This help"
           echo "-l		Loop mode"
           exit 0
           ;;
        l)
           lp=true
           ;;
    esac
done

shift $((OPTIND-1))

[ "${1:-}" = "--" ] && shift

y=1
x=1

if [ $lp == "true" ] ; then  clear ; tput civis ; stty -ctlecho  ; fi

on_trap() {
    tput cnorm
    stty ctlecho
    exit 0
}

trap 'on_trap' SIGINT

while true
do
    cpu=$(</sys/class/thermal/thermal_zone0/temp)
    lifepo4_vin=0$(lifepo4wered-cli get vin)
    lifepo4_vout=0$(lifepo4wered-cli get vout)
    lifepo4_iout=0$(lifepo4wered-cli get iout)

    if [ $lp == "true" ] ; then tput cup $y $x ; fi

    echo "$(date) @ $(hostname)"
    echo "-------------------------------------------"
    echo "GPU => $(/opt/vc/bin/vcgencmd measure_temp)"
    echo "CPU => $((cpu/1000))'C"
    echo ""
    echo "Vin   => ${lifepo4_vin: ${#lifepo4_vin}<5?0:1 :1}.${lifepo4_vin: ${#lifepo4_vin}<5?1:2 } V"
    echo "Vout  => ${lifepo4_vout: ${#lifepo4_vout}<5?0:1 :1}.${lifepo4_vout: ${#lifepo4_vout}<5?1:2 } V"
    echo "Vout  => ${lifepo4_iout: ${#lifepo4_iout}<5?0:1 :1}.${lifepo4_iout: ${#lifepo4_iout}<5?1:2 } A"
    echo ""

    if [ $lp == "false" ] ; then break ; fi
    sleep 0.5
done
