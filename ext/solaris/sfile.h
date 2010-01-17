#define SOLARIS_VERSION "0.3.5"
#define MAX_STRING 512

VALUE cSolarisFileError;
VALUE sACLStruct;

/*
 * Converts a numeric ACL type into a human readable string.
 */
static VALUE acl_type_string(int acl_type){
   VALUE rbACLType;

   switch(acl_type){
      case USER: case USER_OBJ:
         rbACLType = rb_str_new2("user");
         break;
      case GROUP: case GROUP_OBJ:
         rbACLType = rb_str_new2("group");
         break;
      case OTHER_OBJ:
         rbACLType = rb_str_new2("other");
         break;
      case CLASS_OBJ:
         rbACLType = rb_str_new2("mask");
         break;
      case DEF_USER: case DEF_USER_OBJ:
         rbACLType = rb_str_new2("defaultuser");
         break;
      case DEF_GROUP: case DEF_GROUP_OBJ:
         rbACLType = rb_str_new2("defaultgroup");
         break;
      case DEF_OTHER_OBJ:
         rbACLType = rb_str_new2("defaultother");
         break;
      case DEF_CLASS_OBJ:
         rbACLType = rb_str_new2("defaultmask");
         break;
      default:
         rbACLType = rb_str_new2("unknown");
   }
   return rbACLType;
}

/*
 * Helper function used by the acl_write_text class and instance methods.
 */
void do_acl_check(int aclcheck_val, int which){
   char err[MAX_STRING];

   switch(aclcheck_val){
      case 0:
         break; /* Nothing wrong */
      case USER_ERROR:
         sprintf(err,"Invalid ACL entry: %i; Multiple user entries", which);
         rb_raise(cSolarisFileError,err);
      case GRP_ERROR:
         sprintf(err,"Invalid ACL entry: %i; Multiple group entries", which);
         rb_raise(cSolarisFileError,err);
      case OTHER_ERROR:
         sprintf(err,"Invalid ACL entry: %i; Multiple other entries", which);
         rb_raise(cSolarisFileError,err);
      case CLASS_ERROR:
         sprintf(err,"Invalid ACL entry: %i; Multiple mask entries", which);
         rb_raise(cSolarisFileError,err);
      case DUPLICATE_ERROR:
         sprintf(err,"Invalid ACL entry: %i; Multiple user or group entries", which);
         rb_raise(cSolarisFileError,err);
      case ENTRY_ERROR:
         sprintf(err,"Invalid ACL entry: %i; Invalid entry type", which);
         rb_raise(cSolarisFileError,err);
      case MISS_ERROR:
         rb_raise(cSolarisFileError, "Missing ACL entries");
      case MEM_ERROR:
         rb_raise(cSolarisFileError, "Out of memory!");
      default:
         rb_raise(cSolarisFileError, "Unknown error");
   };
}
