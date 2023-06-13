#
#     Copyright 2020 SAP SE Walldorf
#     Author: Michael Trapp
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

##########################################
*** Settings ***
Library    Process
Library    OperatingSystem
Library    /robot/lib/LinuxLab_HRT_Lib.py

Documentation    Check that /etc/os-release is available and the values did not change compared to the GA version of the OS release.

*** Test Cases ***
/etc/os-release
    Should Exist    /etc/os-release
/etc/os-release_NAME
    ${result} =    Grep File    /etc/os-release     NAME="SLES"
    Should Be Equal    ${result}    NAME="SLES"
/etc/os-release_VERSION
    ${result} =    Grep File    /etc/os-release     VERSION="12-SP5"
    Should Be Equal    ${result}    VERSION="12-SP5"
/etc/os-release_VERSION_ID
    ${result} =    Grep File    /etc/os-release     VERSION_ID="12.5"
    Should Be Equal    ${result}    VERSION_ID="12.5"
/etc/os-release_PRETTY_NAME
    ${result} =    Grep File    /etc/os-release     PRETTY_NAME="SUSE Linux Enterprise Server 12 SP5"
    Should Be Equal    ${result}    PRETTY_NAME="SUSE Linux Enterprise Server 12 SP5"
/etc/os-release_ID
    ${result} =    Grep File    /etc/os-release     ID="sles"
    Should Be Equal    ${result}    ID="sles"
