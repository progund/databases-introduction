#!/bin/bash

GET 'https://ait.gu.se/utbildning/program/systemvetenskap/om-programmet' |
    grep TIG |
    tr '(' '\n' |
    tr ')' '\n' |
    grep ^TIG
