#!/bin/bash

GET 'https://ait.gu.se/utbildning/program/systemvetenskap/om-programmet' | grep pdf|tr '"' '\n' | grep http|grep pdf|grep TIG|tr '/' '\n'|grep TIG|cut -d '.' -f1
