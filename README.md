# LinuxLab ROBOT Tests
This is the [ROBOT testframework](https://robotframework.org/) based part of the LinuxLab HANA Regression Tests (HRT).
ROBOT is used for acceptance tests of SUSE and Red Hat releases.

Most of the standard test cases can be implemented with a simple one-liner, based on functions in lib/LinuxLab_HRT_Lib.py, because robotframework exports all functions as tests.

    e.g. sysctl_check_param_int() can be used as 'Sysctl Check Param Int'



Test Syntax:

    TEST_NAME
        TAG
        DOCUMENTATION
        CHECK


    TEST_NAME: <any string without ' '>     # by convention CHECK + PARAM_NAME
                                            #   Sysctl_fs_file-max
                                            #   Systemctl_show_Version


    TAG: 'TAG' TAG_NAMES |                  # optional parameter
    TAG_NAMES: TAG_NAMES TAG_NAME           # currently the tags
    TAG_NAME: FIXED | BUG                   #   FIXED and BUG are supported

    DOCUMENTATION: [\S+ ] |                 # optional parameter, technically any text
                                            #   but it should document a change including:
                                            #   - reason for the change
                                            #   - initial settings
                                            #   - c/d-user
                                            #   - date of change

    CHECK:  'Sysctl Check Param Int'    QUAD_SPACE PARAMETER QUAD_SPACE INT_VALUES                      |
            'Sysctl Check Param Str'    QUAD_SPACE PARAMETER QUAD_SPACE STR_VALUE                       |
            'Sysctl Check Param Empty'  QUAD_SPACE PARAMETER QUAD_SPACE STR_VALUE                       |

            'Systemctl Show Int'        QUAD_SPACE PARAMETER QUAD_SPACE INT_VALUE                       |
            'Systemctl Show Str'        QUAD_SPACE PARAMETER QUAD_SPACE STR_VALUE                       |
            'Systemctl Show Regex'      QUAD_SPACE PARAMETER QUAD_SPACE REGEX                           |

            'Bash Builtin'              QUAD_SPACE PARAMETER QUAD_SPACE STR_VALUE                       |
            'Bash Builtin Int'          QUAD_SPACE PARAMETER QUAD_SPACE INT_VALUE                       |
            'User Bash Builtin'         QUAD_SPACE PARAMETER QUAD_SPACE STR_VALUE                       |
            'User Bash Builtin Int'     QUAD_SPACE PARAMETER QUAD_SPACE INT_VALUE                       |

            'Run Cmd Int'               QUAD_SPACE PARAMETER QUAD_SPACE INT_VALUE                       |
            'Run Cmd Str'               QUAD_SPACE PARAMETER QUAD_SPACE STR_VALUE                       |
            'Run Cmd Int Skip'          QUAD_SPACE PARAMETER QUAD_SPACE SKIP_STR QUAD_SPACE INT_VALUE   |
            'Run Cmd Str Skip'          QUAD_SPACE PARAMETER QUAD_SPACE SKIP_STR QUAD_SPACE STR_VALUE   |
            'Run Cmd Empty Skip'        QUAD_SPACE PARAMETER QUAD_SPACE SKIP_STR                        |

            'Pcre Grep File'            QUAD_SPACE PARAMETER QUAD_SPACE REGEX

    PARAMETER: <any string without a QUAD_SPACE>
                                    # this may also include command options
                                    # Sysctl Check Param Int    fs.file-max    4902860
                                    #   PARAMETER       fs.file-max
                                    # Bash Builtin    ulimit -m    unlimited
                                    #   PARAMETER       ulimit -m
                                    # Run Cmd Str Skip    /usr/bin/loginctl show-seat -p HandlePowerKey    HandlePowerKey=    poweroff
                                    #   PARAMETER       /usr/bin/loginctl show-seat -p HandlePowerKey

    SKIP_STR:   <any string without a QUAD_SPACE>
    QUAD_SPACE: '    '
    STR_VALUE:  <any string quoted with ''>
    INT_VALUES: INT_VALUES INT_VALUE
    INT_VALUE:  INT |               # exact match of the parameter value
                                    # 42 -> RESULT == 42
                INT:INT |           # range check 'from:to' of the parameter value
                                    # 42:44 -> 42 <= RESULT <= 44
                INT-INT+INT |       # range check of type A-B+C -> '(A-B):(A+C)'
                                    # 42-1+2 -> (42-1) <= RESULT <= (42+2)
                INT-INT |           # range check of type A-B -> '(A-B):A'
                                    # 42-1 -> (42-1) <= RESULT <= 42
                INT+INT |           # range check of type A+B -> 'A:(A+B)'
                                    # 42+1 -> 42 <= RESULT <= (42+1)
                INT%DOUBLE          # range check of type A%B -> '(A-A/100*B):(A+A/100*B)'
                                    # 42%1 -> (42-42/100*1) <= RESULT <= (42+42/100*1)
    REGEX:      <pcre>
    INT:        <integer value>
    DOUBLE:     <double value>

Based on that you can write checks like:

    Sysctl_fs_file-max
        Sysctl Check Param Int    fs.file-max    4900688%0.01
    Sysctl_net_ipv4_tcp_mem
        Sysctl Check Param Int    net.ipv4.tcp_mem    574200:574400 765650:765750 1148500:1148600
    Systemctl_Show_Version
        Systemctl Show Regex    Version    239.*
    Systemctl_show_DefaultLimitFSIZE
        Systemctl Show Str    DefaultLimitFSIZE    infinity
    Limit_core_file_size
        Bash Builtin    ulimit -c    unlimited
    Limit_core_file_size
        User Bash Builtin    stduser    ulimit -c    unlimited

# SUSE/openSUSE specific documentation

## The sys-param-check test
 
 This project aims to store the reference files used in our sys-param-check tests as well as the associated documentation.<br>
 The tests are built on top of the Robot Framework (an open source automation framework).
 
 ## History
 Sometimes SAP complains about changes on the kernel settings (systctl) we didn't spot or document before.<br>
 That's why they sent us this test for running it during our build validation and maintenance update workflow.<br>
 Like that, we can detect any change before the product/update release, then open a bug and warn SAP about that.

 I don't know what machines SAP uses for running the tests but from our side, we are running them on a 2GB/1VCPU virtual machines.
 That means I had to adapt some dynamic values in the different reference files, several kernel settings depends on the machines resources.
 
 ## How it works
 The test is very easy to understand, for each OS versions, we have reference files both for limits and sysctl settings.<br>
 OpenQA start a virtual machine and compare the live settings with the referenced settings. If one setting does not match, the test fails. You must know the test is running twice a day through the TestRepo maintenance workflow.<br>
 Following a discussion with the SAP labs team, the test must be run on a system without any SAP tunning activated (sapconf/saptune).

 ## Kdump case
 Kdump should be absolutely disabled before running the sys-param-check tests.
 If it's still running, the system will get less memory because Kdump books memory for the crash.
 A lot of sysctl values are dependant to the amount of memory, so we have to make sure that Kdump doesn't reserve it.

 ## Execute the test manually
 First, make sure you are allowed to access to GitLab.

 - Clone the repo:<br>
 `git clone gitlab@gitlab.suse.de:qa-css/sys-param-check.git`<br>
 `cd sys-param-check`

 - Install the robot framework:<br>
 `unzip bin/robotframework-3.2.2.zip`<br>
 `cd robotframework-3.2.2/`<br>
 `python3 setup.py install`

 - Go into the folder of the desired SLES version and execute one of the tests:<br>
 `cd ../tests/$SLE_VERSION/`<br>
 `robot sysctl.robot`

 ## Creating a Verification Run

 1. Have `openqa-clone-job` configured.
 2. Fork this repository with your changes in the main branch (there's no support for selecting a custom branch. `%your-repo%` below).
 3. Find a previously failing job (`%failing-job%` below. z.B: `https://openqa.opensuse.org/tests/3682089`)
 4. Run:
   ```
   openqa-clone-job --skip-chained-deps --host openqa.opensuse.org \
    --from %failing-job% SYS_PARAM_CHECK_TEST=%your-repo% 
   ```
 ## Contact
 `#team-lsg-qe-core`
