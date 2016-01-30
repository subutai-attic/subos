#!/bin/bash
#Include enviroment variables
. $(cd `dirname "${BASH_SOURCE[0]}"` && pwd)/subutai.env

subutai collect
