#!/bin/sh

#   Simple testing script
#   Author: Lukas Chabek

yellow="\033[33m"
green="\033[32m"
red="\033[31m"
clear="\033[0m"

test_output="true"

executable="app_to_test"

test_folder="tests"
temp_error_output_ext="out"
temp_error_output="temp_file_test.${temp_error_output_ext}"

temp_output_ext="output"
temp_output="temp_file_test.${temp_output_ext}"

temp_ret_code_ext="code"
temp_ret_code="temp_file_test.${temp_ret_code_ext}"


if [ -n "$1" ]
then
    if [ "$1" = "help" ]
    then
        printf "${yellow}Script for simple testing${clear}\n\tTests return code and output error text.\n\tScript can be run with one argument.\n"
        printf "\n\tCreate a test with './test.sh TestName'\n\tThen feel filed in directory '${test_folder}' and launch with ./test.sh.\n"
        printf "\n\tGenerated Files (example: './test.sh example'):\n"

        printf "\t${yellow}${test_folder}/example.launch${clear}"
        printf "\tServes for launch arguments.\n"
        printf "\t${yellow}${test_folder}/example.${temp_error_output_ext}${clear}"
        printf "\tServes for standard error output from application.\n"
        printf "\t${yellow}${test_folder}/example.${temp_output_ext}${clear}"
        printf "\tServes for standard output from application.\n"
        printf "\t${yellow}${test_folder}/example.${temp_ret_code_ext}${clear}"
        printf "\tServes for return code from application.\n"
        exit 0
    else
        if [ ! -d $test_folder ]
        then
            mkdir $test_folder
        fi
        touch ${test_folder}/$1.${temp_error_output_ext} ${test_folder}/$1.${temp_ret_code_ext} ${test_folder}/$1.launch ${test_folder}/$1.${temp_output_ext}
        exit 0
    fi
fi

if [ ! -d $test_folder ]
then
    printf "${red}No tests were found.${clear}\n\tCreate a test with './test.sh TestName'\n"
    exit 0
fi

printf "${yellow}Test output is set to ${clear}${green}${test_output}${clear}${yellow}.${clear}\n"

printf "${yellow}Building project with make:${clear}\n"
make
if [ ! $? -eq 0 ]
then
    printf "${red}Build Failed.${clear}\n"
    exit 0
fi
printf "${green}Build Succeeded.${clear}\n"

tests_count=0
tests_succ=0
for test_path in ${test_folder}/*.launch
do
    tests_count=$((tests_count+1))

    test_param=`cat ${test_path}`
    test_file=${test_path##*/}
    test_name=${test_file%.*}

    printf "${yellow}Test ${test_name}:${clear} "

    ./${executable} ${test_param} 2> ${test_folder}/${temp_error_output} > ${test_folder}/${temp_output}
    printf "$?\n" > ${test_folder}/${temp_ret_code}

    return_code=`cat ${test_folder}/${temp_ret_code} | tr -d "\n"`

    diff_store=`diff -a ${test_folder}/${test_name}.${temp_ret_code_ext} ${test_folder}/${temp_ret_code}`


    if [ -n "${diff_store}" ]
    then
        printf "${red}Failed Return Code.${clear}\n\tExpected error code "
        cat ${test_folder}/${test_name}.${temp_ret_code_ext} | tr -d "\n"
        printf " but got ${return_code}\n"
        continue
    fi

    if [ ! ${return_code} -eq 0 ]
    then
        diff_err_ret=`diff -a ${test_folder}/${test_name}.${temp_error_output_ext} ${test_folder}/${temp_error_output}`
        if [ -n "${diff_err_ret}" ]
        then
            printf "${red}Failed Error Message.${clear}\n\tExpected error message '"
            cat ${test_folder}/${test_name}.${temp_error_output_ext}
            printf "' but got '"
            cat ${test_folder}/${temp_error_output}
            printf "'\n"
            continue
        fi
    fi

    if [ "${test_output}" = "true" ]
    then
    diff_output=`diff -a ${test_folder}/${test_name}.${temp_output_ext} ${test_folder}/${temp_output}`
        if [ -n "${diff_err_ret}" ]
        then
            printf "${red}Failed Output.${clear}\n\tExpected output '"
            cat ${test_folder}/${test_name}.${temp_output_ext}
            printf "' but got '"
            cat ${test_folder}/${temp_output}
            printf "'\n"
            continue
        fi
    fi
    printf "${green}Passed.${clear}\n"
    tests_succ=$((tests_succ+1))
done

printf "${yellow}[Summary] ${clear}"

if [ $tests_count -eq $tests_succ ]
then
    printf "${green}"
else
    printf "${red}"
fi

printf "${tests_succ} tests passed from total of ${tests_count}${clear}\n"

rm -f ${test_folder}/${temp_error_output} ${test_folder}/${temp_ret_code} ${test_folder}/${temp_output}