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
