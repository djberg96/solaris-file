module Solaris
  module Constants
    GETACL = 1
    SETACL = 2
    GETACLCNT = 3
    MIN_ACL_ENTRIES = 4

    USER_OBJ      = (0x01)
    USER          = (0x02)
    GROUP_OBJ     = (0x04)
    GROUP         = (0x08)
    CLASS_OBJ     = (0x10)
    OTHER_OBJ     = (0x20)
    ACL_DEFAULT   = (0x1000)
    DEF_USER_OBJ  = (ACL_DEFAULT | USER_OBJ)
    DEF_USER      = (ACL_DEFAULT | USER)
    DEF_GROUP_OBJ = (ACL_DEFAULT | GROUP_OBJ)
    DEF_GROUP     = (ACL_DEFAULT | GROUP)
    DEF_CLASS_OBJ = (ACL_DEFAULT | CLASS_OBJ)
    DEF_OTHER_OBJ = (ACL_DEFAULT | OTHER_OBJ)

    GRP_ERROR       = 1
    USER_ERROR      = 2
    OTHER_ERROR     = 3
    CLASS_ERROR     = 4
    DUPLICATE_ERROR = 5
    MISS_ERROR      = 6
    MEM_ERROR       = 7
    ENTRY_ERROR     = 8
  end
end
